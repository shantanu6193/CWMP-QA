@isTest(seeAllData=false)
public with sharing class Order_ProductHelperTest {

    @isTest public static void testGetProducts() {
        test.startTest();
            Account acc = PHOS_TestHelper.getParentAccount(true);
            Contact con = PHOS_TestHelper.getPortalContact(false);
            con.AccountId = acc.Id;
            insert con;
            User u = PHOS_TestHelper.getPortalUser(false);
            u.Username = 'testUser1233221@gmail.com';
            u.Email = 'testUser1233221@gmail.com';
            u.ContactId = con.Id;
            insert u;
            System.runAs(u) {
                Product2 prod = PHOS_TestHelper.getProductGoggles(true);
                Map<String, Object> returnMap = Order_ProductHelper.getProducts();
                System.debug('t=map----'+returnMap);
                System.assertNotEquals(returnMap,null);
            }
        test.stopTest();
    }

    /*@isTest public static void testSaveOrderItems(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();        
        User getUser = PHOS_TestHelper.getUser(true);

        Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Name = 'West Sacramento';
        insert newAccount;
        Contact getContact = PHOS_TestHelper.getContact(false);
        getContact.AccountId = newAccount.Id;
        insert getContact;
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Requestor__c = getContact.id;
        newOrder.CreatedById = getUser.Id;
        newOrder.Creator_Contact__c = getContact.id;
        newOrder.Account__c = newAccount.id;
        insert newOrder;

        Order_Product__c orderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        orderItemgoggle.Order__c = newOrder.Id;
        insert orderItemgoggle;
        Order_Product__c orderItemmask = PHOS_TestHelper.getOrderItemmask(false);
        orderItemmask.Order__c = newOrder.Id;
        insert orderItemmask;
        
        orderItems.add(orderItemgoggle);
        orderItems.add(orderItemmask);

        String orderItemsStr = JSON.serialize(orderItems);
        paramMap.put('OrderItems', orderItemsStr);
        paramMap.put('orderId', String.valueOf(newOrder.Id));

        test.startTest();
        Order_ProductHelper.saveOrderItems(paramMap);
        test.stopTest();
    }*/

    /*@isTest public static void testGetFulfilmentEntity(){
        List<String> receiveList = new List<String>();
        test.startTest();
        receiveList = Order_ProductHelper.getFulfilmentEntity();
        test.stopTest();
    }*/
}