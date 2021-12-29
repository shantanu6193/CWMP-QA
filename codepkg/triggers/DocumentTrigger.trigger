trigger DocumentTrigger on Document__c (after insert, before update) {
    new DocumentTriggerHelper().process();
}