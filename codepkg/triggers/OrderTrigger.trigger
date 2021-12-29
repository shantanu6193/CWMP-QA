trigger OrderTrigger on Order__c (before insert, before update, after insert,after update, before delete) {
    new OrderTriggerHelper().process();
}