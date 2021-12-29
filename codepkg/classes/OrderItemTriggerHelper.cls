/***********************************************************************************************************************************
* Class Name   : OrderItemTriggerHelper
* Description  : This is helper class for order item trigger
* Author       : Pankaj
* Created On   : 05/16/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               05/16/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class OrderItemTriggerHelper extends TriggerHelper{

   /* public override void processAfterInsert()  {
        updateOrder();
    }

    public override void processAfterUpdate() {
        updateOrder();
    }

    public override void processAfterDelete() {
    }

    public override void processAfterUndelete() {
    }

    public static void updateOrder(){
        List<Order> updateOrderList = new List<Order>();
        for(OrderItem orderItem : (List<OrderItem>)Trigger.New){
            Order orderRecord = new Order(Id = orderItem.OrderId );
            if(!updateOrderList.contains(orderRecord)){
                updateOrderList.add(orderRecord);
            }  
        }
        TriggerHelper.skipTrigger = true;
        if(!updateOrderList.isEmpty()){
            update updateOrderList;
        }
        TriggerHelper.skipTrigger = false;
    }*/
    

}