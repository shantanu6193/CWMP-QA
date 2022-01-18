@isTest
public with sharing class MARS_AgencyAdminRates_PDF_Test {

    static testmethod void simpleTests() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Agency_Admin_Rates__c adminRate = new Agency_Admin_Rates__c();
        adminRate.Agency__c = acc.Id;
        adminRate.Approval_Status__c = 'Reviewed';
        insert adminRate;
 		ContentVersion cv = MARS_TestHelper.getContentVersion();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = adminRate.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        PageReference testPage = Page.MARS_AdministrativeRate_PDF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(adminRate.Id));
        MARS_AgencyAdminRates_PDF test = new MARS_AgencyAdminRates_PDF(); 
    }
}