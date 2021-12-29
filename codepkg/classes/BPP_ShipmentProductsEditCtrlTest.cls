@IsTest
private without sharing class BPP_ShipmentProductsEditCtrlTest{

    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        List<Product2> productList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name = ' Test Product1';
        prod.Description='Test Product Entry 1';
        prod.productCode = 'ABC';
        prod.isActive = true;        
        productList.add(Prod);
        
        prod = new Product2();
        prod.Name = ' Test Product2';
        prod.Description='Test Product Entry 2';
        prod.productCode = 'ABC';
        prod.isActive = true;        
        productList.add(Prod);
        
        insert productList;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for(Product2 product: productList){
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = pricebookId;
            standardPrice.Product2Id = product.Id;
            standardPrice.UnitPrice = 100;
            standardPrice.IsActive = true;
            pricebookEntryList.add(standardPrice);
        }
        
        insert pricebookEntryList ;
        
        Order__c odr = new Order__c();
        //odr.Name = 'Test Order ';
        odr.Status__c = 'Open';
        //odr.EffectiveDate = system.today();
        //odr.EndDate = system.today() + 4;
        odr.Account__c = acc.id;
        //odr.Pricebook2Id =  pricebookId;
        insert odr;
        
        List<Order_Product__c> orderItemList = new List<Order_Product__c>();
        for(Product2 product: productList){
            Order_Product__c oderItm = new Order_Product__c();
            oderItm.Order__c = odr.id;
            oderItm.Quantity__c = 24;
            oderItm.Unit_Price__c = 240;
            oderItm.Product__c = product.Id;
            //oderItm.PricebookEntryId=pbe.id;
            orderItemList.add(oderItm);     
        }
        
        insert orderItemList;
        
        Shipment_Order__c shipment = new Shipment_Order__c();
        shipment.Order_Custom__c = odr.Id;
        shipment.Delivery_Schedule_Delivery_Date__c = system.today();
        shipment.Shipping_Tracking_Number__c = '1355';
        insert shipment;
        
        Shipment_Order_Line_Item__c shipmentLine = new Shipment_Order_Line_Item__c();
        shipmentLine.Shipment__c = shipment.Id;
        shipmentLine.Order_Product_Shipped__c = orderItemList[0].Id;
        shipmentLine.Quantity__c= 20;
        insert shipmentLine;
    }
    
    @isTest static void testMethod1() {
        Shipment_Order__c shipment = [Select Id from Shipment_Order__c Limit 1];
        List<Order_Product__c> orderItemList = [Select Id from Order_Product__c];
        
        Test.StartTest();
            BPP_ShipmentProductsEditCtrl.ShipmentProducts shipmentProds = BPP_ShipmentProductsEditCtrl.getOrderItemAndShipmentProducts(shipment.Id);
            System.assert(shipmentProds.orderItemList.size()==2);
            System.assert(shipmentProds.shipmentLineItems.size()==1);
            
            Shipment_Order_Line_Item__c shipmentLine = new Shipment_Order_Line_Item__c();
            shipmentLine.Shipment__c = shipment.Id;
            shipmentLine.Order_Product_Shipped__c = orderItemList[1].Id;
            shipmentLine.Quantity__c= 20;
            shipmentProds.shipmentLineItems.add(shipmentLine);
            //shipmentProds.shipmentLineItems.remove(0);
            
            string shipmentLineStr = JSON.serialize(shipmentProds.shipmentLineItems);
            string result = BPP_ShipmentProductsEditCtrl.saveShipmentLineItems(shipmentLineStr, shipment.Id); 
            
           // system.assertEquals(result,'Success');
        Test.StopTest();

    }
    
}