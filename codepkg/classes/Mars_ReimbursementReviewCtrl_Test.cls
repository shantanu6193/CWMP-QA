@isTest
private class Mars_ReimbursementReviewCtrl_Test {
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
        reimburse.Total_Reimbursement_Amount__c = 20;
        reimburse.Comments__c = 'test';
        reimburse.Status__c = 'Agency Review';
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
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = acc.Id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        List<FileUpdateWrapper> fileUpdWrapLst = new List<FileUpdateWrapper>();
        FileUpdateWrapper fileUpdWrap = new FileUpdateWrapper();
        fileUpdWrap.name = 'test';
        fileUpdWrap.documentId = conDocId1;
        fileUpdWrap.contentVersionId = cv1.Id;
        fileUpdWrap.Type = 'V';
        fileUpdWrapLst.add(fileUpdWrap);
        String fileUpdateWrapper = JSON.serialize(fileUpdWrapLst);
        
        
        Mars_ReimbursementReviewCtrl.getReimbursementReviewList(acc.Id);
        Mars_ReimbursementReviewCtrl.getData(reimburse.Id);
        Mars_ReimbursementReviewCtrl.saveComments(reimburse.Id, 'test', fileUpdateWrapper, 'test', acc.Id);
        Mars_ReimbursementReviewCtrl.deleteFile(cv1.Id);
    }
    
    public class FileUpdateWrapper {
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
        public String Type{get;set;}
    }
    
}