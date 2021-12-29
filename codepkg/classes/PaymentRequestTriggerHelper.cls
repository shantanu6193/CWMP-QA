public with sharing class PaymentRequestTriggerHelper extends TriggerHelper {
    //Actions to perform before inserting the Payment Request Record...
    public override void processBeforeInsert() {
        preventPaymentRequestCreation(); //To Prevent creation of Paymnet Request if Project is not in "Active Payment " or "Deobligation" stage..
        autoPopulateActiveAward(); //To Auto populate Active Award in Payment Request...
        selectAdvancePaymentType(); //To allow to select Payment Type as Advance only when the Project is State Share only...
        autoUpdateSubRecipientAndFundingOppFields(); // To fetch Obligating Sub Recipient Name, Email, Funding Opportunity from Project....
        autoUpdateAllowAdminPayment(); //To Update Allow Admin Payment CheckBox. This method marks Allow Admin Payment Checkbox to true, if the PR Expenditure to Date is 0 and Payment Type is Reimbursement...
        updateTotalAdminShareAmount(); //This method is used to update the"Total Admin share Amount" on PR upon "Allow Admin Payment" checkbox change on PR...
        calculateStateSharesAndFederalSharesOfPaymentRequest(); //To calculate State and Federal Shares of the Payment Request...
        updateOverriddenPaymentAmount(); //To update the Overridden Payment Amount Automatically for the first time...
        updateTotalApprovedPaymentAmount(); //To update Total Approved Payment Amount...
        preventSelectingOtherFundingOppServiceLocation(); //To prevent selecting the Service Location which is not tied with the Funding opp of current Project...
        autoPopulateServiceLocation(); //To auto Populate Service Location if there is only one Service location for the Funding Opportunity....
        createProjectServiceJunction(); //If the selected Service Location is not tied with the Project but tied with Funding Opp, then to create a Project Service Location Junction record...
        updateIncidentAndSubRecipient(); // To update Sub Recipient and Incident field value from Project..
 /** This method is used validate that the Expenditure to Date on the PR is Cumulative Expenditures till date
         * for Reimbursement Type PR, Exception for Admin Only Payment. */
        cumulativeExpenditureValidationOnPr();
        //paymentProcessingFlagCalculationOfTheProject();
    }

    //Actions to be perform before updating the Payment Request Record....
    public override void processBeforeUpdate() {
    /** This method is used update the Award field of PR with Active Award of Project,
         * when the PR got rejected and it's Award is no longer Active now. */
        updateAwardFieldWithActiveAwardUponPrRejection();
    
	adjustedForOffsetValidationForPositiveTR();//Required field missing on Associated Transmittals - Adjusted For(Offset) validation.
        updateManagerFieldOnPR();//This method will update Manager field on PR if Approval process is Approved by Manager...
        preventPaymentRequestCreation(); //To Prevent creation of Payment Request if Project is not in "Active Payment " or "Closeout" stage..
/** Check Amount on Payment Request If it is Negative for Reimbursement type display Error. */
        checkNegativeApprovedAmounts();

        preventPrWithdrawnWithPostedTransmittal(); //This method is used to prevent user from Withdrawing the PR if there is a Transmittal already Approved/In Review on it.....
        preventStageChangeForPrWithWithdrawnTr();

        //preventSelectingOtherProjectAward(); //To prevent selecting the Award which is not associated with the current Project...
        selectAdvancePaymentType(); //To allow to select Payment Type as Advance only when the Project is State Share only...
        preventOnHoldProjectsPaymentProcessing(); //To prevent Payment request Processing If Project Status in On Hold....
        autoUpdateSubRecipientAndFundingOppFields();
       	autoUpdateAllowAdminPayment(); //To Update Allow Admin Payment CheckBox. This method marks Allow Admin Payment Checkbox to true, if the PR Expenditure to Date is 0 and Payment Type is Reimbursement...
        cumulativeExpenditureValidationOnPr();
        updateTotalAdminShareAmount(); //This method is used to update the"Total Admin share Amount" on PR upon "Allow Admin Payment" checkbox change on PR...
        calculateStateSharesAndFederalSharesOfPaymentRequest();
        //calculateStateSharesAndFederalShares(); // To fetch Obligating Sub Recipient Name, Email, Funding Opportunity from Project....
        updateOverriddenPaymentAmount(); ////To update the Overridden Payment Amount Automatically for the first time...
        updateTotalApprovedPaymentAmount();
        //fetchProjectFromAward(); //To assign Project name automatically upon selecting the Award record...
        preventSelectingOtherFundingOppServiceLocation(); //To prevent selecting the Service Location which is not tied with the Funding opp of current Project...
        autoPopulateServiceLocation(); //To auto Populate Service Location if there is only one Service location for the Funding Opportunity....
        createProjectServiceJunction(); //If the selected Service Location is not tied with the Project but tied with Funding Opp, then to create a Project Service Location Junction record...
        //updateIncidentAndSubRecipient();
        //paymentProcessingFlagCalculationOfTheProject();
		updateCurrentApprovedAmountOnPrIncludingCurrentPR();	
        //rejectionCommentRequired(); //Method to make Rejection Comment required on Approval Process of Payment Request
    }

    //Actions to be perform after Updating the Payment Request Record....
    	public override void processAfterUpdate() {
    	/** Ticket No - 886 */
        /** This method is used lock the Negative Offset Payment Request upon marking the Stage to "Payment Processing". */
        lockNegativeOffsetPaymentRequestRecordUponPaymentProcessingStage();
        updateTransmittalRecords(); // Updation must be done before, if any transmittal record exists...
        createTransmittalRecord(); //Create Transmittal Record for Payment Request...
        approveReturnedProjectPaymentTrUponPrApproval();
        //stateCostShareFlagCalculation();
        updateRequestedAmountCustomRollUpOnProjectForInsertAndUpdate();
        updateApprovedAmountCustomRollUpOnProjectForInsertAndUpdate();
        updateExpenditureToDateANDRetentionsOnProject();
        //updateRetentionToDateOnProject();
        //rejectionCommentRequired(); //Method to make Rejection Comment required on Approval Process of Payment Request
        withdrawTrUponPrWithdrawn(); //This method used to "Withdraw" the related Transmittal upon Payment Request Withdrawal....
    }

    //Actions to be perform after Inserting the Payment Request Record....
    public override void processAfterInsert() {
        //Create document after creation of project
        createDocuments(); // As per Sprint 5/6 requirement Automation is not needed anymore for Document creation...
        //stateCostShareFlagCalculation();
        updateRequestedAmountCustomRollUpOnProjectForInsertAndUpdate();
        updateApprovedAmountCustomRollUpOnProjectForInsertAndUpdate();
        updateExpenditureToDateANDRetentionsOnProject();
        //updateRetentionToDateOnProject();
    }
    //Actions to be performed before deleting Payment Request Record....
    public override void processBeforeDelete() {
        //stateCostShareFlagCalculation();
        updateApprovedAmountCustomRollUpOnProjectForDelete();
        updateRequestedAmountCustomRollUpOnProjectForDelete();
    }

    public override void processAfterDelete() {
        updateExpenditureToDateANDRetentionsOnProject();
    }

    //Actions to be performed after Undeleting the Payment Request Record....
    public override void processAfterUndelete() {
    //stateCostShareFlagCalculation();
        updateRequestedAmountCustomRollUpOnProjectForInsertAndUpdate();
        updateApprovedAmountCustomRollUpOnProjectForInsertAndUpdate();
        updateExpenditureToDateANDRetentionsOnProject();
    }

    /** Ticket No - 528 - Start */
    /*********************************************
	* Method Name : preventStageChangeForPrWithWithdrawnTr
	* Called From Method : BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used To prevent changing the PR stage from Withdrawn to back for processing the PR,
	*               If any of the Transmittal os Withdrawn for this PR.
	*********************************************/
    private void preventStageChangeForPrWithWithdrawnTr() {
        /** To collect the PR record whose Stage is getting updated from Withdrawn to back for processing. */
        Map<Id, Payment_Request__c> prIdToPrToProcessMap = new Map<Id, Payment_Request__c>();
        for(Payment_Request__c prToProcess : (List<Payment_Request__c>) Trigger.new) {
            /** Fetching old PR record to compare the Stage */
            Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(prToProcess.Id);
            /** Condition 1 - To check if PR stage is changed and old Stage of PR was "Withdrawn" */
            if(oldRecord.Stage__c != prToProcess.Stage__c
                    && oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn) {
                prIdToPrToProcessMap.put(prToProcess.Id, prToProcess);
            }
        }
        /** Condition to check for null pointer exception for prIdToPrToProcessMap collection */
        if(prIdToPrToProcessMap.size() > 0) {
            /** 1. Fetching PRs and its related Withdrawn Transmittals.
             * 2. Iterating the PRs.
             * 3. If there is nay Withdrawn TR then showing error to prevent Changing PR stage. */
            Map<Id, Payment_Request__c> prIdToPrWithTransmittalMap = new Map<Id, Payment_Request__c>([SELECT Id,
                                            (SELECT Id, Name, Stage__c FROM Transmittals__r WHERE Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Withdrawn)
                                        FROM Payment_Request__c WHERE Id IN : prIdToPrToProcessMap.keySet()]);
            for(Payment_Request__c paymentRequestToProcess : prIdToPrToProcessMap.values()) {
                if(prIdToPrWithTransmittalMap.get(paymentRequestToProcess.Id)?.Transmittals__r?.size() > 0) {
                    paymentRequestToProcess.addError('One or more Transmittals are in Withdrawn Stage. Please contact your System Admin');
                }
            }
        }
    }

    /*********************************************
	* Method Name : withdrawTrUponPrWithdrawn
	* Called From Method : AfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method used to "Withdraw" the related Transmittal upon Payment Request Withdrawal.
	*********************************************/
    private void withdrawTrUponPrWithdrawn() {
        /** To collect the Payment Requests which are getting Withdrawn */
        Map<Id, Payment_Request__c> prIdToPrToProcessMap = new Map<Id, Payment_Request__c>();
        for(Payment_Request__c prToProcess : (List<Payment_Request__c>) Trigger.new) {
            /** Fetching old PR record to compare the Stage */
            Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(prToProcess.Id);
            /** Condition 1 - To check if PR stage is changed and new Stage of PR was "Withdrawn" */
            if(oldRecord.Stage__c != prToProcess.Stage__c
                    && prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn) {
                prIdToPrToProcessMap.put(prToProcess.Id, prToProcess);
            }
        }
        /** Condition to check for null pointer exception for prIdToPrToProcessMap collection */
        if(prIdToPrToProcessMap.size() > 0) {
            List<Id> transmittalToLockList = new List<Id>();
            /** Fetching related Transmittal records of PR whose Id is available in prIdToPrToProcessMap collection keySet. */
            List<Transmittal__c> transmittalToWithdraw = [SELECT Id, Name, Stage__c, OwnerId, CreatedById, PaymentRequest__c,
                            PaymentRequest__r.Reason_To_Withdraw__c FROM Transmittal__c WHERE PaymentRequest__c IN : prIdToPrToProcessMap.keySet()];
            /** 1. Checking the Transmittal related list size, if it is greater than 0.
             * 2. Iterating the Transmittal list to Mark the Stage as WithDrawn and Reason to Withdraw is Same as PR's reason to Withdraw.
             * 3. Updating the Transmittal records.
             * 4. Locking the Transmittal records.*/
            if(transmittalToWithdraw?.size() > 0) {
                for (Transmittal__c transmittalToProcess : transmittalToWithdraw) {
                    transmittalToProcess.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Withdrawn;
                    transmittalToProcess.Reason_To_Withdraw__c = transmittalToProcess.PaymentRequest__r.Reason_To_Withdraw__c;
                    transmittalToLockList.add(transmittalToProcess.Id);
                }
                update transmittalToWithdraw; //Updating the Transmittals...

                RecordLockUnlockClass recordLockUnlock = new RecordLockUnlockClass();
                recordLockUnlock.lockRecord(transmittalToLockList); //Locking the Transmittals...
            }
        }
    }

    /*********************************************
	* Method Name : preventPrWithdrawnWithPostedTransmittal
	* Called From Method : BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to prevent user from Withdrawing the PR if there is a Transmittal already Approved/In Review/Paid on it.
	*********************************************/
    private void preventPrWithdrawnWithPostedTransmittal() {
        /** To collect the PR Id with PR Record, which are getting moved to Withdrawn Stage */
        Map<Id, Payment_Request__c> prIdToPrToProcessMap = new Map<Id, Payment_Request__c>();
        for (Payment_Request__c paymentRequest : (List<Payment_Request__c>)Trigger.new) {
            /** Fetching old PR record from Trigger.oldMap collection to compare PR stage. */
            Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(paymentRequest.Id);
            /** Condition 1 - To check if the PR stage is change to "Withdrawn" */
            if(oldRecord.Stage__c != paymentRequest.Stage__c
                    && paymentRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn) {
                prIdToPrToProcessMap.put(paymentRequest.Id, paymentRequest); //Putting PR record to Map collection...
            }
        }
        /** Condition to check for null pointer exception of the "prIdToPrToProcessMap" collection */
        if (prIdToPrToProcessMap.size() > 0) {
            /** Fetching the PR records and their related "Approved/Paid/In Review Transmittal" */
            Map<Id, Payment_Request__c> prIdToPrWithTransmittalMap = new Map<Id, Payment_Request__c>([SELECT Id, Stage__c,
                                                                        (SELECT Id, Stage__c FROM Transmittals__r
                                                                            WHERE Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Approved
                                                                            OR Stage__c =: ALS_CONSTANTS.Transmittal_Stage_Paid
                                                                            OR Stage__c =: ALS_CONSTANTS.Transmittal_Stage_InReview)
                                                                        FROM Payment_Request__c WHERE Id IN : prIdToPrToProcessMap.keySet()]);
            /** Iterating the PR records fetched from Query */
            for(Payment_Request__c prToProcess : prIdToPrWithTransmittalMap.values()) {
                /** Condition to check if there is any Approved/Paid/In Review Transmittal on PR */
                if (prToProcess.Transmittals__r?.size() > 0) {
                    Trigger.newMap.get(prToProcess.Id).addError('There are Transmittals, which are "Confirmed/Paid/In Review" on this Payment Request.');
                }
            }
        }
    }
    /** Ticket No - 528 - End */

    // To prevent creation or updation of Payment Request if Project is not in "Active Payment" or "Deobligation" stage...
    private void preventPaymentRequestCreation(){
        List<Payment_Request__c> prsToProcess = new List<Payment_Request__c>(); //To collect the Payment Request record for processing...
        Set<Id> projectIds = new Set<Id>(); //To collect the Project Id of Payment Request..
        Map<Id,Project__c> idToProjectMap = new Map<Id,Project__c>(); //To fetch the Project records whose Ids are available in Set collection..
        for(Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new){
            //Condition to check if the External Id is available for the PR, As we does not need this validation for migrated PR...
            if(pRequests.External_Id__c == null) {
                projectIds.add(pRequests.Project__c); // Adding the Project Id to the collection.....
                prsToProcess.add(pRequests); //Adding the Payment Request to collection toProcess.....
            }
        }
        if (projectIds.size() > 0) {
            //Fetching the Project records whose IDs are available in Set Collection...
            idToProjectMap = new Map<Id,Project__c>([SELECT Id, Name, Reason_To_Withdraw__c, Stage__c FROM Project__c WHERE Id IN : projectIds]);
            if(idToProjectMap.size() > 0){ //Checking for null pointer exception...
                for(Payment_Request__c pRequestToProcess : prsToProcess) { //Iterating the Payment Request collection for processing....
                    Project__c projectToProcess = idToProjectMap.get(pRequestToProcess.Project__c); //Fetching the Project record from Project map...
                    Payment_Request__c oldRecord = new Payment_Request__c();
                    if(Trigger.isUpdate) {
                        oldRecord = (Payment_Request__c)Trigger.oldMap.get(pRequestToProcess.Id);
                    }

                    //Trigger.IsUpdate condition is added as Exception due to allowing the user to auto update the PR to stage Withdrawn upon Project Withdrawal.....
                    if(Trigger.isUpdate
                            && oldRecord.Stage__c != pRequestToProcess.Stage__c
                            && pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn
                            && projectToProcess.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn
                            && oldRecord.Reason_To_Withdraw__c != pRequestToProcess.Reason_To_Withdraw__c) {
                        continue;
                    }
                    //Condition to check whether the Project Stage is either "Active Payment" or "Closeout" as we only allow to create or Update the PR in these two Stages of Project.....
                    //Except these two stages, User are not allowed to create PR in any other Stage of Project...
                    else if((projectToProcess.Stage__c != ALS_CONSTANTS.Project_Stage_ActivePayment
                            && projectToProcess.Stage__c != ALS_CONSTANTS.Project_Stage_Closeout)) {
                        pRequestToProcess.addError('You can Create/Update Payment Request only when the Project is in "Active Payment" or "Closeout" Stage.');
                    }
                }
            }
        }
    }

    //To Auto populate Active Award in Payment Request...
    private void autoPopulateActiveAward() {
        Set<Id> projectIds = new Set<Id>(); //To collect the Project Id of The Payment Request...
        List<Payment_Request__c> paymentRequestsToProcess = new List<Payment_Request__c>(); //To collect the Payment Request record for Processing...
        if (Trigger.isInsert) { //To check if the record is getting inserted ..
            paymentRequestsToProcess = Trigger.new; //Collecting the PRs to process..
        }
        if (Trigger.isUpdate) { //To check if the record is getting updated.....
            for (Payment_Request__c pRequest : (List<Payment_Request__c>) Trigger.new) {
                //Condition to check whether the Award field is null while updating the Payment Request...
                if (pRequest.Award__c == null) {
                    paymentRequestsToProcess.add(pRequest); //Collecting the PRs to process..
                }
            }
        }
        //Checking for null pointer exception for "paymentRequestsToProcess" collection size....
        if (paymentRequestsToProcess.size() > 0) {
            for (Payment_Request__c pRequest : paymentRequestsToProcess) {
                projectIds.add(pRequest.Project__c); // Add the project Id to Set Collection..
            }
            //Fetching the Project record and its active Award record from Database...
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Name,
                                                        (SELECT Id, Status__c FROM Awards__r
                                                        WHERE Status__c =: ALS_CONSTANTS.Award_Status_Active LIMIT 1)
                                                FROM Project__c WHERE Id IN :projectIds]);
            for (Payment_Request__c pRequest : paymentRequestsToProcess){
                Award__c awardToProcess = projectMap.get(pRequest.Project__c).Awards__r; //Fetching Active Award of the Project which is selected in Payment Request...
                pRequest.Award__c = awardToProcess.Id; //Assigning Award value to the Payment Request...
            }
        }
    }

    //To auto Populate Service Location if there is only one Service location for the Funding Opportunity....
    private void autoPopulateServiceLocation(){
        Set<Id> fundingOppIds = new Set<Id>(); //To collect the Funding Opp Id of The Payment Request...
        Set<Id> projectIds = new Set<Id>(); //To collect the Project Id of the PR.....
        List<Payment_Request__c> paymentRequestsToProcess = new List<Payment_Request__c>(); //To collect the Payment Request record for Processing...

        if (Trigger.isInsert) { //To check if the record is getting inserted.....
            paymentRequestsToProcess = Trigger.new; //Collecting the PRs to process..
        }
        if (Trigger.isUpdate) { //To check if the record is getting updated.....
            for (Payment_Request__c pRequest : (List<Payment_Request__c>) Trigger.new) {
                if (pRequest.Service_Location__c == null ) { //To check if the Service Location value is null....
                    paymentRequestsToProcess.add(pRequest); //Collecting the PRs to process..
                }
            }
        }
        if(paymentRequestsToProcess.size() > 0){
            for (Payment_Request__c pRequest : (List<Payment_Request__c>) Trigger.new) {
                projectIds.add(pRequest.Project__c); //To collect the Project Id t collection...
            }
            //Fetching the Project record data...
            Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>([SELECT Id, Funding_Opportunity_Name__c
                                                                            FROM Project__c WHERE Id IN : projectIds]);
            for (Project__c project : idToProjectMap.values()){
                fundingOppIds.add(project.Funding_Opportunity_Name__c); //Collecting funding Opp id of the Project...
            }
            //Fetching the Funding opp and its related FundingOpp service Location Junction...
            Map<Id, Funding_Opportunity__c> fundingOppsToServiceLocationMap = new Map<Id, Funding_Opportunity__c>([SELECT Id,
                                                                (SELECT Id, Service_Location__c FROM Funding_Opp_Service_Location_Junctions__r)
                                                        FROM Funding_Opportunity__c WHERE Id IN : fundingOppIds]);
            for (Payment_Request__c pRequestToProcess : paymentRequestsToProcess){ //Iterating the PR collection to process..
                //fetching the Funding Opp Service Location Junction from Map Collection...
                List<FundingOppServiceLocationJunction__c> fundingOppServiceOppJunctions = fundingOppsToServiceLocationMap?.get(idToProjectMap.get(pRequestToProcess.Project__c)?.Funding_Opportunity_Name__c)?.Funding_Opp_Service_Location_Junctions__r;
                if (fundingOppServiceOppJunctions.size() == 1) { //To check if there is only one Service Location related to the Funding opp of the Project of the PR...
                    pRequestToProcess.Service_Location__c = fundingOppServiceOppJunctions[0].Service_Location__c; //Assigning the Funding Opp Service Location to PR Service Location...
                }
            }
        }
    }

    //To allow to select Payment Type as Advance only when the Project is State Share only...
    private void selectAdvancePaymentType() {
        Set<Id> projectIds = new Set<Id>(); //To store the project Id which we are going to use in Payment request record...
        List<Payment_Request__c> paymentRequestsToProcess = new List<Payment_Request__c>(); //To collect the Payment Request record for Processing.
        if (Trigger.isInsert) { //To check if the record is getting inserted.....
            for (Payment_Request__c pRequest : (List<Payment_Request__c>) Trigger.new) {
                //Condition to check if the External Id is available for the PR, As we does not need this validation for migrated PR...
                if (pRequest.External_Id__c == null) {
                    paymentRequestsToProcess.add(pRequest); //Adding the Payment Request record to collection...
                }
            }
        }
        if (Trigger.isUpdate) { //To check if the record is getting updated.....
            for (Payment_Request__c pRequest : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(pRequest.Id); //fetching the old Record from Trigger.oldMap collection.....
                //Condition to check if the External Id is available for the PR, As we does not need this validation for migrated PR.....
                // Condition to check if Payment type is changed to Advance.....
                if (pRequest.External_Id__c == null
                        && pRequest.PaymentType__c != oldRecord.PaymentType__c
                        && pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Advance) {
                    paymentRequestsToProcess.add(pRequest); //Adding the Payment Request record to collection...
                }
            }
        }
        //Condition to check for null pointer exception for the "paymentRequestsToProcess" collection...
        if (paymentRequestsToProcess.size() > 0) {
            for (Payment_Request__c pRequest : paymentRequestsToProcess) { //Iterating PR to process collection....
                if (pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Advance) { // Condition to check if Payment type is Advance..
                    projectIds.add(pRequest.Project__c); // Add the project Id to Set Collection..
                }
            }
            //Fetching all the Project record whose ID are available in Set Collection..
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Name, FundingSource__c FROM Project__c WHERE Id IN :projectIds]);

            for (Payment_Request__c pRequest : paymentRequestsToProcess) {
                Project__c project = projectMap?.get(pRequest.Project__c); // Fetching the Project record of the current Payment request..
                // Condition to check if Project's Funding Source is "State Only"....
                //User is allowed to select the PR Type as Advance, Only if the Project's Funding Source is "State Only"...
                if (project?.FundingSource__c != ALS_CONSTANTS.Project_FundingSource_StateOnly
                        && pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Advance) {
                    pRequest.addError('You can select Payment Type as Advance, only if the Project is State Share only.');
                }
            }
        }
    }

    //To prevent Payment request Processing If Project Status in On Hold, Except the Offset Type PR and Upon Transmittal Rejection PR Stage moved to Processing.........
    private void preventOnHoldProjectsPaymentProcessing() {
        Set<Id> projectIds = new Set<Id>(); //To store the project Id which we are going to use in Payment request record...
        List<Payment_Request__c> paymentRequestsToProcess = new List<Payment_Request__c>(); //To collect the Payment Request record for Processing.
        for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) { //Iterating PR from Trigger.new collection....
            Payment_Request__c oldDocRecord = (Payment_Request__c) (Trigger.oldMap.get(payRequest.Id)); //Getting the old Payment Request record from trigger.Oldmap
            //Condition to check if the PR Stage has been changed and PR Type is not Offset...
            //Excluding the Offset type PR, because Offset PR needs to be Processed in order to balance the Negative Amount on Project....
            if (oldDocRecord.Stage__c != payRequest.Stage__c
                    && payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_Offset
                    && payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment) {
                projectIds.add(payRequest.Project__c); //Adding Project ID to Set Collection...
                paymentRequestsToProcess.add(payRequest); //Adding the Payment Request to collection..
            }
        }
        //Condition to check for null pointer exception for "projectIds" collection....
        if (projectIds.size() > 0) {
            //Fetching all the Project record whose ID is available in Set Collection.....
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Name, Stage__c, Status__c FROM Project__c WHERE Id IN :projectIds]);

            for (Payment_Request__c payRequest : paymentRequestsToProcess) { //Iterating PR to process collection...
                Payment_Request__c oldDocRecord = (Payment_Request__c) (Trigger.oldMap.get(payRequest.Id)); //Getting the old Payment Request record from trigger.Oldmap
                Project__c pRecord = projectMap.get(payRequest.Project__c); //Fetching the Project record from Map collection...
                if(oldDocRecord.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                        && payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation
                        && pRecord.Status__c == ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery) {
                    //Allow changing the Stage as this is the condition when Transmittal gets rejected by Accounting and PR moves from "Payment Processing" to "Reviewed - Need More Information" Stage...
                    continue;
                }
                else if (pRecord.Status__c == ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery) { //Condition to check if Project Status is On-Hold....
                    payRequest.addError('You cannot process any Payment, If the Project Status is On Hold.');
                }
            }
        }
    }

    //This method is used to autoUpdate the Sub recipient and Funding Opp fields on PR....
    private void autoUpdateSubRecipientAndFundingOppFields(){
        Set<Id> projectIds = new Set<Id>(); //To collect the Project Ids.....
        List<Payment_Request__c> pRequestsToProcess = new List<Payment_Request__c>(); //To collect the PR for processing...
        if (Trigger.isInsert) { //To check if the record is getting inserted.....
            pRequestsToProcess = Trigger.new;
        }
        if (Trigger.isUpdate) { //To check if the record is getting Updated.....
            for (Payment_Request__c payRequest : (List<Payment_Request__c>)Trigger.new){
                Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(payRequest.Id); //fetching the old record from Trigger.oldMap collection...
                if (payRequest.Project__c != oldRecord.Project__c) { //Checking for null pointer exception...
                    pRequestsToProcess.add(payRequest); //Adding the PR to colelction for processing...
                }
            }
        }
        //Condition to check for null pointer exception of "pRequestsToProcess" collection...
        if (pRequestsToProcess.size() > 0) {
            for (Payment_Request__c payRequest : (List<Payment_Request__c>)Trigger.new){
                projectIds.add(payRequest.Project__c); //Adding the Project Id to collection...
            }
            //Fetching the Project record data whose Id are available in Set collection...
            Map<Id,Project__c> idToProjectMap = new Map<Id, Project__c>([SELECT Id, Name, Obligating_Sub_Recipient__c, StateAdmin__c, Obligating_Sub_Recipient__r.Name, Obligating_Sub_Recipient__r.Email_Address__c, Funding_Opportunity_Name__c FROM Project__c WHERE Id IN : projectIds]);
            for (Payment_Request__c pRequestToProcess : pRequestsToProcess){
                Project__c pRecord = idToProjectMap.get(pRequestToProcess.Project__c); //Fetching the Project record data from Map collection...
                //Update Obligating Sub Recipient Name and Email..
                pRequestToProcess.Sub_Recipient_Name__c = pRecord.Obligating_Sub_Recipient__r.Name;
                pRequestToProcess.Sub_Recipient_Email__c = pRecord.Obligating_Sub_Recipient__r.Email_Address__c;
                //Update Funding Opportunity from Project...
                pRequestToProcess.Funding_Opportunity__c = pRecord.Funding_Opportunity_Name__c;
            }
        }
    }

    //To Update Allow Admin Payment CheckBox. This method marks Allow Admin Payment Checkbox to true, if the PR Expenditure to Date is 0 and Payment Type is Reimbursement...
    private void autoUpdateAllowAdminPayment() {
        for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
            //Condition to check if the External ID is not null for PR, as we dont need this validation for Migrated PRs...
            //Condition to check if the Expenditure to Date is 0 and Payment Type is "Reimbursement" in order to update "Allow Admin Payment" checkbox...
            //The reason being is for Admin Only PR -  Expenditure to Date is 0 and Payment Type is "Reimbursement"
            if (payRequest.External_Id__c == null
                    && payRequest.ExpenditurestoDate__c == 0
                    && payRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement) {
                payRequest.Allow_Admin_Payment__c = true; //Updating the "Allow Admin Payment" checkbox on PR....
            }
        }
    }

    //This method is used to update the"Total Admin share Amount" on PR upon "Allow Admin Payment" checkbox change on PR...
    private void updateTotalAdminShareAmount() {
        //To collect the PRs for which we need to update the "Total Admin Share Amount"....
        List<Payment_Request__c> prListToProcess = new List<Payment_Request__c>();
        List<Id> prIdToUnlockList = new List<Id>();
        Set<Id> projectIds = new Set<Id>(); //To collect the project Dis of PR
        if (Trigger.isInsert) {
            for (Payment_Request__c payRequest : (List<Payment_Request__c>)Trigger.new) {
                //Condition to check if the External Id is null for PR as we don't need to do this automation for those...
                if (payRequest.External_Id__c == null) {
                    prListToProcess.add(payRequest); //Adding PR to collection...
                    projectIds.add(payRequest.Project__c); //Adding project Id to collection...
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Payment_Request__c payRequest : (List<Payment_Request__c>)Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(payRequest.Id); //fetching the old record from Trigger.oldMap...
                //Condition to check if the External Id is null and "Allow Admin payment" checkbox value has been changed....
                if (payRequest.External_Id__c == null
                        && (payRequest.Allow_Admin_Payment__c != oldRecord.Allow_Admin_Payment__c
                            || (oldRecord.Stage__c != payRequest.Stage__c
                                && (oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                                    && (payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation
                                        || payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Processing))))) {
                    if (Approval.isLocked(payRequest.Id)
                            && oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                            && (payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation
                            || payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Processing)) {
                        //Approval.unlock(payRequest.Id);
                        prIdToUnlockList.add(payRequest.Id);
                        prListToProcess.add(payRequest); //Adding the PR to collection for processing...
                        projectIds.add(payRequest.Project__c); //Adding project Id to collection...
                    }
                    else if (!Approval.isLocked(payRequest.Id)) {
                        prListToProcess.add(payRequest); //Adding the PR to collection for processing...
                    projectIds.add(payRequest.Project__c); //Adding project Id to collection...
                }
                    //prListToProcess.add(payRequest); //Adding PR to collection...
                    //projectIds.add(payRequest.Project__c); //Adding project Id to collection...
                }
            }
        }
        //Checking for null Pointer exception for the Project ID collection...
        if (projectIds.size() > 0) {
            if (prIdToUnlockList?.size() > 0 ) {
                RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
                lockUnlock.unlockRecord(prIdToUnlockList);
            }
            //Updated the code for Ticket - 370 - Start
            //Fetching the Project record whose Id is available in collection...
            Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>([SELECT Id, PaytoStateAdmin__c, AvailableAdminAmount__c,
                                                                Total_Admin_Amount_Approved__c, Net_Admin_Amount_Available__c
                                                                FROM Project__c WHERE Id IN : projectIds]);
            for (Payment_Request__c payRequest : prListToProcess) {
                Project__c project = idToProjectMap.get(payRequest.Project__c); //Fetching the related Project of PR from Map collection...
                //Condition to check if the "Pay to Sate Admin" checkbox of Project is true and "Allow Admin Payment" of PR is true...
                //This condition needs to satisfy to Pay Admin Payment for a Project...
                if (project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes && payRequest.Allow_Admin_Payment__c == true) {
                    payRequest.TotalAdminShareAmount__c = project.Net_Admin_Amount_Available__c?.setScale(2,system.RoundingMode.DOWN); //Updating the "Total Admin Share" value of the PR...
                    //Updated the code for Ticket - 370 - End
                }
                else {
                    payRequest.TotalAdminShareAmount__c = 0;
                }
            }
        }
    }

    // To calculate the value of State Shares and Federal Shares values.....
    private void calculateStateSharesAndFederalSharesOfPaymentRequest() {
        Set<Id> projectIds = new Set<Id>(); //To store the project Id which we are going to use in Payment request record...
        List<Id> prIdToUnlockList = new List<Id>();
        List<Payment_Request__c> paymentRequestsToProcess = new List<Payment_Request__c>(); //To collect the Payment Request record for Processing.
        if (Trigger.isInsert) { //To check if the record is getting inserted.....
            //paymentRequestsToProcess = Trigger.new;
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                if (payRequest.External_Id__c == null) {
                    paymentRequestsToProcess.add(payRequest);
                }
            }
        }
        if (Trigger.isUpdate) { //To check if the record is getting Updated.....
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(payRequest.Id); //Fetching the old record from Trigget.oldMap collection...
                if (payRequest.External_Id__c == null &&
                        (payRequest.ExpenditurestoDate__c != oldRecord.ExpenditurestoDate__c
                                || payRequest.TotalAdminShareAmount__c != oldRecord.TotalAdminShareAmount__c
                                || payRequest.PaymentType__c != oldRecord.PaymentType__c
                                || payRequest.Project__c != oldRecord.Project__c
                                || (oldRecord.Stage__c != payRequest.Stage__c
                                    && (oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                                        && (payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation
                                            || payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Processing))))) { //Checking if the Expenditure to data or Project has been changed and PR is not Approval locked..
                    if (Approval.isLocked(payRequest.Id)
                            && oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                            && (payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation
                                    || payRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Processing)) {
                        //Approval.unlock(payRequest.Id);
                        prIdToUnlockList.add(payRequest.Id);
                    paymentRequestsToProcess.add(payRequest); //Adding the PR to collection for processing...
                }
                    else if (!Approval.isLocked(payRequest.Id)) {
                        paymentRequestsToProcess.add(payRequest); //Adding the PR to collection for processing...
                    }
            	}
        	}
        }

        if (paymentRequestsToProcess.size() > 0) {
            if (prIdToUnlockList?.size() > 0 ) {
                RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
                lockUnlock.unlockRecord(prIdToUnlockList);
            }
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                projectIds.add(payRequest.Project__c); //Adding the Project to set collection...
            }
            //Fetching the Project record whose Id are available in Set collection...
            //Updated the code for Ticket - 370 - Start
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Name, Program_Name__r.Name, TotalProjectStateAdminShare__c,
                    AvailableAdminAmount__c, FEMA_Share__c, Federal_Retention__c, State_Share__c, State_Retention__c, FundingSource__c,
                    PaytoStateAdmin__c, EligibleforStateAdminShare__c, StateAdmin__c, Total_State_Amount_Approved__c,
                            Total_Federal_Amount_Approved__c, Total_Admin_Amount_Approved__c, Net_Admin_Amount_Available__c,
                            (SELECT Id FROM Payment_Requests__r) FROM Project__c WHERE Id IN :projectIds]);

            for (Payment_Request__c payRequest : paymentRequestsToProcess) {
                Project__c pRecord = projectMap.get(payRequest.Project__c); //Fetching the Project record from Map Collection.....
                //Checking for null pointer exceptions...
                Decimal expenditureToDate = payRequest.ExpenditurestoDate__c == null?0.00:payRequest.ExpenditurestoDate__c;
                Decimal stateShare = pRecord.State_Share__c == null?0.00:pRecord.State_Share__c;
                Decimal stateRetention = pRecord.State_Retention__c == null?0.00:pRecord.State_Retention__c;
                Decimal stateAdminShare = pRecord.StateAdmin__c == null?0.00:pRecord.StateAdmin__c;
                Decimal federalShare = pRecord.FEMA_Share__c == null?0.00:pRecord.FEMA_Share__c;
                Decimal federalRetention = pRecord.Federal_Retention__c == null?0.00:pRecord.Federal_Retention__c;
                Decimal federalAmountApprovedToDate = pRecord.Total_Federal_Amount_Approved__c == null ? 0.00 : pRecord.Total_Federal_Amount_Approved__c;
                Decimal stateAmountApprovedToDate = pRecord.Total_State_Amount_Approved__c == null ? 0.00 : pRecord.Total_State_Amount_Approved__c;

                /** Ticket - 969 - Start */
                Decimal adminAmountApprovedToDate = pRecord.Total_Admin_Amount_Approved__c == null ? 0.00 : pRecord.Total_Admin_Amount_Approved__c;
                Decimal totalAdminShareOfPr = payRequest.TotalAdminShareAmount__c == null ? 0.00 : payRequest.TotalAdminShareAmount__c;

				payRequest.In_Review_State_Amount_Approved__c = stateAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                payRequest.In_Review_State_Share__c = stateShare?.setScale(2,system.RoundingMode.DOWN);
                payRequest.In_Review_State_Retention__c = stateRetention?.setScale(2,system.RoundingMode.DOWN);

                payRequest.In_Review_Federal_Amount_Approved__c = federalAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                payRequest.In_Review_FEMA_Share__c = federalShare?.setScale(2,system.RoundingMode.DOWN);
                payRequest.In_Review_Federal_Retention__c = federalRetention?.setScale(2,system.RoundingMode.DOWN);

                payRequest.In_Review_Admin_Amount_Approved__c = adminAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                payRequest.Review_Pending_Admin_Amount_Available__c = (pRecord.Net_Admin_Amount_Available__c  == null ? 0.00 : pRecord.Net_Admin_Amount_Available__c)?.setScale(2,system.RoundingMode.DOWN);

                /*payRequest.InReview_State_and_Admin_Amount_Approved__c = (payRequest.In_Review_State_Amount_Approved__c
                        + payRequest.In_Review_Admin_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);
                payRequest.InReview_State_and_Fed_Amount_Approved__c = (payRequest.In_Review_State_Amount_Approved__c
                        + payRequest.In_Review_Federal_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);
                payRequest.In_Review_Total_Amount_Approved__c = (payRequest.In_Review_State_Amount_Approved__c
                        + payRequest.In_Review_Federal_Amount_Approved__c + payRequest.In_Review_Admin_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);*/

                payRequest.Reviewed_Federal_Amount_Approved_to_Date__c = federalAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                payRequest.Reviewed_State_Amount_Approved_to_Date__c = stateAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                payRequest.Reviewed_Admin_Amount_Approved_to_Date__c = adminAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                payRequest.Reviewed_State_and_Admin_Amount_Approved__c = (payRequest.Reviewed_State_Amount_Approved_to_Date__c
                        + payRequest.Reviewed_Admin_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                payRequest.Reviewed_State_and_Fed_Amount_Approved__c = (payRequest.Reviewed_Federal_Amount_Approved_to_Date__c
                        + payRequest.Reviewed_State_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                payRequest.Reviewed_Total_Amount_Approved__c = (payRequest.Reviewed_Federal_Amount_Approved_to_Date__c
                        + payRequest.Reviewed_State_Amount_Approved_to_Date__c
                        + payRequest.Reviewed_Admin_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                /** Ticket - 969 - End */

                //Calculation for Admin Only Payment...
                if(payRequest.ExpenditurestoDate__c == 0
                        && payRequest.Allow_Admin_Payment__c == true
                        && payRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement ) {
                    //Updating State Estimated Payment Amount value with Total Admin Share Amount of the PR...
                    payRequest.StateEstimatedPaymentAmount__c = totalAdminShareOfPr;

                    //Setting remaining field value as 0...
                    payRequest.StateCostShare__c = 0;
                    payRequest.StateRetentionShare__c = 0;
                    payRequest.FederalShareCost__c = 0;
                    payRequest.FederalRetentionShare__c = 0;
                    payRequest.FederalEstimatedPaymentAmount__c = 0;
                }
                else if (payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_FinalPayment
                        && payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_Offset
                        && payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment) {
                    //State Share Calculations....
                    if (pRecord.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly
                            || pRecord.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
                        //Calculating "State Cost Share"...
                        payRequest.StateCostShare__c = ((expenditureToDate * stateShare) / 100)?.setScale(2,system.RoundingMode.DOWN);
                        //State Retention Share.....
                        payRequest.StateRetentionShare__c = ((payRequest.StateCostShare__c * stateRetention) / 100)?.setScale(2,system.RoundingMode.DOWN);
                        //State Admin Share....
                        if (pRecord.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes) {
                            payRequest.StateAdminShare__c = ((payRequest.StateCostShare__c * stateAdminShare) / 100)?.setScale(2,system.RoundingMode.DOWN);
                        }
                        //Estimated State Payment Amount.....
                        payRequest.StateEstimatedPaymentAmount__c = (payRequest.StateCostShare__c - payRequest.StateRetentionShare__c
                                - stateAmountApprovedToDate + totalAdminShareOfPr)?.setScale(2,system.RoundingMode.DOWN);
                    }
                    else {
                        payRequest.StateCostShare__c = 0;
                        payRequest.StateRetentionShare__c = 0;
                        payRequest.StateAdminShare__c = 0;
                        payRequest.StateEstimatedPaymentAmount__c = 0;
                        payRequest.ApprovedStatePaymentAmount__c = 0;
                    }
                    //Federal Share Calculations....
                    if (pRecord.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly
                            || pRecord.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
                        //Federal Cost Share....
                        payRequest.FederalShareCost__c = ((expenditureToDate * federalShare) / 100)?.setScale(2,system.RoundingMode.DOWN);
                        //Federal Retention Share....
                        payRequest.FederalRetentionShare__c = ((payRequest.FederalShareCost__c * federalRetention) / 100)?.setScale(2,system.RoundingMode.DOWN);

                        //Federal Estimated Payment Amount....
                        payRequest.FederalEstimatedPaymentAmount__c = (payRequest.FederalShareCost__c - payRequest.FederalRetentionShare__c
                                                    - federalAmountApprovedToDate)?.setScale(2,system.RoundingMode.DOWN);
                    }
                    else {
                        payRequest.FederalShareCost__c = 0;
                        payRequest.FederalRetentionShare__c = 0;
                        payRequest.FederalEstimatedPaymentAmount__c = 0;
                        payRequest.ApprovedFederalPaymentAmount__c = 0;
                    }
                    //Updated the code for Ticket - 370 - End
                }
            }
        }
    }

    //To update the Overridden Payment Amount Automatically for the first time...
    private void updateOverriddenPaymentAmount() {
        Set<Id> projectIds = new Set<Id>(); //To collect the Project Ids...
        List<Payment_Request__c> pRequestsToProcess = new List<Payment_Request__c>();
        if (Trigger.isInsert) { //To check if the record is getting inserted.....
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                if (payRequest.External_Id__c == null) {
                    pRequestsToProcess.add(payRequest);
                }
            }
        }
        if (Trigger.isUpdate) { //To check if the record is getting Updated.....
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(payRequest.Id); //Fetching the old PR record...
                //Condition to check if the "State Estimated Payment Amount / Federal Estimated Payment Amount" has been changed...
                if (payRequest.External_Id__c == null
                        && (payRequest.StateEstimatedPaymentAmount__c != oldRecord.StateEstimatedPaymentAmount__c
                        || payRequest.FederalEstimatedPaymentAmount__c != oldRecord.FederalEstimatedPaymentAmount__c)) {
                    pRequestsToProcess.add(payRequest); //Adding the PR record into collection for processing...
                }
            }
        }
        //Condition to check for null pointer exception for "pRequestsToProcess" collection....
        if (pRequestsToProcess.size() > 0) {
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                projectIds.add(payRequest.Project__c); //Collecting the Project Id of the PRs....
            }
            //Fetching the Project record data whose Id is present in collection....
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Name, FundingSource__c FROM Project__c WHERE Id IN :projectIds]);

            for (Payment_Request__c payRequest : pRequestsToProcess) { //Iterating the PRs collection for processing...
                Project__c projectToProcess = projectMap.get(payRequest.Project__c); //Fetching the Project record of the PR...
                if (payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_FinalPayment
                        && payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_Offset
                        && payRequest.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                        && (Trigger.isInsert || (Trigger.isUpdate && !Approval.isLocked(payRequest.Id)))) {
                    //Copy "State Estimated Amount" into "Approved State Payment Amount"....
                    if (projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly
                                || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) { //Condition to check if State Estimated Payment Amount is value in Null...payRequest.ApprovedStatePaymentAmount__c == null
                        payRequest.ApprovedStatePaymentAmount__c = payRequest.StateEstimatedPaymentAmount__c;
                    }
                    //Copy "State Estimated Amount" into "Approved State Payment Amount"....
                    if (projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly
                            || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) { //Condition to check if Federal Estimated Payment Amount is value in Null...payRequest.ApprovedFederalPaymentAmount__c == null
                        payRequest.ApprovedFederalPaymentAmount__c = payRequest.FederalEstimatedPaymentAmount__c;
                    }
                }
            }
        }
    }

    private void updateTotalApprovedPaymentAmount() {
        //Set<Id> projectIds = new Set<Id>(); //To collect the Project Ids...
        List<Payment_Request__c> pRequestsToProcess = new List<Payment_Request__c>();
        if (Trigger.isInsert) { //To check if the record is getting inserted.....
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                if (payRequest.External_Id__c == null) {
                    pRequestsToProcess.add(payRequest);
                }
            }
        }
        if (Trigger.isUpdate) { //To check if the record is getting Updated.....
            for (Payment_Request__c payRequest : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(payRequest.Id); //Fetching the old PR record...
                //Condition to check if the "State Estimated Payment Amount / Federal Estimated Payment Amount" has been changed...
                if (payRequest.External_Id__c == null &&
                        (payRequest.ApprovedStatePaymentAmount__c != oldRecord.ApprovedStatePaymentAmount__c
                        || payRequest.ApprovedFederalPaymentAmount__c != oldRecord.ApprovedFederalPaymentAmount__c)) {
                    pRequestsToProcess.add(payRequest); //Adding the PR record into collection for processing...
                }
            }
        }

        if (pRequestsToProcess.size() > 0) {
            for (Payment_Request__c payRequest : pRequestsToProcess) {
                //Calculating "Total Approved Payment Amount"....
                Decimal approvedStatePaymentAmount = payRequest.ApprovedStatePaymentAmount__c == null?0.00:payRequest.ApprovedStatePaymentAmount__c;
                Decimal approvedFederalPaymentAmount = payRequest.ApprovedFederalPaymentAmount__c == null?0.00:payRequest.ApprovedFederalPaymentAmount__c;
                Decimal totalStateAdminShare = payRequest.TotalAdminShareAmount__c == null?0.00:payRequest.TotalAdminShareAmount__c;

                payRequest.TotalApprovedPaymentAmount__c = (approvedStatePaymentAmount + approvedFederalPaymentAmount)?.setScale(2,system.RoundingMode.DOWN);

                payRequest.Approved_Amount_Total__c = (payRequest.TotalApprovedPaymentAmount__c - totalStateAdminShare);
                payRequest.Approved_State_only_Amount__c = (payRequest.Approved_Amount_Total__c - approvedFederalPaymentAmount);
            }
        }
    }

    //Create documents for PR...
    private void createDocuments() {
        //List<String> prIdsAll = new List<String>();
        //List<String> programNameList = new List<String>();
        Set<Id> prIds = new Set<Id>();
        //Fetching all the Payment Request which are inserted and ID is in Trigger.new...
        List<Payment_Request__c> paymentRequestAll = [SELECT Id, Project__r.Id, Project__r.Program_Name__c,External_Id__c FROM Payment_Request__c WHERE Id IN :(List<Payment_Request__c>) Trigger.new];

        for (Payment_Request__c pr : paymentRequestAll) { //Iterating the Payment Request collection.....
            if (pr.Project__r.Program_Name__c != null && pr.External_Id__c == null) {
                //programNameList.add(pr.Project__r.Program_Name__c); //Fetching the Program Name from project and adding to collection...
                prIds.add(pr.Id); //Collecting the PR Ids for which Document is tom create...
            }
        }
        new CreatePaymentRequestDocument().handle(prIds); //Calling another Class method to create the Documents for PR record...
    }

    //Create Transmittal Record for Payment Request...
    private void createTransmittalRecord() {
        List<Id> PaymentRequestToProcessList = new List<Id>();  //To collect Payment Request to Process.....
        for (Payment_Request__c paymentToProcess : (List<Payment_Request__c>) Trigger.new) { //Iterating Trigger.new collection to collect the PR record for processing...
            Payment_Request__c paymentRequestOld = (Payment_Request__c) Trigger.oldMap.get(paymentToProcess.Id); //Fetching Old PR record from Trigger.oldMap collection...
            if (paymentToProcess.Stage__c != paymentRequestOld.Stage__c && paymentToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing) {
                //Condition to check if the PR Stage changed to "Payment Processing"....
                PaymentRequestToProcessList.add(paymentToProcess.Id); //Adding the PR record to the collection for processing...
            }
        }
        //Condition to check for null pointer exception for "PaymentRequestToProcessList" collection...
        if (PaymentRequestToProcessList.size() > 0) {
            ALS_TransmittalUtiity.createTransmittalRecord(PaymentRequestToProcessList); //Calling another Class method to create the Transmittal for PR record...
        }

        /*
        Map<Id, Payment_Request__c> paymentRequestRecordMap = new Map<Id, Payment_Request__c>([SELECT Id, Name, Project__c, Project__r.Name, Project__r.FundingSource__c, (SELECT Id FROM Transmittals__r) FROM Payment_Request__c WHERE Id IN :idToPaymentRequestToProcessMap.keySet()]);
        List<Transmittal__c> transmittalToInsertList = new List<Transmittal__c>();


        for (Payment_Request__c paymentUnderProcessing : paymentRequestRecordMap.values()) {
            if (paymentUnderProcessing.Transmittals__r?.size() == 0) {
                if (paymentUnderProcessing.Project__r.FundingSource__c == 'Federal and State' || paymentUnderProcessing.Project__r.FundingSource__c == 'State Only') {
                    Payment_Request__c prRecordToProcess = idToPaymentRequestToProcessMap.get(paymentUnderProcessing.Id);
                    Transmittal__c stateTransmittal = new Transmittal__c();
                    stateTransmittal.PaymentRequest__c = paymentUnderProcessing.Id;
                    stateTransmittal.TransmittalType__c = 'State';
                    transmittalToInsertList.add(stateTransmittal);
                }
                if (paymentUnderProcessing.Project__r.FundingSource__c == 'Federal and State' || paymentUnderProcessing.Project__r.FundingSource__c == 'Federal Only') {
                    Payment_Request__c prRecordToProcess = idToPaymentRequestToProcessMap.get(paymentUnderProcessing.Id);
                    Transmittal__c federalTransmittal = new Transmittal__c();
                    federalTransmittal.PaymentRequest__c = paymentUnderProcessing.Id;
                    federalTransmittal.TransmittalType__c = 'Federal';
                    transmittalToInsertList.add(federalTransmittal);
                }

            }
            else if(paymentUnderProcessing.Transmittals__r?.size() > 0){
                TransmittalUtiity.submitForApproval(paymentUnderProcessing.Transmittals__r);
            }
        }

        if(transmittalToInsertList.size() > 0){
            insert transmittalToInsertList;
            TransmittalUtiity.submitForApproval(transmittalToInsertList);
        }
  */
    }

    //To update the transmittal record upon updating the Payment Rewuest record...
    private void updateTransmittalRecords(){
        Set<Id> paymentRequestids = new Set<Id>(); //To collect all the Payment Request ID, which has been updated...
        for (Payment_Request__c paymentToProcess : (List<Payment_Request__c>) Trigger.new) { //Iterating Trigger.new collection to collect the PR record for processing...
            paymentRequestids.add(paymentToProcess.Id); //Collecting PR record Id which are updated...
        }
        if (paymentRequestids.size() > 0) {
            //Fetching all the Transmittal record related to the Payment Request, whose ID is in collection...
            List<Transmittal__c> allTransmittals = [SELECT Id, PaymentDelivery__c, PaymentRequest__c, PaymentRequest__r.PaymentDelivery__c FROM Transmittal__c WHERE PaymentRequest__c IN : paymentRequestids];
            List<Transmittal__c> toUpTransmittals=new List<Transmittal__c>(); //To collect the transmittal to update...
            if (allTransmittals.size() > 0) {
                for(Transmittal__c transmittal : allTransmittals){ //Iterating the Transmittal records from the collection...
                    if(transmittal.Id !=null && !Approval.isLocked(transmittal.Id)){ //Condition to check if the transmittal record is locked...
                        toUpTransmittals.add(transmittal); //Adding the Transmittal record to collection for updating...
                    }
                }
                if (toUpTransmittals.size() > 0) {
                    update toUpTransmittals; //Updating the Transmittal records....
                }
            }
        }
    }

    //To assign Project name automatically upon selecting the Award record...
    /*private void fetchProjectFromAward() {
        Set<Id> awardIds = new Set<Id>();
        for(Payment_Request__c paymentRecord : (List<Payment_Request__c>) Trigger.new){
            awardIds.add(paymentRecord.Award__c);
        }
        if (awardIds.size() > 0) {
            Map<Id,Award__c> awardMap = new Map<Id,Award__c>([SELECT Id, Name, Project__c FROM Award__C WHERE Id IN : awardIds]);
            for (Payment_Request__c paymentToProcess : (List<Payment_Request__c>) Trigger.new) {
                if(paymentToProcess.Award__c != null){
                    Award__c awardToProcess = awardMap.get(paymentToProcess.Award__c);
                    paymentToProcess.Project__c = awardToProcess.Project__c;
                }
            }
        }
    }*/

    //To prevent selecting the Service Location which is not tied with the Funding opp of current Project...
    private void preventSelectingOtherFundingOppServiceLocation(){
        List<Payment_Request__c> paymentRequestList = new List<Payment_Request__c>(); //To collect the PR records for processing...
        Set<Id> ProjectIds = new Set<Id>(); //To collect the Project record ID of the Payment request...
        if (Trigger.isInsert) {
            paymentRequestList = Trigger.new;
        }
        if(Trigger.isUpdate){
            for (Payment_Request__c paymentRecord : (List<Payment_Request__c>) Trigger.new) { //Iterating the Trigger.new Collection...
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(paymentRecord.Id); //Fetching the Okd PR record from Trigger.oldMap collection...
                if(paymentRecord.Service_Location__c != null && oldRecord.Service_Location__c != paymentRecord.Service_Location__c){ //Condition to check if the Service location is changed and not null....
                    paymentRequestList.add( paymentRecord); //Adding the PR record to collection for processing....
                }
            }
        }

        if (paymentRequestList.size() > 0) {
            for (Payment_Request__c paymentRecord : (List<Payment_Request__c>) Trigger.new) {
                if(paymentRecord.Service_Location__c != null){
                    ProjectIds.add(paymentRecord.Project__c); //Collecting the Project ID of the PR...
                }
            }
            Map<Id, Id> projectToFundingOppMap = new Map<Id, Id>(); //Map to collect the Project and its Funding Opportunity...
            Map<Id,Project__c> idToProjectMap = new Map<Id, Project__c>(); //Map to collect the Project ID to Project with related Project Service junction records...
            //Fetching the Project record whose ID are available on the projectIds collection...
            idToProjectMap = new Map<Id, Project__c>( [SELECT Id , Funding_Opportunity_Name__c FROM Project__c WHERE Id IN :ProjectIds]);
            for(Project__c projectToPRocess : idToProjectMap.values()){ //Iterating the collection to collect the Project and its Funding Opportunity into Map Collection...
                projectToFundingOppMap.put(projectToPRocess.Id, projectToPRocess.Funding_Opportunity_Name__c); //Collecting the Project and its Funding Opportunity into Map Collection...
            }
            //Fetching the Funding Opportunity and it s related Funding Opp Service Location Junction records...
            Map<Id, Funding_Opportunity__c> fOWithServiceJunctionMap = new Map<Id, Funding_Opportunity__c>( [SELECT Id , (SELECT Id , Service_Location__c FROM  Funding_Opp_Service_Location_Junctions__r) FROM Funding_Opportunity__c WHERE Id IN : projectToFundingOppMap.values()]);
            for(Payment_Request__c prUnderProcessing : paymentRequestList){ //Iterating PR List for processing...
                Funding_Opportunity__c fundingOpp = fOWithServiceJunctionMap?.get(projectToFundingOppMap.get(prUnderProcessing.Project__c)); //Fetching the Funding Opp record of the PR's Project from Map Collection...
                List<Id> serviceLocationIds = new List<Id>(); //To collect the related Service Location of the Funding Opp...
                if (fundingOpp?.Funding_Opp_Service_Location_Junctions__r.size() > 0) { //Condition to check if the Service Location junctions are available for The Funding Opp...
                    for(FundingOppServiceLocationJunction__c junction :fundingOpp?.Funding_Opp_Service_Location_Junctions__r){ //iterating the Junction to collect the Service Location Ids...
                        serviceLocationIds.add(junction.Service_Location__c); //Adding the Service Location Ods to the collection...
                    }
                }
                if(!serviceLocationIds?.contains(prUnderProcessing.Service_Location__c) && prUnderProcessing.Service_Location__c != null){ // Condition to check if the selected Service Location in PR record is available in the Service location ID collection...
                    prUnderProcessing.addError('Service Location Must be tied with the Funding Opportunity of the Project.');
                }
            }
        }
    }

    //If the selected Service Location is not tied with the Project but tied with Funding Opp, then to create a Project Service Location Junction record...
    private void createProjectServiceJunction(){
        List<Payment_Request__c > paymentRequestToProcessList = new List<Payment_Request__c >(); //To collect the PR to process list...
        Set<Id> ProjectIds = new Set<Id>(); //To collect the Project record ID of the PR...
        if (Trigger.isInsert) {
            paymentRequestToProcessList = Trigger.new;
        }
        if(Trigger.isUpdate){
            for (Payment_Request__c paymentRecord : (List<Payment_Request__c>) Trigger.new) { //Iterating Trigger.new Collection to collect the PR for processing...
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(paymentRecord.Id); //Fetching the old PR record from Trigger.oldMap collection...
                if(paymentRecord.Service_Location__c != null && oldRecord.Service_Location__c != paymentRecord.Service_Location__c){ //Condition to check if the Service Location has been changed for PR record....
                    paymentRequestToProcessList.add( paymentRecord); //Adding the PR record into the collection for processing...
                }
            }
        }

        if (paymentRequestToProcessList.size() > 0) {
            List<Project_Service_Location_Junction__c> toInsertJunction = new List<Project_Service_Location_Junction__c>(); //To collect the Service location record to insertt....
            for (Payment_Request__c paymentRecord : (List<Payment_Request__c>) Trigger.new) {
                if(paymentRecord.Service_Location__c != null){ //Condition to check if Service Location field is not null...
                    ProjectIds.add(paymentRecord.Project__c); //Collecting the Project record ID of the PR..
                }
            }

            Map<Id, Id> projectToFundingOppMap = new Map<Id, Id>(); //Map to collect the Project and its Funding Opportunity...
            Map<Id,Project__c> projectWithServiceJunctionMap = new Map<Id, Project__c>(); //Map collection to fetch all the Project and its related Project Service junction records, whose Id is in projectId  collection....
            //Fetching all the Project and its related Project Service junction records, whose Id is in projectId  collection....
            projectWithServiceJunctionMap = new Map<Id, Project__c>( [SELECT Id ,Funding_Opportunity_Name__c, (SELECT Id, Service_Location__c FROM Project_Service_Location_Junctions__r) FROM Project__c WHERE Id IN :ProjectIds]);
            for(Project__c projectToPRocess : projectWithServiceJunctionMap.values()) {
                projectToFundingOppMap.put(projectToPRocess.Id, projectToPRocess.Funding_Opportunity_Name__c); //Collecting the Project and its Funding Opp in Map collection...
            }
            //Fetching the Funding Opportunity and its related Funding Opp Service Location Junction records...
            Map<Id, Funding_Opportunity__c> fOWithServiceJunctionMap = new Map<Id, Funding_Opportunity__c>( [SELECT Id , (SELECT Id , Service_Location__c FROM  Funding_Opp_Service_Location_Junctions__r)
            FROM Funding_Opportunity__c WHERE Id IN : projectToFundingOppMap.values()]);
            for(Payment_Request__c prUnderProcessing : paymentRequestToProcessList){ //Iterating PR to process list...
                if (prUnderProcessing.Service_Location__c != null) { //Condition to check if Service location is Selected in PR..
                    Project__c projectToProcess = projectWithServiceJunctionMap.get(prUnderProcessing.Project__c); //Fetching the Project record from Map collection...
                    Set<Id> serviceLocationIdsForProjectJunction = new Set<Id>(); //To collect the Service Location related to Project...
                    Set<Id> serviceLocationIdsForFundingOppJunction = new Set<Id>(); // To collect the Service Location related to project's funding Opp...
                    if (projectToProcess?.Project_Service_Location_Junctions__r.size() > 0) { //Condition to check if any Service location is tied to FFunding opp of the Project...
                        for (Project_Service_Location_Junction__c junctionToProcess : projectToProcess.Project_Service_Location_Junctions__r) {
                            serviceLocationIdsForProjectJunction.add(junctionToProcess.Service_Location__c); //Collecting Service Location which are tied to the Project...
                        }
                    }
                    Funding_Opportunity__c fundingOppToProcess = fOWithServiceJunctionMap?.get(projectToProcess.Funding_Opportunity_Name__c); //Fetching the Funding Opp record from Map collection...
                    if (fundingOppToProcess?.Funding_Opp_Service_Location_Junctions__r.size() > 0){
                        for(FundingOppServiceLocationJunction__c junctionToProcess : fundingOppToProcess.Funding_Opp_Service_Location_Junctions__r){
                            serviceLocationIdsForFundingOppJunction.add(junctionToProcess.Service_Location__c); //Collecting Service Location which are tied to the Funding Opp...
                        }
                    }
                    //Condition to check if the Service Location of the PR is tied to Project And/Or Funding Opportunity....
                    if (!serviceLocationIdsForProjectJunction.contains(prUnderProcessing.Service_Location__c) && serviceLocationIdsForFundingOppJunction.contains(prUnderProcessing.Service_Location__c)) {
                        Project_Service_Location_Junction__c juctionToInsert = new Project_Service_Location_Junction__c(); //Creating Project Service Junction record...
                        juctionToInsert.Project__c = prUnderProcessing.Project__c;
                        juctionToInsert.Service_Location__c = prUnderProcessing.Service_Location__c;
                        toInsertJunction.add(juctionToInsert); //Adding the record to collection for inserting...
                    }
                }
            }
            if (toInsertJunction.size() > 0) {
                insert toInsertJunction; //Inserting the Project Service junction records...
            }
        }
    }

    //This method is used to update Incident and Obligated Sub Recipient field from Project..
    private void updateIncidentAndSubRecipient() {
        Set<Id> projectIds = new Set<Id>(); //To collect the Project IDs...
        List<Payment_Request__c> paymentRequestsToProcess = new List<Payment_Request__c>(); //To collect the PRs to process...
        for (Payment_Request__c pRequest : (List<Payment_Request__c>)Trigger.new){
            projectIds.add(pRequest.Project__c); //Adding Project Id to collection...
            paymentRequestsToProcess.add(pRequest); // Adding PR to collection....
        }
        if (projectIds.size() > 0) {
            //Fetching all the Project records whose Id are available in Set collection...
            Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>([SELECT Id, Incident_Name__c, Obligating_Sub_Recipient__c FROM Project__c WHERE Id IN : projectIds]);
            for (Payment_Request__c pRequest : paymentRequestsToProcess) {
                Project__c project = idToProjectMap.get(pRequest.Project__c); //fetching the Project record from collection...
                pRequest.ObligatedSubRecipient__c = project?.Obligating_Sub_Recipient__c; //Updating the Obligating Sub Recipient and Incident field of PR...
                if (project.Incident_Name__c != null) {
                    pRequest.IncidentName__c = project?.Incident_Name__c;
                }
            }
        }
    }

    //This method is used to update the "Cumulative State Cost Share Flag" of "Incident SubRecipient Stage" record and "Payment Request" Record....
    /*private void stateCostShareFlagCalculation() {
        Map<Id, Payment_Request__c> IdTopRequestsToProcessMap = new Map<Id, Payment_Request__c>(); // TO collect the PR to process...
        Set<Id> incidentIds = new Set<Id>();
        Set<Id> subRecipientIds = new Set<Id>();
        if (Trigger.isInsert ||Trigger.isUndelete) {
            for (Payment_Request__c pRequest : (List<Payment_Request__c>)Trigger.new) {
                if (pRequest.IncidentName__c != null && pRequest.Stage__c != ALS_CONSTANTS.PR_Stage_Withdrawn) {
                    IdTopRequestsToProcessMap.put(pRequest.Id, pRequest);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Payment_Request__c pRequest : (List<Payment_Request__c>)Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(pRequest.Id); //fetching the old PR record from Trigger.oldMap collection.....
                if (pRequest.IncidentName__c != null &&
                        (pRequest.ExpenditurestoDate__c != oldRecord.ExpenditurestoDate__c
                        || pRequest.StateCostShare__c != oldRecord.StateCostShare__c
                        || pRequest.ApprovedStatePaymentAmount__c != oldRecord.ApprovedStatePaymentAmount__c
                        || pRequest.TotalAdminShareAmount__c != oldRecord.TotalAdminShareAmount__c
                        || (pRequest.Stage__c != oldRecord.Stage__c
                                && (pRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn
                                || oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn)))) { //Condition to check idf the Expenditure to Date or State Cost share hs been changed for PR...
                    IdTopRequestsToProcessMap.put(pRequest.Id, pRequest); //Adding the PR record to collection for processing...
                }
            }
        }
        if (Trigger.isDelete) {
            for (Payment_Request__c pRequest : (List<Payment_Request__c>)Trigger.old) {
                if (pRequest.IncidentName__c != null && pRequest.Stage__c != ALS_CONSTANTS.PR_Stage_Withdrawn) {
                    IdTopRequestsToProcessMap.put(pRequest.Id, pRequest); //Adding the PR record to collection for processing...
                }
            }
        }
        Set<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new Set<Incident_Subrecipient_Stage__c>();
        Map<String, Incident_Subrecipient_Stage__c> incidentSubRecipientIdToStageRecord = new Map<String, Incident_Subrecipient_Stage__c>();
        Map<String, AggregateResult> incidentSubRecipientIdToAggregateResultManualPrs = new Map<String, AggregateResult>();
        Map<String, AggregateResult> incidentSubRecipientIdToAggregateResultMigratedPrs = new Map<String, AggregateResult>();
        if (IdTopRequestsToProcessMap.size() > 0) {
            for (Payment_Request__c pRequest : IdTopRequestsToProcessMap.values()) {
                incidentIds.add(pRequest.IncidentName__c); //Adding Incident Id to Set collection...
                subRecipientIds.add(pRequest.ObligatedSubRecipient__c); //Adding Sub Recipient Id to Set collection...
            }
            List<Incident_Subrecipient_Stage__c> incidentSubrecipientStages = [SELECT Id, Account__c, Incident__c, Cumulative_State_Cost_Share_Flag__c
                                                                            FROM Incident_Subrecipient_Stage__c WHERE Incident__c IN : incidentIds
                                                                            AND Account__c IN : subRecipientIds];
            for (Incident_Subrecipient_Stage__c stageRecordToProcess : incidentSubrecipientStages) {
                incidentSubRecipientIdToStageRecord.put((String)stageRecordToProcess.Incident__c + (String)stageRecordToProcess.Account__c, stageRecordToProcess);
            }
            //Fetching the Aggregate Result of Manually created PRs...
            List<AggregateResult> AggregateResultListOfManualPRs = ([SELECT IncidentName__c, ObligatedSubRecipient__c,
                    SUM(StateCostShare__c) totalStateCostShare FROM Payment_Request__c WHERE External_Id__c = NULL
            AND IncidentName__c IN : incidentIds AND ObligatedSubRecipient__c IN : subRecipientIds
            AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn AND Project__r.Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
            GROUP BY IncidentName__c, ObligatedSubRecipient__c]);
            //Fetching the Aggregate Result of Migrated PRs...
            List<AggregateResult> AggregateResultListOfMigratedPRs = ([SELECT IncidentName__c, ObligatedSubRecipient__c,
                    SUM(ApprovedStatePaymentAmount__c)cumulativeApprovedStateAmount, SUM(TotalAdminShareAmount__c)cumulativeAdminShareAmount FROM Payment_Request__c
            WHERE External_Id__c != NULL AND IncidentName__c IN : incidentIds AND ObligatedSubRecipient__c IN : subRecipientIds
            AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn AND Project__r.Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
            GROUP BY IncidentName__c, ObligatedSubRecipient__c]);

            for (AggregateResult result : AggregateResultListOfManualPRs) {
                Id incidentId = (Id)result.get('IncidentName__c');
                Id subRecipientId = (Id)result.get('ObligatedSubRecipient__c');

                incidentSubRecipientIdToAggregateResultManualPrs.put((String)incidentId + (String)subRecipientId, result);
            }

            for (AggregateResult result : AggregateResultListOfMigratedPRs) {
                Id incidentId = (Id)result.get('IncidentName__c');
                Id subRecipientId = (Id)result.get('ObligatedSubRecipient__c');

                incidentSubRecipientIdToAggregateResultMigratedPrs.put((String)incidentId + (String)subRecipientId, result);
            }

            for (Payment_Request__c payRequest : IdTopRequestsToProcessMap.values()) {
                String key = (String)payRequest.IncidentName__c + (String)payRequest.ObligatedSubRecipient__c;
                Incident_Subrecipient_Stage__c stageRecord = incidentSubRecipientIdToStageRecord.get(key);

                AggregateResult resultManualPRs = incidentSubRecipientIdToAggregateResultManualPrs?.get(key);
                Decimal cumulativeCostShareManualPrs = (Decimal)resultManualPRs?.get('totalStateCostShare');
                Decimal stateShareManual = cumulativeCostShareManualPrs == null?0.00:cumulativeCostShareManualPrs;

                AggregateResult resultMigratedPRs = incidentSubRecipientIdToAggregateResultMigratedPrs?.get(key);
                Decimal cumulativeCostShareMigratedPrs = (Decimal)resultMigratedPRs?.get('cumulativeApprovedStateAmount');
                Decimal cumulativeAdminShareMigratedPrs = (Decimal)resultMigratedPRs?.get('cumulativeAdminShareAmount');
                Decimal stateShareMigrated = cumulativeCostShareMigratedPrs == null?0.00:cumulativeCostShareMigratedPrs;
                Decimal AdminShareMigrated = cumulativeAdminShareMigratedPrs == null?0.00:cumulativeAdminShareMigratedPrs;

                Decimal stateShareNew = (stateShareManual + stateShareMigrated + AdminShareMigrated).setScale(2,system.RoundingMode.DOWN);

                if (Trigger.isDelete) {
                    if (payRequest.External_Id__c == null) {
                        stateShareNew -= payRequest.StateCostShare__c;
                    }
                    else if (payRequest.External_Id__c != null && payRequest.ApprovedStatePaymentAmount__c > 0) {
                        stateShareNew -= payRequest.ApprovedStatePaymentAmount__c;
                    }
                    else if (payRequest.External_Id__c != null && payRequest.TotalAdminShareAmount__c > 0) {
                        stateShareNew -= payRequest.TotalAdminShareAmount__c;
                    }
                }
                if (stateShareNew >= Decimal.valueOf(2500)) {
                    stageRecord.Cumulative_State_Cost_Share_Flag__c = true;
                }
                else if (stateShareNew < Decimal.valueOf(2500)) {
                    stageRecord.Cumulative_State_Cost_Share_Flag__c = false;
                }
                stageRecordsToUpdate.add(stageRecord);
            }
            if (stageRecordsToUpdate.size() > 0) {
                List<Incident_Subrecipient_Stage__c> stageRecordsToUpdateUnique = new List<Incident_Subrecipient_Stage__c>();
                stageRecordsToUpdateUnique.addAll(stageRecordsToUpdate);
                update stageRecordsToUpdateUnique;
            }
        }
    }*/

    /*//Inner Class for Locking and Unlocking the Payment Request record...
    public without sharing class InnerClassforUnlockingAndLocking {
        private List<Approval.UnlockResult> unlockPaymentRequest(List<Id> recordIds){ //Method to Unlock the Record...
            List<Approval.UnlockResult> unlockRecords = Approval.unlock(recordIds, false );
            return unlockRecords;
        }
        private List<Approval.LockResult> lockPaymentRequest(List<Id> recordIds){ //Method to lock the Record...
            List<Approval.LockResult> lockRecords = Approval.lock(recordIds, false );
            return lockRecords;
        }
    }*/

    //This method will update Manager field on PR if Approval process is Approved by Manager...
    private void updateManagerFieldOnPR() {
        for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
            Payment_Request__c oldRecord =(Payment_Request__c)trigger.oldMap.get(pRequests.Id);
            if ( oldRecord.Stage__c != pRequests.Stage__c  && pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing ) {
                pRequests.Manager_Approver__c = UserInfo.getUserId();
            } 
        }
    }

    //This method is used to update the "Approved Admin Amount" field on Project.....
    private void updateApprovedAmountCustomRollUpOnProjectForInsertAndUpdate() {
        Set<Id> projectIds = new Set<Id>();
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                if(pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                        || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment
                        || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_Paid) {
                projectIds.add(pRequests.Project__c);
            }
        }
        }
        if (Trigger.isUpdate) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(pRequests.Id);
                if ((pRequests.Stage__c != oldRecord.Stage__c
                        && ((pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                        || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment
                        || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_Paid)
                        || (oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                        || oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment
                        || oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_Paid)))
                        || pRequests.ExpenditurestoDate__c != oldRecord.ExpenditurestoDate__c
                        || pRequests.TotalAdminShareAmount__c != oldRecord.TotalAdminShareAmount__c
                        || pRequests.ApprovedStatePaymentAmount__c != oldRecord.ApprovedStatePaymentAmount__c
                        || pRequests.ApprovedFederalPaymentAmount__c != oldRecord.ApprovedFederalPaymentAmount__c) { // && (pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_Paid)
                    projectIds.add(pRequests.Project__c);
                }
            }
        }

        if (projectIds.size() > 0) {
            List<Project__c> projectsToUpdate = new List<Project__c>();
            Map<Id, Project__c> projectList = new Map<Id, Project__c>([SELECT Id, Total_Admin_Amount_Approved__c, Total_State_Amount_Approved__c,
                    Total_Federal_Amount_Approved__c FROM Project__c WHERE Id IN : projectIds]);
            List<String> stageList = new List<String>();
            stageList.add(ALS_CONSTANTS.PR_Stage_Paid);//stageList.add('Paid');
            stageList.add(ALS_CONSTANTS.PR_Stage_PaymentProcessing);//stageList.add('Payment Processing');
            stageList.add(ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment);

            List<AggregateResult> results = [SELECT Project__c, SUM(TotalAdminShareAmount__c)totalApprovedAdminAmount,
                    SUM(ApprovedStatePaymentAmount__c) totalApprovedStateAmount, SUM(ApprovedFederalPaymentAmount__c)totalApprovedFederalAmount
                    FROM Payment_Request__c WHERE Project__c IN : projectIds AND Stage__c IN : stageList GROUP BY Project__c];
            Map<Id, AggregateResult> projectidToAggregateResult = new Map<Id, AggregateResult>();
            if (results.size() > 0) {
                for (AggregateResult result : results) {
                    Id projectId = (Id)result.get('Project__c');
                    projectidToAggregateResult.put(projectId, result);
                }
            }

            for (Project__c projectToProcess : projectList.values()) {
                AggregateResult result = projectidToAggregateResult?.get(projectToProcess.Id);
                Decimal totalApprovedAdminAmount = (Decimal) result?.get('totalApprovedAdminAmount') == null? 0.00 : (Decimal) result?.get('totalApprovedAdminAmount');
                Decimal totalApprovedStateAmount = (Decimal) result?.get('totalApprovedStateAmount') == null? 0.00 : (Decimal) result?.get('totalApprovedStateAmount');
                Decimal totalApprovedFederalAmount = (Decimal) result?.get('totalApprovedFederalAmount') == null? 0.00 : (Decimal) result?.get('totalApprovedFederalAmount');
                projectToProcess.Total_Admin_Amount_Approved__c = (totalApprovedAdminAmount==null? 0.00 :totalApprovedAdminAmount).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_State_Amount_Approved__c = ((totalApprovedStateAmount==null? 0.00 :totalApprovedStateAmount) - (totalApprovedAdminAmount==null? 0.00 :totalApprovedAdminAmount)).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_Federal_Amount_Approved__c = (totalApprovedFederalAmount==null? 0.00 :totalApprovedFederalAmount).setScale(2,system.RoundingMode.DOWN);
                projectsToUpdate.add(projectToProcess);
            }

            update projectsToUpdate;
        }
    }

    private void updateApprovedAmountCustomRollUpOnProjectForDelete() {
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Payment_Request__c> prsToProcess = new Map<Id, Payment_Request__c>();
        for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.old) {
            if (pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_Paid) {
                projectIds.add(pRequests.Project__c);
                prsToProcess.put(pRequests.Id, pRequests);
            }
        }
        if (projectIds.size() > 0) {
            List<Project__c> projectsToUpdate = new List<Project__c>();
            List<String> stageList = new List<String>();
            stageList.add(ALS_CONSTANTS.PR_Stage_Paid);//stageList.add('Paid');
            stageList.add(ALS_CONSTANTS.PR_Stage_PaymentProcessing);//stageList.add('Payment Processing');
            stageList.add(ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment);
            Map<Id, Project__c> projectList = new Map<Id, Project__c>([SELECT Id, Total_Admin_Amount_Approved__c, Total_State_Amount_Approved__c,
                    Total_Federal_Amount_Approved__c FROM Project__c WHERE Id IN : projectIds]);
            List<AggregateResult> results = [SELECT Project__c, SUM(TotalAdminShareAmount__c)totalApprovedAdminAmount,
                    SUM(ApprovedStatePaymentAmount__c) totalApprovedStateAmount, SUM(ApprovedFederalPaymentAmount__c)totalApprovedFederalAmount
            FROM Payment_Request__c WHERE Project__c IN : projectIds AND Id IN : prsToProcess.keySet() AND Stage__c IN : stageList GROUP BY Project__c];

            for (AggregateResult result : results) {
                Decimal totalApprovedAdminAmount = (Decimal) result.get('totalApprovedAdminAmount') == null? 0.00 : (Decimal) result?.get('totalApprovedAdminAmount');
                Decimal totalApprovedStateAmount = (Decimal) result?.get('totalApprovedStateAmount') == null? 0.00 : (Decimal) result?.get('totalApprovedStateAmount');
                Decimal totalApprovedFederalAmount = (Decimal) result?.get('totalApprovedFederalAmount') == null? 0.00 : (Decimal) result?.get('totalApprovedFederalAmount');
                Id projectId = (Id)result.get('Project__c');
                Project__c projectToProcess = projectList.get(projectId);

                projectToProcess.Total_Admin_Amount_Approved__c -= (totalApprovedAdminAmount==null? 0.00 :totalApprovedAdminAmount).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_State_Amount_Approved__c -= ((totalApprovedStateAmount==null? 0.00 :totalApprovedStateAmount) - totalApprovedAdminAmount).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_Federal_Amount_Approved__c -= (totalApprovedFederalAmount==null? 0.00 :totalApprovedFederalAmount).setScale(2,system.RoundingMode.DOWN);

                projectsToUpdate.add(projectToProcess);
            }
            update projectsToUpdate;
        }
    }

    private void updateRequestedAmountCustomRollUpOnProjectForInsertAndUpdate() {
        Set<Id> projectIds = new Set<Id>();

        if (Trigger.isInsert || Trigger.isUndelete) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                projectIds.add(pRequests.Project__c);
            }
        }
        if (Trigger.isUpdate) {
            for (Payment_Request__c pRequest : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(pRequest.Id);
                if ((pRequest.Stage__c != oldRecord.Stage__c
                        && (pRequest.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn
                        || oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_Withdrawn))
                        || pRequest.ExpenditurestoDate__c != oldRecord.ExpenditurestoDate__c
                        || pRequest.TotalAdminShareAmount__c != oldRecord.TotalAdminShareAmount__c
                        || pRequest.ApprovedStatePaymentAmount__c != oldRecord.ApprovedStatePaymentAmount__c
                        || pRequest.ApprovedFederalPaymentAmount__c != oldRecord.ApprovedFederalPaymentAmount__c) {
                    projectIds.add(pRequest.Project__c);
                }
            }
        }

        if (projectIds.size() > 0) {
            List<Project__c> projectsToUpdate = new List<Project__c>();
            Map<Id, Project__c> projectList = new Map<Id, Project__c>([SELECT Id, Total_Admin_Amount_Requested__c, Total_State_Amount_Requested__c,
                    Total_Federal_Amount_Requested__c FROM Project__c WHERE Id IN : projectIds]);

            List<AggregateResult> results = [SELECT Project__c, sum(TotalAdminShareAmount__c)totalRequestedAdminAmount,
                    SUM(ApprovedStatePaymentAmount__c) totalRequestedStateAmount, SUM(ApprovedFederalPaymentAmount__c)totalRequestedFederalAmount
            FROM Payment_Request__c WHERE Project__c IN : projectIds AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn GROUP BY Project__c];
            Map<Id, AggregateResult> projectIdToAggregateResultMap = new Map<Id, AggregateResult>();

            Map<Id, AggregateResult> projectidToAggregateResult = new Map<Id, AggregateResult>();
            if (results.size() > 0) {
                for (AggregateResult result : results) {
                    Id projectId = (Id)result.get('Project__c');
                    projectidToAggregateResult.put(projectId, result);
                }
            }

            for (Project__c projectToProcess : projectList.values()) {
                AggregateResult result = projectidToAggregateResult?.get(projectToProcess.Id);
                Decimal totalRequestedAdminAmount = (Decimal) result?.get('totalRequestedAdminAmount') == null? 0.00 : (Decimal) result?.get('totalRequestedAdminAmount');
                Decimal totalRequestedStateAmount = (Decimal) result?.get('totalRequestedStateAmount') == null? 0.00 : (Decimal) result?.get('totalRequestedStateAmount');
                Decimal totalRequestedFederalAmount = (Decimal) result?.get('totalRequestedFederalAmount') == null? 0.00 : (Decimal) result?.get('totalRequestedFederalAmount');
                projectToProcess.Total_Admin_Amount_Requested__c = (totalRequestedAdminAmount==null? 0.00 :totalRequestedAdminAmount).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_State_Amount_Requested__c = ((totalRequestedStateAmount==null? 0.00 :totalRequestedStateAmount) - (totalRequestedAdminAmount==null? 0.00 :totalRequestedAdminAmount)).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_Federal_Amount_Requested__c = (totalRequestedFederalAmount==null? 0.00 :totalRequestedFederalAmount).setScale(2,system.RoundingMode.DOWN);
                projectsToUpdate.add(projectToProcess);
            }

            update projectsToUpdate ;
        }
    }

    private void updateRequestedAmountCustomRollUpOnProjectForDelete() {
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Payment_Request__c> prsToProcess = new Map<Id, Payment_Request__c>();
        for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.old) {
            if (pRequests.Stage__c != ALS_CONSTANTS.PR_Stage_Withdrawn) {
                projectIds.add(pRequests.Project__c);
                prsToProcess.put(pRequests.Id, pRequests);
            }
        }
        if (projectIds.size() > 0) {
            List<Project__c> projectsToUpdate = new List<Project__c>();
            Map<Id, Project__c> projectList = new Map<Id, Project__c>([SELECT Id, Total_Admin_Amount_Requested__c, Total_State_Amount_Requested__c,
                    Total_Federal_Amount_Requested__c FROM Project__c WHERE Id IN : projectIds]);
            List<AggregateResult> results = [SELECT Project__c, SUM(TotalAdminShareAmount__c)totalRequestedAdminAmount,
                    SUM(ApprovedStatePaymentAmount__c) totalRequestedStateAmount, SUM(ApprovedFederalPaymentAmount__c)totalRequestedFederalAmount
                    FROM Payment_Request__c WHERE Project__c IN : projectIds AND Id IN : prsToProcess.keySet()
                    AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn GROUP BY Project__c];

            for (AggregateResult result : results) {
                Decimal totalRequestedAdminAmount = (Decimal) result.get('totalRequestedAdminAmount') == null? 0.00 : (Decimal) result?.get('totalRequestedAdminAmount');
                Decimal totalRequestedStateAmount = (Decimal) result?.get('totalRequestedStateAmount') == null? 0.00 : (Decimal) result?.get('totalRequestedStateAmount');
                Decimal totalRequestedFederalAmount = (Decimal) result?.get('totalRequestedFederalAmount') == null? 0.00 : (Decimal) result?.get('totalRequestedFederalAmount');
                Id projectId = (Id)result.get('Project__c');
                Project__c projectToProcess = projectList.get(projectId);
                projectToProcess.Total_Admin_Amount_Requested__c -= (totalRequestedAdminAmount==null? 0.00 :totalRequestedAdminAmount).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_State_Amount_Requested__c -= ((totalRequestedStateAmount==null? 0.00 :totalRequestedStateAmount) - totalRequestedAdminAmount).setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_Federal_Amount_Requested__c -= (totalRequestedFederalAmount==null? 0.00 :totalRequestedFederalAmount).setScale(2,system.RoundingMode.DOWN);
                projectsToUpdate.add(projectToProcess);
            }
            update projectsToUpdate;
        }
    }

    /*private void updateRetentionToDateOnProject(){
        Set<Id> projectIds = new Set<Id>();
        List<Project__c> projectsToUpdate = new List<Project__c>();
        if (Trigger.isInsert) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                if (pRequests.ExpenditurestoDate__c > 0 && pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement) {
                    Project__c pr = new Project__c();
                    pr.Id = pRequests.Project__c;
                    pr.Expenditure_To_Date__c = pRequests.ExpenditurestoDate__c;
                    pr.Federal_Retention_To_Date__c = pRequests.FederalRetentionShare__c == null?0.00:pRequests.FederalRetentionShare__c;
                    pr.State_Retention_To_Date__c = pRequests.StateRetentionShare__c == null?0.00:pRequests.StateRetentionShare__c;
                    pr.Total_Retention_To_Date__c = (pRequests.FederalRetentionShare__c == null?0.00:pRequests.FederalRetentionShare__c)+(pRequests.StateRetentionShare__c == null?0.00:pRequests.StateRetentionShare__c);
                    projectsToUpdate.add(pr);
                }
            }
        }
        List<Payment_Request__c> prsToProcess = new List<Payment_Request__c>();
        if(Trigger.isUpdate) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(pRequests.Id);
                if (
                        (pRequests.PaymentType__c != oldRecord.PaymentType__c
                        && (pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement || oldRecord.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement))
                        || (pRequests.ExpenditurestoDate__c != oldRecord.ExpenditurestoDate__c && pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement)
                        || (pRequests.FederalRetentionShare__c != oldRecord.FederalRetentionShare__c && pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement)
                        || (pRequests.StateRetentionShare__c != oldRecord.StateRetentionShare__c && pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement)
                ) {
                    projectIds.add(pRequests.Project__c);
                    prsToProcess.add(pRequests);
                }
            }

            if(projectIds.size() > 0) {
                Map<Id, Project__c> idToProjectWithPrsMap = new Map<Id, Project__c>([SELECT Id, Expenditure_To_Date__c, (SELECT Id, Project__c, ExpenditurestoDate__c ,FederalRetentionShare__c, StateRetentionShare__c FROM Payment_Requests__r WHERE Project__c IN :projectIds AND ExpenditurestoDate__c > 0 AND PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_Reimbursement AND Stage__c != :ALS_CONSTANTS.PR_Stage_Withdrawn ORDER BY CreatedDate DESC) FROM Project__c WHERE Id IN :projectIds]);

                for (Id projId : projectIds) {
                    List<Payment_Request__c> paymentRequestList = idToProjectWithPrsMap.get(projId).Payment_Requests__r;
                   if(paymentRequestList.size()>0) {
                           Project__c proj = new Project__c();
                           proj.Id = paymentRequestList[0].Project__c;
                           proj.Expenditure_To_Date__c = paymentRequestList[0].ExpenditurestoDate__c == null ? 0.00 : paymentRequestList[0].ExpenditurestoDate__c;
                           proj.Federal_Retention_To_Date__c = paymentRequestList[0].FederalRetentionShare__c == null ? 0.00 : paymentRequestList[0].FederalRetentionShare__c;
                           proj.State_Retention_To_Date__c = paymentRequestList[0].StateRetentionShare__c == null ? 0.00 : paymentRequestList[0].StateRetentionShare__c;
                           proj.Total_Retention_To_Date__c = (paymentRequestList[0].FederalRetentionShare__c == null ? 0.00 : paymentRequestList[0].FederalRetentionShare__c) + (paymentRequestList[0].StateRetentionShare__c == null ? 0.00 : paymentRequestList[0].StateRetentionShare__c);
                           projectsToUpdate.add(proj);
                    }else{
                       Project__c proj = new Project__c();
                       proj.Id = projId;
                       proj.Expenditure_To_Date__c = 0;
                       proj.Federal_Retention_To_Date__c =0;
                       proj.State_Retention_To_Date__c =0;
                       proj.Total_Retention_To_Date__c =0;
                       projectsToUpdate.add(proj);
                   }
                }
        }
        }
        if(projectsToUpdate.size() > 0){
            update projectsToUpdate;
        }
    }*/

    //Ticket No CaloESALS-405 and 429  To update Project fields which are Copied From highest amount in the Expenditures to Date WITH Retentions field on the PR
    private void updateExpenditureToDateANDRetentionsOnProject() {
        Set<Id> projectIds = new Set<Id>();
        List<Project__c> projectsToUpdate = new List<Project__c>();
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                //If PR type is Reimbursment or Final Payment and Expenditure to date > 0 And Stage is Paid or returned project payment or payment processing the update Project
                if (pRequests.ExpenditurestoDate__c > 0 && (pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement || pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_FinalPayment)
                    && (pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_Paid)
                ) {
                    projectIds.add(pRequests.Project__c);
                }
            }
        }
        if(Trigger.isUpdate) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(pRequests.Id);
                //If Old or New PR type is Reimbursment or Final Payment and Old or New Expenditure to date > 0 And Old or New Stage is Paid or returned project payment or payment processing the update Project
                if (
                        (pRequests.PaymentType__c != oldRecord.PaymentType__c
                                && (pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement || oldRecord.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement || pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_FinalPayment || oldRecord.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_FinalPayment))
                                || (pRequests.ExpenditurestoDate__c != oldRecord.ExpenditurestoDate__c && (pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement || pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_FinalPayment))
                                //|| (pRequests.FederalRetentionShare__c != oldRecord.FederalRetentionShare__c && pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement)
                                //|| (pRequests.StateRetentionShare__c != oldRecord.StateRetentionShare__c && pRequests.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement)
                                || (pRequests.Stage__c != oldRecord.Stage__c
                                && (pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment || pRequests.Stage__c == ALS_CONSTANTS.PR_Stage_Paid )
                                || (oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing || oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment || oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_Paid ))
                        ) {
                    projectIds.add(pRequests.Project__c);
                }
            }
        }
        if(Trigger.isDelete) {
            for (Payment_Request__c pRequests : (List<Payment_Request__c>) Trigger.old) {
                if(pRequests.Project__c != null) {
                    projectIds.add(pRequests.Project__c);
                }
            }
        }
        if(projectIds.size() >0) {
            //fetching PR which has Amount of Expenditure to date is big as compare to other PRs on perticular Project
            Map<Id, Project__c> idToProjectWithPrsMap = new Map<Id, Project__c>([SELECT Id,
            (SELECT Id, Stage__c, Project__c, ExpenditurestoDate__c,FederalRetentionShare__c, StateRetentionShare__c
            FROM Payment_Requests__r
            WHERE Project__c IN :projectIds
            AND ExpenditurestoDate__c > 0
            AND (PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_Reimbursement OR PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_FinalPayment )
            AND (Stage__c = :ALS_CONSTANTS.PR_Stage_PaymentProcessing OR Stage__c = :ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment OR Stage__c = :ALS_CONSTANTS.PR_Stage_Paid )
            ORDER BY ExpenditurestoDate__c DESC limit 1)
            FROM Project__c where Id IN :projectIds]);
           // Map<Id, Project__c> idToProjectWithPrsMap = new Map<Id, Project__c>([SELECT Id, (SELECT Id, Stage__c, Project__c, ExpenditurestoDate__c,FederalRetentionShare__c, StateRetentionShare__c FROM Payment_Requests__r WHERE Project__c IN :projectIds AND ExpenditurestoDate__c > 0 AND (PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_Reimbursement OR PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_FinalPayment ) AND Stage__c != :ALS_CONSTANTS.PR_Stage_Withdrawn ORDER BY ExpenditurestoDate__c DESC limit 1) FROM Project__c where Id IN :projectIds]);
            for (Project__c proj : idToProjectWithPrsMap.values()) {
                List<Payment_Request__c> payReq = idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r;
                //if project has PR with Stage Paid or returned project type or Payment Processing and type is Reimbursment or Final Payment and Expenditure to Date > 0
                if (payReq.size() > 0) {
                    Project__c project = new Project__c();
                    project.Id = proj.Id;
                    project.Expenditure_To_Date__c = (payReq[0].ExpenditurestoDate__c == null?0.00:payReq[0].ExpenditurestoDate__c).setScale(2,system.RoundingMode.DOWN);
                    project.Federal_Retention_To_Date__c = (payReq[0].FederalRetentionShare__c == null?0.00:payReq[0].FederalRetentionShare__c).setScale(2,system.RoundingMode.DOWN);
                    project.State_Retention_To_Date__c = (payReq[0].StateRetentionShare__c == null?0.00:payReq[0].StateRetentionShare__c).setScale(2,system.RoundingMode.DOWN);
                    project.Total_Retention_To_Date__c = ((payReq[0].FederalRetentionShare__c == null?0.00:payReq[0].FederalRetentionShare__c)+(payReq[0].StateRetentionShare__c == null?0.00:payReq[0].StateRetentionShare__c)).setScale(2,system.RoundingMode.DOWN);
                    projectsToUpdate.add(project);
                } else {
                    //if project has no any  PR with Stage Paid or returned project type or Payment Processing and type is Reimbursment or Final Payment and Expenditure to Date > 0
                    Project__c project = new Project__c();
                    project.Id = proj.Id;
                    project.Expenditure_To_Date__c = 0;
                    project.Federal_Retention_To_Date__c = 0;
                    project.State_Retention_To_Date__c = 0;
                    project.Total_Retention_To_Date__c = 0;
                    projectsToUpdate.add(project);
                }
            }
            if(projectsToUpdate.size() > 0){ //Null Check
                update projectsToUpdate; //update Retention and Expenditure to Date fields on Project.
            }
        }
    }

    //Ticket No -CalOES -440 (Payment Request Rejection Processing)..
    /* public static void rejectionCommentRequired() {
        Map<Id,Payment_Request__c> idToPaymentRequestMap = new Map<Id, Payment_Request__c>();
        for(Payment_Request__c prToProcess : (List<Payment_Request__c>) Trigger.new){
            Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(prToProcess.Id);
            //If stage of Payment Request is ReviewedNeedsInformation add Record Id to Map..
            if(prToProcess.Stage__c != oldRecord.Stage__c && prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation ){
                idToPaymentRequestMap.put(prToProcess.Id,prToProcess);
            }
        }
        //Null check..
        if(idToPaymentRequestMap.size() > 0){
            //Fetching Comments of recent Approval History record on Current Payment Request...
            List<ProcessInstance>  processInstanceList =[SELECT TargetObjectId,
            (SELECT Id, StepStatus, Comments
            FROM Steps
            ORDER BY CreatedDate DESC
             limit 1)
            FROM ProcessInstance
            WHERE TargetObjectId IN :idToPaymentRequestMap.keySet()
            ORDER BY CreatedDate DESC];
            for (ProcessInstance processInstance :processInstanceList)
            {
                String comm = processInstance?.Steps[0]?.Comments?.deleteWhitespace();
                //If Approval History comment is black then Throw an Error
                if (comm == null && processInstance?.Steps[0]?.StepStatus == 'Rejected' )
                {
                    idToPaymentRequestMap.get(processInstance.TargetObjectId).addError(
                            'Rejection reason is Required!');
                }
            }
        }
    }*/

	/***********************************************
	  * Method Name : checkNegativeApprovedAmounts
	  * Author : Sushant.
	  * Inputs : -
	  * Description: Validation to check Approved Federal Payment Amount/Approved State Payment Amount.
	                (For Reimbursement, Approved Federal Payment Amount/Approved State Payment Amount must be Greater than or equal to 0.
	  *********************************************/
    private void checkNegativeApprovedAmounts(){
        for(Payment_Request__c paymentRequest :(List<Payment_Request__c>) Trigger.new){
            /** If the New Stage of PR is In Review or Payment Processing And Approved Federal Payment Amount/Approved State Payment Amount is less than 0 then Display Error */
            if((paymentRequest.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
            || paymentRequest.Stage__c ==ALS_CONSTANTS.PR_Stage_PaymentProcessing)
            && (paymentRequest.TotalApprovedPaymentAmount__c < 0
            || paymentRequest.ApprovedStatePaymentAmount__c < 0
            || paymentRequest.ApprovedFederalPaymentAmount__c < 0)
            && paymentRequest.PaymentType__c  == ALS_CONSTANTS.PR_PaymentType_Reimbursement ){
                paymentRequest.addError('Approved Federal Payment Amount/Approved State Payment Amount, must be Greater than or equal to 0 for "Reimbursement" Payment Type');
                //paymentRequest.addError(System.Label.REAL_PR_ReimburseApprovedPaymentError);
            }
        }
    }
	
  /** Ticket No - 541 - Start */
    /*********************************************
     * Method Name : cumulativeExpenditureValidationOnPr
     * Called From Method : ProcessBeforeInsert, ProcessBeforeUpdate
     * Author : Ricky
     * Inputs : -
     * Description: This method is used validate that the Expenditure to Date on the PR is Cumulative Expenditures till date
     *              for Reimbursement Type, PR Exception for Admin Only Payment.
     *********************************************/
    private void cumulativeExpenditureValidationOnPr() {
        Set<Id> projectIds = new Set<Id>();
        Set<Id> prIdsToAvoidInQuery = new Set<Id>();
        List<Payment_Request__c> prToProcessList = new List<Payment_Request__c>();
        if(Trigger.isInsert) {
            for (Payment_Request__c paymentRequest : (List<Payment_Request__c>) Trigger.new) {
                if (paymentRequest.External_Id__c == null
                        && paymentRequest.Project__c != null
                        && paymentRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement
                        && paymentRequest.ExpenditurestoDate__c != 0
                        && paymentRequest.Allow_Admin_Payment__c != true) {
                    projectIds.add(paymentRequest.Project__c);
                    prToProcessList.add(paymentRequest);
                }
            }
        }
        if(Trigger.isUpdate) {
            for (Payment_Request__c paymentRequest : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(paymentRequest.Id);
                if (paymentRequest.External_Id__c == null
                        && paymentRequest.Project__c != null
                        && paymentRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement
                        && oldRecord.ExpenditurestoDate__c != paymentRequest.ExpenditurestoDate__c
                        && paymentRequest.ExpenditurestoDate__c != 0
                        && paymentRequest.Allow_Admin_Payment__c != true) {
                    projectIds.add(paymentRequest.Project__c);
                    prToProcessList.add(paymentRequest);
                    prIdsToAvoidInQuery.add(paymentRequest.Id);
                }
            }
        }
        if(projectIds?.size() > 0) {
            Map<Id, Project__c> projectIdToProjectWithPrMap = new Map<Id, Project__c>();
            if(prIdsToAvoidInQuery?.size() > 0) {
                projectIdToProjectWithPrMap = new Map<Id, Project__c>([SELECT Id, Name,
                                                    (SELECT Id, ExpenditurestoDate__c FROM Payment_Requests__r
                                                        WHERE PaymentType__c =: ALS_CONSTANTS.PR_PaymentType_Reimbursement
                                                        AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn
                                                        AND ExpenditurestoDate__c != 0
                                                        AND Id NOT IN : prIdsToAvoidInQuery ORDER BY Name DESC LIMIT 1)
                                                    FROM Project__c WHERE Id IN : projectIds]);
            }
            else {
                projectIdToProjectWithPrMap = new Map<Id, Project__c>([SELECT Id, Name,
                                                    (SELECT Id, ExpenditurestoDate__c FROM Payment_Requests__r
                                                        WHERE PaymentType__c =: ALS_CONSTANTS.PR_PaymentType_Reimbursement
                                                        AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn
                                                        AND ExpenditurestoDate__c != 0 ORDER BY Name DESC LIMIT 1)
                                                    FROM Project__c WHERE Id IN : projectIds]);
            }

            for (Payment_Request__c prToProcess : prToProcessList) {
                if(projectIdToProjectWithPrMap?.get(prToProcess.Project__c)?.Payment_Requests__r?.size() > 0) {
                    Payment_Request__c latestReimbursementTypePrOnProject = projectIdToProjectWithPrMap?.get(prToProcess.Project__c)?.Payment_Requests__r[0];
                    if(prToProcess.ExpenditurestoDate__c < latestReimbursementTypePrOnProject.ExpenditurestoDate__c) {
                        prToProcess.addError('Please enter cumulative Expenditure to Date on Payment Request.');
                       
                    }
                }
            }
        }
    }
    /** Ticket No - 541 - Start */
	
