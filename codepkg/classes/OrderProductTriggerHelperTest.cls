@isTest public with sharing class OrderProductTriggerHelperTest {
    @isTest public static void processAfterInsertTest(){

        Order__c getOrder = PHOS_TestHelper.getOrder(true);
        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = getOrder.Id;
        insert orderItemgoggle;
        
    }

    @isTest public static void processAfterUpdateTest(){
        Order__c getOrder = PHOS_TestHelper.getOrder(true);
        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = getOrder.Id;
        insert orderItemgoggle;
        orderItemgoggle.Description__c = 'testDescription';
        upsert orderItemgoggle;
     
    }
    @isTest public static void processAfterDeleteTest(){
        Order__c getOrder = PHOS_TestHelper.getOrder(true);
        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = getOrder.Id;
        insert orderItemgoggle;
        orderItemgoggle.Description__c = 'testDescription';
        Delete orderItemgoggle;
        Undelete orderItemgoggle;
     
    }

}