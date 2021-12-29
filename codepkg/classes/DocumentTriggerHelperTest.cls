@isTest
public with sharing class DocumentTriggerHelperTest {
    @isTest public static void testBehaviour() {
        List<Document__c> lstDocs = new list<Document__c>();    
        Document__c doc1 = new Document__c();
            doc1.Document_Name__c = 'Test Document1';
            doc1.Stage__c = ALS_CONSTANTS.Document_Stage_New;
            lstDocs.add(doc1);
        insert lstDocs;
        
        Test.startTest();
                for(Document__c doc : lstDocs){
                    doc.Stage__c = ALS_CONSTANTS.Document_Stage_Uploaded;
                }
                try {
                    update lstDocs;
                }
                catch(Exception e) {
                    System.assert(e.getMessage().contains(System.Label.REAL_Document_UploadStageError));
                }
        Test.stopTest();
    }
}