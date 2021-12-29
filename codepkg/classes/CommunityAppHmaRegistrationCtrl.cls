/***********************************************************************************************************************************
* Class Name   : CommunityAppHmaRegistrationCtrl
* Description  : An apex page controller that supports self registration of users in communities that allow self registration
* Author       : Pankaj
* Created On   : 07/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            07/09/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunityAppHmaRegistrationCtrl {

    /***********************************************
    * Method Name : processHMARequest
    * Author : Pankaj
    * Inputs : -
    * Description: This method process the HMA App Request.
    *********************************************/
    @AuraEnabled
    public static void processHMARequest() {
        
        Map<Id, Set<Id>> appTouserIds = new Map<Id, Set<Id>>();
        Community_Application__c communityApplication = [SELECT Id FROM Community_Application__c WHERE Name='HMA'];
        appTouserIds.put(communityApplication.Id, new Set<Id>());
        appTouserIds.get(communityApplication.Id).add(UserInfo.getUserId());
        UserService.addApplicationToUser(appTouserIds);

    }

    /***********************************************
    * Method Name : getUserDetails
    * Author : Pankaj
    * Inputs : -
    * Description: This method return Map of Contact details.
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getUserDetails(){
        Map<String,Object> returnMap = new Map<String,Object>();
        String userId = UserInfo.getUserId();
        User userRec = [SELECT Id,ContactId from User where Id =:userId];
        Contact contactRec = [SELECT FirstName,LastName,Email,Phone,Account.Parent.Name,Account.Name,Account.Entity_Type__c FROM Contact WHERE Id =: userRec.ContactId];
        returnMap.put('ContactDetails',contactRec);
        return returnMap;
    }

}