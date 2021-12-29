/***********************************************************************************************************************************
* Class Name   : REAL_UpdateProgPrefixOnAmnFdsrJob
* Description  : This batch job is created append the Program prefix to Amendment Project Version for PA Programs.
* Author       : Ricky
* Created On   : 04/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              17/07/2020       Initial Implementation
**************************************************************************************************************************************/
public with sharing class REAL_UpdateProgPrefixOnAmnFdsrJob implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public REAL_UpdateProgPrefixOnAmnFdsrJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateProgPrefixOnAmnFdsrJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        TriggerHelper.skipTrigger = true;
        List<Project__c> projectWithPrimaryAuthorizedAgentList = (List<Project__c>) scope;
        List<Amendment_Request__c> amendmentRequestToUpdateList = new List<Amendment_Request__c>();

        for (Project__c project : projectWithPrimaryAuthorizedAgentList) {
            if (project?.Amendment_Requests__r?.size() > 0) {
                for (Amendment_Request__c amendmentRequest : project?.Amendment_Requests__r) {
                    if (amendmentRequest.FDSR__c != null) {
                        if (amendmentRequest.Project__r.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_CDAA) {
                            if (!amendmentRequest.FDSR__c.startsWith('DSR')) {
                                amendmentRequest.FDSR__c = 'DSR-'+amendmentRequest.FDSR__c;
                                amendmentRequestToUpdateList.add(amendmentRequest);
                            }
                        }
                        else if (amendmentRequest.Project__r.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA_Federal
                                || amendmentRequest.Project__r.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA_FMAG) {
                            if (!amendmentRequest.FDSR__c.startsWith('PW')) {
                                amendmentRequest.FDSR__c = 'PW-'+amendmentRequest.FDSR__c;
                                amendmentRequestToUpdateList.add(amendmentRequest);
                            }
                        }
                    }
                }
            }
        }
        if (amendmentRequestToUpdateList?.size() > 0) {
            update amendmentRequestToUpdateList;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}