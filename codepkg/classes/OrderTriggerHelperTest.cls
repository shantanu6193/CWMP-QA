@IsTest
public with sharing class OrderTriggerHelperTest {
   @isTest public static void testBehaviour(){
        Order__c order = PHOS_TestHelper.getOrder(false); 
        Contact getContact = PHOS_TestHelper.getContact(true);
        order.Creator_Contact__c = getContact.Id;
        insert order;
        System.assertEquals(order.Id, order.Id);
        order.Shipping_State__c ='AL';
        order.Status__c ='Draft';
        update order;
        delete order;
    }
    @isTest public static void testBehaviou1(){
        User usr = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()];
        System.runAs(usr) {
            Group g1 = new Group(Name='testQ', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Order__c');
            insert q1;
        }

        Test.startTest();
        Account acc = PHOS_TestHelper.getAccount(false);
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        acc.ParentId = newParentAccount.Id;
        acc.Queue_Name__c = 'testQ';
        insert acc;

        Contact getContact = PHOS_TestHelper.getContact(false);
        getContact.AccountId = acc.Id;
        insert getContact;

        Order__c order = PHOS_TestHelper.getOrder(false);
        order.Creator_Contact__c = getContact.Id;
        order.Shipping_State__c ='AL';
        order.Status__c ='MHOAC Review';
        order.Order_Source__c = 'Reddinet';
        insert order;
        Test.stopTest();
    }
}