/***********************************************************************************************************************************
* Class Name   : CommunityHomePageCtrl
* Description  : This class to get the data for Community Home Page 
* Author       : Pankaj
* Created On   : 07/08/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            07/08/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunityHomePageCtrl {

    
    /***********************************************
    * Method Name : isTermsPolicyAccepted
    * Author : Dayal
    * Inputs : -
    * Description: this method check the user is accepted terms ploicy or not
    *********************************************/
    public static Boolean isTermsPolicyAccepted(){        
        String userId = UserInfo.getUserId();  
        User_Preference__c userPreference = User_Preference__c.getInstance(userID);
        if(userPreference != null && userPreference.Term_Acceptance__c == true) {
            return true;
        }
       return false;
    }

    /***********************************************
    * Method Name : accepteTermsAndPloicy
    * Author : Dayal
    * Inputs : -
    * Description: it click the accept terms policy if user click on accept button
    *********************************************/
    @AuraEnabled
    public static Boolean accepteTermsAndPolicy(){
        Boolean isAccepted = false;
        try{
            String userId = UserInfo.getUserId();
            User_Preference__c userPreference = new User_Preference__c();
            userPreference.SetupOwnerId = userId;
            userPreference.Term_Accepted_Date__c = DateTime.now();
            userPreference.Term_Acceptance__c = true;
            upsert userPreference;
            isAccepted = true;
        }catch(Exception e){
            throw new AuraHandledException('Terms and policy not accpted');
        }  
        return  isAccepted;  
   }

    /***********************************************
    * Method Name : getAllApplications
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of all applications with apps, announcements and contact details.
    *********************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAllApplications() {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Id> communityAppIds = new List<Id>();    
        List<Community_Application_to_User__c> communityAppIdLst = [SELECT Community_Application__r.Id 
                                            FROM Community_Application_to_User__c WHERE User__c =: UserInfo.getUserId()];
        for(Community_Application_to_User__c commAppUser: communityAppIdLst){
                communityAppIds.add(commAppUser.Community_Application__r.Id);
        }                                    
        // Set<Id> resultIds = (new Map<Id,SObject>(communityAppIdLst)).keySet();   
                                     
        List<Community_Application__c> communityApplications = [
                SELECT
                        Id,
                        Description__c,
                        Display_Name__c,
                        isActive__c,
                        Name,
                        isPrivateApp__c,
                        App_URL__c,
                        Logo_Name__c,
                    (   SELECT Id FROM Community_Application_to_Users__r
                            WHERE User__c=:UserInfo.getUserId() AND isActive__c=TRUE ),
                    (   SELECT Community_Application__r.Name, Id, Name, RecordTypeId, Status__c FROM CommunityRegistration__r
                            where CreatedById =: UserInfo.getUserId() And Status__c =: PHOS_Constants.APPROVAL_STATUS_APP_REQUESTED )
                FROM Community_Application__c WHERE isActive__c = TRUE AND Show_on_Portal__c = TRUE AND (isPrivateApp__c = false OR Id IN :communityAppIds) ORDER BY Sequence__c ASC ];
        System.debug('Apps: '+communityApplications);
        returnMap.put('Apps', communityApplications);
        returnMap.put('UserId',UserInfo.getUserId());
        returnMap.put('Announcements',getAnnouncements());
        returnMap.put('ContactDetails',getUserDetails());
        returnMap.put('isTermsPolicyAccepted',isTermsPolicyAccepted());
        return returnMap;
    }

    /***********************************************
    * Method Name : getAnnouncements
    * Author : Pankaj
    * Inputs : -
    * Description: This method return an announcement meatadata.
    *********************************************/
    private static List<Announcement__mdt> getAnnouncements(){
        List<Announcement__mdt> announcements = [select Title__c,Description__c,Image__c,Sequence__c from Announcement__mdt where IsActive__c = true Order By Sequence__c];
        return announcements;
    }

    /***********************************************
    * Method Name : getUserDetails
    * Author : Pankaj
    * Inputs : -
    * Description: This method return contact details.
    *********************************************/
    private static Contact getUserDetails(){
        String userId = UserInfo.getUserId();
        User userRec = [SELECT Id,ContactId from User where Id =:userId];
        Contact contactRec = [SELECT FirstName,LastName,Email,Phone,Account.Name,Account.Entity_Type__c FROM Contact WHERE Id =: userRec.ContactId];
        return contactRec;
    }

     /***********************************************
    * Method Name : paAppAccesCheck
    * Author : Pankaj
    * Inputs : -
    * Description: This method to check for .
    *********************************************/
    private static Boolean isPAAppAccessible(){
        Boolean hasPAAppAccess;
        String userId = UserInfo.getUserId();
       Community_Application_to_User__c commAppUser = [SELECT Id, Community_Application__c, Community_Application__r.Name
                                                        FROM  Community_Application_to_User__c 
                                                        WHERE User__r.Id =:userId and Community_Application__r.Name = 'PA']; 
        if(commAppUser == null){
            hasPAAppAccess = false;
        }else{
            hasPAAppAccess = true;
        }
        return hasPAAppAccess;
    }
}