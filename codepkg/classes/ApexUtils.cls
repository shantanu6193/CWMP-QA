/***********************************************************************************************************************************
* Class Name   : ApexUtils
* Description  : ApexUtils Class contains method related to common functionality 
* Author       : Pankaj
* Created On   : 05/11/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            05/11/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class ApexUtils {

     /***********************************************
    * Method Name : checkIfCurrentUserHasEditAccess
    * Author : Pankaj
    * Inputs : String recordId
    * Description: This method return true if user has Edit Access, return false if user has not Edit access
    *********************************************/ 
    public static Boolean checkIfCurrentUserHasEditAccess(String recordId) {
        List<UserRecordAccess> userRecordAccesses = [SELECT RecordId, HasEditAccess
        FROM UserRecordAccess
        WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        if(userRecordAccesses.size() > 0) {
            return userRecordAccesses.get(0).HasEditAccess;
        }
        return false;
    }

    /***********************************************
    * Method Name : showErrorWhenRecordLocked
    * Author : Pankaj
    * Inputs : String orderId
    * Description: return true if record is locked and user don't have access to edit it, return false if either record is locked and user don't have access to edit it
    *********************************************/ 
    public static Boolean showErrorWhenRecordLocked(String recordId) {
        Boolean showRecordLockedError = true;
        List<ProcessInstanceWorkitem> workItem = [Select id,ActorId, Actor.Name,OriginalActorId, ProcessInstanceId,ProcessInstance.Status,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId];
        if(!workItem.isEmpty()) {
            List<GroupMember> queueMembers = [Select id,UserOrGroupId  from GroupMember where GroupId =: workItem[0].ActorId];
            for(GroupMember member : queueMembers) {
                if(member.UserOrGroupId == UserInfo.getUserId()) {
                    showRecordLockedError = false;
                }
            }
        }
        return showRecordLockedError;
    }

    private static User currentUserRecord;
 
    /***********************************************
    * Method Name : getCurrentUserDetails
    * Author : Pankaj
    * Inputs : -
    * Description: This method return current user details including account
    *********************************************/ 
    public static User getCurrentUserDetails() {
        if(currentUserRecord == null) {
            currentUserRecord = [SELECT Id,AccountId,ContactId,
                    Account.ParentId,
                    Contact.Account.Entity_Type__c,
                    Contact.Account.Parent.Entity_Type__c,
                    Contact.Account.Parent.Queue_Name__c,
                    Contact.Account.Queue_Name__c,
                    Account.Parent.Product_Filter_Clause__c,
                    Account.Product_Filter_Clause__c,
                    FirstName,
                    LastName,
                    Email
            FROM User WHERE Id=:UserInfo.getUserId()];
        }
        return currentUserRecord;
    }

    /***********************************************
    * Method Name : checkCommunityUser
    * Author : Pankaj
    * Inputs : -
    * Description: This method return true if logged in user is community User
    *********************************************/
    @AuraEnabled
    public static Boolean checkCommunityUser() {
        User userRec = [Select Name,AccountId,UserName,Id from User where Id =: UserInfo.getUserId()];
        if(userRec.AccountId != null){
            return true;
        }
        return false;
    }

    /***********************************************
    * Method Name : Lock Records
    * Author : Neha
    * Inputs : Record Id
    * Description: For record Lock process
    *********************************************/
    @InvocableMethod
    public static void lockRecord(List<String> recordIds){
        Approval.lock(recordIds);
    }


    public static Id getRecordTypeIdbyName(String objectName, String recordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    public static String getRecordTypeNameById(String objectName, Id recordTypeId){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }  
}