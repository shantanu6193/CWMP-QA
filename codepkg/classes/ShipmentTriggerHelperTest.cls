@isTest(seeAllData=false) 
public class ShipmentTriggerHelperTest {
    @IsTest static void testShipment() {
        Order__c orderRec = PHOS_TestHelper.getOrder(true);
        Shipment__c ship = new Shipment__c();
        ship.Order__c = orderRec.Id;
        ship.Name = 'Shipment Demo';
        insert ship;
             
    }
}