trigger PaymentTrigger on Payment__c (before insert, before update, after insert, after update, before delete, after undelete) {
    new PaymentTriggerHelper().process();
}