@isTest public with sharing class PHOS_SendEmailRequestFromCountyUserTest {
    @isTest public static void testSendEmail(){
        List<Id> orderIds = new List<Id>();
        List<Id> orderIds1 = new List<Id>();
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        orderIds.add(newOrder.Id);
        test.startTest();
        //PHOS_SendEmail_Request_From_County_User.sendEmail(orderIds);
        test.stopTest();
   } 
}