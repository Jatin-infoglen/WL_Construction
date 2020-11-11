/*
Date        :    28th September, 2020
Author      :  	 Infoglen
APEX CLASS NAME       :   PaymentReminderBatchShedulerTest
DESCRIPTION           :   This is test class for PaymentReminderBatch
*/
@IsTest

public class PaymentReminderBatchShedulerTest {
    
    @testsetup
    private static void setupMethod(){
        Account testAccount = TestDataFactory.createAccount(True);
        Contact testContact = TestDataFactory.createContact(testAccount.Id, True);
        
        Opportunity opp = TestDataFactory.createOpportunity(testAccount.Id,True);
        OpportunityContactRole testContactRole = TestDataFactory.createOpportunityContactRole(testContact.Id, opp.Id, True);
        
        Id pricebookId = Test.getStandardPricebookId();
        Order ord = TestDataFactory.createOrder(testAccount.Id,opp.Id,pricebookId,RecordTypes.standardOrder,True);
        
  
        Product2 prdct = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebookId,prdct.Id,true);
        
        OrderItem ordItm = TestDataFactory.createOrderItem(ord.Id,pricebookEntry.Id,prdct.Id,True);
        
    }
    
    @isTest
    private static void unitTest1(){
        Account testAccount = [SELECT Id,OwnerId FROM Account LIMIT 1];
        system.assert(testAccount.Id !=Null);
        
        Order testOrder = [SELECT Id ,Status FROM Order WHERE recordtypeId =:Recordtypes.standardOrder LIMIT 1];
        testOrder.Status ='Activated';
        Update testOrder;
        
        PaymentReminderBatchSheduler paymnetsheduler = new PaymentReminderBatchSheduler();
        paymnetsheduler.execute(Null);
        
    }
    
}