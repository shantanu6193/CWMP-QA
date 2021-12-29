/**
 * Created by Neha on 11-03-2021.
 */

trigger IncidentSubRecipinetStageTrigger on Incident_Subrecipient_Stage__c (after insert, before update , after update) {
    new IncidentSubRecipinetStageTriggerHelper().process();
}