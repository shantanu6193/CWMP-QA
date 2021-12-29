@isTest
public without sharing class HMA_EditApplicationButtonTest {
    @isTest public static void testGetInitData() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        User portalUser = HMA_TestHelper.getPortalUser(false);
        portalUser.ContactId = portalCon.Id;
        insert portalUser;
        System.runAs(portalUser) {
            Map<String, Object> returnMapRequest  = new Map<String, Object>();
            Map<String, Object> returnMapRequest1  = new Map<String, Object>();
            Map<String, Object> returnMapRequest2  = new Map<String, Object>();

            Map<String, Object> returnMap  = new Map<String, Object>();
            Map<String, Object> returnMap1  = new Map<String, Object>();
            Map<String, Object> returnMap2  = new Map<String, Object>();
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            newApplication.Status__c = 'Draft';
            update newApplication;
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Application__c = newApplication.Id;
            conRole.Role__c = 'Viewer';
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;

            Test.startTest();
            returnMap = HMA_EditApplicationButton.getInitData(newApplication.Id);
            System.assert(returnMap.size() > 0);
            /**This is used for call method from  HMA_EditRequestCtrl 
            returnMapRequest = HMA_EditRequestCtrl.getInitData(newApplication.Id);
            System.assert(returnMapRequest.size() > 0);*/

        /** Used For Cover else Condition from HMA_EditApplicationButton.getInitData */
            newApplication.Status__c = 'FEMA Decision';
            update newApplication;
            conRole.Role__c = 'FEMA Viewer';
            update conRole;
            returnMap1 = HMA_EditApplicationButton.getInitData(newApplication.Id);
            System.assert(returnMap1.size() > 0);
            /**This is used for call method from  HMA_EditRequestCtrl 
            returnMapRequest1 = HMA_EditRequestCtrl.getInitData(newApplication.Id);
            System.assert(returnMapRequest1.size() > 0);*/

        /** Used For Cover else Condition from HMA_EditApplicationButton.getInitData */
            newApplication.Status__c = 'Withdrawn';
            update newApplication;
            returnMap2 = HMA_EditApplicationButton.getInitData(newApplication.Id);
            System.assert(returnMap2.size() > 0);
            /**This is used for call method from  HMA_EditRequestCtrl 
            returnMapRequest2 = HMA_EditRequestCtrl.getInitData(newApplication.Id);            
            System.assert(returnMapRequest2.size() > 0);*/
            Test.stopTest();
        }
    }
}