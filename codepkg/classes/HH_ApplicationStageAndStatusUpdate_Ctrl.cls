/***********************************************************************************************************************************
* Class Name   : HH_ApplicationStageAndStatusUpdate_Ctrl
* Description  : This Controller class is used in HhApplicationStageAndStatusUpdate LWC component.
* Author       : Ricky
* Created On   : 10/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              23/08/2021       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HH_ApplicationStageAndStatusUpdate_Ctrl {

    /***********************************************
    * Method Name : getRecordDetails
    * Author : Ricky
    * Input Parameters - 1. masterRecordId - Home Hardening Application Record Id, whose data needs to be fetched.
    *                    2. userId - current logged In user Id, In order to check where the component needs to be visible to user or not?
    * Description: This method is used to fetch the record detail by passing record Id and user ID and returns the data to LWC page.
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getRecordDetails(String masterRecordId, String userId) {
        /** Variable to store the return Type for this method. */
        Map<String, Object> resultMap = new Map<String, Object>();

        /** Fetching Application record whose Id has been passes to the method. */
        List<HH_Application__c> applicationRecord = [SELECT Id, Name, Stage__c, Status__c, Rejection_Reason__c, Community_Rejection_Reason__c,
                                                            Cal_OES_Rejection_Reason__c, FEMA_Rejection_Reason__c, Assessment_Rejection_Reason__c,
                                                            Reasons_for_Rejected_Closed__c, Reason_To_Withdraw__c
                                                        FROM HH_Application__c WHERE Id =: masterRecordId LIMIT 1];

        /** Checking if the Application record/Data is available. */
        if (applicationRecord?.size() == 1) {
            /** First element in the return Map is Home Hardening Application record. */
            resultMap.put('hhApplication', applicationRecord);
            /** Second element in the return map is allowed Stages. */
            resultMap.put('allowedStagesList', getAllowedStagesValues(applicationRecord[0].Stage__c, applicationRecord[0].Status__c));
            /** Second element in the return map is User Permission, That is If the Component needs to be displayed to user or not? */
            resultMap.put('isVisible', getUserPermissionForComponent(userId));
        }
        /** Returning the result map to LWC component. */
        return resultMap;
    }

    /***********************************************
    * Method Name : getAllowedStagesValues
    * Author : Ricky
    * Input Parameters - 1. stage - Current Stage of the Home Hardening Application record.
    * Description: This method is used to get the allowed Stages from Metadata based on Current Stage of the record.
    *********************************************/
    @AuraEnabled
    public static List<Map<String, String>> getAllowedStagesValues(String stage, String status) {
        /** Variable to store the HH Stage Config record after fetching it. */
        List<HH_Stage_Config__mdt> stageConfigList = new List<HH_Stage_Config__mdt>();
        /** Variable to prepare the Stage Values map after fetching the allowed Stages from HH Stage Config record. */
        List<Map<String, String>> stageValuesMap = new List<Map<String, String>>();

        /** Fetching Stage Picklist value from Schema method in order to get the translated label of Picklist values.
         * String the values in Map collection as API name as Key and Label as Value. */
        Map<String, String> picklistValueToPicklistLabelMap = new Map<String, String>();
        List<Schema.PicklistEntry> stagePicklistEntryList = HH_Application__c.Stage__c.getDescribe().getPicklistValues();
        if (stagePicklistEntryList?.size() > 0) {
            for (Schema.PicklistEntry picklistEntry : stagePicklistEntryList) {
                picklistValueToPicklistLabelMap.put(picklistEntry.getValue(), picklistEntry.getLabel());
            }
        }

        /** Condition to check if the Status field value of Application is not Rejected,
         * If condition is satisfied, then returning the Stage values from Metadata. */
        if (stage != null
                && status != HH_CONSTANTS.HHApplication_Status_RejectedNotEligible
                && status != HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria
                && status != HH_CONSTANTS.HHApplication_Status_OESDecisionRejected
                && status != HH_CONSTANTS.HHApplication_Status_FEMADecisionRejected
                && status != HH_CONSTANTS.HHApplication_Status_Withdrawn) {
            /** Preparing Query to fetch the records from metadata. */
            String query = 'SELECT Id, label, Current_Stage__c, Stage__c FROM HH_Stage_Config__mdt WHERE Current_Stage__c = \'' + stage + '\'';
            /** Fetching the metadata through Database.Query and string in stageConfigList variable. */
            stageConfigList = (List<HH_Stage_Config__mdt>) Database.query(query);

            /** Iterating the record and preparing the allowed stage as a List of Map collection. */
            for (HH_Stage_Config__mdt stageConfig : stageConfigList) {
                List<String> stageList = stageConfig.Stage__c.split(';');

                for(String stageValue : stageList) {
                    List<String> stageSet = stageValue.split(',');
                    Map<String, String> stageMap = new Map<String, String>();
                    stageMap.put('value', stageSet[1]);
                    if (picklistValueToPicklistLabelMap.get(stageSet[1]) != null) {
                        stageMap.put('label', picklistValueToPicklistLabelMap.get(stageSet[1]));
                    }
                    else {
                        stageMap.put('label', stageSet[0]);
                    }
                    stageValuesMap.add(stageMap);
                }
            }
        }
        /** Condition to check if the Status field value of Application is Rejected,
         * If condition is satisfied, then returning the specific Stage values manually. */
        else if (stage != null
                && (status == HH_CONSTANTS.HHApplication_Status_RejectedNotEligible
                    || status == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria
                    || status == HH_CONSTANTS.HHApplication_Status_OESDecisionRejected
                    || status == HH_CONSTANTS.HHApplication_Status_FEMADecisionRejected)) {
            /** Current Stage value. */
            Map<String, String> stageMap1 = new Map<String, String>();
            stageMap1.put('value', stage);
            stageMap1.put('label', picklistValueToPicklistLabelMap.get(stage));
            stageValuesMap.add(stageMap1);

            /** Rejected-Closed Stage In order to submit for Final rejection and Close the Application. */
                Map<String, String> stageMap2 = new Map<String, String>();
                stageMap2.put('value', HH_CONSTANTS.HHApplication_Stage_RejectedClosed);
                stageMap2.put('label', picklistValueToPicklistLabelMap.get(HH_CONSTANTS.HHApplication_Stage_RejectedClosed));
                stageValuesMap.add(stageMap2);

            /** Draft Stage In order to submit for Appeal. */
            Map<String, String> stageMap3 = new Map<String, String>();
            stageMap3.put('value', HH_CONSTANTS.HHApplication_Stage_Draft);
            stageMap3.put('label', picklistValueToPicklistLabelMap.get(HH_CONSTANTS.HHApplication_Stage_Draft));
            stageValuesMap.add(stageMap3);
        }

        else if (stage != null 
                && (status == HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
            /** Current Stage value. */
            Map<String, String> stageMap1 = new Map<String, String>();
            stageMap1.put('value', stage);
            stageMap1.put('label', picklistValueToPicklistLabelMap.get(stage));
            stageValuesMap.add(stageMap1);

            /** Rejected-Closed Stage In order to submit for Final rejection and Close the Application. */
            Map<String, String> stageMap2 = new Map<String, String>();
            stageMap2.put('value', HH_CONSTANTS.HHApplication_Stage_RejectedClosed);
            stageMap2.put('label', picklistValueToPicklistLabelMap.get(HH_CONSTANTS.HHApplication_Stage_RejectedClosed));
            stageValuesMap.add(stageMap2);
        }
        return stageValuesMap;
    }

    /***********************************************
    * Method Name : getUserPermissionForComponent
    * Author : Ricky
    * Input Parameters - 1. userId - Current logged In User Id.
    * Description: This method is used to decide whether component needs to be visible to the current logged In user or not based on assigned Permission.
    *********************************************/
    @AuraEnabled
    public static Boolean getUserPermissionForComponent(String userId) {
        /** Variable to store the boolean value for return Type. */
        Boolean returnType = false;
        /** Condition to check if the User Id is available in order to fetch the user record data. */
        if (userId != null && userId != '') {
            /** Set collection to store the current user available Permission Set Assignment API Name. */
            Set<String> currentUserPermissionSet = new Set<String>();
            /** Fetching the User record and its related Permission Set assignments. */
            List<User> userRecord = [SELECT Id, Name, Profile.Name,
                                            (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                                        FROM User WHERE Id =: userId LIMIT 1];
            /** Checking for null pointer exception for user record and then Iterating the Permission Set assignments,
             * in order to collect the API names of teh assigned Permission Sets. */
            if (userRecord?.size() == 1 && userRecord[0]?.PermissionSetAssignments?.size() > 0) {
                for (PermissionSetAssignment pAssignment : userRecord[0]?.PermissionSetAssignments) {
                    currentUserPermissionSet.add(pAssignment.PermissionSet.Name);
                }
            }
            /** Checking if the Current user is System Admin or user has Community User/FEMA User Permission Set,
             * then only setting the return type Value to true. */
            if (userRecord?.size() == 1
                    && (userRecord[0]?.Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin
                        || currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                        || currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)
                        || currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName))) { 
                returnType = true;
            }
        }
        return returnType;
    }

    /***********************************************
    * Method Name : updateStageAndStatus
    * Author : Ricky
    * Input Parameters - 1. record - Stringified Home Hardeningh Application Record
    *                    2. userId - Current Logged In User ID
    * Description: This method is used to update the Stage, Status and Rejection Reason of the record passed from LWC component.
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> updateStageAndStatus(String record, String userId) {
        /** Variable to store the HH Stage Config record after fetching it. */
        Map<String, Object> returnMap = new Map<String, Object>();
        /** Application variable to store the deserialized Application record passes from LWC component. */
        HH_Application__c applicationRecordDeserialized = (HH_Application__c) JSON.deserialize(record, HH_Application__c.class);

        /** Adding the values in Application record in order to update it. */
        HH_Application__c applicationRecord = new HH_Application__c();
        applicationRecord.Id = applicationRecordDeserialized.Id;
        applicationRecord.Stage__c = applicationRecordDeserialized.Stage__c;
        applicationRecord.Status__c = applicationRecordDeserialized.Status__c;
        System.debug('STAGE AND STATUS: '+ applicationRecord.Stage__c+': STATUS :  '+applicationRecord.Status__c);

        /** For Demo - Start */
        // else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
        //         && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForFEMAReview) {
        //     applicationRecord.Stage__c = HH_CONSTANTS.HHApplication_Stage_FEMAReview;
        //     applicationRecord.Status__c = HH_CONSTANTS.HHApplication_Status_FEMAReviewPending;
        // }
        // else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
        //         && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMADecisionApprovedForProjectConversion) {
        //         System.debug('FEMA: '+ applicationRecord.Stage__c+': STATUS :  '+applicationRecord.Status__c);
        //     applicationRecord.Stage__c = HH_CONSTANTS.HHApplication_Stage_ApprovedConverted;
        //     applicationRecord.Status__c = null;
        //     System.debug('APP CONVERISON: '+ applicationRecord.Stage__c);
        // }
        /** For Demo - End */
        if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria) {
        applicationRecord.Community_Rejection_Reason__c = applicationRecordDeserialized.Community_Rejection_Reason__c == null ? null : applicationRecordDeserialized.Community_Rejection_Reason__c;
        }
        else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedNotEligible) {
        applicationRecord.Assessment_Rejection_Reason__c = applicationRecordDeserialized.Assessment_Rejection_Reason__c == null ? null : applicationRecordDeserialized.Assessment_Rejection_Reason__c;
        }
        else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
                && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria) {
        applicationRecord.Cal_OES_Rejection_Reason__c = applicationRecordDeserialized.Cal_OES_Rejection_Reason__c == null ? null : applicationRecordDeserialized.Cal_OES_Rejection_Reason__c;
        }
        else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
                && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria) {
        applicationRecord.FEMA_Rejection_Reason__c = applicationRecordDeserialized.FEMA_Rejection_Reason__c == null ? null : applicationRecordDeserialized.FEMA_Rejection_Reason__c;
        }
        else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_RejectedClosed) {
        applicationRecord.Reasons_for_Rejected_Closed__c = applicationRecordDeserialized.Reasons_for_Rejected_Closed__c == null ? null : applicationRecordDeserialized.Reasons_for_Rejected_Closed__c;
        }
        else if (applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn) {
        applicationRecord.Reason_To_Withdraw__c = applicationRecordDeserialized.Reason_To_Withdraw__c == null ? null : applicationRecordDeserialized.Reason_To_Withdraw__c;
        } 

        /** Updating the Application record,
         * 1. If its success - Then returning the result map.
         * 2. If Error - then Passing the Error message to component. */
        try {
            update applicationRecord;

            /** Upon marking the decision as Ready for Cal OES Review,
            * changing the Stage - Cal OES Review and Stage-Reason - Cal OES Review Pending. */
            if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ReadyForCalOesReview) {
                applicationRecord.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESReview;
                applicationRecord.Status__c = HH_CONSTANTS.HHApplication_Status_OESReviewPending;

                TriggerHandler.skipFieldHistoryTrigger = false;
                update applicationRecord;
            }
            /** Upon marking the decision as Ready for FEMA Review,
            * changing the Stage - Cal OES Review and Stage-Reason - FEMA Review Pending. */
            else if (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForFEMAReview) {
                applicationRecord.Stage__c = HH_CONSTANTS.HHApplication_Stage_FEMAReview;
                applicationRecord.Status__c = HH_CONSTANTS.HHApplication_Status_FEMAReviewPending;

                TriggerHandler.skipFieldHistoryTrigger = false;
                update applicationRecord;
            }

            returnMap = getRecordDetails(applicationRecord.Id, userId);
            return returnMap;
        }
        catch (Exception e) {
            throw new AuraHandledException(CustomExceptionController.getSpecificErrorMessage(e.getMessage()));
        }
    }
}