/***********************************************************************************************************************************
* Class Name   : REAL_UpdateProgPrefixOnProjectNumJob
* Description  : This batch job is created append the Program prefix to project Number for PA Programs.
* Author       : Ricky
* Created On   : 04/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              17/07/2021       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_UpdateProgPrefixOnProjectNumJob implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public REAL_UpdateProgPrefixOnProjectNumJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateProgPrefixOnProjectNumJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        TriggerHelper.skipTrigger = true;
        List<Project__c> projectWithPrimaryAuthorizedAgentList = (List<Project__c>) scope;
        List<Project__c> projectToUpdateList = new List<Project__c>();

        for (Project__c project : projectWithPrimaryAuthorizedAgentList) {
            if (project.Project_Number__c != null) {
                if (project.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_CDAA) {
                    if (!project.Project_Number__c.startsWith('DSR')) {
                        project.Project_Number__c = 'DSR-'+project.Project_Number__c;
                        projectToUpdateList.add(project);
                    }
                }
                else if (project.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA_Federal
                        || project.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA_FMAG) {
                    if (!project.Project_Number__c.startsWith('PW')) {
                        project.Project_Number__c = 'PW-'+project.Project_Number__c;
                        projectToUpdateList.add(project);
                    }
                }
            }
        }
        if (projectToUpdateList?.size() > 0) {
            update projectToUpdateList;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}