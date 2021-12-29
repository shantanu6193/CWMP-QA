/***********************************************************************************************************************************
* Class Name   : REAL_UpdateIncSubSummaryNameJob
* Description  : This batch job is created to update the Incident Sub Recipient Summary Name in
 *              "Declaration Number(Incident) - FIPS(Sub Recipient)" format.
* Author       : Ricky
* Created On   : 19/07/2020
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              17/07/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_UpdateIncSubSummaryNameJob implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public REAL_UpdateIncSubSummaryNameJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateIncSubSummaryNameJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Incident_Subrecipient_Stage__c> summaryList = (List<Incident_Subrecipient_Stage__c>) scope;

        for (Incident_Subrecipient_Stage__c summary : summaryList) {
            String summaryName = '';
            if (summary.Declaration_Number__c != null) {
                summaryName += summary.Declaration_Number__c;
            }
            if (summary.FIPS__c != null
                    && (summaryName != null && summaryName != '')) {
                summaryName += ('-(' + summary.FIPS__c +')');
            }
            else if(summary.FIPS__c != null
                    && (summaryName == null || summaryName == '')) {
                summaryName += summary.FIPS__c;
            }
            summary.Name = summaryName;
        }
        update summaryList;
    }

    public void finish(Database.BatchableContext bc) {
    }
}