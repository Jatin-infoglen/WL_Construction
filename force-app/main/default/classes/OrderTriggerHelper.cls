/**
Name                   :        OrderTriggerHelper         
Author                 :        Infoglen
Date                   :        24th September, 2020
Description            :        This Class is Used to perform Logic on Order Trigger.
**/
public class OrderTriggerHelper {
    
    //This Method is used to create task on Order with Conatact, Account and Opportunity
    public static void CreateTaskOnOrder(Map<Id,Id> orderIds){
        system.debug('CreateTaskOnOrder call -->'+orderIds);
        if(orderIds.size() > 0){
            //List To store task That will be insert
            List<Task> tasksToInsert =  new List<Task>();
            
            //Getting Task 
            tasksToInsert = WlUtility.taskCreationOnOrder(orderIds,False);
            system.debug('tasksToInsert-->'+tasksToInsert);
            //Inserting Task
            if(tasksToInsert.size() > 0)
                INSERT tasksToInsert;
        }
    }
    
    //This method is used to Update Total amount of Order on Account
    public static void updateCreditOrderAccounts(Set<Id> AccountsIds){
        
        //This Map is Used to store Total order Amount Of Related Orders
        Map<Id,Decimal> totalOrderAmountMap = new Map<Id, Decimal>();
        //This Map is used to store Paid Amount of Related orders Of Account
        Map<Id,Decimal> paidOrderAmountMap = new Map<Id, Decimal>();
        //use to update Accounts
        List<Account>AccountToUpdates = new List<Account>();
        
        
        //Getting Sum of Total Amount of All the Orders
        for(AggregateResult agriObj : [SELECT AccountId, SUM(Total_Amount__c)totalAmount FROM Order WHERE AccountId IN : AccountsIds AND (status ='Paid' /*OR status ='Credit Memo'*/ OR status ='Activated') Group by AccountId]){
            totalOrderAmountMap.put((Id)agriObj.get('AccountId'),(Decimal)agriObj.get('totalAmount'));
        }
        
        //Getting Sum of Total Amount of Psid Orders
        for(AggregateResult agriObj : [SELECT AccountId, SUM(Total_Amount__c)paidAmount FROM Order WHERE AccountId IN : AccountsIds AND status ='Paid' Group by AccountId]){
            paidOrderAmountMap.put((Id)agriObj.get('AccountId'),(Decimal)agriObj.get('paidAmount'));
        }
        
        //This is used to store Activated date Of Order
        Map<Id, DateTime> orderActivatedDateWithAccoutIdsMap = WlUtility.lastOrderActivatedDateCalc(accountsIds);
        system.debug('orderActivatedDateWithAccoutIdsMap--->'+orderActivatedDateWithAccoutIdsMap);
       
        for(String accountId : AccountsIds){
            //Account With Activated date, Sum of Total Amount
            Account customer =  new Account();
            customer.Id = accountId;
            
            if(orderActivatedDateWithAccoutIdsMap != Null && orderActivatedDateWithAccoutIdsMap.containsKey(accountId) && System.Label.Account_Activated_Date_Migrate =='True')
                customer.LastActivatedOrderDate__c = orderActivatedDateWithAccoutIdsMap.get(accountId).date();
            
            //If Order Containt Account Push Total Order Amount on Order
            if(totalOrderAmountMap.containsKey(accountId)){
                customer.OrderTotal__c = totalOrderAmountMap.get(accountId);
            }else{
                customer.OrderTotal__c = 0;
            }	
            if(totalOrderAmountMap.containsKey(accountId) || paidOrderAmountMap.containsKey(accountId) /*|| creditOrderAmountMap.containsKey(accountId)*/ ){
               
                Decimal paidAmount = paidOrderAmountMap.containsKey(accountId)  ? paidOrderAmountMap.get(accountId) : 0;
                Decimal totalAmount = totalOrderAmountMap.containsKey(accountId) ? totalOrderAmountMap.get(accountId) : 0;
                customer.OpenBalance__c = totalAmount - paidAmount;
            }
            
            //Adding Accounts in List To update
            AccountToUpdates.add(customer);
        }
        
        //Updating Account
        if(AccountToUpdates.size() > 0)
            update AccountToUpdates;
    }
    
    
    //This method is USed to Update Total amount of Order on Opportunity
    public static void updateOpportunitys(Set<Id> OpportunityIds){
        
        Map<Id,Decimal> totalOrderAmountMap = new Map<Id, Decimal>();
        Map<Id,Decimal> paidOrderAmountMap = new Map<Id, Decimal>();
        List<Opportunity>opportunityToUpdates = new List<Opportunity>();
        
        for(AggregateResult agriObj : [SELECT OpportunityId, SUM(Total_Amount__c)totalAmount FROM Order WHERE OpportunityId IN : OpportunityIds AND (status ='Paid' /*OR status ='Credit Memo'*/ OR status ='Activated') Group by OpportunityId]){
            totalOrderAmountMap.put((Id)agriObj.get('OpportunityId'),(Decimal)agriObj.get('totalAmount'));
        }
        
        for(String OpportunityId : OpportunityIds){
            
            Opportunity opportunity =  new Opportunity();
            opportunity.Id= OpportunityId;
            
            if(totalOrderAmountMap.containsKey(OpportunityId)){
                opportunity.OrderTotal__c = totalOrderAmountMap.get(OpportunityId);
            }else{
                opportunity.OrderTotal__c = 0;
            }	
            opportunityToUpdates.add(opportunity);
        }
        
        if(opportunityToUpdates.size() > 0)
            update opportunityToUpdates;
        
    }
    //This method is used to Check order on Opportunity
    public static Map<String,Integer> orderCountCheckOnOpportunity(Set<Id> opportunityIds){
        
        //This Map is used to store Recordtype with Count
        Map<String,Integer> countOfRecordTypeMap = new Map<String,Integer>();
        
        for(Order ordObj : [SELECT Id, RecordTypeId, RecordType.name, OpportunityId from Order where OpportunityId IN : opportunityIds]){
            //Creating unique key with Opportunity id and Recordtype Id
            String key = ordObj.OpportunityId +'-'+ordObj.RecordTypeId;
            
            if(countOfRecordTypeMap.containsKey(key)){
                countOfRecordTypeMap.put(key, (countOfRecordTypeMap.get(key) + 1));
            }else{
                countOfRecordTypeMap.put(key, 1);
            }
        }
        return countOfRecordTypeMap;
    }
    
