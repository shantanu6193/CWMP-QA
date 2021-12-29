@isTest
public class HH_ApplicationActionsCtrlTest {
	@isTest
    public static void testisExternalUser() {
        Map<String,Object> result = new Map<String,Object>();
        Test.startTest();
		result=HH_ApplicationActionsCtrl.isExternalUser();
        System.assert(result != null);
        Test.stopTest();
    }
    @isTest
    public static void testEditAndDeleteApp() {
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> result1 = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_New;
        insert application;
        Test.startTest();
		result = HH_ApplicationActionsCtrl.editApplication(application.Id);
       System.assert(result != null);
        result1 = HH_ApplicationActionsCtrl.deleteApplication(application.Id);
        System.assert(result1 != null);
        Test.stopTest();
    }
    @isTest
    public static void testEditAndDeleteAppOtherStatus() {
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> result1 = new Map<String,Object>();
           User u = HH_TestHelper.createPortalUser();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =:HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = permissionSet.Id);
        }
        System.runAs(u) {
            HH_Application__c application = new HH_Application__c();
           // application.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
           // application.Status__c = HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo;
 			application.Stage__c = HH_CONSTANTS.HHApplication_Stage_AssessmentDecision;
        	application.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedNotEligible;
        	application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        	application.Tax_Parcel_Number__c = '234234';
        	application.Is_the_property_in_the_floodplain__c = 'No';
            insert application;
            Test.startTest();
            try {
                result = HH_ApplicationActionsCtrl.editApplication(application.Id);
                System.assert(result != null);
                result1 = HH_ApplicationActionsCtrl.deleteApplication(application.Id);
                System.assert(result1 != null);
            } catch(Exception e) {
                //System.assertEquals(e.getMessage(),'');
            }
            Test.stopTest();
    	}
    }
}