trigger ContactRoleTrigger on AccountContactRole__c (before insert) {
    new ContactRoleTriggerHelper().process();
}