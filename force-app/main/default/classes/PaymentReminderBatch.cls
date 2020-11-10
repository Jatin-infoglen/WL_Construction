/**
Name                   :        PaymentReminderBatch         
Author                 :        Infoglen
Date                   :        24th September, 2020
Description            :        This Class is Used to create task On due date
**/

global class PaymentReminderBatch implements  Database.Batchable<sObject>{
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        // collect the Refferral discount records to be passed to execute
        String query = 'SELECT Id,Total_Amount__c,AccountId,opportunityId FROM order WHERE Status =\'Activated\' AND  DueDate__c = Today AND TaskCreated__c = False AND Total_Amount__c > 0';
        return Database.getQueryLocator(query);
        
        
    }
    //Execute Method
    global void execute(Database.BatchableContext bc, List<Order> oredrList){
        
        Map<Id,Id> orderWithOpportunityId = new Map<Id,Id>();
        List<Task> tasksToInsert =  new List<Task>();
        
        For(Order orderObj : oredrList ){
            orderWithOpportunityId.put(orderObj.Id,orderObj.OpportunityId);
        }
        
        if(orderWithOpportunityId.size() > 0){
            //Getting Task 
            tasksToInsert = WlUtility.taskCreationOnOrder(orderWithOpportunityId,True);
        }
        
        if(tasksToInsert.size() > 0){
            Database.SaveResult[] taskList = Database.insert(tasksToInsert, false);
            system.debug('taskList--->'+taskList);
        }
        
        
    }
    global void finish(Database.BatchableContext BC){
    }
}