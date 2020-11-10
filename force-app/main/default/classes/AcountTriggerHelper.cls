/**
Name                   :        AcountTriggerHelper         
Author                 :        Infoglen
Date                   :        11 October, 2020
Description            :        This is a Helper Of accou Trigger.
**/

public class AcountTriggerHelper {
        //
        //This method is used to Update the Owner of Accociated Oredrs of Account
        public static void updateOrderOwner(Map<Id,Account> accountWithOwner){
            
            system.debug('updateOrderOwner method call---');
            //This List is used to Store Updated Oredrs
            List<Order> orderToUpdateWithOwner = new List<Order>();
            
            for(Order ord : [SELECT Id,AccountId,ownerId,Status FROM Order WHERE AccountId IN : accountWithOwner.keySet() ]){
             
                if((ord.Status =='Activated' || ord.Status =='Paid' || ord.Status =='Credit Memo') && accountWithOwner.containskey(ord.AccountId)){
                        ord.OwnerId = accountWithOwner.get(ord.AccountId).ownerId;
                        orderToUpdateWithOwner.add(ord);
                }
            }
            //Updating Orders
            if(orderToUpdateWithOwner.size() > 0)
                update orderToUpdateWithOwner;
        }
        
    }