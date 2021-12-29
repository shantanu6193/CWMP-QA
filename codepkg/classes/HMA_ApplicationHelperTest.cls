@isTest public with sharing class HMA_ApplicationHelperTest {
    @isTest public static void testCheckACRoleAndCreateContactRoleForApplication() {
        Map<Id, Application__c> preAppIdToApplicationMap = new Map<Id, Application__c>();
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = portalCon.AccountId);
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        conRole.Pre_Application__c  = newApplication.Pre_Application__c;
        insert conRole;
        preAppIdToApplicationMap.put(newApplication.Pre_Application__c, newApplication);
        
        Test.startTest();
        HMA_ApplicationHelper.checkACRoleAndCreateContactRoleForApplication(preAppIdToApplicationMap);
        Test.stopTest();
    }

    @isTest public static void testCheckACRoleAndCreateContactRoleForApplication1() {
        Map<Id, Application__c> preAppIdToApplicationMap = new Map<Id, Application__c>();
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = newApplication.Subapplicant_Entity__c);
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        conRole.Pre_Application__c  = newApplication.Pre_Application__c;
        insert conRole;
        preAppIdToApplicationMap.put(newApplication.Pre_Application__c, newApplication);
        
        Test.startTest();
        HMA_ApplicationHelper.checkACRoleAndCreateContactRoleForApplication(preAppIdToApplicationMap);
        Test.stopTest();
    }

    @isTest public static void testProcessAccountContactRole() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id);
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        conRole.Pre_Application__c  = newApplication.Pre_Application__c;
        insert conRole;

        Test.startTest();
        HMA_ApplicationHelper.processAccountContactRole(portalCon, conRole, newApplication.Subapplicant_Entity__c);

        acRole.Account_Name__c = portalCon.AccountId;
        update acRole;
        HMA_ApplicationHelper.processAccountContactRole(portalCon, conRole, portalCon.AccountId);
        Test.stopTest();
    }

    @isTest public static void testPrepareDataForSendingEmail() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = portalCon.AccountId);
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        conRole.Pre_Application__c  = newApplication.Pre_Application__c;
        insert conRole;

        Test.startTest();
        HMA_ApplicationHelper.prepareDataForSendingEmail(portalCon, conRole);
        Test.stopTest();
    }

    @isTest public static void testProcessCommunityUser() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = portalCon.AccountId);
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        conRole.Pre_Application__c  = newApplication.Pre_Application__c;
        insert conRole;

        Test.startTest();
        HMA_ApplicationHelper.processCommunityUser(portalCon, conRole, new List<User>() );
        Test.stopTest();
    }

    @isTest public static void testProcessCommunityUser1() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Contact__c = portalCon.Id;
        insert conRole;

        Test.startTest();
        HMA_ApplicationHelper.processCommunityUser(portalCon, conRole, new List<User>() );
        Test.stopTest();
    }

    @isTest public static void testShareSubApplication() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        User u = HMA_TestHelper.getPortalUserHMA(false);
        u.ContactId = portalCon.Id;
        insert u;
        List<User> userList = new List<User>();
        userList.add(u);
        System.runAs(u) {
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = portalCon.AccountId);
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'Contributor';
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            conRole.Pre_Application__c  = newApplication.Pre_Application__c;
            insert conRole;

            Test.startTest();
            HMA_ApplicationHelper.shareSubApplication(portalCon, conRole, userList);

            //Document__c doc = HMA_TestHelper.createCustomDocumentRecord(newApplication.Id);
            conRole.Role__c = 'Viewer';
            update conRole;
            HMA_ApplicationHelper.shareSubApplication(portalCon, conRole, userList);
            Test.stopTest();
        }
    }

    @isTest public static void testProcessAccount() {
        Map<String, Object> recordDetailsMap = new Map<String, Object>();
        Key_Value_Store__mdt kvStore = HMA_TestMetadataHelper.getKeyValue('SOC_OPS_Non_GovernmentOwnerId');
        Account newParentAccount = HMA_TestHelper.getParentAccount(true);
        Account acc = HMA_TestHelper.getPortalAccount(false);
        acc.OwnerId = kvStore.Text_Value__c;
        acc.Entity_Type__c = 'County';
        acc.ParentId = newParentAccount.Id;
        acc.ShippingStreet = '207 N Butte St';
        acc.ShippingCity = 'Willows';
        acc.ShippingState = 'CA';
        acc.ShippingPostalCode  = '95988';
        insert acc;
        AccountRecordWrapper obj = new AccountRecordWrapper();
        obj.NonGovernmentalEntity = 'Test';
        obj.FederalTaxID = acc.Entity_Id__c;
        obj.FacilityName = acc.Name;
        obj.FacilityID = acc.Entity_Id__c;
        //obj.FacilityID = '125486';
        obj.StreetAddress = acc.ShippingStreet;
        obj.CityName = acc.ShippingCity;
        obj.County = null;
        obj.State = acc.ShippingState;
        obj.ZipPostalCode = acc.ShippingPostalCode;

        recordDetailsMap.put('accountRecord', obj);
        Test.startTest();
        HMA_ApplicationHelper.processAccount(recordDetailsMap);

        obj.NonGovernmentalEntity = acc.Name;
        recordDetailsMap.put('accountRecord', obj);
        HMA_ApplicationHelper.processAccount(recordDetailsMap);

        obj.County = acc.Name;
        recordDetailsMap.put('accountRecord', obj);
        HMA_ApplicationHelper.processAccount(recordDetailsMap);
        Test.stopTest();
    }

    @isTest public static void testUpdateScoringChecklistOESBriefSummary() {
        Map<Id, Application__c> appIdToApplicationMap = new Map<Id, Application__c>();
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Scoring_Checklist__c sc = HMA_TestHelper.getScoringChecklist(true, newApplication.Id, '');
        appIdToApplicationMap.put(newApplication.Id, newApplication);
        Test.startTest();
        HMA_ApplicationHelper.updateScoringChecklistOESBriefSummary(appIdToApplicationMap);
        Test.stopTest();
    }

    @isTest public static void testValidateAppWhenStatusIsFEMAReview() {
        List<Application__c> femaApplications = new List<Application__c>();
        Application__c newApplication = HMA_TestHelper.getApplication(false, '', '', '');
        newApplication.Is_this_an_eligible_Activity__c = 'No';
        newApplication.Is_this_an_eligible_Subapplicant__c  = 'No';
        newApplication.Is_BCR_verified_at_1_0_or_greater__c  = 'No';
        newApplication.Match_Letter__c  = 'No';
        newApplication.Maintenance_Letter__c  = 'No';
        newApplication.Subapplication_Complete__c   = 'No';

        femaApplications.add(newApplication);
        Test.startTest();
        HMA_ApplicationHelper.validateAppWhenStatusIsFEMAReview(femaApplications);
        Test.stopTest();
    }

    public class AccountRecordWrapper {
        public String NonGovernmentalEntity;
        public String FederalTaxID;
        public String Facility;
        public String FacilityName;
        public String FacilityID;
        public String StreetAddress;
        public String CityName;
        public String County;
        public String State;
        public String ZipPostalCode;
    }
}