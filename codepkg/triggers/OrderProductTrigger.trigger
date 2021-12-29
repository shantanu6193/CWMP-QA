trigger OrderProductTrigger on Order_Product__c(before insert, before update, after insert, after update, after delete, after undelete) {

    new OrderProductTriggerHelper().process();

}