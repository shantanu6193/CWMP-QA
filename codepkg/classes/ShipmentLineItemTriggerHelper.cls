/***********************************************************************************************************************************
* Class Name   : ShipmentLineItemTriggerHelper
* Description  : This is helper class for shipment line item trigger
* Author       : Pankaj
* Created On   : 05/17/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                05/17/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class ShipmentLineItemTriggerHelper extends TriggerHelper {

    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are inserted
    *********************************************/
    public override void processAfterInsert() {
        updateOrderLineItemStatus();
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated
    *********************************************/
    public override void processAfterUpdate() {
        updateOrderLineItemStatus();
    }

    /***********************************************
    * Method Name : updateOrderLineItemStatus
    * Author : Pankaj
    * Inputs : -
    * Description: This method used for Shipment Order Line status is Ready then update Order product to send. For rejected it will be failed
    *********************************************/
    private void updateOrderLineItemStatus() {
        List<Shipment_Order_Line_Item__c> shipmentOrderLineItems = (List<Shipment_Order_Line_Item__c>)Trigger.new;
        Map<Id, Shipment_Order_Line_Item__c> oldShipmentOrderLineItemsByIds = (Map<Id, Shipment_Order_Line_Item__c>)Trigger.oldMap;

        List<Shipment_Order_Line_Item__c> recordsToProcess = new List<Shipment_Order_Line_Item__c>();
        for (Shipment_Order_Line_Item__c shipmentOrderLineItem : shipmentOrderLineItems) {
            if(shipmentOrderLineItem.Status__c == null) continue;
            if((oldShipmentOrderLineItemsByIds == null || oldShipmentOrderLineItemsByIds.get(shipmentOrderLineItem.Id) == null ||
                    (oldShipmentOrderLineItemsByIds.get(shipmentOrderLineItem.Id).Status__c != shipmentOrderLineItem.Status__c))
                    && (shipmentOrderLineItem.Status__c == PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_READY
                || shipmentOrderLineItem.Status__c == PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_Rejected)) {

                recordsToProcess.add(shipmentOrderLineItem);
            }
        }
        if(recordsToProcess.isEmpty()) return;

        List<Order_Product__c> orderProductsToUpdate = new List<Order_Product__c>();
        for (Shipment_Order_Line_Item__c shipmentOrderLineItem : recordsToProcess) {
            if(shipmentOrderLineItem.Order_Product_Shipped__c == null) continue;

            if(shipmentOrderLineItem.Status__c == PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_READY) {
                orderProductsToUpdate.add( new Order_Product__c(Id=shipmentOrderLineItem.Order_Product_Shipped__c,
                Status__c = PHOS_Constants.ORDER_PRODUCT_STATUS_SENT));
            }

            if(shipmentOrderLineItem.Status__c == PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_Rejected) {
                orderProductsToUpdate.add( new Order_Product__c(Id=shipmentOrderLineItem.Order_Product_Shipped__c,
                        Status__c = PHOS_Constants.ORDER_PRODUCT_STATUS_REJECTED));
            }
        }
        update orderProductsToUpdate;

    }

    /*public override void processAfterInsert() {
        calculateTotalReceiving(Trigger.new);
    }

    public override void processAfterUpdate() {
        calculateTotalReceiving(Trigger.new);
    }

    public override void processAfterDelete() {
        calculateTotalReceiving(Trigger.old);
    }

    private void calculateTotalReceiving(List<Shipment_Line_Item__c> shipmentLineItems) {
        List<String> orderItemIds = new List<String>();
        for (Shipment_Line_Item__c shipmentLineItem : shipmentLineItems) {
            if(shipmentLineItem.Order_Product_Shipped__c != null) {
                orderItemIds.add(shipmentLineItem.Order_Product_Shipped__c);
            }
        }
        List<AggregateResult> aggregateResults = [SELECT SUM(Product_Received_BOL_Total_Quantity__c) total,  Order_Product_Shipped__c
                FROM Shipment_Line_Item__c
                WHERE Order_Product_Shipped__c
                IN:orderItemIds
                GROUP BY Order_Product_Shipped__c
        ];
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        for (AggregateResult aggregateResult : aggregateResults) {
            orderItemsToUpdate.add(new OrderItem(Id=(Id)aggregateResult.get('Order_Product_Shipped__c'),
                    Product_Received_Total_Quantity__c = (Decimal)aggregateResult.get('total')));
        }
        update orderItemsToUpdate;
    }*/
}