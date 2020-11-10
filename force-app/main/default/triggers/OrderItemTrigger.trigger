trigger OrderItemTrigger on OrderItem (before insert,before update,after update) {
    
    Set<String> orderIds = new Set<String>(); 
    If(Trigger.isInsert && Trigger.isBefore){
        system.debug('in before insert');
        for(OrderItem itemObj : Trigger.New){
            orderIds.add(itemObj.OrderId); 
        }
    }
   
    
    if(Trigger.New.size() > 0 && orderIds.size() > 0){
        OrderProductTriggerHelper.restrictOrderProductToInsert(orderIds, Trigger.New);
        /*--------------------------------*/
        Map<Id,Set<Id>> orderProductCodeWithOrdersMap = OrderProductTriggerHelper.restrictDuplicateOrderProduct(orderIds);
        if(orderProductCodeWithOrdersMap.size() > 0 && orderProductCodeWithOrdersMap !=Null){
            for(OrderItem ordItem : Trigger.New){
                if(orderProductCodeWithOrdersMap.containsKey(ordItem.OrderId)){
                    if(orderProductCodeWithOrdersMap.get(ordItem.OrderId).contains(ordItem.Product2Id)){
                        ordItem.addError('Duplicate Product Found.Please Edit Existing Order Product to continue..');
                    }
                }
            }
        }
    }
}