@isTest public without sharing class HMA_SubApplicationRoleTest {
    @isTest public static void testExecuteClass() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        User portalUser = HMA_TestHelper.getPortalUser(false);
        portalUser.ContactId = portalCon.Id;
        insert portalUser;
        System.runAs(portalUser) {
            Map<String, Object> returnMap = new Map<String, Object>();
            Map<String, Object> returnMapElse = new Map<String, Object>();
            Map<String, Object> returnMapElse1 = new Map<String, Object>();
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id, Account_Name__c = portalCon.AccountId);
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
            HMA_SubApplicationRole obj = new HMA_SubApplicationRole();

            Test.startTest();
            returnMap = obj.executeClass(newApplication.Id, 'Contact_Roles');
            System.assert(returnMap.size() > 0);

            returnMapElse = obj.executeClass(newApplication.Id, 'Contact_Role_Confirmation_Table1');
            System.assert(returnMapElse.size() > 0);

            conRole.Role__c = 'FEMA Programmatic Analyst';
            update conRole;
            returnMapElse1 = obj.executeClass(newApplication.Id, 'FEMA_Request_For_Information');
            System.assert(returnMapElse1.size() > 0);
            Test.stopTest();
        }
    }
}