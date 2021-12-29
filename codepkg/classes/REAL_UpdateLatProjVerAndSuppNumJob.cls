/***********************************************************************************************************************************
* Class Name   : REAL_UpdateAwardRecordNewFieldsBatch
* Description  : This batch job is created to update the Total Individual Retentions and Amount Except Retention, Latest Project Version
 *                  and Latest Supplement Number field of Project record.
* Author       : Ricky
* Created On   : 20/07/2020
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              20/07/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_UpdateLatProjVerAndSuppNumJob implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public REAL_UpdateLatProjVerAndSuppNumJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateLatProjVerAndSuppNumJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Project__c> projectRecordList = (List<Project__c>) scope;
        for (Project__c project : projectRecordList) {
            Decimal federalProjectAmount = project.Federal_Project_Award__c == null ? 0.00 : project.Federal_Project_Award__c;
            Decimal stateProjectAmount = project.State_Project_Award__c == null ? 0.00 : project.State_Project_Award__c;
            Decimal federalRetention = project.Federal_Retention__c == null ? 0.00 : project.Federal_Retention__c;
            Decimal stateRetention = project.State_Retention__c == null ? 0.00 : project.State_Retention__c;

            project.Total_Federal_Retention__c = ((federalProjectAmount * federalRetention)/100)?.setScale(2,system.RoundingMode.DOWN);
            project.Total_State_Retention__c = ((stateProjectAmount * stateRetention)/100)?.setScale(2,system.RoundingMode.DOWN);
            project.Federal_Project_Award_W_O_Retention__c = (federalProjectAmount - project.Total_Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
            project.State_Project_Award_W_O_Retention__c = (stateProjectAmount - project.Total_State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

            if (project?.Amendment_Requests__r?.size() == 1) {
                project.Latest_Project_Version__c = project?.Amendment_Requests__r[0].FDSR__c == null ? null : project?.Amendment_Requests__r[0].FDSR__c;
                project.Latest_Supplement_Number__c = project?.Amendment_Requests__r[0].SupplementNumber__c == null ? null : project?.Amendment_Requests__r[0].SupplementNumber__c;
            }
            else {
                project.Latest_Project_Version__c = project.Project_Number__c == null ? null : project.Project_Number__c;
                project.Latest_Supplement_Number__c = project.Supplement_Number__c == null ? null : project.Supplement_Number__c;
            }
        }
        update projectRecordList;
    }

    public void finish(Database.BatchableContext bc) {
    }
}