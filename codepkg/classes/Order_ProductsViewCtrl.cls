/***********************************************************************************************************************************
* Class Name   : Order_ProductsViewCtrl
* Description  : This class for get order product
* Author       : Pankaj
* Created On   : 07/31/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               07/31/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class Order_ProductsViewCtrl {
    
    /***********************************************
    * Method Name : getOrderProducts
    * Author : Pankaj
    * Inputs : String orderId, String fieldAPINames
    * Description: This method return map of order products,order status and app name
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrderProducts(String orderId, String fieldAPINames){
        Map<String, Object> returnMap = new Map<String, Object>();
        List<String> fieldAPINameList = (List<String>) JSON.deserialize(fieldAPINames, List<String>.class);
        String query = 'SELECT ' + String.join(fieldAPINameList, ',') + ',Id,Product__r.Name FROM Order_Product__c WHERE Order__c =: orderId';
        List<Order_Product__c> orderItems = Database.query(query);
        Order__c order = [Select Id, Status__c from Order__c where Id =: orderId];
        System.debug('orderItems' + orderItems);
        returnMap.put('orderItems', orderItems);
        returnMap.put('orderStatus', order.Status__c);
        returnMap.put('appName', getAppName());
        Boolean orderApproved = false;
        Boolean hasEditAccess = ApexUtils.checkIfCurrentUserHasEditAccess(orderId);
        returnMap.put('hasEditAccess', hasEditAccess);
        Boolean showRecordLockedError = false;
        Boolean isLocked = Approval.isLocked(orderId);
        User userRec = ApexUtils.getCurrentUserDetails();
        Set<String> orderStatuses = new Set<String>{'Draft', 'MHOAC Review', 'RDMHS Review'};
        if(hasEditAccess == true && isLocked == true){
            showRecordLockedError = ApexUtils.showErrorWhenRecordLocked(orderId);
        } else if(!orderStatuses.contains(order.Status__c) && userRec.AccountId != null) {
            showRecordLockedError = true;
            orderApproved = true;
        }
        returnMap.put('ShowRecordLockedError',showRecordLockedError);
        returnMap.put('OrderApproved',orderApproved);
        if(userRec.AccountId != null) {
            returnMap.put('isCommunityUser',true);
        } else {
            returnMap.put('isCommunityUser',false);
        }
        Boolean isCountyChild = false;
        if(userRec.Contact.Account.Parent.Entity_Type__c != null  && userRec.Contact.Account.Parent.Entity_Type__c == 'County'){
            isCountyChild = true;
        }
        returnMap.put('CountyChild',isCountyChild);
        return returnMap;
    }

    /***********************************************
    * Method Name : getAppName
    * Author : Pankaj
    * Inputs : -
    * Description: This method return string of app name
    *********************************************/
    public static String getAppName() {
        if(ApexUtils.checkCommunityUser()) {
            return 'Community User';
        }
        UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
        AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition Where DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
        return appDefinition.Label;
    }
}