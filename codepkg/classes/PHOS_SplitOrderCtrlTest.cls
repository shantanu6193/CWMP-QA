@isTest
public class PHOS_SplitOrderCtrlTest {
    @isTest(seeAllData=true)
    public static void testCreateShipment2(){
        Order__c getOrder = PHOS_TestHelper.getOrder(false);
        Contact getContact = PHOS_TestHelper.getContact(true);
        User getUser = PHOS_TestHelper.getUser(true);
        //Id warehouseRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId();
        Warehouse_Config__mdt wareHouseData = [Select Id,Account_Id__c,isActive__c,Send_Email__c,DeveloperName,MasterLabel,Create_Shipment_Order__c
                                                        from Warehouse_Config__mdt where MasterLabel = 'West Sacramento' LIMIT 1];
        
        system.debug('wareHuseData---------'+wareHouseData);
        Account newAccount = [Select Id,Name,Entity_Id__c FROM Account where Id =:wareHouseData.Account_Id__c];
        
        getOrder.Requestor__c = getContact.id;
        getOrder.CreatedById = getUser.Id;
        getOrder.Creator_Contact__c = getContact.id;
        getOrder.Account__c = getContact.AccountId;
        insert getOrder;
        List<Order_Product__c> newOrderProduct = new List <Order_Product__c>();
        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = getOrder.Id;
        orderItemgoggle.Product_Name__c = 'Eye Goggles';
        orderItemgoggle.Quantity_Filled__c = 10;
        orderItemgoggle.Case_Count__c = 10;
        orderItemgoggle.Fulfilment_Entity_Warehouse__c ='West Sacramento';
        orderItemgoggle.Warehouse_Info__c = 'test';
        insert orderItemgoggle;


        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Warehouse_Product__c warehouseProduct = new Warehouse_Product__c();
        warehouseProduct.Product__c = product.Id;
        warehouseProduct.Warehouse__c = newAccount.Id;
        warehouseProduct.Is_Active__c = true;
        warehouseProduct.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        insert warehouseProduct;

        Inventory__c inventory = new Inventory__c();
        inventory.Warehouse_Product__c = warehouseProduct.Id;
        inventory.SKU_Id__c = 'test';
        inventory.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        inventory.Remaining_Inventory__c = 1200000;
        inventory.Total_Available_Inventory__c = 1200000;
        insert inventory;

        Shipment_Order__c shipOrderRec= new Shipment_Order__c();
        shipOrderRec.Name='Shipment Name';
        shipOrderRec.Order_Custom__c=getOrder.Id;
        shipOrderRec.Status__c = PHOS_Constants.SHIPMENT_ORDER_STATUS_READY;
        Id phosShipOrderRecordTypeId = Schema.SObjectType.Shipment_Order__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
        shipOrderRec.RecordTypeId = phosShipOrderRecordTypeId;
        insert shipOrderRec;
        
        Shipment_Order_Line_Item__c shipmlnRec = new Shipment_Order_Line_Item__c ();
        shipmlnRec.Order_Product_Shipped__c = orderItemgoggle.Id;
        shipmlnRec.Quantity__c = 10;
        shipmlnRec.Case_Count__c = 10;
        shipmlnRec.Status__c = PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_READY;
        shipmlnRec.Shipment__c = shipOrderRec.Id;
        insert shipmlnRec;
        
        Map<String,Object>paramMap = new Map<String,Object>();
        paramMap.put('fulfilment',wareHouseData.MasterLabel);
        paramMap.put('Order',JSON.serialize(getOrder));
        paramMap.put('OrderItems',JSON.serialize(newOrderProduct));
        test.startTest();
        Map<String,Object> returnRes = PHOS_SplitOrderCtrl.processSplitOrder(paramMap);
        System.assert(returnRes.size()>0);
        test.stopTest();
    }
    @isTest 
    public static void testGetOrderDetails(){
        Order__c getOrder = PHOS_TestHelper.getOrder(true);
        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = getOrder.Id;
        insert orderItemgoggle;
        Order_Product__c orderItemmask = PHOS_TestHelper.getOrderItemmask(false);
        orderItemmask.Order__c = getOrder.Id;
        insert orderItemmask;
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        orderItems.add(orderItemgoggle);
        orderItems.add(orderItemmask);
        
        test.startTest();
        Map<String, Object> receivedMap = PHOS_SplitOrderCtrl.getOrderDetails(String.valueOf(getOrder.Id));
        System.assert(receivedMap.size()>0);
        test.stopTest();
        
    }
 
    
    @isTest 
    public static void testGetProducts(){
        Product2 productGoggles = PHOS_TestHelper.getProductGoggles(true);      
		        
        test.startTest();
        Map<String, Object> receivedMap = PHOS_SplitOrderCtrl.getProducts();
        System.assert(receivedMap.size()>0);
        test.stopTest();
	}

    @isTest 
    public static void testGetEmailAddresses(){
                
        Order__c getOrder = PHOS_TestHelper.getOrder(true);

        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = getOrder.Id;
        insert orderItemgoggle;
        Order_Product__c orderItemmask = PHOS_TestHelper.getOrderItemmask(false);
        orderItemmask.Order__c = getOrder.Id;
        insert orderItemmask;
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        orderItems.add(orderItemgoggle);
        orderItems.add(orderItemmask);
        
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('Order', Json.serialize(getOrder));
        paramMap.put('OrderItems', Json.serialize(orderItems));
        paramMap.put('fulfilment', 'West Sacramento');
        
        test.startTest();
        Map<String, Object> receivedMap = PHOS_SplitOrderCtrl.getEmailAddresses(paramMap);
       // System.assert(receivedMap.size()>0);
        test.stopTest();
        
    }

}