/*********************************************
     * Method Name : adjustedForOffsetValidationForPositiveTR
     * Called From Method : ProcessBeforeUpdate
     * Author : Sushant.
     * Inputs : -
     * Description: This method is used validate that the Adjusted for(Offset)
     * field is required on Associated transmittal before sending PR to Approval if PR is of Offset type.
     *********************************************/
    private void adjustedForOffsetValidationForPositiveTR() {
        Set<Id> prIds = new Set<Id>();

        for (Payment_Request__c paymentRequest : (List<Payment_Request__c>) Trigger.new) {
            Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(paymentRequest.Id);
            /** In PR stage is in Review, Payment type is Offset,Total Approved Payment Amount on PR is Positive then add PR id to Set.*/
            if ((oldRecord.Stage__c != paymentRequest.Stage__c )
                    &&paymentRequest.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                    && paymentRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                    && paymentRequest.TotalApprovedPaymentAmount__c > 0) {
                prIds.add(paymentRequest.Id);
            }
        }
        /** Get all Positive Approved Amount transmittals related to PR's which has Adjusted For Offset value is null.*/
        Map<Id, Payment_Request__c> PrIdToPRMap = new Map<Id, Payment_Request__c>([
                SELECT Id, (
                        SELECT id,Adjusted_For_Offset__c,ApprovedAmount__c
                        FROM Transmittals__r
                        WHERE ApprovedAmount__c > 0 AND Adjusted_For_Offset__c = null
                )
                FROM Payment_Request__c
                where Id IN :prIds
        ]);
        for (Payment_Request__c pr : PrIdToPRMap.values()) {
            List<Transmittal__c> transmittalList = PrIdToPRMap.get(pr.Id).Transmittals__r;
            /** If PR has Associated transmittal which has null Adjusted For Offset value then throw error*/
            if (transmittalList.size() > 0) {
                Payment_Request__c actualRecord = (Payment_Request__c) Trigger.newMap.get(pr.Id);
                actualRecord.addError('Required field missing on Associated Transmittals - Adjusted For(Offset)');
            }
        }
    }
	
    /** Ticket No - 476 - Start */
    /*********************************************
     * Method Name : approveReturnedProjectPaymentTrUponPrApproval
     * Called From Method : ProcessAfterUpdate
     * Author : Ricky
     * Inputs : -
     * Description: This method is used To update the Approve the related Transmittal of the Payment Request of Type "Returned Project payment"
     *              upon PR approval from manager.
     *********************************************/
    private void approveReturnedProjectPaymentTrUponPrApproval() {
        /** To collect the PR Of Returned Project Payment for further processing. */
        Map<Id, Payment_Request__c> prIdToPrToProcessMap = new Map<Id, Payment_Request__c>();
        for(Payment_Request__c prToProcess : (List<Payment_Request__c>)Trigger.new) {
            Payment_Request__c oldRecord = (Payment_Request__c)Trigger.oldMap.get(prToProcess.Id);
            /** Condition 1 - To check that the PR stage is changed to Payment Processing
             * Condition 2 - To check for the Payment Type of PR is "Returned Project Payment"
             * Condition 3 - To check for the Approved State/Federal Payment Amount of PR is less than 0. */
            if(prToProcess.Stage__c != oldRecord.Stage__c
                    && oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                    && prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                    && prToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                    && (prToProcess.ApprovedFederalPaymentAmount__c < 0 || prToProcess.ApprovedStatePaymentAmount__c < 0)) {
                prIdToPrToProcessMap.put(prToProcess.Id, prToProcess); /** Adding PR to Map collection for further process. */
            }
        }
        /** Condition to check for null pointer exception for prIdToPrToProcessMap collection. */
        if(prIdToPrToProcessMap?.size() > 0) {
            //List<Task> taskToCreateList = new List<Task>(); /** To collect the tasks to create on Transmittal record for Accounting queue. */
            /** Fetching the related Transmittal records of PR whose Payment Request Id is available in prIdToPrToProcessMap collection Keyset. */
            Map<Id, Transmittal__c> trIdToTransmittalToApproveMap = new Map<Id, Transmittal__c>([SELECT Id, Name, Comments__c, PaymentRequest__c
                                        FROM Transmittal__c WHERE PaymentRequest__c IN : prIdToPrToProcessMap.keySet()]);
            /** Fetching the Accounting Queue record data in order to change the Owner of Transmittal to Accounting
             * to make the Transmittal record visible for Accounting user. */
            Group queueData = [SELECT Id, Name,DeveloperName FROM Group WHERE Type=:ALS_CONSTANTS.Queue_Type
                                        AND DeveloperName =: ALS_CONSTANTS.Queue_API_Name];
            /** Condition to check for null pointer exception for trIdToTransmittalToApproveMap collection. */
            if(trIdToTransmittalToApproveMap?.size() > 0) {
                /** Updating the Transmittal record to Stage Approved and Changing the Owner to Accounting Queue. */
                for (Transmittal__c transmittalToApprove : trIdToTransmittalToApproveMap.values()) {
                    transmittalToApprove.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved;
                    transmittalToApprove.OwnerId = queueData?.Id;
                    transmittalToApprove.Comments__c = ALS_CONSTANTS.Transmittal_ApprovalCommentForReturnedProjectPayment;

                    /*/** Creating a Task record on Transmittal and assigning it to Accounting Queue.
                    Task taskToCreate = new Task();
                    taskToCreate.OwnerId = queueData?.Id;
                    taskToCreate.WhatId = transmittalToApprove.Id;
                    taskToCreate.Status = ALS_CONSTANTS.Task_Status_Open;
                    taskToCreate.Subject = ALS_CONSTANTS.Task_Subject_InvoiceToSuRecipient;

                    taskToCreateList.add(taskToCreate);*/
                }
                /** Updating the Transmittal record and Locking it. */
                update trIdToTransmittalToApproveMap.values();
                //insert taskToCreateList;
                List<Id> trIdsToLock = new List<Id>();
                trIdsToLock.addAll(trIdToTransmittalToApproveMap.keySet());
                RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
                lockUnlock.lockRecord(trIdsToLock);
            }
        }
    }
    /** Ticket No - 476 - End */