    //This method is used to Update Paid date On Order When the order Status become Paid
    public static void paidOrderDateUpdate(Set<Id> paidOrderIds){
        List<Order> paidOrderDatesToUpdate = new List<Order>();
        If(paidOrderIds.size() > 0){
            for(Order ordObj : [SELECT Id,Status,OrderPaidDate__c FROM Order WHERE Id In : paidOrderIds]){
                ordObj.OrderPaidDate__c = system.today();
                paidOrderDatesToUpdate.add(ordObj);
            }
            if(paidOrderDatesToUpdate.size() > 0)
                Update paidOrderDatesToUpdate;
        }
    }
    //this method is used to update creditMemoOrderAmount when totalAmount becomes negative
    public static void updateCreditMemoOrderAmount(List<Order> lstOrdersToUpdate){
        system.debug('updateCreditMemoOrderAmount call -->'+lstOrdersToUpdate);
        if(lstOrdersToUpdate.size() > 0) 
            update lstOrdersToUpdate;
    }
    
    //This methos is used to update the credit memo orders Discount
    public static void updateCreditMemoDiscount(Map<Id,Decimal> orignalOrdersWithDiscount){
        system.debug('updateCreditMemoDiscount call-->'+orignalOrdersWithDiscount);
        List<Order> creditMemoOrdersToUpdate = new List<Order>();
        For(Order crediOrdr : [SELECT Id,DiscountAmount__c,OriginalOrder__c FROM Order WHERE Status ='Draft' AND OriginalOrder__c IN : orignalOrdersWithDiscount.keySet()]){
            if(orignalOrdersWithDiscount.containsKey(crediOrdr.OriginalOrder__c)){
                Order creditMemoOrder = new order();
                creditMemoOrder.Id = crediOrdr.Id;
                creditMemoOrder.DiscountAmount__c = orignalOrdersWithDiscount.get(crediOrdr.OriginalOrder__c) > 0 ? orignalOrdersWithDiscount.get(crediOrdr.OriginalOrder__c) : 0;
                creditMemoOrdersToUpdate.add(creditMemoOrder);
            }
        }
        
        if(creditMemoOrdersToUpdate.size() > 0)
        Update creditMemoOrdersToUpdate;
    }
}