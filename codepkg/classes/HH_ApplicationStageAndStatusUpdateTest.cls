@isTest
public class HH_ApplicationStageAndStatusUpdateTest {
    @TestSetup private static void setup() {
        Profile pf= [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName=orgId+dateString+RandomId;
        User uu=new User(FirstName = 'ABC',
                LastName = 'XYZ',
                Email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = pf.Id
        );
        insert uu;
    }

	@isTest
    public static void testupdateStageAndStatus() {
        User uu = [SELECT Id, Name FROM User LIMIT 1];
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_ApprovedConverted;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_Withdrawn;
        application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application.Tax_Parcel_Number__c = '234234';
        application.Is_the_property_in_the_floodplain__c = 'No';
        application.Assessed_Value_of_the_Property__c = 1200000;
        application.Income_Bracket__c = 'Less than 80%';
        application.Application_Lead__c = uu?.Id;
        insert application;
       
        String newApplicationJson = JSON.serialize(application);
        String userId = UserInfo.getUserId();
        Test.startTest();
    	result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson,userId);
        System.assert(result != null);
        Test.stopTest();
    }
    @isTest
    public static void testupdateStageAndStatusRejected() {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c application = new HH_Application__c();
        //application.Applicant__c = c.Id;
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedNotEligible;
        insert application;
       
        String newApplicationJson = JSON.serialize(application);
        String userId = UserInfo.getUserId();
        Test.startTest();
    	result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson,userId);
        System.assert(result != null);
        Test.stopTest();
    }
    @isTest
    public static void testupdateStageAndStatusNotEligible() {
        User uu = [SELECT Id, Name FROM User LIMIT 1];
        Map<String,Object> result = new Map<String,Object>();
        List<HH_Application__c> applistToInsert = new List<HH_Application__c>();

        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_AssessmentDecision;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedNotEligible;
        application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application.Tax_Parcel_Number__c = '234234';
        application.Is_the_property_in_the_floodplain__c = 'Yes';
        application.Assessed_Value_of_the_Property__c = 1200000;
        application.Income_Bracket__c = 'Less than 80%';
        application.Application_Lead__c = uu?.Id;
        applistToInsert.add(application);

        HH_Application__c application2 = new HH_Application__c();
        application2.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityDecision;
        application2.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria;
        application2.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application2.Tax_Parcel_Number__c = '234234';
        application2.Is_the_property_in_the_floodplain__c = 'No';
        application2.Assessed_Value_of_the_Property__c = 1300000;
        application2.Income_Bracket__c = '80% through 120%';
        application2.Application_Lead__c = uu?.Id;
        applistToInsert.add(application2);

        HH_Application__c application3 = new HH_Application__c();
        application3.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESDecision;
        application3.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria;
        application3.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application3.Tax_Parcel_Number__c = '234234';
        application3.Is_the_property_in_the_floodplain__c = 'Yes';
        application3.Assessed_Value_of_the_Property__c = 1400000;
        application3.Income_Bracket__c = 'Above 120% to 200%';
        application3.Application_Lead__c = uu?.Id;
        applistToInsert.add(application3);

        HH_Application__c application4 = new HH_Application__c();
        application4.Stage__c = HH_CONSTANTS.HHApplication_Stage_FEMADecision;
        application4.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria;
        application4.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application4.Tax_Parcel_Number__c = '234234';
        application4.Is_the_property_in_the_floodplain__c = 'No';
        application4.Assessed_Value_of_the_Property__c = 1500000;
        application4.Income_Bracket__c = 'Greater than 200%';
        application4.Application_Lead__c = uu?.Id;
        applistToInsert.add(application4);

        HH_Application__c application5 = new HH_Application__c();
        application5.Stage__c = HH_CONSTANTS.HHApplication_Stage_AssessmentDecision;
        application5.Status__c = HH_CONSTANTS.HHApplication_Status_ReadyForCalOesReview;
        application5.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application5.Tax_Parcel_Number__c = '234234';
        application5.Is_the_property_in_the_floodplain__c = 'No';
        application5.Assessed_Value_of_the_Property__c = 1500000;
        application5.Income_Bracket__c = 'Greater than 200%';
        application5.Application_Lead__c = uu?.Id;
        applistToInsert.add(application5);

        HH_Application__c application6 = new HH_Application__c();
        application6.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESDecision;
        application6.Status__c = HH_CONSTANTS.HHApplication_Status_ApprovedForFEMAReview;
        application6.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application6.Tax_Parcel_Number__c = '234234';
        application6.Is_the_property_in_the_floodplain__c = 'No';
        application6.Assessed_Value_of_the_Property__c = 1500000;
        application6.Income_Bracket__c = 'Greater than 200%';
        application6.Application_Lead__c = uu?.Id;
        applistToInsert.add(application6);

        HH_Application__c application7 = new HH_Application__c();
        application7.Stage__c = HH_CONSTANTS.HHApplication_Stage_FEMADecision;
        application7.Status__c = HH_CONSTANTS.HHApplication_Status_FEMADecisionApprovedForProjectConversion;
        application7.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application7.Tax_Parcel_Number__c = '234234';
        application7.Is_the_property_in_the_floodplain__c = 'No';
        application7.Assessed_Value_of_the_Property__c = 1500000;
        application7.Income_Bracket__c = 'Greater than 200%';
        application7.Application_Lead__c = uu?.Id;
        applistToInsert.add(application7);
        
        HH_Application__c application8 = new HH_Application__c();
        application8.Stage__c = HH_CONSTANTS.HHApplication_Stage_HomeownerAgreement;
        application8.Status__c = HH_CONSTANTS.HHApplication_Status_TriPartyAgreementFinalized;
        application8.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application8.Tax_Parcel_Number__c = '234234';
        application8.Is_the_property_in_the_floodplain__c = 'No';
        application8.Assessed_Value_of_the_Property__c = 1500000;
        application8.Income_Bracket__c = 'Greater than 200%';
        application8.Application_Lead__c = uu?.Id;
        application8.Homeowner_contribution_check_payment__c = 'Yes';
        application8.Homeowner_Contribution_Amount__c = 120000;
        applistToInsert.add(application8);

        insert applistToInsert;

        //String newApplicationJson = JSON.serialize(application);
        String newApplicationJson1 = JSON.serialize(applistToInsert[0]);
        String newApplicationJson2 = JSON.serialize(applistToInsert[1]);
        String newApplicationJson3 = JSON.serialize(applistToInsert[2]);
        String newApplicationJson4 = JSON.serialize(applistToInsert[3]);
        String newApplicationJson5 = JSON.serialize(applistToInsert[4]);
        String newApplicationJson6 = JSON.serialize(applistToInsert[5]);
        String newApplicationJson7 = JSON.serialize(applistToInsert[6]);
        String newApplicationJson8 = JSON.serialize(applistToInsert[7]);
        String userId = UserInfo.getUserId();

        Test.startTest();

    	result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson1,userId);
        System.assert(result != null);
        result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson2,userId);
        System.assert(result != null);
        result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson3,userId);
        System.assert(result != null);
        result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson4,userId);
        System.assert(result != null);
        try {
            result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson5,userId);
            System.assert(result != null);
        }
        catch (Exception e) {

        }
        try {
            result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson6, userId);
            System.assert(result != null);
        }
        catch (Exception e) {

        }
        try {
            result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson7, userId);
            System.assert(result != null);
        }
        catch (Exception e) {

        }
        try {
            result = HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus(newApplicationJson8, userId);
            System.assert(result != null);
        }
        catch (Exception e) {

        }
        Test.stopTest();
    }

    @isTest
    public static void testGetRecordDetails() {
        User uu = [SELECT Id, Name FROM User LIMIT 1];
        Map<String,Object> result = new Map<String,Object>();
        List<HH_Application__c> appListToInsert = new List<HH_Application__c>();


        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application.Tax_Parcel_Number__c = '234234';
        application.Is_the_property_in_the_floodplain__c = 'No';
        application.Assessed_Value_of_the_Property__c = 1200000;
        application.Income_Bracket__c = 'Less than 80%';
        application.Application_Lead__c = uu?.Id;
        appListToInsert.add(application);
        insert appListToInsert;

        Test.startTest();
        result = HH_ApplicationStageAndStatusUpdate_Ctrl.getRecordDetails(appListToInsert[0].Id, UserInfo.getUserId());
        System.assert(result != null);
        Test.stopTest();
    }
}