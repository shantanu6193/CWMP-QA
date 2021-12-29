trigger CurrentPrioritiesTrigger on Current_Priorities__c (after insert, after update) {
    new CurrentPrioritiesTriggerHelper().process();

}