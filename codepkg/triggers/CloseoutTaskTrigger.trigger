trigger CloseoutTaskTrigger on Closeout_Task__c (before update, after update, after insert, before insert) {
    new CloseoutTaskTriggerHelper().process();

}