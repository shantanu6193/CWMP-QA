@isTest 
public with sharing class EmailHelperTest {
    @isTest public static void testSendEmail() {
        List<Messaging.SingleEmailMessage> returnMap = new List<Messaging.SingleEmailMessage>();
        List<Order__c> orderList = new List<Order__c>();
        List<String> toAddressesList = new List<String>();
        toAddressesList.add('test@gmail.com');
        List<String> ccAddressesList = new List<String>();
        ccAddressesList.add('test1@gmail.com');
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        orderList.add(newOrder);
        Test.startTest();
        returnMap = EmailHelper.sendEmail(orderList, toAddressesList, ccAddressesList, 'CountyUser_RejectionEmailStateAgency', 'Community_User_Profile_Name');
        System.assert(returnMap.size()>0);
        Test.stopTest();
    }
}