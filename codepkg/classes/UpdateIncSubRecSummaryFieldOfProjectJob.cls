/**
 * Created by Ricky on 23-04-2021.
 */

public with sharing class UpdateIncSubRecSummaryFieldOfProjectJob implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    private final String query;

    public UpdateIncSubRecSummaryFieldOfProjectJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateIncSubRecSummaryFieldOfProjectJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Set<Id> subRecipientIds = new Set<Id>(); //To collect the Sub Recipient Id of Summary Object records...
        Set<Id> incidentIds = new Set<Id>(); //To Collect Incident Ids of Summary Object records....
        List<Project__c> projectList = (List<Project__c>) scope;
        for (Project__c project : projectList) {
            subRecipientIds.add(project.Obligating_Sub_Recipient__c);
            incidentIds.add(project.Incident_Name__c);
        }
        List<Incident_Subrecipient_Stage__c> stageList = [SELECT Id, Account__c, Incident__c FROM Incident_Subrecipient_Stage__c WHERE Account__c IN : subRecipientIds AND Incident__c  IN : incidentIds];

        Map<String, Incident_Subrecipient_Stage__c> incidentSubRecipientIdToStageRecordMap = new Map<String, Incident_Subrecipient_Stage__c>();
        for (Incident_Subrecipient_Stage__c stage : stageList) {
            String key = (String) stage.Incident__c + (String) stage.Account__c;
            incidentSubRecipientIdToStageRecordMap.put(key, stage);
        }
        for (Project__c project : projectList) {
            String key = (String) project.Incident_Name__c + (String) project.Obligating_Sub_Recipient__c;
            project.Incident_Subrecipient_Summary__c = incidentSubRecipientIdToStageRecordMap.get(key).Id;
        }
        update projectList;
        for (Project__c project : projectList) {
            if (project.Incident_Name__c != null) {
                String key = (String) project.Incident_Name__c + (String) project.Obligating_Sub_Recipient__c;
                project.Incident_Subrecipient_Summary__c = incidentSubRecipientIdToStageRecordMap.get(key).Id;
            }
        }
        update projectList;
    }

    public void finish(Database.BatchableContext bc) {
    }
}