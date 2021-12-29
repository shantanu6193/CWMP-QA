/***********************************************************************************************************************************
* Class Name   : Order_ProductsEditCtrl
* Description  : This class for get order product
* Author       : Pankaj
* Created On   : 07/31/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               07/31/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class Order_ProductsEditCtrl {

    /***********************************************
    * Method Name : getProducts
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of all active products
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getProducts(){
        return Order_ProductHelper.getProducts();
    }

    /***********************************************
    * Method Name : getOrderProductDetails
    * Author : Pankaj
    * Inputs : String orderId, String fieldAPINames
    * Description: This method return map of order products and warehouses 
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrderProductDetails(String orderId, String fieldAPINames){
        Map<String,Object> returnMap = new Map<String,Object>();
        List<String> fieldAPINameList = (List<String>) JSON.deserialize(fieldAPINames, List<String>.class);
        String query = 'SELECT ' + String.join(fieldAPINameList,',') + ',Product__r.Name, Product__r.ProductCode,Product_Family__c,Product_Name__c FROM Order_Product__c WHERE Order__c =: orderId';
        List<Order_Product__c> orderItems = Database.query(query);
        System.debug('orderItems'+orderItems);
        List<Warehouse_Config__mdt> warehouseList = [select id,Enable_Post_Sent__c,DeveloperName, MasterLabel  from Warehouse_Config__mdt where Enable_Post_Sent__c = true];
        returnMap.put('Warehouse',warehouseList);
        returnMap.put('orderItems', orderItems);
        return returnMap;
    }

    /***********************************************
    * Method Name : saveOrderItems
    * Author : Pankaj
    * Inputs : Map<String, Object> paramMap
    * Description: This method insert\update\delete the order products and return map of updated order products with error message if quantities are not available 
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> saveOrderItems(Map<String, Object> paramMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = (List<Order_Product__c>) JSON.deserialize(String.valueOf(paramMap.get('OrderItems')),
                    List<Order_Product__c>.class);

        returnMap = checkAvailableQty(orderItems);
        Boolean hasError = (Boolean)returnMap.get('hasError');
        if(hasError == true) return returnMap;

        String orderId = (String) paramMap.get('Order__c');//OrderId

        //create order version is app is Cal OES - Public Health Ordering System
        String appName = getAppName();
        if(appName == 'Cal OES - Public Health Ordering System' || appName == 'PHOS Community User') {
            System.debug('-----Creating Order Version------'+appName);
            AppUtils.generateSnapshotInJSON(orderId);
        }

        List<String> orderItemIds = new List<String>();
        for (Order_Product__c orderItem : orderItems) {
            if(String.isNotEmpty(orderItem.Id)) {
                orderItemIds.add(orderItem.Id);
            }
            System.debug('orderItem.Quantity__c-----'+orderItem.Quantity__c);
            System.debug('orderItem.Unit_Price__c-----'+orderItem.Unit_Price__c);
            if(orderItem.Unit_Price__c != null) {
                orderItem.Total_Price__c =  orderItem.Quantity__c * orderItem.Unit_Price__c;
                orderItem.Product_Code__c = orderItem.Product__r.ProductCode;
            }
        }
        List<Order_Product__c> orderItemsToDelete = new List<Order_Product__c>();
        if (orderItemIds.size() == 0) {
            orderItemsToDelete = [SELECT Id FROM Order_Product__c WHERE Order__c=:orderId];
        } else {
            orderItemsToDelete = [SELECT Id FROM Order_Product__c WHERE Order__c =:orderId AND Id NOT IN :orderItemIds];
        }
        delete orderItemsToDelete;

        List<String> productIds = new List<String>();
        for (Order_Product__c orderItem : orderItems) {
            if (orderItem.Id==null && String.isEmpty(orderItem.Order__c)) {
                orderItem.Order__c = orderId;
            }
            if (orderItem.Unit_Price__c == null) {
                orderItem.Unit_Price__c = 0;
            }
            productIds.add(orderItem.Product__c);
        }
        upsert orderItems;
        returnMap.put('hasError', false);
        return returnMap;
    }

    /***********************************************
    * Method Name : checkAvailableQty
    * Author : Pankaj
    * Inputs : List<Order_Product__c> orderProducts
    * Description: This method checks order products quantity available in inventory and return map of updated order products with error message if conditions are satisfied 
    *********************************************/
    private static Map<String, Object> checkAvailableQty(List<Order_Product__c> orderProducts) {
        Map<String, Object> returnMap = new Map<String, Object>();
        // this flag will derive to show error on UI
        returnMap.put('hasError', false);


        /**
         * on order product we have picklist of warehouse. Grab account id and get warehouse code
        */
        Map<String,String> warehouseMap = new  Map<String,String>();
        Map<String,Boolean> warehouseQtyValidationMap = new  Map<String,Boolean>();
        Map<String,Boolean> warehouseAllowZeroFulfilledQtyMap = new  Map<String,Boolean>();
        List<Id> accountIds = new List<Id>();
        List<Warehouse_Config__mdt> warehouseConfigs = [SELECT Id,Account_Id__c,isActive__c,MasterLabel,Check_For_Warehouse_Validations__c,Allow_Zero_Fulfilled_Qty__c
                FROM Warehouse_Config__mdt WHERE isActive__c = true];
        for(Warehouse_Config__mdt tempWarehouse : warehouseConfigs) {
            accountIds.add(tempWarehouse.Account_Id__c);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Entity_Id__c FROM Account WHERE Id IN :accountIds]);
        for(Warehouse_Config__mdt tempWarehouse : warehouseConfigs) {
            if(accountMap.get(tempWarehouse.Account_Id__c) == null) throw new AuraHandledException('Warehouse account not found. '
                            + tempWarehouse.MasterLabel);
            warehouseMap.put(tempWarehouse.MasterLabel, accountMap.get(tempWarehouse.Account_Id__c).Entity_Id__c);
            warehouseQtyValidationMap.put(tempWarehouse.MasterLabel, tempWarehouse.Check_For_Warehouse_Validations__c);
            warehouseAllowZeroFulfilledQtyMap.put(tempWarehouse.MasterLabel, tempWarehouse.Allow_Zero_Fulfilled_Qty__c);

        }


        Map<String, Integer> remainingInventoryBySKU = new Map<String, Integer>();
        Map<String, Integer> minimumQuantityInventory = new Map<String, Integer>();
        List<Id> productIds = new List<Id>();
        for (Order_Product__c orderProduct : orderProducts) {
            productIds.add(orderProduct.Product__c);
        }
        Map<String,Boolean> skipPHOSWarehouseValidation = new Map<String,Boolean>();
        for(Product2 prodRec : [SELECT Id,Skip_PHOS_Warehouse_Validation__c FROM Product2 WHERE Id IN: productIds]){
            skipPHOSWarehouseValidation.put(prodRec.Id,prodRec.Skip_PHOS_Warehouse_Validation__c);
        }
        List<Inventory__c> inventoryList = [SELECT Id,Name,Remaining_Inventory__c,SKU_Id__c,Warehouse_Code__c,
                                            Warehouse_Product__r.Product__c,Warehouse_Product__r.Warehouse__c,Warehouse_Product__r.Warehouse_SKU_Id__c,
                                            Warehouse_Product__r.Warehouse_Code__c,Warehouse_Product__r.Product__r.Minimum_Order_Quantity__c
                                            FROM Inventory__c
                                            WHERE Warehouse_Product__r.Warehouse__c IN: accountIds];
        for (Inventory__c inventory : inventoryList) {
            //remaining inventory for SKU & Warehouse
            remainingInventoryBySKU.put(inventory.SKU_Id__c + inventory.Warehouse_Code__c,
                                        (inventory.Remaining_Inventory__c != null ? Integer.valueOf(inventory.Remaining_Inventory__c) : 0));
            //minimum order quantity for specific product
            minimumQuantityInventory.put(inventory.SKU_Id__c + inventory.Warehouse_Code__c,
                    (inventory.Warehouse_Product__r.Product__r.Minimum_Order_Quantity__c != null ? Integer.valueOf(inventory.Warehouse_Product__r.Product__r.Minimum_Order_Quantity__c) : null));
        }

        Map<Integer, String> errorByIndex = new Map<Integer, String>();
        Integer index = 0;
        for (Order_Product__c orderProduct : orderProducts) {
            errorByIndex.put(index, '');// default no error
            //if product have skip PHO SWarehouse Validation is true  then continue
            if(skipPHOSWarehouseValidation.get(orderProduct.Product__c) == true){
                index++;
                continue;
            }
            // if it is already sent then we don't need to check against remaining qty
            if(orderProduct.Status__c == 'Sent') {
                index++;
                continue;
            }
            // if Fulfilment Entity / Warehouse is blank or Quantity Filled is blank
            if(String.isBlank(orderProduct.Fulfilment_Entity_Warehouse__c) || orderProduct.Quantity_Filled__c == null) {
                index++;
                continue;
            }

            if(orderProduct.Fulfilment_Entity_Warehouse__c != null && orderProduct.Fulfilment_Entity_Warehouse__c == PHOS_Constants.FILLED_REGIONALLY_STATUS) {
                index++;
                continue;
            }

            // if Warehouse entry is missing
            if(warehouseQtyValidationMap.get(orderProduct.Fulfilment_Entity_Warehouse__c) == null && orderProduct.Fulfilment_Entity_Warehouse__c != PHOS_Constants.FILLED_REGIONALLY_STATUS) {
                errorByIndex.put(index, 'Warehouse config is missing.');
                returnMap.put('hasError', true);
                index++;
                continue;
            }

            // if check for validations is false then continue
            if(orderProduct.Fulfilment_Entity_Warehouse__c != null && warehouseQtyValidationMap.get(orderProduct.Fulfilment_Entity_Warehouse__c) == false) {
                index++;
                continue;
            }

             // if check for warehouse allow zero fulfilled Qty validations is true then continue
             if(orderProduct.Fulfilment_Entity_Warehouse__c != null && warehouseAllowZeroFulfilledQtyMap.get(orderProduct.Fulfilment_Entity_Warehouse__c) == true) {
                index++;
                continue;
            }
            
            //if Warehouse SKU is missing
            if(orderProduct.Warehouse_Info__c == null) {
                errorByIndex.put(index, 'SKU is missing for this warehouse');
                returnMap.put('hasError', true);
                index++;
                continue;
            }

            //Inventory record is missing
            if(remainingInventoryBySKU.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)) == null) {
                errorByIndex.put(index, 'Inventory record not found');
                returnMap.put('hasError', true);
                index++;
                continue;
            }

            //if Quantity Filled is less than Minimum Order Quantity for Product, then Error
            if(minimumQuantityInventory.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)) != null
                && (orderProduct.Quantity_Filled__c < minimumQuantityInventory.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)))) {
                errorByIndex.put(index,' Minimum Order Quantity for this Product is '+ minimumQuantityInventory.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)));
                returnMap.put('hasError', true);
                index++;
                continue;
            }

            //if MOD of Quantity Filled by Minimum Order Quantity for Product < 1, then Error
            if(minimumQuantityInventory.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)) != null
                    && (math.mod(Integer.valueOf(orderProduct.Quantity_Filled__c), minimumQuantityInventory.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c))) != 0 )) {
                errorByIndex.put(index,' Case Quantity for this Product must be in increments of '+ minimumQuantityInventory.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)));
                returnMap.put('hasError', true);
                index++;
                continue;
            }

            //if remaining quantity on Inventory is less than Quantity filled, give Error
            if(remainingInventoryBySKU.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)) < orderProduct.Quantity_Filled__c ) {
                    errorByIndex.put(index, ' Insufficient Quantity at this Warehouse. Maximum Order Quantity for this Product is '
                                + remainingInventoryBySKU.get(orderProduct.Warehouse_Info__c + warehouseMap.get(orderProduct.Fulfilment_Entity_Warehouse__c)));
                    returnMap.put('hasError', true);
                    index++;
                    continue;
            }
            index++;
        }
        returnMap.put('errorMap', errorByIndex);
        return returnMap;
    }

    /***********************************************
    * Method Name : getFieldDetails
    * Author : Pankaj
    * Inputs : string fieldsJSON, string objectName
    * Description: This method return list of Field details for specific object using JSON fields
    *********************************************/
    @AuraEnabled
    public static List<FieldDetails> getFieldDetails(string fieldsJSON, string objectName){
        List<FieldDetails> fieldDetailsList = new List<FieldDetails>();
        fieldDetailsList = (List<FieldDetails>)JSON.deserialize(fieldsJSON, List<FieldDetails>.class);

        for(FieldDetails fieldDtl : fieldDetailsList){
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldDtl.APIName).getDescribe();

            fieldDtl.fieldType = getFieldType(fieldResult.getType());
            if(fieldDtl.isRequired==null){
                fieldDtl.isRequired = false;
            }
            if(fieldDtl.isDisabled==null){
                fieldDtl.isDisabled = false;
            }
            if(fieldDtl.enablePostSent==null){
                fieldDtl.enablePostSent = false;
            }

            if(fieldResult.getType() ==  Schema.DisplayType.PICKLIST){
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                fieldDtl.picklistValues = new List<string>();
                for( Schema.PicklistEntry f : ple){
                    fieldDtl.picklistValues.add(f.getValue());
                }
            }
        }
        return fieldDetailsList;
    }

    //Field detail wrapper
    /***********************************************************************************************************************************
    * Class Name   : FieldDetails
    * Description  : This is wrapper class for get field details
    * Author       : Pankaj
    * Created On   : 07/31/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj               07/31/2020       Initial Implementation
    **************************************************************************************************************************************/

    public class FieldDetails{
        @AuraEnabled public string APIName;
        @AuraEnabled public string Label;
        @AuraEnabled public string fieldType;
        @AuraEnabled public string OnChangeFormula;
        @AuraEnabled public boolean isRequired = false;
        @AuraEnabled public boolean isDisabled = false;
        @AuraEnabled public boolean enablePostSent = false;
        @AuraEnabled public List<string> picklistValues = new List<string>();
    }

    /***********************************************
    * Method Name : getFieldType
    * Author : Pankaj
    * Inputs : Schema.DisplayType fieldType
    * Description: This method return string of field type
    *********************************************/
    @TestVisible
    private static string getFieldType(Schema.DisplayType fieldType ){
        if(fieldType == Schema.DisplayType.String ||
                fieldType == Schema.DisplayType.TextArea ||
                fieldType == Schema.DisplayType.Phone ||
                fieldType == Schema.DisplayType.Email ||
                fieldType == Schema.DisplayType.URL)
            return 'STRING';

        if(fieldType == Schema.DisplayType.Currency)
            return 'CURRENCY';

        if(fieldType == Schema.DisplayType.Double||
                fieldType == Schema.DisplayType.Integer)
            return 'DOUBLE';

        if(fieldType == Schema.DisplayType.Boolean)
            return 'BOOLEAN';

        if(fieldType == Schema.DisplayType.DateTime)
            return 'DATETIME';

        if(fieldType == Schema.DisplayType.Date)
            return 'DATE';

        if(fieldType == Schema.DisplayType.PICKLIST)
            return 'PICKLIST';

        if(fieldType == Schema.DisplayType.MultiPicklist)
            return 'MULTIPICKLIST';

        return 'UNKNOWN';
    }

    /***********************************************
    * Method Name : getAppName
    * Author : Pankaj
    * Inputs : -
    * Description: This method return string of app name
    *********************************************/
    public static String getAppName() {
        Profile userProfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String profileName = userProfile.name;
        if(ApexUtils.checkCommunityUser()) {
            return 'PHOS Community User';
        }
        UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
        AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition Where DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
        return appDefinition.Label;
    }
}