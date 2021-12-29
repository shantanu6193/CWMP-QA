public with sharing class TransmittalTriggerHelper extends TriggerHelper{
    public override void processAfterUpdate() {
        //This method is used to Unlock the Pr and Move the Stage to Processing when Transmittal gets rejected....
        //If the Project Status is On Hold then It prevents the Transmittal from getting Approved...
        verifyTransmittalApprovalAndRejectionAndUnlockPrOnRejection();
		//Method to Recall Related Transmittal of current Transmittal.
        recallRelatedTransmittalRecord();

        
		approveNegativeOffsetTrUponPositiveOffsetTrApproval();

		updateAdjustedOffsetTransmittalStageToPaid();//Update Stage of AdjustedTR to Paid If Approved amount is equal to total of All related transmittal Approved Amount.
	}

    public override void processAfterInsert() {
        //PopulateTransmittalDataFromPR();
    }

    public override void processBeforeInsert(){
        //This method is used to Update the data on Transmittal record....
        PopulateTransmittalDataFromPR();
    }

    public override void processBeforeUpdate(){
        //This method is used to Update the data on Transmittal record....
        PopulateTransmittalDataFromPR();
        //updateTransmittalAtInReviewStage();
        //Method to make Rejection Comment required on Approval Process of Transmittal
        rejectionCommentRequired();
    }

    /*private void updateTransmittalAtInReviewStage() {
        for (Transmittal__c transmittalRecord : (List<Transmittal__c>) Trigger.new) {
            Transmittal__c oldRecord = (Transmittal__c)Trigger.oldMap.get(transmittalRecord.Id);
            if(transmittalRecord.Stage__c != oldRecord.Stage__c && transmittalRecord.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview){
                PopulateTransmittalDataFromPR();
            }
        }
    }*/
    //This method is used to Update the data on Transmittal record upon insertion or Updation....
    private void PopulateTransmittalDataFromPR(){
        Set<Id> PaymentRequestIds = new Set<Id>(); //To collect the Payment Request Ids...
        Set<Id> ProjectIds = new Set<Id>(); //To Project Ids.....
        List<Transmittal__c> transmittalToProcessList = new List<Transmittal__c>();
        for (Transmittal__c transmittalRecord : (List<Transmittal__c>) Trigger.new) {
            if (transmittalRecord.PaymentRequest__c != null) {
                PaymentRequestIds.add(transmittalRecord.PaymentRequest__c); //Adding the Payment Request Id to collection.....
                transmittalToProcessList.add(transmittalRecord);
            }
        }
        if (PaymentRequestIds.size() > 0) {
        //Fetching Payment Request Details whose Id are available in Set Collection.....
            Map<Id, Payment_Request__c> idToPaymentRequestmap = new Map<Id, Payment_Request__c>([SELECT Id, Name, Manager_Approved_Date_Time__c, Comments__c, Cumulative_State_Cost_Share_Flag__c, OffsetToPaymentRequest__c,
                    CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Email, PaymentType__c, ObligatedAgency__c, ObligatedAgency__r.SupplierID__c, Service_Location__c, Service_Location__r.Name,
                    Encumbrance__c, Encumbrance__r.EncumbranceNumber__c, PaymentDelivery__c, AccrualNumber__c, FederalShareCost__c, StateCostShare__c, StateAdminShare__c, TotalAdminShareAmount__c,
                    ApprovedFederalPaymentAmount__c, ApprovedStatePaymentAmount__c, Project__c, Project__r.Funding_Opportunity_Name__c, Project__r.Program_Name__c,
                    Project__r.StateAmountDisbursed__c, Project__r.FederalAmountDisbursed__c, Project__r.Project_Number__c, Project__r.Obligating_Sub_Recipient__c,
                    Project__r.Obligating_Sub_Recipient__r.Name, Project__r.Obligating_Sub_Recipient__r.Email_Address__c, Project__r.Obligating_Sub_Recipient__r.Sub_Recipient_FIPS__c,
                    Project__r.Total_Project_Award__c, Project__r.AmountAvailable__c, Project__r.Declaration_Number__c, Project__r.FundingSource__c, Award__c, EnactmentYear__c,
                    ReimbursementEndDate__c, ReimbursementStartDate__c, Project__r.Start_Date__c, Project__r.End_Date__c, Manager_Approver__c,Manager_Approver__r.Name, Manager_Approver__r.Title,
                    Manager_Approver__r.Department, Manager_Approver__r.Phone, Manager_Approver__r.Email , Manager_Approver__r.City, Manager_Approver__r.Street, Manager_Approver__r.Country,
                    Manager_Approver__r.PostalCode, Manager_Approver__r.State  FROM Payment_Request__c WHERE Id IN : PaymentRequestIds]);
            //To collect all the Proejct Ids, for fetching Primari Authorized Agent data...
            for(Payment_Request__c prRecord : idToPaymentRequestmap.values()){
                ProjectIds.add(prRecord.Project__c);
            }

            //Fetching Primary Authorized agent data from Project Role with the help of Project ID in Payment Request....
            Map<Id,Project_Role__c> idToProjectRoleMap = new Map<Id,Project_Role__c>([SELECT Id, Name, Project_Name__c, Project_Role_Global_List__c, Contact_Type__c,
                    AccountContactJunction__c, AccountContactJunction__r.Contact_Name__c, AccountContactJunction__r.Contact_Name__r.Name, AccountContactJunction__r.Contact_Name__r.Phone,
                    AccountContactJunction__r.Contact_Name__r.Email, AccountContactJunction__r.Contact_Name__r.AccountId,AccountContactJunction__r.Contact_Name__r.Account.Name,
                    AccountContactJunction__r.Contact_Name__r.OtherStreet, AccountContactJunction__r.Contact_Name__r.OtherCity, AccountContactJunction__r.Contact_Name__r.OtherState,
                    AccountContactJunction__r.Contact_Name__r.OtherPostalCode, AccountContactJunction__r.Contact_Name__r.OtherCountry, AccountContactJunction__r.Account_Name__r.Name
                    FROM Project_Role__c WHERE Project_Name__c IN :ProjectIds
                    AND Project_Role_Global_List__c =: ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent
                    AND Contact_Type__c =: ALS_CONSTANTS.ProjectRole_ContactType]);
            //Iterating idToProjectRole Map of Project to Project Role...
            Map<Id, Project_Role__c> projectToProjectRoleMap = new Map<Id, Project_Role__c>();
            for (Project_Role__c projectRole : idToProjectRoleMap.values()) {
                projectToProjectRoleMap.put(projectRole.Project_Name__c, projectRole);
            }

            for (Transmittal__c transmittalToProcess : transmittalToProcessList) {
                //Transmittal__c oldTransmittalRecord = (Transmittal__c) Trigger.oldMap.get(transmittalToProcess.Id);
                //if (transmittalToProcess.Stage__c == 'New' || transmittalToProcess.Stage__c == 'Rejected') {
                Payment_Request__c paymentRequestToProcess = idToPaymentRequestmap.get(transmittalToProcess.PaymentRequest__c);
                Project_Role__c projectRoleToProcess = projectToProjectRoleMap?.get(paymentRequestToProcess.Project__c);

                //Assign the data from Payment Request to Transmittal Record.....
                transmittalToProcess.PaymentDelivery__c = paymentRequestToProcess.PaymentDelivery__c;
                transmittalToProcess.ApplicantName__c = paymentRequestToProcess.Project__r.Obligating_Sub_Recipient__c;
                //transmittalToProcess.Applicant_Email__c = paymentRequestToProcess.Project__r.Obligating_Sub_Recipient__r.Email_Address__c;
                transmittalToProcess.ApplicantNumber__c = paymentRequestToProcess.Project__r.Obligating_Sub_Recipient__r.Sub_Recipient_FIPS__c;
                transmittalToProcess.ProjectPONumber__c = paymentRequestToProcess.Project__r.Project_Number__c;
                transmittalToProcess.Offset_Payment_Request__c = paymentRequestToProcess?.OffsetToPaymentRequest__c;
                transmittalToProcess.Project__c = paymentRequestToProcess?.Project__c;
                transmittalToProcess.FundingType__c = paymentRequestToProcess.Project__r.FundingSource__c;
                transmittalToProcess.IncidentProjectNumber__c = paymentRequestToProcess.Project__r.Declaration_Number__c;
                transmittalToProcess.EnactmentFiscalYear__c = paymentRequestToProcess.EnactmentYear__c;
                //Ticket No-372 Transmittals - comments + service locations
                transmittalToProcess.Comments__c = paymentRequestToProcess.Comments__c;
                if(transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_Federal){
                    transmittalToProcess.ServiceLocationCode__c = paymentRequestToProcess.Service_Location__r.Name;
                }
                transmittalToProcess.PaymentType__c = paymentRequestToProcess.PaymentType__c;
                if (paymentRequestToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_MutualAid) {
                    transmittalToProcess.ObligatedAgency__c = paymentRequestToProcess.ObligatedAgency__c;
                    transmittalToProcess.SupplierID__c = paymentRequestToProcess.ObligatedAgency__r?.SupplierID__c;
                }
                else {
                    transmittalToProcess.ObligatedAgency__c = null;
                    transmittalToProcess.SupplierID__c = null;
                }
                transmittalToProcess.DisasterGrantFO__c = paymentRequestToProcess.Project__r.Funding_Opportunity_Name__c;
                transmittalToProcess.ProgramName__c = paymentRequestToProcess.Project__r.Program_Name__c;
                //If Transmittal Type is State and Cumulative State Cost Share Flagg is red on PR, then marh the Transmittal Stage "On Hold"..
                transmittalToProcess.Cumulative_State_Cost_Share_Flag__c = paymentRequestToProcess.Cumulative_State_Cost_Share_Flag__c;
                if (transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_State
                        && paymentRequestToProcess.Cumulative_State_Cost_Share_Flag__c == false && transmittalToProcess.Stage__c == ALS_CONSTANTS.Stage_New) {
                    transmittalToProcess.Stage__c = ALS_CONSTANTS.Transmittal_Stage_OnHold;
                } else if (transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_State
                        && paymentRequestToProcess.Cumulative_State_Cost_Share_Flag__c == true && transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_OnHold) {
                    transmittalToProcess.Stage__c = ALS_CONSTANTS.Stage_New;
                }

                //Fields needed to send Email upon Transmittal Rejection...
                transmittalToProcess.PR_Owner_Email__c = paymentRequestToProcess.CreatedBy.Email;

                //TO convert DateTime field into Date..
                Datetime dt = paymentRequestToProcess.CreatedDate;
                transmittalToProcess.Date__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                if (paymentRequestToProcess.Project__r?.Start_Date__c != null && paymentRequestToProcess.Project__r?.End_Date__c != null) {
                    //transmittalToProcess.PeriodOfPerformance__c = paymentRequestToProcess.Project__r?.Grant_Award_Start_Date__c + ' - ' + paymentRequestToProcess.Project__r?.Grant_Award_End_Date__c;
                    transmittalToProcess.StartDate__c = paymentRequestToProcess.Project__r?.Start_Date__c;
                    transmittalToProcess.EndDate__c = paymentRequestToProcess.Project__r?.End_Date__c;
                }
                if (paymentRequestToProcess.ReimbursementStartDate__c != null && paymentRequestToProcess.ReimbursementEndDate__c != null) {
                    //transmittalToProcess.ReimbursementPeriod__c = paymentRequestToProcess.ReimbursementStartDate__c + ' - ' + paymentRequestToProcess.ReimbursementEndDate__c;
                    transmittalToProcess.ReimbursementStartDate__c = paymentRequestToProcess.ReimbursementStartDate__c;
                    transmittalToProcess.ReimbursementEndDate__c = paymentRequestToProcess.ReimbursementEndDate__c;
                }
                //From Details Fields Data...
                transmittalToProcess.PaymentUsersManager__c = paymentRequestToProcess.Manager_Approver__r?.Name;
                transmittalToProcess.ManagersTitle__c = paymentRequestToProcess.Manager_Approver__r?.Title;
                transmittalToProcess.ManagersDepartment__c = paymentRequestToProcess.Manager_Approver__r?.Department;
                transmittalToProcess.FromEmail__c = paymentRequestToProcess?.Manager_Approver__r?.Email;
                transmittalToProcess.ManagerMailingStreet__c = paymentRequestToProcess?.Manager_Approver__r?.Street;
                transmittalToProcess.ManagerMailingCity__c = paymentRequestToProcess?.Manager_Approver__r?.City;
                transmittalToProcess.ManagerMailingState__c = paymentRequestToProcess?.Manager_Approver__r?.State;
                transmittalToProcess.ManagerMailingPostalCode__c = paymentRequestToProcess?.Manager_Approver__r?.PostalCode;
                transmittalToProcess.ManagerMailingCountry__c = paymentRequestToProcess?.Manager_Approver__r?.Country;
                transmittalToProcess.Manager_s_Phone__c = paymentRequestToProcess?.Manager_Approver__r?.Phone;
                transmittalToProcess.Approved_Date__c = paymentRequestToProcess?.Manager_Approved_Date_Time__c;

                //To Details Fields Data....
                transmittalToProcess.PrimaryAuthorizedAgentName__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.Name;
                transmittalToProcess.AccountName__c = projectRoleToProcess?.AccountContactJunction__r?.Account_Name__r.Name;
                transmittalToProcess.ToEmail__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.Email;
                transmittalToProcess.Phone__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.Phone;
                transmittalToProcess.ContactMailingStreet__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.OtherStreet;
                transmittalToProcess.ContactMailingCity__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.OtherCity;
                transmittalToProcess.ContactMailingState__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.OtherState;
                transmittalToProcess.ContactMailingPostalCode__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.OtherPostalCode;
                transmittalToProcess.ContactMailingCountry__c = projectRoleToProcess?.AccountContactJunction__r?.Contact_Name__r.OtherCountry;

                //Billing Line Items Data....
                if (transmittalToProcess.External_Id__c == null) {
                    transmittalToProcess.Total_amount_Obligated__c = paymentRequestToProcess?.Project__r.Total_Project_Award__c;
                    transmittalToProcess.Amount_Available__c = paymentRequestToProcess?.Project__r.AmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                    if (paymentRequestToProcess.Encumbrance__c != null) {
                        transmittalToProcess.AccrualEncumbranceNo__c = paymentRequestToProcess?.Encumbrance__r?.EncumbranceNumber__c;
                    }
                    if (paymentRequestToProcess.AccrualNumber__c != null) {
                        transmittalToProcess.AccrualEncumbranceNo__c = paymentRequestToProcess?.AccrualNumber__c;
                    }
                    if (transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_State) {
                        transmittalToProcess.Amount_Obligated__c = paymentRequestToProcess?.StateCostShare__c?.setScale(2,system.RoundingMode.DOWN);
                        transmittalToProcess.Admin_Share_Amount__c = paymentRequestToProcess?.TotalAdminShareAmount__c?.setScale(2,system.RoundingMode.DOWN);
                        transmittalToProcess.ExpenditurestoDate__c = paymentRequestToProcess.Project__r?.StateAmountDisbursed__c?.setScale(2,system.RoundingMode.DOWN);
                        transmittalToProcess.ApprovedAmount__c = paymentRequestToProcess.ApprovedStatePaymentAmount__c?.setScale(2,system.RoundingMode.DOWN);
                    } else if (transmittalToProcess.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_Federal) {
                        transmittalToProcess.Amount_Obligated__c = paymentRequestToProcess?.FederalShareCost__c?.setScale(2,system.RoundingMode.DOWN);
                        transmittalToProcess.ExpenditurestoDate__c = paymentRequestToProcess.Project__r?.FederalAmountDisbursed__c?.setScale(2,system.RoundingMode.DOWN);
                        transmittalToProcess.ApprovedAmount__c = paymentRequestToProcess.ApprovedFederalPaymentAmount__c?.setScale(2,system.RoundingMode.DOWN);
                    }
                }
            }
        }
    }

    /** Updated the method for Ticket No - 528, 529 - Start */
    /*********************************************
     * Method Name : verifyTransmittalApprovalAndRejectionAndUnlockPrOnRejection
     * Called From Method : Process After Update
     * Author : Ricky
     * Inputs : -
     * Description: This method is used to Unlock the Pr and Move the Stage to Processing when Transmittal gets rejected.
     *              If the Project Status is On Hold then It prevents the Transmittal from getting Approved.
     *********************************************/
    private void verifyTransmittalApprovalAndRejectionAndUnlockPrOnRejection() {
        List<Id> PaymentRequestIds = new List<Id>(); /** To collect the Payment Request Ids */
        /** To collect the TRs which needs to be verified before Approval/Rejection/Recall */
        List<Transmittal__c> transmittalToProcessList = new List<Transmittal__c>();
        for (Transmittal__c transmittalToProcess : (List<Transmittal__c>) Trigger.new) {
            /** Fetching the old Transmittal record fro Trigger.oldMap in order to compare the Stage value. */
            Transmittal__c oldTransmittalRecord = (Transmittal__c) Trigger.oldMap.get(transmittalToProcess.Id);
            /** Updated for Ticket - 491 - Start */
            /** Condition 1 - To check that the Stage of transmittal has been changed.
             * Condition 2 - To check if the New Stage of Transmittal is - Rejected/Approved/Withdrawn/New */
            if (transmittalToProcess.PaymentRequest__c != null
                    && transmittalToProcess.Stage__c != oldTransmittalRecord.Stage__c
                    && (transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected
                        || transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved
                        || transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Withdrawn
                        ||transmittalToProcess.Stage__c == ALS_CONSTANTS.Stage_New)) {
                PaymentRequestIds.add(transmittalToProcess.PaymentRequest__c); /** Adding PR is to collection */
                transmittalToProcessList.add(transmittalToProcess); /** Adding TR is to collection */
            }
        }

        /** Condition to check null pointer exception for PaymentRequestIds collection. */
        if (PaymentRequestIds.size() > 0) {
            //List<Payment_Request__c> paymentRequestToUpdateList = new List<Payment_Request__c>();
            Set<Id> prIdsToUnlockUnique = new Set<Id>();
            /** Fetching the PR record and its related Approved Transmittal record. */
            Map<Id, Payment_Request__c> idToPaymentRequestMap = new Map<Id, Payment_Request__c>([SELECT Id, Stage__c, Project__r.Status__c,
                                                                        PaymentType__c,
                                                                        (SELECT Id, Stage__c, PaymentRequest__c FROM Transmittals__r
                                                                            WHERE Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Approved
                                                                            OR Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Paid)
                                                                    FROM Payment_Request__c WHERE Id IN : PaymentRequestIds]);
            /** Iterating the TR records to verify the changes */
            for (Transmittal__c transmittalToProcess : transmittalToProcessList) {
                Transmittal__c oldTransmittalRecord = (Transmittal__c) Trigger.oldMap.get(transmittalToProcess.Id);
                Payment_Request__c paymentToProcess = idToPaymentRequestMap.get(transmittalToProcess.PaymentRequest__c);
                /** Condition 1 - To check if there is any Approved/Paid TR available on the PR of current TR
                 * Condition 2 - Current Transmittal new Stage is Rejected/Withdrawn/New
                  * Condition 3 - Old TR stage was In Review - This condition is added to avoid the scenario for auto Approve transmittal record.
                  *                 Eg - Returned Project PR Approval, Negative Amount Offset PR and TR approval.*/
                if(paymentToProcess?.Transmittals__r?.size() > 0
                        && (transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected
                            || transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Withdrawn
                            || (transmittalToProcess.Stage__c == ALS_CONSTANTS.Stage_New
                                && oldTransmittalRecord.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview))) {
                    transmittalToProcess.addError('You cannot Reject/Withdraw/Recall this Transmittal, the other Transmittal associated with the Payment Request is already Confirmed/Paid.');
                }
                /** Condition 1 - To check if the current TR stage is Approved/Rejected */
                if(transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected
                        || transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved) {
                    /** Condition 1 - To check if the TR is Rejected - in order to move the PR to "Reviewed need More Information" Stage,
                     * So that the FPD can process the PR again. */
                    /*if(transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected) {
                        paymentToProcess.Stage__c = ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation; //Moving the PR Stage to processing....
                    paymentRequestToUpdateList.add(paymentToProcess);
                    prIdsToUnlockUnique.add(transmittalToProcess.PaymentRequest__c);
                }*/
                    /** These condition are added to avoid Approval of TR if the PR is not in "Payment Processing Stage".
                     * Condition 1 - TR's old Stage was In Review
                     * Condition 2 - TR's new Stage is Approved
                     * Condition 3 - PR is not in  "Payment Processing" stage*/
                    if(oldTransmittalRecord.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview
                            && transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved
                            && paymentToProcess.Stage__c != ALS_CONSTANTS.PR_Stage_PaymentProcessing) {
                        transmittalToProcess.addError('You cannot process any Transmittal, If the Payment Request is not in "Payment Processing" Stage.');
                    }
                    /** These condition are added to avoid Approval of TR if the Project status is "On Hold - Debt Recovery".
                     * Condition 1 - TR's new Stage is Approved
                     * Condition 2 - PR Type is not "Offset/Returned Project Payment" - This condition is added to allow processing TRs of Offset Type PR.
                     * Condition 3 - Project Status is "On Hold - Debt Recovery" */
                else if(transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved
                            && transmittalToProcess.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_Offset
                            && transmittalToProcess.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                        && paymentToProcess.Project__r.Status__c == ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery) {
                    transmittalToProcess.addError('You cannot process any Transmittal, If the Project Status is On Hold.');
                }
            }
            }
            /** Updating the PRs and unlocking it after TR rejection. */
            /*if(paymentRequestToUpdateList.size() > 0) {
                List<Id> prIdsToUnlock = new List<Id>();
                prIdsToUnlock.addAll(prIdsToUnlockUnique);
                RecordLockUnlockClass recordLockUnlock = new RecordLockUnlockClass();
                recordLockUnlock.unlockRecord(prIdsToUnlock);
                update paymentRequestToUpdateList;
            }*/
            //Updated for Ticket - 491 - End
        }
    }
    /** Ticket No - 528, 529 - End */


    /***********************************************
     * Method Name : recallTransmittalRecord
     * Author : Sushant.
     * Inputs : - Transmittal Id ,String Action('Reject'/'Recall').
     * Description: This method will Recall/Reject the Transmittal.
     *********************************************/
    public static void recallOrRejectTransmittalRecord(List<Id> transmittalIds ,String Action) {
        List<Id> targetId = transmittalIds;
        if(transmittalIds?.size() > 0) {
            List<Approval.ProcessWorkitemRequest> transmittalToRecallWorkItemList = new List<Approval.ProcessWorkitemRequest>();
            /**Fetching Approval Process Of Transmittal who's Id = 'targetId' and Approval Stae is in Pending Stage**/
            ProcessInstanceWorkitem[] workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :targetId
                                                        AND ProcessInstance.Status = 'Pending'];
            if(workItems?.size() > 0) {
                for (ProcessInstanceWorkitem workItem : workItems) {
                    /** Instance of Approval Process **/
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                    if(Action == 'Recall') {
                        pwr.setAction('Removed'); /** Set the type of action to Removed To Recall. **/
                    }
                    if(Action == 'Reject'){
                        pwr.setAction('Reject'); /** Set the type of action to Reject To Reject. **/
                        pwr.setComments(ALS_CONSTANTS.Transmittal_RecallComment + UserInfo.getName());
                    }
                    pwr.setWorkitemId(workItems[0].Id);
                    transmittalToRecallWorkItemList.add(pwr);
                }
                Approval.ProcessResult[] result = Approval.process(transmittalToRecallWorkItemList); /** Update Approval process for 'targetId' Transmittal.**/
            }
        }
            }

    /***********************************************
    //Recall related Transmittal Ticket No 529
   * Method Name : recallRelatedTransmittalRecord
   * Author : Sushant.
   * Inputs : -
   * Description: This method will Recall/Reject related Transmittal if it is in In Review Stage
                  And update the Payment request Stage to Reviewed Needs Information
                  oR it will Display Error if related Transmittal is in Approved stage.
   *********************************************/
    private void recallRelatedTransmittalRecord(){

        Map<Id,Transmittal__c> paymentRequestIdToTransmittalsMap = new Map<Id,Transmittal__c>();
        Set<Id> currentRecordIds = new Set<Id>();
        Map<Id,Transmittal__c> transmittalIdToTransmittalToRecallMap = new Map<Id, Transmittal__c>();
        Map<Id,Transmittal__c> transmittalIdToTransmittalToRejectMap = new Map<Id, Transmittal__c>();
        List<Payment_Request__c> prsToUpdate = new List<Payment_Request__c>();
        List<Id> paymentRequestRecordsToUnlock = new List<Id>();
        List<Id> transmittalIdsToRecallList = new List<Id>();
        List<Id> transmittalIdsToRejectList = new List<Id>();
        RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
        Set<Id> trProjectIds = new Set<Id>(); //To collect the Project of the TR

        for (Transmittal__c transmittalToProcess : (List<Transmittal__c>) Trigger.new) {
            Transmittal__c oldTransmittalRecord = (Transmittal__c) Trigger.oldMap.get(transmittalToProcess.Id);
            /** If Transmittal if getting recalled check Stage of record if New Stage is "New " or "Rejected "
             * and old Stage was "In Review" then add Id to paymentRequestIdToTransmittalsMap */
            if (oldTransmittalRecord.Stage__c!= transmittalToProcess.Stage__c
                && (transmittalToProcess.Stage__c == ALS_CONSTANTS.Stage_New
                || transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected)
                && oldTransmittalRecord.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview) {

                paymentRequestIdToTransmittalsMap.put(transmittalToProcess?.PaymentRequest__c,transmittalToProcess);
                currentRecordIds.add(transmittalToProcess.Id);

                if (transmittalToProcess.Project__c != null) {
                    trProjectIds.add(transmittalToProcess.Project__c);
                }
            }
        }
        if(paymentRequestIdToTransmittalsMap?.size() >0) {
            /** Get All Transmittal Related to Payment Request Excluding Current Transmittal Record */
            List<Transmittal__c> relatedTransmittals = [
                    SELECT Id, Stage__c, PaymentRequest__c, PaymentRequest__r.Stage__c
                    FROM Transmittal__c
                    WHERE PaymentRequest__c
                    IN :paymentRequestIdToTransmittalsMap.keySet() AND Id NOT IN :currentRecordIds];

            Map<Id, Award__c> projectIdToActiveAwardMap = new Map<Id, Award__c>();
            if (trProjectIds?.size() > 0) {
                List<Award__c> activeAwardOfProjectList = [SELECT Id, Status__c, Project__c FROM Award__c
                                                            WHERE Project__c IN : trProjectIds
                                                            AND Status__c =: ALS_CONSTANTS.Award_Status_Active];
                for (Award__c award : activeAwardOfProjectList) {
                    projectIdToActiveAwardMap.put(award.Project__c, award);
                }
            }

            if(relatedTransmittals?.size() > 0){

                for (Transmittal__c tr : relatedTransmittals) {
                    Transmittal__c currentTransmittal = (Transmittal__c) paymentRequestIdToTransmittalsMap.get(tr.PaymentRequest__c);
                    /** If related Transmittal is Approved then Display Error*/
                    if (tr.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved || tr.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Paid ) {
                        paymentRequestIdToTransmittalsMap.get(tr.PaymentRequest__c).addError('You cannot Recall/Reject this Transmittal, the other Transmittal associated with the Payment Request is already Confirmed/Paid.');
                    /** If the Current Transmittal got Recalled and If related Transmittal is in In-Review Stage then recall the transmittal Update Comment Field
                     *  to Inform user why this transmittal got Recalled And move Stage to New*/
                    } else if (tr.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview && currentTransmittal.Stage__c == ALS_CONSTANTS.Stage_New ) {
                        tr.Recall_Comments__c = ALS_CONSTANTS.Transmittal_RecallComment + UserInfo.getName();
                        tr.Stage__c = ALS_CONSTANTS.Stage_New;
                        transmittalIdToTransmittalToRecallMap.put(tr.Id,tr);
                    }
                    /** If the Current Transmittal got Recalled and If related Transmittal is in In-Review Stage then Reject the transmittal Update Comment Field
                    *  to Inform user why this transmittal got Rejected And move Stage to Rejected */
                    else if(tr.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview && currentTransmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected ){
                        tr.Recall_Comments__c = ALS_CONSTANTS.Transmittal_RecallComment + UserInfo.getName();
                        tr.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Rejected;
                        transmittalIdToTransmittalToRejectMap.put(tr.Id,tr);
                    }
                }
            }

            /** Calling recallOrRejectTransmittalRecord Method to Recall the Record */
            if (transmittalIdToTransmittalToRecallMap?.size() > 0) {
                transmittalIdsToRecallList.addAll(transmittalIdToTransmittalToRecallMap.keySet());
                recallOrRejectTransmittalRecord(transmittalIdsToRecallList,'Recall');
            }
            /** Calling recallOrRejectTransmittalRecord Method to Reject the Record */
            if(transmittalIdToTransmittalToRejectMap?.size() > 0){
                transmittalIdsToRejectList.addAll(transmittalIdToTransmittalToRejectMap.keySet());
                recallOrRejectTransmittalRecord(transmittalIdsToRejectList,'Reject');
            }
            /** Updating related Transmittal Comment And Stage.*/
            if(transmittalIdToTransmittalToRecallMap?.size() > 0){
                update transmittalIdToTransmittalToRecallMap.values();
            }
            /** Updating related Transmittal Comment And Stage.*/
            if(transmittalIdToTransmittalToRejectMap?.size() > 0){
                update transmittalIdToTransmittalToRejectMap.values();
            }
            /** Update PR Stage to Reviewed Needs Information */
            for(Transmittal__c transmittalToProcess : paymentRequestIdToTransmittalsMap.values()) {
                Payment_Request__c paymentToProcess = new Payment_Request__c();
                paymentToProcess.Id = transmittalToProcess.PaymentRequest__c;
                paymentToProcess.Stage__c = ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation;
                if (paymentToProcess.Award__r.Status__c != ALS_CONSTANTS.Award_Status_Active) {
                    paymentToProcess.Award__c = projectIdToActiveAwardMap?.get(transmittalToProcess.Project__c)?.Id;
                }
                prsToUpdate.add(paymentToProcess);
            }
            /** Instance of RecordLockUnlockClass To Call Unlock Method */
            paymentRequestRecordsToUnlock.addAll(paymentRequestIdToTransmittalsMap.keySet());
            lockUnlock.unlockRecord(paymentRequestRecordsToUnlock);

            update prsToUpdate;
        }
    }

    //Ticket No -CalOES -440 (Transmittal Rejection Processing)..
    /***********************************************
  * Method Name : rejectionCommentRequired
  * Author : Sushant.
  * Inputs : -
  * Description: To make Rejection Comment required on Transmittal Approval Process
  *********************************************/
    private void rejectionCommentRequired() {
        Map<Id,Transmittal__c> idToTransmittalMap = new Map<Id, Transmittal__c>();
        for(Transmittal__c transmittalToProcess : (List<Transmittal__c>) Trigger.new){
            Transmittal__c oldRecord = (Transmittal__c) Trigger.oldMap.get(transmittalToProcess.Id);
            /**If stage of transmittal is Rejected add Record Id to Map..*/
            if(transmittalToProcess.Stage__c != oldRecord.Stage__c && transmittalToProcess.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Rejected ){
                idToTransmittalMap.put(transmittalToProcess.Id,transmittalToProcess);
            }
        }
        if(idToTransmittalMap?.size() > 0){
            /**Fetching Comments of recent Approval History record on Current Transmittal...*/
            List<ProcessInstance> ProcessInstanceList = [SELECT TargetObjectId,
            (SELECT Id, StepStatus, Comments
            FROM Steps
            ORDER BY CreatedDate DESC
            LIMIT 1 )
            FROM ProcessInstance
            WHERE TargetObjectId IN :idToTransmittalMap.keySet()
            ORDER BY CreatedDate DESC LIMIT 1];
            for (ProcessInstance processInstance :ProcessInstanceList)
            {
                String comment = processInstance?.Steps[0]?.Comments?.deleteWhitespace();
                /**If Approval History comment is black then Throw an Error*/
                if ((comment == null && processInstance?.Steps[0]?.StepStatus == 'Rejected'))
                {
                    idToTransmittalMap.get(processInstance.TargetObjectId).addError(
                            'Rejection reason is Required!');
                }
            }
        }
    }

    /** Ticket No - 475 - Start */
    /*********************************************
	* Method Name : approveNegativeOffsetTrUponPositiveOffsetTrApproval
	* Called From Method : BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used To update the Negative Offset Transmittal to Approved Stage,
	*               Once all the related Offset Transmittal gets Approved.
	*********************************************/
    private void approveNegativeOffsetTrUponPositiveOffsetTrApproval () {
        /** To collect the positive Offset Transmittals to process th Negative Offset Transmittals. */
        Map<Id, Transmittal__c> trIdTransmittalToProcessMap = new Map<Id, Transmittal__c>();
        Set<Id> offSetTrIds = new Set<Id>(); /** To collect the Offset Transmittal Ids. */
        for(Transmittal__c transmittal : (List<Transmittal__c>) Trigger.new) {
            /** Fetching the old Transmittal records to compare the field value changes. */
            Transmittal__c oldRecord = (Transmittal__c) Trigger.oldMap.get(transmittal.Id);
            /** Condition 1 - To check that the Transmittal Stage has been changed.
             * Condition 2 - New Stage of Transmittal is Approved
             * Condition 3 - Payment Type is Offset.
             * Condition 4 - Approved Amount is greater than 0 - This condition is added to avoid the process when Negative Offset TR getting Approved. */
            if(transmittal.Stage__c != oldRecord.Stage__c
                    && oldRecord.Stage__c == ALS_CONSTANTS.Transmittal_Stage_InReview
                    && transmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved
                    && transmittal.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                    && transmittal.ApprovedAmount__c > 0) {
                trIdTransmittalToProcessMap.put(transmittal.Id, transmittal);
                /** Condition to check for Positive Offset transmittal lookup field null pointer exception */
                if(transmittal.Adjusted_For_Offset__c != null) {
                    offSetTrIds.add(transmittal.Adjusted_For_Offset__c);
                }
                /*else {
                    transmittal.addError(System.Label.REAL_Transmittal_AdjustedforOffsetRequiredError);
                }*/
            }
        }
        /** Condition to check null pointer exception for offSetTrIds collection and method calling for further process. */
        if(offSetTrIds.size() > 0) {
            TransmittalTriggerHelperInnerClass ic = new TransmittalTriggerHelperInnerClass();
            ic.updateNegativeOffsetTransmittalBasedOnApprovedAmount(offSetTrIds);
        }
    }

    /*********************************************
    * Class Name : TransmittalTriggerHelperInnerClass
    * Called From Method : approveNegativeOffsetTrUponPositiveOffsetTrApproval
    * Author : Ricky
    * Description: This class is written without sharing in order to process the negative Offset transmittals,
    *              which is not visible to Accounting unless it is Approved.
    *********************************************/
    private without sharing class TransmittalTriggerHelperInnerClass {

        /*********************************************
         *  Method Name : updateNegativeOffsetTransmittalBasedOnApprovedAmount
         * Called From Method : approveNegativeOffsetTrUponPositiveOffsetTrApproval
         * Author : Ricky
         * Inputs : - 1. List<Transmittal__c> approvedNegativeOffsetTrList - List of Negative Offset Transmittals which got Approved.
         * Description: This method is used To update the Negative Offset Transmittal to Approved Stage,
         *               Once all the related Positive Offset Transmittal gets Approved and
         *               Approved Amount is equal to Negative Offset TR Approved Amount.
         *********************************************/
        private void updateNegativeOffsetTransmittalBasedOnApprovedAmount (Set<Id> offSetTrIds) {
            /** To collect the Negative Offset transmittal record to Approve. */
            Map<Id, Transmittal__c> trIdToTrsToApproveMap = new Map<Id, Transmittal__c>();
            /** Fetching the Negative Offset Transmittal record and Its related Positive Offset Transmittal record
             * which are Approved to compare the Approved Amount.
             * Reason to use the normal query instead of Aggregate query is that We cannot fetch the Parent record fileds and group by that. */
            Map<Id, Transmittal__c> transmittalIdToTransmittalRecordMap = new Map<Id, Transmittal__c>([SELECT Id, Name, Stage__c,
                                                                            PaymentRequest__c, ApprovedAmount__c,
                                                                            (SELECT Id, Name, Stage__c, PaymentType__c, ApprovedAmount__c
                                                                            FROM Transmittals__r
                                                                            WHERE Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Approved
                                                                            OR Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Paid)
                                                                            FROM Transmittal__c WHERE Id IN : offSetTrIds]);
            /** Fetching the Accounting Queue record data in order to change the Owner of Transmittal to Accounting
             * to make the Transmittal record visible for Accounting user. */
            Group queueData = [SELECT Id, Name,DeveloperName FROM Group WHERE Type=:ALS_CONSTANTS.Queue_Type AND DeveloperName =: ALS_CONSTANTS.Queue_API_Name];
            /** 1. Iterating the Negative Offset Transmittal record to compare the Approved Amount.
             * 2. Comparing the Positive Approved Amount on Positive Offset Transmittals with Negative Approved Amount on Negative Offset transmittal
             * 3. Marking the Negative Offset transmittal as Approved and changing the Owner to make it visible o Accounting user. */
            for(Transmittal__c transmittalToProcess : transmittalIdToTransmittalRecordMap.values()) {
                Decimal approvedAmount = 0;
                if(transmittalToProcess?.Transmittals__r?.size() > 0) {
                    for (Transmittal__c transmittal : transmittalToProcess.Transmittals__r) {
                        if(transmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved
                                || transmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Paid) {
                            approvedAmount += transmittal.ApprovedAmount__c;
                        }
                    }
                    if((transmittalToProcess.ApprovedAmount__c.setScale(2,system.RoundingMode.DOWN)
                            + approvedAmount.setScale(2,system.RoundingMode.DOWN)) == 0) {
                        transmittalToProcess.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved;
                        transmittalToProcess.OwnerId = queueData?.Id;
                        transmittalToProcess.Comments__c = ALS_CONSTANTS.Transmittal_ApprovalCommentForNegativeOffsetTR;
                        trIdToTrsToApproveMap.put(transmittalToProcess.Id, transmittalToProcess);
                    }
                }
            }
            /** 1. Updating the Negative Offset transmittal Stage.
             * 2. Locking the Transmittal record.
             * 3. Sending the Approved Tr to another method for PR processing.*/
            if (trIdToTrsToApproveMap?.size() > 0) {
                update trIdToTrsToApproveMap.values();
                List<Id> trIdsToLock = new List<Id>();
                trIdsToLock.addAll(trIdToTrsToApproveMap.keySet());
                RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
                lockUnlock.lockRecord(trIdsToLock);
                updatePrStageToApproveUponApprovingAllTransmittal(trIdToTrsToApproveMap.values());
            }
        }

        /*********************************************
        * Method Name : updatePrStageToApproveUponApprovingAllTransmittal
        * Called From Method : approveNegativeOffsetTrUponPositiveOffsetTrApproval
        * Author : Ricky
        * Inputs : - 1. List<Transmittal__c> approvedNegativeOffsetTrList - List of Negative Offset Transmittals which got Approved.
        * Description: This method is used To update the Negative Offset Payment Request to Approved Stage,
        *               Once all the related Transmittal gets Approved.
        *********************************************/
        private void updatePrStageToApproveUponApprovingAllTransmittal (List<Transmittal__c> approvedNegativeOffsetTrList) {
            Set<Id> paymentRequestIds = new Set<Id>(); /** To collect the Payment Request of the Approved Negative Offset transmittal record. */
            /** Iterating the Transmittal records which are passed to this method in order to collect their PR. */
            for (Transmittal__c transmittal : approvedNegativeOffsetTrList) {
                if(transmittal.PaymentRequest__c != null) {
                    paymentRequestIds.add(transmittal.PaymentRequest__c); /** Adding the PR record to collection. */
                }
            }
            /** Condition to check for null pointer exception for paymentRequestIds collection. */
            if(paymentRequestIds.size() > 0) {
                /** To collect the Negative Offset Payment Request record to Approve. */
                Map<Id, Payment_Request__c> prIdPrToUpdateMap = new Map<Id, Payment_Request__c>();
                /** Fetching the Negative offset Payment Request record and its related Transmittal record */
                Map<Id, Payment_Request__c> prIdToPrWithRelatedTransmittalMap = new Map<Id, Payment_Request__c>([SELECT Id, Name, Stage__c,
                                                                                (SELECT Id, Stage__c FROM Transmittals__r)
                                                                                FROM Payment_Request__c WHERE Id IN : paymentRequestIds]);
                /** 1. Iterating the Negative Offset Payment Request record to compare the Approved TR record.
                 * 2. Comparing the related Transmittal record size to Approved Transmittal records.
                 * 3. Marking the Negative Offset Payment Request as Payment Processing. */
                for(Payment_Request__c prToProcess : prIdToPrWithRelatedTransmittalMap.values()) {
                    Integer count = 0;
                    for (Transmittal__c transmittal : prToProcess.Transmittals__r) {
                        if(transmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved
                                || transmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Paid) {
                            count++;
                        }
                    }
                    if(prToProcess?.Transmittals__r?.size() == count) {
                        prToProcess.Stage__c = ALS_CONSTANTS.PR_Stage_PaymentProcessing;
                        prIdPrToUpdateMap.put(prToProcess.Id, prToProcess);
                    }
                }
                /** 1. Updating the Negative Offset Payment Request Stage. 
                 * 2. Locking the Payment Request record.*/
                if(prIdPrToUpdateMap?.size() > 0) {
                    update prIdPrToUpdateMap.values();
                    List<Id> prIdsToLockList = new List<Id>();
                    prIdsToLockList.addAll(prIdPrToUpdateMap.keySet());
                    RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
                    lockUnlock.lockRecord(prIdsToLockList);
                }
            }
        }
    }
    /** Ticket No - 475 - End */
    /***********************************************
     * Method Name : updateAdjustedOffsetTransmittalToPaid
     * Author : Sushant.
     * Inputs : -
     * Description: Update Stage of AdjustedforOffsettransmittal to Paid
     * if Approved amount on Adjusted TR and total Approved amount on Related Paid TRs =0.
     *********************************************/
    private void updateAdjustedOffsetTransmittalStageToPaid(){
        Map<Id,Transmittal__c> trIdToTransmittalToUpdateMap = new Map<Id,Transmittal__c>();
        set<Id> adjustedNegativeOffsetTRId = new Set<Id>();//Adjusted Transmittal for Offset Ids.
        for(Transmittal__c transmittal:(List<Transmittal__c>) Trigger.new){
            Transmittal__c oldRecord = (Transmittal__c) Trigger.oldMap.get(transmittal.Id);
            //If current Transmittal is in Paid stage , Payment type is Offset , Approved amount is > 0 and Adjusted for Offset != null then get Id of Adjusted for Offset Transmittal
            if(transmittal.PaymentType__c == ALS_CONSTANTS.Transmittal_PaymentType_Offset
                && transmittal.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Paid
                && transmittal.ApprovedAmount__c > 0
                && transmittal.Adjusted_For_Offset__c != null
                && oldRecord.Stage__c == ALS_CONSTANTS.Transmittal_Stage_Approved ){
                adjustedNegativeOffsetTRId.add(transmittal.Adjusted_For_Offset__c);
            }
        }
        //Get all relted Transmittal which are in Paid Stage.
        Map<Id,Transmittal__c> transmittalIdToTransmittalMap = new Map<Id,Transmittal__c>([select Id,ApprovedAmount__c,
                                (Select Id,ApprovedAmount__c from Transmittals__r WHERE Stage__c=:ALS_CONSTANTS.Transmittal_Stage_Paid)
                                FROM Transmittal__c WHERE Id IN :adjustedNegativeOffsetTRId]);
        Decimal totalApprovedAmount = 0;//Collect Approved amounts of All transmittal to this variable.
        for(Transmittal__c transmittal: transmittalIdToTransmittalMap.values()){
            if(transmittal?.Transmittals__r?.size() >0){
                for(Transmittal__c relatedTR: transmittal.Transmittals__r ){
                    totalApprovedAmount += relatedTR.ApprovedAmount__c == null?0:relatedTR.ApprovedAmount__c;
                }
            }
            //if totalApprovedAmount - Approved amount on Adjusted for Offset TR is equal to 0 then update Adjusted for Offset TR stage to Paid.
            if((totalApprovedAmount + transmittal?.ApprovedAmount__c.setScale(2,system.RoundingMode.DOWN)) == 0){
                transmittal.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Paid;
                trIdToTransmittalToUpdateMap.put(transmittal.Id,transmittal);
            }
        }
        if(trIdToTransmittalToUpdateMap.size()>0){
            List<Id> trIdsToUnLockList = new List<Id>();
            trIdsToUnLockList.addAll(trIdToTransmittalToUpdateMap.keySet());
            RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
            lockUnlock.unlockRecord(trIdsToUnLockList);//Unlock adjusted for Offset Transmittal.
            update trIdToTransmittalToUpdateMap.values();//Update Stage of Transmittal.
            lockUnlock.lockRecord(trIdsToUnLockList);//Again lock the Transmittal.
        }
    }
}