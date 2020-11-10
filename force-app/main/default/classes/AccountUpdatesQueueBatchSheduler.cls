/*
Name        :    AccountUpdatesQueueBatchSheduler
Date        :    12 October, 2020
Author      :  	 Infoglen
Description :    This batch class is used to shedule the AccountUpdatesQueueBatchSheduler
*/

global class AccountUpdatesQueueBatchSheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        AccountUpdatesQueueBatch accountrevievable = new AccountUpdatesQueueBatch();//Creating Batch Object
        database.executebatch(accountrevievable);//Executing batch 
    }
    
}