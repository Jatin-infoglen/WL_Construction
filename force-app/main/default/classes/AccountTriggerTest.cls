@isTest
public class AccountTriggerTest {
    
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
        Order testOrder = [SELECT Id ,Status FROM Order LIMIT 1];
        testOrder.Status ='Activated';
        Update testOrder;
        
        Id profId  = TestDataFactory.getProfileId('System Administrator');
        User curUser = TestDataFactory.createUser(false);
        curUser.ProfileId = profId;
        
        System.runAs(curUser){
            testAccount.ownerId = curUser.id;
            Update testAccount;
        }
    }
    
}