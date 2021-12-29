/**
 * Created by PREM on 31-07-2020.
 */

@isTest
public class Order_ProductsEditCtrlTest {
    @isTest 
    public static void testGetProducts(){
        User newUser = PHOS_TestHelper.getUser(true);
        System.runAs(newUser){
            //Account newAccount = new Account();
            //insert newAccount;
            Map<String,Object> returnMap = new Map<String,Object>();
            Product2 product = PHOS_TestHelper.getProductGoggles(true);
            Test.startTest();
            returnMap = Order_ProductsEditCtrl.getProducts();
            System.assert(returnMap.size()>0);
            Test.stopTest();
        }
    }
    @isTest 
    public static void testGetOrderProductDetails(){
        List<String> fieldAPINameList = new List<String>();
        Map<String,Object> returnMap = new Map<String,Object>();
        Order__c newOrder = PHOS_TestHelper.getOrder(true);


        String orderId = String.valueOf(newOrder.Id);
        fieldAPINameList.add('Description__c');
        String fieldAPINames = JSON.serialize(fieldAPINameList);
        Test.startTest();
        returnMap = Order_ProductsEditCtrl.getOrderProductDetails(orderId, fieldAPINames);
        System.assert(returnMap.size()>0);
        Test.stopTest();
    }

    @isTest 
    public static void testSaveOrderItems(){
        List<User> newUserList = [SELECT Id,Name from User LIMIT 1];
        for(User newUser : newUserList){
            List<UserAppInfo> userAppInfoList =  [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :newUser.Id LIMIT 1] ;
            if(!userAppInfoList.isEmpty()){
                System.runAs(newUser){
                    Map<String, Object> paramMap = new Map<String, Object>();
                    List<Order_Product__c> orderItems = new List<Order_Product__c>();
                    Contact newContact = PHOS_TestHelper.getContact(true);
                    Order__c newOrder = PHOS_TestHelper.getOrder(false);
                    newOrder.CreatedById = newUser.Id;
                    newOrder.Requestor__c = newContact.Id;
                    insert newOrder;
                    Product2 product = PHOS_TestHelper.getProductGoggles(true);
                    Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
                    newOrderItemgoggle.Order__c = newOrder.Id;
                    newOrderItemgoggle.Product__c = product.Id;
                    insert newOrderItemgoggle;
                    orderItems.add(newOrderItemgoggle);
                    paramMap.put('OrderItems', JSON.serialize(orderItems));
                    paramMap.put('Order__c', newOrder.Id);
                    Test.startTest();
                    Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
                    system.assert(returnMap.size()>0);
                    Test.stopTest();

                }

            }
            break;
        }

    }

    @isTest 
    public static void testGetFieldDetails(){
        List<Order_ProductsEditCtrl.FieldDetails> returnDetailsList = new List<Order_ProductsEditCtrl.FieldDetails>();
        List<Order_ProductsEditCtrl.FieldDetails> fieldDetailsList = new List<Order_ProductsEditCtrl.FieldDetails>();
        Order_ProductsEditCtrl.FieldDetails fieldDetails = new Order_ProductsEditCtrl.FieldDetails();

        fieldDetails.APIName = 'Name';
        fieldDetails.Label= 'Product Name';
        fieldDetails.fieldType = 'PICKLIST';
        fieldDetails.isRequired = null;
        fieldDetails.isDisabled = null;
        fieldDetails.enablePostSent = null;
        fieldDetails.OnChangeFormula = null;
        fieldDetailsList.add(fieldDetails);
        Product2 newProductMask = PHOS_TestHelper.getProductMask(true);
        string fieldsJSON = JSON.serialize(fieldDetailsList);
        String objectName = JSON.serialize(newProductMask);
        Test.startTest();
        returnDetailsList = Order_ProductsEditCtrl.getFieldDetails(fieldsJSON , 'Product2');
        System.assert(returnDetailsList.size()>0);
        Test.stopTest();
    }
    
