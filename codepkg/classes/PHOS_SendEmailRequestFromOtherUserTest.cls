@isTest(seeAllData=false)
public class PHOS_SendEmailRequestFromOtherUserTest {
    @isTest public static void testSendEmail() {
        List<Id> orderIds = new List<Id>();
        Incident__c newIncident = HMA_TestHelper.getIncident(false);
        newIncident.Name = 'COVID-19';
        newIncident.Eamil_To_Send__c = 'test@test.com';
        newIncident.Personnel_Email_IDs__c  = 'test1@test.com';
        insert newIncident;
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        EmailMessage newEmailMessage = new EmailMessage();
        newEmailMessage.Subject = 'New request submitted by RDMHS/Other User';
        newEmailMessage.ToAddress = 'test@gmail.com';
        newEmailMessage.CcAddress = 'testcc@gmail.com';
        newEmailMessage.RelatedToId = newOrder.Id;
        insert newEmailMessage;

        Order__c orderRec = [SELECT Id,(SELECT Subject, ToAddress, CcAddress, RelatedToId FROM Emails) FROM Order__c LIMIT 1];
        orderIds.add(orderRec.Id);

        Test.startTest();
        PHOS_SendEmail_Request_From_Other_User.sendEmail(orderIds);
        Test.stopTest();
    }
}