trigger  ShipmentOrderTrigger on Shipment_Order__c (after insert,after update,before insert,before update) {
    new ShipmentOrderTriggerHelper().process();
}