    /*@isTest(SeeAllData=true) 
    public static void testSaveOrderItemsnew(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        //Order_ProductsEditGetAccountTest.getAccountData();
        //system.assert(false,'warehouseAcc--'+warehouseAcc);
        Contact newContact = PHOS_TestHelper.getContact(true);
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = newContact.Id;
        insert newOrder;
        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        newOrderItemgoggle.Order__c = newOrder.Id;
        newOrderItemgoggle.Product__c = product.Id;
        newOrderItemgoggle.Fulfilment_Entity_Warehouse__c ='';
        insert newOrderItemgoggle;
        
        Product2 product1 = PHOS_TestHelper.getProductMask(true);
        Order_Product__c newOrderItemMask = PHOS_TestHelper.getOrderItemmask(false);
        newOrderItemMask.Order__c = newOrder.Id;
        newOrderItemMask.Product__c = product1.Id;
        newOrderItemMask.Status__c = 'Sent';
        insert newOrderItemMask;
        orderItems.add(newOrderItemMask);
        
        paramMap.put('OrderItems', JSON.serialize(orderItems));
        paramMap.put('Order__c', newOrder.Id);
        Test.startTest();
        Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
        system.assert(returnMap.size()>0);
        Test.stopTest();               
   }*/
    
    @isTest(SeeAllData=true) 
    public static void testSaveOrderItemsFillQty(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        Warehouse_Config__mdt wareHouseData = [Select Id,Account_Id__c,isActive__c,Send_Email__c,DeveloperName,MasterLabel,Create_Shipment_Order__c
                                                        from Warehouse_Config__mdt where MasterLabel = 'West Sacramento' LIMIT 1];
        
        system.debug('wareHuseData---------'+wareHouseData);
        Account newAccount = [Select Id,Name,Entity_Id__c FROM Account where Id =: wareHouseData.Account_Id__c];
        
        Contact newContact = PHOS_TestHelper.getContact(true);
        User getUser = PHOS_TestHelper.getUser(true);
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = newContact.Id;
        newOrder.Requestor__c = newContact.id;
        newOrder.CreatedById = getUser.Id;
        newOrder.Creator_Contact__c = newContact.id;
        newOrder.Account__c = newContact.AccountId;
        insert newOrder;
        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        newOrderItemgoggle.Order__c = newOrder.Id;
        newOrderItemgoggle.Product__c = product.Id;
        newOrderItemgoggle.Fulfilment_Entity_Warehouse__c ='West Sacramento';
        newOrderItemgoggle.Quantity_Filled__c = 5;
        newOrderItemgoggle.Warehouse_Info__c = 'test';
        insert newOrderItemgoggle;
        orderItems.add(newOrderItemgoggle);
        
        Product2 product1 = PHOS_TestHelper.getProductMask(true);
        Order_Product__c newOrderItemMask = PHOS_TestHelper.getOrderItemmask(false);
        newOrderItemMask.Order__c = newOrder.Id;
        newOrderItemMask.Product__c = product1.Id;
        newOrderItemMask.Fulfilment_Entity_Warehouse__c = 'West Sacramento';
        newOrderItemMask.Quantity_Filled__c = 15;
        insert newOrderItemMask;
        orderItems.add(newOrderItemMask);
       
        Warehouse_Product__c warehouseProduct = new Warehouse_Product__c();
        warehouseProduct.Product__c = product.Id;
        warehouseProduct.Warehouse__c = newAccount.Id;
        warehouseProduct.Is_Active__c = true;
        warehouseProduct.Warehouse_SKU_Id__c = newAccount.Entity_Id__c;
        warehouseProduct.Warehouse_Code__c = 'CV24';
        warehouseProduct.Warehouse_SKU_Id__c = 'p-21312';
        warehouseProduct.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        insert warehouseProduct;
        
        Inventory__c inventory = new Inventory__c();
        inventory.Warehouse_Product__c = warehouseProduct.Id;
        inventory.Warehouse_Code__c = 'CV12';
        inventory.SKU_Id__c = 'test';
        inventory.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        inventory.Remaining_Inventory__c = 1200000;
        inventory.Total_Available_Inventory__c = 1200000;
        insert inventory;
        
        
        paramMap.put('OrderItems', JSON.serialize(orderItems));
        paramMap.put('Order__c', newOrder.Id);
        Test.startTest();
        Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
        system.assert(returnMap.size()>0);
        Test.stopTest();               
   }
    
