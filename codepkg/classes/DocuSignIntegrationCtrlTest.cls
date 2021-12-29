@isTest
public with sharing class DocuSignIntegrationCtrlTest {
    @isTest
    public static void testEnvelope() {
        try {
            Key_Value_Store__mdt templateIdKeyValue = HMA_TestMetadataHelper.getKeyValue('Docusign_Maintenance_Commitment_TempId');
            String templateIdMaintenanceCommitment = templateIdKeyValue.Text_Value__c;
            Map<String, Object> returnMap = new Map<String, Object>();
            Contact portalCon = HMA_TestHelper.getPortalContact(true);
            Incident__c incident = HMA_TestHelper.getIncident(true);
            Program__c newProgram = HMA_TestHelper.getProgram(true);
            Application__c newApplication = HMA_TestHelper.getApplication(false, '', '', '');
            newApplication.Disaster__c = incident.Id;
            newApplication.Subapplicant_Entity__c = portalCon.AccountId;
            insert newApplication;
            Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(true, newApplication.Id);
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = portalCon.AccountId);
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'Maintenance Commitment';
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            conRole.Pre_Application__c  = newApplication.Pre_Application__c;
            insert conRole;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DocusignMockCallout());
            DocuSignIntegrationCtrl docusign = new DocuSignIntegrationCtrl(templateIdMaintenanceCommitment, portalCon.Id, new List<Id>{Id.valueOf(newApplication.Id)});
            docusign.docuSignEnvelopeGenerator();
            Test.stopTest();
        } catch(Exception e) {
            System.debug('Exception in---'+e);
        }
    }
}