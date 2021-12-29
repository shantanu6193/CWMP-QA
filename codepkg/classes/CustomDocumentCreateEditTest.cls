/**
 * Created by Sushant Patil on 16-06-2021.
 */

@IsTest
private class CustomDocumentCreateEditTest {
    @IsTest
    static void testBehavior() {
        HH_Application__c hhApplication = new HH_Application__c();
        Document__c doc =new Document__c(Document_Name__c ='Test');
        Document__c doc1 =new Document__c(Document_Name__c ='Test');
        insert hhApplication;
        insert doc1;
        String documentDetail =JSON.serialize(doc);
        String documentDetail1 =JSON.serialize(doc1);
        Test.startTest();
        try{
            CustomDocumentCreateEdit.saveDocumentInfo(documentDetail,false);
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Insertion Failed'));
        }
        CustomDocumentCreateEdit.getDocumentInfo(doc1.Id,hhApplication.Id);
        try{
            CustomDocumentCreateEdit.saveDocumentInfo(documentDetail1,true);
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Failed to Update'));
        }

        Test.stopTest();
    }
}