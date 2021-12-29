/**
 * Created by nehab on 06-01-2021.
 */

trigger ProjectServiceJunctionTrigger on Project_Service_Location_Junction__c (before insert, before update) {
    new ProjectServiceJunctionTriggerHelper().process();
}