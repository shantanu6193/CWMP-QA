/***********************************************************************************************************************************
* Class Name   : HH_UpdateApplicationLeadCtrl
* Description  : This Controller class is used in hhApplicationLead LWC component.
* Author       : Shantanu
* Created On   : 17/11/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu             17/11/2021       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HH_UpdateApplicationLeadCtrl {


    @AuraEnabled
    public static Map<String,Object>  getQueueName(String applicationId) {
        Map<String,Object> returnMap = new Map<String,Object>();
        List<HH_Application__c> apps = [SELECT Id,County__c,Application_Lead__c,Stage__c,Status__c FROM HH_Application__c WHERE Id=:applicationId];
        String countyQueueAPIName = getCountyQueueAPIName();
        if(countyQueueAPIName == null && apps.get(0).County__c != null) {
            List<County_Config__mdt> countyconfigs = [SELECT Id,Queue_API_Name__c FROM County_Config__mdt WHERE Label =: apps.get(0).County__c];
            if(countyconfigs.size() > 0 ) {
                returnMap.put('queueName', countyconfigs.get(0).Queue_API_Name__c);
            }
        } else {
            returnMap.put('queueName', countyQueueAPIName);
        }
       
        returnMap.put('applicationLeadId', apps.get(0).Application_Lead__c);
        returnMap.put('showComponent', true);
        return returnMap;
    }

    private static String getCountyQueueAPIName() {
        List<GroupMember> members = [SELECT Id,GroupId,Group.DeveloperName FROM GroupMember WHERE UserOrGroupId =:UserInfo.getUserId() AND Group.Type = 'Queue'];
        if(members.size() > 0 ) {
            System.debug('members: '+members.get(0).Group.DeveloperName);
            List<County_Config__mdt> countyconfigs = [SELECT Id,Queue_API_Name__c FROM County_Config__mdt WHERE Queue_API_Name__c =: members.get(0).Group.DeveloperName];
            System.debug('countyconfigs: '+countyconfigs);
            if(countyconfigs.size() > 0 && countyconfigs.get(0).Queue_API_Name__c != null) {
                return countyconfigs.get(0).Queue_API_Name__c;
            }
        }
        return null;
    }


   public static List<LookupSearchResult> getSearchResults(String searchTerm, String queueName) {
        return null;
   }

   @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFacility(String searchTerm,String queueName) {
        
        searchTerm = searchTerm.replace(' ','%');
        String query = 'select id,name from user where id in (select userorgroupid from groupmember where group.DeveloperName = \''+queueName+'\')';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND (Name like\'%' + searchTerm + '%\'' ;
        }
        system.debug('query===='+query);
        List<User> users = Database.query(query);
        List<LookupSearchResult> results = searchUsers(users, true);
        System.debug('results---' + results);
        return results;
    }
    
    /***********************************************
    * Method Name : searchAccount
    * Author : Shantanu
    * Inputs : List<User> users, Boolean showSubtitle
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Health Care Facility
    *********************************************/
    private static List<LookupSearchResult> searchUsers( List<User> users, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        for (User user : users) {
            results.add(
                    new LookupSearchResult(
                            user.Id,
                            'User',
                            userIcon,
                            user.Name,
                            null,
                            user
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    
    @AuraEnabled
    public static void  saveApplicationLead(String userId, String applicationId) {
        HH_Application__c application = new HH_Application__c(Id=applicationId, Application_Lead__c=userId);
        update application;
    }
}