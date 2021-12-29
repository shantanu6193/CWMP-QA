@isTest public with sharing class ContentDocumentLinkTriggerHelperTest {
    @isTest(SeeAllData=true) public static void testContentDocumentLinkTrigger(){
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        ContentDocument newContentDocument = [SELECT Id from ContentDocument LIMIT 1];
        ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
        newContentDocumentLink.ContentDocumentId = newContentDocument.Id;
        newContentDocumentLink.Visibility = 'AllUsers';
        newContentDocumentLink.LinkedEntityId = newOrder.Id;
        
        Test.startTest();
        insert newContentDocumentLink;
        Test.stopTest();
    }
}