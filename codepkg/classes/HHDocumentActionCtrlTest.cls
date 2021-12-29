@isTest
public class HHDocumentActionCtrlTest {
 	@isTest
    public static void test1() {
        	User u = HH_TestHelper.createPortalUser();
        
        	System.runAs(new User(Id=UserInfo.getUserId())) {
            Program__c program = new Program__c();
            program.Name = 'HH Application';
            program.Master_Label_Program_Name__c = 'HH Application';
            insert program;
            
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name = 'HH_Community_Homeowner_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
            Group g1 = new Group(Name='HH_Community_San_Diego_County_Group',Type='Regular');
            insert g1;
            Group g2 = new Group(Name='HH_San_Diego_County_Community_Reviewer',Email='test@gmail.com', type='Queue');
            insert g2;
            QueuesObject q1 = new QueueSObject(QueueID = g2.id, SobjectType = 'HH_Application__c');
            insert q1;
            }
        System.debug('Homeowner: '+u);
        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_New;
        insert application;
        Document__c document = new Document__c();
        document.Document_Name__c = 'Test Doc';
        document.Status__c = 'Active';
        document.HH_Application__c = application.Id;
        document.Document_Creation_Method__c = HH_CONSTANTS.Document_CreationMethod_SystemGenerated;
        insert document;
        
        Document__c document1 = new Document__c();
        document1.Document_Name__c = 'Test Doc1';
        document1.Status__c = 'Active';
        document1.Is_Required__c = 'Required';
        document1.HH_Application__c = application.Id;
        insert document1;
        
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
        cdl1.LinkedEntityId = document.Id;
        cdl1.ContentDocumentId = conDocId;
        cdl1.shareType = 'V';
        Insert cdl1;

        document.Stage__c = 'Uploaded';
        Update document;

        HH_Application__c application1 = new HH_Application__c();
        application1.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application1.Status__c = HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit;
        insert application1;
        Document__c document2 = new Document__c();
        document2.Document_Name__c = 'Test Doc';
        document2.Status__c = 'Active';
        document2.HH_Application__c = application1.Id;
        document2.Document_Creation_Method__c = HH_CONSTANTS.Document_CreationMethod_SystemGenerated;
        insert document2;

        Document__c document11 = new Document__c();
        document11.Document_Name__c = 'Test Doc1';
        document11.Status__c = 'Active';
        document11.Is_Required__c = 'Required';
        document11.HH_Application__c = application1.Id;
        insert document11;

        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;

        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;

        //Create ContentDocumentLink for Project
        ContentDocumentLink cdl11 = New ContentDocumentLink();
        cdl11.LinkedEntityId = document2.Id;
        cdl11.ContentDocumentId = conDocId1;
        cdl11.shareType = 'V';
        Insert cdl11;

        document2.Stage__c = 'Uploaded';
        Update document2;
        
        HH_DocumentActionCtrl obj = new HH_DocumentActionCtrl();
        List<DocumentUploadCtrl.DocumentMetaInfoWrapper> docWrapperList = new List<DocumentUploadCtrl.DocumentMetaInfoWrapper>();
      	DocumentUploadCtrl.DocumentMetaInfoWrapper testObj = new DocumentUploadCtrl.DocumentMetaInfoWrapper();
        testObj.documentRecord = document2;
        testObj.ContentDocumentLink = cdl1;
        //testObj.ContentVersion = cv;
        docWrapperList.add(testObj);

        String testx;
        	Test.startTest();
        System.debug('Is Active User: '+u.IsActive);
        System.runAs(u) {
       	 	docWrapperList = obj.handleHHApplicationActions(application.Id,docWrapperList);
        }
        	docWrapperList = obj.executeAction(application.Id,docWrapperList);
        	HH_DocumentActionCtrl executeDelete = new HH_DocumentActionCtrl();
            try{
                executeDelete.executeDeleteAction(document.Id,conDocId);
        		executeDelete.executeDeleteAction(document1.Id,conDocId);
                executeDelete.executeDeleteAction(document2.Id,conDocId);
                executeDelete.executeDeleteAction(document11.Id,conDocId);
            }catch(exception e){
                System.assertEquals(System.label.HH_Document_Edit_Delete, e.getMessage());
            }
        try{
            executeDelete.executeEditAction(document.Id);
            executeDelete.executeEditAction(document.Id);
            executeDelete.executeEditAction(document2.Id);
            executeDelete.executeEditAction(document11.Id);
        }Catch(exception e){
            System.assertEquals('Application not editable', e.getMessage());
        }
        	Test.stopTest();
        }
}