/***********************************************************************************************************************************
* Class Name   : Order_ProductHelper
* Description  : This class for get order product
* Author       : Pankaj
* Created On   : 04/17/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               04/24/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class Order_ProductHelper {

    /***********************************************
    * Method Name : getProducts
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of products
    *********************************************/
    public static Map<String,Object> getProducts() {
        Map<String,Object> returnMap = new Map<String,Object>();
        String query = 'Select Id, Name, ProductCode, Family from Product2 where IsActive = true AND Available_to_use_in_PHOS__c = true ';
        User user = [SELECT Id,AccountId,Account.Entity_Type__c,Account.Parent.Product_Filter_Clause__c,Account.Product_Filter_Clause__c
            FROM User
            WHERE Id=:UserInfo.getUserId()];

        if(user.Account != null && String.isNotBlank(user.Account.Product_Filter_Clause__c)) {
            query += user.Account.Product_Filter_Clause__c;
        }else if(user.Account != null && user.Account.Parent != null && String.isNotBlank(user.Account.Parent.Product_Filter_Clause__c)) {
            query += user.Account.Parent.Product_Filter_Clause__c;
        } else if(user.Account != null){
            query += ' AND Hide_for_PHOS_Portal_Users__c != true ';
        }
        query += ' ORDER BY Name';
        //System.assertEquals(query, user.Account.Entity_Type__c);
        List<Product2> product2s = Database.query(query);
        List<Product2> product2sList = new List<Product2>();
        List<Product2> product2sOtherList = new List<Product2>();


        for(Product2 product2 : product2s) {
            if(product2.Name != 'Other'){
                product2sList.add(product2);
            }else if(product2.Name == 'Other'){
                product2sOtherList.add(product2);
            }
        }
        product2sList.addAll(product2sOtherList);
        returnMap.put('Products', product2sList);
        return returnMap;
    }

    /*public static void saveOrderItems(Map<String, Object> paramMap) {

        List<OrderItem> orderItems = (List<OrderItem>) JSON.deserialize(String.valueOf(paramMap.get('OrderItems')), List<OrderItem>.class);
        String orderId = (String) paramMap.get('orderId');
        AppUtils.generateSnapshotInJSON(orderId);

        List<String> orderItemIds = new List<String>();
        for (OrderItem orderItem : orderItems) {
            if(String.isNotEmpty(orderItem.Id)) {
                orderItemIds.add(orderItem.Id);
            }
        }
        List<OrderItem> orderItemsToDelete = new List<OrderItem>();
        if (orderItemIds.size() == 0) {
            orderItemsToDelete = [SELECT Id FROM OrderItem WHERE OrderId=:orderId];
        } else {
            orderItemsToDelete = [SELECT Id FROM OrderItem WHERE OrderId=:orderId AND Id NOT IN :orderItemIds];
        }
        delete orderItemsToDelete;

        List<String> productIds = new List<String>();
        for (OrderItem orderItem : orderItems) {
            if (String.isEmpty(orderItem.OrderId)) {
                orderItem.OrderId = orderId;
            }
            if (orderItem.UnitPrice == null) {
                orderItem.UnitPrice = 0;
            }
            productIds.add(orderItem.Product2Id);
        }
        List<PricebookEntry> pricebookEntries = [Select Id,Product2Id FROM PricebookEntry
        WHERE Product2Id IN :productIds AND IsActive=TRUE];
        Map<String, PricebookEntry> priceBookByProduct = new Map<String, PricebookEntry>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            priceBookByProduct.put(pricebookEntry.Product2Id, pricebookEntry);
        }
        List<PricebookEntry> pricebookEntries2 = new List<PricebookEntry>();
        for (String productId : productIds) {
            if (priceBookByProduct.get(productId) == null) {
                PricebookEntry pricebookEntry = new PricebookEntry(Product2Id=productId, UnitPrice=0, UseStandardPrice=true);
                pricebookEntries2.add(pricebookEntry);
                priceBookByProduct.put(pricebookEntry.Product2Id, pricebookEntry);
            }
        }
        insert pricebookEntries2;
        for (OrderItem orderItem : orderItems) {
            if (orderItem.PricebookEntryId == null) {
                orderItem.PricebookEntryId = priceBookByProduct.get(orderItem.Product2Id).Id;
            }
        }

        upsert orderItems;

    }*/

    /*public static List<String> getFulfilmentEntity() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = OrderItem.Fulfilment_Entity_Warehouse__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }*/

}