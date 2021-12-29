/***********************************************************************************************************************************
* Class Name   : Order_PageDeciderCtrl
* Description  : This class for order page decider
* Author       : Pankaj
* Created On   : 04/17/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               04/17/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class Order_PageDeciderCtrl {

    /***********************************************
    * Method Name : getInitData
    * Author : Pankaj
    * Inputs : String oppId
    * Description: This method return map of CurrentAppName, AccountId and Bulk_Procurement_RecordTypeId
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getInitData(String oppId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        UserAppInfo userApp = [SELECT Id, AppDefinitionId
                                        FROM UserAppInfo WHERE UserId = :UserInfo.getUserId()  ORDER BY CreatedDate DESC LIMIT 1];
        AppDefinition appDef = [SELECT DurableId, Label,DeveloperName FROM AppDefinition
                                            Where DurableId = :userApp.AppDefinitionId LIMIT 1];

        returnMap.put('CurrentAppName', appDef.DeveloperName);
        if(oppId != null){
            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id=:oppId];
            returnMap.put('AccountId', opp.AccountId);
        }
        returnMap.put('Bulk_Procurement_RecordTypeId', Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName()
                .get('Bulk_Procurement').getRecordTypeId());

        return returnMap;
    }
}