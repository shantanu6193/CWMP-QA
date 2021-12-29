/***********************************************************************************************************************************
* Class Name   : HMANOI_EditRequestCtrl
* Description  : This class for get data to HMA NOI Edit Request
* Author       : Pankaj
* Created On   : 07/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              07/12/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HMANOI_EditRequestCtrl {
    
    /***********************************************
    * Method Name : getInitData
    * Author : Pankaj
    * Inputs : String preAppId
    * Description: This method return map of Object
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getInitData(String preAppId) {
        Boolean isEdit;
        Map<String, Object> returnMap  = new Map<String, Object>();
        Pre_Application__c preApp = [Select id, Current_Stage__c,Status__c from Pre_Application__c where Id =: preAppId];
        if(preApp.Status__c == 'Draft' || preApp.Status__c == 'Pending Review') {
            isEdit = true;
            returnMap.put('isEdit', isEdit);
            if(preApp.Current_Stage__c == 'Record Submitted') {
                preApp.Current_Stage__c = 'GeneralInfo';
            }
            returnMap.put('currentStage', preApp.Current_Stage__c);
        }else {
            isEdit = false;
            returnMap.put('isEdit', isEdit);
            returnMap.put('currentStage', preApp.Current_Stage__c);
        }
        return returnMap;
    }
}