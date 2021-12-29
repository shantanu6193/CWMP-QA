/***********************************************************************************************************************************
* Class Name   : CommunityAppMARSRegistrationCtrl
* Description  : An apex page controller that supports self registration of users in communities that allow self registration for MARS App
* Author       : Sravan Reddy Pinninti
* Created On   : 03/14/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sravan            03/14/2021       Initial Implementation
**************************************************************************************************/

public without sharing class CommunityAppMARSRegistrationCtrl {
    
    @AuraEnabled
    public static Map<String,Object> getUserDetails(){
        Map<String,Object> returnMap = new Map<String,Object>();
        String userId = UserInfo.getUserId();
        User userRec = [SELECT Id,ContactId from User where Id =:userId];
        Contact contactRec = [SELECT FirstName,LastName,Email,Phone,Account.Parent.Name,Account.Name,Account.Entity_Type__c FROM Contact WHERE Id =: userRec.ContactId];
        returnMap.put('ContactDetails',contactRec);
        return returnMap;
    }

    @AuraEnabled
    public static void processMARSRequest(string accessLevel, string accountId, string contactId){
        User userRec =  ApexUtils.getCurrentUserDetails();
        Group recordOwner= [SELECT Id FROM Group  WHERE DeveloperName ='MARS_User_Request_Approval' AND Type='Queue'];
        User_Registration__c registration = new User_Registration__c();
        registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('MARS').getRecordTypeId();
        registration.Community_Application__c = [SELECT Id FROM Community_Application__c WHERE Name='MARS' LIMIT 1].Id;
        registration.First_Name__c =  userRec.FirstName;
        registration.Last_Name__c = userRec.LastName;
        registration.Email__c = userRec.Email;
        registration.Fire_Agency__c = accountId;
        registration.Status__c = 'App Requested';
        registration.Entity_Type__c = 'Fire Agency';
        registration.Access_Level__c = accessLevel;
        registration.Contact_Name__c = ContactId;
        registration.User__c = UserInfo.getUserId();
        registration.OwnerId = recordOwner.Id;
        

        insert registration;


    }

    
    @AuraEnabled
    public static void processMARSPayingEntityRequest(string accountId, string contactId){
        User userRec =  ApexUtils.getCurrentUserDetails();
        Group recordOwner= [SELECT Id FROM Group  WHERE DeveloperName ='MARS_User_Request_Approval' AND Type='Queue'];
        User_Registration__c registration = new User_Registration__c();
        registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('MARS').getRecordTypeId();
        registration.Community_Application__c = [SELECT Id FROM Community_Application__c WHERE Name='MARS' LIMIT 1].Id;
        registration.First_Name__c =  userRec.FirstName;
        registration.Last_Name__c = userRec.LastName;
        registration.Email__c = userRec.Email;
        registration.MARS_Paying_Entity__c = accountId;
        registration.Status__c = 'App Requested';
        registration.Entity_Type__c = 'MARS Paying Entity';
        registration.Contact_Name__c = ContactId;
        registration.User__c = UserInfo.getUserId();
        registration.OwnerId = recordOwner.Id;
        

        insert registration;


    }
    
}