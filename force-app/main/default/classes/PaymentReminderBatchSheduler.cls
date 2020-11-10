/*
Name        :    PaymentReminderBatchSheduler
Date        :    24th September, 2020
Author      :  	 Infoglen
Description :    This batch class is used to shedule the PaymentReminderBatch
*/

global class PaymentReminderBatchSheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        PaymentReminderBatch paymentReminder = new PaymentReminderBatch();//Creating Batch Object
        database.executebatch(paymentReminder);//Executing batch 
    }
}