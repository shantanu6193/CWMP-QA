@isTest(seeAllData=false)
public without sharing class CommunityAppPHOSRegistrationCtrlTest {
    public static Contact getPortalContact(boolean create) {
        Account acc = PHOS_TestHelper.getAccount(create);
        Contact portalContact = new Contact();
        portalContact.Firstname='FirstNameportal';
        portalContact.Lastname='LastNameportal';
        portalContact.Email='email@portal.com';
        portalContact.Phone ='923-875-1274';
        portalContact.AccountId = acc.Id;

        if(create)
            insert portalContact;
        return portalContact;
    }

    public static User getPortalUser(boolean create) {

        //**** First give call to getPortalContact() methos and provide ContactId to PortalUser

        Profile profile = [select Id,name from Profile where Name like 'PHOS Customer Community Plus Login User' limit 1];
        UserRole userRole = [Select Id, Name from UserRole where Name like 'Region 1 Customer User' limit 1];
        system.debug('profile-----------'+profile);
        Contact con = getPortalContact(create);
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User portalUser = new User(
                Username = uniqueName+'@acme.com',
                //ContactId = contact.Id,
                ProfileId = profile.Id,
                Alias = 'test123',
                Email = 'email@portal.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = con.Id
                //IsActive = true,
                //UserRoleId = userRole.Id
        );

        if(create)
            insert portalUser;
        return portalUser;
    }

    public static User_Registration__c getUserRegistration(boolean create){
        Account newAccount = PHOS_TestHelper.getAccount(create);
        User_Registration__c   newUserRegistration = new User_Registration__c();
        //newUserRegistration.Community_Application__c = Community_Application__c.Id;
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.First_Name__c = 'testFirstName';
        newUserRegistration.Last_Name__c = 'testLastName';
        newUserRegistration.Status__c = 'Pending for Approval';
        newUserRegistration.Email__c = 'email@portal.com';
        newUserRegistration.Non_Governmental_Entity__c = 'test';
        //newUserRegistration.State_Agency__c = newAccount.Id;
        newUserRegistration.Entity_Type__c = 'State Agency';

        if(create)
            insert newUserRegistration;
        return newUserRegistration;
    }
    /*@isTest public static void testProcessPHOSRequest(){

        Account acc = PHOS_TestHelper.getParentAccount(true);
        Contact con = getPortalContact(false);
        con.AccountId = acc.Id;
        insert con; 
       // User u =[SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];  
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        Group g1;
        System.runAs(u) {  
             g1 = new Group(Name='testQ', type='Queue');
            insert g1;   
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'User_Registration__c');
            insert q1;
            GroupMember member = new GroupMember();
            member.UserOrGroupId = usr.Id;
            member.GroupId = g1.Id;
            insert member;
        }
        System.runAs(usr) {  
            Test.startTest();
                User_Registration__c newUserRegistration = getUserRegistration(false);
                newUserRegistration.User__c = usr.Id;
                newUserRegistration.OwnerId = g1.Id;
                newUserRegistration.Email__c = 'email'+UserServiceTest.generateRandomString(8)+'@portal.com';
                insert newUserRegistration;
                newUserRegistration.Id = null;
                String userRegistrationStr = JSON.serialize(newUserRegistration);
                
                CommunityAppPHOSRegistrationCtrl.processPHOSRequest(userRegistrationStr);
                CommunityAppPHOSRegistrationCtrl.processPHOSRequestForRejection(userRegistrationStr);
            Test.stopTest();
        }
    }

     @isTest public static void testProcessUserRegApprovalRequest(){
         Account newAccount = new Account();
         newAccount.Name = 'NewTest1'+system.now()+Math.random();
         newAccount.BillingStreet='rse';
         newAccount.BillingCountry='USA1';
         newAccount.type = 'Customer';
         newAccount.BillingState='NY';
         newAccount.Queue_Name__c = 'test232';
         newAccount.BillingPostalCode='3421545';
         newAccount.Phone='5445342134';
         newAccount.Website='https://www.google.com';
         insert newAccount;
         Contact newContact = PHOS_TestHelper.getContact(false);
         newContact.AccountId = newAccount.Id;
         insert newContact;
         User portalUser = PHOS_TestHelper.getPortalUser(false);
         portalUser.ContactId = newContact.Id;
         //portalUser.AccountId = newContact.AccountId;
         insert portalUser;
         System.runAs(portalUser) {
             Account newAccount1 = PHOS_TestHelper.getAccount(true);
             Account acc = [SELECT Id,Name,Parent.Queue_Name__c FROM Account WHERE Id=: newContact.AccountId LIMIT 1];
             User_Registration__c newUserRegistration = PHOS_TestHelper.getUserRegistration(false);
             insert newUserRegistration;
             String recordId = String.valueOf(newUserRegistration.Id);

             test.startTest();
             //CommunityAppPHOSRegistrationCtrl.processUserRegApprovalRequest(recordId);
             test.stopTest();
         }
     }*/

    @isTest public static void testProcessPHOSRequestForRejection(){

        /*Account acc = PHOS_TestHelper.getParentAccount(true);
        Contact con = PHOS_TestHelper.getPortalContact(false);
        con.AccountId = acc.Id;
        insert con;
        User u = PHOS_TestHelper.getPortalUser(false);
        u.ContactId = con.Id;
        insert u;
        System.runAs(u) {
            User_Registration__c newUserRegistration = getUserRegistration(false);
            //insert newUserRegistration;
            String userRegistrationStr = JSON.serialize(newUserRegistration);
            test.startTest();
            CommunityAppPHOSRegistrationCtrl.processPHOSRequestForRejection(userRegistrationStr);
            test.stopTest();
        }*/
    }

    @isTest public static void testUpdateOwner(){

        Account acc = PHOS_TestHelper.getParentAccount(true);
        Contact con = PHOS_TestHelper.getPortalContact(false);
        con.AccountId = acc.Id;
        insert con;
        User u = PHOS_TestHelper.getPortalUser(false);
        u.ContactId = con.Id;
        insert u;
        System.runAs(u) {
            User_Registration__c newUserRegistration = PHOS_TestHelper.getUserRegistration(false);
            insert newUserRegistration;
            test.startTest();
            CommunityAppPHOSRegistrationCtrl.updateOwner(newUserRegistration.Id);
            CommunityAppPHOSRegistrationCtrl.getUserDetails();
            test.stopTest();
        }
    }
}