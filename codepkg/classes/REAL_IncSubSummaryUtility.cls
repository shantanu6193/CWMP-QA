/***********************************************************************************************************************************
* Class Name   : REAL_IncSubSummaryUtility
* Description  : Incident Sub Recipient Summary Utility.
* Author       : Ricky
* Created On   : 19/07/2021
* Modification Log :
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              19/07/2021       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_IncSubSummaryUtility {
    /*********************************************
	* Method Name : updateSummaryName
	* Author : Ricky
	* Inputs : - 1.List<Transmittal__c> transmittalList -
	* Description: This method is used send the Transmittal record for Approval.
	*********************************************/
    public void  updateSummaryName(List<Id> incidentIds, List<Id> subRecipientIds) {
        String query = 'SELECT Id, Name, Account__c, FIPS__c, Incident__c, Declaration_Number__c FROM Incident_Subrecipient_Stage__c';
        if (incidentIds?.size() > 0
                && !(subRecipientIds?.size() > 0)) {
            //String incidentIdString = inClausify(incidentIds);
            //query += 'WHERE Incident__c IN : incidentIdString';
            query += ' WHERE Incident__c IN : incidentIds';
        }
        else if (subRecipientIds?.size() > 0
                && !(incidentIds?.size() > 0)) {
            //String subRecipientIdString = inClausify(subRecipientIds);
            //query += ' WHERE Account__c IN : subRecipientIdString';
            query += ' WHERE Account__c IN : subRecipientIds';
        }
        else if (incidentIds?.size() > 0
                && subRecipientIds?.size() > 0) {
            //String incidentIdString = inClausify(incidentIds);
            //String subRecipientIdString = inClausify(subRecipientIds);
            //query += ' WHERE Account__c IN : subRecipientIdString OR Incident__c IN : incidentIdString';
            query += ' WHERE Account__c IN : subRecipientIds OR Incident__c IN : incidentIds';
        }
        List<Incident_Subrecipient_Stage__c> summaryList = Database.query(query);
        if (summaryList?.size() > 0) {
            for (Incident_Subrecipient_Stage__c summary : summaryList) {
                String summaryName = '';
                if (summary.Declaration_Number__c != null) {
                    summaryName += summary.Declaration_Number__c;
                }
                if (summary.FIPS__c != null
                        && (summaryName != null && summaryName != '')) {
                    summaryName += ('-(' + summary.FIPS__c + ')');
                }
                else if(summary.FIPS__c != null
                        && (summaryName == null || summaryName == '')) {
                    summaryName += summary.FIPS__c;
                }
                summary.Name = summaryName;
            }

            update summaryList;
        }
    }

    /*********************************************
	* Method Name : inClausify
	* Author : Ricky
	* Inputs : - 1. List<Id> ids -
	* Description: This method is used send the Transmittal record for Approval.
	*********************************************/
    public static String inClausify (List<Id> recordIds) {
        String inClause = String.format( '(\'\'{0}\'\')',
                new List<String> { String.join( new List<Id>(recordIds) , '\',\'') });
        return inClause;
    }
}