@isTest(seeAllData=false) 
public class ShipmentOrderTriggerHelperTest {
    @isTest static void testShipmentOrder() {

        Account newAccount = PHOS_TestHelper.getWarehouseAccount(true);

        Order__c orderRec = PHOS_TestHelper.getOrder(true);
        Id phosShipOrderRecordTypeId = Schema.SObjectType.Shipment_Order__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
      
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = orderRec.Id;
        orderItemgoggle.Fulfilment_Entity_Warehouse__c = 'West Sacramento';
        orderItemgoggle.Quantity_Filled__c = 10;
        //insert orderItemgoggle;
        orderItems.add(orderItemgoggle);
        Order_Product__c orderItemmask = PHOS_TestHelper.getOrderItemmask(false);
        orderItemmask.Order__c = orderRec.Id;
        orderItemmask.Fulfilment_Entity_Warehouse__c = 'West Sacramento';
        orderItemmask.Quantity_Filled__c = 10;
        orderItems.add(orderItemmask);
        insert orderItems;

        Shipment_Order__c shipmentOrder = PHOS_TestHelper.getShipmentOrder(false);
        shipmentOrder.Order_Custom__c = orderRec.Id;
        shipmentOrder.Warehouse__c = newAccount.Id;
        insert shipmentOrder;
        

        List<Shipment_Order_Line_Item__c> shipmentOrderLineItems = new List<Shipment_Order_Line_Item__c>();
        Shipment_Order_Line_Item__c shipmentOrderLineItem1 = PHOS_TestHelper.getShipmentOrderLineItem(false);
        shipmentOrderLineItem1.Order_Product_Shipped__c = orderItems[0].Name;
         shipmentOrderLineItem1.Shipment__c = shipmentOrder.Id;
        shipmentOrderLineItems.add(shipmentOrderLineItem1);
        Shipment_Order_Line_Item__c shipmentOrderLineItem2 = PHOS_TestHelper.getShipmentOrderLineItem(false);
        shipmentOrderLineItem2.Order_Product_Shipped__c = orderItems[1].Name;
        shipmentOrderLineItem2.Shipment__c = shipmentOrder.Id;
        shipmentOrderLineItems.add(shipmentOrderLineItem2);

        insert shipmentOrderLineItems;

        shipmentOrder.Status__c = 'Rejected';
        update shipmentOrder;
    }
}