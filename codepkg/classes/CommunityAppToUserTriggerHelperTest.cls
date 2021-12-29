@isTest(seeAllData=false)
public class CommunityAppToUserTriggerHelperTest {
    @isTest public static void testCommunityAppToUser() {
        test.startTest();
        Contact newContact = PHOS_TestHelper.getContact(true);
        User poratlUser = PHOS_TestHelper.getPortalUser(false);
        poratlUser.ContactId = newContact.Id;
        insert poratlUser;
        Community_Application__c comApp = PHOS_TestHelper.getCommunityApplication(true);
        Community_Application_to_User__c comAppToUSer = new Community_Application_to_User__c();
        comAppToUSer.Community_Application__c = null;
        comAppToUSer.Contact__c = newContact.Id;
        comAppToUSer.User__c = poratlUser.Id;
        insert comAppToUSer;
        comAppToUSer.isActive__c = false;
        update comAppToUSer;
        delete comAppToUSer;
        test.stopTest();
    }
}