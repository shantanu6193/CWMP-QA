@isTest
private class MARS_ResourceAgreementHistoryCtrl_Test {
    @testSetup
    static void createRecData(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Agency_Rate_Agreement__c agenRateAgr = new Agency_Rate_Agreement__c();
        agenRateAgr.Name = 'testAgenRateAgr';
        agenRateAgr.Agency__c = acc.Id;
        agenRateAgr.Start_Date__c = System.today();
        agenRateAgr.End_Date__c = System.today() + 10;
        agenRateAgr.Approval_Status__c = 'Reviewed';
        insert agenRateAgr;
        
        Agency_Rate_Agreement_Line_Item__c agenRateAgrLI = new Agency_Rate_Agreement_Line_Item__c();
        agenRateAgrLI.Name = 'testAgenRateAgrLI';
        agenRateAgrLI.Agency_Rate_Agreement__c = agenRateAgr.Id;
        agenRateAgrLI.OT__c = true;
        agenRateAgrLI.PTP__c = true;
        agenRateAgrLI.Status__c = 'Active';
        insert agenRateAgrLI;
        
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
        cdl.LinkedEntityId = agenRateAgr.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
    }
    
    @isTest
    static void test(){
        Account acct = [SELECT Id FROM Account WHERE Name = 'testAccount' LIMIT 1];
        Agency_Rate_Agreement__c agnRate = [SELECT Id FROM Agency_Rate_Agreement__c WHERE Name = 'testAgenRateAgr' LIMIT 1];
        MARS_ResourceAgreementHistoryCtrl.getAgreementHistory(acct.Id);
        MARS_ResourceAgreementHistoryCtrl.getData(agnRate.Id);
    }
    
}