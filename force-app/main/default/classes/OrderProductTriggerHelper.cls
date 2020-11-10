public class OrderProductTriggerHelper {
    
    public static void restrictOrderProductToInsert(Set<String> creditOrderIds, List<OrderItem> orderProducts){
        
        Map<String, List<OrderProducts>> mapOfOrderProductWrapperList = new Map<String, List<OrderProducts>>();
        Map<String, List<OrignalOrderClass>> mapOfOrdersAndProducts = new Map<String, List<OrignalOrderClass>>();
        
        for(Order creditMemoOrders : [SELECT Id, OriginalOrder__c FROM Order WHERE RecordTypeId = :RecordTypes.CreditMemo
                                      AND status = 'Draft' AND OriginalOrder__c != Null AND Id IN :creditOrderIds ]){
                                          for(OrderItem item : orderProducts){
                                              if(mapOfOrderProductWrapperList.containsKey(creditMemoOrders.OriginalOrder__c)) {
                                                  List<OrderProducts> orderProductWrapperList = mapOfOrderProductWrapperList.get(creditMemoOrders.OriginalOrder__c);
                                                  orderProductWrapperList.add(new orderProducts(creditMemoOrders.OriginalOrder__c, item.OrderId, item.Product2Id, 
                                                                                                (Integer)item.Quantity,item.UnitPrice, item));
                                                  mapOfOrderProductWrapperList.put(creditMemoOrders.OriginalOrder__c, orderProductWrapperList);
                                              } else {
                                                  mapOfOrderProductWrapperList.put(creditMemoOrders.OriginalOrder__c, new List<orderProducts> {new orderProducts(creditMemoOrders.OriginalOrder__c, item.OrderId, item.Product2Id, 
                                                                                                                                                                 (Integer)item.Quantity,item.UnitPrice, item)});
                                              }
                                          }
                                          
                                      }
        
        System.debug('@@@@mapOfOrderProductWrapperList'+mapOfOrderProductWrapperList);
        
        for(OrderItem ordItem : [SELECT Id, Product2Id, UnitPrice, Quantity, OrderId FROM OrderItem WHERE OrderId In : mapOfOrderProductWrapperList.keyset()]){
            List<OrignalOrderClass> orderItems = mapOfOrdersAndProducts.get(ordItem.OrderId);
            if (orderItems == null) {
                orderItems = new List<OrignalOrderClass>();
                mapOfOrdersAndProducts.put(ordItem.OrderId, orderItems);
            }
            orderItems.add(new OrignalOrderClass(ordItem.Product2Id, (Integer)ordItem.Quantity, ordItem.UnitPrice));
        }
        
        System.debug('@@@@mapOfOrdersAndProducts'+mapOfOrdersAndProducts);
        
        for(String orignalOrderId : mapOfOrdersAndProducts.keySet()){
            List<OrignalOrderClass> orignalOrderProduct = mapOfOrdersAndProducts.get(orignalOrderId);
            if(mapOfOrderProductWrapperList.containsKey(orignalOrderId)){
                for(OrderProducts creditOrderProductObj : mapOfOrderProductWrapperList.get(orignalOrderId)){
                    String msg = 'Order Product must be similar to original Order Product!';
                    for(OrignalOrderClass orignalOrderProductObj : orignalOrderProduct){
                        if(creditOrderProductObj.productId == orignalOrderProductObj.productId){
                            if(creditOrderProductObj.quantity > orignalOrderProductObj.quantity){
                                msg = 'You can\'t insert Quantity more than the original Order!';
                                break;
                            }else if(creditOrderProductObj.amount > orignalOrderProductObj.amount){
                                msg = 'You can\'t insert price more then original Order!';
                                break;
                            }
                            
                            if(msg == 'Order Product must be similar to original Order Product!'){
                                msg = '';
                                break;
                            }
                            
                        }else{
                            msg = 'Order Product must be similar to original Order Product!';
                        }
                    }
                    if(String.isNotBlank(msg)){
                        creditOrderProductObj.creditOrderItem.addError(msg);
                    }
                }
            }
        }
    }
    
    public static Map<Id,Set<Id>> restrictDuplicateOrderProduct(Set<String> ProductOrderIds ){
        system.debug('restrictDuplicateOrderProduct call ->'+ProductOrderIds);
        
        
        Map<Id,Set<Id>> orderProductCodeWithOrdersMap = new Map<Id,Set<Id>>();
        for(OrderItem orderItm : [SELECT OrderId,Product2Id FROM OrderItem WHERE OrderId IN : ProductOrderIds ]){
            if(orderProductCodeWithOrdersMap.containsKey(orderItm.OrderId)){
                orderProductCodeWithOrdersMap.get(orderItm.OrderId).add(orderItm.Product2Id);
            }else{
                orderProductCodeWithOrdersMap.put(orderItm.OrderId ,new Set<Id>{orderItm.Product2Id});
            }
        }
        	
        return orderProductCodeWithOrdersMap; 
    }
    
    
    public class OrderProducts{
        Public String creditMemoOrderId;
        Public String orignalOrderId;
        Public String productId;        
        Public Integer quantity;
        Public Decimal amount;
        Public OrderItem creditOrderItem;
        Public OrderProducts(String orignalOrderId, String creditMemoOrderId, String productId,Integer quantity, Decimal amount, OrderItem currentOrderItem){
            this.orignalOrderId = orignalOrderId;
            this.creditMemoOrderId = creditMemoOrderId;
            this.productId = productId;
            this.quantity = quantity;
            this.amount = amount;
            this.creditOrderItem = currentOrderItem;
        } 
    }
    
    Public class OrignalOrderClass{
        Public string productId;
        Public Integer quantity;
        Public Decimal amount;
        Public OrignalOrderClass(string productId, Integer quantity, Decimal amount){
            this.productId = productId;
            this.quantity = quantity;
            this.amount = amount;
        }
    }    
}