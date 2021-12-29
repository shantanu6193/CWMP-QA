trigger AmendmentRequestTrigger on Amendment_Request__c (before insert, after insert, before update, after update, before delete ) {
    new AmendmentRequestTriggerHelper().process();
}