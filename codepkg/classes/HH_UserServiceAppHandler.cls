/***********************************************************************************************************************************
* Class Name   :HH_UserServiceAppHandler
* Description  : This class for HH user serive app handler 
* Author       : Shantanu
* Created On   : 08/24/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu               08/24/2021     Initial Implementation
**************************************************************************************************************************************/


public without sharing class HH_UserServiceAppHandler implements UserServiceAppHandler{

    /***********************************************
    * Method Name : handleReject
    * Author : Shantanu
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method call sendRejectionEmail method
    *********************************************/
    public void handleReject(List<User_Registration__c> userRegistrations) {
    
    }

    /***********************************************
    * Method Name : handleApprove
    * Author : Shantanu
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method call handleApprove Logic
    *********************************************/
    public void handleApprove(List<User_Registration__c> userRegistrations) {
        List<String> userTypes = new List<String>();
        for(User_Registration__c ureg: userRegistrations) {
            userTypes.add(ureg.User_Type__c);
        }
        System.debug('userTypes: '+userTypes);
       
        list<Community_Application_to_User__c> addApptoUser = new list<Community_Application_to_User__c>();
        List<Community_Application__c> hhApps = [SELECT Id, User_Type__c,Parent__c 
                                                FROM Community_Application__c WHERE 
                                                Parent__r.Name=:HH_CONSTANTS.HH_Parent_Community_Application_Name AND 
                                                User_Type__c IN :userTypes];
        System.debug('hhApps: '+hhApps);
        Map<String,Community_Application__c> userTypeToAppMap = new Map<String,Community_Application__c>();
        for (Community_Application__c  hhApp : hhApps) {
            userTypeToAppMap.put(hhApp.User_Type__c,hhApp);
        }
        List<String> userIds = new List<String>();
        List<String> femaUserIds = new List<String>();
        Map<String,List<String>> countyToUsersMap = new Map<String,List<String>>();
        List<Contact> contactsToUpdate = new List<Contact>();

        for(User_Registration__c ureg: userRegistrations) {
            System.debug('uReg: '+ureg);
            Community_Application_to_User__c appToUser = new Community_Application_to_User__c();
            appToUser.Contact__c = ureg.Contact_Name__c;
            appToUser.User__c = ureg.User__c;
            appToUser.isActive__c = true;
            Community_Application__c  app =  userTypeToAppMap.get(ureg.User_Type__c);
            if(ureg.User_Type__c == HH_CONSTANTS.UserRegistration_UserType_Community) {
                Contact uc = new Contact(Id = ureg.Contact_Name__c, Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Community);
                contactsToUpdate.add(uc);
            } else if (ureg.User_Type__c == HH_CONSTANTS.UserRegistration_UserType_FEMA) {
                // Contact uc = new Contact(Id = ureg.Contact_Name__c, Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_FEMA);
                // contactsToUpdate.add(uc);
            }
            if(app.Parent__c != null) {
                Community_Application_to_User__c parentAppToUser = new Community_Application_to_User__c();
                parentAppToUser.Contact__c = ureg.Contact_Name__c;
                parentAppToUser.User__c = ureg.User__c;
                parentAppToUser.isActive__c = true;
                parentAppToUser.Community_Application__c = app.Parent__c;
                addApptoUser.add(parentAppToUser);
            }
            appToUser.Community_Application__c = app.Id;
            addApptoUser.add(appToUser);
            userIds.add(ureg.User__c);
            if(ureg.User_Type__c == HH_CONSTANTS.UserRegistration_UserType_Community) {
            String actualCountyName = ureg.County__c.subString(0,ureg.County__c.indexOf(',')).trim();
            if(!countyToUsersMap.containsKey(actualCountyName)) {
                countyToUsersMap.put(actualCountyName,new List<String>());
            }
            countyToUsersMap.get(actualCountyName).add(ureg.User__c);
            } else if (ureg.User_Type__c == HH_CONSTANTS.UserRegistration_UserType_FEMA) {
                femaUserIds.add(ureg.User__c);
            }
            
        }
        if(contactsToUpdate.size() > 0) {
            update contactsToUpdate;
        }
        insert addApptoUser;
        System.debug('countyToUsersMap :' + countyToUsersMap);
        if(countyToUsersMap.size() > 0 ) {
            addUserToQueues(countyToUsersMap);
            addUserToPublicGroups(countyToUsersMap);
        }
        if(femaUserIds.size() > 0 ) {
            addFEMAUserToGroup(femaUserIds);
        }
    }

     /***********************************************
    * Method Name : addFEMAUserToGroup
    * Author : Shantanu
    * Inputs : List<String> femaUserIds
    * Description: This method will add fema users to group and queue.
    *********************************************/
    public void addFEMAUserToGroup(List<String> femaUserIds) {
        // List<String> groupQueueNames = new List<String>();
        // groupQueueNames.add(HH_CONSTANTS.HH_FEMA_User_Group_APIName);
        // groupQueueNames.add(HH_CONSTANTS.HH_FEMA_User_Queue_APIName);
        // List<Group> groups = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN : groupQueueNames];  
        // List<GroupMember> membersToBeAdded = new List<GroupMember>();
        // for (Group g1 : groups) {
        //     addUsersToGroup(g1.Id, femaUserIds, membersToBeAdded);
        // }
        // if(membersToBeAdded.size() > 0){
        //     String memberToBeAddedJson = JSON.serialize(membersToBeAdded);
        //     insertMembers(memberToBeAddedJson);   
        // }
    }

     /***********************************************
    * Method Name : addUserToPublicGroups
    * Author : Shantanu
    * Inputs : Map<String,List<String>> countyToUsersMap
    * Description: This method will add users to group depending on its county.
    *********************************************/
    public void addUserToPublicGroups(Map<String,List<String>> countyToUsersMap) {
        List<County_Config__mdt> hhCountyConfigs = [SELECT Label, DeveloperName,
                                                     Application_Type__c, Public_Group_API_Name__c 
                                                     FROM County_Config__mdt 
                                                     WHERE Application_Type__c =:HH_CONSTANTS.HH_Application_APIName_CountyConfig 
                                                     AND Label IN:countyToUsersMap.keySet()];

        Map<String,String> countyToGroupMap = new Map<String,String>();
        for(County_Config__mdt cc : hhCountyConfigs) {
            countyToGroupMap.put(cc.Label,cc.Public_Group_API_Name__c);
        }
        List<Group> groups = [SELECT Id, Name, DeveloperName 
                                            FROM Group WHERE DeveloperName IN : countyToGroupMap.values()];

        Map<String,String> groupNameToIdMap = new Map<String,String>();
        for(Group countyGroup : groups) {
            groupNameToIdMap.put(countyGroup.DeveloperName,countyGroup.Id);
        }    
        List<GroupMember> membersToBeAdded = new List<GroupMember>();            
        for(String countyName : countyToUsersMap.keySet()) {
            List<String> countyUserIds = countyToUsersMap.get(countyName);
            String publicGroupName = countyToGroupMap.get(countyName);
            if(countyUserIds.size() > 0 && publicGroupName != null) {
                String publicGroupId = groupNameToIdMap.get(publicGroupName);
                addUsersToGroup(publicGroupId,countyUserIds,membersToBeAdded);
            }
        }
        
        if(membersToBeAdded.size() > 0) {
            String memberToBeAddedJson = JSON.serialize(membersToBeAdded);
            insertMembers(memberToBeAddedJson);
        }
    }


    /***********************************************
    * Method Name : addUserToQueues
    * Author : Shantanu
    * Inputs : Map<String,List<String>> countyToUsersMap
    * Description: This method will add users to Queue depending on its county.
    *********************************************/
    public void addUserToQueues(Map<String,List<String>> countyToUsersMap) {
        List<County_Config__mdt> hhCountyConfigs = [SELECT Label, DeveloperName,
                                                     Application_Type__c, Queue_API_Name__c 
                                                     FROM County_Config__mdt 
                                                     WHERE Application_Type__c =:HH_CONSTANTS.HH_Application_APIName_CountyConfig 
                                                     AND Label IN:countyToUsersMap.keySet()];

        Map<String,String> countyToQueueMap = new Map<String,String>();
        for(County_Config__mdt cc : hhCountyConfigs) {
            countyToQueueMap.put(cc.Label,cc.Queue_API_Name__c);
        }
        List<Group> groups = [SELECT Id, Name, DeveloperName 
                                            FROM Group WHERE DeveloperName IN : countyToQueueMap.values() AND Type = 'Queue'];

        Map<String,String> queueNameToIdMap = new Map<String,String>();
        for(Group countyGroup : groups) {
            queueNameToIdMap.put(countyGroup.DeveloperName,countyGroup.Id);
        }    
        List<GroupMember> membersToBeAdded = new List<GroupMember>();            
        for(String countyName : countyToUsersMap.keySet()) {
            List<String> countyUserIds = countyToUsersMap.get(countyName);
            String queueName = countyToQueueMap.get(countyName);
            if(countyUserIds.size() > 0 && queueName != null) {
                String queueId = queueNameToIdMap.get(queueName);
                addUsersToGroup(queueId,countyUserIds,membersToBeAdded);
            }
        }
        
        if(membersToBeAdded.size() > 0) {
            String memberToBeAddedJson = JSON.serialize(membersToBeAdded);
            insertMembers(memberToBeAddedJson);
        }
    }

    /***********************************************
    * Method Name : handleApprove
    * Author : Shantanu
    * Inputs : String groupId,List<String> userIds,List<GroupMember> membersToBeAdded
    * Description: This method will create GroupMember record and add it into list.
    *********************************************/
    public void addUsersToGroup(String groupId,List<String> userIds,List<GroupMember> membersToBeAdded) {
        for(String userId : userIds) {
            GroupMember gm = new GroupMember();
            gm.GroupId = groupId;
            gm.UserOrGroupId = userId;
            membersToBeAdded.add(gm);  
        }
    }


     /***********************************************
    * Method Name : handleApprove
    * Author : Shantanu
    * Inputs : String  memberToBeAddedJson  (List<GroupMember>)
    * Description: This method will insert member asynchronously. 
                    Why asynchronus? 
                    To avoid Mixed DML operation between GroupMember(Setup) and User_Registration__c(Non setup) object.
    *********************************************/
    @future
    public static void insertMembers(String memberToBeAddedJson) {
        List<GroupMember> membersToBeAdded =  new List<GroupMember>();
        membersToBeAdded = (List<GroupMember>)JSON.deserializeStrict(memberToBeAddedJson, List<GroupMember>.class);
        insert membersToBeAdded;
    }
}