@IsTest(SeeAllData=true)
private  class HH_CustomRelatedListRFICtrlTest {
    @IsTest
    public static void test1() {
        Id homownerId = null;
        Id communityUserId = null;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            User homeowner = HH_TestHelper.createCaloesPortalUser('homeowner@xyz.com');
            homownerId = homeowner.Id;
            User communityUser = HH_TestHelper.createCaloesPortalUser('community@xyz.com');
            communityUserId = communityUser.Id;
        }
        User caloesInternalUser = HH_TestHelper.createCaloesUser();
        PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = homownerId, PermissionSetId = permissionSet.Id);
        PermissionSet permissionSet2 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUserId, PermissionSetId = permissionSet2.Id);
        Id applicationId = null;
        Test.startTest(); 
        System.runAs(new User(Id=communityUserId)) {
            User u = [SELECT Id,ContactId FROM User WHERE Id=:communityUserId];
            Contact c = [SELECT Id,Email FROM Contact WHERE Id=:u.ContactId];
            c.Preferred_Language__c = 'English';
            update c;
            HH_Application__c application = new HH_Application__c();
            application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
            application.Assessor_Email__c = 'ashjkhasf@gmail.com';
            application.Tax_Parcel_Number__c = '234234';
            application.Is_the_property_in_the_floodplain__c = 'No';
            application.Applicant__c = c.Id;
            insert application;
            applicationId = application.Id;
            application.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
            application.Status__c = HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo;
            application.Assessed_Value_of_the_Property__c = 1234;
            application.Income_Bracket__c = '< 120% AMI';
            application.Tax_Parcel_Number__c = '123434';
            application.Is_the_property_in_the_floodplain__c = HH_CONSTANTS.PickList_Yes;
            application.Application_Lead__c = u.Id;
            update application;
            Request_For_Information__c req = new Request_For_Information__c();
            HH_Application__c app = [SELECT Id,Applicant__r.Preferred_Language__c FROM HH_Application__c WHERE Id=:application.Id];
            System.debug('app: '+ app);
            req.RecordTypeId = ApexUtils.getRecordTypeIdbyName('Request_For_Information__c','CWMP');
            req.Status__c = 'RFI Requested';
            req.Description__c = 'Description';
            req.RFI_Deadline__c = system.today();
            req.CWMP_Application__c = application.Id;
            insert req;
            System.debug('RFI Created..');
            HH_CustomRelatedListRFICtrl.getRFIRecords(application.Id);
        }

        System.runAs(new User(Id=homownerId)) {
            HH_CustomRelatedListRFICtrl.getRFIRecords(applicationId);
        }
        System.runAs(caloesInternalUser) {
            HH_CustomRelatedListRFICtrl.getRFIRecords(applicationId);
        }
        System.runAs(new User(Id=UserInfo.getUserId())) {
            HH_CustomRelatedListRFICtrl.getRFIRecords(applicationId);
        }
        Test.stopTest();
    }

    
}