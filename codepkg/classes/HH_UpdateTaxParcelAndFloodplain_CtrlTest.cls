@isTest
public class HH_UpdateTaxParcelAndFloodplain_CtrlTest {
	@isTest
    public static void testApplicationPreviewDetails() {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        //application.Applicant__c = c.Id;
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_New;
        insert application;
        //Application_Contact__c ac = insertApplicationContact(application.Id);
        //Funded_Program__c fp = insertFundedPrograms(application.Id);
        Document__c doc = new Document__c(Document_Type__c='Proof of Rental',Document_Name__c ='Test',HH_Application__c = application.Id);
        insert doc;
        String newApplicationJson = JSON.serialize(application);
        String userId = UserInfo.getUserId();
        Test.startTest();
		result= HH_UpdateTaxParcelAndFloodplain_Ctrl.updateTaxParcelAndFloodPlain(newApplicationJson,userId);
        System.assert(result != null);
        Test.stopTest();
    }
}