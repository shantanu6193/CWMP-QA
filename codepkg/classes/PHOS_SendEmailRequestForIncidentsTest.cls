@isTest(seeAllData=false)
public class PHOS_SendEmailRequestForIncidentsTest {
    @IsTest
    static void testSendEmail(){
        test.StartTest();
        Incident__c newIncident = new Incident__c(Name='COVID-19',Eamil_To_Send__c = 'test@gmail.com',isActive__c =true,
                                                 	Personnel_Email_IDs__c = 'test56@gmail.com');
        insert newIncident;
        List<Id> newOrderList = new List<Id>();
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        newOrder.Incident__c = newIncident.Id;
        newOrder.Personnel__c = true;
        insert newOrder;
        newOrderList.add(newOrder.Id);
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'test134@gmail.com';
        newEmail.ToAddress = 'test123@gmail.com';
        newEmail.FromName = 'test';
        newEmail.CcAddress = 'test12@gmail.com';
        newEmail.RelatedToId = newOrder.Id;
        newEmail.Subject = 'New request submitted by';
        insert newEmail;
        
        PHOS_SendEmail_Request_For_Incidents.sendEmail(newOrderList);
        test.StopTest();
    }
    @IsTest public static void testFormatPlainBody(){
        Test.startTest();
        PHOS_SendEmail_Request_For_Incidents.formatPlainBody('this is first, email.');                                                            
        Test.stopTest();
    }
}