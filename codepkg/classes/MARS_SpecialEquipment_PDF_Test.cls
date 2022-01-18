@isTest
public without sharing class MARS_SpecialEquipment_PDF_Test {
    static testmethod void simpleTests(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Agency_Special_Equipment__c spEquip = new Agency_Special_Equipment__c();
        spEquip.Agency__c = acc.Id;
        spEquip.Approval_Status__c = 'Reviewed';
        insert spEquip;
 		ContentVersion cv = MARS_TestHelper.getContentVersion();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = spEquip.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        PageReference testPage = Page.MARS_AdministrativeRate_PDF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(spEquip.Id));
        MARS_SpecialEquipment_PDF test = new MARS_SpecialEquipment_PDF();
    } 
}