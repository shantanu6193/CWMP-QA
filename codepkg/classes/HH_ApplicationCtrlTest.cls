@IsTest(SeeAllData=true)
public without sharing class HH_ApplicationCtrlTest {
    
    
    @IsTest
    public static void test1() {
         User u = HH_TestHelper.createPortalUser();
         System.runAs(new User(Id=UserInfo.getUserId())) {
             PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name = 'HH_Community_Homeowner_User' LIMIT 1];
             insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
         }
         String applicationId = null;
         System.runAs(u) {
             Test.startTest();
             HH_ApplicationCtrl.getApplicationRecord(null);
             Contact c = [SELECT Id,FirstName,LastName FROM Contact WHERE Id=:u.ContactId];
             c.Is_Mailing_Address_Different__c = 'No';
             c.LastName = 'Becker';
             c.Is_Physical_Address_a_Foreign_Address__c = 'No';
             c.Preferred_Language__c = 'English';
             c.Physical_City__c = 'Napa';
             c.Physical_State__c = 'California';
             c.Physical_Country__c = 'UNITED STATES OF AMERICA';
             c.Physical_Street__c = 'Roosevelt Road';
             c.Physical_Zip_Postal_Code__c = '5234462';
             c.Phone = '1234567890';
             c.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Homeowner;
             update c;
             HH_Application__c application = new HH_Application__c();
             application.Applicant__c = c.Id;
             application.Applicant__r = c;
             application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
             application.Assessor_Email__c = 'ashjkhasf@gmail.com';
             application.Tax_Parcel_Number__c = '234234';
             application.Is_the_property_in_the_floodplain__c = 'No';
             application.City__c = 'Napa';
             application.State__c = 'CA';
             application.Zip_Postal_Code__c = '241532';
             application.County__c = 'San Diego';
             application.Property_Street_Address__c = 'Test121';
             application.Property_Structure__c = 'Single Family Residence Single Story';
             application.Property_Foreclosed_or_in__c = 'No';
             application.Property_Liens__c = 'Yes';
             application.Year_of_Construction__c = '1940';
             application.Authority_to_make_updates_to_the_Home__c = 'Yes';
             application.Total_Living_Area__c = 34322;
             application.Number_of_Stories__c = 3;
             application.Is_National_Register_of_Historic_Places__c = 'Yes';
             application.Accessible_by_a_Passenger_Vehicle__c = 'Yes';
             application.Is_Anyone_65__c = 'Yes';
             application.Is_Anyone_Age_5_and_Under__c = 'Yes';
             application.Anyone_Not_a_Proficient_English_Speaker__c = 'Yes';
             application.Is_Anyone_has_Disabilities__c = 'No';
             application.Property_Owner__c = 'Yes';
             application.Primary_Residence__c = 'Yes';
             application.Rental_Property__c = 'No';
             application.Currently_Occupied__c = 'No';
             application.Car_Ownership__c = 'Yes';
             application.Any_Other_Names_on_the_Property_Deed__c = 'No';
             String newApplicationJson = JSON.serialize(application);
             Map<String,Object> resultMap = HH_ApplicationCtrl.saveApplication(newApplicationJson,'', false,'ApplicantInfo');
             HH_Application__c a = (HH_Application__c)resultMap.get('application');
             applicationId = a.Id;
             System.debug('a: '+ a.Id);
             insertApplicationContact(a.Id,u.ContactId);
             insertFundedPrograms(a.Id);
         }
          
             HH_Application__c app = [SELECT Id, NAme, Applicant__c,Applicant__r.Email, Stage__c,Status__c,HH_Community_URL__c,Agreement_Disclosure__c, Applicant__r.Id, Applicant__r.FirstName, Applicant__r.LastName
                                    FROM HH_Application__c WHERE Id =: applicationId];
             app.Agreement_Disclosure__c = true;
             //application.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
             app.County__c = HH_CONSTANTS.HHApplication_County_SanDiego;
             String updateAppJson = JSON.serialize(app);
             System.debug('ApplicationId: '+app.Id);
             HH_ApplicationCtrl.saveApplication(updateAppJson,'', false,'ApplicantInfo');
             Map<String,Object> getRecordMap  = HH_ApplicationCtrl.getApplicationRecord(app.Id);
             HH_Application__c submitApp =(HH_Application__c) getRecordMap.get('application');
             System.debug('Application before submit: '+submitApp);
             insertDocuments(applicationId);
             HH_ApplicationCtrl.saveApplication(JSON.serialize(submitApp),'', true,'ApplicantInfo');
             HH_ApplicationValidationCtrl.validateApplication(submitApp.Id);
             Document__c doc = new Document__c(Document_Type__c='Proof of Rental',Document_Name__c ='Test');
             insert doc;
             HH_ApplicationCtrl.deleteDocument(doc.Id,'');
             Test.stopTest();
        
    }
    
    @IsTest
    public static void test2() {
         	User u = HH_TestHelper.createPortalUser();
         	System.runAs(new User(Id=UserInfo.getUserId())) {
             PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name = 'HH_Community_County_User' LIMIT 1];
             insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
         }
             String applicationId = null;
         System.runAs(u) {
             Test.startTest();
        //     HH_ApplicationCtrl.getApplicationRecord(null);
             Contact c = [SELECT Id,FirstName,LastName,AccountId FROM Contact WHERE Id=:u.ContactId];
             HH_Application__c application = new HH_Application__c();
             application.Applicant__c = c.Id;
             application.Applicant__r = c;
             application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
         	application.Assessor_Email__c = 'ashjkha@gmail.com';
         	application.Tax_Parcel_Number__c = '234234';
         	application.Is_the_property_in_the_floodplain__c = 'No';
             String newApplicationJson = JSON.serialize(application);
                 Map<String,Object> resultMap = HH_ApplicationCtrl.saveApplication(newApplicationJson,'', false,'ApplicantInfo');
             HH_Application__c a = (HH_Application__c)resultMap.get('application');
             System.debug('a: '+ a.Id);
                 applicationId = a.Id;
             Application_Contact__c ac = insertApplicationContact(a.Id,u.ContactId);
             Funded_Program__c fp = insertFundedPrograms(a.Id);
             }
             HH_Application__c app1 = [SELECT Id,Name,Applicant__r.AccountId,(SELECT Id,Annual_Income__c,Contact__r.FirstName,Contact__r.LastName FROM Application_Contacts__r),(SELECT Id,HH_Application__c FROM Funded_Programs__r) FROM HH_Application__c WHERE Id =: applicationId];
             String newApplicationJson1 = JSON.serialize(app1);
             insertDocuments(applicationId);
             HH_ApplicationCtrl.saveApplication(newApplicationJson1,'', false,'ApplicantInfo');
            
             HH_Application__c app = [SELECT Id,Name,Applicant__r.Email, Stage__c,Status__c,HH_Community_URL__c,Agreement_Disclosure__c, Applicant__r.Id, Applicant__r.FirstName, Applicant__r.LastName
                                      FROM HH_Application__c WHERE Id =: applicationId];
             app.Agreement_Disclosure__c = true;
            
             app.County__c = HH_CONSTANTS.HHApplication_County_SanDiego;
             String updateAppJson = JSON.serialize(app);
             System.debug('ApplicationId: '+app.Id);
             HH_ApplicationCtrl.saveApplication(updateAppJson,'', false,'ApplicantInfo');
             Map<String,Object> getRecordMap  = HH_ApplicationCtrl.getApplicationRecord(app.Id);
             HH_Application__c submitApp =(HH_Application__c) getRecordMap.get('application');
             System.debug('Application before submit: '+submitApp);
             HH_ApplicationCtrl.saveApplication(JSON.serialize(submitApp),'', true,'ApplicantInfo');
             HH_ApplicationCtrl.createDocumentRecord('Proof of Rental',app.Id);
             Document__c doc = new Document__c(Document_Type__c='Proof of Rental',Document_Name__c ='Test');
             insert doc;
        //     HH_ApplicationCtrl.getApplicationRecord(app.Id);
             Test.stopTest();
       
    }
    
     @IsTest
    public static void test3() {
         	User u = HH_TestHelper.createPortalUser();
         	System.runAs(new User(Id=UserInfo.getUserId())) {
             PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name = 'HH_Community_County_User' LIMIT 1];
             insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
         }
         //System.runAs(u) {
             Test.startTest();
            
             /*Account acc = new account();
             acc.Account_Name__c = 'QvMp30';
             acc.Name = 'HOUSEHOLD-QvMp30';
             insert acc;*/
            
             Contact c = new Contact();
             c.FirstName = 'FirstName';
             c.LastName = 'LastName';
             //c.AccountId = u.AccountId;
             
            
          
          
             HH_Application__c application = new HH_Application__c();
             application.Applicant__c = c.Id;
             application.Applicant__r = c;
             application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
         	application.Assessor_Email__c = 'ashjkh@gmail.com';
         	application.Tax_Parcel_Number__c = '234234';
         	application.Is_the_property_in_the_floodplain__c = 'No';
           
             String newApplicationJson = JSON.serialize(application);
             Map<String,Object> resultMap = HH_ApplicationCtrl.saveApplication(newApplicationJson,'000000', false,'ApplicantInfo');
             Map<String,Object> resultMap1 = HH_ApplicationCtrl.saveApplication(newApplicationJson,'', false,'ApplicantInfo');
             Test.stopTest();
    }

    @IsTest
    public static void test4() {
             Document__c doc1 = new Document__c();
             doc1.Document_Type__c = 'Proof of Rental';
             doc1.Document_Name__c = 'Test Doc';
             doc1.Status__c = 'Active';
             insert doc1;
            
             List<Id> idList = new List<Id>();
             ContentVersion cv = new ContentVersion();
        	 cv.Title = 'Test Document';
       	 	 cv.PathOnClient = 'TestDocument.pdf';
        	 cv.VersionData = Blob.valueOf('Test Content');
        	 cv.IsMajorVersion = true;
        	 Insert cv;
        
        
             ContentVersion cv1 = new ContentVersion();
        	 cv1.Title = 'Test Document';
       	 	 cv1.PathOnClient = 'TestDocument.pdf';
        	 cv1.VersionData = Blob.valueOf('Test Content');
        	 cv1.IsMajorVersion = true;
        	 Insert cv1;
             idList.add(cv.Id);
        	 idList.add(cv1.Id);

        	 //Get Content Documents
        	  List<ContentVersion> conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:idList];
             //Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
			

        	 //Create ContentDocumentLink for Project
        	 ContentDocumentLink cdl1 = New ContentDocumentLink();
        	 cdl1.LinkedEntityId = doc1.Id;
        	 cdl1.ContentDocumentId = conDocId[0].ContentDocumentId;
        	 cdl1.shareType = 'V';
        	 Insert cdl1;
        
             ContentDocumentLink cdl2 = New ContentDocumentLink();
        	 cdl2.LinkedEntityId = doc1.Id;
        	 cdl2.ContentDocumentId = conDocId[1].ContentDocumentId;
        	 cdl2.shareType = 'V';
        	 Insert cdl2;
        	 Test.startTest();
             HH_ApplicationCtrl.updateDocumentRecord(doc1.Id,doc1.Document_Name__c);
           	 Test.stopTest();
    }
    
   
    private static Application_Contact__c insertApplicationContact(Id applicationId,Id contactId) {
        Contact c1 = HH_TestHelper.getContact(false);
        c1.FirstName = 'Jerry';
        c1.LastName = 'Jason';
        insert c1;
        Application_Contact__c ac = new Application_Contact__c();
        ac.Head_of_Household__c = 'Yes';
        ac.Annual_Income__c = 100;
        ac.Relationship_to_Homeowner__c = 'Self';
        ac.HH_Application__c = applicationId;
        ac.Contact__c = contactId;
        insert ac; 
        Application_Contact__c ac1 = new Application_Contact__c();
        ac1.Head_of_Household__c = 'No';
        ac1.Annual_Income__c = 1400;
        ac1.Relationship_to_Homeowner__c = 'Spouse';
        ac1.HH_Application__c = applicationId;
        ac1.Contact__c = c1.Id;
        insert ac1; 
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

    private static void insertDocuments(String applicationId) {
        List<Document__c> docList = [SELECT Id,Stage__c,Is_Required__c,Status__c,Date_Uploaded__c FROM Document__c WHERE HH_Application__c =: applicationId];
            System.debug('Total Documents: '+docList);
            for(Document__c doc : docList) {
                    ContentVersion contentVersion = new ContentVersion(
                                                    Title          = 'a picture',
                                                    PathOnClient   = 'Pic.jpg',
                                                    VersionData    = Blob.valueOf('Test Content'),
                                                    IsMajorVersion = true);
                    insert contentVersion;
                    ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVersion.Id];
                    ContentDocumentLink contentlink=new ContentDocumentLink();
                    contentlink.ShareType= 'I';
                    contentlink.LinkedEntityId = doc.Id; 
                    contentlink.ContentDocumentId=testcontent.ContentDocumentId;
                    contentlink.Visibility = 'AllUsers'; 
                    insert contentlink;              
            }
            for(Document__c doc : docList) {
                    doc.Stage__c = HH_CONSTANTS.Document_Stage_Uploaded;
                    doc.Status__c = HH_CONSTANTS.Document_Status_Active;
            }
            update docList;
    }
}