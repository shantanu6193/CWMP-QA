@isTest public with sharing class HMA_Email_For_NewRequestTest {
    @isTest public static void testSendEmail() {
        User internalUser = HMA_TestHelper.getInternalUser(true, 'HMA_Manager');
        System.runAs(internalUser) {
            List<Id> preAppApprovedIds = new List<Id>();
            //Community_Application__c commApp = HMA_TestHelper.getCommunityApplication(true);
            Incident__c incident = HMA_TestHelper.getIncident(true);
            Contact contact = HMA_TestHelper.getContact(true);
            EmailTemplate hmaNOINewRequestEmailET = HMA_TestHelper.getEmailTemplate(true, 'HMA_NOI_New_Request_Email');
            EmailTemplate bricNOINewRequestEmailET = HMA_TestHelper.getEmailTemplate(true, 'BRIC_NOI_New_Request_Email');
            EmailTemplate fmaNOINewRequestEmaillET = HMA_TestHelper.getEmailTemplate(true, 'FMA_NOI_New_Request_Email');
            Pre_Application__c preApplicationApp = HMA_TestHelper.getPreApplication(false);
            preApplicationApp.Disaster__c = incident.Id;
            preApplicationApp.Requestor__c = contact.Id;
            preApplicationApp.Sub_Application_Due_Date__c = Date.TODAY()+2;
            insert preApplicationApp;
            preAppApprovedIds.add(preApplicationApp.Id);
            Contact_Role__c newContactRole = HMA_TestHelper.getContactRole(false);
            newContactRole.Contact__c = contact.Id;
            newContactRole.Pre_Application__c = preApplicationApp.Id;
            insert newContactRole;
            Test.startTest();
            HMA_Email_For_NewRequest.sendEmail(preAppApprovedIds);

            /**This call is used to cover BRIC Code lines */
            if(String.isNotBlank(Schema.SObjectType.Pre_Application__c.getRecordTypeInfosByDeveloperName().get('BRIC').getRecordTypeId())) {
                preApplicationApp.RecordTypeId = Schema.SObjectType.Pre_Application__c.getRecordTypeInfosByDeveloperName().get('BRIC').getRecordTypeId();
            }
            update preApplicationApp;
            HMA_Email_For_NewRequest.sendEmail(preAppApprovedIds);

            /**This call is used to cover FMA Code lines */
            if(String.isNotBlank(Schema.SObjectType.Pre_Application__c.getRecordTypeInfosByDeveloperName().get('FMA').getRecordTypeId())) {
                preApplicationApp.RecordTypeId = Schema.SObjectType.Pre_Application__c.getRecordTypeInfosByDeveloperName().get('FMA').getRecordTypeId();
            }
            update preApplicationApp;
            HMA_Email_For_NewRequest.sendEmail(preAppApprovedIds);
            Test.stopTest();
        }
    }
}