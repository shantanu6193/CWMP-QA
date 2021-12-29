/*********************************************
 * Class Name : ALS_TransmittalUtilityInnerClass
 * Called From Method : Payment Request trigger Helper - createTransmittalRecord, ALS Transmittal creation FLow
 * Author : Neha
 * Description: This class is used to create the Transmittal record for PR/Summary object record
 *              and Sending the PR's Transmittal fpr Approval upon PR approval from Manager.
 *********************************************/
public with sharing class ALS_TransmittalUtiity {
    /*********************************************
	* Method Name : submitForApproval
	* Author : Neha
	* Inputs : - 1.List<Transmittal__c> transmittalList -
	* Description: This method is used send the Transmittal record for Approval.
	*********************************************/
    public static void  submitForApproval(List<Transmittal__c> transmittalList)
    {
        /** Fetching the Accounting Queue record data in order to change the Owner of Transmittal to Accounting
         * to make the Transmittal record visible for Accounting user. */
        Group queueData = [SELECT Id, Name,DeveloperName FROM Group WHERE Type=:ALS_CONSTANTS.Queue_Type AND DeveloperName =: ALS_CONSTANTS.Queue_API_Name];
        if (queueData == null) {
            new AuraHandledException('Transmittals_Accounting_Team Queue does not exist. ');
        }
        List<Transmittal__c> transmittalToChangeOwner = new List<Transmittal__c>(); /** To collect the Transmittal record to change Owner */
        for(Transmittal__c transmittalToProcess : transmittalList) {
            /** Fetching the Pending Approvals of the current Transmittal record, if any */
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :transmittalToProcess.Id
            AND ProcessInstance.Status =: ALS_CONSTANTS.Status_Pending];

            /** Checking for the size of Process Instance Work Items on this Transmittal record,
             * If there isn't  any then changing the owner of the transmittal record. */
            if(piWorkItems?.size() == 0) {
                transmittalToProcess.OwnerId = queueData.Id;
                transmittalToChangeOwner.add(transmittalToProcess);
            }
        }
        
        /** Updating the Transmittal record Owner */
        if (transmittalToChangeOwner.size() > 0) {
            update transmittalToChangeOwner;
        }
        
        for(Transmittal__c transmittalToProcess : transmittalList) {
            /** Fetching the Pending Approvals of the current Transmittal record, if any */
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :transmittalToProcess.Id
            AND ProcessInstance.Status =: ALS_CONSTANTS.Status_Pending];
            /** Checking for the size of Process Instance Work Items on this Transmittal record,
             * If there isn't  any, then creating Approval request for the transmittal. */
            if(piWorkItems?.size() == 0) {
                /** Create an approval request for the Transmittal__c */
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments('Submitting request for approval');
                request.setObjectId(transmittalToProcess.Id);
                request.setProcessDefinitionNameOrId('Transmittals_Accounting_Approval');
                /** Submit the approval request for the Transmittal__c */
                if(transmittalToProcess.Stage__c == ALS_CONSTANTS.Stage_New
                        || transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected) {
                    Approval.ProcessResult result = Approval.process(request);
                }
                /*if ((transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_State && transmittalToProcess.Stage__c != ALS_CONSTANTS.Transmittal_Stage_OnHold) || transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_Federal) {
                    Approval.ProcessResult result = Approval.process(request);
                }*/
            }
        }
    }

    /*********************************************
	* Method Name : createTransmittalRecord
	* Called from Method -
	* Author : Neha
	* Inputs : - 1. List<Id> paymantToProcessIds - PR Ids on which the TR needs to be created
	* Description: This method is used create the Transmittal record for Payment Request/Incident Sub Recipient Summary reocrd.
	*********************************************/
    @InvocableMethod
    public static void createTransmittalRecord(List<Id> paymantToProcessIds) {
        Set<Id> paymentRequestIds = new Set<Id>(); /** To collect the PR Id from paymantToProcessIds collection variable */
        Set<Id> summaryRecordIds = new Set<Id>(); /** To collect the summary record Id from paymantToProcessIds collection variable */
        /** Iterating paymantToProcessIds collection to divide the PR Id and Summary record Id Bases on the Object API name */
        for (Id idToProcess : paymantToProcessIds) {
            if (idToProcess.getSobjectType().getDescribe().getName() == ALS_CONSTANTS.PR_ObjectAPIName) {
                paymentRequestIds.add(idToProcess);
            }
            else if (idToProcess.getSobjectType().getDescribe().getName() == ALS_CONSTANTS.Summary_ObjectAPIName) {
                summaryRecordIds.add(idToProcess);
            }
        }

        /** Processing PR Ids for Transmittal creation/Submission for Approval */
        if (paymentRequestIds.size() > 0) {
            List<Transmittal__c> transmittalToInsertList = new List<Transmittal__c>(); /** To collect the Transmittal to insert */
            List<Transmittal__c> transmittalToApproveList = new List<Transmittal__c>(); /** To collect the Transmittal to send for Approval */
            Map<Id, Payment_Request__c> paymentRequestRecordMap = new Map<Id, Payment_Request__c>(); /** To Fetch the PR and its related TRs */

            /** Calling the Inner class to fetch the PR an its related TRs in System context(Without Sharing) */
            ALS_TransmittalUtilityInnerClass queryPrs = new ALS_TransmittalUtilityInnerClass();
            paymentRequestRecordMap = queryPrs.QueryPaymentRequest(paymentRequestIds);

            System.debug('paymentRequestRecordMap = ' + paymentRequestRecordMap.size());
            for (Payment_Request__c paymentUnderProcessing : paymentRequestRecordMap.values()){
                /** Condition 1 - To check if the there is no any TR available for this PR
                 * Condition 2 - To check if the User has create permission on Transmittal object */
                if (paymentUnderProcessing.Transmittals__r?.size() == 0 && Schema.SObjectType.Transmittal__c.isCreateable()) {
                    /** Condition 1 - To check if The Project Funding Source is Federal and State/State Only in order to create State transmittal
                     * Condition 2.1 - To check if the Approved State Payment Amount is greater than 0 on PR
                     *                  in order to avoid creation of TR for 0 Amount.
                     * Condition 2.2 - To chek the Payment Type of PR if the Approved State Payment Amount is less than 0
                     *                  in order to allow creation of TR when PR Type is Offset or Returned Project Payment.*/
                    if ((paymentUnderProcessing.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                                || paymentUnderProcessing.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly)
                            && (paymentUnderProcessing.ApprovedStatePaymentAmount__c > 0
                                || (paymentUnderProcessing.ApprovedStatePaymentAmount__c < 0
                                    && (paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                                        ||paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)))) {
                        /** Calling a method to create State transmittal record */
                        Transmittal__c stateTransmittal = createStateTransmittalForPaymentRequest(paymentUnderProcessing);
                        if(stateTransmittal != null) {
                            transmittalToInsertList.add(stateTransmittal);
                        }
                    }
                    /** Condition 1 - To check if The Project Funding Source is Federal and State/Federal Only in order to create Federal transmittal
                     * Condition 2.1 - To check if the Approved Federal Payment Amount is greater than 0 on PR
                     *                  in order to avoid creation of TR for 0 Amount.
                     * Condition 2.2 - To chek the Payment Type of PR if the Approved Federal Payment Amount is less than 0
                     *                  in order to allow creation of TR when PR Type is Offset or Returned Project Payment.*/
                    if ((paymentUnderProcessing.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                                || paymentUnderProcessing.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly)
                            && (paymentUnderProcessing.ApprovedFederalPaymentAmount__c > 0
                                || (paymentUnderProcessing.ApprovedFederalPaymentAmount__c < 0
                                    && (paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                                        ||paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)))) {

                        /** Calling a method to create Federal transmittal record */
                        Transmittal__c federalTransmittal = createFederalTransmittalForPaymentRequest(paymentUnderProcessing);
                        if(federalTransmittal != null) {
                        transmittalToInsertList.add(federalTransmittal);
                    }
                    }

                    /** Condition 1 - to check for PR stage in order to send the TR for Approval.
                     * Condition 2 - To check if the Approved State/Federal payment Amount is +ve on PR
                     * as we do not need to send the -ve Amount Trs for Approval*/
                    /*if(paymentUnderProcessing.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                            && ((paymentUnderProcessing.ApprovedFederalPaymentAmount__c > 0
                                    || (paymentUnderProcessing.ApprovedFederalPaymentAmount__c < 0
                                        && paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment))
                                || paymentUnderProcessing.ApprovedStatePaymentAmount__c > 0
                                    || (paymentUnderProcessing.ApprovedStatePaymentAmount__c < 0
                                        && paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment))) {
                        transmittalToApproveList.addAll(transmittalToInsertList);
                    }*/
                    if(paymentUnderProcessing.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                            && (paymentUnderProcessing.ApprovedFederalPaymentAmount__c > 0
                                || paymentUnderProcessing.ApprovedStatePaymentAmount__c > 0)) {
                        transmittalToApproveList.addAll(transmittalToInsertList);
                    }
                }
                /** Condition 1 - To Check if the Transmittal records are already available for PR
                 * Condition 2 - To check PR Stage is "Payment Processing"
                 * Condition 3 - To check if the Approved State/Federal payment Amount is +ve on PR
                 * as we do not need to send the -ve Amount Trs for Approval
                 * When the PR's Stage is in other than New/Processing/In Review/Reviewed Need More information,
                 * "Generate Transmittal" button should not be visible.*/
                else if (paymentUnderProcessing.Transmittals__r?.size() > 0
                        && paymentUnderProcessing.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing) {
                    /*if ((paymentUnderProcessing.ApprovedFederalPaymentAmount__c > 0
                                || (paymentUnderProcessing.ApprovedFederalPaymentAmount__c < 0
                                    && paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment))
                            || paymentUnderProcessing.ApprovedStatePaymentAmount__c > 0
                                || (paymentUnderProcessing.ApprovedStatePaymentAmount__c < 0
                                    && paymentUnderProcessing.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)) {
                        transmittalToApproveList.addAll(paymentUnderProcessing.Transmittals__r);
                    }*/
                    if(paymentUnderProcessing.ApprovedFederalPaymentAmount__c > 0
                            || paymentUnderProcessing.ApprovedStatePaymentAmount__c > 0) {
                    transmittalToApproveList.addAll(paymentUnderProcessing.Transmittals__r);
                    }
                }
                /** Condition to check if the TRs are already available on PR in order to show exception in  Flow*/
                else if(paymentUnderProcessing.Transmittals__r?.size() > 0)
                {
                    throw new AuraHandledException('Transmittal already Exists');
                }
                /** Condition to check if the User does not have create Permission on Transmittal in order to show exception in Flow*/
                else if (!Schema.SObjectType.Transmittal__c.isCreateable()) {
                    throw new AuraHandledException('You dont have create permission.');
            }
            }
            /** Inserting the TR records */
            if(transmittalToInsertList.size() > 0){
                insert transmittalToInsertList;
            }
            /** Submitting the Trs for Approval */
            if(transmittalToApproveList.size() > 0){
                submitForApproval(transmittalToApproveList);
            }
        }

        /** Processing Summary record Ids for Transmittal creation. */
        if (summaryRecordIds.size() > 0)  {
            /** Fetching the Incident Sub Recipient Stage record and its related Transmittals */
            Map<Id, Incident_Subrecipient_Stage__c> idToSummaryRecordMap = new Map<Id, Incident_Subrecipient_Stage__c>([SELECT Id,
                            Incident__r.Declaration_Number__c, Available_Federal_Amount__c, Incident__c, Account__c , Account__r.Sub_Recipient_FIPS__c,
                            Available_State_Admin_Amount__c, Cumulative_State_Cost_Share_Flag__c, Available_State_Amount__c,
                        (SELECT Id FROM Transmittals__r) FROM Incident_Subrecipient_Stage__c WHERE Id IN : summaryRecordIds]);
            List<Transmittal__c> transmittalToInsert = new List<Transmittal__c>(); /** To collect the Transmittals to insert */
            for (Incident_Subrecipient_Stage__c summaryRecordToProcess : idToSummaryRecordMap.values()) {
                /** Condition 1 - To check if the there is no any TR available for this Summary record */
                if (summaryRecordToProcess.Transmittals__r?.size() == 0) {
                    /** Condition to check if the Available State Amount/Available Admin Amount is greater than 0 */
                    if (summaryRecordToProcess.Available_State_Amount__c > 0
                            || summaryRecordToProcess.Available_State_Admin_Amount__c > 0) {
                        /** Creating State Transmittal */
                        Transmittal__c transToInsertState =  new Transmittal__c();
                        transToInsertState.Incident_Subrecipient_Summary__c = summaryRecordToProcess.Id;
                        transToInsertState.TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_State;
                        transToInsertState.Admin_Share_Amount__c = summaryRecordToProcess.Available_State_Admin_Amount__c;
                        transToInsertState.ApprovedAmount__c = summaryRecordToProcess.Available_State_Amount__c + summaryRecordToProcess.Available_State_Admin_Amount__c;
                        transToInsertState.Amount_Available__c = summaryRecordToProcess.Available_State_Amount__c;
                        transToInsertState.ApplicantName__c = summaryRecordToProcess.Account__c;
                        transToInsertState.ApplicantNumber__c = summaryRecordToProcess.Account__r.Sub_Recipient_FIPS__c;
                        transToInsertState.IncidentProjectNumber__c = summaryRecordToProcess.Incident__r.Declaration_Number__c;
                        transToInsertState.Cumulative_State_Cost_Share_Flag__c = summaryRecordToProcess.Cumulative_State_Cost_Share_Flag__c;
                        transmittalToInsert.add(transToInsertState);
                    }
                    /** Condition to check if the Available Federal Amount Amount is greater than 0 */
                    if (summaryRecordToProcess.Available_Federal_Amount__c > 0) {
                        /** Creating Federal Transmittal */
                        Transmittal__c transToInsertFederal =  new Transmittal__c();
                        transToInsertFederal.Incident_Subrecipient_Summary__c = summaryRecordToProcess.Id;
                        transToInsertFederal.TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal;
                        transToInsertFederal.ApprovedAmount__c = summaryRecordToProcess.Available_Federal_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                        transToInsertFederal.Amount_Available__c = summaryRecordToProcess.Available_Federal_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                        transToInsertFederal.ApplicantName__c = summaryRecordToProcess.Account__c;
                        transToInsertFederal.ApplicantNumber__c = summaryRecordToProcess.Account__r.Sub_Recipient_FIPS__c;
                        transToInsertFederal.IncidentProjectNumber__c = summaryRecordToProcess.Incident__r.Declaration_Number__c;
                        transmittalToInsert.add(transToInsertFederal);
                    }
                }
            }
            /** Inserting the Transmittal records */
            if (transmittalToInsert.size() > 0) {
                insert transmittalToInsert;
            }
        }
    }

    /*********************************************
     *  Method Name : createStateTransmittalForPaymentRequest
     * Called From Method : createTransmittalRecord
     * Author : Ricky
     * Inputs : - 1. Payment_Request__c paymentUnderProcessing - Payment request record for which the TR needs to be created.
     * Description: This method is used To prepare the State transmittal data and return it for inserting Transmittal record.
     *********************************************/
    private static Transmittal__c createStateTransmittalForPaymentRequest(Payment_Request__c paymentUnderProcessing) {
        /** Preparing State Transmittal record data */
        Transmittal__c stateTransmittal = new Transmittal__c();
        stateTransmittal.PaymentRequest__c = paymentUnderProcessing.Id;
        stateTransmittal.TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_State;
        stateTransmittal.Cumulative_State_Cost_Share_Flag__c = paymentUnderProcessing.Cumulative_State_Cost_Share_Flag__c;
        if (stateTransmittal.Cumulative_State_Cost_Share_Flag__c == false ) {
            stateTransmittal.Stage__c = ALS_CONSTANTS.Transmittal_Stage_OnHold;
        }
        else {
            stateTransmittal.Stage__c = ALS_CONSTANTS.Stage_New;
        }
        /** Return statement */
        return stateTransmittal;
    }

    /*********************************************
     *  Method Name : createFederalTransmittalForPaymentRequest
     * Called From Method : createTransmittalRecord
     * Author : Ricky
     * Inputs : - 1. Payment_Request__c paymentUnderProcessing - Payment request record for which the TR needs to be created.
     * Description: This method is used To prepare the Federal transmittal data and return it for inserting Transmittal record.
     *********************************************/
    private static Transmittal__c createFederalTransmittalForPaymentRequest(Payment_Request__c paymentUnderProcessing) {
        /** Preparing Federal Transmittal record data */
        Transmittal__c federalTransmittal = new Transmittal__c();
        federalTransmittal.PaymentRequest__c = paymentUnderProcessing.Id;
        federalTransmittal.TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal;
        federalTransmittal.Stage__c = ALS_CONSTANTS.Stage_New;
        /** Return statement */
        return federalTransmittal;
    }

    /*********************************************
     * Class Name : ALS_TransmittalUtilityInnerClass
     * Called From Method : createTransmittalRecord
     * Author : Ricky
     * Description: This class is used to execute the functionality which is needed to be executed without Sharing.
     *********************************************/
    private without sharing class ALS_TransmittalUtilityInnerClass {
        /*********************************************
        * Method Name : QueryPaymentRequest
        * Called From Method : createTransmittalRecord
        * Author : Ricky
        * Inputs : - 1. Set<Id> paymentRequestIds - Set of Payment Request Ids on which TR needs to be created.
        * Description: This method is used To query the PR and its related Transmittal in System Context.
        *               The query is written in without Sharing class in order to get the Negative Offset TR record to mark it as Approved
        *              as Accounting user does not has access to Negative Offset transmittal unless it is Approved.
        *********************************************/
        private Map<Id, Payment_Request__c> QueryPaymentRequest(Set<Id> paymentRequestIds) {
            Map<Id, Payment_Request__c> paymentRequestRecordMap = new Map<Id, Payment_Request__c>([SELECT Id, Name, Project__c,
                    Cumulative_State_Cost_Share_Flag__c, Project__r.Name, PaymentType__c, ApprovedStatePaymentAmount__c,
                    ApprovedFederalPaymentAmount__c, Project__r.FundingSource__c, Stage__c, ExpenditurestoDate__c, Allow_Admin_Payment__c,
            (SELECT Id, TransmittalType__c, Stage__c FROM Transmittals__r) FROM Payment_Request__c WHERE Id IN :paymentRequestIds]);
            return paymentRequestRecordMap;
        }
    }
}