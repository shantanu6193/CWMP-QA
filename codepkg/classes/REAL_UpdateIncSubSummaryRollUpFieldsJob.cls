/***********************************************************************************************************************************
* Class Name   : REAL_UpdateIncSubSummaryRollUpFieldsJob
* Description  : This batch class is created to update the Custom Roll Up fields on Incident Sub Recipient Summary records.
* Author       : Ricky 
* Created On   : 17/07/2020
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              17/07/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_UpdateIncSubSummaryRollUpFieldsJob  implements Database.Batchable<sObject>, Schedulable {
    private final String query;

    public REAL_UpdateIncSubSummaryRollUpFieldsJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateIncSubSummaryRollUpFieldsJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Incident_Subrecipient_Stage__c> summaryList = (List<Incident_Subrecipient_Stage__c>) scope;
        Set<Id> summaryIds = new Set<Id>();
        for (Incident_Subrecipient_Stage__c summary : summaryList) {
            summaryIds.add(summary.Id);
        }
        List<AggregateResult> results = [SELECT Incident_Subrecipient_Summary__c ,
                                                    SUM(Net_Federal_Amount_Available__c)FederalAmountAvailable,
                                                    SUM(Net_State_Amount_Available__c)StateAmountAvailable,
                                                    SUM(Net_Admin_Amount_Available__c)AvailableAdminAmount,
                                                    SUM(Total_Project_Award__c)TotalProjectAward,
                                                    SUM(Federal_Project_Award__c)FederalProjectAward,
                                                    SUM(State_Project_Award__c)StateProjectAward,
                                                    SUM(TotalProjectStateAdminShare__c)StateAdminShare,
                                                    SUM(Federal_Retention_To_Date__c)FederalRetentionToDate,
                                                    SUM(State_Retention_To_Date__c)StateRetentionToDate,
                                                    SUM(Total_Retention_To_Date__c)TotalRetentionToDate,
                                                    SUM(Total_Federal_Retention__c)TotalFederalRetention,
                                                    SUM(Total_State_Retention__c)TotalStateRetention,
                                                    SUM(Federal_Project_Award_W_O_Retention__c)FederalAwardWithRetention,
                                                    SUM(State_Project_Award_W_O_Retention__c)StateAwardWithoutRetention
                                            FROM Project__c
                                            WHERE Incident_Subrecipient_Summary__c IN : summaryIds AND
                                            Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                            GROUP BY Incident_Subrecipient_Summary__c];

        // Fetching the aggregate result for the Project which are of PA programs.
        List<AggregateResult> paResults = [SELECT Incident_Subrecipient_Summary__c, SUM(Federal_Project_Award__c)PaFederalProjectAward,
                                                    SUM(State_Project_Award__c)PaStateProjectAward,
                                                    SUM(TotalProjectStateAdminShare__c)PaAdminProjectAward
                                            FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIds
                                            AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                            AND (Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c =: ALS_CONSTANTS.Program_PA
                                            OR Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c =: ALS_CONSTANTS.Program_PA_StateOnly)
                                            GROUP BY Incident_Subrecipient_Summary__c];
        // Collection to collect the Aggregate result in order of Summary id as key and aggregate result record as value.
        Map<Id, AggregateResult> summaryIdToPaSummaryRecordMap = new Map<Id, AggregateResult>();
        if (paResults?.size() > 0) {
            for (AggregateResult aggResult :paResults) {
                Id summaryId = (Id)aggResult.get('Incident_Subrecipient_Summary__c');
                summaryIdToPaSummaryRecordMap.put(summaryId, aggResult);
            }
        }

        List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();
        for(AggregateResult aggResult : results) {
            Id summaryId = (Id)aggResult.get('Incident_Subrecipient_Summary__c');
            Incident_Subrecipient_Stage__c stageRecord = new Incident_Subrecipient_Stage__c();
            stageRecord.Id = summaryId;
            Decimal federalAmountAvailable = (Decimal)aggResult?.get('FederalAmountAvailable');
            Decimal stateAmountAvailable = (Decimal)aggResult?.get('StateAmountAvailable');
            Decimal adminAmountAvailable = (Decimal)aggResult?.get('AvailableAdminAmount');

            Decimal totalProjectAward = (Decimal)aggResult?.get('TotalProjectAward');
            Decimal federalProjectAward = (Decimal)aggResult?.get('FederalProjectAward');
            Decimal stateProjectAward = (Decimal)aggResult?.get('StateProjectAward');
            Decimal stateAdminShare = (Decimal)aggResult?.get('StateAdminShare');
            Decimal federalRetentionToDate = (Decimal)aggResult?.get('FederalRetentionToDate');
            Decimal stateRetentionToDate = (Decimal)aggResult?.get('StateRetentionToDate');

            Decimal TotalRetentionToDate = (Decimal)aggResult?.get('TotalRetentionToDate');
            Decimal TotalFederalRetention = (Decimal)aggResult?.get('TotalFederalRetention');
            Decimal TotalStateRetention = (Decimal)aggResult?.get('TotalStateRetention');
            Decimal FederalAwardWithRetention = (Decimal)aggResult?.get('FederalAwardWithRetention');
            Decimal StateAwardWithoutRetention = (Decimal)aggResult?.get('StateAwardWithoutRetention');

            stageRecord.Available_Federal_Amount__c = (federalAmountAvailable == null?0.00:federalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Available_State_Amount__c = (stateAmountAvailable == null?0.00:stateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Available_State_Admin_Amount__c = (adminAmountAvailable == null?0.00:adminAmountAvailable).setScale(2,system.RoundingMode.DOWN);

            stageRecord.Total_Amount_Obligated__c = (totalProjectAward == null?0.00:totalProjectAward).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_Federal_Amount_Obligated__c = (federalProjectAward == null?0.00:federalProjectAward).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_State_Amount_Obligated__c = (stateProjectAward == null?0.00:stateProjectAward).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_Admin_Amount_Obligated__c = (stateAdminShare == null?0.00:stateAdminShare).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_Federal_Retention_to_Date__c = (federalRetentionToDate == null?0.00:federalRetentionToDate).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_State_Retention_to_Date__c = (stateRetentionToDate == null?0.00:stateRetentionToDate).setScale(2,system.RoundingMode.DOWN);

            stageRecord.Total_Retention_To_Date__c = (TotalRetentionToDate == null?0.00:TotalRetentionToDate).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_Federal_Retention__c = (TotalFederalRetention == null?0.00:TotalFederalRetention).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_State_Retention__c = (TotalStateRetention == null?0.00:TotalStateRetention).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_Federal_Award_W_O_Retention__c = (FederalAwardWithRetention == null?0.00:FederalAwardWithRetention).setScale(2,system.RoundingMode.DOWN);
            stageRecord.Total_State_Award_W_O_Retention__c = (StateAwardWithoutRetention == null?0.00:StateAwardWithoutRetention).setScale(2,system.RoundingMode.DOWN);

            // Fetching the Aggregate Result for PA Project in order to update PA Roll Ups on Summary record.
            AggregateResult paResult = summaryIdToPaSummaryRecordMap?.get(summaryId);
            // Fetching the values from Aggregate Result record for PA projects...
            Decimal paFederalProjectAward = (Decimal)paResult?.get('PaFederalProjectAward');
            Decimal paStateProjectAward = (Decimal)paResult?.get('PaStateProjectAward');
            Decimal paAdminProjectAward = (Decimal)paResult?.get('PaAdminProjectAward');

            stageRecord.PA_Federal_Amount_Obligated__c = (paFederalProjectAward == null?0.00: paFederalProjectAward).setScale(2,system.RoundingMode.DOWN);
            stageRecord.PA_State_Amount_Obligated__c = (paStateProjectAward == null?0.00: paStateProjectAward).setScale(2,system.RoundingMode.DOWN);
            stageRecord.PA_State_Admin_Amount_Obligated__c = (paAdminProjectAward == null?0.00: paAdminProjectAward).setScale(2,system.RoundingMode.DOWN);

            stageRecordsToUpdate.add(stageRecord);
        }
        if (stageRecordsToUpdate?.size() > 0) {
            update stageRecordsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}