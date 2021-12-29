@isTest 
public with sharing class HMA_ApplicationTriggerHandlerTest {
    @isTest 
    public static void testTriggerMethod() {
        test.startTest();
        Application__c applicationProjectYes = HMA_TestHelper.getApplication(true, '', '', 'Yes');
        test.stopTest();
    }
    @isTest 
    public static void testTriggerMethod1() {
        test.startTest();
        //Program_Document__c proDoc = HMA_TestHelper.getProgramDocument(true, 'Work Schedule', 'Work Schedule');
        Application__c applicationAANo = HMA_TestHelper.getApplication(true, 'Advance Assistance', 'Acquisition Demo-Relocation', 'No');
        applicationAANo.Project_Type__c = 'Elevation-Floodproofing';
        update applicationAANo;
        test.stopTest();
    }
    @isTest 
    public static void testTriggerMethod2() {
        test.startTest();
        Application__c applicationplanning = HMA_TestHelper.getApplication(true, 'Planning', 'New Plan', 'Yes');
        test.stopTest();
    }

    //This method tests the application update scenario for FEMA Review status for application.
    /*@isTest
    public static void testUpdateApplicationScenario() {
        User user = HMA_TestHelper.getUser(false);
        //HMA_TestHelper.assignPermissionSet(user, 'HMA_Analyst_User');
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        Contact contact = HMA_TestHelper.getPortalContact(true);
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Test.startTest();
        Account acc = HMA_TestHelper.getAccount(false);
        acc.Name = 'FEMA Account';
        insert acc;
        Contact_Role__c contactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, app, contact.Id, 'FEMA EHP Analyst');
        app.Status__c = 'FEMA Review';
        app.Status_Reason__c = 'Submitted to FEMA';
        update app;
        System.assert(app.Status__c == 'FEMA Review');
        Test.stopTest();
    }*/
}