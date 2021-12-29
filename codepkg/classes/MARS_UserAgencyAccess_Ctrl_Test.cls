@isTest
private class MARS_UserAgencyAccess_Ctrl_Test {
    @testSetup
    static void createRecData(){     
        Account acc = new Account();
        acc.Name = 'testing';
        insert acc;
        
        Account acct = new Account();
        acct.Name = 'test case';
        acct.MACS_ID__c = '112211';
        acct.Chief_Name__c = 'testname';
        acct.BillingCity = 'Sacramento';
        acct.Entity_Type__c = 'Fire Agency';
        insert acct;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        insert con;
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = acct.Id;
        acr.ContactId = con.Id;
        acr.Relationship_Strength__c = 'Primary';
        insert acr;
        
        User_Registration__c usrReg = new User_Registration__c();
        usrReg.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByName().get('MARS').getRecordTypeId();
        usrReg.Fire_Agency__c = acct.id;
        usrReg.Access_Level__c = 'Primary';
        usrReg.Status__c = 'Requested';
        usrReg.First_Name__c = 'testrecord';
        insert usrReg;
        
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
        Account acct = [SELECT Id FROM Account WHERE Name = 'test case'];
        User u = [SELECT Id FROM User WHERE FirstName = 'first'];
        User_Registration__c userReg = [SELECT Id, User__c FROM User_Registration__c WHERE First_Name__c = 'testrecord'];
        userReg.User__c = u.Id;
        update userReg;
        
        List<String> selId = new List<String>{'abc', 'bcd', 'cde'};
        
        System.runAs(u){
            MARS_UserAgencyAccess_Ctrl.getAgenciesList();
            MARS_UserAgencyAccess_Ctrl.submitNewAgencyAccessRequest('Primary', acct.Id);
            MARS_UserAgencyAccess_Ctrl.submitChangeAgencyAccessRequest('Primary', acct.Id);
            MARS_UserAgencyAccess_Ctrl.apexSearchFireAgency('test case', selId);
        }
    }
}