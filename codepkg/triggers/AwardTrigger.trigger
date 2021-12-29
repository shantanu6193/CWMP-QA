trigger AwardTrigger on Award__c (before insert, after update) {
    new AwardTriggerHelper().process();
}