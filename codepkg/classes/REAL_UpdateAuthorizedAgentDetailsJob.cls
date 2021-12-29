/***********************************************************************************************************************************
* Class Name   : REAL_UpdateAuthorizedAgentDetailsJob
* Description  : This batch job is created to update the Primary Authorized Agent Details on project.
* Author       : Ricky
* Created On   : 19/07/2020
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              17/07/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_UpdateAuthorizedAgentDetailsJob implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public REAL_UpdateAuthorizedAgentDetailsJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateAuthorizedAgentDetailsJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Project__c> projectWithPrimaryAuthorizedAgentList = (List<Project__c>) scope;
        List<Project__c> projectToUpdateList = new List<Project__c>();

        for (Project__c project : projectWithPrimaryAuthorizedAgentList) {
            if (project?.Project_Roles__r?.size() == 1) {
                Project_Role__c authorizedAgent = project?.Project_Roles__r[0];

                project.Authorized_Agent_LastName__c = authorizedAgent.AccountContactJunction__r.Contact_Name__r.LastName;
                if (authorizedAgent.AccountContactJunction__r.Contact_Name__r.FirstName != null) {
                    project.Authorized_Agent_FirstName__c = authorizedAgent.AccountContactJunction__r.Contact_Name__r.FirstName;
                }
                if (authorizedAgent.AccountContactJunction__r.Contact_Name__r.Title != null) {
                    project.Authorized_Agent_Title__c = authorizedAgent.AccountContactJunction__r.Contact_Name__r.Title;
                }
                if (authorizedAgent.AccountContactJunction__r.Contact_Name__r.Salutation != null) {
                    project.Authorized_Agent_Salutation__c = authorizedAgent.AccountContactJunction__r.Contact_Name__r.Salutation;
                }

                projectToUpdateList.add(project);
            }
        }
        if (projectToUpdateList?.size() > 0) {
            update  projectToUpdateList;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}