@isTest 
public without sharing class PageLayoutHelperTest {
    @isTest public static void testHandleNextPreviousProgramTemplatePage() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Program_Template_Page__mdt ptMdt = HMA_TestMetadataHelper.getProgramTemplatePageMdt('HMGP_Scope_Of_Work_General');

        returnMap = PageLayoutHelper.handleNextPreviousProgramTemplatePage('previous', newApplication.Id, ptMdt.Id);
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testGetProgramTemplatePageForProjectSite() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Program_Template_Page__mdt ptMdt = HMA_TestMetadataHelper.getProgramTemplatePageMdt('HMGP_Scope_Of_Work_General');

        returnMap = PageLayoutHelper.getProgramTemplatePageForProjectSite(newApplication.Id, ptMdt.Id, '');
        System.assert(returnMap.size() > 0);
    }

}