@isTest
public class OrderItemTriggerTest {
    @testsetup
    private static void setupMethod(){
        Account testAccount = TestDataFactory.createAccount(True);
        Opportunity opp = TestDataFactory.createOpportunity(testAccount.Id,True);
        
        Id pricebookId = Test.getStandardPricebookId();
        Order ord = TestDataFactory.createOrder(testAccount.Id,opp.Id,pricebookId,RecordTypes.standardOrder,True);
        
        
        Product2 prdct = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebookId,prdct.Id,true);
        
        OrderItem ordItm = TestDataFactory.createOrderItem(ord.Id,pricebookEntry.Id,prdct.Id,false);
        ordItm.Quantity = 2;
        Insert ordItm;
        
        ord.Status ='Activated';
        Update ord;
        
        Order creditOrd = TestDataFactory.createOrder(testAccount.Id, opp.Id, pricebookId, RecordTypes.CreditMemo, false);
        creditOrd.OriginalOrder__c = ord.Id;
        Insert creditOrd;
        
        
    }
    @isTest
    private static void unitTest1(){
        try{
            Order creditOrder = [SELECT Id,status FROM Order WHERE RecordtypeId =:RecordTypes.CreditMemo];
            PricebookEntry prcEntry = [SELECT Id FROM PricebookEntry Limit 1];
            Product2 crditPrd = [SELECT Id FROM Product2 LIMIT 1];
            
            OrderItem creditOrdItm = TestDataFactory.createOrderItem(creditOrder.Id,prcEntry.Id,crditPrd.Id,false);
            creditOrdItm.Quantity = 3;
            Insert creditOrdItm;
        }catch(exception e){
            system.debug('in catch -->'+e);
        }
    }
    @isTest
    private static void unitTest2(){
        try{
            Order creditOrder = [SELECT Id,status FROM Order WHERE RecordtypeId =:RecordTypes.CreditMemo];
            PricebookEntry prcEntry = [SELECT Id FROM PricebookEntry Limit 1];
            Product2 crditPrd = [SELECT Id FROM Product2 LIMIT 1];
            
            OrderItem creditOrdItm = TestDataFactory.createOrderItem(creditOrder.Id,prcEntry.Id,crditPrd.Id,false);
            creditOrdItm.Quantity = 2;
            creditOrdItm.UnitPrice = 3000;
            Insert creditOrdItm;
        }catch(exception e){
            system.debug('in catch -->'+e);
        }
    }
    @isTest
    private static void unitTest3(){
        try{
            Order creditOrder = [SELECT Id,status FROM Order WHERE RecordtypeId =:RecordTypes.CreditMemo];
            PricebookEntry prcEntry = [SELECT Id FROM PricebookEntry Limit 1];
            Product2 crditPrd = [SELECT Id FROM Product2 LIMIT 1];
            
            OrderItem creditOrdItm = TestDataFactory.createOrderItem(creditOrder.Id,prcEntry.Id,crditPrd.Id,true);
            OrderItem creditDuplicateOrdItm = TestDataFactory.createOrderItem(creditOrder.Id,prcEntry.Id,crditPrd.Id,true);
        }catch(exception e){
            system.debug('in catch -->'+e);
        }
    }
    @isTest
    private static void unitTest4(){
        try{
            Order creditOrder = [SELECT Id,status FROM Order WHERE RecordtypeId =:RecordTypes.CreditMemo];
            PricebookEntry prcEntry = [SELECT Id FROM PricebookEntry Limit 1];
            Product2 crditPrd =TestDataFactory.createProduct(false);
            
            crditPrd.Name ='Test Cutter';
            crditPrd.ProductCode = 'Test Cutter';
            crditPrd.Description = 'Test Cutter';
            crditPrd.IsActive = true;
            Insert crditPrd;
            
            OrderItem creditOrdItm = TestDataFactory.createOrderItem(creditOrder.Id,prcEntry.Id,crditPrd.Id,true);
            
        }catch(exception e){
            system.debug('in catch -->'+e);
        }
    }
}