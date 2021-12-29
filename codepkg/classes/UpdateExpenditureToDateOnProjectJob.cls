/**
 * Created by Sushant p on 21-04-2021.
 */
//Ticket No CaloESALS-405 and 429  To update Project fields which are Copied From highest amount in the Expenditures to Date WITH Retentions field on the PR
public with sharing class UpdateExpenditureToDateOnProjectJob implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    private final String query;

    public UpdateExpenditureToDateOnProjectJob(String query) {
        this.query = query;
    }
    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateExpenditureToDateOnProjectJob(query));
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        Set<Id> projectIds = new Set<Id>();
        List<Project__c> projectsToUpdate = new List<Project__c>();
        for(SObject sc : scope) {
            Project__c prj = (Project__c) sc;
            projectIds.add(prj.Id);
        }

        //List<Project__c> projectList =[SELECT Id FROM Project__c ];

        //for Filter using Created Date
        //Map<Id, Project__c> idToProjectWithPrsMap = new Map<Id, Project__c>([SELECT Id, Expenditure_To_Date__c, (SELECT Id, Project__c, ExpenditurestoDate__c ,FederalRetentionShare__c, StateRetentionShare__c FROM Payment_Requests__r WHERE Project__c IN :projectIds AND ExpenditurestoDate__c > 0 AND PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_Reimbursement AND Stage__c != :ALS_CONSTANTS.PR_Stage_Withdrawn ORDER BY CreatedDate DESC) FROM Project__c WHERE Id IN :projectIds]);
        //fetching PR which has Amount of Expenditure to date is big as compare to other PRs on perticular Project

        //for  Filter using Expenditure to Date
        Map<Id, Project__c> idToProjectWithPrsMap = new Map<Id, Project__c>([SELECT Id,
        (SELECT Id, Stage__c, Project__c, ExpenditurestoDate__c,FederalRetentionShare__c, StateRetentionShare__c
        FROM Payment_Requests__r
        WHERE Project__c IN :projectIds
        AND ExpenditurestoDate__c > 0
        AND (PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_Reimbursement OR PaymentType__c = :ALS_CONSTANTS.PR_PaymentType_FinalPayment )
        AND (Stage__c = :ALS_CONSTANTS.PR_Stage_PaymentProcessing OR Stage__c = :ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment OR Stage__c = :ALS_CONSTANTS.PR_Stage_Paid )
        ORDER BY ExpenditurestoDate__c DESC limit 1)
        FROM Project__c where Id IN :projectIds]);

        for(Project__c proj : idToProjectWithPrsMap.values()){
            List<Payment_Request__c> pr = idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r;
            if(pr.size() >0){
                proj.Expenditure_To_Date__c = idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].ExpenditurestoDate__c;
                proj.Federal_Retention_To_Date__c = idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].FederalRetentionShare__c == null?0.00:idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].FederalRetentionShare__c;
                proj.State_Retention_To_Date__c = idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].StateRetentionShare__c == null?0.00:idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].StateRetentionShare__c;
                proj.Total_Retention_To_Date__c = (idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].FederalRetentionShare__c == null?0.00:idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].FederalRetentionShare__c)+(idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].StateRetentionShare__c == null?0.00:idToProjectWithPrsMap.get(proj.Id).Payment_Requests__r[0].StateRetentionShare__c);
                projectsToUpdate.add(proj);
            } else{
                proj.Expenditure_To_Date__c = 0;
                proj.Federal_Retention_To_Date__c = 0;
                proj.State_Retention_To_Date__c = 0;
                proj.Total_Retention_To_Date__c = 0;
                projectsToUpdate.add(proj);
            }
        }
        if(projectsToUpdate.size() > 0) {
            update projectsToUpdate;
        }
    }
    public void finish(Database.BatchableContext bc) {
    }
}