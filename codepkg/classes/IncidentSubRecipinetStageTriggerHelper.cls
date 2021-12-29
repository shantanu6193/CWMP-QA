/**
 * Created by Neha on 11-03-2021.
 */

public with sharing class IncidentSubRecipinetStageTriggerHelper extends TriggerHelper {
    public override void processAfterInsert() {
        updateIncidentSubRecipientSummaryField();
    }

    /** Ticket - 926 */
    public override void processBeforeUpdate() {
        /** This method is used to update the Obligated State Share Flag value on Summary record,
         * if the Sum of "State Project Award" of all the related Project is greater than or equal to 2500 - then Flag will become green
         * Or else Flag will be updated as Red.
         * Based on the Updated Flag value of the record - It updates the related Project and Award records.*/
        updateObligatedStateShareFlagOnSummaryRecord();
    }

    public override void processAfterUpdate() {
        //updateStateShareFlag();
		/** Ticket No - 563 */
        updateStateShareFlagOfProjectPRAndTR();
        markRelatedProjectToCloseoutUponIncSubJunctionClosed();
    }
    private void updateIncidentSubRecipientSummaryField() {
        Set<Id> subrecipientIds = new Set<Id>();
        Set<Id> incidentIds = new Set<Id>();
        Map<String, Incident_Subrecipient_Stage__c> incidentSubRecipientIdToSummaryRecordMap = new Map<String, Incident_Subrecipient_Stage__c>();
        for (Incident_Subrecipient_Stage__c summaryRecord : (List<Incident_Subrecipient_Stage__c>) Trigger.new) {
            subrecipientIds.add(summaryRecord.Account__c);
            incidentIds.add(summaryRecord.Incident__c);
            String key = (String)summaryRecord.Incident__c + (String)summaryRecord.Account__c;
            incidentSubRecipientIdToSummaryRecordMap.put(key, summaryRecord);
        }

        List<Project__c> projectList = [SELECT Id, Name, Incident_Name__c, Obligating_Sub_Recipient__c, Incident_Subrecipient_Summary__c
                                    FROM Project__c WHERE Obligating_Sub_Recipient__c IN : subrecipientIds AND Incident_Name__c  IN : incidentIds
                                        AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn];
        List<Project__c> projectsToUpdateList = new List<Project__c>();
        Id projectId;
        for (Project__c project : projectList) {
            projectId = project.Id;
            String key = (String)project.Incident_Name__c + (String)project.Obligating_Sub_Recipient__c;
            if (incidentSubRecipientIdToSummaryRecordMap?.get(key) != null) {
                project.Incident_Subrecipient_Summary__c = incidentSubRecipientIdToSummaryRecordMap?.get(key)?.Id;
                projectsToUpdateList.add(project);
            }
        }
        //System.assert(true==false,projectsToUpdateList.size());
        if(projectsToUpdateList.size() > 0) {
            update projectsToUpdateList;
        }
    }

    /*private void updateStateShareFlag() {
        Map<Id, Id> stageIdToSubRecipientId = new Map<Id, Id>(); //To collect the Summary record Id as key and its Sub Recipient Id as value..
        Map<Id, Id> stageIdToIncidentId = new Map<Id, Id>(); //To collect the Summary record Id as key and its Incident Id as value..
        //To collect "Sub Recipient Id + Incident Id" as key and the Summary record Id as value..
        Map<String, Incident_Subrecipient_Stage__c> incidentSubRecipientIdToStageRecord = new Map<String, Incident_Subrecipient_Stage__c>();
        for (Incident_Subrecipient_Stage__c stageRecordToProcess : (List<Incident_Subrecipient_Stage__c>) Trigger.new) {
            Incident_Subrecipient_Stage__c oldRecord = (Incident_Subrecipient_Stage__c) Trigger.oldMap.get(stageRecordToProcess.Id);
            //if (stageRecordToProcess.Cumulative_State_Cost_Share_Flag__c != oldRecord.Cumulative_State_Cost_Share_Flag__c) {
                stageIdToSubRecipientId.put(stageRecordToProcess.Id, stageRecordToProcess.Account__c);
                stageIdToIncidentId.put(stageRecordToProcess.Id, stageRecordToProcess.Incident__c);
                incidentSubRecipientIdToStageRecord.put((String)stageRecordToProcess.Account__c + (String)stageRecordToProcess.Incident__c, stageRecordToProcess);
            //}
        }
        List<String> stageListToAvoid = new List<String>();
        stageListToAvoid.add(ALS_CONSTANTS.PR_Stage_Paid);
        stageListToAvoid.add(ALS_CONSTANTS.PR_Stage_Withdrawn);
        stageListToAvoid.add(ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment);

        //Fetching PRs and its related State Transmittal records in order to update the Flag, which are related to the Summary record......
        Map<Id, Payment_Request__c> prsToProcess = new Map<Id, Payment_Request__c>([SELECT Id, Stage__c , ExpenditurestoDate__c,
                Allow_Admin_Payment__c, Cumulative_State_Cost_Share_Flag__c, ObligatedSubRecipient__c, IncidentName__c, PaymentType__c,
                (SELECT Id, TransmittalType__c , Stage__c, Cumulative_State_Cost_Share_Flag__c FROM Transmittals__r
                WHERE TransmittalType__c =: ALS_CONSTANTS.Transmittal_Type_State)
        FROM Payment_Request__c WHERE ObligatedSubRecipient__c IN : stageIdToSubRecipientId.values()
        AND IncidentName__c IN : stageIdToIncidentId.values()
                AND Stage__c NOT IN  : stageListToAvoid
                AND Project__r.Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn]);

        List<Payment_Request__c> prsToUpdate = new List<Payment_Request__c>(); //To collect the PR whose flag are to be updated....
        List<Transmittal__c> transmittalsToUpdate = new List<Transmittal__c>(); //To collect the Transmittal whose flag are to be updated....
        //To collect the Transmittal which are needed to be sent for Approval once the Flag changed to Green...
        List<Transmittal__c> transmittalsToSendForApproval = new List<Transmittal__c>();
        List<Id> prIdToUnLock = new List<Id>(); //To collect the PR Id which are locked in order to unlock before updating the Flag....
        List<Id> transmittalIdsToUnlock = new List<Id>(); //To collect the Transmittal Id which are locked in order to unlock before updating the Flag....
        for (Payment_Request__c prToProcess : prsToProcess.values()) {
            String key = (String)prToProcess.ObligatedSubRecipient__c + (String)prToProcess.IncidentName__c;
            //List<Payment_Request__c> prs = new List<Payment_Request__c>();
//            if (incidentSubRecipientIdToStageRecord.containsKey(key)
//                    && prToProcess.ExpenditurestoDate__c == 0
//                    && prToProcess.Allow_Admin_Payment__c == true
//                    && prToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement) {
//                if (!Approval.isLocked(prToProcess.Id)) {
//                    prToProcess.Cumulative_State_Cost_Share_Flag__c = true;
//                    prsToUpdate.add(prToProcess);
//                }
//            }
            //Condition to check if the Summary record exists in the Map collection...
            if (incidentSubRecipientIdToStageRecord.containsKey(key)) {
                Incident_Subrecipient_Stage__c stageRecord = incidentSubRecipientIdToStageRecord.get(key); //Fetching the Summary record from map collection...
                //Condition to check if the PR is Locked and PR's Flag and Summary Record's Flag matches, If it is already matches then no need to updated the PR Flag....
                if (Approval.isLocked(prToProcess.Id) && prToProcess.Cumulative_State_Cost_Share_Flag__c != stageRecord.Cumulative_State_Cost_Share_Flag__c) {
                    prIdToUnLock.add(prToProcess.Id); //Adding the PR Id to collection in order to unlock it before Updating the Flag...
                    prToProcess.Cumulative_State_Cost_Share_Flag__c = stageRecord.Cumulative_State_Cost_Share_Flag__c; //Updating PR Flag...
                    prsToUpdate.add(prToProcess); //Adding PR record to collection to updated it...
                }
                //Condition to check if the PR's Flag and Summary Record's Flag matches, If it is already matches then no need to updated the PR Flag....
                else if(prToProcess.Cumulative_State_Cost_Share_Flag__c != stageRecord.Cumulative_State_Cost_Share_Flag__c) {
                    prToProcess.Cumulative_State_Cost_Share_Flag__c = stageRecord.Cumulative_State_Cost_Share_Flag__c; //Updating PR Flag...
                    prsToUpdate.add(prToProcess); //Adding PR record to collection to updated it...
                }

                //Condition to check if the Transmittal is Locked and Transmittal's Flag and Summary Record's Flag matches, If it is already matches then no need to updated the Transmittal Flag....
                if (prToProcess?.Transmittals__r?.size() == 1 && Approval.isLocked(prToProcess.Transmittals__r[0].Id)
                        && prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c != stageRecord.Cumulative_State_Cost_Share_Flag__c) {
                    transmittalIdsToUnlock.add(prToProcess.Transmittals__r[0].Id); //To add the Transmittal Id to collection for unlocking...
                    prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c = stageRecord.Cumulative_State_Cost_Share_Flag__c; //Updating the Flag value...
                    transmittalsToUpdate.add(prToProcess.Transmittals__r[0]); //Adding transmittal record to update in collecton..
                }
                //Condition to check if the Transmittal is Locked and Transmittal's Flag and Summary Record's Flag matches, If it is already matches then no need to updated the Transmittal Flag....
                else if (prToProcess?.Transmittals__r?.size() == 1 && !Approval.isLocked(prToProcess.Transmittals__r[0].Id)
                        && prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c != stageRecord.Cumulative_State_Cost_Share_Flag__c) {
                    prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c = stageRecord.Cumulative_State_Cost_Share_Flag__c; //updating Cumulative State Cost Share Flag value of Transmittal...
                    //Condition to check if the Flag is Green, then we need to put the Transmittal in new Stage...
                    if (prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c == true) {
                        prToProcess.Transmittals__r[0].Stage__c = ALS_CONSTANTS.Stage_New; //To Set the Stage if the Flag value if true.....
                    }
                    //Condition to check if the Flag is Red, then we need to put the Transmittal in "On Hold" Stage...
                    else if (prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c == false) {
                        prToProcess.Transmittals__r[0].Stage__c = ALS_CONSTANTS.Transmittal_Stage_OnHold; //To Set the Stage if the Flag value if False.....
                    }
                    //Condition to check if the PR stage is "Payment Processing" and PR Flag is Green, In order to send the Transmittal for Approval...
                    if (prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                            && prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c == true) {
                        transmittalsToSendForApproval.add(prToProcess.Transmittals__r[0]); //To send the Transmittals for Approval...
                    }
                    transmittalsToUpdate.add(prToProcess.Transmittals__r[0]); //Adding Transmittal record to collection for updating...
                }
            }
        }
        //Checking null pointer exception for the PR collection to update...
        if (prsToUpdate.size() > 0) {
            RecordLockUnlockClass lockUnlockRecords = new RecordLockUnlockClass();
            lockUnlockRecords.unlockRecord(prIdToUnLock);
            update prsToUpdate; //Updating the PRs...
            lockUnlockRecords.lockRecord(prIdToUnLock);
//            IncidentSubRecipinetStageTriggerHelper.InnerClassforUnlockingAndLocking ic =
//                    new IncidentSubRecipinetStageTriggerHelper.InnerClassforUnlockingAndLocking();
//            ic.unlockRecords(prIdToUnLock); //Unlocking the Locked PRs before updating....
//            update prsToUpdate; //Updating the PRs...
//            ic.lockRecords(prIdToUnLock); //Locking the PRs back after updating...
        }
        //Checking null pointer exception for the Transmittal collection to update...
        if (transmittalsToUpdate.size() > 0) {
            RecordLockUnlockClass lockUnlockRecords = new RecordLockUnlockClass();
            lockUnlockRecords.unlockRecord(transmittalIdsToUnlock);
            update transmittalsToUpdate; //Updating the PRs...
            lockUnlockRecords.lockRecord(transmittalIdsToUnlock);

//            IncidentSubRecipinetStageTriggerHelper.InnerClassforUnlockingAndLocking ic =
//                    new IncidentSubRecipinetStageTriggerHelper.InnerClassforUnlockingAndLocking();
//            ic.unlockRecords(transmittalIdsToUnlock); //Unlocking the Locked Transmittal before updating....
//            update transmittalsToUpdate; //Updating the Transmittal...
//            ic.lockRecords(transmittalIdsToUnlock); //Locking the Transmittal back after updating...
        }
        //Checking for null pointer exception for the Transmittal collection to send for Approval...
        if (transmittalsToSendForApproval.size() > 0) {
            ALS_TransmittalUtiity.submitForApproval(transmittalsToSendForApproval); //Submitting the Transmittal for Approval after Flag change...
        }
    }*/

    /** Ticket No - 382 - Start */
    /*********************************************
     * Method Name : markRelatedProjectToCloseoutUponIncSubJunctionClosed
     * Called From Method : Process After Update
     * Author : Ricky
     * Inputs : -
     * Description: This method is used to update all the related Project stage to closeout upon Incident Sub Recipient Stage is marked "Closed".
     *********************************************/
    private void markRelatedProjectToCloseoutUponIncSubJunctionClosed() {
        /** To collect the Incodent Sub Recipient record, hose Stage has been moved to Closed Stage. */
        Map<Id, Incident_Subrecipient_Stage__c> summaryIdToSummaryRecordMap = new Map<Id, Incident_Subrecipient_Stage__c>();
        for (Incident_Subrecipient_Stage__c summaryRecordToProcess : (List<Incident_Subrecipient_Stage__c>) Trigger.new) {
            /** Fetching old Summary record in order to compare the Stage. */
            Incident_Subrecipient_Stage__c oldRecord = (Incident_Subrecipient_Stage__c) Trigger.oldMap.get(summaryRecordToProcess.Id);
            /** Condition to compare that the Summary record Stage is changed to "Closed". */
            if (summaryRecordToProcess.Stage__c != oldRecord.Stage__c
                    && summaryRecordToProcess.Stage__c == ALS_CONSTANTS.Summary_Stage_Closed) {
                summaryIdToSummaryRecordMap.put(summaryRecordToProcess.Id, summaryRecordToProcess);
            }
        }

        if (summaryIdToSummaryRecordMap?.size() > 0) {
            /** Fetching the related Projects of the Summary record. */
            Map<Id, Project__c> projectIdToProjectRecordMap = new Map<Id, Project__c>([SELECT Id, Name, Stage__c, Incident_Subrecipient_Summary__c
                                                FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIdToSummaryRecordMap.keySet()]);
            /** To collect the Projects which stage needs to be Updated.
             * This list is made seperately in order to avoid updating the Project which are already in Closeout Stage. */
            List<Project__c> projectToUpdateList = new List<Project__c>();
            if (projectIdToProjectRecordMap?.size() > 0) {
                for (Project__c projectToProcess : projectIdToProjectRecordMap.values()) {
                    if (projectToProcess.Stage__c != ALS_CONSTANTS.Project_Stage_Closeout) {
                        projectToProcess.Stage__c = ALS_CONSTANTS.Project_Stage_Closeout;
                        projectToUpdateList.add(projectToProcess);
                    }
                }
                /** Updating the Project records to Closeout Stage. */
                if (projectToUpdateList?.size() > 0) {
                    update projectToUpdateList;
                }
            }
        }
    }
    /** Ticket No - 382 - End */

    /** Ticket No - 563 - Start */
    /*********************************************
     * Method Name : updateStateShareFlagOfProjectPRAndTR
     * Called From Method : ProcessAfterUpdate
     * Author : Ricky
     * Inputs : -
     * Description: This method is used to update the State Cost Share Flag on Project and its related PR and State TR.
     *              Send the State TR for Approval when the Flag changes from Red to Green and PR is in Payment Processing Stage.
     *********************************************/
    private void updateStateShareFlagOfProjectPRAndTR() {
        /** Map collection to collect the Incident Sub Recipient Summary record which is been updated. */
        Map<Id, Incident_Subrecipient_Stage__c> summaryIdToSummaryRecordMap = new Map<Id, Incident_Subrecipient_Stage__c>();
        for (Incident_Subrecipient_Stage__c summary : (List<Incident_Subrecipient_Stage__c>) Trigger.new) {
            summaryIdToSummaryRecordMap.put(summary.Id, summary);
        }
        if (summaryIdToSummaryRecordMap?.size() > 0) {
            List<Payment_Request__c> prToUpdateList = new List<Payment_Request__c>(); /** To collect the Payment Request to Update. */
            List<Transmittal__c> trToUpdateList = new List<Transmittal__c>(); /** To collect the State Transmittal to Update. */
            Set<Id> prToUnlockIds = new Set<Id>(); /** To collect the Payment Request to Unlock before Updating it. */
            Set<Id> trToUnlockIds = new Set<Id>(); /** To collect the Transmittal to Unlock before Updating it. */
            List<Transmittal__c> transmittalsToSendForApproval = new List<Transmittal__c>(); /** To collect the State Transmittal to send for Approval. */
            /** Fetching all the Projects, which are related to the Summary record which got updated.
             * Exception for Project Stage - Withdrawn*/
            List<Project__c> projectToProcessList = [SELECT Id, Stage__c, Cumulative_State_Cost_Share_Flag__c, Incident_Subrecipient_Summary__c FROM Project__c
                                                        WHERE Incident_Subrecipient_Summary__c IN : summaryIdToSummaryRecordMap.keySet()
                                                        AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn];
            if (projectToProcessList?.size() > 0) {
                /** Updating the State Cost Share Flag of Project. */
                for (Project__c project : projectToProcessList) {
                    Incident_Subrecipient_Stage__c summaryRecord = summaryIdToSummaryRecordMap.get(project.Incident_Subrecipient_Summary__c);
                    project.Cumulative_State_Cost_Share_Flag__c = summaryRecord.Cumulative_State_Cost_Share_Flag__c;
                }

                /** Fetching all the Payment Requests and its related State Transmittal, whose Project are related to the Summary record.
                 * Exception for PR Stage - Withdrawn, Paid, Returned Project Payment
                 * Exception for Project Stage - Withdrawn*/
                List<Payment_Request__c> paymentRequestToProcessList = [SELECT Id, Project__r.Incident_Subrecipient_Summary__c,
                                                    Cumulative_State_Cost_Share_Flag__c, Stage__c,
                                                        (SELECT Id, Stage__c, Cumulative_State_Cost_Share_Flag__c FROM Transmittals__r
                                                        WHERE TransmittalType__c =: ALS_CONSTANTS.Transmittal_Type_State LIMIT 1)
                                                    FROM Payment_Request__c
                                                    WHERE Project__r.Incident_Subrecipient_Summary__c IN : summaryIdToSummaryRecordMap.keySet()
                                                    AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                    AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Paid
                                                    AND Stage__c !=: ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                                                    AND Project__r.Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn];
                /** Checking for null pointer Exception for the PR collection Which has been fetched. */
                if (paymentRequestToProcessList?.size() > 0) {
                    for (Payment_Request__c prToProcess : paymentRequestToProcessList) {
                        Incident_Subrecipient_Stage__c summaryRecord = summaryIdToSummaryRecordMap.get(prToProcess.Project__r.Incident_Subrecipient_Summary__c);
                        /** Updating PR Record Flag values. */
                        if (Approval.isLocked(prToProcess.Id)
                                && prToProcess.Cumulative_State_Cost_Share_Flag__c != summaryRecord.Cumulative_State_Cost_Share_Flag__c) {
                            prToUnlockIds.add(prToProcess.Id);
                            prToProcess.Cumulative_State_Cost_Share_Flag__c = summaryRecord.Cumulative_State_Cost_Share_Flag__c;
                            prToUpdateList.add(prToProcess);
                        }
                        else if(prToProcess.Cumulative_State_Cost_Share_Flag__c != summaryRecord.Cumulative_State_Cost_Share_Flag__c) {
                            prToProcess.Cumulative_State_Cost_Share_Flag__c = summaryRecord.Cumulative_State_Cost_Share_Flag__c;
                            prToUpdateList.add(prToProcess);
                        }
                        /** Updating TR Record Flag values. */
                        if (prToProcess.Transmittals__r?.size() == 1) {
                            Transmittal__c trToProcess = prToProcess.Transmittals__r[0];
                            if (Approval.isLocked(trToProcess.Id) && trToProcess.Cumulative_State_Cost_Share_Flag__c != summaryRecord.Cumulative_State_Cost_Share_Flag__c) {
                                trToUnlockIds.add(trToProcess.Id);
                                trToProcess.Cumulative_State_Cost_Share_Flag__c = summaryRecord.Cumulative_State_Cost_Share_Flag__c;
                                trToUpdateList.add(trToProcess);
                            }
                            else if(trToProcess.Cumulative_State_Cost_Share_Flag__c != summaryRecord.Cumulative_State_Cost_Share_Flag__c) {
                                trToProcess.Cumulative_State_Cost_Share_Flag__c = summaryRecord.Cumulative_State_Cost_Share_Flag__c;
                                if (trToProcess.Cumulative_State_Cost_Share_Flag__c == true) {
                                    trToProcess.Stage__c = ALS_CONSTANTS.Stage_New;
                                }
                                else if (trToProcess.Cumulative_State_Cost_Share_Flag__c == false) {
                                    trToProcess.Stage__c = ALS_CONSTANTS.Transmittal_Stage_OnHold;
                                }
                                /** Collecting the TR to send for Approval upon Flag change. */
                                if (prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                                        && prToProcess.Transmittals__r[0].Cumulative_State_Cost_Share_Flag__c == true) {
                                    transmittalsToSendForApproval.add(prToProcess.Transmittals__r[0]);
                                }
                                trToUpdateList.add(trToProcess);
                            }
                        }
                    }
                }

                update projectToProcessList; /** Updating the Project record. */
                if (prToUpdateList?.size() > 0) { /** Updating the Payment Request record. */
                    if (prToUnlockIds?.size() > 0) {
                        List<Id> prIdsToUnlock = new List<Id>();
                        prIdsToUnlock.addAll(prToUnlockIds);
                        RecordLockUnlockClass recordLockUnlock = new RecordLockUnlockClass();
                        recordLockUnlock.unlockRecord(prIdsToUnlock);
                        update prToUpdateList;
                        recordLockUnlock.lockRecord(prIdsToUnlock);
                    }
                    else {
                        update prToUpdateList;
                    }
                }
                if (trToUpdateList?.size() > 0) { /** Updating the Transmittal record. */
                    if (trToUnlockIds?.size() > 0) {
                        List<Id> trIdsToUnlock = new List<Id>();
                        trIdsToUnlock.addAll(trToUnlockIds);
                        RecordLockUnlockClass recordLockUnlock = new RecordLockUnlockClass();
                        recordLockUnlock.unlockRecord(trIdsToUnlock);
                        update trToUpdateList;
                        recordLockUnlock.lockRecord(trIdsToUnlock);
                    }
                    else {
                        update trToUpdateList;
                    }
                }
                if (transmittalsToSendForApproval?.size() > 0) { /** Sending State Tr for Approval upon Flag changed to true. */
                    ALS_TransmittalUtiity.submitForApproval(transmittalsToSendForApproval);
                }
            }
        }
    }
    /** Ticket No - 563 - End */
    
    /** Ticket - 926 - Start */
    /*********************************************
     * Method Name : updateObligatedStateShareFlagOnSummaryRecord
     * Called From Method : ProcessBeforeUpdate
     * Author : Ricky
     * Inputs : -
     * Description: This method is used to update the Obligated State Share Flag value on Summary record,
    *               if the Sum of "State Project Award" of all the related Project is greater than or equal to 2500 - then Flag will become green
    *               Or else Flag will be updated as Red.
     *********************************************/
    private void updateObligatedStateShareFlagOnSummaryRecord() {
        // Map collection to collect the Summary records whose "Total State Amount Obligated" getting changed
        // and "Obligated State Share Flag" is getting Updated..
        Map<Id, Incident_Subrecipient_Stage__c> summaryIdToSummaryRecordMap = new Map<Id, Incident_Subrecipient_Stage__c>();
        // Iterating the Trigger.new Collection to check if the "Total State Amount Obligated" field value is getting changed.
        for(Incident_Subrecipient_Stage__c summary : (List<Incident_Subrecipient_Stage__c>) Trigger.new) {
            Incident_Subrecipient_Stage__c oldRecord = (Incident_Subrecipient_Stage__c) Trigger.oldMap.get(summary.Id);

            if (oldRecord.Total_State_Amount_Obligated__c != summary.Total_State_Amount_Obligated__c) {
                Decimal stateShare = summary.Total_State_Amount_Obligated__c == null ? 0.00 : summary.Total_State_Amount_Obligated__c;
                // Condition to update the Falg -
                // If the "Total State Amount Obligated" field value is greater than or equal to 2500, Then Flag value will be set to true.
                // Or else Flag value will be Set to false.
                if (stateShare >= 2500) {
                    summary.Obligated_State_Share__c = true;
                }
                else {
                    summary.Obligated_State_Share__c = false;
                }
                summaryIdToSummaryRecordMap.put(summary.Id, summary);
            }
        }
        // Checking for null pointer exception for summaryIdToSummaryRecordMap collection,
        // In order to update the Flag of related Projects an Award records.
        if (summaryIdToSummaryRecordMap?.size() > 0) {
            updateObligatedStateShareFlagOnProjectAndAward(summaryIdToSummaryRecordMap);
        }
    }

    /*********************************************
     * Method Name : updateObligatedStateShareFlagOnProjectAndAward
     * Called From Method : updateObligatedStateShareFlagOnSummaryRecord
     * Author : Ricky
     * Inputs : -
     * Description: This method is used to update the Obligated State Share Flag value on related Project and its Award records,
    *               if the Sum of "State Project Award" of all the related Project is greater than or equal to 2500 - then Flag will become green
    *               Or else Flag will be updated as Red.
     *********************************************/
    private void updateObligatedStateShareFlagOnProjectAndAward(Map<Id, Incident_Subrecipient_Stage__c> summaryIdToSummaryRecordMap) {
        // Collection to collect the Project records on which "Obligated State Share Flag" value needs to be updated.
        List<Project__c> projectToUpdateList = new List<Project__c>();
        // Collection to collect the Award records on which "Obligated State Share Flag" value needs to be updated.
        List<Award__c> awardToUpdateList = new List<Award__c>();
        // Fetching the Project and its related Award records in order to update the "Obligated State Share Flag" value.
        List<Project__c> projectWithRelatedAwardsList = [SELECT Id, Name, Incident_Subrecipient_Summary__c, Obligated_State_Share__c,
                                                    (SELECT Id, Name, Obligated_State_Share__c FROM Awards__r)
                                                FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIdToSummaryRecordMap.keySet()
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn];
        if (projectWithRelatedAwardsList?.size() > 0) {
            for (Project__c projectRecordToUpdate : projectWithRelatedAwardsList) {
                Incident_Subrecipient_Stage__c summaryRecord = summaryIdToSummaryRecordMap.get(projectRecordToUpdate?.Incident_Subrecipient_Summary__c);
                // Condition to check if the Project record's "Obligated State Share Flag" value doesn't match with Summary,
                // Then update the "Obligated State Share Flag" value on Project record.
                if (projectRecordToUpdate.Obligated_State_Share__c != summaryRecord.Obligated_State_Share__c) {
                    projectRecordToUpdate.Obligated_State_Share__c = summaryRecord.Obligated_State_Share__c;
                    projectToUpdateList.add(projectRecordToUpdate);
                }
                // Condition to check if the Project record's related Award record's "Obligated State Share Flag" value doesn't match with Summary,
                // Then update the "Obligated State Share Flag" value on Award record.
                if (projectRecordToUpdate?.Awards__r?.size() > 0) {
                    for(Award__c awardRecordToUpdate : projectRecordToUpdate?.Awards__r) {
                        if(awardRecordToUpdate.Obligated_State_Share__c != summaryRecord.Obligated_State_Share__c) {
                            awardRecordToUpdate.Obligated_State_Share__c = summaryRecord.Obligated_State_Share__c;
                            awardToUpdateList.add(awardRecordToUpdate);
                        }
                    }
                }
            }
            //System.assert(true==false, '*************** 342 Inc Sub Helper ************* '+awardToUpdateList.size());
            // Checking for null pointer exception for projectToUpdateList collection to update it.
            if (projectToUpdateList?.size() > 0) {
                update projectToUpdateList;
            }
            // Checking for null pointer exception for awardToUpdateList collection to update it.
            if (awardToUpdateList?.size() > 0) {
                update awardToUpdateList;
            }
        }
        }
    /** Ticket - 926 - End */
}