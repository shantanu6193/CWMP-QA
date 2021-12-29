/**
 * Created by Ricky on 12-05-2021.
 */

public with sharing class updateStateFederalAwardOfProjectJob implements Database.Batchable<sObject>, Schedulable {
    private final String query;

    public updateStateFederalAwardOfProjectJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new updateStateFederalAwardOfProjectJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Project__c> projectList = (List<Project__c>)scope;
        List<Project__c> projectToUpdateList = new List<Project__c>();
        for (Project__c projectToProcess : projectList) {
            Decimal totalProjectAward = projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c;
            Decimal stateSharePercentage = projectToProcess.State_Share__c == null ? 0.00 : projectToProcess.State_Share__c;
            Decimal femaSharePercentage = projectToProcess.FEMA_Share__c == null ? 0.00 : projectToProcess.FEMA_Share__c;
            if (projectToProcess.FundingSource__c != null) {
                if(projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                        || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
                    projectToProcess.Federal_Project_Award__c = (totalProjectAward * femaSharePercentage)/100;
                }
                if(projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                        || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
                    projectToProcess.State_Project_Award__c = (totalProjectAward * stateSharePercentage)/100;
                }
                projectToUpdateList.add(projectToProcess);
            }
        }

        if(projectToUpdateList.size() > 0) {
            update projectToUpdateList;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}