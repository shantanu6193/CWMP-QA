/**
 * Created by Neha on 23-04-2020.
 */

@IsTest(SeeAllData =false)
public with sharing class DIP_Mark_Lead_Unresponsive_Batch_Test {
    @IsTest(SeeAllData = false)
    static void testBehavior() {

        Test.startTest();
        Lead newLead = new Lead();
        newLead.Queue_Owner__c = 'COVID - Contributions Group - Donations';
        newLead.Company = 'MITT';
        newLead.LastName = 'test';
        newLead.In_Queue_Since__c = datetime.newInstance(2020, 11, 15, 12, 30, 0);
        newLead.Requests_Follow_up_with_State_Contact__c = true;
        insert newLead;
        newLead.LastName = 'test123';
        update newLead;
        Task newTask = new Task();
        newTask.WhoId = newLead.Id;
        insert newTask; 
        // Event newEvent = new Event();
        // newEvent.WhoId = newLead.Id;
        // newEvent.DurationInMinutes = 10;
        // insert newEvent;
        DIP_Mark_Lead_Unresponsive_Batch b = new DIP_Mark_Lead_Unresponsive_Batch();
        Database.executeBatch(b);
        Test.stopTest();

    }
}