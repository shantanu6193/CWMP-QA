trigger TransmittalTrigger on Transmittal__c (after update , after insert, before Update, before insert) {
    new TransmittalTriggerHelper().process();
}