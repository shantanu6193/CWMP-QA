@IsTest
public class HH_UpdateContactDetailsCtrlTest {
    @IsTest
    public static void testContactDetails() {
        Map<String,Object> result1 = new Map<String,Object>();
        Map<String,Object> result2 = new Map<String,Object>();
        Map<String,Object> result3 = new Map<String,Object>();
        User u = HH_TestHelper.createPortalUser();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =:HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
        }
        System.runAs(u) {
            Test.startTest();
            result1 = HH_UpdateContactDetailsCtrl.showContactDetails();
            result2 = HH_UpdateContactDetailsCtrl.getContactDetails(u.ContactId);
            Contact cont = [SELECT Id,FirstName,LastName,Phone,Email FROM Contact WHERE Id=:u.ContactId];
            String contStr = JSON.serialize(cont);
            result3 = HH_UpdateContactDetailsCtrl.updateContactDetails(contStr);
            Test.stopTest();
        }
    }
    
}