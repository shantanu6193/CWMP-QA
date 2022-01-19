@isTest(seeAllData=true)
public class HH_UserServiceAppHandlerTest {

    @isTest 
    public static void testHandleApprove() {
        List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
        Community_Application__c parentCommunity = new Community_Application__c();
       // parentCommunity.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        parentCommunity.Display_Name__c = 'California Wildfire Mitigation Program ';
        parentCommunity.isActive__c = true;
        parentCommunity.User_Approval_Class__c='HH_UserServiceAppHandler';
        parentCommunity.Name = HH_CONSTANTS.HH_Parent_Community_Application_Name;
        parentCommunity.User_Type__c = 'Community'; 
        insert parentCommunity;
        
        Community_Application__c newCommunityApp = new Community_Application__c();
        newCommunityApp.App_Permission_Set_Developer_Name__c = 'HH_Community_Homeowner_User';
        newCommunityApp.Display_Name__c = 'HH Community Homeowner ';
        newCommunityApp.isActive__c = true;
        newCommunityApp.Parent__c = parentCommunity.Id;
		newCommunityApp.User_Type__c = 'Community';        
        newCommunityApp.Name = 'HH Community Homeowner ';
        insert newCommunityApp;
        
        Community_Application__c newCommunityAppFema = new Community_Application__c();
        newCommunityAppFema.App_Permission_Set_Developer_Name__c = 'HH_Community_FEMA_User';
        newCommunityAppFema.Display_Name__c = 'HH Community FEMA';
        newCommunityAppFema.isActive__c = true;
        newCommunityAppFema.Parent__c = parentCommunity.Id;
		newCommunityAppFema.User_Type__c = 'FEMA';        
        newCommunityAppFema.Name = 'HH Community FEMA';
        insert newCommunityAppFema;
        
        Account newAccount = HH_TestHelper.getAccount(true);
        Contact cont = new Contact(Firstname='FirstName',Lastname='LastName', Email='email1213@gmail.com',Phone = '9652314586',AccountId = newAccount.Id, Entity_Change_Requested__c=true);
        insert cont;
        Contact cont2 = new Contact(Firstname='FirstName',Lastname='LastName', Email='email1213534@gmail.com',Phone = '9652314586',AccountId = newAccount.Id, Entity_Change_Requested__c=true);
        insert cont2;
        User_Registration__c   newUserRegistration = HH_TestHelper.getUserRegistration(false);
        newUserRegistration.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
        newUserRegistration.Community_Application__c = newCommunityApp.Id;
        newUserRegistration.Contact_Name__c = cont.Id;
        newUserRegistration.Email__c = 'email1213@gmail.com';
        newUserRegistration.Unique_Household_Number__c = '12376';
        newUserRegistration.County__c='Shasta, County of';
        newUserRegistration.User__c = UserInfo.getUserId();
        insert newUserRegistration;
        userRegistrationsList.add(newUserRegistration);
        
        User_Registration__c   newUserRegistrationFema = HH_TestHelper.getUserRegistration(false);
        newUserRegistrationFema.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
        newUserRegistrationFema.Community_Application__c = newCommunityApp.Id;
        newUserRegistrationFema.Contact_Name__c = cont2.Id;
        newUserRegistrationFema.Email__c = 'email1213@gmail.com';
        newUserRegistrationFema.Unique_Household_Number__c = '12376';
        //newUserRegistration.County__c='Shasta, County of';
        newUserRegistrationFema.User_Type__c = HH_CONSTANTS.UserRegistration_UserType_FEMA;
        newUserRegistrationFema.User__c = UserInfo.getUserId();
        insert newUserRegistrationFema;
        userRegistrationsList.add(newUserRegistrationFema);

        Test.startTest();
        HH_UserServiceAppHandler UserServiceAppHandler = new HH_UserServiceAppHandler();
        UserServiceAppHandler.handleApprove(userRegistrationsList);
        UserServiceAppHandler.handleReject(userRegistrationsList);

        Test.stopTest();
    }
    
   /* @isTest 
    public static void testInsertMembers() {
        
        List<User> User = new List<User>();
       
        User newUser = HH_TestHelper.createPortalUser();
        
        

        Test.startTest();
        HH_UserServiceAppHandler.insertMembers(newUser.Name);
       // System.assertEquals(newUserReg.Id, newUserReg.Id);
        Test.stopTest();
    }*/
}