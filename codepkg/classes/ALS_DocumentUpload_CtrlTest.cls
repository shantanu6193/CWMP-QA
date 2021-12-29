@isTest(seeAllData=false)
public class ALS_DocumentUpload_CtrlTest {

   @isTest public static void testSaveFileDetails1() {
       Date startDate = system.today()+1;
       Date EndDate = system.today()+10;
       Map<String, Object> returnMap = new Map<String, Object>();
       Map<String, Object> returnMap1 = new Map<String, Object>();
       Profile pf= [Select Id from profile where Name='System Administrator'];
       String orgId=UserInfo.getOrganizationId();
       String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
       Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
       String uniqueName=orgId+dateString+RandomId;
       User uu=new User(firstname = 'ABC',
               lastName = 'XYZ',
               email = uniqueName + '@test' + orgId + '.org',
               Username = uniqueName + '@test' + orgId + '.org',
               EmailEncodingKey = 'ISO-8859-1',
               Alias = uniqueName.substring(18, 23),
               TimeZoneSidKey = 'America/Los_Angeles',
               LocaleSidKey = 'en_US',
               LanguageLocaleKey = 'en_US',
               ProfileId = pf.Id
       );
       insert uu;
       Program__c prP = new Program__c(Name='Test Program Parent');
       insert prP;
       Program__c pr3 = new Program__c(Name='Test Program update', Parent_Program__c=prP.Id);
       insert pr3;
       Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
       insert inc;
       Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=pr3.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
       insert fp2;

       Account account=new Account(Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate,DUNS__c = '1234' );
        insert account;
       Project__c newProj =new Project__c(Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fp2.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Obligating_Sub_Recipient__c=account.Id,Start_Date__c=startDate,End_Date__c=EndDate);
        insert newProj;

        //for Project
        Document__c newDoc1 = new Document__c();
        newDoc1.Document_Type__c = ALS_CONSTANTS.Document_DocumentType_Compliance;
        newDoc1.Document_Name__c = 'testName';
        newDoc1.ProjectId__c =  newProj.Id;
        insert newDoc1;

        Program_Document__c newProDocument = new Program_Document__c();
        newProDocument.Document_Name__c = 'testName';//newDoc1.Document_Name__c;
        insert newProDocument;

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
        cdl1.LinkedEntityId = newDoc1.Id;
        cdl1.ContentDocumentId = conDocId;
        cdl1.shareType = 'V';
        Insert cdl1;

        String documentRecordId = newDoc1.Id;
        String recordId = newProj.Id;

        //Create Document
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;

        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;

        //Create ContentDocumentLink
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = newDoc1.Id;
        cd1.ContentDocumentId = conDocId1;
        cd1.shareType = 'V';
        Insert cd1;

       String documentRecordId1 = newDoc1.Id;
       String recordId1 = account.Id;
        test.startTest();
            returnMap = ALS_DocumentUpload_Ctrl.saveFileDetails(documentRecordId, '', recordId);
            System.assert(returnMap.size()>0);
            returnMap1 = ALS_DocumentUpload_Ctrl.saveFileDetails(documentRecordId, '', recordId);
            System.assert(returnMap1.size()>0);
            try {
               returnMap1 = ALS_DocumentUpload_Ctrl.saveFileDetails(documentRecordId1, '', recordId1);
            }
            catch(Exception e) {
               System.assert(e.getMessage().contains('List has no rows for assignment to SObject'));
            }
        test.stopTest();
   }

}