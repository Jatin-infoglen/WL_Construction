/**
Name                   :        TaskTrigger         
Author                 :        Infoglen
Date                   :        28th October, 2020
Description            :        This is Used to perform action on Task.
**/
trigger TaskTrigger on Task (After Update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        //This map is used to store Task with subordinate Orders
        Map<Id,Task> tasksWithOrderIdMap = new Map<Id, Task>();   
        
        for(Task taskObj : Trigger.new){
            
            if(taskObj.AccountReceivable__c == TRUE && taskObj.Order__c != NULL && taskObj.Status == 'Completed' && taskObj.CreditCardDate__c != NULL ){
                tasksWithOrderIdMap.put(taskObj.Order__c, taskObj);
            }
        }
        
        //Calling Helpers
        if(tasksWithOrderIdMap.size() > 0 && tasksWithOrderIdMap  !=Null){
            TaskTriggerHelper.updateOrdersToPaid(tasksWithOrderIdMap);
        }
    }
}