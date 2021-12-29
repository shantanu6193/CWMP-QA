trigger ProjectSiteTrigger on Project_Site__c (before insert, after insert, before update, after update, after delete) {
    new HMA_ProjectSiteTriggerHandler().process();

}