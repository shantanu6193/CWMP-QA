/**
* Created by nehab on 06-10-2020.
*/
trigger ProjectTrigger on Project__c (before insert, after insert, before update, after update, before delete, after undelete) {
    new ProjectTriggerHelper().process();
}