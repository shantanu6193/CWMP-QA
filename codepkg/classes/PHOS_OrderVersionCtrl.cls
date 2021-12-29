/***********************************************************************************************************************************
* Class Name   : PHOS_OrderVersionCtrl
* Description  : This class for PHOS order version and get products
* Author       : Pankaj
* Created On   : 04/03/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/03/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class PHOS_OrderVersionCtrl {

    /***********************************************
    * Method Name : getProducts
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of all active products
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getProducts(){
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Product2> product2s = [Select Id, Name,ProductCode, Family from Product2 where IsActive = true ORDER BY Name];
        List<Product2> product2sList = new List<Product2>();
        List<Product2> product2sOtherList = new List<Product2>();


        for(Product2 product2 : product2s){
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

    /***********************************************
    * Method Name : getVersion
    * Author : Pankaj
    * Inputs : String orderVersionId
    * Description: This method return map of Order products and order records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getVersion(String orderVersionId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Order_Version__c orderVersion = [SELECT Id,Order__c,Order_Custom__c, Version_Data__c, CreatedDate, CreatedBy.Name FROM Order_Version__c where Id=:orderVersionId];
        Order__c orderRec = (Order__c)JSON.deserialize(orderVersion.Version_Data__c, Order__c.class);
        returnMap.put('orderRec', JSON.deserializeUntyped(orderVersion.Version_Data__c));
        returnMap.put('orderItems', orderRec.Order_Products__r);
        returnMap.put('orderVersion', orderVersion);
        return returnMap;
    }
}