    @isTest(SeeAllData=true) 
    public static void testSaveOrderItemsNoSKU(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
                Warehouse_Config__mdt wareHouseData = [Select Id,Account_Id__c,isActive__c,Send_Email__c,DeveloperName,MasterLabel,Create_Shipment_Order__c
                                                        from Warehouse_Config__mdt where MasterLabel = 'West Sacramento' LIMIT 1];
        
        system.debug('wareHuseData---------'+wareHouseData);
        Account newAccount = [Select Id,Name,Entity_Id__c FROM Account where Id =: wareHouseData.Account_Id__c];
        
        Contact newContact = PHOS_TestHelper.getContact(true);
        User getUser = PHOS_TestHelper.getUser(true);
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = newContact.Id;
        newOrder.Requestor__c = newContact.id;
        newOrder.CreatedById = getUser.Id;
        newOrder.Creator_Contact__c = newContact.id;
        newOrder.Account__c = newContact.AccountId;
        insert newOrder;

        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        newOrderItemgoggle.Order__c = newOrder.Id;
        newOrderItemgoggle.Product__c = product.Id;
        newOrderItemgoggle.Fulfilment_Entity_Warehouse__c ='West Sacramento';
        newOrderItemgoggle.Quantity_Filled__c = 15;
        newOrderItemgoggle.Warehouse_Info__c = 'test';
        insert newOrderItemgoggle;
        
        Warehouse_Product__c warehouseProduct = new Warehouse_Product__c();
        warehouseProduct.Product__c = product.Id;
        warehouseProduct.Warehouse__c = newAccount.Id;
        warehouseProduct.Is_Active__c = true;
        warehouseProduct.Warehouse_SKU_Id__c = newAccount.Entity_Id__c;
        warehouseProduct.Warehouse_Code__c = 'CV12';
        warehouseProduct.Warehouse_SKU_Id__c = 'p-21312';
        warehouseProduct.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        insert warehouseProduct;

        Inventory__c inventory = new Inventory__c();
        inventory.Warehouse_Product__c = warehouseProduct.Id;
        inventory.Warehouse_Code__c = 'CV12';
        inventory.SKU_Id__c = 'test';
        inventory.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        inventory.Remaining_Inventory__c = 1200000;
        inventory.Total_Available_Inventory__c = 1200000;
        insert inventory;
        
        
        orderItems.add(newOrderItemgoggle);
        paramMap.put('OrderItems', JSON.serialize(orderItems));
        paramMap.put('Order__c', newOrder.Id);
        Test.startTest();
        Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
        system.assert(returnMap.size()>0);
        Test.stopTest();               
    }
    
   /* @isTest(SeeAllData=true) 
    public static void testSaveOrderItemsNoWarehouse(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        Contact newContact = PHOS_TestHelper.getContact(true);
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = newContact.Id;
        insert newOrder;
        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        newOrderItemgoggle.Order__c = newOrder.Id;
        newOrderItemgoggle.Product__c = product.Id;
        //newOrderItemgoggle.Quantity_Filled__c = 10;
        newOrderItemgoggle.Fulfilment_Entity_Warehouse__c = 'West Sacramento';
        insert newOrderItemgoggle;
        orderItems.add(newOrderItemgoggle);
        Product2 product1 = PHOS_TestHelper.getProductMask(true);
        Order_Product__c newOrderItemMask = PHOS_TestHelper.getOrderItemmask(false);
        newOrderItemMask.Order__c = newOrder.Id;
        newOrderItemMask.Product__c = product1.Id;
        newOrderItemMask.Fulfilment_Entity_Warehouse__c = 'West Sacramento' ;
        insert newOrderItemMask;
        orderItems.add(newOrderItemMask);
        paramMap.put('OrderItems', JSON.serialize(orderItems));
        paramMap.put('Order__c', newOrder.Id);
        Test.startTest();
        Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
        system.assert(returnMap.size()>0);
        Test.stopTest();               
    }*/
    
