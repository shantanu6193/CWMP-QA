@isTest
private class MARS_FileListCtrlTest {
    static testMethod void testCaseContent() {
		Account acc=new Account();
		acc.Name='test';
     
		insert acc;
              
        Test.startTest();
        List<String> otherIds=new List<String>();
        
        
        MARS_FileListCtrl.getContents(acc.Id, otherIds, 'CreatedDate', 'testnew');
        Test.stopTest();
        
    }
    static testMethod void deleteFile(){
        Account acc=new Account();
		acc.Name='test';
     	insert acc;
        
        ContentVersion cv = new ContentVersion();
		cv.Title = 'Test Document';
		cv.PathOnClient = 'TestDocument.pdf';
		cv.VersionData = Blob.valueOf('Test Content');
		cv.IsMajorVersion = true;
		Insert cv;
 
		//Get Content Version
		List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
		
 
		//Get Content Documents
		List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		    
        Test.startTest();
        List<String> otherIds=new List<String>();
        
        
        MARS_FileListCtrl.deleteFile(cdList[0].Id+'', acc.Id+'', otherIds, 'CreatedDate', 'testnew');
        Test.stopTest();
    }
    
}