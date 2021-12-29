/**
 * Created by Admin on 21-04-2020.
 */

@IsTest
private class DIP_Lead_Process_Queue_Update_Test {
    @IsTest
    static void testBehavior() {

        Lead testLead = new Lead();
        testLead.FirstName ='Test First Name';
        testLead.LastName = 'Test Last Name';
        testLead.Email  = 'Test@Dummy.com';
        testLead.Company = 'test Company';
        testLead.In_Queue_Since__c = null;
        testLead.OwnerId = UserInfo.getUserId();
        insert testLead;
        testLead.Company = 'new';
        User usr = PHOS_TestHelper.getUser(true);
        testLead.OwnerId = usr.Id;
        update testLead;
        Test.startTest();

        DIP_Lead_Process_Queue_Update  cb = new DIP_Lead_Process_Queue_Update();
        Database.Executebatch(cb);

        Test.stopTest();

    }
}