@isTest(seeAllData=false)
public with sharing class CommunityHomePageCtrlTest {
    @isTest 
    public static void testGetAllApplications() {
        Contact portalContact = PHOS_TestHelper.getContact(true);
        User portalUser = PHOS_TestHelper.getPortalUser(false);
        portalUser.ContactId = portalContact.Id;
        insert portalUser;
        System.runAs(portalUser) {
            Map<String, Object> returnMap = new Map<String, Object>();
            Community_Application__c newCommunityApplication = HMA_TestHelper.getCommunityApplication(true);
            Community_Application_to_User__c newCommunityApplicationtoUser = HMA_TestHelper.getCommunityApplicationToUser(false);
            newCommunityApplicationtoUser.User__c = portalUser.Id;
            newCommunityApplicationtoUser.Community_Application__c = newCommunityApplication.Id;
            insert newCommunityApplicationtoUser;

            Test.startTest();
            returnMap = CommunityHomePageCtrl.getAllApplications();
            System.assert(returnMap.size()>0);
            Test.stopTest();
        }
    }
}