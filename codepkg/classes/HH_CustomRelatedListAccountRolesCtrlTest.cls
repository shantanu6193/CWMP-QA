@IsTest(SeeAllData=true)
private  class HH_CustomRelatedListAccountRolesCtrlTest {
    @IsTest
    public static void test1() {
        Id homownerId = null;
        Id communityUserId = null;
        Account contractor = null;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            User communityUser = HH_TestHelper.createCaloesPortalUser('community@xyz.com');
            communityUserId = communityUser.Id;
            contractor =  new Account();
            contractor.Name = 'Sample Contractor';
            contractor.Email_Address__c = 'xyz@gmail.com';
            contractor.Entity_Type__c = 'Contractor';
            contractor.Entity_Id__c = contractor.Email_Address__c;
            insert contractor;
            AccountShare acc = new AccountShare();
            acc.UserOrGroupId = communityUser.Id;
            acc.AccountAccessLevel = 'Edit';
            acc.OpportunityAccessLevel = 'None';
            acc.AccountId = contractor.Id;
            insert acc;
        }
        User caloesInternalUser = HH_TestHelper.createCaloesUser();
        PermissionSet permissionSet2 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUserId, PermissionSetId = permissionSet2.Id);
        Id applicationId = null;
        CWMP_Project__c projectRecord = new CWMP_Project__c();
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
            application.Income_Bracket__c = '80% through 120%';
            application.Tax_Parcel_Number__c = '123434';
            application.Is_the_property_in_the_floodplain__c = HH_CONSTANTS.PickList_Yes;
            application.Application_Lead__c = u.Id;
            application.County__c = HH_CONSTANTS.HHApplication_County_SanDiego;
            update application;
            
            projectRecord.CWMP_Application__c = application.Id;
            insert projectRecord;
            
            Account_Role__c accountRole = new Account_Role__c();
            accountRole.RecordTypeId = ApexUtils.getRecordTypeIdbyName('Account_Role__c','CWMP');
            accountRole.Status__c = 'Active';
            accountRole.Point_of_Contact__c = 'test';
            accountRole.CWMP_Application__c = application.Id;
            accountRole.CWMP_Project__c = projectRecord.Id;
            accountRole.Account__c = contractor.Id;
            insert accountRole;
            HH_CustomRelatedListAccountRolesCtrl.getCWMPAccountRoles(application.Id);
            HH_CustomRelatedListAccountRolesCtrl.getCWMPAccountRoles(projectRecord.Id);
        }
        System.runAs(caloesInternalUser) {
            HH_CustomRelatedListAccountRolesCtrl.getCWMPAccountRoles(applicationId);
            HH_CustomRelatedListAccountRolesCtrl.getCWMPAccountRoles(projectRecord.Id);
        }
       
        Test.stopTest();
    }
}