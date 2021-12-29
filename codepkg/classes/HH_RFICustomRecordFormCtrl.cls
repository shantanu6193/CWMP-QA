public with sharing class HH_RFICustomRecordFormCtrl {


     /***********************************************
   * Method Name : getInitDetails
   * Author : Shantanu
   * Inputs : String parentRecordId(CWMP Application),String recordId, String userId, String mode(View/Edit)
   * Description: This get Required Details to showcase RFI Record.
   *********************************************/
    @AuraEnabled 
    public static Map<String,Object> getInitDetails(String parentRecordId,String recordId, String userId, String mode) {
        Map<String,Object> result = new Map<String,Object>();
        System.debug('ParentRecordId: '+parentRecordId);
        System.debug('recordId: '+recordId);
        System.debug('UserId: '+userId);
        String cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c
                                .getRecordTypeInfosByName()
                                .get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName)
                                .getRecordTypeId();
        if(recordId != null) {
            Request_For_Information__c rfi = [SELECT Id, RecordType.Name, RecordTypeId, Name, RFI_Deadline__c,Status__c,RFI_Type__c,Description__c,
                                                Cal_OES_Comment__c,Community_Comment__c,FEMA_Comments__c,
                                                Homeowner_Comment__c, CWMP_Application__c,CWMP_Application__r.Name
                                                 FROM Request_For_Information__c WHERE Id =:recordId];
            
            result.put('rfi',rfi);
            result.put('applicationId',rfi.CWMP_Application__c);
            parentRecordId = rfi.CWMP_Application__c;
        } else {
            Request_For_Information__c rfi = new Request_For_Information__c();
            rfi.RecordTypeId = cwmpRecordTypeId;
            rfi.RFI_Type__c = HH_CONSTANTS.Rfi_RFIType_CWMP;
            rfi.CWMP_Application__c = parentRecordId;
            result.put('rfi',rfi);
        }
        List<HH_Application__c> apps = [SELECT Id,Name,Stage__c,Status__c FROM HH_Application__c WHERE Id =:parentRecordId];
        System.debug('apps: '+apps);
        if(apps.size() == 0) {
            throw new CustomException('No CWMP Application found with Id '+parentRecordId);
        }
        HH_Application__c app = apps.get(0);
        if (!isHomeowner() &&  mode != 'View' && !isRFIEditable(app)) {
            throw new CustomException(System.Label.HH_RFICreationPreventionError);
        }
        result.put('isHomeowner',isHomeowner());
        result.put('applicationName', apps.get(0).Name);
        return result;
    }


     /***********************************************
   * Method Name : upsertRFI
   * Author : Shantanu
   * Inputs : String rfiJSON, String parentRecordId(CWMP Application)
   * Description: This create/update RFI.
   *********************************************/
    @AuraEnabled 
    public static Map<String,Object>  upsertRFI(String rfiJSON, String parentRecordId) {
        Map<String,Object> result = new Map<String,Object>();
        Request_For_Information__c rfi = (Request_For_Information__c)JSON.deserialize(rfiJSON, Request_For_Information__c.class);
        String cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c
                                .getRecordTypeInfosByName()
                                .get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName)
                                .getRecordTypeId();
        rfi.CWMP_Application__c = parentRecordId;
        rfi.RFI_Type__c = HH_CONSTANTS.Rfi_RFIType_CWMP;
        upsert rfi;
        result.put('rfi', rfi);
        return result;
    }

    @AuraEnabled
    public static void isEditable(String applicationId) {
        HH_Application__c app = [SELECT Id,Status__c, Stage__c FROM HH_Application__c WHERE Id =:applicationId];
        if (!isRFIEditable(app)) {
            throw new CustomException(System.Label.HH_RFICreationPreventionError);
        }
    }

      /***********************************************
   * Method Name : isRFIEditable
   * Author : Shantanu
   * Inputs : HH_Application__c app
   * Description: Check if RFI is Editable for FEMA,Community and Caloes User
   *********************************************/
    private static Boolean isRFIEditable(HH_Application__c app) {
        List<User> userRecords = [SELECT Id, Name, Profile.Name, AccountId, ContactId,
            (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
            FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if(userRecords.size() > 0) {
            if(userRecords[0]?.profile.Name == HH_CONSTANTS.HH_System_Admin_Profile_Name) {
                return true;
            }
            for(PermissionSetAssignment currentUserPermission: userRecords[0].PermissionSetAssignments) {
                if(currentUserPermission.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName) {
                    if ((app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                    || (app?.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)) {
                        return true;
                    }
                } else if (currentUserPermission.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName) {
                    if(app?.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI) {
                        return true;
                    }
                } else if (currentUserPermission.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName) {
                    if(app?.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI) {
                        return true;
                    }
                }
            }
        }
        return false;
   }



   /***********************************************
   * Method Name : isHomeOwner
   * Author : Shantanu
   * Inputs : 
   * Description: This method check current user Permission is Homeowner or not.
   *********************************************/
   private static Boolean isHomeowner() {
    List<PermissionSetAssignment> currentUserPermissionList = [SELECT Id, PermissionSetId, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =:HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName];
    if(currentUserPermissionList.size() > 0) {
        for(PermissionSetAssignment currentUserPermission: currentUserPermissionList) {
            if(currentUserPermission.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName) {
                return true;
            }
        }
    }
    return false;
    }

    /***********************************************
   * Method Name : delete RFI
   * Author : Shantanu
   * Inputs : 
   * Description: This method delete RFI
   *********************************************/
    @AuraEnabled 
    public static void  deleteRFI(String recordId) {
        Request_For_Information__c rfi = new Request_For_Information__c();
        rfi.Id= recordId;
        delete rfi;
    }

    public class CustomException extends Exception{

    }

 }