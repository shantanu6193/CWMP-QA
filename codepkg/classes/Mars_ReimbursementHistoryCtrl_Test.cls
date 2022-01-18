@isTest
private class Mars_ReimbursementHistoryCtrl_Test {
    @isTest
    static void test(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Incident__c inci = new Incident__c();
        inci.Name = 'testIncident';
        insert inci;
        
        Reimbursement__c reimburse = new Reimbursement__c();
        reimburse.Account__c = acc.Id;
        reimburse.Incident__c = inci.Id;
        //reimburse.Name = 'testReimburse';
        reimburse.Comments__c = 'test';
        insert reimburse;
        
        Reimbursement_Line_Item__c reimburseLI = new Reimbursement_Line_Item__c();
        reimburseLI.Reimbursement__c = reimburse.Id;
        reimburseLI.Description__c = 'test';
        insert reimburseLI;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = reimburse.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        Mars_ReimbursementHistoryCtrl.getReimbursementHistory(acc.Id);
        Mars_ReimbursementHistoryCtrl.getData(reimburse.Id);
    }

}