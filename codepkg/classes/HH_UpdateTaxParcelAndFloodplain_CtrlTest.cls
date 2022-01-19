@isTest
public class HH_UpdateTaxParcelAndFloodplain_CtrlTest {
    @testSetup
    public static void testSetUp() {
        User caloesUser = HH_TestHelper.createCaloesUser();  
        User communityUser = new User();
        System.runAs(caloesUser) {
        	communityUser = HH_TestHelper.createCaloesPortalUser('testcommunityuser2856348@gmail.com');
            
        }
         
        PermissionSet permissionSet1 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUser.Id, PermissionSetId = permissionSet1.Id);
    }
    
	@isTest
    public static void testApplicationPreviewDetails() {
        User caloesUser = [SELECT Id, isActive from User Where username != 'testcommunityuser2856348@gmail.com' LIMIT 1];
        User communityUser = [SELECT Id from User Where username = 'testcommunityuser2856348@gmail.com' LIMIT 1];
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        //application.Applicant__c = c.Id;
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_New;
        application.Homeowner_contribution_check_payment__c = HH_CONSTANTS.Picklist_Yes;
        insert application;
        
        HH_Application__c application2 = new HH_Application__c();
        application2.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application2.Status__c = HH_CONSTANTS.HHApplication_Status_New; 
        insert application2;
        
        //Application_Contact__c ac = insertApplicationContact(application.Id);
        //Funded_Program__c fp = insertFundedPrograms(application.Id);
        Document__c doc = new Document__c(Document_Type__c='Proof of Rental',Document_Name__c ='Test',HH_Application__c = application.Id);
        insert doc;
        String newApplicationJson = JSON.serialize(application);
        String newApplicationJson2 = JSON.serialize(application2);
        String userId = UserInfo.getUserId();
        Test.startTest();
        System.runAs(caloesUser) {
		result= HH_UpdateTaxParcelAndFloodplain_Ctrl.updateTaxParcelAndFloodPlain(newApplicationJson,userId);
        System.assert(result != null);
            
            userId = UserInfo.getUserId();
            result= HH_UpdateTaxParcelAndFloodplain_Ctrl.updateTaxParcelAndFloodPlain(newApplicationJson2,userId);
        	System.assert(result != null);
            
            result = HH_UpdateTaxParcelAndFloodplain_Ctrl.getUserPermissionForComponent(caloesUser.Id);
        	System.assert(result != null); 
        }
        
        System.runAs(communityUser) {
            userId = UserInfo.getUserId();
           	result= HH_UpdateTaxParcelAndFloodplain_Ctrl.updateTaxParcelAndFloodPlain(newApplicationJson2,userId);
        	System.assert(result != null); 
            
            result = HH_UpdateTaxParcelAndFloodplain_Ctrl.getUserPermissionForComponent(communityUser.Id);
        	System.assert(result != null); 
        }

        Test.stopTest();
    }
}