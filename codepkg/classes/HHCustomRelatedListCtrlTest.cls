@isTest
public class HHCustomRelatedListCtrlTest {
    @isTest
    public static void testEditAndDeleteApp() {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_New;
        insert application;
        Application_Contact__c ac = insertApplicationContact(application.Id);
        Test.startTest();
		result = HHCustomRelatedListCtrl.getRecordInfo(application.Id,'Name!=null','');
        System.assert(result != null);
        Test.stopTest();
    }
    private static Application_Contact__c insertApplicationContact(Id applicationId) {
        Contact c1 = HH_TestHelper.getContact(false);
        c1.FirstName = 'Jerry';
        c1.LastName = 'Jason';
        insert c1;
        Application_Contact__c ac = new Application_Contact__c();
        ac.Head_of_Household__c = 'Yes';
        ac.Annual_Income__c = 100;
        ac.Relationship_to_Homeowner__c = 'Self';
        ac.HH_Application__c = applicationId;
        ac.Contact__c = c1.Id;
        insert ac; 
        return ac;   
    }
}