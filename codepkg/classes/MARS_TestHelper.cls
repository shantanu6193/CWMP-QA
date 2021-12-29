@isTest(SeeAllData=false)
public class MARS_TestHelper {
    public static User getStandardUser(boolean create)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName='standarduser'+Math.random()+'@govbd.dev');
        if(create)
            insert u;
        return u;
    }
    public static User getPortalUser(boolean create) {
        
        //**** First give call to getPortalContact() methos and provide ContactId to PortalUser

        Profile profile = [select Id,name from Profile where Name like 'CalOES Portal User' limit 1];
        UserRole userRole = [Select Id, Name from UserRole where Name like 'Region 1 Customer User' limit 1];
        system.debug('profile-----------'+profile);
        Contact con = MARS_TestHelper.getPortalContact(create);
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User portalUser = new User(
            Username = uniqueName+'@acme.com',
            //ContactId = contact.Id,
            ProfileId = profile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
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

    public static Contact getPortalContact(boolean create) {
        Account acc = MARS_TestHelper.getAccount(create);
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
    public static User getUser(boolean create){
        Profile profile = [select Id,name from Profile where Name = 'CalOES PHOS Standard User' limit 1];
        User user = new User(Username = 'standarduser123Test45333@govbd.dev', LastName = 'nik' , Email = 'test12345@test.com',
                Alias = 'standt',   TimeZoneSidKey = 'America/New_York',    LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,LanguageLocaleKey = 'en_US',
                SenderEmail = 'standarduser@govbd.dev',    SenderName = 'user');
        if(create)
            insert user;
        return user;
    }

    public static Account getParentAccount(boolean create){
        Account newAccount = new Account();
        newAccount.Name = 'NewTest13'+system.now()+Math.random();
        newAccount.BillingStreet='rewxe';
        newAccount.BillingCountry='USA-11';
        newAccount.BillingState='NSdY';
        newAccount.BillingPostalCode='3425345';
        newAccount.Phone='544534334';
        newAccount.Entity_Type__c = 'Fire Agency';
        newAccount.Entity_Id__c = '234543';
        newAccount.Account_Name__c = 'Test';
        if(create)
            insert newAccount;
        return newAccount;
    }

    public static Account getAccount(boolean create){
        //Account newParentAccount = MARS_TestHelper.getParentAccount(create);
        Account newAccount = new Account();
        newAccount.Name = 'NewTest'+system.now()+Math.random();
        newAccount.MACS_ID__c = 'ARC';
        newAccount.Federal_Tax_ID__c = '90909';
        newAccount.DUNS__c	= '821972783';
        //newAccount.ParentId = newParentAccount.Id;
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c = 'Fire Agency';
        newAccount.Entity_Id__c = '23454453';
        if(create)
            insert newAccount;
        return newAccount;
    }
    public static Contact getContact(Boolean create) {
        Account newAccount = MARS_TestHelper.getAccount(create);
        Contact contact = new Contact(AccountId = newAccount.Id ,Firstname='FirstName', Lastname='LastName',Email='email@email.com',Phone ='123-123-1234');
        if (create) {
            insert contact;
        }
        return contact;
    }

    public static EmailMessage getEmailMessage(boolean create , Id orderId){
        EmailMessage newEmailMessage = new EmailMessage();
        newEmailMessage.Subject = 'New request submitted by County User%';
        newEmailMessage.RelatedToId = orderId;
        if(create)
            insert newEmailMessage;
        return newEmailMessage;
    }

   
    public static User_Registration__c getUserRegistration(boolean create){
        Account newAccount = MARS_TestHelper.getAccount(create);
        User_Registration__c   newUserRegistration = new User_Registration__c();
        //newUserRegistration.Community_Application__c = Community_Application__c.Id;
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.First_Name__c = 'testFirstName';
        newUserRegistration.Last_Name__c = 'testLastName';
        newUserRegistration.Status__c = 'Pending for Approval';
        newUserRegistration.Email__c = 'test@gmail.com';
        newUserRegistration.Entity_Type__c = 'Fire Agency';
        
        if(create)
            insert newUserRegistration;
        return newUserRegistration;
    }
    
    public static Community_Application__c getMARSCommunityApplication(boolean create){
        Community_Application__c newCommunityApplication = new Community_Application__c();
        newCommunityApplication.App_Permission_Set_Developer_Name__c = 'MARS_Community_User';
        newCommunityApplication.User_Approval_Class__c = 'MARS_UserServiceAppHandler';
        newCommunityApplication.App_URL__c = 'https://uat-caloes.cs33.force.com/mars';
        newCommunityApplication.Display_Name__c = 'MARS';
        newCommunityApplication.isActive__c = true;
        newCommunityApplication.Name = 'MARS';
        if(create)
            insert newCommunityApplication;
        return newCommunityApplication;
    }
    public static Account accountWithEntityType(boolean create, String entityType){
        Account newParentAccount = MARS_TestHelper.getParentAccount(create);
        Account newAccount = new Account();
        newAccount.Name = 'NewTest'+system.now()+Math.random();
        newAccount.ParentId = newParentAccount.Id;
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c=entityType;
        newAccount.Entity_Id__c=entityType;
        if(create)
            insert newAccount;
        return newAccount;
    }
   public static Incident__c getIncident(boolean create){
       Incident__c incident= new Incident__c();
       incident.Name = 'Test Incident MARS';
       incident.Declaration_Number__c = '4456';
       incident.Available_for_Application__c  ='MARS';
        if(create)
       		insert incident;
       return incident;
   }
   public static F42__c getF42(boolean create){
       F42__c f42Record= new F42__c();
       f42Record.Name = 'Test F42';
       f42Record.Strike_Team__c = 'ABC';
       f42Record.Incident_Request_Number__c  ='12345';
       f42Record.ER_UNIT__c  ='55555';
       f42Record.OH_OVERHEAD_TYPE__c = 'STEN';
       f42Record.DI_Committed_to_Incident_Date__c =  DateTime.Now().AddDays(-3).date();
       f42Record.DI_Return_from_Incident_Date__c =  DateTime.Now().date();
       f42Record.DI_Committed_to_Incident_Time__c = '1030';
       f42Record.DI_Return_from_Incident_Time__c = '1645'; 
       f42Record.ER_TYPE__c = '1';
       f42Record.DI_REPORTING_LOCATION__c = 'test';
       f42Record.SV_TYPE__c = 'SUV';
       f42Record.SV_VEHICLE_OWNERSHIP__c ='Agency';
       f42Record.PA_PAYING_AGENCY__c ='USFS';
       f42Record.ER_CDF_OES_VEHICLE__c =false;
       f42Record.SV_ENDING_ODOMETER__c = 1200;
       f42Record.SV_BEGINNING_ODODMETER__c =500;
       f42Record.ER_LICENSE_NUMBER__c ='34567';
       f42Record.OH_ICS_Title__c ='Manager';
       f42Record.ER_APPARATUS__c ='Test';
       f42Record.SN_LOSS_DAMAGE_CLAIM__c =true;
       f42Record.SN_SUPPLY_NUMBER__c ='1234';
       f42Record.RA_AGENCY_NAME__c ='Fire Dept Agency';
       f42Record.RA_YOUR_NAME__c ='Mark p';
       f42Record.RA_YOUR_PHONE__c ='(123) 456-7890';
       f42Record.ER_FEMA_CODES__c ='8089';
       f42Record.ER_SPECIAL_EQUIPMENT__c ='Chain Saw';
       f42Record.RA_YOUR_TITLE__c ='Test';
       f42Record.PA_PRINTED_NAME__c ='Test User';
       f42Record.PA_DATE__c = DateTime.Now().date();
       f42Record.PA_ICS_POSITION_TITLE__c ='test ICS';
       f42Record.PI_NUMBER_OF_PERSONNEL_ON_APPARATUS__c = '4';
        if(create)
       		insert f42Record;
       return f42Record;
   }
   public static ContentVersion getContentVersion(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.Type__c ='Test';
        Insert cv;
        return cv;
   }
}