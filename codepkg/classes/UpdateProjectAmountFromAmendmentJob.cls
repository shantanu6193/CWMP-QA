/**
 * Created by Ricky on 13-04-2021.
 */

public with sharing class UpdateProjectAmountFromAmendmentJob implements Database.Batchable<sObject>, Schedulable{
    private final String query;

    public UpdateProjectAmountFromAmendmentJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateProjectAmountFromAmendmentJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Project__c> projectsList = (List<Project__c>) scope;
        Set<Id> amendmentIds = new Set<Id>(); //To Collect the Amensdment Id for Collecting its Awrd..
        Map<Id, Award__c> amendmentIdToAwardMap = new Map<Id, Award__c>(); //To Map Amendment Id with Award ...
        List<Project__c> projectListToUpdate = new List<Project__c>(); //To collect List of Project for Updating..
        List<Award__c> awardListToUpdate = new List<Award__c>(); //To collect List of Award for Updating..
        for (Project__c project : projectsList) {
            if (project.Amendment_Requests__r.size() > 0) {
                amendmentIds.add(project.Amendment_Requests__r[0].Id);
            }
        }

        List<Award__c> awardList = [SELECT Id, AmountObligated__c, Amendment_Request__c FROM Award__c WHERE Amendment_Request__c IN : amendmentIds];
        for (Award__c award : awardList) {
            amendmentIdToAwardMap.put(award.Amendment_Request__c, award);
        }

        for (Project__c project : projectsList) {
            if (project.Amendment_Requests__r.size() > 0) {
                Award__c awardToProcess = amendmentIdToAwardMap.get(project.Amendment_Requests__r[0].Id);
                awardToProcess.Status__c = 'Active';
                project.Total_Project_Award__c = awardToProcess.AmountObligated__c;

                projectListToUpdate.add(project);
                awardListToUpdate.add(awardToProcess);
            }
        }
        if (projectListToUpdate.size() > 0) {
            update projectListToUpdate;
            update awardListToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}