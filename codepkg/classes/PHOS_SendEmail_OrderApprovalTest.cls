@IsTest
public with sharing class PHOS_SendEmail_OrderApprovalTest {
    @isTest
    public static void testSendEmail(){
        Order__c order = PHOS_TestHelper.getOrder(true);
        List<Id> orderId = new List<Id>();
        orderId.add(order.Id);
        PHOS_SendEmail_OrderApproval.sendEmail(orderId);
    }
}