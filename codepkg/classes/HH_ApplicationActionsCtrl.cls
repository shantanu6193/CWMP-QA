public with sharing class HH_ApplicationActionsCtrl {


      /***********************************************
    * Method Name : isExternalUser
    * Author : Shantanu
    * Description: This method will check if current user is External user.
    *********************************************/
    @AuraEnabled
    public static  Map<String,Object>  isExternalUser(){
        Map<String,Object> result = new Map<String,Object>();
        User user = [SELECT Id,AccountId,LanguageLocaleKey FROM User WHERE Id=:UserInfo.getUserId()];
        result.put('isExternal', user.AccountId != null);
        result.put('language', user.LanguageLocaleKey);
        return result;  
    }
    
     /***********************************************
    * Method Name : deleteApplication
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method delete application if stage is Draft and Status is New
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> deleteApplication(String applicationId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            HH_Application__c application  = new SystemContextProvider().getApplication(applicationId);
            if(application.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft &&
                application.Status__c == HH_CONSTANTS.HHApplication_Status_New) {
                new SystemContextProvider().deleteApplication(application);
                result.put('isDelete', true);
                result.put('success', true);
            } else {
                result.put('success', true);
                result.put('isDelete', false);
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', e.getMessage());
        }
        return result;
    }

     /***********************************************
    * Method Name : editApplication
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's if Application is Editable.
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> editApplication(String applicationId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            Boolean isEdit = HH_EditRequestCtrl.isApplicationEditable(applicationId);
            if(isEdit) {
                result.put('success', true);
                result.put('isEditable',true);
            } else {
                result.put('success', true);
                result.put('isEditable', false);
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', e.getMessage());
        }
        return result;
    }

    public  without sharing class SystemContextProvider {


        public HH_Application__c getApplication( String applicationId) {
            return [SELECT Stage__c,Status__c FROM HH_Application__c WHERE Id=:applicationId LIMIT 1];
        }
        
        public void deleteApplication(HH_Application__c app) {
            delete app;
        }
        
    }

}