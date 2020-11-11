/**@@
#APEX CLASS NAME       :    TestDataFactory
#DESCRIPTION           :    This is Utility class used for test data creation
@@**/
@isTest
public with sharing class TestDataFactory{
    
    public static Account createAccount(Boolean isInsert){
        
        Account acc = new Account();
        acc.Name = 'ACCENT LANDSCAPES'; // Account Name
        acc.Phone = '317-769-2020';  // Phone
        
        if(isInsert)
            insert acc;
        return acc;
    }
    
    public static Id getProfileId(String profileName){
        Profile curProf = [SELECT Id FROM Profile where name=:profileName limit 1];
        return curProf.Id;
    }
    
    public static User createUser(Boolean isInsert){
        User userToInsert = new User();
        userToInsert.Alias = 'test'; 
        userToInsert.Email='test@testorg.com';
        userToInsert.EmailEncodingKey='UTF-8';
        userToInsert.FirstName='Infoglen';
        userToInsert.LastName='Testing';
        userToInsert.LanguageLocaleKey='en_US'; 
        userToInsert.LocaleSidKey='en_US';
        userToInsert.TimeZoneSidKey='America/Los_Angeles';
        userToInsert.UserName='infoglenTest@test.com';
        
        if(isInsert)
            Insert userToInsert;
        return userToInsert;
    }
    
    Public static Opportunity createOpportunity(Id accountId,Boolean isInsert){
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'Florida Pest Control/Chemical-';// Opportunity Name
        oppObj.AccountId = accountId;                  // Account Name
        oppObj.CloseDate = system.today();   // Close Date
        oppObj.StageName = 'Closed Won';                 // Stage
        oppObj.LeadSource = 'Excellent';                 // Lead Source
        
        if(isInsert)
            Insert oppObj;
        return oppObj;
    }
    public static Order createOrder(Id accountId,Id opportunityId,Id priceBookId, Id recordtypeId,Boolean isInsert){
        Order orderObj = new Order();
        orderObj.AccountId = accountId;
        //Pricebook2Id = '01s4W000001Yj6rQAC';
        orderObj.OpportunityId = opportunityId;
        orderObj.RecordTypeId = recordtypeId;
        orderObj.Pricebook2Id = priceBookId;
        orderObj.EffectiveDate = system.today();
        orderObj.Status = 'Draft';
        orderObj.ShippingFees__c = 20.01;
        if(isInsert)
            insert orderObj;
        return orderObj;
    }
    public static OrderItem createOrderItem(Id orderId,Id priceBookentryId,Id productId,Boolean isInsert){
        OrderItem orderitemObj = new OrderItem();
        orderitemObj.Quantity = 1;
        orderitemObj.UnitPrice = 2299.99;
        orderitemObj.OrderId = orderId;
        orderitemObj.PricebookEntryId = priceBookentryId;
        orderitemObj.Product2Id = productId;
        if(isInsert)
            insert orderitemObj;
        return orderitemObj;        
    }
    public static Product2 createProduct(Boolean isInsert){
        Product2 product2Obj = new Product2();
        product2Obj.Name = 'PERFECT TRAC SAW';
        product2Obj.ProductCode = 'PERFECT TRAC SAW';
        product2Obj.Description = 'PERFECT TRAC CONCRETE SAW';
        product2Obj.IsActive = true;
        if(isInsert)
            insert product2Obj;
        return product2Obj;
    }
    
    public static PricebookEntry createPricebookEntry (Id standard, Id prod,Boolean isInsert) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standard;
        one.product2id = prod;
        one.unitprice = 2299.99;
        one.isactive = true;
        if(isInsert)
            insert one;
        return one;
    }
    public static Task createTask(Id orderId,Id opportunityId,Id recordTypeId,Id AccountId,Boolean isInsert){
        Task taskObj  = new Task();
        taskObj.Subject = 'Payment Reminder';       // Subject
        taskObj.WhatId = AccountId;                // Related To
        taskObj.Order__c = orderId;                // Order
        taskObj.Priority = 'High';                 // Priority
        taskObj.RecordTypeId = recordTypeId;
        taskObj.ActivityDate = system.today();
        taskObj.Opportunity__c = opportunityId;
        
        if(isInsert)
            insert taskObj;
        return taskObj;
    }
    
    public static Contact createContact(Id accountId,Boolean isInsert){
        Contact con = new Contact();
        con.FirstName = 'Bob';
        con.LastName  = 'Test';
        con.AccountId = accountId;
        con.MailingStreet = '298 S. Ringo Street';
        con.Phone = '123456789';
        con.MailingCity = 'Little Rock';
        con.MailingState = 'AR';
        con.MailingPostalCode = '72201'; 
        if(isInsert)
            insert con;
        return con;
        
    }
    
    public static OpportunityContactRole createOpportunityContactRole(Id contactId,Id opportunityId,Boolean isInsert){
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = contactId;
        ocr.OpportunityId = opportunityId;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        if(isInsert)
            insert ocr;
        return ocr;
    }
}