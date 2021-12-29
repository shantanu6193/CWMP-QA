/**
 * Created by Ricky on 29-03-2021.
 */

public with sharing class UpdateRequestedAndApprovedAmountJob implements Database.Batchable<sObject>, Schedulable {
    private final String query;

    public UpdateRequestedAndApprovedAmountJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateRequestedAndApprovedAmountJob(query));
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Project__c> projectListToProcess = (List<Project__c>) scope;
        Set<Id> projectIds = new Set<Id>();
        for (Project__c project : projectListToProcess) {
            projectIds.add(project.Id);
        }

        List<String> stageList = new List<String>();
        stageList.add(ALS_CONSTANTS.PR_Stage_Paid);//stageList.add('Paid');
        stageList.add(ALS_CONSTANTS.PR_Stage_PaymentProcessing);//stageList.add('Payment Processing');
        stageList.add(ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment);

        List<AggregateResult> approvedAmountResults = [SELECT Project__c, SUM(TotalAdminShareAmount__c)totalApprovedAdminAmount,
                SUM(ApprovedStatePaymentAmount__c) totalApprovedStateAmount, SUM(ApprovedFederalPaymentAmount__c)totalApprovedFederalAmount
        FROM Payment_Request__c WHERE Project__c IN : projectIds AND Stage__c IN : stageList GROUP BY Project__c];
        Map<Id, AggregateResult> projectIdToApprovedAmountAggregateResult = new Map<Id, AggregateResult>();
        if (approvedAmountResults.size() > 0) {
            for (AggregateResult result : approvedAmountResults) {
                Id projectId = (Id)result.get('Project__c');
                projectIdToApprovedAmountAggregateResult.put(projectId, result);
            }
        }

        List<AggregateResult> RequestedAmountResults = [SELECT Project__c, sum(TotalAdminShareAmount__c)totalRequestedAdminAmount,
                SUM(ApprovedStatePaymentAmount__c) totalRequestedStateAmount, SUM(ApprovedFederalPaymentAmount__c)totalRequestedFederalAmount
        FROM Payment_Request__c WHERE Project__c IN : projectIds AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn GROUP BY Project__c];

        Map<Id, AggregateResult> projectIdToRequestedAmountAggregateResult = new Map<Id, AggregateResult>();
        if (RequestedAmountResults.size() > 0) {
            for (AggregateResult result : RequestedAmountResults) {
                Id projectId = (Id)result.get('Project__c');
                projectIdToRequestedAmountAggregateResult.put(projectId, result);
            }
        }

        for (Project__c projectToProcess : projectListToProcess) {
            //Updating Requested Payment Amount on Project...
            AggregateResult requestedAmountResult = projectIdToRequestedAmountAggregateResult?.get(projectToProcess.Id);
            Decimal totalRequestedAdminAmount = (Decimal) requestedAmountResult?.get('totalRequestedAdminAmount') == null? 0.00 : (Decimal) requestedAmountResult?.get('totalRequestedAdminAmount');
            Decimal totalRequestedStateAmount = (Decimal) requestedAmountResult?.get('totalRequestedStateAmount') == null? 0.00 : (Decimal) requestedAmountResult?.get('totalRequestedStateAmount');
            Decimal totalRequestedFederalAmount = (Decimal) requestedAmountResult?.get('totalRequestedFederalAmount') == null? 0.00 : (Decimal) requestedAmountResult?.get('totalRequestedFederalAmount');
            projectToProcess.Total_Admin_Amount_Requested__c = totalRequestedAdminAmount==null? 0.00 :totalRequestedAdminAmount;
            projectToProcess.Total_State_Amount_Requested__c = ((totalRequestedStateAmount==null? 0.00 :totalRequestedStateAmount) - (totalRequestedAdminAmount==null? 0.00 :totalRequestedAdminAmount));
            projectToProcess.Total_Federal_Amount_Requested__c = totalRequestedFederalAmount==null? 0.00 :totalRequestedFederalAmount;

            //Updating Approved Payment Amount on Project...
            AggregateResult approvedAmountResult = projectIdToApprovedAmountAggregateResult?.get(projectToProcess.Id);
            Decimal totalApprovedAdminAmount = (Decimal) approvedAmountResult?.get('totalApprovedAdminAmount') == null? 0.00 : (Decimal) approvedAmountResult?.get('totalApprovedAdminAmount');
            Decimal totalApprovedStateAmount = (Decimal) approvedAmountResult?.get('totalApprovedStateAmount') == null? 0.00 : (Decimal) approvedAmountResult?.get('totalApprovedStateAmount');
            Decimal totalApprovedFederalAmount = (Decimal) approvedAmountResult?.get('totalApprovedFederalAmount') == null? 0.00 : (Decimal) approvedAmountResult?.get('totalApprovedFederalAmount');
            projectToProcess.Total_Admin_Amount_Approved__c = totalApprovedAdminAmount==null? 0.00 :totalApprovedAdminAmount;
            projectToProcess.Total_State_Amount_Approved__c = ((totalApprovedStateAmount==null? 0.00 :totalApprovedStateAmount) - (totalApprovedAdminAmount==null? 0.00 :totalApprovedAdminAmount));
            projectToProcess.Total_Federal_Amount_Approved__c = totalApprovedFederalAmount==null? 0.00 :totalApprovedFederalAmount;
        }

        update projectListToProcess;
    }

    public void finish(Database.BatchableContext bc) {
    }
}