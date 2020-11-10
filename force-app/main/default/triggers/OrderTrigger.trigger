/**
Name                   :        OrderTrigger         
Author                 :        Infoglen
Date                   :        24th September, 2020
Description            :        This is Used to perform action Order.
**/

trigger OrderTrigger on Order (before insert, before update, after update) {
    
    
    //Order Insert Start
    if(Trigger.isinsert){
        //Order Before Insert Start
        if(Trigger.isBefore){
            system.debug('in before insert');
            //Used to Store Opportunity Ids for Order Creation
            Set<Id> opportunityIdsForOrder = new Set<Id> ();
            
            for(Order ordObj : Trigger.new){
                if(ordObj.opportunityId !=Null && ordObj.RecordTypeId !=Null ){
                    //Filling Opportunitiesd Ids
                    opportunityIdsForOrder.add(ordObj.opportunityId);
                }
            }
            
            if(opportunityIdsForOrder.size() > 0){
                
                //Checking Opportunities if they have More than 2 Orders With Same Record Type
                Map<String,Integer> opportunityNdOrderCountmap = OrderTriggerHelper.orderCountCheckOnOpportunity(opportunityIdsForOrder);
                
                for(Order ordObj : Trigger.new){
                    //Unique key With combinationof Opportunity Id and RecordType Id
                    String key = ordObj.OpportunityId +'-'+ ordObj.RecordTypeId;
                    
                    if(opportunityNdOrderCountmap.containskey(key) && opportunityNdOrderCountmap.get(key) > 0){
                        ordObj.addError('Opportunity Can’t have more then 1 Orders with same type');
                    }
                }
            }
        }//Order Before Insert End
        
    }//Order Insert End
    
    //Order Update Start
    if(Trigger.isUpdate ){
        
        Id creditMemoRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
        //Order Update After Start
        if(Trigger.isAfter){
            
            //Use to store Account Id
            Set<Id> orderSumAccountIds = new Set<Id>();
            //used to store Opportunity Ids
            Set<Id> orderSumOpportunityIds = new Set<Id>();
            //Paid Order Ids
            Set<Id> paidOrderIds = new Set<Id>();
             //Use to store Order Ids with opportunity Ids
            Map<Id,Id> orderwithOpportunityIdsMap = new Map<Id,Id>();
            //
            Map<Id,Decimal> orignalOrderWithDiscount = new Map<Id,Decimal>();
            
            List<Order> orignalOrdersList = new List<Order>();
            
            //Checking Order Conditions
            for(Order orderObj : Trigger.New){
                
                //Paid order Details for Task Creation
                if((orderObj.Status =='Paid' && orderObj.Total_Amount__c != Null && orderObj.AccountId !=Null && orderObj.ownerId != Null && orderObj.OpportunityId !=Null ) 
                   && (Trigger.OldMap.get(orderObj.Id).Status != orderObj.Status)){
                       orderwithOpportunityIdsMap.put(orderObj.Id,orderObj.OpportunityId);
                   } 
                //Order Total for Paid and Activated Orders
                if((orderObj.AccountId !=Null && orderObj.OpportunityId !=Null) && (orderObj.Status == 'Activated' || orderObj.Status == 'Paid' || orderObj.Status == 'Credit Memo')){
                    orderSumAccountIds.add(orderObj.AccountId); 
                    orderSumOpportunityIds.add(orderObj.OpportunityId);
                } 
                //Paid Orders to update Paid date
                if(orderObj.Status =='Paid' && (Trigger.OldMap.get(orderObj.Id).Status != orderObj.Status) && System.Label.Account_Activated_Date_Migrate =='True'){
                    paidOrderIds.add(orderObj.Id);
                }
               
                //Credit Memo Amount Include in Orignal Order
                if(orderObj.Status =='Credit Memo' && Trigger.OldMap.get(orderObj.Id).Status != orderObj.Status && orderObj.RecordTypeId == creditMemoRecordType){
                    orignalOrdersList.add(new Order(Id = orderObj.OriginalOrder__c, CreditMemoOrderAmount__c = orderObj.Total_Amount__c));
                }
                
                if(orderObj.Status != 'Draft' && orderObj.RecordTypeId == RecordTypes.standardOrder  && orderObj.DiscountAmount__c != Trigger.oldMap.get(orderObj.Id).DiscountAmount__c){
                    orignalOrderWithDiscount.put(orderObj.Id,orderObj.DiscountAmount__c );
                }
            }
            
            //Calling Helper Methods to Implement Logic
            
            if(orderwithOpportunityIdsMap.size() > 0)
                OrderTriggerHelper.CreateTaskOnOrder(orderwithOpportunityIdsMap);
            
            if(orderSumAccountIds.size() > 0)
                OrderTriggerHelper.updateCreditOrderAccounts(orderSumAccountIds);
            
            if(orderSumOpportunityIds.size() > 0)
                OrderTriggerHelper.updateOpportunitys(orderSumOpportunityIds);
            
            if(paidOrderIds.size() > 0)
                OrderTriggerHelper.paidOrderDateUpdate(paidOrderIds);
            
            //Credit Memo Balance
            if(orignalOrdersList.size() > 0)
                OrderTriggerHelper.updateCreditMemoOrderAmount(orignalOrdersList);
            
            if(orignalOrderWithDiscount.size() > 0 && orignalOrderWithDiscount !=Null)
                OrderTriggerHelper.updateCreditMemoDiscount(orignalOrderWithDiscount);
            
        }  //Order Update After End
    }//Order Update End
}