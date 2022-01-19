@isTest
public class HH_EditRequestCtrlTest {
    @TestSetup
    public static void createAppLead () {
        System.runAs(new User(Id=UserInfo.getUserId())) {
            User communityUserObj = HH_TestHelper.createCaloesPortalUser('community+1@xyz.com');
            PermissionSet permissionSet2 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = communityUserObj.Id, PermissionSetId = permissionSet2.Id);
        }
    }
 	@isTest
    public static void testGetInitData() {
        Map<String,Object> result = new Map<String,Object>();
        User u = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1];
        System.runAs(u) {
            HH_Application__c application = new HH_Application__c();
 			application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
        	application.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentComplete;
        	application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        	application.Tax_Parcel_Number__c = '234234';
        	application.Is_the_property_in_the_floodplain__c = 'No';
            application.Income_Bracket__c = 'Less than 80%';
            application.Assessed_Value_of_the_Property__c = 1000.00;
            application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
            insert application;
            Test.startTest();
             result = HH_EditRequestCtrl.getInitData(application.Id);
             System.assert(result != null);
             Test.stopTest();
    	}
    }
    @isTest
    public static void testGetInitData1() {
        Map<String,Object> result = new Map<String,Object>();
        User u = HH_TestHelper.createPortalUser();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
        }
        System.runAs(u) {
            HH_Application__c application = new HH_Application__c();
 			application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        	application.Status__c = HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit;
        	application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        	application.Tax_Parcel_Number__c = '234234';
        	application.Is_the_property_in_the_floodplain__c = 'No';
            application.Income_Bracket__c = 'Less than 80%';
            application.Assessed_Value_of_the_Property__c = 1000.00;
            //application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
            insert application;
            Test.startTest();
             result = HH_EditRequestCtrl.getInitData(application.Id);
             System.assert(result != null);
             Test.stopTest();
    	}
    }
    @isTest
    public static void testGetInitData2() {
        Map<String,Object> result = new Map<String,Object>();
        User u = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1];

        System.runAs(u) {
            HH_Application__c application = new HH_Application__c();
 			application.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
        	application.Status__c = HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo;
        	application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        	application.Tax_Parcel_Number__c = '234234';
        	application.Is_the_property_in_the_floodplain__c = 'No';
            application.Income_Bracket__c = 'Less than 80%';
            application.Assessed_Value_of_the_Property__c = 1000.00;
            application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
            insert application;
            Test.startTest();
             result = HH_EditRequestCtrl.getInitData(application.Id);
             System.assert(result != null);
             Test.stopTest();
    	}
    }
    @isTest
    public static void testGetInitData3() {
        	Map<String,Object> result = new Map<String,Object>();
        	User u = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1];
           System.runAs(u) {
                HH_Application__c application = new HH_Application__c();
                application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
                application.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentPending;
                application.Assessor_Email__c = 'ashjkhasf@gmail.com';
                application.Tax_Parcel_Number__c = '234234';
                application.Is_the_property_in_the_floodplain__c = 'No';
               application.Income_Bracket__c = 'Less than 80%';
               application.Assessed_Value_of_the_Property__c = 1000.00;
               application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
                insert application;
                Test.startTest();
                 HH_EditRequestCtrl.isApplicationEditable(application.Id);
                 //System.assert(result != null);
                 Test.stopTest();
           }
    }
    @isTest
    public static void testGetInitData4() {
        	Map<String,Object> result = new Map<String,Object>();
         	Profile p = [select Id,name from Profile where Name = 'CalOES Internal User' limit 1];
        	User u = new User(profileId = p.id,username = 'internalUser@123@gmail.com',email = 'internal@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='JamesweS',lastname='weSmith');
        	insert u;   
        	System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSet.Id);
        	}
           System.runAs(u) {
                HH_Application__c application = new HH_Application__c();
                application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
                application.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentPending;
                application.Assessor_Email__c = 'ashjkhasf@gmail.com';
                application.Tax_Parcel_Number__c = '234234';
                application.Is_the_property_in_the_floodplain__c = 'No';
                application.Income_Bracket__c = 'Less than 80%';
                application.Assessed_Value_of_the_Property__c = 1000.00;
               application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
                insert application;
                Test.startTest();
                 HH_EditRequestCtrl.isApplicationEditable(application.Id);
                 //System.assert(result != null);
                 Test.stopTest();
           }
    }
     @isTest
    public static void testGetInitData5() {
        	Map<String,Object> result = new Map<String,Object>();
         	Profile p = [select Id,name from Profile where Name = 'CalOES Internal User' limit 1];
        	User u = new User(profileId = p.id,username = 'internalUser@123@gmail.com',email = 'internal@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='JamesweS',lastname='weSmith');
        	insert u;   
        	System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSet.Id);
        	}
           System.runAs(u) {
                HH_Application__c application = new HH_Application__c();
                application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
                application.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentComplete;
                application.Assessor_Email__c = 'ashjkhasf@gmail.com';
                application.Tax_Parcel_Number__c = '234234';
                application.Is_the_property_in_the_floodplain__c = 'No';
                application.Income_Bracket__c = 'Less than 80%';
                application.Assessed_Value_of_the_Property__c = 1000.00;
               application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
                insert application;
                Test.startTest();
                 HH_EditRequestCtrl.isApplicationEditable(application.Id);
                 //System.assert(result != null);
                 Test.stopTest();
           }
    }

    @isTest
    public static void testGetInitData6() {
        	Map<String,Object> result = new Map<String,Object>();
         	Profile p = [select Id,name from Profile where Name = 'CalOES Internal User' limit 1];
        	User u = new User(profileId = p.id,username = 'internalUser@123@gmail.com',email = 'internal@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='JamesweS',lastname='weSmith');
        	insert u;   
        	System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSet.Id);
        	}
           System.runAs(u) {
                HH_Application__c application = new HH_Application__c();
                application.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESReview;
                application.Status__c = HH_CONSTANTS.HHApplication_Status_OESOpenRFI;
                application.Assessor_Email__c = 'ashjkhasf@gmail.com';
                application.Tax_Parcel_Number__c = '234234';
                application.Is_the_property_in_the_floodplain__c = 'No';
                application.Income_Bracket__c = 'Less than 80%';
                application.Assessed_Value_of_the_Property__c = 1000.00;
               application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
                insert application;
                Test.startTest();
                 HH_EditRequestCtrl.isApplicationEditable(application.Id);
                 //System.assert(result != null);
                 Test.stopTest();
           }
    }
    
     @isTest
    public static void testGetInitData7() {
        	Map<String,Object> result = new Map<String,Object>();
         	Profile p = [select Id,name from Profile where Name = 'CalOES Internal User' limit 1];
        	User u = new User(profileId = p.id,username = 'internalUser@123@gmail.com',email = 'internal@ff.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='JamesweS',lastname='weSmith');
        	insert u;   
        	System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSet.Id);
        	}
           System.runAs(u) {
                HH_Application__c application = new HH_Application__c();
                application.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
                application.Status__c = HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo;
                application.Assessor_Email__c = 'ashjkhasf@gmail.com';
                application.Tax_Parcel_Number__c = '234234';
                application.Is_the_property_in_the_floodplain__c = 'No';
                application.Income_Bracket__c = 'Less than 80%';
                application.Assessed_Value_of_the_Property__c = 1000.00;
               application.Application_Lead__c = [SELECT Id from User WHERE Username = 'community+1@xyz.com' AND email = 'community+1@xyz.com' limit 1].Id;
                insert application;
                Test.startTest();
                 HH_EditRequestCtrl.isApplicationEditable(application.Id);
                 //System.assert(result != null);
                 Test.stopTest();
           }
    }


}