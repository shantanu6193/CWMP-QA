public without sharing class PaymentTriggerHelper extends TriggerHelper {
    public override void processBeforeInsert() {
        //autoUpdateProjectOfPRonPayment();
        autoUpdateProjectOfPRonPayment();
        //selectSameProjectAsPR();
        //calculateStateAmountAndStateAdminAmount();
        calculateStateAmountAndStateAdminAmountNew();
        calculateActualStatePaymentAmountForCloseoutPayment ();
        updateTotalAmountPaidOfPayment();
    }
    public override void processBeforeUpdate() {
        //calculateStateAmountAndStateAdminAmount();
        calculateStateAmountAndStateAdminAmountNew();
        calculateActualStatePaymentAmountForCloseoutPayment ();
        updateTotalAmountPaidOfPayment();
    }
    public override void processAfterInsert() {
        //createCloseoutPayment();
        //createCloseoutPayment();
        //This method is used to update the Disbursed Amounts on Project, Whenever a Payment is Created.....
        updateDisbursedAmountCustomRollUpOnProjectForInsertAndUpdate(); // The reason to call this method in After Trigger is because we are updating a field through Process Builder..
        createNegativePaymentOnOriginalOffsetTR();
    }
    public override void processAfterUpdate() {
        //This method is used to update the Disbursed Amounts on Project, Whenever a Payment is Updated.....
        updateDisbursedAmountCustomRollUpOnProjectForInsertAndUpdate(); // The reason to call this method in After Trigger is because we are updating a field through Process Builder..
    }
    public override void processBeforeDelete() {
        //This method is used to update the Disbursed Amounts on Project, Whenever a Payment is Deleted.....
        updateDisbursedAmountCustomRollUpOnProjectForDelete();
    }
    public override void processAfterUndelete() {
        //This method is used to update the Disbursed Amounts on Project, Whenever a Payment is Undeleted.....
        updateDisbursedAmountCustomRollUpOnProjectForInsertAndUpdate(); // The reason to call this method in After Trigger is because we are updating a field through Process Builder..
    }

    private void updateTotalAmountPaidOfPayment() {
        List<Payment__c> paymentToProcessList = new List<Payment__c>();
        if (Trigger.isInsert) {
            paymentToProcessList = Trigger.new;
        }
        if (Trigger.isUpdate) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                Payment__c oldRecord = (Payment__c)Trigger.oldMap.get(paymentToProcess.Id);
                if (paymentToProcess.ActualStateAmount__c != oldRecord.ActualStateAmount__c
                        || paymentToProcess.FederalAmountPaid__c != oldRecord.FederalAmountPaid__c) {
                    paymentToProcessList.add(paymentToProcess);
                }
            }
        }

        for (Payment__c paymentToProcess : paymentToProcessList) {
            Decimal stateAmountPaid = (paymentToProcess.ActualStateAmount__c == null ? 0.00 : paymentToProcess.ActualStateAmount__c).setScale(2,system.RoundingMode.DOWN);
            Decimal federalAmountPaid = (paymentToProcess.FederalAmountPaid__c == null ? 0.00 : paymentToProcess.FederalAmountPaid__c).setScale(2,system.RoundingMode.DOWN);

            paymentToProcess.AmountPaid__c = (stateAmountPaid + federalAmountPaid).setScale(2,system.RoundingMode.DOWN);
        }
    }

    //To calculate the Actual State Amount to be Paid and State Admin Amount to be Paid...
    /*private void calculateStateAmountAndStateAdminAmount() {
        Set<Id> projectIds = new Set<Id>();
        Set<Id> pRequestIds = new Set<Id>();
        //List<Project__c> projectsToUpdate = new List<Project__c>();
        List<Payment__c> paymentsToProcessList = new List<Payment__c>();
        if (Trigger.isInsert ) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                if (paymentToProcess.Payment_Type__c != ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment
                        && paymentToProcess.Incident_Subrecipient_Summary__c == null) {
                    paymentsToProcessList.add(paymentToProcess);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                Payment__c oldRecord = (Payment__c)Trigger.oldMap.get(paymentToProcess.Id);
                if ( paymentToProcess.StateAmountPaid__c != oldRecord.StateAmountPaid__c
                        && paymentToProcess.Payment_Type__c != ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment
                        && paymentToProcess.Incident_Subrecipient_Summary__c == null) {
                    paymentsToProcessList.add(paymentToProcess);
                }
            }
        }
        if (paymentsToProcessList.size() > 0) {
            for (Payment__c paymentToProcess : paymentsToProcessList){
                pRequestIds.add(paymentToProcess.PaymentRequest__c);
                projectIds.add(paymentToProcess.Project__c);
            }
            Map<Id, Project__c> idToProjectWithPrMap = new Map<Id, Project__c>([SELECT Id, Name, TotalProjectStateAdminShare__c, PaytoStateAdmin__c, AdminAmountDisbursed__c, AvailableAdminAmount__c,
                                        (SELECT Id, PaymentType__c, TotalAdminShareAmount__c FROM Payment_Requests__r WHERE Id IN : pRequestIds) FROM Project__c WHERE Id IN : projectIds]);
            for (Payment__c paymentToProcess : paymentsToProcessList){
                Project__c project = idToProjectWithPrMap.get(paymentToProcess.Project__c);
                for (Payment_Request__c pRequest : project.Payment_Requests__r){
                    if (pRequest.Id == paymentToProcess.PaymentRequest__c) {
                        if (((project.AvailableAdminAmount__c < 0 && Trigger.isInsert)
                                    || (paymentToProcess.StateAdminAmount__c < 0 && Trigger.isUpdate))
                                && (pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                                    || pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)
                                && project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes
                                && paymentToProcess.StateAmountPaid__c < project.AvailableAdminAmount__c) {
                            if (Trigger.isInsert) {
                                paymentToProcess.StateAdminAmount__c = project.AvailableAdminAmount__c?.setScale(2,system.RoundingMode.DOWN);
                            }
                            else if (Trigger.isUpdate) {
                                paymentToProcess.StateAdminAmount__c = (paymentToProcess.StateAdminAmount__c + project.AvailableAdminAmount__c).setScale(2,system.RoundingMode.DOWN);
                            }
                            paymentToProcess.ActualStateAmount__c =  (paymentToProcess.StateAmountPaid__c - paymentToProcess.StateAdminAmount__c).setScale(2,system.RoundingMode.DOWN);
                        }
                        else if (((project.AvailableAdminAmount__c < 0 && Trigger.isInsert)
                                        || (paymentToProcess.StateAdminAmount__c < 0 && Trigger.isUpdate))
                                    && (pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                                        || pRequest.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)
                                    && project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes
                                    && paymentToProcess.StateAmountPaid__c >= project.AvailableAdminAmount__c) {
                            paymentToProcess.StateAdminAmount__c = paymentToProcess.StateAmountPaid__c?.setScale(2,system.RoundingMode.DOWN);
                            paymentToProcess.ActualStateAmount__c = 0;
                        }
                        else if (paymentToProcess.StateAmountPaid__c >= pRequest.TotalAdminShareAmount__c && pRequest.TotalAdminShareAmount__c > 0) {
                            paymentToProcess.StateAdminAmount__c = pRequest.TotalAdminShareAmount__c?.setScale(2,system.RoundingMode.DOWN);
                            paymentToProcess.ActualStateAmount__c =  (paymentToProcess.StateAmountPaid__c - paymentToProcess.StateAdminAmount__c).setScale(2,system.RoundingMode.DOWN);
                        }
                        else {
                            paymentToProcess.ActualStateAmount__c = paymentToProcess.StateAmountPaid__c?.setScale(2,system.RoundingMode.DOWN);
                        }
                    }
                }
            }
        }
    }*/

    //To calculate the Actual State Amount to be Paid and State Admin Amount to be Paid...
    private void calculateStateAmountAndStateAdminAmountNew() {
        Set<Id> projectIds = new Set<Id>();
        Set<Id> pRequestIds = new Set<Id>();
        List<Payment__c> paymentsToProcessList = new List<Payment__c>();
        if (Trigger.isInsert ) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                if (paymentToProcess.Payment_Type__c != ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment
                        && paymentToProcess.Incident_Subrecipient_Summary__c == null) {
                    paymentsToProcessList.add(paymentToProcess);
                }
            } 
        }
        if (Trigger.isUpdate) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                Payment__c oldRecord = (Payment__c)Trigger.oldMap.get(paymentToProcess.Id);
                if ( paymentToProcess.StateAmountPaid__c != oldRecord.StateAmountPaid__c
                        && paymentToProcess.Payment_Type__c != ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment
                        && paymentToProcess.Incident_Subrecipient_Summary__c == null) {
                    paymentsToProcessList.add(paymentToProcess);
                }
            }
        }
        if (paymentsToProcessList.size() > 0) {
            for (Payment__c paymentToProcess : paymentsToProcessList) {
                pRequestIds.add(paymentToProcess.PaymentRequest__c);
                projectIds.add(paymentToProcess.Project__c);
            }
            Map<Id, Payment_Request__c> prIdToPrMap = new Map<Id, Payment_Request__c>([SELECT Id, PaymentType__c, TotalAdminShareAmount__c,
                                                                        (SELECT Id, Name, StateAdminAmount__c FROM Payments__r)
                                                                    FROM Payment_Request__c WHERE Id IN : pRequestIds]);
            for (Payment__c paymentToProcess : paymentsToProcessList) {
                Payment_Request__c pRequestToProcess = prIdToPrMap?.get(paymentToProcess.PaymentRequest__c);
                Decimal totalAdminAmountOfPR = 0;
                if (pRequestToProcess?.Payments__r?.size() > 0) {
                    for (Payment__c payment : pRequestToProcess?.Payments__r) {
                        totalAdminAmountOfPR += (payment.StateAdminAmount__c == null ? 0.00 : payment.StateAdminAmount__c);
                    }
    }

                if (((pRequestToProcess.TotalAdminShareAmount__c < 0 && Trigger.isInsert)
                            || (paymentToProcess.StateAdminAmount__c < 0 && Trigger.isUpdate))
                        && (pRequestToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                            || pRequestToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)
                        && paymentToProcess.StateAmountPaid__c < pRequestToProcess.TotalAdminShareAmount__c) {
                    if (Trigger.isInsert) {
                        paymentToProcess.StateAdminAmount__c = pRequestToProcess.TotalAdminShareAmount__c?.setScale(2,system.RoundingMode.DOWN);
                    }
                    else if (Trigger.isUpdate) {
                        paymentToProcess.StateAdminAmount__c = (paymentToProcess.StateAdminAmount__c
                                + pRequestToProcess.TotalAdminShareAmount__c).setScale(2,system.RoundingMode.DOWN);
                    }
                    paymentToProcess.ActualStateAmount__c =  (paymentToProcess.StateAmountPaid__c
                            - paymentToProcess.StateAdminAmount__c).setScale(2,system.RoundingMode.DOWN);
                }
                else if (((pRequestToProcess.TotalAdminShareAmount__c < 0 && Trigger.isInsert)
                            || (paymentToProcess.StateAdminAmount__c < 0 && Trigger.isUpdate))
                        && (pRequestToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Offset
                            || pRequestToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment)
                        && paymentToProcess.StateAmountPaid__c >= pRequestToProcess.TotalAdminShareAmount__c) {
                    paymentToProcess.StateAdminAmount__c = paymentToProcess.StateAmountPaid__c?.setScale(2,system.RoundingMode.DOWN);
                    paymentToProcess.ActualStateAmount__c = 0;
                }
                else if (paymentToProcess.StateAmountPaid__c >= pRequestToProcess.TotalAdminShareAmount__c
                        && pRequestToProcess.TotalAdminShareAmount__c > 0) {
                    paymentToProcess.StateAdminAmount__c = pRequestToProcess.TotalAdminShareAmount__c?.setScale(2,system.RoundingMode.DOWN);
                    paymentToProcess.ActualStateAmount__c =  (paymentToProcess.StateAmountPaid__c
                            - paymentToProcess.StateAdminAmount__c).setScale(2,system.RoundingMode.DOWN);
                }
                else {
                    paymentToProcess.ActualStateAmount__c = paymentToProcess.StateAmountPaid__c?.setScale(2,system.RoundingMode.DOWN);
                }
            }
        }
    }


    //This method is used to update the Disbursed Amounts on Project, Whenever a Payment is Created/Updated/undeleted.....
    private void updateDisbursedAmountCustomRollUpOnProjectForInsertAndUpdate() {
        Set<Id> projectIds = new Set<Id>();
        List<Payment__c> paymentsToProcessList = new List<Payment__c>();
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                paymentsToProcessList.add(paymentToProcess);
                if (paymentToProcess.Project__c != null) {
                    projectIds.add(paymentToProcess.Project__c);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
                Payment__c oldRecord = (Payment__c)Trigger.oldMap.get(paymentToProcess.Id);
                if (paymentToProcess.AmountPaid__c != oldRecord.AmountPaid__c
                        || paymentToProcess.FederalAmountPaid__c != oldRecord.FederalAmountPaid__c
                        || paymentToProcess.StateAmountPaid__c != oldRecord.StateAmountPaid__c
                        || paymentToProcess.StateAdminAmount__c != oldRecord.StateAmountPaid__c) {
                    paymentsToProcessList.add(paymentToProcess);
                    if (paymentToProcess.Project__c != null) {
                        projectIds.add(paymentToProcess.Project__c);
                    }
                }
            }
        }

        if (projectIds.size() > 0) {
            List<Project__c> projectList = [SELECT Id, FederalAmountDisbursed__c, StateAmountDisbursed__c, AdminAmountDisbursed__c,
                    TotalAmountDisbursed__c FROM Project__c WHERE Id IN : projectIds];
            List<AggregateResult> resultList = [SELECT Project__c, SUM(AmountPaid__c)totalAmountPaid, SUM(FederalAmountPaid__c)federalAmountPaid,
                    SUM(ActualStateAmount__c)stateAmountPaid, SUM(StateAdminAmount__c)adminAmountPaid FROM Payment__c WHERE Project__c IN  : projectIds GROUP BY Project__c];
            Map<Id, AggregateResult> projectIdToAggregateResult = new Map<Id, AggregateResult>();
            if (resultList.size() > 0) {
                for (AggregateResult result : resultList) {
                    Id projectId = (Id) result.get('Project__c');
                    projectIdToAggregateResult.put(projectId, result);
                }
                for (Project__c project : projectList) {
                    AggregateResult result = projectIdToAggregateResult?.get(project.Id);
                    Decimal totalAmountPaid = (Decimal) result?.get('totalAmountPaid');
                    Decimal federalAmountPaid = (Decimal) result?.get('federalAmountPaid');
                    Decimal stateAmountPaid = (Decimal) result?.get('stateAmountPaid');
                    Decimal adminAmountPaid = (Decimal) result?.get('adminAmountPaid');

                    //Adding the updated value to the Project...
                    project.TotalAmountDisbursed__c = (totalAmountPaid == null ? 0.00 : totalAmountPaid).setScale(2,system.RoundingMode.DOWN);
                    project.FederalAmountDisbursed__c = (federalAmountPaid == null ? 0.00 : federalAmountPaid).setScale(2,system.RoundingMode.DOWN);
                    project.StateAmountDisbursed__c = (stateAmountPaid == null ? 0.00 : stateAmountPaid).setScale(2,system.RoundingMode.DOWN);
                    project.AdminAmountDisbursed__c = (adminAmountPaid == null ? 0.00 : adminAmountPaid).setScale(2,system.RoundingMode.DOWN);
                }
                update projectList;
            }
        }
    }

    //This method is used to update the Disbursed Amounts on Project, Whenever a Payment is Deleted.....
    private void updateDisbursedAmountCustomRollUpOnProjectForDelete() {
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Payment__c> paymentToDeleteMap = new Map<Id, Payment__c>();
        for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.old) {
            paymentToDeleteMap.put(paymentToProcess.Id, paymentToProcess);
            if (paymentToProcess.Project__c != null) {
                projectIds.add(paymentToProcess.Project__c);
            }
        }
        if (projectIds.size() > 0) {
            List<Project__c> projectList = [SELECT Id, FederalAmountDisbursed__c, StateAmountDisbursed__c, AdminAmountDisbursed__c,
                    TotalAmountDisbursed__c FROM Project__c WHERE Id IN : projectIds];
            List<AggregateResult> resultList = [SELECT Project__c, SUM(AmountPaid__c)totalAmountPaid, SUM(FederalAmountPaid__c)federalAmountPaid,
                    SUM(ActualStateAmount__c)stateAmountPaid, SUM(StateAdminAmount__c)adminAmountPaid
                    FROM Payment__c WHERE Id IN  : paymentToDeleteMap.keySet() AND Project__c IN  : projectIds GROUP BY Project__c];
            Map<Id, AggregateResult> projectIdToAggregateResult = new Map<Id, AggregateResult>();
            if (resultList.size() > 0) {
                for (AggregateResult result : resultList) {
                    Id projectId = (Id) result.get('Project__c');
                    projectIdToAggregateResult.put(projectId, result);
                }
                for (Project__c project : projectList) {
                    AggregateResult result = projectIdToAggregateResult?.get(project.Id);
                    Decimal totalAmountPaid = (Decimal) result?.get('totalAmountPaid');
                    Decimal federalAmountPaid = (Decimal) result?.get('federalAmountPaid');
                    Decimal stateAmountPaid = (Decimal) result?.get('stateAmountPaid');
                    Decimal adminAmountPaid = (Decimal) result?.get('adminAmountPaid');

                    //Adding the updated value to the Project...
                    project.TotalAmountDisbursed__c -= (totalAmountPaid == null ? 0.00 : totalAmountPaid).setScale(2,system.RoundingMode.DOWN);
                    project.FederalAmountDisbursed__c -= (federalAmountPaid == null ? 0.00 : federalAmountPaid).setScale(2,system.RoundingMode.DOWN);
                    project.StateAmountDisbursed__c -= (stateAmountPaid == null ? 0.00 : stateAmountPaid).setScale(2,system.RoundingMode.DOWN);
                    project.AdminAmountDisbursed__c -= (adminAmountPaid == null ? 0.00 : adminAmountPaid).setScale(2,system.RoundingMode.DOWN);
                }
                update projectList;
            }
        }
    }

    private void autoUpdateProjectOfPRonPayment() {
        Set<Id> paymentRequestIds = new Set<Id>();
        List<Payment__c> paymentToProcessList =  new List<Payment__c>();
        for (Payment__c paymentToProcess : (List<Payment__c>)Trigger.new) {
            if (paymentToProcess.PaymentRequest__c != null) {
                paymentRequestIds.add(paymentToProcess.PaymentRequest__c);
                paymentToProcessList.add(paymentToProcess);
            }
        }
        if (paymentRequestIds.size() > 0) {
            Map<Id, Payment_Request__c> idToPaymentRequestMap = new Map<Id, Payment_Request__c>([SELECT Id, Project__c
                                                                FROM Payment_Request__c WHERE Id IN  : paymentRequestIds]);
            for (Payment__c paymentToProcess : paymentToProcessList) {
                Payment_Request__c prToProcess = idToPaymentRequestMap.get(paymentToProcess.PaymentRequest__c);
                paymentToProcess.Project__c = prToProcess.Project__c;
            }
        }
    }
    private void calculateActualStatePaymentAmountForCloseoutPayment () {
        for(Payment__c paymentToProcess : (List<Payment__c>)Trigger.new)  {
            if(paymentToProcess.Incident_Subrecipient_Summary__c != null
                    && paymentToProcess.Payment_Type__c == ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment){
                Decimal actualstateAmount = paymentToProcess.ActualStateAmount__c == null ? 0.00 : paymentToProcess.ActualStateAmount__c;
                Decimal stateAdminAmount = paymentToProcess.StateAdminAmount__c == null ? 0.00 : paymentToProcess.StateAdminAmount__c;

                paymentToProcess.StateAmountPaid__c = (actualstateAmount + stateAdminAmount).setScale(2,system.RoundingMode.DOWN);
            }
        }
    }
    /***********************************************
     * Method Name : createNegativePaymentOnOriginalOffsetTR
     * Author : Sushant.
     * Inputs : -
     * Description: Create Negative Payment on Adjusted for Offset Transmittal if Payment got created on Related transmittal of Adjusted for Offset Transmittal.
     *********************************************/
    private void createNegativePaymentOnOriginalOffsetTR(){
        Map<Id,Payment__c> transmittalIdToPaymentMap = new Map<Id, Payment__c>();
        List<Payment__c> paymentsToCreate = new List<Payment__c>();
        for(Payment__c paymentToProcess:(List<Payment__c>) Trigger.new){
           if(paymentToProcess.AmountPaid__c > 0 && paymentToProcess.Transmittal__c != null){
               transmittalIdToPaymentMap.put(paymentToProcess.Transmittal__c,paymentToProcess);
           }
        }
        //Check If the current transmittal has related Adjusted for Offset Payment or Not
        List<Transmittal__c> transmittals =[SELECT Id, Adjusted_For_Offset__r.TransmittalType__c, Adjusted_For_Offset__c, Adjusted_For_Offset__r.Project__c, Adjusted_For_Offset__r.PaymentRequest__c  FROM Transmittal__c WHERE Adjusted_For_Offset__c !=null AND ApprovedAmount__c >0 AND Id IN :transmittalIdToPaymentMap.keySet()];
        for(Transmittal__c trans:transmittals){
            Payment__c offSetPayment =(Payment__c) transmittalIdToPaymentMap.get(trans.Id);
            Payment__c newPayment = new Payment__c();
            newPayment.Transmittal__c = trans.Adjusted_For_Offset__c;
            newPayment.Project__c = trans.Adjusted_For_Offset__r.Project__c;
            newPayment.PaymentRequest__c = trans.Adjusted_For_Offset__r.PaymentRequest__c;
            //If Payment type is State
            if(trans.Adjusted_For_Offset__r.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_State) {
                if(offSetPayment.StateAmountPaid__c >0) {
            newPayment.StateAmountPaid__c =  offSetPayment.StateAmountPaid__c == null?0:-offSetPayment.StateAmountPaid__c;
                }
                if(offSetPayment.FederalAmountPaid__c >0) {
                      newPayment.StateAmountPaid__c =  offSetPayment.FederalAmountPaid__c == null?0:-offSetPayment.FederalAmountPaid__c;
                }
            } //If Payment type is Federal
            else if(trans.Adjusted_For_Offset__r.TransmittalType__c == ALS_CONSTANTS.Transmittal_Type_Federal) {
                if(offSetPayment.StateAmountPaid__c >0) {
                    newPayment.FederalAmountPaid__c =  offSetPayment.StateAmountPaid__c == null?0:-offSetPayment.StateAmountPaid__c;
                }
                if(offSetPayment.FederalAmountPaid__c >0) {
            newPayment.FederalAmountPaid__c =  offSetPayment.FederalAmountPaid__c == null?0:-offSetPayment.FederalAmountPaid__c;
                }
            }
            newPayment.Payment_Type__c = ALS_CONSTANTS.Payment_PaymentType_RegularPayment;
            paymentsToCreate.add(newPayment);
        }
        if(paymentsToCreate.size()> 0){
            insert paymentsToCreate;
        }

    }

    /*private void createCloseoutPayment() {
        Map<Id, Payment__c> idToPaymentMap = new Map<Id, Payment__c>();
        Set<Id> incSubSummaryIds = new Set<Id>();
        for (Payment__c paymenttoProcess : (List<Payment__c>) Trigger.new) {
            if (paymenttoProcess.Incident_Subrecipient_Summary__c != null
                    && paymenttoProcess.Payment_Type__c == ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment) {
                idToPaymentMap.put(paymenttoProcess.Id, paymenttoProcess);
                incSubSummaryIds.add(paymenttoProcess.Incident_Subrecipient_Summary__c);
            }
        }
        if (incSubSummaryIds.size() > 0) {
            //Fetching Incident Sub Recipient Record Data...
            Map<Id,Incident_Subrecipient_Stage__c> idToSummaryRecordMap = new Map<Id,Incident_Subrecipient_Stage__c>([SELECT Id, Incident__c, Account__c,
            (SELECT Id, Name FROM Payments__r ORDER BY CreatedDate DESC) FROM Incident_Subrecipient_Stage__c WHERE Id IN : incSubSummaryIds]);
            //Map Collection to Store "Incident + Sub Recipient" as Key and Summary Record as Value...
            Map<String, Incident_Subrecipient_Stage__c> IncidentSubRecipientToStageRecordMap = new Map<String, Incident_Subrecipient_Stage__c>();
            //Collection to store the Account and Incident Ids in order to fetch the Project records...
            Set<Id> accountIds = new Set<Id>();
            Set<Id> incidentIds = new Set<Id>();
            //Iterating the idToSummaryRecordMap collection in order to collect the Account Id, Incident Id and to store the value in IncidentSubRecipientToStageIdMap collection...
            for(Incident_Subrecipient_Stage__c stageRecord : idToSummaryRecordMap.values()){
                accountIds.add(stageRecord.Account__c);
                incidentIds.add(stageRecord.Incident__c);
                String key = (String)stageRecord.Incident__c + (String)stageRecord.Account__c;
                IncidentSubRecipientToStageRecordMap.put(key, stageRecord);
            }
            //Fetching the Project record which is associated with the Sub Recipient and Incident avilable in Set collection...
            Map<Id,Project__c> projectIdsToProjectsMap = new Map<Id,Project__c>([SELECT Id, Name, StateAmountAvailable__c, AvailableAdminAmount__c,
                    FederalAmountAvailable__c, Project_Number__c, Total_Project_Award__c, AmountAvailable__c, Incident_Name__c, Stage__c,
                    Obligating_Sub_Recipient__c, StateAmountDisbursed__c, FederalAmountDisbursed__c,
                    Declaration_Number__c, Obligating_Sub_Recipient__r.Sub_Recipient_FIPS__c, CalOES_Project_Number__c,
                    (SELECT Id, IncidentName__c, ObligatedSubRecipient__c, StateEstimatedPaymentAmount__c, FederalEstimatedPaymentAmount__c, Stage__c,
                            Cumulative_State_Cost_Share_Flag__c, PaymentType__c, PaymentDelivery__c, ApprovedStatePaymentAmount__c, Project__c,
                            ApprovedFederalPaymentAmount__c FROM Payment_Requests__r WHERE PaymentType__c =: ALS_CONSTANTS.PR_PaymentType_FinalPayment LIMIT 1)
                    FROM Project__c WHERE Obligating_Sub_Recipient__c IN :accountIds AND Incident_Name__c IN : incidentIds ]);

            //Collection to store the  "Incident + Sub Recipient" as Key and List of Associated Project Record as Value...
            Map<String, List<Project__c>> IncidentSubRecipientToProjectListMap = new Map<String, List<Project__c>>();
            for (Project__c project : projectIdsToProjectsMap.values()) {
                String key = (String)project.Incident_Name__c + (String)project.Obligating_Sub_Recipient__c;
                if (IncidentSubRecipientToProjectListMap.containsKey(key)) {
                    List<Project__c> projectList = IncidentSubRecipientToProjectListMap.get(key);
                    projectList.add(project);
                    IncidentSubRecipientToProjectListMap.put(key, projectList);
                }
                else if (!IncidentSubRecipientToProjectListMap.containsKey(key)) {
                    List<Project__c> projectList = new List<Project__c>();
                    projectList.add(project);
                    IncidentSubRecipientToProjectListMap.put(key, projectList);
                }
            }

            List<Project__c> projectsToCloseout = new List<Project__c>();
            //List<Payment_Request__c> prListToInsert = new List<Payment_Request__c>();
            List<Payment_Request__c> prListToUpsert = new List<Payment_Request__c>();
            List<Id> prsToUnlock = new List<Id>();
            Map<Id, String> existingPrIdWithTransmittalTypeToCreateMap = new Map<Id, String>();
            for (Payment__c paymentToProcess : idToPaymentMap.values()) {
                Incident_Subrecipient_Stage__c summaryRecord = idToSummaryRecordMap.get(paymentToProcess.Incident_Subrecipient_Summary__c);
                String key = (String)summaryRecord.Incident__c + (String)summaryRecord.Account__c;
                Decimal federalPaymentAmount = paymentToProcess.FederalAmountPaid__c == null ? 0.00 : paymentToProcess.FederalAmountPaid__c;
                Decimal stateAdminAmount = paymentToProcess.StateAdminAmount__c == null ? 0.00 : paymentToProcess.StateAdminAmount__c;
                Decimal statePaymentAmount = paymentToProcess.ActualStateAmount__c == null ? 0.00 : paymentToProcess.ActualStateAmount__c;
                List<Project__c> projectList = IncidentSubRecipientToProjectListMap.get(key);
                for (Project__c project : projectList) {
                    Payment_Request__c closeoutPrOfProject;
                    if (project.Payment_Requests__r.size() > 0) {
                        closeoutPrOfProject = project.Payment_Requests__r[0];
                    }

                    if (project.AmountAvailable__c == 0 && project.AvailableAdminAmount__c == 0
                            && project.Stage__c != ALS_CONSTANTS.Project_Stage_Closeout) {
                        //Updating Project Stage to Closeout...
                        project.Stage__c = ALS_CONSTANTS.Project_Stage_Closeout;
                        projectsToCloseout.add(project);
                    }
                    else if(federalPaymentAmount > 0 && project.FederalAmountAvailable__c > 0) {
                        //Updating Project Stage to Closeout...
                        if (project.Stage__c != ALS_CONSTANTS.Project_Stage_Closeout) {
                            project.Stage__c = ALS_CONSTANTS.Project_Stage_Closeout;
                            projectsToCloseout.add(project);
                        }

                        if (closeoutPrOfProject != null) {
                            prsToUnlock.add(closeoutPrOfProject.Id);
                            existingPrIdWithTransmittalTypeToCreateMap.put(closeoutPrOfProject.Id, ALS_CONSTANTS.Transmittal_Type_Federal);
                            closeoutPrOfProject.FederalEstimatedPaymentAmount__c = project.FederalAmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                            closeoutPrOfProject.ApprovedFederalPaymentAmount__c = project.FederalAmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                            prListToUpsert.add(closeoutPrOfProject);
                        }
                        else {
                            Payment_Request__c pRToInsert = new Payment_Request__c();
                            pRToInsert.Project__c = project.Id;
                            pRToInsert.Cumulative_State_Cost_Share_Flag__c = true;
                            pRToInsert.PaymentType__c = ALS_CONSTANTS.PR_PaymentType_FinalPayment;
                            pRToInsert.Stage__c = ALS_CONSTANTS.PR_Stage_Paid;
                            pRToInsert.IncidentName__c = project.Incident_Name__c;
                            pRToInsert.ObligatedSubRecipient__c = project.Obligating_Sub_Recipient__c;
                            pRToInsert.PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard;

                            //Federal Estimated Payment Amount Calculation...
                            if (federalPaymentAmount > 0 && project.FederalAmountAvailable__c > 0 && federalPaymentAmount >= project.FederalAmountAvailable__c) {
                                pRToInsert.FederalEstimatedPaymentAmount__c = project.FederalAmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                                pRToInsert.ApprovedFederalPaymentAmount__c = project.FederalAmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                            }
                            else if (federalPaymentAmount > 0 && project.FederalAmountAvailable__c > 0 && federalPaymentAmount < project.FederalAmountAvailable__c) {
                                pRToInsert.FederalEstimatedPaymentAmount__c = federalPaymentAmount.setScale(2,system.RoundingMode.DOWN);
                                pRToInsert.ApprovedFederalPaymentAmount__c = federalPaymentAmount.setScale(2,system.RoundingMode.DOWN);
                            }
                            prListToUpsert.add(pRToInsert);
                        }
                    }
                    else if((statePaymentAmount > 0 &&  project.StateAmountAvailable__c > 0)
                            || (stateAdminAmount > 0 &&  project.AvailableAdminAmount__c > 0)) {
                        //Updating Project Stage to Closeout...
                        if (project.Stage__c != ALS_CONSTANTS.Project_Stage_Closeout) {
                            project.Stage__c = ALS_CONSTANTS.Project_Stage_Closeout;
                            projectsToCloseout.add(project);
                        }

                        if (closeoutPrOfProject != null) {
                            prsToUnlock.add(closeoutPrOfProject.Id);
                            existingPrIdWithTransmittalTypeToCreateMap.put(closeoutPrOfProject.Id, ALS_CONSTANTS.Transmittal_Type_State);
                            closeoutPrOfProject.TotalAdminShareAmount__c = project.AvailableAdminAmount__c?.setScale(2,system.RoundingMode.DOWN);
                            closeoutPrOfProject.StateEstimatedPaymentAmount__c = (project.StateAmountAvailable__c + closeoutPrOfProject.TotalAdminShareAmount__c).setScale(2,system.RoundingMode.DOWN);
                            closeoutPrOfProject.ApprovedStatePaymentAmount__c = (project.StateAmountAvailable__c + closeoutPrOfProject.TotalAdminShareAmount__c).setScale(2,system.RoundingMode.DOWN);
                            prListToUpsert.add(closeoutPrOfProject);
                        }
                        else {
                            Payment_Request__c pRToInsert = new Payment_Request__c();
                            pRToInsert.Project__c = project.Id;
                            pRToInsert.Cumulative_State_Cost_Share_Flag__c = true;
                            pRToInsert.PaymentType__c = ALS_CONSTANTS.PR_PaymentType_FinalPayment;
                            pRToInsert.Stage__c = ALS_CONSTANTS.PR_Stage_Paid;
                            pRToInsert.IncidentName__c = project.Incident_Name__c;
                            pRToInsert.ObligatedSubRecipient__c = project.Obligating_Sub_Recipient__c;
                            pRToInsert.PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard;

                            //State Estimated Payment Amount Calculation...
                            pRToInsert.TotalAdminShareAmount__c = project.AvailableAdminAmount__c?.setScale(2,system.RoundingMode.DOWN);
                            pRToInsert.StateEstimatedPaymentAmount__c = (project.StateAmountAvailable__c + pRToInsert.TotalAdminShareAmount__c).setScale(2,system.RoundingMode.DOWN);
                            pRToInsert.ApprovedStatePaymentAmount__c = (project.StateAmountAvailable__c + pRToInsert.TotalAdminShareAmount__c).setScale(2,system.RoundingMode.DOWN);
                            prListToUpsert.add(pRToInsert);
                        }
                    }
                }
            }
            if (projectsToCloseout.size() > 0) {
                update projectsToCloseout;
            }
            if (prListToUpsert.size() > 0) {
                if (prsToUnlock.size() > 0) {
                    RecordLockUnlockClass lockUnlockClass = new RecordLockUnlockClass() ;
                    lockUnlockClass.unlockRecord(prsToUnlock);
                    //Approval.unlock(prsToUnlock);
                }
                upsert prListToUpsert;
                createCloseoutTransmittalAndPayment (prListToUpsert,  IncidentSubRecipientToStageRecordMap,
                        projectIdsToProjectsMap, existingPrIdWithTransmittalTypeToCreateMap);
            }
        }
    }

    private void createCloseoutTransmittalAndPayment (List<Payment_Request__c> prListToInsert, Map<String,
            Incident_Subrecipient_Stage__c> IncidentSubRecipientToStageRecordMap,
            Map<Id,Project__c> projectIdsToProjectsMap, Map<Id, String> existingPrIdWithTransmittalTypeToCreateMap) {
        List<Transmittal__c> transmittalsToInsertList = new List<Transmittal__c>();
        List<Payment__c> paymentsToInsertList = new List<Payment__c>();
        List<String> prsToLock = new List<String>();
        for (Payment_Request__c paymentRequest : prListToInsert) {
            String key = (String)paymentRequest.IncidentName__c + (String)paymentRequest.ObligatedSubRecipient__c;
            Incident_Subrecipient_Stage__c summaryRecord =  IncidentSubRecipientToStageRecordMap.get(key);
            prsToLock.add((String)paymentRequest.Id);
            Project__c project = projectIdsToProjectsMap.get(paymentRequest.Project__c);
            String transmittalToCreateForExistingPr = existingPrIdWithTransmittalTypeToCreateMap?.get(paymentRequest.Id);
            if (paymentRequest.ApprovedStatePaymentAmount__c > 0
                    && (transmittalToCreateForExistingPr == null || transmittalToCreateForExistingPr == ALS_CONSTANTS.Transmittal_Type_State)) {
                Transmittal__c transToInsertState =  new Transmittal__c();
                transToInsertState.PaymentRequest__c = paymentRequest.Id;
                transToInsertState.Project__c = paymentRequest.Project__c;
                transToInsertState.TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_State;
                transToInsertState.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved;
                transToInsertState.PaymentDelivery__c = paymentRequest.PaymentDelivery__c;
                transToInsertState.Cumulative_State_Cost_Share_Flag__c = true;
                transToInsertState.ProjectPONumber__c = project.Project_Number__c;

                transToInsertState.Total_amount_Obligated__c = project.Total_Project_Award__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertState.Amount_Available__c = project.AmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertState.Admin_Share_Amount__c = project.AvailableAdminAmount__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertState.ExpenditurestoDate__c = project.StateAmountDisbursed__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertState.ApprovedAmount__c = project.StateAmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                transmittalsToInsertList.add(transToInsertState);
            }
            //Creating Federal Transmittal...
            if (paymentRequest.ApprovedFederalPaymentAmount__c > 0
                    && (transmittalToCreateForExistingPr == null || transmittalToCreateForExistingPr == ALS_CONSTANTS.Transmittal_Type_Federal)) {
                Transmittal__c transToInsertFederal =  new Transmittal__c();
                transToInsertFederal.PaymentRequest__c = paymentRequest.Id;
                transToInsertFederal.Project__c = paymentRequest.Project__c;
                transToInsertFederal.TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal;
                transToInsertFederal.Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved;
                transToInsertFederal.PaymentDelivery__c = paymentRequest.PaymentDelivery__c;
                transToInsertFederal.ProjectPONumber__c = project.Project_Number__c;

                transToInsertFederal.Total_amount_Obligated__c = project.Total_Project_Award__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertFederal.Amount_Available__c = project.AmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertFederal.ExpenditurestoDate__c = project.FederalAmountDisbursed__c?.setScale(2,system.RoundingMode.DOWN);
                transToInsertFederal.ApprovedAmount__c = project.FederalAmountAvailable__c?.setScale(2,system.RoundingMode.DOWN);
                transmittalsToInsertList.add(transToInsertFederal);
            }
            Payment__c payment = new Payment__c();
            payment.PaymentRequest__c = paymentRequest.Id;
            payment.Payment_Type__c = ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment;
            payment.Closeout_Payment__c = summaryRecord.Payments__r[0].Id;
            if (transmittalToCreateForExistingPr == null || transmittalToCreateForExistingPr == ALS_CONSTANTS.Transmittal_Type_Federal) {
                payment.FederalAmountPaid__c = (paymentRequest.ApprovedFederalPaymentAmount__c == null ? 0.00 : paymentRequest.ApprovedFederalPaymentAmount__c).setScale(2,system.RoundingMode.DOWN);
            }
            if (transmittalToCreateForExistingPr == null || transmittalToCreateForExistingPr == ALS_CONSTANTS.Transmittal_Type_State) {
                payment.StateAdminAmount__c = (paymentRequest.TotalAdminShareAmount__c == null ? 0.00 : paymentRequest.TotalAdminShareAmount__c).setScale(2,system.RoundingMode.DOWN);
                payment.StateAmountPaid__c = (paymentRequest.ApprovedStatePaymentAmount__c == null ? 0.00 : paymentRequest.ApprovedStatePaymentAmount__c).setScale(2,system.RoundingMode.DOWN);
                if (payment.StateAmountPaid__c >= payment.StateAdminAmount__c) {
                    payment.ActualStateAmount__c = (payment.StateAmountPaid__c - payment.StateAdminAmount__c).setScale(2,system.RoundingMode.DOWN);
                }
                else {
                    payment.ActualStateAmount__c = 0;
                }
            }

            //payment.AmountPaid__c = payment.ActualStateAmount__c + payment.FederalAmountPaid__c;
            paymentsToInsertList.add(payment);
        }
        insert transmittalsToInsertList;
        List<String> transmittalToLock = new List<String>();
        for (Transmittal__c trans : transmittalsToInsertList) {
            transmittalToLock.add((String)trans.Id);
        }
        if (prsToLock.size() > 0) {
            RecordLockUnlockClass lockUnlockClass = new RecordLockUnlockClass() ;
            lockUnlockClass.lockRecord(prsToLock);
            lockUnlockClass.lockRecord(transmittalToLock);
            //ApexUtils.lockRecord(prsToLock);
            //ApexUtils.lockRecord(transmittalToLock);
        }
        insert paymentsToInsertList;
    }*/
}