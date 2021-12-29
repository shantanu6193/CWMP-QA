@isTest
public class HH_ApplicationPreviewCtrlTest {
	@isTest
    public static void testApplicationPreviewDetails() {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        //application.Applicant__c = c.Id;
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_New;
        insert application;
        Application_Contact__c ac = insertApplicationContact(application.Id);
        Funded_Program__c fp = insertFundedPrograms(application.Id);
        Document__c doc = new Document__c(Document_Type__c='Proof of Rental',Document_Name__c ='Test',HH_Application__c = application.Id);
        insert doc;
              //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;

        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        //Create ContentDocumentLink for Project
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = doc.Id;
        cdl1.ContentDocumentId = conDocId;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        Test.startTest();
		result= HH_ApplicationPreviewCtrl.getApplicationPreviewDetails(application.Id);
        System.assert(result != null);
        Test.stopTest();
    }
    private static Application_Contact__c insertApplicationContact(Id applicationId) {
        Contact c1 = new Contact(FirstName = 'Jerry',LastName = 'Jason',Email = 'sahfajsfnkaskf@gmail.com');
        insert c1;
        Application_Contact__c ac = new Application_Contact__c();
        ac.Head_of_Household__c = 'Yes';
        ac.Annual_Income__c = 100;
        ac.Relationship_to_Homeowner__c = 'Self';
        ac.HH_Application__c = applicationId;
        ac.Contact__c = c1.Id;
        insert ac; 
        return ac;   
    }

    private static Funded_Program__c insertFundedPrograms(Id applicationId) {
        Funded_Program__c fp = new Funded_Program__c();
        fp.Program_Name__c = 'Other';
        fp.Date_Funding_Received__c = Date.today();
        fp.Other_Program_Name__c = 'Other Program';
        fp.HH_Application__c = applicationId;
        insert fp;
        return fp;   
    }
}