/*
Name        :    AccountUpdatesQueueBatch
Date        :    12 October, 2020
Author      :  	 Infoglen
Description :    This batch class is used to shedule the AccountUpdatesQueueBatch
*/

global class AccountUpdatesQueueBatch implements  Database.Batchable<sObject>{
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,LastActivatedOrderDate__c,UpdateAccountDate__c FROM Account WHERE LastActivatedOrderDate__c !=Null AND LastActivatedOrderDate__c < Today AND UpdateAccount__c = false';
        // collect the Last Order Activity Date of Account
          return Database.getQueryLocator(query);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext bc, List<Account> accountOrderActivityList){
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account accObj : accountOrderActivityList){
            Integer updateAccountMonthCount = WLUtility.dateDiffrence(accObj.UpdateAccountDate__c);
            system.debug('updateAccountMonthCount-->'+updateAccountMonthCount);
            Integer lastActivatedDateMonthCount = WLUtility.dateDiffrence(accObj.LastActivatedOrderDate__c);
            system.debug('lastActivatedDateMonthCount-->'+lastActivatedDateMonthCount);
          
            /*IF(accObj.LastActivatedOrderDate__c.monthsBetween(System.today()) >= 18 &&
               (accObj.UpdateAccountDate__c == Null || accObj.UpdateAccountDate__c.monthsBetween(System.today()) >= 18)){*/
            
            IF(lastActivatedDateMonthCount >= 18 && (accObj.UpdateAccountDate__c == Null || lastActivatedDateMonthCount >= 18)){
                 
                  //Filling Account
                   accObj.UpdateAccount__c = true;
                   accObj.UpdateAccountDate__c = system.today();
                   accountsToUpdate.add(accObj);
               }
        }
        
        //Update Accounts with Account Update Date and Update Account checkBox
        if(accountsToUpdate.size() > 0){
            system.debug('accountsToUpdate--->'+accountsToUpdate);
             Database.SaveResult[] accountList = Database.update(accountsToUpdate, false);
				//system.debug('accountList-->'+accountList);
        }        
    }
    
    //Finish Method
    global void finish(Database.BatchableContext BC){
    }
}