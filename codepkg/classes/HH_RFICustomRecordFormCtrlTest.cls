@IsTest
private  class HH_RFICustomRecordFormCtrlTest {

    @IsTest(SeeAllData=true)
    public static void test1() {
        Id communityUserId = null;
        User homeownerUser = new User();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            User communityUser = HH_TestHelper.createCaloesPortalUser('community@xyz.com');
            communityUserId = communityUser.Id;
            homeownerUser = HH_TestHelper.createCaloesPortalUser('homeowner@xyz.com');
        } 
        User caloesUser = HH_TestHelper.createCaloesUser();  
        PermissionSet permissionSet2 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUserId, PermissionSetId = permissionSet2.Id);
        PermissionSet permissionSet3 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = homeownerUser.Id, PermissionSetId = permissionSet3.Id);
        Test.startTest();
        String applicationId = null;
        HH_Application__c application = new HH_Application__c();
        Request_For_Information__c req = new Request_For_Information__c();
        System.runAs(new User(Id=communityUserId)) {
            User u = [SELECT Id,ContactId FROM User WHERE Id=:communityUserId];
            Contact c = [SELECT Id,Email FROM Contact WHERE Id=:u.ContactId];
            c.Preferred_Language__c = 'English';
            update c;
            System.debug('Contact: '+c);
            //HH_Application__c application = new HH_Application__c();
            application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
            application.Assessor_Email__c = 'ashjkhasf@gmail.com';
            application.Tax_Parcel_Number__c = '234234';
            application.Is_the_property_in_the_floodplain__c = 'No';
            application.Applicant__c = c.Id;
            application.Applicant__r = c;
            application.County__c = HH_CONSTANTS.HHApplication_County_SanDiego;
            insert application;
            applicationId = application.Id;
        }
        System.runAs(new User(Id=UserInfo.getUserId())) {
            insertDocuments(applicationId);
        }
        System.runAs(new User(Id=communityUserId)) {
            //HH_Application__c application = new HH_Application__c(Id=applicationId);
            application.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
            application.Status__c = HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo;
            application.Assessed_Value_of_the_Property__c = 1234;
            application.Income_Bracket__c = '80% through 120%';
            application.Tax_Parcel_Number__c = '123434';
            application.Is_the_property_in_the_floodplain__c = HH_CONSTANTS.PickList_Yes;
            application.Application_Lead__c = communityUserId;
            update application;
            
            HH_RFICustomRecordFormCtrl.getInitDetails(application.Id, null, communityUserId, 'Edit');
            HH_RFICustomRecordFormCtrl.isEditable(application.Id);
            //Request_For_Information__c req = new Request_For_Information__c();
            req.RecordTypeId = ApexUtils.getRecordTypeIdbyName('Request_For_Information__c','CWMP');
            req.Status__c = 'RFI Requested';
            req.Description__c = 'Description';
            req.RFI_Deadline__c = system.today();
            req.CWMP_Application__c = application.Id;
            Map<String,Object> rfi = HH_RFICustomRecordFormCtrl.upsertRFI(JSON.serialize(req), application.Id); 
            Request_For_Information__c rfiInserted = (Request_For_Information__c)rfi.get('rfi');
            //rfiInserted.Status__c = 'Closed';
            rfiInserted.Homeowner_Comment__c = 'Comments';
            update rfiInserted;

            application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
            application.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentInProgress; 
            try{
                update application;
            } catch(Exception e) {
                System.debug('Pending RFI error');
            }

            rfiInserted.Status__c = 'Closed';
          
            HH_RFICustomRecordFormCtrl.getInitDetails(application.Id, rfiInserted.Id, communityUserId, 'Edit');
            try{
                HH_RFICustomRecordFormCtrl.upsertRFI(JSON.serialize(rfiInserted), application.Id); 
            } Catch (Exception e) {
                System.debug('Application Status NOT in RFI ');
            }
            application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
            application.Status__c = HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo; 
            update application;
            HH_RFICustomRecordFormCtrl.isEditable(application.Id);
            HH_RFICustomRecordFormCtrl.upsertRFI(JSON.serialize(req), application.Id); 
            HH_RFICustomRecordFormCtrl.deleteRFI(rfiInserted.Id);
        }

        System.runAs(homeownerUser) { 
            try {
            	HH_RFICustomRecordFormCtrl.getInitDetails(application.Id, req.Id, homeownerUser.Id, 'Edit');
            }
            catch(Exception e) {}
        }
      
        Test.stopTest();
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