/***********************************************************************************************************************************
* Class Name   : IncidentTriggerHelper
* Description  : IncidentTriggerHelper Class
* Author       : Ricky
* Created On   : 19/07/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              19/07/2021       Initial Implementation
**************************************************************************************************************************************/

public with sharing class IncidentTriggerHelper extends TriggerHelper {

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Ricky
    * Inputs : -
    * Description: This method call after records are updating
    *********************************************/
    public override void processAfterUpdate() {
        updateIncidentSubSummaryNameUponFIPSChange();
    }

    /***********************************************
     * Method Name : updateIncidentSubSummaryNameUponFIPSChange
     * Author : Ricky
     * Inputs :
     * Description: This method updates the related Incident Sub Recipient Summary record Name upon Declaration Number update of Incident record.
     *              Incident Sub Recipient Summary Name - "Declaration Number(Incident) - FIPS(Sub Recipient/Account)"
     ************************************************/
    private void updateIncidentSubSummaryNameUponFIPSChange() { 
        List<Id> incidentIds = new List<Id>(); // Collection to collect the Incident Ids whose Declaration Number has been changed.
        // Iterating Trigger.new collection to check if the Declaration Number of the record is changed.
        for (Incident__c incidentToProcess : (List<Incident__c>) Trigger.new) {
            Incident__c oldRecord = (Incident__c) Trigger.oldMap.get(incidentToProcess.Id);
            if (oldRecord.Declaration_Number__c != incidentToProcess.Declaration_Number__c) {
                incidentIds.add(incidentToProcess.Id);
            }
        }
        // Calling the Utility class to update the related Incident Sub Recipient records names.
        if (incidentIds?.size() > 0) {
            REAL_IncSubSummaryUtility summaryUtility = new REAL_IncSubSummaryUtility();
            summaryUtility.updateSummaryName(incidentIds, null);
        }
    }
}