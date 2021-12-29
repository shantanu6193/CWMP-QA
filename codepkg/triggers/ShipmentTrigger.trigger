trigger ShipmentTrigger on Shipment__c (before insert,before update) {
 new ShipmentTriggerHelper().process();
}