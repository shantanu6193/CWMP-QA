@isTest(seeAllData=false)
public class HHDocumentTest {

    @isTest 
    public static void testHHDocument() {
        
        Document__c document = new Document__c();
        document.Document_Name__c = 'Test Doc';
        document.Status__c = 'Active';
        insert document;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;

        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        //Create ContentDocumentLink for Project
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = document.Id;
        cdl1.ContentDocumentId = conDocId;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        List<String> documentIds = new List<String>();
       
            documentIds.add(document.Id);
        
        
        List<ContentDocumentLink> contentLinks  = [SELECT Id, ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: documentIds];
        System.debug('contentLinks: '+contentLinks);
        List<String> contentDocIds = new List<String>();
        Map<String,String> contentDocMap = new Map<String,String>();
        for(ContentDocumentLink cdl : contentLinks) {
            contentDocMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
        }
        List<ContentVersion> contentVersions = [SELECT Id,ContentDocumentId,PathOnClient,IsLatest,FileType,VersionNumber from ContentVersion where IsLatest = true AND ContentDocumentId IN:contentDocMap.values()];
        Map<String,ContentVersion> contentDocVersionMap = new Map<String,ContentVersion>();
        for(ContentVersion latestVersion: contentVersions) {
            contentDocVersionMap.put(latestVersion.ContentDocumentId,latestVersion);
        }
        

        Test.startTest();
            HHDocument hhDoc = new HHDocument();
            hhDoc.setDocument(document);
            String contentDocId = contentDocMap.get(document.Id);
            System.debug('contentDocId: '+contentDocId);
            if(contentDocId != null) {
                hhDoc.setContentDocumentId(contentDocId);
                ContentVersion latestVersion = contentDocVersionMap.get(contentDocId);
                System.debug('latestVersion: '+latestVersion);
                if(latestVersion != null) {
                    hhDoc.setLatestVersionId(latestVersion.Id);
                    hhDoc.setVersionNumber(latestVersion.VersionNumber);
                    hhDoc.setFileName(latestVersion.PathOnClient);
                }
            }
        hhDoc.getDocumentInfo();
        ContentVersion latestVersion = contentDocVersionMap.get(contentDocId);
        HHDocument controller = new HHDocument(document,contentDocId,latestVersion.Id,latestVersion.PathOnClient,latestVersion.VersionNumber);
        
        Test.stopTest();
    }
}