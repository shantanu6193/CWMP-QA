/***********************************************************************************************************************************
* Class Name   : HH_ApplicationTriggerHandler
* Description  : Handle object trigger operations
* Author       : Shantanu
* Created On   : 10/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu              23/08/2021       Initial Implementation
**************************************************************************************************************************************/
public without sharing class HH_ApplicationTriggerHandler extends TriggerHandler implements TriggerInterface {
    public override void beforeInsert() {
        /** This method is used to update the Program field on HH Application upon insertion of the record. */
        updateProgramNameInHhApplicationRecord();

        /** This method is used to update the default Status upon Stage update on the Application record. */
        updateDefaultStatusUponStageChange();

        /** This method is used to update the Owner Name upon Insertion of the Application. */
        updateRecordOwnerFieldUponInsert();
    }

    public override void afterInsert() {
        /** This method is used to create the related Document upon Application creation. */
        createDocuments();
    }
    
    public override void beforeUpdate() {
        /** This method is used to auto update the Stage field to Cal OES Review, when the User update the Application from
         *  Assessment to Assessment Decision and Status to Ready for Cal OES Review. */
        //autoUpdateStageToOESReviewUponReadyForCalOESReviewStageReason();

        /** This method is used to prevent user from submitting application for next Stage for Review, if there is a pending RFI related to the Application. */
        checkRfiStatusBeforeSendingToNextStageForReview();

        /** This method is used to update the default Status upon Stage update on the Application record. */
        updateDefaultStatusUponStageChange();

        /** This method is used to prevent the user from changing the Stage in Reverse order except System Administrator. */
        preventReverseStageChange();

        updateApproverEmail();

        /** This method is used to prevent the user from submitting the Application to Cal OES Review, before uploading all the required Documents. */
        preventCalOesSubmissionWithoutDocumentUpload();

        /** This method is used to prevent the User from Updating the Application Status to "Tri Party Agreement Finalized",
        When the Selected Contractors is missing. */
        checkContractorsBeforeTriPartyAgreementFinalized();

        /** This method is used to prevent Homeowner/Community user from updating the Application based on Stage ans Status of the Application record. */
        StageBasedUpdateAccessToUser();

        /** This method is used to create the related Document upon Application creation. */
        updateRecordOwnerToHhCountyQueueBasedOnStage();

        //checkContractorsBeforeTriPartyAgreementFinalized();
    }

    public override void afterUpdate() {
        /** This method is used to create the related Document upon Application creation. */
        shareRecordWithUserBasedOnStage();
        convertCWMPApplicationToCWMPProject();
    }

    public override void beforeDelete() {
        /** This method is used to prevent the user from Deleting Application when its STage is not "Draft" and Stage-Reason is not "New",
         * Unless the User is System Admin. */
        preventDeletionExceptDraftNewStage();
    }

    /***********************************************
    * Method Name : updateDefaultStatusUponStageChange
    * Author : Ricky
    * Description: This method is used to update the default Status upon Stage update on the Application record.
    *********************************************/
    private void updateDefaultStatusUponStageChange() {
            for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>)Trigger.new) {
            HH_Application__c oldRecord = new HH_Application__c();
            if (Trigger.isUpdate) {
                /** Fetching Old record from Trigger.old in order to compare the field values. */
                oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
                }

            /** 1. While Insert - Updating all te Application Status if the Status is not one of the Dependent value of Stage.
             * 2. While Update - Updating only those Application Status whose Stage is changed and Status is not one of the Dependent value of Stage. */
            if (Trigger.isInsert || (Trigger.isUpdate && hhApplicationToProcess.Stage__c != oldRecord.Stage__c)) {
                if(hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                        && (hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_New
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_New;
                }
                /** This condition is to update the Status to Community Review Pending,
                * when the Stage moved to Community Review from Draft after application Submission. */
                else if ((Trigger.isInsert
                            || (Trigger.isUpdate
                                && (hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                                    || hhApplicationToProcess.Agreement_Disclosure__c != oldRecord.Agreement_Disclosure__c)))
                        && hhApplicationToProcess.Agreement_Disclosure__c == true
                        && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                        && (hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_CommunityReviewPending;
                }
                /** This condition is to update the Status to Community Decision Pending,
                * when the Stage moved to Community Decision from Community Review Stage and Status Community Review In Progress. */
                else if (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                        && (hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_CommunityDecisionPending
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    //hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_CommunityDecisionPending;
                }
                /** This condition is to update the Status to Assessment Pending,
                * when the Stage moved to Assessment after getting Approved from Community. */
                else if (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                            && (hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_AssessmentPending
                                        && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_AssessmentInProgress
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_AssessmentComplete
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentPending;
                }
                /** This condition is to update the Status to OES Review Pending,
                * when the Stage moved to OES Review after Assessment gets complete. */
                else if (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                        && (hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESReviewPending
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESReviewInProgress
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESReviewComplete
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESOpenRFI
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_OESReviewPending;
                }
                /** This condition is to update the Status to FEMA Review Pending,
                * when the Stage moved to FEMA Review after gets approved for FEMA Review. */
                else if (hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                        && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                        && (hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_FEMAReviewPending
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_FEMAReviewInProgress
                                    && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_FEMAReviewComplete
                        && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI
                        && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_FEMAReviewPending;
                }
            }
        }
    }

    /***********************************************
    * Method Name : StageBasedUpdateAccessToUser
    * Author : Ricky
    * Description: This method is used to prevent Homeowner/Community user from updating the Application
     *              based on Stage and Status of the Application record.
    *********************************************/
    private void StageBasedUpdateAccessToUser() {
        /** Collection to collect the HH Applications which needs to be processed. */
        List<HH_Application__c> hhApplicationToProcessList = new List<HH_Application__c>();
        /** Collection to collect the Current user Id in order to fetch their assigned Permission Set. */
        Set<Id> currentUserIds = new Set<Id>();
        /** Iterating Trigger.new and collecting the Applications which got updated and Stage is not Draft. */
        for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
            if (hhApplicationToProcess != oldRecord
                    && hhApplicationToProcess.Stage__c != HH_CONSTANTS.HHApplication_Stage_Draft) {
                hhApplicationToProcessList.add(hhApplicationToProcess);
                currentUserIds.add(UserInfo.getUserId());
            }
        }
        if (currentUserIds?.size() > 0) {
            /** Fetching the User records and its Permission Set Assignments. */
            List<User> userList = [SELECT Id, Name,
                                        (SELECT Id, PermissionSet.Id, PermissionSet.Name FROM PermissionSetAssignments)
                                    FROM User WHERE Id IN :currentUserIds];
            /** Map collection to arrange the User records as User Id as key and List of Permission Set API names as value. */
            Map<Id, List<String>> userIdToPermissionSetApiNameListMap = new Map<Id, List<String>>();
            for (User user : userList) {
                List<String> permissionSetApiNameList = new List<String>();
                if (user?.PermissionSetAssignments?.size() > 0) {
                    for (PermissionSetAssignment permissionSet : user?.PermissionSetAssignments) {
                        permissionSetApiNameList.add(permissionSet.PermissionSet.Name);
                    }
                }
                if (permissionSetApiNameList?.size() > 0) {
                    userIdToPermissionSetApiNameListMap.put(user.Id, permissionSetApiNameList);
                }
            }
            /** Iterating hhApplicationToProcessList collection to process the Records. */
            for (HH_Application__c hhApplicationToProcess : hhApplicationToProcessList) {
                HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
                /** Condition Criteria - (1 AND !2 AND 3)
                 * 1. Stage or Status of the record got Changed.
                 *      - This condition was added to prevent Homeowner from Changing the Stage.
                 * 2. Old Stage - Draft
                 *      New Stage - Community Review
                 *      New Status - Community Review Pending.
                 *      - This condition was added for allowing the Homeowner to Submit the Application for Review.
                 * 3. User have HH Home Owner Permission Set.
                 *      - This condition was to add check the if the USer has HH Homeowner Permission Set.
                 * This Condition is added to prevent homeowner from changing Application Stage and Status,
                 * other the submitting for Community Review. */
                if (userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName)
                        && (hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                            || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                        && !(oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                            && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending)) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
                /** Condition Criteria - (1 AND 2 AND 3 AND (4 OR 5) AND 6)
                 *      - This condition is added to allow Homeowner to update the Record except the Stage and Status.
                 * 1. Record is been updated.
                 * 2. Stage of the Application is not Updated.
                 * 3. Status of the Application is not updated.
                 * 4. Stage - Draft
                 *      Status - New/Appeal Approved - Resubmit
                 * 5. Stage - Community Review
                 *      Status is - Open RFI-Need More Info
                 * 6. User has HH Homeowner Permission Set.
                 * This condition is added to allow Homeowner user to make changes to Application,
                 * without changing the Stage or Status in tha particular Stage and Status mentioned in the condition. */
                else if (userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName)
                        && oldRecord != hhApplicationToProcess
                        && hhApplicationToProcess.Stage__c == oldRecord.Stage__c
                        && hhApplicationToProcess.Status__c == oldRecord.Status__c
                        && !((hhApplicationToProcess.Stage__c ==  HH_CONSTANTS.HHApplication_Stage_Draft
                                && (hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_New
                                        || hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit ))
                            || (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))) {
                    //hhApplicationToProcess.addError('You cannot edit this record, because it is already submitted for Review.');
                    hhApplicationToProcess.addError('Application not editable.');
                }
                /* Condition Criteria - !((1 AND (2 OR (3 AND 4))) OR (5 OR 6)) AND 7
                 * 1. Stage or Status of the Record is updated.
                 *      - To check if the Stage/Status of the record got updated.
                 * 2. Old Stage - Community Decision
                 *      Old Status - Approved for Assessment
                 *      New Stage - Assessment
                 *      - To allow User to Move the Record from Community Decision to Assessment after Approval.
                 * 3. Old Stage - Community Decision
                 *      New Stage - Community Decision
                 * 4. New Status - Approved for Assessment
                 *      3th and 4th condition is added to allow community user to move the Record to Assessment Stage.
                 * 5. Stage - Draft/Community Review/Community Decision/Assessment/Assessment Decision
                 * 6. Stage - Cal OE Review
                 *      Status - Cal OES Review Pending/Open RFI-Need more Info
                 *   - 5th and 6th condition is added to allow user to make changes to record when Stage is Draft/Community Review
                 *          /Community Decision/Assessment/Assessment Decision/Cal OES Review(Pending/RFI Status).
                 * 7. User has HH Community user Permission Set.
                 *      - This condition is to check if the user has HH Community User Permission.
                 * 8. Status - Withdrawn
                 *      - This condition is to allow Community User to Withdraw the Application.
                 * This Condition is added to prevent Community User from changing Application Stage and Status,
                 * after the submitting for CalOES Review except Open RFI and to Withdraw the Application.
                else if (!(((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                                        || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                                && ((oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                        && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                        && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending)
                                    || oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision))
                            || (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                    || (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                            && (hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending
                                                || hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))
                                    || (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                                        && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI)
                        || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_RejectedClosed
                        || hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn))
                        && userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)) {
                    //hhApplicationToProcess.addError('You cannot edit this application because it is already submitted for Cal OES Review.');
                    hhApplicationToProcess.addError('Application not editable.');
                }*/
                 /**This Condition is added to allow Community County User to change the Application Stage and Status.
                 * Condition Criteria - !((1 OR 2) AND (3 OR 4)) AND 5
                 *      - This condition is added to allow Homeowner to update the Record except the Stage and Status.
                 * 1. Stage of the Application is Updated.
                 * 2. Status of the Application is updated.
                 * 3. Stage - Draft/Community Review/Community Decision/Assessment/Assessment Decision/
                 *              Cal OES Review(Only from Assessment to Pending Status)/Rejected-Closed
                 * 4. Application Status is "Withdrawn".
                 * 5. User has HH Community County User Permission Set. */
                else if (userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                        && (hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                                || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                            && !(hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                    && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ReadyForCalOesReview
                                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending)
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_HomeownerAgreement 
                                || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_HomeownerAgreement
                                    && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_TriPartyAgreementFinalized
                                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_ApprovedConverted)
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_RejectedClosed
                                || hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
                 /**This condition is added to allow Community County user to make changes to Application,
                 *      without changing the Stage or Status in the particular Stage and Status mentioned in the condition.
                 * Condition Criteria - (1 AND 2 AND 3 AND !4 AND 5)
                 *      - This condition is added to allow Homeowner to update the Record except the Stage and Status.
                 * 1. Record is been updated.
                 * 2. Stage of the Application is not Updated.
                 * 3. Status of the Application is not updated.
                 * 4. Stage - Draft/Community Review/Community Decision/Assessment/Assessment Decision/
                 *              Cal OES Review(Only Open RFI Status)/FEMA Review(Only Open RFI Status)
                 * 6. User has HH Community User Permission Set. */
                else if(userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                        && hhApplicationToProcess != oldRecord
                        && hhApplicationToProcess.Stage__c == oldRecord.Stage__c
                        && hhApplicationToProcess.Status__c == oldRecord.Status__c
                        && !((hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                            || (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI) 
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_HomeownerAgreement 
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_ApprovedConverted)
                            || hhApplicationToProcess.Application_Lead__c != oldRecord.Application_Lead__c)) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
                 /** Condition Criteria - !((1 AND (2 OR (3 AND 4))) OR (5 OR 6)) AND 7
                 * 1. Stage or Status of the Record is updated.
                 *      - To check if the Stage/Status of the record got updated.
                 * 2. Old Stage - Community Decision
                 *      Old Status - Approved for Assessment
                 *      New Stage - Assessment
                 *      - To allow User to Move the Record from Community Decision to Assessment after Approval.
                 * 3. Old Stage - Community Decision
                 *      New Stage - Community Decision
                 * 4. New Status - Approved for Assessment
                 *      3th and 4th condition is added to allow community user to move the Record to Assessment Stage.
                 * 5. Stage - Draft/Community Review
                 * 6. Stage - Cal OE Review
                 *      Status - Cal OES Review Pending/Open RFI-Need more Info
                 * - 5th and 6th condition is added to allow user to make changes to record when Stage is Draft/Community Review
                 *          /Community Decision/Assessment/Assessment Decision/Cal OES Review/OES Decision/FEMA Review(Pending Status).
                 * 7. User has HH Community user Permission Set.
                 *      - This condition is to check if the user has HH Community User Permission.
                 * 8. Status - Withdrawn
                 *      - This condition is to allow Community User to Withdraw the Application.
                 * 7. User has HH CalOES user Permission Set.
                 *      - This condition is to check if the user has HH CalOES User Permission.
                 * This Condition is added to prevent CalOES User from changing Application Stage and Status,
                 * after the submitting for FEMA Review except Open RFI and to Withdraw the Application. */
                else if (userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)
                        && !(((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                                    || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                                && ((oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                        && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                                        && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewPending)
                                    || oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision))
                                || (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview 
                                    || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
                                    || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
                                            && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMADecisionApprovedForProjectConversion 
                                            && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_HomeownerAgreement 
                                            && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_ContractorQuoteReadyToBeRequested)
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_RejectedClosed
                                || hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn))) {
                    hhApplicationToProcess.addError('Application not editable.');
                } 

                /** Post MVP - After FEMA User Gets Introduce - To remove the above three Else If block and uncomment the below. */
                /** Condition Criteria - (1 OR 2) AND !(3 OR 4) AND 5
                 *      - This Condition is added to allow FEMA User to change the Application Stage and Status.
                 * 1. Stage of the Application is Updated.
                 * 2. Status of the Application is updated.
                 * 3. Stage - FEMA Review/FEMA Decision/Approved-Converted/Rejected-Closed.
                 * 4. Application Status is "Withdrawn".
                 * 5. User has CWMP FEMA User Permission Set.*/
                else if (userIdToPermissionSetApiNameListMap.get(UserInfo.getUserId()).contains(HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName)
                        && (hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                                || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                        && !(hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_RejectedClosed)) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
            }
        }
    }

    /***********************************************
    * Method Name : updateRecordOwnerToHhCountyQueueBasedOnStage
    * Author : Ricky
    * Description: This method is used to change the owner of the Application to County Community bases on .
    *********************************************/
    private void updateRecordOwnerToHhCountyQueueBasedOnStage() {
        /** Collection to collect the County names of the Application, in order to fetch the related public group to share the record with. */
        Set<String> countyNameList = new Set<String>();
        Set<String> QueueAPINames = new Set<String>();
        List<HH_Application__c> hhApplicationToProcessList = new List<HH_Application__c>();

        /** Iterating Trigger.new to collect the HH Application to process and based on Stage, Status, and County of the record. */
        for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
            /** This condition is to check if the Application is submitted for Community Review,
             * In order to change the owner to Community Users Queue of their respective County. */
            if ((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                    || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                        && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                        && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                        && hhApplicationToProcess.County__c != null) {

                /** Adding County names into a Set Collection in order to query the metadata to get related Public group. */
                countyNameList.add(hhApplicationToProcess.County__c);
                hhApplicationToProcessList.add(hhApplicationToProcess);
            }
            /** This condition is to check if the Application is submitted for Cal OES Review, In order to change the owner to Cal OES Users Queue. */ 
            else if ((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                        || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending) {

                QueueAPINames.add(HH_CONSTANTS.HH_CalOESInternal_User_Queue_APIName);
                hhApplicationToProcessList.add(hhApplicationToProcess);
            }
            /** Post MVP Changes - After FEMA User Gets Introduce */
            /** This condition is to check if the Application is submitted for FEMA Review, In order to change the owner to FEMA Users Queue. */
            else if ((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                    || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewPending) {

                QueueAPINames.add(HH_CONSTANTS.HH_FEMA_User_Queue_APIName);
                hhApplicationToProcessList.add(hhApplicationToProcess);
            }
        }

        if (hhApplicationToProcessList?.size() > 0) {
            /** Collection variable to store the Fetched Metadata record. */
            List<County_Config__mdt> countyConfigMetaRecordList = new List<County_Config__mdt>();
            /** This Map collection is to store the County name  as Key and Queue API name as Value in order to fetch the related Queue record,
             * while changing the owner of the Application. */
            Map<String, String> countyNameToQueueApiNameMap = new Map<String, String>();
            Map<String, County_Config__mdt> countyNameToCountyConfigRecord = new Map<String, County_Config__mdt>();
            if (countyNameList?.size() > 0) {
                countyConfigMetaRecordList = [SELECT Id, Label, Application_Type__c, Public_Group_API_Name__c, Queue_API_Name__c, Emails__c
                                                FROM County_Config__mdt WHERE Label IN :countyNameList
                                                AND Application_Type__c = :HH_CONSTANTS.HH_Application_APIName_CountyConfig];
            }
            /** Arranging the County Config Metadata Record in order as County name as Key and Group API name as value. */
            if (countyConfigMetaRecordList?.size() > 0) {
                for (County_Config__mdt countyConfig : countyConfigMetaRecordList) {
                    if (countyConfig.Queue_API_Name__c != null) {
                        QueueAPINames.add(countyConfig.Queue_API_Name__c);
                        countyNameToQueueApiNameMap.put(countyConfig.Label, countyConfig.Queue_API_Name__c);

                        countyNameToCountyConfigRecord.put(countyConfig.Label, countyConfig);
                    }
                }
            }

            if (QueueAPINames?.size() > 0) {
                /** Fetching the Public Group Info in order to share the record. */
                List<Group> publicGroupInfoList = [
                        SELECT Id, Name, DeveloperName, Type, Email
                        FROM Group
                        WHERE DeveloperName IN :QueueAPINames AND Type = 'Queue'
                ];
                /** Arranging the Group record in order as Group API name as Key and Group record as value,
                 * In order to fetch the record while processing the Applications. */
                Map<String, Group> queueDeveloperNameToQueueRecordMap = new Map<String, Group>();

                if (publicGroupInfoList?.size() > 0) {
                    /** Iterating the group record to arrange as API name as Key and Record as Value in order to fetch while updating the Owner. */
                    for (Group groupRecord : publicGroupInfoList) {
                        queueDeveloperNameToQueueRecordMap.put(groupRecord.DeveloperName, groupRecord);
                    }
                    /** Iterating application records to process. */
                    for (HH_Application__c hhApplicationToChangeOwner : hhApplicationToProcessList) {

                        /** This condition is to check if the Application is submitted for Community Review,
                         * In order to change the owner to Community Users Queue. */
                        if (hhApplicationToChangeOwner.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                && hhApplicationToChangeOwner.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                && queueDeveloperNameToQueueRecordMap?.get(countyNameToQueueApiNameMap?.get(hhApplicationToChangeOwner?.County__c))?.Id != null) {
                            hhApplicationToChangeOwner.OwnerId = queueDeveloperNameToQueueRecordMap?.get(countyNameToQueueApiNameMap?.get(hhApplicationToChangeOwner?.County__c))?.Id;
                            if(countyNameToCountyConfigRecord?.get(hhApplicationToChangeOwner?.County__c)?.Emails__c != null) {
                                string emailString = countyNameToCountyConfigRecord?.get(hhApplicationToChangeOwner?.County__c)?.Emails__c?.replace(',', ';');
                                List<String> emails = emailString?.split(';');
                                hhApplicationToChangeOwner.Community_County_Queue_Email__c = emails[0];
                            } 
                            hhApplicationToChangeOwner.Owner_Name__c = queueDeveloperNameToQueueRecordMap?.get(countyNameToQueueApiNameMap?.get(hhApplicationToChangeOwner?.County__c))?.Name;
                        }
                        /** This condition is to check if the Application is submitted for Cal OES Review,
                         * In order to change the owner to Cal OES Users Queue. */
                        else if (hhApplicationToChangeOwner.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                && hhApplicationToChangeOwner.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending
                                && queueDeveloperNameToQueueRecordMap?.get(HH_CONSTANTS.HH_CalOESInternal_User_Queue_APIName)?.Id != null) {
                            hhApplicationToChangeOwner.OwnerId = queueDeveloperNameToQueueRecordMap?.get(HH_CONSTANTS.HH_CalOESInternal_User_Queue_APIName)?.Id;
                            hhApplicationToChangeOwner.Owner_Name__c = queueDeveloperNameToQueueRecordMap?.get(HH_CONSTANTS.HH_CalOESInternal_User_Queue_APIName)?.Name;

                        }
                        /** Post MVP Changes - After FEMA User Gets Introduce */
                        /** This condition is to check if the Application is submitted for FEMA Review,
                         * In order to change the owner to FEMA Users Queue. */
                        else if (hhApplicationToChangeOwner.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                                && hhApplicationToChangeOwner.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewPending
                                && queueDeveloperNameToQueueRecordMap?.get(HH_CONSTANTS.HH_FEMA_User_Queue_APIName)?.Id != null) {
                            hhApplicationToChangeOwner.OwnerId = queueDeveloperNameToQueueRecordMap?.get(HH_CONSTANTS.HH_FEMA_User_Queue_APIName)?.Id;
                            hhApplicationToChangeOwner.Owner_Name__c = queueDeveloperNameToQueueRecordMap?.get(HH_CONSTANTS.HH_FEMA_User_Queue_APIName)?.Name;
                        }
                    }
                }
            }
        }
    }

    /***********************************************
    * Method Name : shareRecordWithUserBasedOnStage
    * Author : Ricky
    * Description: This method is used to share the HH Application records based on Stage and Status.
    *********************************************/
    private void shareRecordWithUserBasedOnStage() {
        /** Collection to collect the County names of the Application, in order to fetch the related public group to share the record with. */
        Set<String> countyNameList = new Set<String>();

        /** Collection to collect the Public group API names based on Stage and Status and selected County value on Application record,
         * In order to Query the Group Data. */
        Set<String> publicGroupApiNames = new Set<String>();

        /** Collection to collect the HH Application record to Share. */
        Map<Id, HH_Application__c> hhApplicationIdToHhApplicationShareMap = new Map<Id, HH_Application__c>();

        /** Iterating Trigger.new to collect the HH Application to process and based on Stage, Status, and County of the record. */
        for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
            /** This condition is to check the Application submitted for Community Review,
             * In order to share the record with Community of their respective County, Initial Owner of the record, and Cal OES User. */
            if ((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                    || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                        && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                        && hhApplicationToProcess.County__c != null) {

                hhApplicationIdToHhApplicationShareMap.put(hhApplicationToProcess.Id, hhApplicationToProcess);
                    /** Adding County names into a Set Collection in order to query the metadata to get related Public group. */
                    countyNameList.add(hhApplicationToProcess.County__c);

                publicGroupApiNames.add(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName);
                }
            /** Post MVP Changes - After FEMA User Gets Introduce */
            /** This condition is to check if the Application is submitted for FEMA Review, In order to share th record with FEMA User group. */
            else if ((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                        || hhApplicationToProcess.Status__c != oldRecord.Status__c)
                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewPending) {

                hhApplicationIdToHhApplicationShareMap.put(hhApplicationToProcess.Id, hhApplicationToProcess);
                publicGroupApiNames.add(HH_CONSTANTS.HH_FEMA_User_Group_APIName);
            }
            }

        if (hhApplicationIdToHhApplicationShareMap?.size() > 0) {
            /** Querying the County Config Metadata to fetch the related Public group API name of County. */
            List<County_Config__mdt> countyConfigMetaRecordList = new List<County_Config__mdt>();
            Map<String, String> countyNameToPublicGroupApiNameMap = new Map<String, String>();
            Map<String, Group> groupDeveloperNameToGroupRecordMap = new Map<String, Group>();
            List<Group> publicGroupInfoList = new List<Group>();
            if (countyNameList?.size() > 0) {
                countyConfigMetaRecordList = [
                        SELECT Id, Label, Application_Type__c, Public_Group_API_Name__c,
                                Queue_API_Name__c
                        FROM County_Config__mdt
                                                WHERE Label IN : countyNameList
                        AND Application_Type__c = :HH_CONSTANTS.HH_Application_APIName_CountyConfig
                ];
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

            /** List collection to collect the Application Share record s to insert. */
            List<HH_Application__Share> appShareToOwnerRecordList = new List<HH_Application__Share>();

            for (HH_Application__c hhApplicationToShare : hhApplicationIdToHhApplicationShareMap.values()) {
                HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToShare.Id);
                    /** Condition to check if the Application Stage is "Community Review" and Status is "Community Review Pending",
                     * In order to Share the record based on County of the Property Address. */
                if (hhApplicationToShare.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                    && hhApplicationToShare.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                    && hhApplicationToShare.County__c != null) {

                    /** Sharing the record with Homeowner/Initial Record Owner when the Application is submitted for Community Review. */
                    HH_Application__Share appShareToOwnerRecord = new HH_Application__Share();
                    appShareToOwnerRecord.ParentId = hhApplicationToShare.Id;
                    appShareToOwnerRecord.RowCause = HH_Application__Share.RowCause.HomeownerUser__c;
                    appShareToOwnerRecord.UserOrGroupId = oldRecord.OwnerId;
                    appShareToOwnerRecord.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;

                    appShareToOwnerRecordList.add(appShareToOwnerRecord);


                    /** This condition is to share the record with the County user of the Application. */
                    if (groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(hhApplicationToShare?.County__c))?.Id != null) {
                        HH_Application__Share appShareToCommunityRecord = new HH_Application__Share();
                        appShareToCommunityRecord.ParentId = hhApplicationToShare.Id;
                        appShareToCommunityRecord.RowCause = HH_Application__Share.RowCause.CommunityUser__c;
                        appShareToCommunityRecord.UserOrGroupId = groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(hhApplicationToShare?.County__c))?.Id;
                        appShareToCommunityRecord.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;

                        appShareToOwnerRecordList.add(appShareToCommunityRecord);
                    }
                    /** To be uncommented in Sprint 5 */
                    /** Sharing the record with Cal OES user group when the Application is submitted for Community Review.
                     * Reason for Sharing in this Stage instead of Cal OES Review is -
                     *      Cal OES is super user and has all the Permission as Community User except for Application creation. */
                    HH_Application__Share appShareToCalOesRecord = new HH_Application__Share();
                    appShareToCalOesRecord.ParentId = hhApplicationToShare.Id;
                    appShareToCalOesRecord.RowCause = HH_Application__Share.RowCause.CalOESUser__c;
                    appShareToCalOesRecord.UserOrGroupId = groupDeveloperNameToGroupRecordMap?.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName)?.Id;
                    appShareToCalOesRecord.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;

                    appShareToOwnerRecordList.add(appShareToCalOesRecord);
                }
                /** Post MVP Changes - After FEMA User Gets Introduce */
                /** Sharing the record with FEMA user group when the Application is submitted for FEMA Review. */
                else if (hhApplicationToShare.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview) {
                    HH_Application__Share appShareToFemaRecord = new HH_Application__Share();
                    appShareToFemaRecord.ParentId = hhApplicationToShare.Id;
                    appShareToFemaRecord.RowCause = HH_Application__Share.RowCause.FEMAUser__c;
                    appShareToFemaRecord.UserOrGroupId = groupDeveloperNameToGroupRecordMap?.get(HH_CONSTANTS.HH_FEMA_User_Group_APIName)?.Id;
                    appShareToFemaRecord.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;

                    appShareToOwnerRecordList.add(appShareToFemaRecord);
                }
                    }

            if (appShareToOwnerRecordList?.size() > 0) {
                insert appShareToOwnerRecordList;
            }
        }
    }

    /***********************************************
    * Method Name : createDocuments
    * Author : Sushant
    * Description: This method is used to create the related Document upon Application creation.
    *********************************************/
    public void createDocuments() {
        /** Collection to collect the Application ID which are inserted and Program field is not null in order to pass the Ids for Document creation. */
        Set<Id> applicationIds = new Set<Id>();
        for (HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
            if (applicationToProcess.Program__c  != null) {
                applicationIds.add(applicationToProcess.Id);
            }
        }
        if (applicationIds?.size() > 0) {
            new HHCreateHHApplicationDocument().handle(applicationIds);
        }
    }

    /***********************************************
    * Method Name : updateProgramNameInHhApplicationRecord
    * Author : Ricky
    * Description: This method is used to update the Program field on HH Application upon insertion of the record.
    *********************************************/
    private void updateProgramNameInHhApplicationRecord() {
        /** Fetching CWMP Program record in order to update teh Program field in Application. */
        List<Program__c> hhProgramRecord = [SELECT Id, Name, Master_Label_Program_Name__c FROM Program__c
                                                WHERE Master_Label_Program_Name__c = :HH_CONSTANTS.HH_Application_ProgramName_MasterLabel LIMIT 1];
        if (hhProgramRecord?.size() == 1) {
            /** Iterating Trigger.new collection and checking if the Application  record's Program field is Empty or does not have CWMP Program ID,
             * then assigning the CWMP program Id. */
            for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>) Trigger.new) {
                if (hhApplicationToProcess.Program__c == null
                        || (hhApplicationToProcess.Program__c !=  null
                        && hhApplicationToProcess.Program__c != hhProgramRecord[0]?.Id)) {
                    hhApplicationToProcess.Program__c = hhProgramRecord[0]?.Id;
                }
            }
        }
    }

    /***********************************************
    * Method Name : autoUpdateStageToOESReviewUponReadyForCalOESReviewStageReason
    * Author : Ricky
    * Description: This method is used to auto update the Stage field to Cal OES Review,
     * when the User update the Application for Assessment to Assessment Decision and Status to Ready for Cal OES Review.
    *********************************************/
//    private void autoUpdateStageToOESReviewUponReadyForCalOESReviewStageReason() {
//        for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>) Trigger.new) {
//            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
//            /** This condition is added to check if the record is Approved for Cal OES Review,
//             * then auto update the Stage - OES Review, and Stage-Reason - OES Review Pending. */
//            if ((oldRecord.Stage__c != oldRecord.Stage__c
//                    || oldRecord.Status__c != hhApplicationToProcess.Status__c)
//                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
//                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_ReadyForCalOesReview) {
//                hhApplicationToProcess.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESReview;
//                hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_OESReviewPending;
//            }
//            /** This condition is added to check if the record is Approved for FEMA Review,
//             * then auto update the Stage - FEMA Review, and Stage-Reason - FEMA Review Pending. */
//            if ((oldRecord.Stage__c != oldRecord.Stage__c
//                    || oldRecord.Status__c != hhApplicationToProcess.Status__c)
//                    && hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
//                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForFEMAReview) {
//                hhApplicationToProcess.Stage__c = HH_CONSTANTS.HHApplication_Stage_FEMAReview;
//                hhApplicationToProcess.Status__c = HH_CONSTANTS.HHApplication_Status_FEMAReviewPending;
//            }
//        }
//    }

    /***********************************************
    * Method Name : preventDeletionExceptDraftNewStage
    * Author : Ricky
    * Description: This method is used to prevent the user from Deleting Application when its STage is not "Draft" and Stage-Reason is not "New",
    *               Unless the User is System Admin.
    *********************************************/
    private void preventDeletionExceptDraftNewStage() {
        /** Set collection to store the current logged In User Id who is trying to delete the Application. */
        Set<Id> userIdSet = new Set<Id>();
        /** Iterating Trigger.new in order to collect the current Logged In User ID. */
        for (HH_Application__c applicationToDelete : (List<HH_Application__c>) Trigger.old) {
            userIdSet.add(UserInfo.getUserId());
        }

        if (userIdSet?.size() > 0) {
            /** Fetching the user record data in order to get the current User Profile. */
            Map<Id, User> userIdToUserRecordMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM User WHERE Id IN :userIdSet]);
   
            /** Iterating Trigger.old to check the required condition before deleting the Application record. */
            for (HH_Application__c applicationToDelete : (List<HH_Application__c>) Trigger.old) {
                /** Condition to check -
                 * 1. Stage - Draft
                 *     Stage-Reason - New
                 * 2. User profile - System Admin
                 * Condition Criteria - (1 OR 2) */
                if (!(applicationToDelete.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                        && applicationToDelete.Status__c == HH_CONSTANTS.HHApplication_Status_New)
                        && userIdToUserRecordMap?.get(UserInfo.getUserId()).Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin) {
                    applicationToDelete.addError(System.Label.HH_EN_Application_Delete_Not_Allowed);
                }
            }
        }
    }

    /***********************************************
    * Method Name : preventCalOesSubmissionWithoutDocumentUpload
    * Author : Ricky
    * Updated By: Sushant.
    * Description: This method is used to prevent the user from submitting the Application to next step,
    *              before uploading all the required Documents.
    *********************************************/
    private void preventCalOesSubmissionWithoutDocumentUpload() {
        /** Map collection to collect the Application record which needs to processed. */
        Map<Id, HH_Application__c> applicationIdToApplicationToProcessMap = new Map<Id, HH_Application__c>();
//        List<Id> hhApplicationIdList = new List<Id>();
        /** Iterating Trigger.new and collecting the Application which are being submitted for Cal OES Review. */
        for (HH_Application__c hhApplicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
            /** Condition to check if the Stage of the Application is changed and new Stage of the Application is Cal OES Review. */
            if (hhApplicationToProcess.Stage__c != oldRecord.Stage__c
                    && (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                            || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview)) {
                /** Adding the Application record to Map collection for processing it further. */
                applicationIdToApplicationToProcessMap.put(hhApplicationToProcess.Id, hhApplicationToProcess);
            }
//            if ((hhApplicationToProcess.Stage__c != oldRecord.Stage__c
//                    || hhApplicationToProcess.Status__c != oldRecord.Status__c)
//                    && ( hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
//                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_ReadyForCalOesReview)) {
//                hhApplicationIdList.add(hhApplicationToProcess.Id);
//            }
        }
//        if(hhApplicationIdList.size() >0){
//            List<HH_Application__c> lst =[SELECT id,(SELECT id,Document_Type__c,Stage__c FROM Documents__r) from HH_Application__c where id In : hhApplicationIdList];
//            for(HH_Application__c hh :lst){
//                Integer i = 0;
//                for(Document__c dd:hh.Documents__r){
//                    if((dd.Document_Type__c == 'Proof of Rental' || dd.Document_Type__c == 'Proof of Ownership') && dd.Stage__c=='Uploaded'){
//                        i++;
//                    }
//                }
//                if(i != 2){
//                    hh.addError('Please upload Home Assessment Report, Environmental Checklist Documents.');
//                }else {
//                    System.debug('Success...');
//                }
//            }
//        }
        /** Checking for null pointer exception for applicationIdToApplicationToProcessMap collection. */
        if (applicationIdToApplicationToProcessMap?.size() > 0) {
            /** Fetching the Application record and its related Documents, whose
             *      Status = Active */
            Map<Id, HH_Application__c> appIdToAppToProcessWithDocumentMap = new Map<Id, HH_Application__c>([SELECT Id, Name,
                                                                    (SELECT Id, Document_Type__c, Stage__c FROM Documents__r
                                                                    WHERE Status__c = :HH_CONSTANTS.Document_Status_Active)
                                                            FROM HH_Application__c WHERE Id IN :applicationIdToApplicationToProcessMap.keySet()]);
            /** Iterating applicationIdToApplicationToProcessMap map collection record to check for condition for Documents. */
            for (HH_Application__c applicationToProcess : applicationIdToApplicationToProcessMap?.values()) {
                /** Condition to check if the Document is required and not uploaded. */
                if (appIdToAppToProcessWithDocumentMap?.get(applicationToProcess.Id)?.Documents__r?.size() > 0) {
                    /** If anyone of multiple documents which has same document type document is uploaded then mark below variable as true **/
                    Boolean isHomeAssessmentReport = false;
                    Boolean isEnvironmentalChecklist = false;
                    Boolean isProofOfRental = false;
                    Boolean isPropertyOwnerID = false;
                    Boolean isProofOfOwnership = false;
                    Boolean isProofOfRentalDocAvailable = false;
                    /** Iterating the available Documents of the current Documents. */
                    for (Document__c document : appIdToAppToProcessWithDocumentMap?.get(applicationToProcess.Id)?.Documents__r) {
                        if(document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_Rental){
                            isProofOfRentalDocAvailable = true;
                        }
                        /** If the document is Uploaded **/
                        if(document.Stage__c == HH_CONSTANTS.Document_Stage_Uploaded) {
                            /** If the document type is Home Assessment Report then mark it as True **/
                            if (document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_HomeAssessmentReport) {
                                isHomeAssessmentReport = true;
                            }
                            /** If the document type is Environmental Checklist then mark it as True **/
                            if (document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_EnvironmentalChecklist) {
                                isEnvironmentalChecklist = true;
                            }
                            /** If the document type is Proof Of Ownership then mark it as True **/
                            if (document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_ProofOfOwnership) {
                                isProofOfOwnership = true;
                            }
                            /** If the document type is Property Owner ID then mark it as True **/
                            if (document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_PropertyOwnerID) {
                                isPropertyOwnerID = true;
                            }
                            /** If the document type is Proof of Rental then mark it as True **/
                            if (document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_Rental) {
                                isProofOfRental = true;
                            }
                        }else{
                            /** If the document type is Proof of Rental, document is not required and Document is not uploaded then mark it as True **/
                        if (document?.Document_Type__c == HH_CONSTANTS.Document_DocumentType_Rental
                                && (applicationToProcess.Currently_Occupied__c == null || applicationToProcess.Currently_Occupied__c == HH_CONSTANTS.PickList_No)) {
                                isProofOfRental = true;
                            }
                        }
                    }
                    if((applicationToProcess.Currently_Occupied__c == null || applicationToProcess.Currently_Occupied__c == HH_CONSTANTS.PickList_No ) && isProofOfRentalDocAvailable == false){
                        isProofOfRental = true;
                    }
                    /** If the Application is in 'Pending Cal OES Review' status, 'Home Assessment Report' and 'Environmental Checklist'
                     * Documents are not uploaded display the error to upload both documents. **/

                    if(applicationToProcess?.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending
                            && (isHomeAssessmentReport == false || isEnvironmentalChecklist == false)){
                        applicationToProcess.addError('Please upload \'Home Assessment Report\' / \'Environmental Checklist\' Documents.');
                    /** while changing status if Property Owner ID, Proof Of Ownership, Proof Of Rental
                     * documents are not uploaded then display error to upload required document **/

                    }else if(isProofOfRental == false
                     || isPropertyOwnerID == false
                     || isProofOfOwnership == false){
                            applicationToProcess.addError('Please upload all the required Documents.');
                        }
                    }
                }
            }
        }

    /***********************************************
    * Method Name : preventReverseStageChange
    * Author : Ricky
    * Description: This method is used to prevent the user from changing the Stage in Reverse order except System Administrator.
    *********************************************/
    private void preventReverseStageChange() {
        /** Collection variable to store the currently logged in User Ids. */
        Set<Id> userId = new Set<Id>();
        /** Map collection to store the application record which needs to be processes.(Stage/Status is changed) */
        Map<Id, HH_Application__c> appIdToApplicationToProcessMap = new Map<Id, HH_Application__c>();
        for (HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(applicationToProcess.Id);
            /** Condition to check if the Stage or Status of the Application is changed. */
            if (applicationToProcess.Stage__c != oldRecord.Stage__c
                    || applicationToProcess.Status__c != oldRecord.Status__c) {
                appIdToApplicationToProcessMap.put(applicationToProcess.Id, applicationToProcess);
                userId.add(UserInfo.getUserId());
                        }
                        }
        if (appIdToApplicationToProcessMap?.size() > 0) {
            Map<Id, Set<String>> userIdToAssignedPermissionSetsMap = new Map<Id, Set<String>>();
            /** Fetching the User record and its related Permission Set assignments. */
            Map<Id, User> userIdToUserRecordMap = new Map<Id, User>([
                    SELECT Id, Name, Profile.Name, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                    FROM User
                    WHERE Id IN :userId
            ]);
            /** Checking for null pointer exception for user record and then Iterating the Permission Set assignments,
             * in order to collect the API names of teh assigned Permission Sets. */
            if (userIdToUserRecordMap?.size() > 0) {
                for (User userRecordToProcess : userIdToUserRecordMap.values()) {
                    /** Set collection to store the current user available Permission Set Assignment API Name. */
                    Set<String> currentUserPermissionSet = new Set<String>();
                    if (userRecordToProcess?.PermissionSetAssignments?.size() > 0) {
                        for (PermissionSetAssignment pAssignment : userRecordToProcess?.PermissionSetAssignments) {
                            currentUserPermissionSet.add(pAssignment.PermissionSet.Name);
                        }
                    }
                    if (currentUserPermissionSet?.size() > 0) {
                        userIdToAssignedPermissionSetsMap.put(userRecordToProcess.Id, currentUserPermissionSet);
                    } else {
                        userIdToAssignedPermissionSetsMap.put(userRecordToProcess.Id, null);
                    }
                }
            }

            /** Iterating the application record to be processed. */
            for (HH_Application__c hhApplicationToProcess : appIdToApplicationToProcessMap.values()) {
                HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(hhApplicationToProcess.Id);
                /** Condition to check if the Stage of the Application is changed, In order to check the necessary conditions before update. */
                if (oldRecord.Stage__c != hhApplicationToProcess.Stage__c) {
                    /** Condition to check -
                     * 1. Old Record Stage = Community Decision
                     * 2. New Record Stage = Community Review
                     * 3. User profile != System Admin
                     * Condition Criteria - 1 AND 2 AND NOT(3)
                     * This condition is to check whether the record Stage has benn changed
                     *      from - Community Decision
                     *      to - Community Review.*/
                    if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                            && oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                            && (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview)) {
                        hhApplicationToProcess.addError('Application not editable.');
                    }
                    /** Condition to check -
                     * 1. Old Record Stage = Assessment Decision
                     * 2. New Record Stage = Community Review / Community Decision / Assessment
                     * 3. User profile != System Admin
                     * Condition Criteria - 1 AND 2 AND NOT(3)
                     * This condition is to check whether the record Stage has benn changed
                     *      from - Assessment Decision
                     *      to - Community Review / Community Decision / Assessment */
                    else if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                            && oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                            && (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment)) {
                        hhApplicationToProcess.addError('Application not editable.');
                    }
                    /** Condition to check -
                     * 1. Old Record Stage = Cal OES Decision
                     * 2. New Record Stage = Community Review / Community Decision / Assessment / Assessment Decision / Cal OES Review
                     * 3. User profile != System Admin
                     * Condition Criteria - 1 AND 2 AND NOT(3)
                     * This condition is to check whether the record Stage has benn changed
                     *      from - OES Decision
                     *      to - Community Review / Community Decision / Assessment / Assessment Decision / Cal OES Review. */
                    else if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                            && oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
                            && (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview)) {
                        hhApplicationToProcess.addError('Application not editable.');
                    }
                    /** Post MVP - After FEMA User Gets Introduce - to uncomment the code. */
                    /** Condition to check -
                     * 1. Old Record Stage = FEMA Decision
                     * 2. New Record Stage = Community Review / Community Decision / Assessment / Assessment Decision
                     *                      / Cal OES Review /Cal OES Decision / FEMA Review
                     * 3. User profile != System Admin
                     * Condition Criteria - 1 AND 2 AND NOT(3)
                     * This condition is to check whether the record Stage has benn changed
                     *      from - OES Decision
                     *      to - Community Review / Community Decision / Assessment / Assessment Decision
                    *            / Cal OES Review /Cal OES Decision / FEMA Review */
                    else if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                            && oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
                            && (hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
                                || hhApplicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview)) {
                        hhApplicationToProcess.addError('Application not editable.');
                    }
                }

                /** Condition to check -
                 * 1. Stage/Status of the Application is changed.
                 * 2. Old Record Status = Rejected-Not Eligible/Rejected-Does Not meet Criteria/FEMA Rejected/OES Rejected.
                 * 3. New Record Stage != Draft AND
                 * 4. New Record Status != Appeal Approved Resubmit
                 * 5. New Record Stage != Rejected-Closed
                 * 6. User Profile != System Admin
                 * Condition Criteria - 1 AND 2 AND 3 AND 4 AND 5 AND 6 */
                if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                        && (oldRecord.Stage__c != hhApplicationToProcess.Stage__c
                        || oldRecord.Status__c != hhApplicationToProcess.Status__c)
                        && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedNotEligible
                            || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria
                            || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMADecisionRejected
                            || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESDecisionRejected)
                        && (hhApplicationToProcess.Stage__c != HH_CONSTANTS.HHApplication_Stage_Draft
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit
                            && hhApplicationToProcess.Stage__c != HH_CONSTANTS.HHApplication_Stage_RejectedClosed
                            && hhApplicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
                /** Condition to check -
                 * 1. Stage/Status of the Application is changed.
                 * 2. Old Record Status = Withdrawn
                 * 3. New Record Stage != Rejected-Closed
                 * 4. User Profile != System Admin
                 * Condition Criteria - 1 AND 2 AND 3 AND 4 */
                if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                        && (oldRecord.Stage__c != hhApplicationToProcess.Stage__c
                        || oldRecord.Status__c != hhApplicationToProcess.Status__c)
                        && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn
                        && hhApplicationToProcess.Stage__c != HH_CONSTANTS.HHApplication_Stage_RejectedClosed) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
                /** Condition to check -
                 * 1. Stage/Status of the Application is changed.
                 * 2. New Record Stage = Withdrawn
                 * 3. Old Record Stage = Community Review
                 * 4. Old Record Status = Community Review Pending/Community Review In progress
                 * 5. 3. Old Record Stage = Community Decision
                 * 6. Old Record Status = Approved for Assessment/Rejected-Does Not Meet Criteria
                 * 7. Old Record Stage = Assessment
                 * 8. Old Record Status = Assessment Pending/Assessment in Progress/Assessment Complete
                 * 9. Old Record Stage = Assessment Decision
                 * 10. Old Record Status = Rejected-Not Eligible
                 * 11. Old Record Stage = Cal OES Review
                 * 12. Old Record Status = Cal OES Review Pending/Cal OES Review In progress
                 * 13. Old Record Stage = Cal OES Decision
                 * 14. Old Record Status = Rejected-Does Not Meet Criteria
                 * 15. User Profile != System Admin
                 * Condition Criteria - 1 AND 2 AND
                 *                      NOT((3 AND 4) || (5 AND 6) || (7 AND 8) || (9 AND 10) || (11 AND 12) || (13 AND 14))
                 *                      AND NOT(15)  */
                if(oldRecord.Status__c != hhApplicationToProcess.Status__c
                    && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn
                    && userIdToAssignedPermissionSetsMap.get(UserInfo.getUserId())?.contains(HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName)) {
                        hhApplicationToProcess.addError(System.Label.HH_Application_FEMAWithdrawnError);   
                } 

                else if (userIdToUserRecordMap.get(UserInfo.getUserId())?.Profile.Name != HH_CONSTANTS.HH_Profile_SystemAdmin
                        && oldRecord.Status__c != hhApplicationToProcess.Status__c
                        && hhApplicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_Withdrawn
                        && (userIdToAssignedPermissionSetsMap.get(UserInfo.getUserId())?.contains(HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName) 
                            || !(oldRecord.Stage__c == hhApplicationToProcess.Stage__c
                            && ((oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit)
                            || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))
                            || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria))
                            || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_AssessmentPending
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_AssessmentInProgress
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_AssessmentComplete
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))
                            || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_AssessmentDecision
                                && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedNotEligible)
                            || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewInProgress
                                    || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))
                            || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESDecision
                                        && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria) 
                                || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                                    && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewPending
                                        || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewInProgress)) 
                                || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMADecision
                                    && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMADecisionApprovedForProjectConversion 
                                        || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria)) 
                                || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_HomeownerAgreement
                                    && (oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ContractorQuoteReadyToBeRequested
                                        || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ContractorQuoteRequested
                                        || oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_ContractorQuoteReceived)))))) {
                    hhApplicationToProcess.addError('Application not editable.');
                }
            }
        }
    }

    /***********************************************
    * Method Name : convertCWMPApplicationToCWMPProject
    * Author : Sushant
    * Description: This method is used to Create CWMP Project when the changes the Stage into Approved Converted
    *********************************************/
    private void convertCWMPApplicationToCWMPProject() {
        /** Map to store Application Id with Application record **/
         Map<Id, HH_Application__c> appIdToApplicationToProcessMap = new Map<Id, HH_Application__c>();

         Map<Id, Id> applicationIdToRelatedProjectIdMap = new Map<Id, Id>();


        /** list of projects needs to be inserted **/
        List<CWMP_Project__c> projectToInsertList = new List<CWMP_Project__c>();
        for (HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
         HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(applicationToProcess.Id);
         /** If stage and status is changed and new stage is Approved Converted then add then Application id to Map **/
            if ((applicationToProcess.Stage__c != oldRecord.Stage__c
                 || applicationToProcess.Status__c != oldRecord.Status__c)
             && (applicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_ApprovedConverted)) {
                appIdToApplicationToProcessMap.put(applicationToProcess.Id, applicationToProcess);
            }
        }
        if(appIdToApplicationToProcessMap?.size() > 0) {
            List<Account_Role__c> accountRoles = new List<Account_Role__c>();
            /** get all data related to CWMP Application and CWMP Project **/
            Map<Id, HH_Application__c> appIdToApplicationMap = new Map<Id, HH_Application__c>([SELECT Id,Status__c,Stage__c,Applicant__c, 
                                                                    (SELECT Id from CWMP_Projects__r), 
                                                                    (SELECT Id, Name, CWMP_Application__c, CWMP_Project__c FROM Account_Roles__r) 
                                                                    FROM HH_Application__c WHERE Id IN:appIdToApplicationToProcessMap.keySet()]);
            for(HH_Application__c hhApplicationToProcess :appIdToApplicationToProcessMap.values()){
                HH_Application__c cwmpApp = appIdToApplicationMap.get(hhApplicationToProcess.Id);
                /** if the project is not created then create new project with CWMP Application Id and Applicant Id **/
                if(cwmpApp.CWMP_Projects__r?.size() == 0) {
                    CWMP_Project__c projectToInsert = new CWMP_Project__c();
                    projectToInsert.CWMP_Application__c = cwmpApp.Id;
                    projectToInsert.Applicant__c = cwmpApp.Applicant__c;
                    projectToInsertList.add(projectToInsert);
                }
                /** Condition to check if there are any availabel Contractors, 
                 * then collecting it in a collection in order to relate it with the Project. */
                if(cwmpApp.Account_Roles__r?.size() > 0) {
                    accountRoles.addAll(cwmpApp.Account_Roles__r);
                }
            }

            /** Condition to check there are any project reocrds to be inserted in the List. */
            if(projectToInsertList?.size() > 0) {
                /** insert created Projects **/
                insert projectToInsertList;
                /** Collecting the inserted Project records Id in Map Collection with the related Application ID as Key. */
                for(CWMP_Project__c insertedProject : projectToInsertList) {
                    applicationIdToRelatedProjectIdMap.put(insertedProject.CWMP_Application__c, insertedProject.Id);
                }
            }
            /** Condition to check if there are any available Contractors, 
             * then updating the Project field in order to relate it with the Project. */
            if(accountRoles?.size() > 0) {
                for(Account_Role__c accRole : accountRoles) {
                    accRole.CWMP_Project__c = applicationIdToRelatedProjectIdMap.get(accRole.CWMP_Application__c);
                }
                update accountRoles;
            }
        }
    }
    
    /***********************************************
    * Method Name : updateApproverEmail
    * Author : Ricky
    * Description: This method is used to update Approver Email based on Stage.
    *********************************************/
    private void updateApproverEmail() {
        for (HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(applicationToProcess.Id);
            /** This Condition is to check if the STage/Status of the Application is updated. */
            if (oldRecord.Stage__c != applicationToProcess.Stage__c
                    && oldRecord.Status__c != applicationToProcess.Status__c) {
                /** This Condition is to update the Community Approver Email when the Application is send for Assessment.
                 * Condition to check -
                 * Current Stage - Assessment
                 * Current Status - Assessment Pending */
                if(applicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                        && applicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment) {
                    applicationToProcess.Community_Approver_s_Email__c = UserInfo.getUserEmail();
                }
                /** This Condition is to update the Assessment Approver Email when the Application is submitted for Cal OES Review.
                 * Condition to check -
                 * Current Stage - Cal OES Review
                 * Current Status - Cal OES Review Pending */
                else if(applicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                        && applicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_OESReviewPending) {
                    applicationToProcess.Assessment_Approver_s_Email__c = UserInfo.getUserEmail();
                }
                /** This Condition is to update the Cal OES Approver Email when the Application is submitted for FEMA Review.
                 * Condition to check -
                 * Current Stage - FEMA Review
                 * Current Status - FEMA Review Pending */
                else if(applicationToProcess.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                        && applicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewPending) {
                    applicationToProcess.Cal_OES_Approver_s_Email__c = UserInfo.getUserEmail();
                }
            }
        }
    }

    /***********************************************
    * Method Name : checkRfiStatusBeforeSendingToNextStageForReview
    * Author : Ricky
    * Description: This method is used to prevent user from submitting application for next Stage for Review,
    *              if there is a pending RFI related to the Application.
    *********************************************/
    private void checkRfiStatusBeforeSendingToNextStageForReview() {
        /** Map collection to store the Application records which needs to be processed. */
        Map<Id, HH_Application__c> appIdToApplicationToProcessMap = new Map<Id, HH_Application__c>();
        /** Iterating Trigger.new collection to collect the Application to Process. */
        for (HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
            /** Fetching old record of the Application from Trigger.old map collection. */
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(applicationToProcess.Id);
            /** This condition is added to check if the AApplication Status is changed to Approved for the next user Review.
             * Condition Criteria -
             * 1. Stage or Status of the Application is changed.
             * 2. Old Status of the Application is - Ope RFI
             *       New Status != Open RFI */
            if((applicationToProcess.Stage__c != oldRecord.Stage__c
                        || applicationToProcess.Status__c != oldRecord.Status__c)
                    && ((oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                            && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo
                            && applicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESOpenRFI)
                        || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                            && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo
                            && applicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESOpenRFI)
                        || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                            && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI
                            && applicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_OESOpenRFI)
                        || (oldRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                            && oldRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI
                            && applicationToProcess.Status__c != HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI))) {
                appIdToApplicationToProcessMap.put(applicationToProcess.Id, applicationToProcess);
            }
        }
        /** Checking for null pointer exception for appIdToApplicationToProcessMap map collection. */
        if (appIdToApplicationToProcessMap?.size() > 0) {
            /** Fetching the Application record with their related Open RFI records,
             * whose ID are available in  appIdToApplicationToProcessMap map collection Key set. */
            Map<Id, HH_Application__c> appIdToApplicationWithRfiMap = new Map<Id, HH_Application__c>(
                    [SELECT Id, (SELECT Id FROM Request_For_Information__r WHERE Status__c =: HH_CONSTANTS.RFI_RFIStatus_Requested
                                    OR Status__c =: HH_CONSTANTS.RFI_RFIStatus_Received)
                    FROM HH_Application__c WHERE Id IN : appIdToApplicationToProcessMap.keySet()]);
            /** Iterating  appIdToApplicationToProcessMap map collection in order to check if there is any Open RFI. */
            for (HH_Application__c hhApplicationToProcess : appIdToApplicationToProcessMap.values()) {
                /** Fetching the Application record with Open RFI from appIdToApplicationWithRfiMap collection. */
                HH_Application__c applicationToProcessWithOpenRfi = appIdToApplicationWithRfiMap?.get(hhApplicationToProcess.Id);
                /** Condition to check if there is any Open RFI exists with the Application. If Yes then throwing Error. */
                if (applicationToProcessWithOpenRfi?.Request_For_Information__r?.size() > 0) {
                    hhApplicationToProcess.addError(System.Label.HH_PendingRFIErrorMessage);
                }
            }
        }
    }

    /***********************************************
    * Method Name : updateRecordOwnerFieldUponInsert
    * Author : Ricky
    * Description: This method is used to update the Owner Name upon Insertion of the Application.
    *********************************************/
    private void updateRecordOwnerFieldUponInsert() {
        for (HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
            applicationToProcess.Owner_Name__c = UserInfo.getName();
        }
    }

    /***********************************************
    * Method Name : checkContractorsBeforeTriPartyAgreementFinalized
    * Author : Ricky
    * Description: This method is used to prevent the User from Updating the Application Status to "Tri Party Agreement Finalized", 
    *              When the Selected Contractors is missing.
    *********************************************/
    private void checkContractorsBeforeTriPartyAgreementFinalized() { 
        /** Map collection to collect the Applications whose Status are updated to Tri Party Agreement Finalized. */
        Map<Id, HH_Application__c> appIdToAppToProcessMap = new Map<Id, HH_Application__c>();
        /** Itearting the Trigger.new Collection in order to check for the Applicatiosn whose Status are updated to Tri Party Agreement Finalized. */
        for(HH_Application__c applicationToProcess : (List<HH_Application__c>) Trigger.new) {
            HH_Application__c oldRecord = (HH_Application__c) Trigger.oldMap.get(applicationToProcess.Id);
            if(oldRecord.Status__c != applicationToProcess.Status__c 
                && applicationToProcess.Status__c == HH_CONSTANTS.HHApplication_Status_TriPartyAgreementFinalized) {
                    appIdToAppToProcessMap.put(applicationToProcess.Id, applicationToProcess);
            }
        } 

        /** Checking for null pointer exception. */
        if(appIdToAppToProcessMap?.size() > 0) {
            /** Fetching teh Application record and its related Contractor records. */
            Map<Id, HH_Application__c> appIdToAppToProcessWithContractorMap = new Map<Id, HH_Application__c>([SELECT Id, Name, 
                                                                (SELECT Id, Name FROM Account_Roles__r WHERE Status__c = 'Active') 
                                                                FROM HH_Application__c WHERE Id IN : appIdToAppToProcessMap.keySet()]);
            
            /** Iterating appIdToAppToProcessMap collection in orderto check for the related Contractor records. */
             for(HH_Application__c applicationToProcess : appIdToAppToProcessMap.values()) {
                List<Account_Role__c> contractors = new List<Account_Role__c>();


                /** Checking the related Contractor records for the Application, If the size is not greater than 0, Then throwing Error.  */
                if(appIdToAppToProcessWithContractorMap?.get(applicationToProcess.Id)?.Account_Roles__r?.size() > 0) {
                    contractors.addAll(appIdToAppToProcessWithContractorMap?.get(applicationToProcess.Id)?.Account_Roles__r);
                } 

                if(!(contractors?.size() > 0)) {
                    applicationToProcess.addError(System.Label.HH_Application_ContractorInfoMissingError);
                } 
            }
        }
    }
}