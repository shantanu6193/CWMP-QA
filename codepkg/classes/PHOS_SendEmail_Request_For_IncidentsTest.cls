@IsTest
public with sharing class PHOS_SendEmail_Request_For_IncidentsTest {
    @IsTest
    static void testSendEmail(){
        test.StartTest();
        Incident__c newIncident = new Incident__c(Name='COVID-19',Eamil_To_Send__c = 'test@gmail.com',isActive__c =true);
        insert newIncident;
        List<Id> newOrderList = new List<Id>();
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        newOrder.Incident__c = newIncident.Id;
        upsert newOrder;
        newOrderList.add(newOrder.Id);
        
       
        
        PHOS_SendEmail_Request_For_Incidents.sendEmail(newOrderList);
        test.StopTest();
    }
}