/*
Name        :    WlUtility
Date        :    24th September, 2020
Author      :  	 Infoglen
Description :    This  class is used to Maintain Comman Logics
*/
public class WlUtility {
    
     public static List<Task> taskCreationOnOrder(Map<Id,Id> orderWithOpportunityIds,Boolean isTaskCreated){
         system.debug('taskCreationOnOrder call -->'+orderWithOpportunityIds);
        if(orderWithOpportunityIds.size() > 0){
            
            //Used to STore Opportunity and Opportunity Contact Information
            Map<Id,OpportunityContactRole> OppContactMap = New Map<Id,OpportunityContactRole>();
            
            //Getting Contact Of Opportunity 
            for(OpportunityContactRole oppContactRole : [SELECT Id, OpportunityId,ContactId,isPrimary ,Contact.Email,Contact.Phone FROM OpportunityContactRole WHERE Contact.Phone !=Null AND OpportunityId IN : orderWithOpportunityIds.Values()/*AND isPrimary = true*/]){
                OppContactMap.Put(oppContactRole.OpportunityId,oppContactRole);
            }
            system.debug('OppContactMap--->'+OppContactMap);
            //Used to store Task That will be Insert
            List<Task> tasksToInsert = new List<Task>();
            List<Order> OrdersToUpadte = new List<Order>();
            
            For(Order orderObj : [SELECT Id,Total_Amount__c,AccountId,TaskCreated__c,Opportunity.ownerId FROM Order Where Id In : orderWithOpportunityIds.keySet() ]){
                //Filling Task Information
                Task taskToInsert = new Task();
                taskToInsert.Status = 'Open';
                taskToInsert.Priority = 'High';
                taskToInsert.Order__c = orderObj.Id;
                taskToInsert.WhatId = orderObj.AccountId;
                taskToInsert.ActivityDate  = System.today() + 1;
                
                //Mark Task Creation to True on order
                if(isTaskCreated){
                    orderObj.TaskCreated__c = true;
                    taskToInsert.Subject = 'Payment Reminder';
                    taskToInsert.AccountReceivable__c = true;
                  	taskToInsert.recordtypeId = RecordTypes.PaymentReminderRecordType;
                    OrdersToUpadte.add(orderObj);
                }else{
                    system.debug('in else ');
                    taskToInsert.Subject ='Call for Feedback';
                    taskToInsert.OwnerId = orderObj.Opportunity.ownerId;
                    taskToInsert.recordtypeId = RecordTypes.feedbackRecordType;
                }
                //Filling Conatct Information in Task from Opportunity
                if(OppContactMap.containsKey(orderObj.OpportunityId)){
                    system.debug('in if of opportunity COntent');
                    taskToInsert.Contact__c  = OppContactMap.get(orderObj.OpportunityId).ContactId;
                    taskToInsert.WhoId = OppContactMap.get(orderObj.OpportunityId).ContactId; 
                    taskToInsert.Opportunity__c = orderObj.OpportunityId;
                }
                
                tasksToInsert.add(taskToInsert);
            }
            //Assigning Owner of task from Queue Members for Payment Reminder Task
            if(isTaskCreated){
                //Getting Queue Id 
                Id queueId = getQueue('Account_Receivable_Team');
                //Getting Queue Members List
                List<User> queueMembers = getQueueMembers(queueId);
                if(queueMembers.size() > 0 && tasksToInsert.size() > 0 ){
                    tasksToInsert =  queueMemberAssigment(tasksToInsert,queueMembers);
                }
            }
           // Database method to update the records in List
            if(OrdersToUpadte.size() > 0){
                Database.SaveResult[] orderList = Database.update(OrdersToUpadte, false);
				system.debug('orderList-->'+orderList);
            }
            
            //Returning Tasks
            if(tasksToInsert.size() > 0)
                return tasksToInsert;
        }
        return null;
    }
    
    //This method is used to get the Queue Id
    public static Id getQueue(String queuName){
        List<Group> queue = [SELECT Id from Group WHERE Type = 'Queue' AND DeveloperNAME =: queuName];
        if(queue.size() > 0){
            return queue[0].Id;
        }
        return Null;
    } 
    
    //This Method is used to get the user list of Queue
    public static List<User> getQueueMembers(Id queueId){
        if(queueId !=Null){
            return [SELECT id, name, username, isActive FROM user WHERE id IN ( SELECT userOrGroupId FROM groupmember WHERE groupId = :queueId )ORDER BY name];
        }else{
            return null;
        }
    }
    
    //This method is used to assign owners To task
    public static List<Task> queueMemberAssigment(List<Task> taskList,List<User> queueMembersList){
        
        if(taskList.size() == queueMembersList.size()){//if task list size is equals to user list size
            for(integer i = 0; i < taskList.size(); i++){
                taskList[i].ownerId = queueMembersList[i].Id;
            }
        }else if(taskList.size() > queueMembersList.size() ){//if task list size is greater than user list size
            Integer taskCount = 0;
            for(Integer i = 0 ; i < queueMembersList.size(); i++ ){
                if(taskCount < taskList.size()){
                    taskList[taskCount].ownerId = queueMembersList[i].id;
                    taskCount++;
                    if(i+1==queueMembersList.size()){
                        i=-1;
                    }
                }
                else
                    break;
            }
        }else{//if task list size is less then user list size
            
            for(Integer i=0; i < queueMembersList.size(); i++){
                taskList[i].ownerId = queueMembersList[i].id;
                if(i+1==taskList.size())
                    break;                   
            }
        }
        return taskList;
    }
    public static Map<Id, DateTime> lastOrderActivatedDateCalc(Set<Id> accountIds ){
        system.debug('lastOrderActivatedDateCalc call -->'+accountIds);
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, DateTime> mapOfMaxActivatedDate = new Map<Id, DateTime>();
        if(accountIds.size() > 0){
            for(AggregateResult aggResult : [SELECT AccountId, MAX(ActivatedDate)maxdate FROM Order WHERE (status ='Activated' OR status ='Paid') AND AccountId IN : accountIds  GROUP By accountId]){
                if(aggResult.get('maxdate') != NULL){
                    mapOfMaxActivatedDate.put((Id)aggResult.get('AccountId'), (DateTime)aggResult.get('maxdate'));
                }
            }
        }
        system.debug('mapOfMaxActivatedDate-->'+mapOfMaxActivatedDate);
        if(mapOfMaxActivatedDate.size() > 0)
            return mapOfMaxActivatedDate;
        else
            return null;
    }
    
    public static Integer dateDiffrence(Date dateForCalc){
        if(dateForCalc != Null){
            Integer monthCount = dateForCalc.daysBetween(system.today()) / 30;
            return monthCount;
        }
        return 0;
        
    }
    
}