    @isTest(SeeAllData=true) 
    public static void testSaveOrderItemInvLessQty(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        Warehouse_Config__mdt wareHouseData = [Select Id,Account_Id__c,isActive__c,Send_Email__c,DeveloperName,MasterLabel,Create_Shipment_Order__c
                                                        from Warehouse_Config__mdt where MasterLabel = 'West Sacramento' LIMIT 1];
        
        system.debug('wareHuseData---------'+wareHouseData);
        Account newAccount = [Select Id,Name,Entity_Id__c FROM Account where Id =: wareHouseData.Account_Id__c];
        
        Contact newContact = PHOS_TestHelper.getContact(true);
        User getUser = PHOS_TestHelper.getUser(true);
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = newContact.Id;
        newOrder.Requestor__c = newContact.id;
        newOrder.CreatedById = getUser.Id;
        newOrder.Creator_Contact__c = newContact.id;
        newOrder.Account__c = newContact.AccountId;
        insert newOrder;
        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        newOrderItemgoggle.Order__c = newOrder.Id;
        newOrderItemgoggle.Product__c = product.Id;
        newOrderItemgoggle.Unit_Price__c = null;
        newOrderItemgoggle.Fulfilment_Entity_Warehouse__c ='West Sacramento';
        newOrderItemgoggle.Quantity_Filled__c = 1500;
        newOrderItemgoggle.Warehouse_Info__c = 'test';
        insert newOrderItemgoggle;
        orderItems.add(newOrderItemgoggle);
        
        Product2 product1 = PHOS_TestHelper.getProductMask(true);
        Order_Product__c newOrderItemMask = PHOS_TestHelper.getOrderItemmask(false);
        newOrderItemMask.Order__c = newOrder.Id;
        newOrderItemMask.Product__c = product1.Id;
        newOrderItemMask.Fulfilment_Entity_Warehouse__c = PHOS_Constants.FILLED_REGIONALLY_STATUS;
        newOrderItemMask.Quantity_Filled__c = 1200;
        insert newOrderItemMask;
        orderItems.add(newOrderItemMask);
       
        Warehouse_Product__c warehouseProduct = new Warehouse_Product__c();
        warehouseProduct.Product__c = product.Id;
        warehouseProduct.Warehouse__c = newAccount.Id;
        warehouseProduct.Is_Active__c = true;
        warehouseProduct.Warehouse_SKU_Id__c = newAccount.Entity_Id__c;
        warehouseProduct.Warehouse_Code__c = 'CV12';
        warehouseProduct.Warehouse_SKU_Id__c = 'p-21312';
        warehouseProduct.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        insert warehouseProduct;
       
        Inventory__c inventory = new Inventory__c();
        inventory.Warehouse_Product__c = warehouseProduct.Id;
        inventory.Warehouse_Code__c = 'CV12';
        inventory.SKU_Id__c = 'test';
        inventory.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        inventory.Remaining_Inventory__c = 1000;
        inventory.Total_Available_Inventory__c = 1000;
        insert inventory;
        
        
        paramMap.put('OrderItems', JSON.serialize(orderItems));
        paramMap.put('Order__c', newOrder.Id);
        Test.startTest();
        Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
        system.assert(returnMap.size()>0);
        Test.stopTest();               
    }
   
