@isTest(seeAllData=false)
public without sharing class HH_TestHelper {


    public static User createPortalUser () {
        Account acc = new Account (
            Name = 'Portal Account'
        );  
        insert acc;
        Contact con = new Contact (
            AccountId = acc.id,
            FirstName = 'FirstName',
            LastName = 'LastName'
        );
        insert con;
        Profile p = [select Id,name from Profile where Name = 'CalOES Portal User' limit 1];
        User newUser = new User(
            profileId = p.id,
            username = 'PortalUser@gmail.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='JamesS',
            lastname='Smith',
            IsActive = true,
            contactId = con.id
        );
        insert newUser;     
        return newUser;
    }
    
    public static User createCaloesPortalUser (String uniqueEmail) {
        Account a = getAccount(true);
        Contact con = new Contact (
            AccountId = a.id,
            FirstName = 'John',
            LastName = 'Smith',
            Email = uniqueEmail
        );
        insert con;
        Profile p = [select Id,name from Profile where Name =:HH_CONSTANTS.CALOES_Portal_Profile_Name limit 1];
        User newUser = new User(
            profileId = p.id,
            username = uniqueEmail,
            email = uniqueEmail,
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='John',
            lastname='Smith',
            IsActive = true,
            contactId = con.id
        );
        insert newUser;     
        return newUser;
    }

    

    public static User createCaloesUser() {
        Profile p = [select Id,name from Profile where Name =:HH_CONSTANTS.CALOES_Internal_Profile_Name limit 1];
        User internalUser = new User(
            profileId = p.id,
            username = 'caloes@xyz.com',
            email = 'caloes@xyz.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='JSmith',
            firstname='Jason',
            lastname='Smith',
            IsActive = true
        ); 
        insert internalUser;  
        PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = internalUser.id, PermissionSetId = permissionSet.Id); 
        return internalUser;
    }
    
    
    
    
    public static Community_Application__c getCommunityApplication(boolean create){
        Community_Application__c newCommunityApplication = new Community_Application__c();
        newCommunityApplication.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        //newCommunityApplication.User_Approval_Class__c = 'PHOS_UserServiceAppHandler';
        //newCommunityApplication.App_URL__c = 'https://uat-caloes.cs33.force.com/hma ';
       // newCommunityApplication.Display_Name__c = 'Hazard Mitigation - NOI Requests Portal  ';
        newCommunityApplication.isActive__c = true;
        newCommunityApplication.Name = 'HH Community Homeowner';
        if(create)
            insert newCommunityApplication;
        return newCommunityApplication;
    }
    
     public static User_Registration__c getUserRegistration(boolean create){
        Account newAccount = HH_TestHelper.getAccount(create);
        User_Registration__c   newUserRegistration = new User_Registration__c();
       
        newUserRegistration.First_Name__c = 'testFirstName';
        newUserRegistration.Last_Name__c = 'testLastName';
        newUserRegistration.Status__c = 'Pending for Approval';
        newUserRegistration.Email__c = 'test@gmail.com';
        newUserRegistration.User_Type__c = 'Community';
        
        if(create)
            insert newUserRegistration;
        return newUserRegistration;
    }


    public static Contact getContact(boolean create){
        Account account = getAccount(create);
        Contact contact = new Contact(Firstname='FirstName',
                                    Lastname='LastName',
                                    Email='email@gmail.com',
                                    Phone = '9652314586',	
                                    AccountId = account.Id);
        if(create)
        insert contact;
        return contact;
    }

    public static Account getAccount(boolean create){
        Account account = new Account(Name = 'HOUSEHOLD-312vg3',AccountSource = 'web',AnnualRevenue = 1800000,Description = 'A bank account is a financial account maintained by a bank or other financial institution in which the financial transactions between the bank and a customer are recorded',
                              NumberOfEmployees = 15,Industry = 'banking',Phone = '8569321475',Rating = 'Warm');
        if(create)
        insert account;
        return account;
    }
    /*public static Document__c getDocument(){
        Document__c doc = new Document__c(Document_Type__c='',Document_Name__c='Test');
        insert doc;
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ionicLogo.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Accounts '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(''); // converting your binary string to Blog
        insert conVer;

        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = doc.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        return doc;
    }*/

    public static HH_Application__c getApplication (Boolean addApplicationContact,Boolean create) {
        HH_Application__c application = new HH_Application__c();
        if(create) {
            insert application;
        }
        Contact c1 = HH_TestHelper.getContact(false);
        c1.FirstName = 'Jerry';
        c1.LastName = 'Jason';
        insert c1;
        Application_Contact__c ac = new Application_Contact__c();
        ac.HH_Application__c = application.Id;
        ac.Contact__c = c1.Id;
        ac.Head_of_Household__c = 'Yes';
        if(create && addApplicationContact) {
            insert ac;
        }
        return application;
    }

    
}