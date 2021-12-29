@isTest
private class MARS_ResourceAgreementCtrl_Test {    
    @isTest
    static void test(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        List<Agency_Rate_Agreement_Line_Item__c> agenRateAgreeLI = new List<Agency_Rate_Agreement_Line_Item__c>();
        Agency_Rate_Agreement__c agenRateAgr = new Agency_Rate_Agreement__c();
        agenRateAgr.Name = 'testAgenRateAgr';
        agenRateAgr.Agency__c = testAccount.Id;
        agenRateAgr.Agreement_Type__c = 'GBR';
        agenRateAgr.Approval_Status__c = 'Expired'; 
        insert agenRateAgr;
        
        Agency_Rate_Agreement_Line_Item__c agenRateAgrLI = new Agency_Rate_Agreement_Line_Item__c();
        agenRateAgrLI.Name = 'testAgenRateAgrLI';
        agenRateAgrLI.Agency_Rate_Agreement__c = agenRateAgr.Id;
        insert agenRateAgrLI;
        Agency_Non_Suppression_Personnel__c nonSupPer = new Agency_Non_Suppression_Personnel__c();
        nonSupPer.Agency__c = testAccount.Id;
        nonSupPer.Start_Date__c =  DateTime.Now().AddDays(-3).date();
        nonSupPer.Approval_Status__c = 'Reviewed';
        insert nonSupPer;
        Agency_Non_Suppression_Line_Item__c nonSupPerItem = new Agency_Non_Suppression_Line_Item__c();
        nonSupPerItem.Classification_Title__c = 'Test';
        nonSupPerItem.Current_Rate__c = 25.00;
        nonSupPerItem.Status__c = 'Active';
        nonSupPerItem.Agency_Non_Suppression_Personnel__c = nonSupPer.Id;
        insert nonSupPerItem;
        
        MARS_ResourceAgreementCtrl.apexSearchCFAA_Line_Items('Test', testAccount.Id);
        MARS_ResourceAgreementCtrl.getData(testAccount.Id);
        
    }
    @isTest
    static void test1(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        List<Agency_Rate_Agreement_Line_Item__c> agenRateAgreeLI = new List<Agency_Rate_Agreement_Line_Item__c>();
        Agency_Rate_Agreement__c agenRateAgr = new Agency_Rate_Agreement__c();
        agenRateAgr.Name = 'testAgenRateAgr';
        agenRateAgr.Agency__c = testAccount.Id;
        agenRateAgr.Agreement_Type__c = 'GBR';
        agenRateAgr.Approval_Status__c = 'Expired'; //MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        insert agenRateAgr;
 		 
        Id profileId = [Select Id From Profile Where Name ='CalOES Portal User'].Id;
        Account acct = TestUtility.createAccount('test');
        Contact cont = TestUtility.createContact('test', 'tes', 'test@gmail.vom', acct.Id);
        User u = TestUtility.createCommunityUser(cont.Id, profileId, 'Amit', 'Singh');        
        
        Agency_Rate_Agreement_Line_Item__c agenRateAgrLI = new Agency_Rate_Agreement_Line_Item__c();
        agenRateAgrLI.Name = 'testAgenRateAgrLI';
        agenRateAgrLI.Start_Date__c = DateTime.Now().date();
		agenRateAgrLI.Agency_Rate_Agreement__c = agenRateAgr.Id;
        //insert agenRateAgrLI;
        
        String agrList = JSON.serialize(agenRateAgreeLI);
        String startDate = String.valueOf(Date.today());
        String endDate = String.valueOf(Date.today().addDays(10));

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
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        List<FileUpdateWrapper> fileUpdWrapperLst = new List<FileUpdateWrapper>();
        FileUpdateWrapper fileUpdWrapper = new FileUpdateWrapper();
        fileUpdWrapper.name = 'test';
        fileUpdWrapper.documentId = conDocId;
        fileUpdWrapper.contentVersionId = cv.Id;
        fileUpdWrapper.Type = 'V';
        fileUpdWrapperLst.add(fileUpdWrapper);
        String fileUpdateWrap = JSON.serialize(fileUpdWrapperLst);
        
        //System.runAs(u){
            //MARS_ResourceAgreementCtrl.createAgreeLineItem(agrList, testAccount.Id, startDate, endDate, fileUpdateWrap, 'GBR');
            //MARS_ResourceAgreementCtrl.deleteFile(cv.Id);
    	//}
    }
    
    public class FileUpdateWrapper {
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
        public String Type{get;set;}
    }
}