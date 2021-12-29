/**
 * Created by StackNexus Admin on 30-03-2021.
 */

public with sharing class SummaryJunctionRollupJob implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private final String query;

    public SummaryJunctionRollupJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new SummaryJunctionRollupJob(query));
    }

    public Database.QueryLocator start(Database.batchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext param1, List<SObject> Scope) {
       List<Incident_Subrecipient_Stage__c> summaryRecordList = (List<Incident_Subrecipient_Stage__c>) Scope;
        /*set<Id> recordId = new set<Id>();
        for(SObject obj : Scope){
            recordId.add(obj.Id);
        }
        List<Incident_Subrecipient_Stage__c> sammaryList =[SELECT Id,Account__c,Incident__c FROM Incident_Subrecipient_Stage__c where Id IN :recordId];*/
        Map<String,AggregateResult> incAccToAggregateResultMap = new Map<String,AggregateResult>();
        Set<Id> accIds =new Set<Id>();
        Set<Id> incIds =new Set<Id>();

        for(Incident_Subrecipient_Stage__c inc : summaryRecordList){
            //String key =(String)inc.Incident__c+(String)inc.Account__c;
            //accIncToSummaryMap.put(key,inc);
            accIds.add(inc.Account__c);
            incIds.add(inc.Incident__c);
        }
        if(accIds.size() > 0 && incIds.size() > 0 ) {
            List<AggregateResult> results = [SELECT Incident_Name__c,Obligating_Sub_Recipient__c ,
                                            SUM(FederalAmountAvailable__c)FederalAmountAvailable,
                                            SUM(StateAmountAvailable__c)StateAmountAvailable,
                                            SUM(AvailableAdminAmount__c)AvailableAdminAmount FROM Project__c
                                            WHERE Incident_Name__c IN : incIds AND
                                            Obligating_Sub_Recipient__c IN : accIds GROUP BY Incident_Name__c,Obligating_Sub_Recipient__c ];

            for (AggregateResult result : results) {
                Id incidentIds = (Id)result.get('Incident_Name__c');
                Id subRecipientId = (Id)result.get('Obligating_Sub_Recipient__c');
                String key = (String)incidentIds + (String)subRecipientId;
                incAccToAggregateResultMap.put(key, result);
            }
            for (Incident_Subrecipient_Stage__c summaryRecord : summaryRecordList) {
                String key =(String)summaryRecord.Incident__c+(String)summaryRecord.Account__c;
                AggregateResult result = (AggregateResult) incAccToAggregateResultMap?.get(key);
                Decimal federalAmountAvailable = (Decimal)result?.get('FederalAmountAvailable') == null ? 0.00 : (Decimal)result?.get('FederalAmountAvailable');
                Decimal stateAmountAvailable = (Decimal)result?.get('StateAmountAvailable') == null ? 0.00 : (Decimal)result?.get('StateAmountAvailable');
                Decimal adminAmountAvailable = (Decimal)result?.get('AvailableAdminAmount') == null ? 0.00 : (Decimal)result?.get('AvailableAdminAmount');

                summaryRecord.Available_State_Admin_Amount__c = adminAmountAvailable == null? 0.00 : adminAmountAvailable;
                summaryRecord.Available_Federal_Amount__c = federalAmountAvailable == null? 0.00 : federalAmountAvailable;
                summaryRecord.Available_State_Amount__c = stateAmountAvailable == null? 0.00 : stateAmountAvailable;
            }
            update summaryRecordList ;

            /*List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();
            for(AggregateResult aggResult :results){
                Id incidentIds = (Id)aggResult.get('Incident_Name__c');
                Id subRecipientId = (Id)aggResult.get('Obligating_Sub_Recipient__c');
                String key = (String)incidentIds + (String)subRecipientId;
                Incident_Subrecipient_Stage__c stageRecord = accIncToSummaryMap.get(key);
                Decimal federalAmountAvailable = (Decimal)aggResult.get('FederalAmountAvailable');
                Decimal stateAmountAvailable = (Decimal)aggResult.get('StateAmountAvailable');
                Decimal adminAmountAvailable = (Decimal)aggResult.get('AvailableAdminAmount');
                stageRecord.Available_Federal_Amount__c = federalAmountAvailable;
                stageRecord.Available_State_Amount__c = stateAmountAvailable;
                stageRecord.Available_State_Admin_Amount__c = adminAmountAvailable;
                stageRecordsToUpdate.add(stageRecord);
            }
            update stageRecordsToUpdate;*/
        }

    }
    public void finish(Database.BatchableContext BC) {

    }
}