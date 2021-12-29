/***********************************************************************************************************************************
* Class Name   :CommunityAppHHRegistrationCtrl
* Description  : This class for create UserRequest for CWMP Application.
* Author       : Shantanu
* Created On   : 12/06/2021 (mm/dd/yyyy)
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu               12/06/2021     Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunityAppHHRegistrationCtrl {

    /***********************************************
    * Method Name : getUserDetails
    * Author : Shantanu
    * Description: This method call to get Currentuser contact details.
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getUserDetails(){
        Map<String,Object> returnMap = new Map<String,Object>();
        User userRec = [SELECT Id,ContactId from User where Id =:UserInfo.getUserId()];
        Contact contactRec = [SELECT FirstName,LastName,Email,Phone,Account.Parent.Name,Account.Name,Account.Entity_Type__c FROM Contact 
                                WHERE Id =: userRec.ContactId];
        returnMap.put('ContactDetails',contactRec);
        return returnMap;
    }

     /***********************************************
    * Method Name : processHHRequest
    * Author : Shantanu
    * Input : string accountId, string contactId, String userType, String countyName
    * Description: This method will redirect to Process request depending on permission set.
    *********************************************/
    @AuraEnabled
    public static void processHHRequest(string accountId, string contactId, String userType, String countyName){
            if (userType == HH_CONSTANTS.UserRegistration_UserType_Community) {
                processCommunityUserRequest(accountId, contactId, userType, countyName);
            } else if (userType == HH_CONSTANTS.UserRegistration_UserType_FEMA) {
                processFEMAUserRequest(accountId, contactId, userType);
            }
    }


     /***********************************************
    * Method Name : processCommunityUserRequest
    * Author : Shantanu
    * Input : string accountId, string contactId, String userType, String countyName
    * Description: This method will create User_Registration__c request of CWMP App for Community User.
    *********************************************/
    private static void processCommunityUserRequest(string accountId, string contactId, String userType, String countyName) {
        User userRec =  ApexUtils.getCurrentUserDetails();
        String actualCountyName = countyName.substring(0,countyName.indexOf(',')).trim();
        System.debug('County Name: '+ actualCountyName);
        County_Config__mdt countyConfig = [SELECT Id,County_User_Approver_Queue_API_Name__c FROM County_Config__mdt 
                                            WHERE label =: actualCountyName LIMIT 1];
        if(countyConfig == null)  {
            throw new AuraHandledException('No Approver Queue found for '+actualCountyName);
        }
        Group recordOwner= [SELECT Id FROM Group  WHERE Type='Queue' AND DeveloperName =:countyConfig.County_User_Approver_Queue_API_Name__c];
        User_Registration__c registration = new User_Registration__c();
        registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.RecordType_HH_RegistrationAPIName).getRecordTypeId();
        List<Community_Application__c> communityApps = [SELECT Id FROM Community_Application__c 
        WHERE Name =:HH_CONSTANTS.HH_Parent_Community_Application_Name AND isActive__c = true];
        if(communityApps.size() == 0) {
            throw new AuraHandledException('No active Community Application Found for '+userType);
        }
        registration.Community_Application__c = communityApps.get(0).Id;
        registration.First_Name__c =  userRec.FirstName;
        registration.Last_Name__c = userRec.LastName;
        registration.Email__c = userRec.Email;
        registration.User_Type__c = userType;
        registration.Entity_Type__c = userRec.Contact.Account.Entity_Type__c;
        registration.Status__c = 'App Requested';
        registration.County__c = countyName;
        registration.Contact_Name__c = contactId;
        registration.User__c = UserInfo.getUserId();
        registration.OwnerId = recordOwner.Id;
        insert registration;
    }


     /***********************************************
    * Method Name : processFEMAUserRequest
    * Author : Shantanu
    * Input : string accountId, string contactId, String userType, String countyName
    * Description: This method will create User_Registration__c request of CWMP App for FEMA User.
    *********************************************/
    private static void processFEMAUserRequest(String accountId, String contactId, String userType) {
        User userRec =  ApexUtils.getCurrentUserDetails();
        List<Group> groupList = [SELECT Id FROM Group  WHERE Type='Queue' AND DeveloperName =:HH_CONSTANTS.HH_CalOESInternal_User_Queue_APIName];       
        if(groupList.size() == 0) {
            throw new AuraHandledException('No Approver Queue found with API Name - '+HH_CONSTANTS.HH_CalOESInternal_User_Queue_APIName);
        }
        System.debug('groupList: '+groupList);
        User_Registration__c registration = new User_Registration__c();
        registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.RecordType_HH_RegistrationAPIName).getRecordTypeId();
        List<Community_Application__c> communityApps = [SELECT Id FROM Community_Application__c 
        WHERE Name =:HH_CONSTANTS.HH_Parent_Community_Application_Name  AND isActive__c = true];
        if(communityApps.size() == 0) {
            throw new AuraHandledException('No active Community Application Found for '+userType);
        }
        registration.Community_Application__c = communityApps.get(0).Id;
        registration.First_Name__c =  userRec.FirstName;
        registration.Last_Name__c = userRec.LastName;
        registration.Email__c = userRec.Email;
        registration.User_Type__c = userType;
        registration.Entity_Type__c = userRec.Contact.Account.Entity_Type__c;
        registration.Federal_Agency__c = userRec.AccountId;
        registration.Status__c = 'App Requested';
        registration.Contact_Name__c = contactId;
        registration.User__c = UserInfo.getUserId();
        registration.OwnerId = groupList.get(0).Id;
        insert registration;
    }
}