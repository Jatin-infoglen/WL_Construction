/*
Name        :    TaskTriggerHelper
Date        :    28 October, 2020
Author      :  	 Infoglen
Description :    This Helper Class is used to implement logics of TaskTrigger
*/
public class TaskTriggerHelper {
    
    //This method is used to update the Order When full payment  will recieve by task
    public static void updateOrdersToPaid(Map<Id, Task> tasksWithOrderIds){
        
        //This is used to store Oder taht will be update
        List<Order> ordersToUpdate = new List<Order>();
        
        for(Order ordObj : [SELECT Id, Status FROM Order WHERE Status != 'Paid' AND Id IN : tasksWithOrderIds.keySet()]){
            
            //Checking coresponding task with Order
            if(tasksWithOrderIds.containsKey(ordObj.Id)){
                //Storing payment Discount Amount
                Decimal paymentDiscount = tasksWithOrderIds.get(ordObj.Id).Payment_Discount__c > 0 ? tasksWithOrderIds.get(ordObj.Id).Payment_Discount__c : 0; 
                //Storing crdit Card Amount
                Decimal creditCardAmount = tasksWithOrderIds.get(ordObj.Id).CreditCardAmount__c > 0 ? tasksWithOrderIds.get(ordObj.Id).CreditCardAmount__c : 0;
                
                //Checking Oredr amount With Task Amount
                if((paymentDiscount + creditCardAmount) == tasksWithOrderIds.get(ordObj.Id).OrderAmount__c){
                    Order activatedOrder = new Order();
                    activatedOrder.Id = ordObj.Id;
                    activatedOrder.DiscountAmount__c = paymentDiscount;
                    activatedOrder.PaymentType__c =  'Credit Card';
                    activatedOrder.Status = 'Paid';
                    ordersToUpdate.add(activatedOrder);
                }
            }
            
            //Updating Order
            if(ordersToUpdate.size() > 0){
                update ordersToUpdate;
            }
        }
    }
    
}