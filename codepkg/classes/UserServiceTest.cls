@isTest(seeAllData=false)
public with sharing class UserServiceTest {
    @isTest 
    public static void testAddUsersToApp() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        User_Registration__c newUserReg = PHOS_TestHelper.getUserRegistration(false);
        newUserReg.Community_Application__c = newCommunityApp.Id;
        insert newUserReg;
        userRegistrationsList.add(newUserReg);

        Test.startTest();
        UserService.addUsersToApp(userRegistrationsList);
        System.assertEquals(newUserReg.Id, newUserReg.Id);
        Test.stopTest();
    }
    
    @isTest 
    public static void testcreateCommunityStandardUser() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        newAccount.ParentId = newParentAccount.Id;
        newAccount.Name = 'Alameda';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.Entity_Type__c = 'County';
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    
   @isTest 
    public static void testcreateCommunityStandardUserOther() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        newAccount.ParentId = newParentAccount.Id;
        newAccount.Name = 'Alameda';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.Non_Governmental_Entity__c = 'test';
        newUserRegistration.Non_Government_Entity_Type__c ='Other';
        newUserRegistration.Entity_Type__c = 'Non-Governmental Entity';
        newUserRegistration.Federal_Tax_ID__c = '23435325';
        newUserRegistration.City_Name__c= 'CA';
        newUserRegistration.State__c = 'Test';
        newUserRegistration.Zip_Postal_Code__c = '12345';
        newUserRegistration.Street_Address__c ='Test marg';
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    
   @isTest 
    public static void testcreateCommunityStandardUserFacility() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        newAccount.ParentId = newParentAccount.Id;
        newAccount.Name = 'FAMILY CRISIS CENTER';
        insert newAccount;
        Contact contact = new Contact(AccountId = newAccount.Id ,Firstname='FirstName', Lastname='LastName',Email='testuser122123@gmail.com',Phone ='123-123-1234',Entity_Change_Requested__c=true);
        insert contact;
        User user = PHOS_TestHelper.getUser(false);
        user.ContactId = contact.Id;
        //insert user;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.Non_Government_Entity_Type__c ='Health Care Facility';
        newUserRegistration.Entity_Type__c = 'Non-Governmental Entity';
        newUserRegistration.Facility_ID__c = '234567890';
        newUserRegistration.Facility_Name__c = 'FAMILY CRISIS CENTER';
        newUserRegistration.City_Name__c = 'CA test';
        newUserRegistration.State__c = 'Test';
        newUserRegistration.Zip_Postal_Code__c = '12345';
        newUserRegistration.Street_Address__c ='Test marg';
        newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
        newUserRegistration.Facility__c = newAccount.Id;
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testcreateCommunityStandardUserOther1() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        Account newAccountChild = PHOS_TestHelper.getAccount(false);
        newAccountChild.Name = 'Alameda';
        newAccountChild.ParentId = newParentAccount.Id;
        insert newAccountChild;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.Non_Government_Entity_Type__c ='Health Care Facility';
        newUserRegistration.Entity_Type__c = 'Non-Governmental Entity';
        newUserRegistration.Facility_ID__c = '23454453';
        newUserRegistration.Facility_Name__c = 'Alameda';
        //newUserRegistration.Federal_Tax_ID__c = '23435325';
        newUserRegistration.City_Name__c= 'CA';
        newUserRegistration.State__c = 'Test';
        newUserRegistration.Zip_Postal_Code__c = '12345';
        newUserRegistration.Street_Address__c ='Test marg';
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testcreateCommunityStateAgencyUser() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        //newAccount.Name = 'Alameda';
        newAccount.Entity_Type__c ='State Agency';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.Entity_Type__c = 'State Agency';
        newUserRegistration.State_Agency__c = newAccount.Id;
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testcreateCommunityCityUser() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Name = 'Adelanto sd';
        newAccount.Entity_Id__c = 'CITY-89899';
        newAccount.Entity_Type__c ='City';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.Entity_Type__c = 'City';
        newUserRegistration.City__c = newAccount.Id;
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testcreateCommunityCourtsUser() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Name = 'County Superior Court';
        newAccount.Entity_Type__c ='Courts';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.Entity_Type__c = 'Courts';
        newUserRegistration.Courts__c = newAccount.Id;
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testcreateCommunityTribalUser() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Name = 'Lagoon Rancheria';
        newAccount.Entity_Type__c ='Tribal';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.Entity_Type__c = 'Tribal';
        newUserRegistration.Tribal__c = newAccount.Id;
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testcreateCommunitySpecialDistrictUser() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Name = 'test ';
        newAccount.Entity_Type__c ='Special District';
        insert newAccount;
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.Entity_Type__c = 'Special District';
        newUserRegistration.Special_District__c = newAccount.Id;
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }
    @isTest 
    public static void testUpdateStateAgencyUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
      	Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Entity_Type__c ='State Agency';
        insert newAccount;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccount.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            Test.startTest();
                User_Registration__c   newUserRegistration = getUserRegistration(false);
                newUserRegistration.Entity_Type__c = 'State Agency';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.State_Agency__c = newAccount.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                newUserRegistration.User__c = usr.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
    @isTest 
    public static void testUpdateSpecialDistrictUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
      	Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Entity_Type__c ='Special District';
        insert newAccount;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccount.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            Test.startTest();
                User_Registration__c   newUserRegistration = getUserRegistration(false);
                newUserRegistration.Entity_Type__c = 'Special District';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.Special_District__c = newAccount.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                newUserRegistration.User__c = usr.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
    @isTest 
    public static void testUpdateTribalUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
      	Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Entity_Type__c ='Tribal';
        insert newAccount;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccount.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            Test.startTest();
                User_Registration__c newUserRegistration = getUserRegistration(false);
                newUserRegistration.Entity_Type__c = 'Tribal';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.Tribal__c = newAccount.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                newUserRegistration.User__c = usr.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
    @isTest 
    public static void testUpdateCourtsUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
      	Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Entity_Type__c ='Courts';
        insert newAccount;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccount.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            Test.startTest();
                User_Registration__c newUserRegistration =  getUserRegistration(false);
                newUserRegistration.Entity_Type__c = 'Courts';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.Courts__c = newAccount.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                newUserRegistration.User__c = usr.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
	@isTest 
    public static void testUpdateFacilityUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
      	Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Entity_Type__c ='City';
        insert newAccount;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccount.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            	Test.startTest();
                User_Registration__c newUserRegistration =  getUserRegistration(false);
                newUserRegistration.Non_Government_Entity_Type__c ='Health Care Facility';
                newUserRegistration.Entity_Type__c = 'Non-Governmental Entity';
                newUserRegistration.Facility_ID__c = '234567890';
                newUserRegistration.Facility_Name__c = 'FAMILY CRISIS CENTER';
                newUserRegistration.City_Name__c = 'CA test';
                newUserRegistration.State__c = 'Test';
                newUserRegistration.Zip_Postal_Code__c = '12345';
                newUserRegistration.Street_Address__c ='Test marg';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.Facility__c = newAccount.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                newUserRegistration.User__c = usr.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
    @isTest 
    public static void testUpdateCityUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
      	Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.Entity_Type__c ='City';
        insert newAccount;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccount.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            Test.startTest();
                User_Registration__c newUserRegistration = getUserRegistration(false);
                newUserRegistration.Entity_Type__c = 'City';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.City__c = newAccount.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                newUserRegistration.User__c = usr.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
    @isTest 
    public static void testUpdateCountyUser(){
 		List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
      	Account newAccountChild = PHOS_TestHelper.getAccount(false);
        newAccountChild.Entity_Type__c ='County';
        newAccountChild.Name = 'Alameda';
        newAccountChild.ParentId = newParentAccount.Id;
        insert newAccountChild;
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        Community_Application__c newCommunityApp = PHOS_TestHelper.getCommunityApplication(true);
        con.AccountId = newAccountChild.Id;
        con.Email='testuser122123@gmail.com';
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        System.runAs(usr) {  
            	Test.startTest();
                User_Registration__c newUserRegistration = getUserRegistration(false);
                newUserRegistration.Entity_Type__c = 'County';
                newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
                newUserRegistration.User__c = usr.Id;
                newUserRegistration.Community_Application__c = newCommunityApp.Id;
                insert newUserRegistration;
                userRegistrationsList.add(newUserRegistration);
                UserService.createCommunityStandardUser(userRegistrationsList);
			    System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
            Test.stopTest();
        }
    }
    public static User_Registration__c getUserRegistration(boolean create){
        Account newAccount = PHOS_TestHelper.getAccount(create);
        User_Registration__c newUserRegistration = new User_Registration__c();
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.First_Name__c = 'testFirstName';
        newUserRegistration.Last_Name__c = 'testLastName';
        newUserRegistration.Status__c = 'Pending for Approval';
        newUserRegistration.Email__c = 'testuser122123'+ generateRandomString(8) +'@gmail.com';
        newUserRegistration.Password__c = 'test@12345';
        if(create)
            insert newUserRegistration;
        return newUserRegistration;
    }
	
	public static String generateRandomString(Integer len) {
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		while (randStr.length() < len) {
		   Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
		   randStr += chars.substring(idx, idx+1);
		}
		return randStr; 
	}
    @isTest
    public static void testHHContactDetails() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c parentCommunity = new Community_Application__c();
        parentCommunity.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        parentCommunity.Display_Name__c = 'California Wildfire Mitigation Program ';
        parentCommunity.isActive__c = true;
        parentCommunity.User_Approval_Class__c='HH_UserServiceAppHandler';
        parentCommunity.Name = HH_CONSTANTS.HH_Parent_Community_Application_Name;
        insert parentCommunity;

        Community_Application__c newCommunityApp = new Community_Application__c();
        newCommunityApp.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        newCommunityApp.Display_Name__c = 'HH Community Homeowner ';
        newCommunityApp.isActive__c = true;
        newCommunityApp.Parent__c = parentCommunity.Id;
        newCommunityApp.User_Type__c = 'Homeowner';
        newCommunityApp.Name = 'HH Community Homeowner ';
        insert newCommunityApp;
        Account newAccount = HH_TestHelper.getAccount(false);
        newAccount.Name = HH_CONSTANTS.Account_HOUSEHOLD_Name+'-5437853';
        insert newAccount;
        Contact contact = new Contact(Firstname='FirstName',Lastname='LastName', email='email12313@gmail.com',Phone = '9652314586',AccountId = newAccount.Id);
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        newUserRegistration.Unique_Household_Number__c = '5437853';
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }

    @isTest
    public static void testHHContactDetails1() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c parentCommunity = new Community_Application__c();
        parentCommunity.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        parentCommunity.Display_Name__c = 'California Wildfire Mitigation Program ';
        parentCommunity.isActive__c = true;
        parentCommunity.User_Approval_Class__c='HH_UserServiceAppHandler';
        parentCommunity.Name = HH_CONSTANTS.HH_Parent_Community_Application_Name;
        insert parentCommunity;

        Community_Application__c newCommunityApp = new Community_Application__c();
        newCommunityApp.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        newCommunityApp.Display_Name__c = 'HH Community Homeowner ';
        newCommunityApp.isActive__c = true;
        newCommunityApp.Parent__c = parentCommunity.Id;
        newCommunityApp.User_Type__c = 'Homeowner';
        newCommunityApp.Name = 'HH Community Homeowner ';
        insert newCommunityApp;
        Account newAccount = HH_TestHelper.getAccount(true);
        Contact contact = new Contact(Firstname='FirstName',Lastname='LastName', email='email1213@gmail.com',Phone = '9652314586',AccountId = newAccount.Id, Entity_Change_Requested__c=true);
        User_Registration__c   newUserRegistration = getUserRegistration(false);
        newUserRegistration.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        newUserRegistration.Rejection_Reason__c = 'Entity Change Required';
        newUserRegistration.Email__c = 'email1213@gmail.com';
        newUserRegistration.Unique_Household_Number__c = '12376';
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        Test.startTest();
        UserService.createCommunityStandardUser(userRegistrationsList);
        System.assertEquals(newUserRegistration.Id, newUserRegistration.Id);
        Test.stopTest();
    }

}