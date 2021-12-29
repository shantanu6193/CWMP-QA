@isTest 
public with sharing class PageLayoutCtrlTest {
    @isTest public static void testGetPageDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        returnMap = PageLayoutCtrl.getPageDetails(newApplication.Id, '');
        System.assert(returnMap.size() > 0);
    }
    @isTest public static void testGetPageDetails1() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Program_Template_Page__mdt ptMdt = HMA_TestMetadataHelper.getProgramTemplatePageMdt('HMGP_Scope_Of_Work_General');

        returnMap = PageLayoutCtrl.getPageDetails(newApplication.Id, ptMdt.Id);
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testGetPageLayoutDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        //Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Page_Layout__mdt plMdt = HMA_TestMetadataHelper.getPageLayoutMdt('HMGP_Acquisition_Demo_Relocation');

        returnMap = PageLayoutCtrl.getPageLayoutDetails(plMdt.Id);
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testGetProjectSitePageDetailsByPageLayoutId() {
        Map<String, Object> returnMap = new Map<String, Object>();
        //Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Page_Layout__mdt plMdt = HMA_TestMetadataHelper.getPageLayoutMdt('HMGP_Acquisition_Demo_Relocation');
        
        returnMap = PageLayoutCtrl.getProjectSitePageDetailsByPageLayoutId(plMdt.Id);
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testGetRecordDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Page_Layout__mdt plMdt = HMA_TestMetadataHelper.getPageLayoutMdt('HMGP_Acquisition_Demo_Relocation');

        returnMap = PageLayoutCtrl.getRecordDetails(newApplication.Id, plMdt.Id);
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testGetRecordDetails1() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        //Page_Layout__mdt plMdt = HMA_TestMetadataHelper.getPageLayoutMdt('HMGP_Acquisition_Demo_Relocation');

        returnMap = PageLayoutCtrl.getRecordDetails(newApplication.Id, '');
        System.assert(returnMap.size() > 0);
    }

    // @isTest public static void testGetRecordDetails2() {
    //     Map<String, Object> returnMap = new Map<String, Object>();
    //     Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
    //     Page_Layout__mdt plMdt = HMA_TestMetadataHelper.getPageLayoutMdt('HMGP_Acquisition_Demo_Relocation');

    //     returnMap = PageLayoutCtrl.getRecordDetails(newApplication.Pre_Application__c, plMdt.Id);
    //     System.assert(returnMap.size() > 0);
    // }
    @isTest public static void testGetLoggedInUsrDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap = PageLayoutCtrl.getLoggedInUsrDetails();
        System.assert(returnMap.size() > 0);
    }

    /*@isTest public static void testGetPathDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');

        returnMap = PageLayoutCtrl.getPathDetails(newApplication.Id);
        System.assert(returnMap.size() > 0);
    }*/

    @isTest public static void testGetListofTable() {
        Map<String, Object> returnMap = new Map<String, Object>();

        returnMap = PageLayoutCtrl.getListofTable('SELECT Id, DeveloperName FROM Page_Field__mdt');
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testDynamicTableClassApex() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        User portalUser = HMA_TestHelper.getPortalUser(false);
        portalUser.ContactId = portalCon.Id;
        insert portalUser;
        System.runAs(portalUser) {
            Map<String, Object> returnMap = new Map<String, Object>();
            Map<String, Object> returnMap1 = new Map<String, Object>();
            Map<String, Object> returnMap2 = new Map<String, Object>();
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
            
            returnMap = PageLayoutCtrl.dynamicTableClassApex(newApplication.Id, 'HMA_SubApplicationRole', 'Contact_Role_Confirmation_Table');
            System.assert(returnMap.size() > 0);

            /**This is used for cover else condition from HMA_SubApplicationRole.executeClass */
            returnMap2 = PageLayoutCtrl.dynamicTableClassApex(newApplication.Id, 'HMA_SubApplicationRole', 'Contact_Roles');
            System.assert(returnMap2.size() > 0);

            /**This is used for cover else condition from HMA_SubApplicationRole.executeClass */
            conRole.Role__c = 'FEMA Programmatic Analyst';
            update conRole;
            returnMap1 = PageLayoutCtrl.dynamicTableClassApex(newApplication.Id, 'HMA_SubApplicationRole', 'FEMA_Request_For_Information');
            System.assert(returnMap1.size() > 0);
        }
        
    }

    @isTest public static void testSearch() {
        List<LookupSearchResult> returnList = new List<LookupSearchResult>();
        /**Program records are created for cover SearchProgramsCtrl class */
        Program__c parentPro = HMA_TestHelper.getProgram(false);
        parentPro.Name = 'Hazard Mitigation Assistance';
        insert parentPro;
        Program__c pro = HMA_TestHelper.getProgram(false);
        pro.Name = 'HMGP';
        pro.Parent_Program__c  = parentPro.Id;
        insert pro;
        returnList = PageLayoutCtrl.search('HMGP', new List<String>{}, 'SearchProgramsCtrl');
    }

    @isTest public static void testGetFieldDependencies() {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap = PageLayoutCtrl.getFieldDependencies('Application__c', 'County__c', 'Region__c');
        System.assert(returnMap.size() > 0);
    }
}