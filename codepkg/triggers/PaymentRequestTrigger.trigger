trigger PaymentRequestTrigger on Payment_Request__c (before insert, before update, after update , after insert, before delete , after undelete, after delete ) {
        new PaymentRequestTriggerHelper().process();
}