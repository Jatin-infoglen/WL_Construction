@isTest
public class AccountUpdatesQueueBatchTest {
    @testsetup
    private static void setupMethod(){
        
        Account testAccount = TestDataFactory.createAccount(True);
        Opportunity opp = TestDataFactory.createOpportunity(testAccount.Id,True);
        
        Id pricebookId = Test.getStandardPricebookId();
        Order ord = TestDataFactory.createOrder(testAccount.Id,opp.Id,pricebookId,RecordTypes.standardOrder,True);
        
        
        Product2 prdct = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebookId,prdct.Id,true);
        
        OrderItem ordItm = TestDataFactory.createOrderItem(ord.Id,pricebookEntry.Id,prdct.Id,True);
        
    }
    
    @isTest
    private static void unitTest1(){
        Account testAccount = [SELECT Id,LastActivatedOrderDate__c FROM Account LIMIT 1];
        System.assert(testAccount.Id !=Null);
        
        Order testOrder = [SELECT Id ,Status FROM Order WHERE recordtypeId =:Recordtypes.standardOrder LIMIT 1];
        system.assert(testOrder.Id != Null);
        
        testOrder.Status ='Activated';
        Date startDate = Date.newInstance(2017,10,7);
        testOrder.ActivatedDate = startDate;
        Update testOrder;
        
        testAccount.LastActivatedOrderDate__c =startDate;
        Update testAccount;
        
     
       AccountUpdatesQueueBatchSheduler accountBatchSheduler = new AccountUpdatesQueueBatchSheduler();
        accountBatchSheduler.execute(null);
        
    }
}