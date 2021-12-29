@IsTest
private class MARS_Agency_Personnel_Ctrl_Test {
    @testSetup
    static void createAccountRecord(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Account acct = new Account();
        acct.Name = 'Testing';
        insert acct;
        
        Contact con = new Contact();
        con.FirstName = 'contact';
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert con;
        
        User_Registration__c usr = new User_Registration__c();
        usr.First_Name__c = 'test';
        usr.Status__c = 'Access Level Change Requested';
        usr.Fire_Agency__c = acc.Id;
        insert usr;
        
        usr.State__c = 'App Requested';
        update usr;
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
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = acct.Id;
        acr.ContactId = con.Id;
        acr.Relationship_Strength__c = 'Strong';
        insert acr;
    }
    
    @IsTest
    static void getAgenciesUsersListTest(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test' LIMIT 1];
        Account accts = [SELECT Id, Name FROM Account WHERE Name = 'Testing' LIMIT 1];
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName = 'test' LIMIT 1];
        User u = [SELECT Id, AccountId FROM User WHERE FirstName = 'first' LIMIT 1];
        User_Registration__c usrId = [SELECT Id, First_Name__c FROM User_Registration__c WHERE First_Name__c = 'test' LIMIT 1]; 
        AccountContactRelation accCon = [SELECT Id, AccountId FROM AccountContactRelation WHERE AccountId = :accts.Id LIMIT 1];

        System.runAs(u){
            MARS_Agency_Personnel_Ctrl personnelCtrl = new MARS_Agency_Personnel_Ctrl();
            MARS_Agency_Personnel_Ctrl.getAgenciesUsersList(acc.Id);
            MARS_Agency_Personnel_Ctrl.getPendingAgenciesUsersList(acc.Id);
            MARS_Agency_Personnel_Ctrl.getPendingAgenciesUsersCount(acc.Id);
            MARS_Agency_Personnel_Ctrl.submitUserAccessChangeRequest('Primary', acc.Id, con.Id);
            MARS_Agency_Personnel_Ctrl.submitUserAccessChangeRequest('Secondary', acc.Id, con.Id);
            MARS_Agency_Personnel_Ctrl.submitRemoveUserAccessRequest('Primary', acc.Id, con.Id);
            MARS_Agency_Personnel_Ctrl.submitAddUserAccessRequest('Primary', acc.Id, con.Id);
            MARS_Agency_Personnel_Ctrl.submitUserAccessRejectRequest(usrId.Id);
            MARS_Agency_Personnel_Ctrl.submitUserAccessApproveRequest(usrId.Id);
            MARS_Agency_Personnel_Ctrl.getRelationshipStrength(accCon.AccountId);   
        }
    }
}