    @isTest(SeeAllData=true) 
    public static void testSaveOrderItemNoInv(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();
        Warehouse_Config__mdt wareHouseData = [Select Id,Account_Id__c,isActive__c,Send_Email__c,DeveloperName,MasterLabel,Create_Shipment_Order__c
                                                        from Warehouse_Config__mdt where MasterLabel = 'West Sacramento' LIMIT 1];
        
        system.debug('wareHuseData---------'+wareHouseData);
        Account newAccount = [Select Id,Name,Entity_Id__c FROM Account where Id =: wareHouseData.Account_Id__c];
        
        Contact newContact = PHOS_TestHelper.getContact(true);
        User getUser = PHOS_TestHelper.getUser(true);
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = newContact.Id;
        newOrder.Requestor__c = newContact.id;
        newOrder.CreatedById = getUser.Id;
        newOrder.Creator_Contact__c = newContact.id;
        newOrder.Account__c = newContact.AccountId;
        insert newOrder;
        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c newOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        newOrderItemgoggle.Order__c = newOrder.Id;
        newOrderItemgoggle.Product__c = product.Id;
        newOrderItemgoggle.Fulfilment_Entity_Warehouse__c ='West Sacramento';
        newOrderItemgoggle.Quantity_Filled__c = 10;
        newOrderItemgoggle.Warehouse_Info__c = 'test123';
        insert newOrderItemgoggle;
        orderItems.add(newOrderItemgoggle);
         
        Product2 product1 = PHOS_TestHelper.getProductMask(true);
        Order_Product__c newOrderItemMask = PHOS_TestHelper.getOrderItemmask(false);
        newOrderItemMask.Order__c = newOrder.Id;
        newOrderItemMask.Product__c = product1.Id;
        newOrderItemMask.Fulfilment_Entity_Warehouse__c ='West Sacramento';
        newOrderItemgoggle.Warehouse_Info__c = '';
        newOrderItemMask.Quantity_Filled__c = 1200;
        insert newOrderItemMask;
        orderItems.add(newOrderItemMask);
        
        
        Warehouse_Product__c warehouseProduct = new Warehouse_Product__c();
        warehouseProduct.Product__c = product.Id;
        warehouseProduct.Warehouse__c = newAccount.Id;
        warehouseProduct.Is_Active__c = true;
        warehouseProduct.Warehouse_SKU_Id__c = newAccount.Entity_Id__c;
        warehouseProduct.Warehouse_Code__c = 'CV12';
        warehouseProduct.Warehouse_SKU_Id__c = 'p-21312';
        warehouseProduct.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test';
        insert warehouseProduct;

        Inventory__c inventory = new Inventory__c();
        inventory.Warehouse_Product__c = warehouseProduct.Id;
        inventory.Warehouse_Code__c = 'CV12';
        inventory.SKU_Id__c = 'test';
        inventory.Warehouse_Code_And_SKU_Id__c = newAccount.Entity_Id__c + 'test 1234';
        inventory.Remaining_Inventory__c = 1000;
        inventory.Total_Available_Inventory__c = 1000;
        insert inventory;
        
        
        paramMap.put('OrderItems', JSON.serialize(orderItems));
        paramMap.put('Order__c', newOrder.Id);
        Test.startTest();
        Map<String, Object> returnMap = Order_ProductsEditCtrl.saveOrderItems(paramMap);
        system.assert(returnMap.size()>0);
        Test.stopTest();               
    }

	@isTest 
    public static void testGetFieldTypeTextArea(){
        Schema.DisplayType dt = Schema.DisplayType.TextArea;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    @isTest 
    public static void testGetFieldTypeCurrency(){
        Schema.DisplayType dt = Schema.DisplayType.Currency;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    @isTest 
    public static void testGetFieldTypeDouble(){
        Schema.DisplayType dt = Schema.DisplayType.Double;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    
    @isTest 
    public static void testGetFieldTypeBoolean(){
        Schema.DisplayType dt = Schema.DisplayType.Boolean;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
        
    @isTest 
    public static void testGetFieldTypeDateTime(){
        Schema.DisplayType dt = Schema.DisplayType.DateTime;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    
    @isTest 
    public static void testGetFieldTypeDate(){
        Schema.DisplayType dt = Schema.DisplayType.Date;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    @isTest 
    public static void testGetFieldTypePicklist(){
        Schema.DisplayType dt = Schema.DisplayType.PICKLIST;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    @isTest 
    public static void testGetFieldTypeMultiPicklist(){
        Schema.DisplayType dt = Schema.DisplayType.MultiPicklist;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
    @isTest 
    public static void testGetFieldTypeUnknown(){
        Schema.DisplayType dt = Schema.DisplayType.JSON;
		Test.startTest();
        String result = Order_ProductsEditCtrl.getFieldType(dt);
        System.assertNotEquals(result, null);
        Test.stopTest();
    } 
}