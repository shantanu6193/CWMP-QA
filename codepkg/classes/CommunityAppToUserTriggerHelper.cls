/***********************************************************************************************************************************
* Class Name   : CommunityAppToUserTriggerHelper
* Description  : This is Helper class for CommunityAppToUser Trigger 
* Author       : Pankaj
* Created On   : 07/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            07/09/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class CommunityAppToUserTriggerHelper extends TriggerHelper {

    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are insertd and assign permission set to users.
    *********************************************/
    public override void processAfterInsert() {

        List<Community_Application_to_User__c> communityApplicationToUsers = new List<Community_Application_to_User__c>();
        for (Community_Application_to_User__c communityApplicationToUser : (List<Community_Application_to_User__c>)Trigger.new) {
            if(communityApplicationToUser.isActive__c == true) {
                communityApplicationToUsers.add(communityApplicationToUser);
            }
        }
        addUsersToPermissionSet(communityApplicationToUsers);
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated and assign permission set to users.
    *********************************************/
    public override void processAfterUpdate() {
        List<Community_Application_to_User__c> communityApplicationToUsers = new List<Community_Application_to_User__c>();
        for (Community_Application_to_User__c communityApplicationToUser : (List<Community_Application_to_User__c>)Trigger.new) {
            if(communityApplicationToUser.isActive__c == true) {
                communityApplicationToUsers.add(communityApplicationToUser);
            }
        }
        addUsersToPermissionSet(communityApplicationToUsers);
    }

    /***********************************************
    * Method Name : processBeforeDelete
    * Author : Pankaj
    * Inputs : -
    * Description: This method will remove permission set.
    *********************************************/
    public override void processBeforeDelete() {
        //todo - add logic to remove permission set

    }

    /***********************************************
    * Method Name : addUsersToPermissionSet
    * Author : Pankaj
    * Inputs : List<Community_Application_to_User__c> communityApplicationToUsers
    * Description: This method assign permission set to users.
    *********************************************/
    public static void addUsersToPermissionSet(List<Community_Application_to_User__c> communityApplicationToUsers) {
        if(communityApplicationToUsers.size() == 0) return;
        Map<Id, Set<Id>> userIdToAppId = new Map<Id, Set<Id>>();
        for (Community_Application_to_User__c communityApplicationToUser : communityApplicationToUsers) {
            if(communityApplicationToUser.User__c != null){
                if(userIdToAppId.get(communityApplicationToUser.Community_Application__c) == null) {
                    userIdToAppId.put(communityApplicationToUser.Community_Application__c, new Set<Id>());
                }
                userIdToAppId.get(communityApplicationToUser.Community_Application__c).add(communityApplicationToUser.User__c);
            }
        }
        if(userIdToAppId.size() > 0){
            System.enqueueJob(new AddPermissionObject(JSON.serialize(userIdToAppId)));
        }        
    }

    /***********************************************************************************************************************************
    * Class Name   : AddPermissionObject
    * Description  : Inner Queueable class for add permission set to users.
    * Author       : Pankaj
    * Created On   : 07/09/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj            07/09/2020       Initial Implementation
    **************************************************************************************************************************************/

    public class AddPermissionObject implements Queueable {
        String userIdToAppIdStr;
        AddPermissionObject(String userIdToAppIdStr) {
            this.userIdToAppIdStr = userIdToAppIdStr;
        }
        public void execute(QueueableContext context) {
            Map<Id, Set<Id>> userIdToAppId = (Map<Id, Set<Id>>)JSON.deserialize(userIdToAppIdStr, Map<Id, Set<Id>>.Class);
            UserService.addPermissionSetToUser(userIdToAppId);
        }
    }


}