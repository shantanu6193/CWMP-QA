trigger ProjectRoleTrigger on Project_Role__c (before insert ,before update, after insert , after update ) {
    new ProjectRoleTriggerHelper().process();
}