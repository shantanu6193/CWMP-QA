@isTest
public with sharing class HMA_FEMAAppDetailsCtrlTest {
    @isTest
    public static void testSaveApplication() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'FEMA Review';
        app.Status_Reason__c = 'Submitted to FEMA';
        insert app;
        Test.startTest();
        Map<String, Object> returnMap = HMA_FEMAApplicationDetailsCtrl.saveApplication(JSON.serialize(app));
        System.assert(returnMap.size()>0);
        Test.stopTest();
    }

    @isTest
    public static void testGetCurrentUserContactRole() {
        User user = HMA_TestHelper.getPortalUserHMA(false);
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        Contact contact = HMA_TestHelper.getPortalContact(true);
        user.ContactId = contact.Id;
        user.IsActive = true;
        insert user;
        System.debug('User in FEma---'+user.Id);
        Id uId = user.Id;
        String userStringId = String.valueOf(uId);
        System.debug('User in FEma String---'+userStringId);
        Contact_Role__c contactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, app, contact.Id, 'Responsible Representative');
        System.runAs(user) {
            Test.startTest();
            Map<String, Object> returnMap = HMA_FEMAApplicationDetailsCtrl.getCurrentUserContactRole(app.Id);
            System.assert(returnMap.size() > 0);
            Test.stopTest();
        }
}
}