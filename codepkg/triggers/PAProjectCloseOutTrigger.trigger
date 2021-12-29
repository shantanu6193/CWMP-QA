trigger PAProjectCloseOutTrigger on Project_Closeout__c (after insert, after update, after delete, before insert, before update) {
    new PA_ProjectCloseOutTriggerHelper().process();
  }