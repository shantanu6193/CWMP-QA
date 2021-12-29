@isTest(seeAllData=false) 
public class ShipmentLineItemTriggerHelperTest {
    @isTest static void testShipmentLineItem() {
     //  List<Shipment_Order_Line_Item__c> shipmentOrderLineItems = new List<Shipment_Order_Line_Item__c>();
        test.startTest();
        
        Shipment_Order__c shipmentOrder = PHOS_TestHelper.getShipmentOrder(true);
        Shipment_Order_Line_Item__c shipmentOrderLineItem1 = PHOS_TestHelper.getShipmentOrderLineItem(false);
        shipmentOrderLineItem1.Status__c = PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_READY;
        shipmentOrderLineItem1.Shipment__c = shipmentOrder.Id;
        
        insert shipmentOrderLineItem1;
       
		shipmentOrderLineItem1.Status__c =PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_Rejected;        
        update shipmentOrderLineItem1;
        test.stopTest();   
    }
}