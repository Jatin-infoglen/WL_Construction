@isTest
public class TaskTriggerTest {
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
        Account testAccount = [SELECT Id,OwnerId FROM Account LIMIT 1];
        system.assert(testAccount.Id != Null);
        
        Order testOrder = [SELECT Id ,Status,Total_Amount__c FROM Order LIMIT 1];
        system.assert(testOrder.Id != Null);
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id LIMIT 1];
        
        testOrder.Status ='Activated';
        Update testOrder;
        Task tskObj = TestDataFactory.createTask(testOrder.Id,opp.Id, RecordTypes.PaymentReminderRecordType, testAccount.Id, true);
        
        system.assert(tskObj.Id !=Null);
        
        Task testTask = [SELECT Id,OrderAmount__c,CreditCardAmount__c,AccountReceivable__c,CreditCardDate__c,status FROM Task WHERE id =:tskObj.Id];
        
        testTask.CreditCardDate__c = system.today();
        testTask.Payment_Discount__c = 20;
        testTask.CreditCardAmount__c = 2300;
        testTask.AccountReceivable__c = true;
        update testTask;
        
        testTask.Status ='Completed';
        Update testTask;
    }
    
}