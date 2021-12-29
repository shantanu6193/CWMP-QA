/***********************************************************************************************************************************
* Class Name   : PHOS_Order_Products_EditCtrl
* Description  : This class for get the order Items/products
* Author       : Pankaj
* Created On   : 04/24/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/24/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_Order_Products_EditCtrl {

    
    /***********************************************
    * Method Name : getProducts
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of all active products
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getProducts(){
        //return all active products
        return Order_ProductHelper.getProducts();
    }

    /***********************************************
    * Method Name : getOrderProductDetails
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return map of order items of a order
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrderProductDetails(String orderId){
        Map<String,Object> returnMap = new Map<String,Object>();
        //get orderItems associated with Order
        List<OrderItem> orderItems = [
                SELECT
                        AvailableQuantity,
                        Cost__c,
                        CreatedById,
                        CreatedDate,
                        Description,
                        EndDate,
                        Estimated_time_of_Arrival__c,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        ListPrice,
                        OrderId,
                        OrderItemNumber,
                        OriginalOrderItemId,
                        PricebookEntryId,
                        Product2Id,
                        Product2.Name,
                        Product2.Family,
                        Quantity,
                        QuoteLineItemId,
                        ServiceDate,
                        SystemModstamp,
                        TotalPrice,
                        Tracking__c,
                        UnitPrice,
                        Item_Code__c,
                        Quantity_Filled__c,
                        Quantity_Approved__c,
                        Quantity_Back_Ordered__c,
                        Equivalent_Substitutes_Acceptable__c,
                        Delivered_On_Date__c,
                        Carrier_Tracking__c,
                        Fulfilment_Entity_Warehouse__c,
                        Mission__c
                FROM OrderItem WHERE OrderId=:orderId];
        returnMap.put('orderItems', orderItems);
        return returnMap;
    }
    @AuraEnabled
    public static void saveOrderItems(Map<String, Object> paramMap){
        //Save OrderItems
        //Order_ProductHelper.saveOrderItems(paramMap);
    }
    @AuraEnabled
    public static Map<String, String> getPickListData(String sObjectName, String fieldName) {
        SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        SObjectField fieldToken = fields.get(fieldName);
        DescribeFieldResult selectedField = fieldToken.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = selectedField.getPicklistValues();
        Map<String, String> keyValueMap = new Map<String, String>();
        for(Schema.PicklistEntry entry : picklistEntries) {
            keyValueMap.put(entry.getValue(), entry.getLabel());
        }
        return keyValueMap;
    }
}