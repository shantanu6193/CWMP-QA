/***********************************************************************************************************************************
* Class Name   : ProgressBarWithSubStepsCtrl
* Description  : This class for get picklist values and record
* Author       : Pankaj
* Created On   : 04/21/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/21/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class ProgressBarWithSubStepsCtrl {
    
    /***********************************************
    * Method Name : getInitData
    * Author : Pankaj
    * Inputs : String sObjectName,String fieldName,String recordId
    * Description: This method return map of picklist values and record
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getInitData(String sObjectName,String fieldName,String recordId) {
        Map<String, Object> returnMap = new Map<String, Object>();  
        String keyPrefix = recordId.substring(0,3);
        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
            String prefix = obj.getDescribe().getKeyPrefix();
             if(prefix == keyPrefix){
                sObjectName = obj.getDescribe().getName();
                break;
              }
        }
        List<Schema.PicklistEntry> picklistEntries = getPickListData(sObjectName, fieldName);
        Map<String, String> keyValueMap = new Map<String, String>();
        for(Schema.PicklistEntry entry : picklistEntries) {
            keyValueMap.put(entry.getValue(), entry.getLabel());
        }

        List<Map<String, String>> pickListOptions = PicklistUtility.getPicklistOptions(sObjectName,fieldName);
        returnMap.put('PickListOptions',pickListOptions);
        String query = 'SELECT Id,' + fieldName + ' FROM ' + sObjectName + ' WHERE Id =\'' + recordId+'\'';
        Sobject record = Database.query(query);
        String fieldValue = (String)record.get(fieldName);
        record.put(fieldName,keyValueMap.get(fieldValue));
        returnMap.put('Record',record);
        User userRec = ApexUtils.getCurrentUserDetails();
        if(userRec.AccountId != null) {
            returnMap.put('CommunityUser',true);
        } else {
            returnMap.put('CommunityUser',false);
        }

        return returnMap;
    }

    /***********************************************
    * Method Name : updateRecord
    * Author : Pankaj
    * Inputs : String sObjectName,String fieldName,String recordId,String updatedValue
    * Description: This method update records of specified object, field and return map of record
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> updateRecord(String sObjectName,String fieldName,String recordId,String updatedValue) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String keyPrefix = recordId.substring(0,3);
        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
            String prefix = obj.getDescribe().getKeyPrefix();
             if(prefix == keyPrefix){
                sObjectName = obj.getDescribe().getName();
                break;
              }
        }
        List<Schema.PicklistEntry> picklistEntries = getPickListData(sObjectName, fieldName);
        Map<String, String> keyValueMap = new Map<String, String>();
        for(Schema.PicklistEntry entry : picklistEntries) {
            keyValueMap.put(entry.getLabel(), entry.getValue());
        }
        String query = 'SELECT Id,' + fieldName + ' FROM ' + sObjectName + ' WHERE Id =\'' + recordId+'\'';
        String valueToUpdate = keyValueMap.get(updatedValue);
        Sobject record = Database.query(query);
        record.put(fieldName,valueToUpdate);
        update record;
        record.put(fieldName,updatedValue);
        returnMap.put('Record',record);
        return returnMap;
    }
    /***********************************************
    * Method Name : getPickList
    * Author : Shivraj
    * Inputs : String sObjectName,String fieldName
    * Description: This method returns label & value of the picklist field
    *********************************************/
    public static List<Schema.PicklistEntry> getPickListData(String sObjectName, String fieldName) {
        SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        SObjectField fieldToken = fields.get(fieldName);
        DescribeFieldResult selectedField = fieldToken.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = selectedField.getPicklistValues();
        return picklistEntries;
    }
}