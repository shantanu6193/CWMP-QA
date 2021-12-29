/**
 *  Created by Ricky on 19-07-2021.
 */

trigger IncidentTrigger on Incident__c (after update) { 
    new IncidentTriggerHelper().process();
}