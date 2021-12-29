/**
 * Created by ricky on 18-03-2021.
 */

public with sharing class UpdateIncidentSubRecipeintStageRecordJob implements Database.Batchable<sObject>, Schedulable {
    private final String query;

    public UpdateIncidentSubRecipeintStageRecordJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateIncidentSubRecipeintStageRecordJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Set<Id> incidentIds = new Set<Id>();
        Set<Id> subRecipientIds = new Set<Id>();
        //Map<String, Incident_Subrecipient_Stage__c> incidentSubRecipientIdToStageRecord = new Map<String, Incident_Subrecipient_Stage__c>();
        Map<String, AggregateResult> incidentSubRecipientIdToAggregateResultManualPrs = new Map<String, AggregateResult>();
        Map<String, AggregateResult> incidentSubRecipientIdToAggregateResultMigratedPrs = new Map<String, AggregateResult>();
        List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();

        if(scope.size() > 0) {
            List<Incident_Subrecipient_Stage__c> stageRecordList = (List<Incident_Subrecipient_Stage__c>) scope;
            for(Incident_Subrecipient_Stage__c stageRecord : stageRecordList) {
                incidentIds.add(stageRecord.Incident__c);
                subRecipientIds.add(stageRecord.Account__c);
                //incidentSubRecipientIdToStageRecord.put((String)stageRecord.Incident__c + (String)stageRecord.Account__c, stageRecord);
            }
            List<AggregateResult> AggregateResultListOfManualPRs = ([SELECT IncidentName__c, ObligatedSubRecipient__c,
                    SUM(StateCostShare__c) totalStateCostShare FROM Payment_Request__c WHERE External_Id__c = NULL
            AND IncidentName__c IN : incidentIds AND ObligatedSubRecipient__c IN : subRecipientIds
            AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn GROUP BY IncidentName__c, ObligatedSubRecipient__c]);
            //Fetching the Aggregate Result of Migrated PRs...
            List<AggregateResult> AggregateResultListOfMigratedPRs = ([SELECT IncidentName__c, ObligatedSubRecipient__c,
                    SUM(ApprovedStatePaymentAmount__c)cumulativeApprovedStateAmount, SUM(TotalAdminShareAmount__c)cumulativeAdminShareAmount FROM Payment_Request__c
            WHERE External_Id__c != NULL AND IncidentName__c IN : incidentIds AND ObligatedSubRecipient__c IN : subRecipientIds
            AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn GROUP BY IncidentName__c, ObligatedSubRecipient__c]);

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

            for(Incident_Subrecipient_Stage__c stageRecordToProcess : stageRecordList) {
                String key = (String)stageRecordToProcess.Incident__c + (String)stageRecordToProcess.Account__c;

                AggregateResult resultManualPRs = incidentSubRecipientIdToAggregateResultManualPrs?.get(key);
                Decimal cumulativeCostShareManualPrs = (Decimal)resultManualPRs?.get('totalStateCostShare');
                Decimal stateShareManual = cumulativeCostShareManualPrs == null?0.00:cumulativeCostShareManualPrs;

                AggregateResult resultMigratedPRs = incidentSubRecipientIdToAggregateResultMigratedPrs?.get(key);
                Decimal cumulativeCostShareMigratedPrs = (Decimal)resultMigratedPRs?.get('cumulativeApprovedStateAmount');
                Decimal cumulativeAdminShareMigratedPrs = (Decimal)resultMigratedPRs?.get('cumulativeAdminShareAmount');
                Decimal stateShareMigrated = cumulativeCostShareMigratedPrs == null?0.00:cumulativeCostShareMigratedPrs;
                Decimal AdminShareMigrated = cumulativeAdminShareMigratedPrs == null?0.00:cumulativeAdminShareMigratedPrs;

                Decimal stateShareNew = stateShareManual + stateShareMigrated + AdminShareMigrated ;

                if (stateShareNew >= Decimal.valueOf(2500)) {
                    stageRecordToProcess.Cumulative_State_Cost_Share_Flag__c = true;
                }
                else if (stateShareNew < Decimal.valueOf(2500)) {
                    stageRecordToProcess.Cumulative_State_Cost_Share_Flag__c = false;
                }
                stageRecordsToUpdate.add(stageRecordToProcess);
            }
        }
        if (stageRecordsToUpdate.size() > 0) {
            update stageRecordsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}