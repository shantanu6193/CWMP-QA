@isTest
public with sharing class PHOS_SendEmailToJEOCUserFromCAHCUserTest {
    @isTest
    static void testSendEmail(){
        test.StartTest();
        List<Id> newOrderList = new List<Id>();
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        newOrder.Status__c='Staffing in Progress';
        upsert newOrder;
        newOrderList.add(newOrder.Id);
        PHOS_SendEmail_To_JEOCUser_From_CAHCUser.sendEmail(newOrderList);
        test.StopTest();
    }
}