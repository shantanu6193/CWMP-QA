/***********************************************************************************************************************************
* Class Name   : HH_RFITriggerHandler
* Description  : Handle RFI object trigger operations
* Author       : Ricky
* Created On   : 18/11/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              18/11/2021       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HH_RFITriggerHandler  extends TriggerHandler implements TriggerInterface {
    public override void beforeInsert() {
        /** This method is used to prevent RFI creation when the CWMP Application is other than Open RFI Status and Record Type is CWMP.  */
        preventRfiCreationOnApplicationStatusOtherThanOpenRfi();

        //updateDefaultStatus();
    }

    public override void beforeUpdate() {
        /** This method is used to prevent RFI creation when the CWMP Application is other than Open RFI Status and Record Type is CWMP.  */
        preventRfiCreationOnApplicationStatusOtherThanOpenRfi();

        /** This method is used to prevent updating RFI when it is in Closed Status. */
        //preventRFIUpdateAfterClosed();

        /** This method is used to update RFI status to RFI Received when the Homeowner updates the Comment(Responds to RFI). */
        updateRFIStatusUponHomeownerResponse();
    }

    public override void afterInsert() {
        shareRFIWithHomeownerCommunityAndCalOesUserUser();
        checkOpenRFI();
    }
    public override void afterUpdate() {
        checkOpenRFI();
    }

    /***********************************************
    * Method Name : preventRfiCreationOnApplicationStatusOtherThanOpenRfi
    * Author : Ricky
    * Description: This method is used to prevent RFI creation when the CWMP Application is other than Open RFI Status and Record Type is CWMP.
    *********************************************/
    private void preventRfiCreationOnApplicationStatusOtherThanOpenRfi() {
        /** Fetching CWMP Record Type Id by Developer Name. */
        Id cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName).getRecordTypeId();
        /** Collection to store the CWMP RFI records which needs to be processed. */
        List<Request_For_Information__c> cwmpRfiToProcessList = new List<Request_For_Information__c>();
        /** Set collection to store the CWMP Application Ids in order to check for the Stage and Status. */
        Set<Id> cwmpApplicationIdSet = new Set<Id>();

        Set<Id> userIds = new Set<Id>();
        /** Iterating Trigger.new collection in order to collect the CWMP RFI and and their related CWMP Application Id. */
        for (Request_For_Information__c rfiToProcess : (List<Request_For_Information__c>) Trigger.new) {
            Request_For_Information__c oldRecord = new Request_For_Information__c();
            if (Trigger.isUpdate) {
                oldRecord = (Request_For_Information__c) Trigger.oldMap.get(rfiToProcess.Id);
            }
            /** Condition to check if the RFI record Type is CWMP and CWMP Application record is associated with the RFI. */
            if (rfiToProcess.RecordTypeId == cwmpRecordTypeId
                    && rfiToProcess.CWMP_Application__c != null
                    && (Trigger.isInsert
                        || (Trigger.isUpdate
                            && oldRecord != rfiToProcess))) {
                cwmpRfiToProcessList.add(rfiToProcess);
                cwmpApplicationIdSet.add(rfiToProcess.CWMP_Application__c);
                userIds.add(UserInfo.getUserId());
            }
        }

        /** Checking for null pointer exception for cwmpRfiToProcessList collection. */
        if (cwmpRfiToProcessList?.size() > 0) {
            /** Fetching CWMP Application records in order to check for the Stage and Status of teh record before creating the RFI record. */
            Map<Id, HH_Application__c> appIdToApplicationRecordMap = new Map<Id, HH_Application__c>(
                                                            [SELECT Id, Name, Stage__c, Status__c, Applicant__r.Email FROM HH_Application__c WHERE Id IN : cwmpApplicationIdSet]);

            Map<Id, Set<String>> userIdToSetOfPermissionSetApiNameMap = getCurrentUserPermissionSet(userIds);

            /** Iterating cwmpRfiToProcessList collection in order to check for the related CWMP Application Stage and Status. */
            for (Request_For_Information__c rfiToProcess : cwmpRfiToProcessList) {
                /** Fetching the related CWMP Application record from appIdToApplicationRecordMap Map colelction. */
                HH_Application__c cwmpAppRecord = appIdToApplicationRecordMap.get(rfiToProcess.CWMP_Application__c);
                /** Updating CWMP Applicant EMail and default Status field. */
                if (Trigger.isInsert) {
                    updateAdditionalFields(rfiToProcess, cwmpAppRecord);
                    if (userIdToSetOfPermissionSetApiNameMap?.get(UserInfo.getUserId())?.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                            && !((cwmpAppRecord?.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                    && cwmpAppRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (cwmpAppRecord?.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    && cwmpAppRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))) {
                        rfiToProcess.addError(System.Label.HH_RFICreationPreventionError);
                    }
                    else if (userIdToSetOfPermissionSetApiNameMap?.get(UserInfo.getUserId())?.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)
                            && !((cwmpAppRecord?.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && cwmpAppRecord?.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))) {
                        rfiToProcess.addError(System.Label.HH_RFICreationPreventionError);
                    }
                }
                /** This condition is added to check for the particular Stage and Status.
                 * If the gets Condition satisfies then throw error.
                 * Condition criteria -  !(1 OR 2 OR 3 OR 4)
                 * 1. Stage - Community Review
                 *      Status - Open RFI - Need More Information
                 * 2. Stage - Assessment
                 *      Status - Open RFI - Need More Information
                 * 3. Stage - Cal OES Review
                 *      Status - Open RFI - Need More Information
                 * 4. Stage - FEMA Review
                 *      Status - Open RFI - Need More Information */
                if (Trigger.isUpdate) {
                    Request_For_Information__c oldRecord = (Request_For_Information__c) Trigger.oldMap.get(rfiToProcess.Id);
                    updateAdditionalFields(rfiToProcess, cwmpAppRecord);
	                if (!((cwmpAppRecord?.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
	                            && cwmpAppRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
	                        || (cwmpAppRecord?.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
	                            && cwmpAppRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
	                        || (cwmpAppRecord?.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                            && cwmpAppRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))) {
	                    rfiToProcess.addError(System.Label.HH_RFIUpdationPreventionError);
					}

                    /*if (!userIdToSetOfPermissionSetApiNameMap?.get(UserInfo.getUserId())?.contains(HH_CONSTANTS.HH_Profile_SystemAdmin)
                            && rfiToProcess.Status__c != HH_CONSTANTS.RFI_RFIStatus_Requested
                            && rfiToProcess.Status__c != HH_CONSTANTS.RFI_RFIStatus_Received) {
                        rfiToProcess.addError(System.Label.HH_RFIUneditableErrorMessage);
                    }*/

                    if (!userIdToSetOfPermissionSetApiNameMap?.get(UserInfo.getUserId())?.contains(HH_CONSTANTS.HH_Profile_SystemAdmin)
                            && ((oldRecord.Status__c == rfiToProcess.Status__c
                            && rfiToProcess.Status__c != HH_CONSTANTS.RFI_RFIStatus_Requested
                                    && rfiToProcess.Status__c != HH_CONSTANTS.RFI_RFIStatus_Received)
                                || (oldRecord.Status__c != rfiToProcess.Status__c
                                    && (oldRecord.Status__c == HH_CONSTANTS.RFI_RFIStatus_Closed
                                        || oldRecord.Status__c == HH_CONSTANTS.RFI_RFIStatus_Withdrawn)))) {
                        rfiToProcess.addError(System.Label.HH_RFIUneditableErrorMessage);
                    }
                }	
            }
        }
    }

    /***********************************************
    * Method Name : updateRFIStatusUponHomeownerResponse
    * Author : Ricky
    * Description: This method is used to update RFI status to RFI Received when the Homeowner updates the Comment(Responds to RFI).
    *********************************************/
    private void updateRFIStatusUponHomeownerResponse() {
        /** Fetching CWMP Record Type Id by Developer Name. */
        Id cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName).getRecordTypeId();
        /** Iterating Trigger.new collection in order to collect the CWMP RFI and and their related CWMP Application Id. */
        for (Request_For_Information__c rfiToProcess : (List<Request_For_Information__c>) Trigger.new) {
            /** Fetching the old record from Trigger.oldMap collection. */
            Request_For_Information__c oldRecord = (Request_For_Information__c) Trigger.oldMap.get(rfiToProcess.Id);
            /** This condition is added to check if the Homeowner has provided the comments(Responded to the RFI) then update the RFI status to RFI Received.
             * If teh Condition satisfies then updating RFI Status to RFI Received.
             * Condition Criteria - 1 AND 2 AND 3 AND 4
             * 1. Record Type - CWMP
             * 2. Homeowner Comments field is changed
             * 3. Homeowner comments field is not null.
             * 4. RF status != RFI Received/Closed */
            if (rfiToProcess.RecordTypeId == cwmpRecordTypeId
                    && rfiToProcess.CWMP_Application__c != null
                    && oldRecord.Homeowner_Comment__c != rfiToProcess.Homeowner_Comment__c
                    && rfiToProcess.Homeowner_Comment__c?.trim()?.length() > 0
                    && rfiToProcess.Status__c == HH_CONSTANTS.RFI_RFIStatus_Requested) {
                rfiToProcess.Status__c = HH_CONSTANTS.RFI_RFIStatus_Received;
            }
        }
    }

    /***********************************************
    * Method Name : shareRFIWithHomeownerCommunityAndCalOesUserUser
    * Author : Ricky
    * Description: This method is used to Share the RFI records with Homeowner User, Community and Cal OES user groups after creation.
    *********************************************/
    private void shareRFIWithHomeownerCommunityAndCalOesUserUser() {
        /** Fetching CWMP Record Type Id by Developer Name. */
        Id cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName).getRecordTypeId();
        /** List collection to store the RFI records to be processed. */
        List<Request_For_Information__c> rfiToProcessList = new List<Request_For_Information__c>();
        /** Set collection to store the CWMP Application ID related to RFI. */
        Set<Id> applicationIdSet = new Set<Id>();
        /** Iterating Trigger.new collection to collect the only CWMP Application RFI records. */
        for (Request_For_Information__c rfiToProcess : (List<Request_For_Information__c>) Trigger.new) {
            /** Condition to check if the RFI record Type is CWMP and CWMP Application record is associated with the RFI. */
            if (rfiToProcess.RecordTypeId == cwmpRecordTypeId
                    && rfiToProcess.CWMP_Application__c != null) {
                rfiToProcessList.add(rfiToProcess);
                applicationIdSet.add(rfiToProcess.CWMP_Application__c);
            }
        }
        /** Condition to check for null pointer exception for the rfiToProcessList collection. */
        if (rfiToProcessList?.size() > 0) {
            /** Fetching CWMP Application records which are related to RFI which needs to be processed. */
            Map<Id, HH_Application__c> appIdToApplicationRecordMap = new Map<Id, HH_Application__c>(
                    [SELECT Id, Name, County__c, Applicant__r.Name FROM HH_Application__c WHERE Id IN : applicationIdSet]);
            /** Set collection to store the name of the Counties of the related CWMP Application records. */
            Set<String> countySet = new Set<String>();
            /** Set collection to store the Applicant(Related Contact) Ids. */
            Set<Id> applicantIds = new Set<Id>();
            /** Iterating Application records to collect the counties of the Application. */
            for (HH_Application__c hhApplicationToProcess : appIdToApplicationRecordMap?.values()) {
                applicantIds.add(hhApplicationToProcess.Applicant__c);
                if (hhApplicationToProcess.County__c != null) {
                    countySet.add(hhApplicationToProcess.County__c);
                }
            }
            /** Fetching Homeowner user records in order to share the RFI with Homeowner User. */
            List<User> homeownerUserList = [SELECT Id, Name, ContactId FROM User WHERE ContactId IN : applicantIds
                                                AND IsActive = TRUE AND Contact.Contact_Type__c =: HH_CONSTANTS.HH_Contact_Type_Homeowner];
            /** Map collection to store the User Record with Contact ID as Key. */
            Map<Id, User> contactIdToHomeownerUserRecordMap = new Map<Id, User>();
            if (homeownerUserList?.size() > 0) {
                for (User user : homeownerUserList) {
                    contactIdToHomeownerUserRecordMap.put(user.ContactId, user);
                }
            }

            /** Querying the County Config Metadata to fetch the related Public group API name of County. */
            List<County_Config__mdt> countyConfigMetaRecordList = new List<County_Config__mdt>();
            /** Mp collection to store the Public group API name with key as County name. */
            Map<String, String> countyNameToPublicGroupApiNameMap = new Map<String, String>();
            /** Mp collection to store the Public group record with key as Group API name. */
            Map<String, Group> groupDeveloperNameToGroupRecordMap = new Map<String, Group>();
            /** Set collection to store group API names in order to fetch Public group records. */
            Set<String> publicGroupApiNames = new Set<String>();
            /** Adding Internal user group API name to the Set collection. */
            publicGroupApiNames.add(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName);
            /** List collection to store the fetched Public group records data. */
            List<Group> publicGroupInfoList = new List<Group>();
            if (countySet?.size() > 0) {
                countyConfigMetaRecordList = [SELECT Id, Label, Application_Type__c, Public_Group_API_Name__c, Queue_API_Name__c FROM County_Config__mdt
                        WHERE Label IN : countySet AND Application_Type__c = :HH_CONSTANTS.HH_Application_APIName_CountyConfig];
            }
            /** Arranging the County Config Metadata Record in order as County name as Key and Group API name as value. */
            if (countyConfigMetaRecordList?.size() > 0) {
                for (County_Config__mdt countyConfig : countyConfigMetaRecordList) {
                    if (countyConfig.Public_Group_API_Name__c != null) {
                        publicGroupApiNames.add(countyConfig.Public_Group_API_Name__c);
                        countyNameToPublicGroupApiNameMap.put(countyConfig.Label, countyConfig.Public_Group_API_Name__c);
                    }
                }
            }

            if (publicGroupApiNames?.size() > 0) {
                /** Fetching the Public Group Info in order to share the record. */
                publicGroupInfoList = [SELECT Id, Name, DeveloperName, Type FROM Group
                                        WHERE DeveloperName IN :publicGroupApiNames AND Type = 'Regular'];

                /** Arranging the Group record in order as Group API name as Key and Group record as value,
                 * In order to fetch the record while processing the Applications. */
                if (publicGroupInfoList?.size() > 0) {
                    for (Group groupRecord : publicGroupInfoList) {
                        groupDeveloperNameToGroupRecordMap.put(groupRecord.DeveloperName, groupRecord);
                    }
                }
            }

            List<Request_For_Information__Share> refShareToInsertList = new List<Request_For_Information__Share>();
            for (Request_For_Information__c rfiToShare : rfiToProcessList) {
                /** Sharing record to Homeowner User. */
                if (contactIdToHomeownerUserRecordMap?.get(appIdToApplicationRecordMap?.get(rfiToShare.CWMP_Application__c)?.Applicant__c)?.Id != null) {
                    Request_For_Information__Share rfiShareToInsert1 = new Request_For_Information__Share();
                    rfiShareToInsert1.ParentId = rfiToShare.Id;
                    rfiShareToInsert1.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;
                    rfiShareToInsert1.UserOrGroupId = contactIdToHomeownerUserRecordMap?.get(appIdToApplicationRecordMap?.get(rfiToShare.CWMP_Application__c)?.Applicant__c).Id;
                    rfiShareToInsert1.RowCause = Request_For_Information__Share.RowCause.CWMP_Sharing__c;
                    refShareToInsertList.add(rfiShareToInsert1);
                }

                /** Sharing RFI record with Community user Group. */
                if (groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(appIdToApplicationRecordMap?.get(rfiToShare.CWMP_Application__c)?.County__c))?.Id != null) {
                    Request_For_Information__Share rfiShareToInsert2 = new Request_For_Information__Share();
                    rfiShareToInsert2.ParentId = rfiToShare.Id;
                    rfiShareToInsert2.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;
                    rfiShareToInsert2.UserOrGroupId = groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(appIdToApplicationRecordMap?.get(rfiToShare.CWMP_Application__c)?.County__c))?.Id;
                    rfiShareToInsert2.RowCause = Request_For_Information__Share.RowCause.CWMP_Sharing__c;
                    refShareToInsertList.add(rfiShareToInsert2);
                }

                /** Sharing the RFI record with Cal OES User group. */
                if (groupDeveloperNameToGroupRecordMap.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName).Id != null) {
                    Request_For_Information__Share rfiShareToInsert3 = new Request_For_Information__Share();
                    rfiShareToInsert3.ParentId = rfiToShare.Id;
                    rfiShareToInsert3.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;
                    rfiShareToInsert3.UserOrGroupId = groupDeveloperNameToGroupRecordMap.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName).Id;
                    rfiShareToInsert3.RowCause = Request_For_Information__Share.RowCause.CWMP_Sharing__c;
                    refShareToInsertList.add(rfiShareToInsert3);
                }
            }
            /** Checking for null pointer exception for the refShareToInsertList collection before inserting. */
            if (refShareToInsertList?.size() > 0) {
                insert refShareToInsertList;
            }
        }
    }

    /***********************************************
    * Method Name : updateAdditionalFields
    * Author : Ricky
    * Description: This method is used to update the additional fields of the CWMP RFI while Insertion.
    *********************************************/
    private void updateAdditionalFields(Request_For_Information__c rfiToProcess, HH_Application__c hhApplicationToProcess) {
        if(Trigger.isInsert) {
        if (hhApplicationToProcess?.Applicant__r?.Email != null) {
            rfiToProcess.CWMP_Applicant_Email__c = hhApplicationToProcess?.Applicant__r?.Email;
        }
        if (rfiToProcess.RFI_Type__c == HH_CONSTANTS.Rfi_RFIType_CWMP) {
            rfiToProcess.Status__c = HH_CONSTANTS.RFI_RFIStatus_Requested;
        }
    }

        if (Trigger.isUpdate) {
            if (rfiToProcess.Status__c == null || rfiToProcess.Status__c == '') {
                rfiToProcess.Status__c = HH_CONSTANTS.RFI_RFIStatus_Requested;
            }
        }
    }

    /***********************************************
    * Method Name : checkOpenRFI
    * Author : Sushant.
    * Description: This method is used to update checkbox on CWMP application when any related RFI is open.
    *********************************************/
    Private void checkOpenRFI(){
        /** To Store record Ids of CWMP Application **/
        Set<Id> cwmpApplicationIds = new Set<Id>();
        /** To Store records of CWMP Application **/
        List<HH_Application__c> app = new List<HH_Application__c>();
        /** To get record Type Id of CWMP Record Type **/
        Id cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName).getRecordTypeId();
        for (Request_For_Information__c rfiToProcess : (List<Request_For_Information__c>) Trigger.new) {
            /** If the status of RFI is changed then store the cwmp Application Id into cwmpApplicationIds **/
            if(Trigger.isUpdate){
                Request_For_Information__c oldRecord = (Request_For_Information__c) Trigger.oldMap.get(rfiToProcess.Id);
                if(rfiToProcess?.RecordTypeId == cwmpRecordTypeId
                        && rfiToProcess?.Status__c != oldRecord?.Status__c
                        && rfiToProcess.Status__c == HH_CONSTANTS.RFI_RFIStatus_Closed
                        || rfiToProcess.Status__c == HH_CONSTANTS.RFI_RFIStatus_Withdrawn
                        || oldRecord.Status__c == HH_CONSTANTS.RFI_RFIStatus_Closed
                        || oldRecord.Status__c == HH_CONSTANTS.RFI_RFIStatus_Withdrawn){
                    cwmpApplicationIds.add(rfiToProcess?.CWMP_Application__c);
                }
            }
            /** If the record is newly inserted then store the cwmp Application Id into cwmpApplicationIds **/
            if(Trigger.isInsert){
                if(rfiToProcess?.RecordTypeId == cwmpRecordTypeId) {
                    cwmpApplicationIds.add(rfiToProcess?.CWMP_Application__c);
                }
            }
        }
        if(cwmpApplicationIds?.size() > 0){
            /** Fetching all Open RFI's Related to CWMP Application **/
            app = [Select Id,Is_Any_Open_RFI__c,(Select Id from Request_For_Information__r where Status__c != :HH_CONSTANTS.RFI_RFIStatus_Closed AND Status__c != :HH_CONSTANTS.RFI_RFIStatus_Withdrawn) from HH_Application__c WHERE Id IN :cwmpApplicationIds];
            List<HH_Application__c> appListToUpdate = new List<HH_Application__c>();
            if(app?.size() >0){
                for (HH_Application__c application : app) {
                    HH_Application__c appToUpdate = new HH_Application__c();
                    appToUpdate.Id = application.Id;
                    /** If any RFI is open related to CWMP Application then Check the "is any open RFI" checkbox **/
                    if(application?.Request_For_Information__r?.size() > 0){
                        appToUpdate.is_Any_Open_RFI__c = true;
                        appListToUpdate.add(appToUpdate);
                    /** If no any RFI is open related to CWMP Application then unCheck the "is any open RFI" checkbox **/
                    }else{
                        appToUpdate.is_Any_Open_RFI__c = false;
                        appListToUpdate.add(appToUpdate);
                    }
                }
                /** update the existing list **/
                if(appListToUpdate.size() >0){
                    update appListToUpdate;
                }
            }
        }
    }

    /***********************************************
    * Method Name : preventRFIUpdateAfterClosed
    * Author : Ricky
    * Description: This method is used to prevent updating RFI when it is in Closed Status.
    *********************************************/
    private void preventRFIUpdateAfterClosed() {
        /** To get record Type Id of CWMP Record Type **/
        Id cwmpRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName).getRecordTypeId();
        /** Iterating Trigger.new collection to collect the only CWMP Application RFI records. */
        for (Request_For_Information__c rfiToProcess : (List<Request_For_Information__c>) Trigger.new) {
            Request_For_Information__c oldRecord = (Request_For_Information__c) Trigger.oldMap.get(rfiToProcess.Id);
            /** Condition to check if the RFI record Type is CWMP and CWMP Application record is associated with the RFI. */
            if (rfiToProcess.RecordTypeId == cwmpRecordTypeId
                    && rfiToProcess.CWMP_Application__c != null
                    && oldRecord != rfiToProcess
                    && (oldRecord.Status__c == HH_CONSTANTS.RFI_RFIStatus_Closed
                        || oldRecord.Status__c == HH_CONSTANTS.RFI_RFIStatus_Withdrawn)) {
                rfiToProcess.addError(System.Label.HH_RFIUneditableErrorMessage);
            }
        }
    }

    /***********************************************
    * Method Name : getCurrentUserPermissionSet
    * Author : Ricky
    * Input : Set<Id> userIds - Set collection of User Ids
    * Description: This method accepts Set collection of User Id and
    *              returns Map<Id, Set<String>> in Which User Id is Key and Set of assigned Permission is as value.
    *              If the User is System Admin, then Profile name is also returned in its assigned Permissions.
    *********************************************/
    private Map<Id, Set<String>> getCurrentUserPermissionSet(Set<Id> userIds) {
        Map<Id, Set<String>> userIdToPermissionSetApiNameMap = new Map<Id, Set<String>>();
        if (userIds?.size() > 0) {
            List<User> userList = [SELECT Id, Name, Profile.Name,
                                        (SELECT Id, PermissionSet.Id, PermissionSet.Name FROM PermissionSetAssignments)
                                    FROM User WHERE Id IN : userIds];
            for (User userRecord : userList) {
                if (userRecord?.PermissionSetAssignments?.size() > 0) {
                    Set<String> permissionSetApiNames = new Set<String>();
                    for (PermissionSetAssignment prSet : userRecord?.PermissionSetAssignments) {
                        permissionSetApiNames.add(prSet.PermissionSet.Name);
                    }
                    if (userRecord.Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin) {
                        permissionSetApiNames.add(userRecord.Profile.Name);
                    }
                    userIdToPermissionSetApiNameMap.put(userRecord.Id, permissionSetApiNames);
                }
                else if (userRecord.Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin) {
                    Set<String> permissionSetApiNames = new Set<String>();
                    permissionSetApiNames.add(userRecord.Profile.Name);
                    userIdToPermissionSetApiNameMap.put(userRecord.Id, permissionSetApiNames);
                }
            }
        }
        return userIdToPermissionSetApiNameMap;
    }
}