/** Ticket - 886 - Start */
    /*********************************************
     * Method Name : lockNegativeOffsetPaymentRequestRecordUponPaymentProcessingStage
     * Called From Method : ProcessAfterUpdate
     * Author : Ricky.
     * Inputs : -
     * Description: This method is used lock the Negative Offset Payment Request upon marking the Stage to "Payment Processing".
     *********************************************/
    private void lockNegativeOffsetPaymentRequestRecordUponPaymentProcessingStage() {
        List<Id> paymentRequestIdToLockList = new List<Id>();
        for (Payment_Request__c negativeOffsetPrToLock : (List<Payment_Request__c>)Trigger.new) {
            if(negativeOffsetPrToLock.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                    && negativeOffsetPrToLock.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                    && !Approval.isLocked(negativeOffsetPrToLock.Id)
                    && (negativeOffsetPrToLock.ApprovedStatePaymentAmount__c < 0
                    || negativeOffsetPrToLock.ApprovedFederalPaymentAmount__c < 0)) {
                paymentRequestIdToLockList.add(negativeOffsetPrToLock.Id);
            }
        }
        if (paymentRequestIdToLockList?.size() > 0) {
            RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
            lockUnlock.lockRecord(paymentRequestIdToLockList);
        }
    }
    /** Ticket - 886 - End */
    
    /*********************************************
     * Method Name : updateAwardFieldWithActiveAwardUponPrRejection
     * Called From Method : ProcessBeforeUpdate
     * Author : Ricky.
     * Inputs : -
     * Description: This method is used update the Award field of PR with Active Award of Project,
     *              when the PR got rejected and it's Award is no longer Active now.
     *********************************************/
    private void updateAwardFieldWithActiveAwardUponPrRejection() {
        Map<Id, Payment_Request__c> prIdToPrToProcessMap = new Map<Id, Payment_Request__c>();
        Set<Id> projectIds = new Set<Id>();
        for (Payment_Request__c prToProcess : (List<Payment_Request__c>) Trigger.new) {
            Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(prToProcess.Id);
            if(oldRecord.Stage__c != prToProcess.Stage__c
                    && oldRecord.Stage__c == ALS_CONSTANTS.PR_Stage_InReview
                    && (prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation
                        || prToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_Processing)) {
                prIdToPrToProcessMap.put(prToProcess.Id, prToProcess);
                projectIds.add(prToProcess.Project__c);
            }
        }
        if(projectIds?.size() > 0) {
            Map<Id, Project__c> projectIdToProjectWithActiveAwardMap = new Map<Id, Project__c>([SELECT Id, Name,
                                                                                (SELECT Id, Name, Project__c FROM Awards__r
                                                                                    WHERE Status__c =: ALS_CONSTANTS.Award_Status_Active LIMIT 1)
                                                                                FROM Project__c WHERE Id IN : projectIds]);
            for (Payment_Request__c prToProcess : prIdToPrToProcessMap.values()) {
                if (prToProcess.Award__c != projectIdToProjectWithActiveAwardMap?.get(prToProcess.Project__c)?.Awards__r[0]?.Id) {
                    prToProcess.Award__c = projectIdToProjectWithActiveAwardMap?.get(prToProcess.Project__c)?.Awards__r[0]?.Id;
                }
            }
        }
    }

    /** Ticket - 969 - Start */
    /*********************************************
     * Method Name : updateCurrentApprovedAmountOnPrIncludingCurrentPR
     * Called From Method : ProcessBeforeUpdate
     * Author : Ricky.
     * Inputs : -
     * Description: This method is used update the Approved Amount on Payment Request including the current Payment Request record.
     *********************************************/
    private void updateCurrentApprovedAmountOnPrIncludingCurrentPR() {
        List<Payment_Request__c> paymentRequestToProcessList = new List<Payment_Request__c>();
        List<Id> paymentRequestIdToUnlockList = new List<Id>();
        Set<Id> projectIds = new Set<Id>();
        if (Trigger.isInsert) {
            for (Payment_Request__c pRequestToProcess : (List<Payment_Request__c>) Trigger.new) {
                if (pRequestToProcess.Project__c != null
                        && (pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                            || pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                            || pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_Paid)) {
                    paymentRequestToProcessList.add(pRequestToProcess);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Payment_Request__c pRequestToProcess : (List<Payment_Request__c>) Trigger.new) {
                Payment_Request__c oldRecord = (Payment_Request__c) Trigger.oldMap.get(pRequestToProcess.Id);
                if (oldRecord.Stage__c != pRequestToProcess.Stage__c
                        && pRequestToProcess.Project__c != null
                        && ((pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                                || pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                                || pRequestToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_Paid)
                            && oldRecord.Stage__c != ALS_CONSTANTS.PR_Stage_PaymentProcessing
                            && oldRecord.Stage__c != ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment
                            && oldRecord.Stage__c != ALS_CONSTANTS.PR_Stage_Paid)) {

                    if(Approval.isLocked(pRequestToProcess.Id)) {
                        paymentRequestIdToUnlockList.add(pRequestToProcess.Id);
                    }
                    paymentRequestToProcessList.add(pRequestToProcess);
                }
            }
        }
        if(paymentRequestToProcessList?.size() > 0) {
            RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
            if (paymentRequestIdToUnlockList?.size() > 0) {
                lockUnlock.unlockRecord(paymentRequestIdToUnlockList);
            }

            for (Payment_Request__c pRequestToProcess : paymentRequestToProcessList) {
                Decimal inReviewFederalApprovedAmount = (pRequestToProcess?.In_Review_Federal_Amount_Approved__c == null ? 0.00 : pRequestToProcess?.In_Review_Federal_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);
                Decimal inReviewStateAmountApproved = (pRequestToProcess?.In_Review_State_Amount_Approved__c == null ? 0.00 : pRequestToProcess?.In_Review_State_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);
                Decimal inReviewAdminApprovedAmount = (pRequestToProcess?.In_Review_Admin_Amount_Approved__c == null ? 0.00 : pRequestToProcess?.In_Review_Admin_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);

                Decimal currentPrFederalApprovedAmount = (pRequestToProcess?.ApprovedFederalPaymentAmount__c == null ? 0.00 : pRequestToProcess?.ApprovedFederalPaymentAmount__c)?.setScale(2,system.RoundingMode.DOWN);
                Decimal currentPrTotalStateApprovedAmount = (pRequestToProcess?.ApprovedStatePaymentAmount__c == null ? 0.00 : pRequestToProcess?.ApprovedStatePaymentAmount__c)?.setScale(2,system.RoundingMode.DOWN);
                Decimal currentPrAdminApprovedAmount = (pRequestToProcess?.TotalAdminShareAmount__c == null ? 0.00 : pRequestToProcess?.TotalAdminShareAmount__c)?.setScale(2,system.RoundingMode.DOWN);
                Decimal currentPrStateOnlyAmountApproved = (currentPrTotalStateApprovedAmount - currentPrAdminApprovedAmount);

                pRequestToProcess.Reviewed_Federal_Amount_Approved_to_Date__c = (inReviewFederalApprovedAmount + currentPrFederalApprovedAmount)?.setScale(2,system.RoundingMode.DOWN);
                pRequestToProcess.Reviewed_State_Amount_Approved_to_Date__c = (inReviewStateAmountApproved + currentPrStateOnlyAmountApproved)?.setScale(2,system.RoundingMode.DOWN);
                pRequestToProcess.Reviewed_Admin_Amount_Approved_to_Date__c = (inReviewAdminApprovedAmount + currentPrAdminApprovedAmount)?.setScale(2,system.RoundingMode.DOWN);

                pRequestToProcess.Reviewed_State_and_Admin_Amount_Approved__c = (pRequestToProcess.Reviewed_State_Amount_Approved_to_Date__c
                        + pRequestToProcess.Reviewed_Admin_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                pRequestToProcess.Reviewed_State_and_Fed_Amount_Approved__c = (pRequestToProcess.Reviewed_Federal_Amount_Approved_to_Date__c
                        + pRequestToProcess.Reviewed_State_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                pRequestToProcess.Reviewed_Total_Amount_Approved__c = (pRequestToProcess.Reviewed_Federal_Amount_Approved_to_Date__c
                        + pRequestToProcess.Reviewed_State_Amount_Approved_to_Date__c
                        + pRequestToProcess.Reviewed_Admin_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
            }
            if (paymentRequestIdToUnlockList?.size() > 0) {
                lockUnlock.lockRecord(paymentRequestIdToUnlockList);
            }
        }
    }
    /** Ticket - 969 - End */
}