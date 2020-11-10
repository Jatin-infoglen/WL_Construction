/**
Name                   :        AccountTrigger         
Author                 :        Infoglen
Date                   :        11 October, 2020
Description            :        This is Used to perform action Account.
**/

trigger AccountTrigger on Account (after update) {
    
    if(Trigger.isAfter){
        
        if(Trigger.isUpdate){
         //This Map is Used to store AccountId with Account details
            Map<Id, Account> accountWithOwner = new Map<Id, Account>();
            for(Account acct : Trigger.New){
                if(acct.OwnerId != trigger.oldMap.get(acct.Id).OwnerId ){
                    system.debug('acctin account TRigger --->'+acct);
                    accountWithOwner.put(acct.Id,acct);
                }
            }
            
            //Helper Calling
            if(accountWithOwner.size() > 0)
                AcountTriggerHelper.updateOrderOwner(accountWithOwner);
        }
    }
    
}