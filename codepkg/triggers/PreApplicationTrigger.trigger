trigger PreApplicationTrigger on Pre_Application__c (before insert, before update, after insert, after update) {
    new PreApplicationHelper().process();
}