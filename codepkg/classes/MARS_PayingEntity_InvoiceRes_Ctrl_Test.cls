@isTest
private class MARS_PayingEntity_InvoiceRes_Ctrl_Test {
    @testSetup
    static void createRecData(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'testContact';
        insert con;
        
        Incident__c incid = new Incident__c();
        incid.Name = 'testIncident';
        insert incid;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'testInvoice';
        invoice.Account__c = acc.Id;
        invoice.Incident__c = incid.Id;
        insert invoice;
        
        Funding_Source__c funSource = new Funding_Source__c();
        funSource.Name = 'testFunSource';
        funSource.Account__c = acc.Id;
        insert funSource;
        
		Invoice_Payment__c invPay = new Invoice_Payment__c();
		invPay.Invoice__c = invoice.Id;
		invPay.Funding_Source__c = funSource.Id;
        invPay.Status__c = 'Partially Paid';
        invPay.Date_Of_Payment__c = Date.today();
        insert invPay;
        
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
    }
    
    @isTest
    static void test(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'testAccount' LIMIT 1];
        Incident__c inci = [SELECT Id FROM Incident__c WHERE Name = 'testIncident' LIMIT 1];
        User u = [SELECT Id FROM User WHERE FirstName = 'first' LIMIT 1];
        String accId = acct.Id;
        String incidId = inci.Id;
        Date StartDate = Date.today();
        Date endDate = Date.today();
        System.runAs(u){
            MARS_PayingEntity_InvoiceResearch_Ctrl.getInvoicePayments(accId, incidId, StartDate, endDate);
        }
    }
}