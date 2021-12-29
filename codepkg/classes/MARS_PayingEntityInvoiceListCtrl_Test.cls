@isTest
private class MARS_PayingEntityInvoiceListCtrl_Test {
    
    @testSetup
    static void createInvoice(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.MACS_ID__c = '1234321';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'test contact';
        insert con;
        
        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='CalOES Portal User'].id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@aqqqqp11rio.com';   
        user.CommunityNickname = 'testssjjsUser123';
        user.Alias = 't1';
        user.Email = 'no1122qq@eaaaamail.com';
        user.IsActive = true;
        user.ContactId = con.Id;
        insert user;
        
        Incident__c incident = new Incident__c();
        incident.Name = 'testIncident';
        incident.Description__c = 'testIncident';
        insert incident;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = acc.Id;
        invoice.Incident__c = incident.Id;
        invoice.Name = 'testInvoice';
        insert invoice;
        
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
        cdl.LinkedEntityId = invoice.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        Funding_Source__c fundingSource = new Funding_Source__c();
        fundingSource.Account__c = acc.Id;
        fundingSource.Name = 'testFundingSource';
        insert fundingSource;
        
        Invoice_Payment__c invoicePayment = new Invoice_Payment__c();
        invoicePayment.Invoice__c = invoice.Id;
        invoicePayment.Funding_Source__c = fundingSource.Id;
        invoicePayment.Invoice_Percent__c = 50.0;
        invoicePayment.Invoice_Amount__c = 23900.04;
        invoicePayment.Status__c = 'Pending';
        insert invoicePayment;
    }
    
    @IsTest
    static void test(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'test' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'test contact' LIMIT 1];
        User u = [SELECT Id FROM User WHERE FirstName = 'first' LIMIT 1];
        Invoice__c inv = [SELECT Id FROM Invoice__c WHERE Account__c = :acc.Id LIMIT 1];
        inv.Status__c = 'Pending For Paying Entity Approval';
        update inv;
        Invoice_Payment__c invPayment = [SELECT Id, Name FROM Invoice_Payment__c WHERE Invoice__c = :inv.Id LIMIT 1];
        invPayment.Status__c = 'Pending';
        update invPayment;
        
        System.runAs(u){
            MARS_PayingEntityInvoiceListCtrl.getInvoiceList();
            MARS_PayingEntityInvoiceListCtrl.getInvoiceData(inv.Id);
            MARS_PayingEntityInvoiceListCtrl.getInvoiceListByFilter('', 'testIncident', '1234321');   
            MARS_PayingEntityInvoiceListCtrl.approvePaymentInvoice(invPayment.Id, '10000', System.today(), 'test');
            MARS_PayingEntityInvoiceListCtrl.rejectPaymentInvoice(invPayment.Id, 'test');
            MARS_PayingEntityInvoiceListCtrl.rejectInvoice(inv.Id, 'test');
            
        }
        MARS_PayingEntityInvoiceListCtrl.approveInvoice(inv.Id, 'test', 'testing');
        MARS_PayingEntityInvoiceListCtrl.saveSignature(inv.Id, 'test');
    } 
}