/**
 * Created by Ricky on 07-07-2021.
 */
/** This batch jpb is created to update the State Cost Share of Flag on Incident Sub Recipient Summary Record. */
public with sharing class ALS_UpdateStateCostShareFlagOfSummaryJob implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public ALS_UpdateStateCostShareFlagOfSummaryJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ALS_UpdateStateCostShareFlagOfSummaryJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Incident_Subrecipient_Stage__c> summaryRecordList = (List<Incident_Subrecipient_Stage__c>) scope;
        Set<Id> summaryIds = new Set<Id>();
        for (Incident_Subrecipient_Stage__c summary : summaryRecordList) {
            summaryIds.add(summary.Id);
        }
        if (summaryIds?.size() > 0) {
            //Fetching all the Junction records...
            List<AggregateResult> aggregateResults = [SELECT Incident_Subrecipient_Summary__c,
                                                            SUM(Total_State_Amount_Requested__c)stateAmountRequested,
                                                            SUM(Total_Admin_Amount_Requested__c)adminAmountRequested
                                                        FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIds
                                                        AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                        GROUP BY Incident_Subrecipient_Summary__c];
            System.debug('Aggregate Result list size is..: '+aggregateResults.size());
            List<Incident_Subrecipient_Stage__c> stageRecordsToUpdateList = new List<Incident_Subrecipient_Stage__c>();
            for (AggregateResult result : aggregateResults) {
                Id summaryId = (Id)result.get('Incident_Subrecipient_Summary__c');
                Decimal stateShare = (Decimal)result.get('stateAmountRequested');
                Decimal adminShare = (Decimal)result.get('adminAmountRequested');
                Incident_Subrecipient_Stage__c summaryRecord = new Incident_Subrecipient_Stage__c();
                summaryRecord.Id = summaryId;
                Decimal aggregateCostShare = ((stateShare == null ? 0.00 : stateShare) + (adminShare == null ? 0.00 : adminShare))?.setScale(2,system.RoundingMode.DOWN);

                //System.debug('Current Aggregate Result is..: '+result);
                if (aggregateCostShare >= 2500) {
                    summaryRecord.Cumulative_State_Cost_Share_Flag__c = true;
                }
                else if (aggregateCostShare < 2500) {
                    summaryRecord.Cumulative_State_Cost_Share_Flag__c = false;
                }
                stageRecordsToUpdateList.add(summaryRecord);
            }
            System.debug('Total number of junctions to update is..: '+stageRecordsToUpdateList.size());
            if(stageRecordsToUpdateList.size() > 0) {
                update stageRecordsToUpdateList;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}