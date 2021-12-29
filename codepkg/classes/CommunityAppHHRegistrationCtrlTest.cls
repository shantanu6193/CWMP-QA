@isTest
public class CommunityAppHHRegistrationCtrlTest {
    @isTest
    public static void testGetUserDetails() {
        Map<String,Object> result = new Map<String,Object>();
        User u = HH_TestHelper.createPortalUser();
          System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =:HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
        }
        System.runAs(u) {
            Test.startTest();
            result = CommunityAppHHRegistrationCtrl.getUserDetails();
            System.assert(result != null);
            Test.stopTest();
        }
    }
    @isTest
    public static void testProcessHHRequest() {
        Account acc = HH_TestHelper.getAccount(true);
        Contact con = new Contact(Firstname='FirstName', Lastname='LastName', Email='email@gmail.com', Phone = '9652314586',AccountId = acc.Id);
        Contact con2 = new Contact(Firstname='FirstName', Lastname='LastName', Email='email@gmail.com', Phone = '9652314586',AccountId = acc.Id);
        Community_Application__c commApp = new Community_Application__c();
        commApp.Name = HH_CONSTANTS.HH_Parent_Community_Application_Name;
        commApp.isActive__c = true;
        insert commApp;
        Test.startTest();
        try {
        CommunityAppHHRegistrationCtrl.processHHRequest(acc.Id,con.Id,'Community','San Diego, County Of');
        }
        catch (Exception e) { }

        try {
            CommunityAppHHRegistrationCtrl.processHHRequest(acc.Id, con2.Id,'FEMA','San Diego, County Of');
        }
        catch (Exception e) { }
        Test.stopTest();

    }
}