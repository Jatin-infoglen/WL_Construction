/*
Date        :    28th September, 2020
Author      :  	 Infoglen
APEX CLASS NAME       :   OrderTriggerTest
DESCRIPTION           :   This is test class for OrderTrigger
*/
@IsTest
public class OrderTriggerTest {
    @testsetup
    private static void setupMethod(){
        Account testAccount = TestDataFactory.createAccount(True);
        Opportunity opp = TestDataFactory.createOpportunity(testAccount.Id,True);
        
        Id pricebookId = Test.getStandardPricebookId();
        Order ord = TestDataFactory.createOrder(testAccount.Id,opp.Id,pricebookId,RecordTypes.standardOrder,True);
        
        
        Product2 prdct = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebookId,prdct.Id,true);
        
        OrderItem ordItm = TestDataFactory.createOrderItem(ord.Id,pricebookEntry.Id,prdct.Id,True);
        ord.Status = 'Activated';
        update ord;
        
        Order creditOrd = TestDataFactory.createOrder(testAccount.Id, opp.Id, pricebookId, RecordTypes.CreditMemo, false);
        creditOrd.OriginalOrder__c = ord.Id;
        Insert creditOrd;
        
    }
    @isTest
    private static void unitTest1(){
        
        Account testAccount = [SELECT Id,OwnerId FROM Account LIMIT 1];
        system.assert(testAccount.Id !=Null);
        
        Order testOrder = [SELECT Id ,Status FROM Order WHERE recordtypeId =:Recordtypes.CreditMemo LIMIT 1];
        Product2 crditPrd = [SELECT Id FROM Product2 LIMIT 1];
        
        system.assert(crditPrd.Id !=Null);
        
        PricebookEntry prcEntry = [SELECT Id FROM PricebookEntry Limit 1];
        OrderItem creditOrdItm = TestDataFactory.createOrderItem(testOrder.Id,prcEntry.Id,crditPrd.Id,true);
        
        testOrder.Status = 'Credit Memo';
        update testOrder;
        
    }
    
    @isTest
    private static void unitTest2(){
        Account testAccount = [SELECT Id,OwnerId FROM Account LIMIT 1];
        system.assert(testAccount.Id != Null);
        
        Order testOrder = [SELECT Id ,Status FROM Order WHERE recordtypeId =:Recordtypes.standardOrder LIMIT 1];
        System.assert(testOrder.Id !=Null);
        
        testOrder.PaymentType__c = 'Cash';
        testOrder.DiscountAmount__c = 1;
        testOrder.Status = 'paid';
        update testOrder;
        
    }
    
}