/**
 * Created by Pankaj on 17-05-2020.
 */

trigger ShipmentLineItemTrigger on Shipment_Order_Line_Item__c (after insert, after update, after delete) {
    new ShipmentLineItemTriggerHelper().process();
}