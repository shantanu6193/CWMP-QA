@isTest
private class Mars_ReimbursementCtrl_Test {
    @isTest
    static void testCreateReimbursementRecord(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        F42__c f42Rec = MARS_TestHelper.getF42(false);
        Incident__c incident = MARS_TestHelper.getIncident(true);
        f42Rec.Incident__c = incident.Id;
        f42Rec.Account__c = testAccount.Id;
        insert f42Rec;
        
        Reimbursement__c reimburse = new Reimbursement__c();
        reimburse.Account__c = testAccount.Id;
        //reimburse.F_42__c = f42Rec.Id;
        reimburse.Incident_Request_Number__c = '12345';
        reimburse.Unit_Number__c = '55555';
        reimburse.Incident__c = incident.Id;
        reimburse.Strike_Team__c = 'ABC';
        //insert reimburse;
        //List<Reimbursement__c> reimburseLst = [SELECT Id FROM Reimbursement__c WHERE Name = 'testReimburse'];
        String objParentData = JSON.serialize(reimburse);
        
        Reimbursement_Line_Item__c reimburseLI = new Reimbursement_Line_Item__c();
        reimburseLI.City__c = 'test';
        reimburseLI.Amount__c = 1000;
        reimburseLI.Meal__c = 300;
        reimburseLI.Lodging__c = 500;
        reimburseLI.MISC__c = 300;
        reimburseLI.Description__c = 'test Data';
        //reimburseLI.Reimbursement__c = reimburse.Id;
        insert reimburseLI;
        List<Reimbursement_Line_Item__c> reimburseLILst = [SELECT Id FROM Reimbursement_Line_Item__c WHERE Reimbursement__c = :reimburse.Id];
        String lineItemData = JSON.serialize(reimburseLILst);
        ContentVersion cv = MARS_TestHelper.getContentVersion();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = reimburse.Account__c;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        List<FileUpdateWrapper> fileUpdWrapLst = new List<FileUpdateWrapper>();
        FileUpdateWrapper fileUpdWrap = new FileUpdateWrapper();
        fileUpdWrap.name = 'test';
        fileUpdWrap.documentId = conDocId;
        fileUpdWrap.contentVersionId = cv.Id;
        fileUpdWrap.Type = 'Test';
        fileUpdWrapLst.add(fileUpdWrap);
        String fileUpdateWrapper = JSON.serialize(fileUpdWrapLst);
        Blob signiture = Blob.valueof('Test data');
        String signStr = JSON.serialize(signiture);
        test.startTest();
        Mars_ReimbursementCtrl.createReimbursementRecord(lineItemData, objParentData, null, fileUpdateWrapper);
        Mars_ReimbursementCtrl.deleteFile(cv.Id);
        test.stopTest();
    }
    
    public class FileUpdateWrapper {
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
        public String Type{get;set;}
    }
    @isTest 
    static void testApexSearchIncident() {
         Incident__c incident = MARS_TestHelper.getIncident(true);
         test.startTest();
         List<LookupSearchResult> result = Mars_ReimbursementCtrl.apexSearchIncident('Test Incident MARS');
         System.assert(result.size() > 0);
         test.stopTest();
    }
    @isTest 
    static void testGetAgencyDetails() {
         Account testAccount = MARS_TestHelper.getAccount(true);
         test.startTest();
         Account acc = Mars_ReimbursementCtrl.getAgencyDetails(testAccount.Id);
         System.assertNotEquals(acc.Name,null);
         test.stopTest();
    } 
    
    @isTest 
    static void testApexSearchStrikeTeam() {
         F42__c f42Rec = MARS_TestHelper.getF42(false);
         Incident__c incident = MARS_TestHelper.getIncident(true);
         f42Rec.Incident__c =incident.Id;
         insert f42Rec;
         test.startTest();
         List<LookupSearchResult> result = Mars_ReimbursementCtrl.apexSearchStrikeTeam('ABC', incident.Id);
         System.assert(result.size() > 0);
         test.stopTest();
    }
    @isTest 
    static void getApexSearchUnitNumber() {
         F42__c f42Rec = MARS_TestHelper.getF42(false);
         Incident__c incident = MARS_TestHelper.getIncident(true);
         f42Rec.Incident__c =incident.Id;
         insert f42Rec;
         test.startTest();
         List<Map<String, String>> result = Mars_ReimbursementCtrl.apexSearchUnitNumber(incident.Id,'ABC','12345');
         System.assert(result.size() > 0);
         test.stopTest();
    }
    @isTest 
    static void getApexSearchIncidentRequestNumber() {
         F42__c f42Rec = MARS_TestHelper.getF42(false);
         Incident__c incident = MARS_TestHelper.getIncident(true);
         f42Rec.Incident__c =incident.Id;
         insert f42Rec;
         test.startTest();
         List<Map<String, String>> result = Mars_ReimbursementCtrl.apexSearchIncidentRequestNumber(incident.Id,'ABC');
         System.assert(result.size() > 0);
         test.stopTest();
    }
         
}