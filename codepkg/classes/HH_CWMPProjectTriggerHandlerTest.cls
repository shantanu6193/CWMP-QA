@Istest
public without sharing class HH_CWMPProjectTriggerHandlerTest {
    @IsTest
    public static void testHH_CWMPProjectTriggerHandler() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(AccountId = acc.Id, FirstName = 'FirstName', LastName = 'LastName', Email = 'firstnamelastname3463563@gmail.com', Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Homeowner);
        insert con;

        HH_Application__c applicationRecord = new HH_Application__c(Applicant__c = con.Id, Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft, Status__c = HH_CONSTANTS.HHApplication_Status_New, County__c = HH_CONSTANTS.HHApplication_County_SanDiego);
        insert applicationRecord;

        CWMP_Project__c projectRecord = new CWMP_Project__c(CWMP_Application__c = applicationRecord.Id);
        insert projectRecord;
        
        projectRecord.Project_Stage__c = '';
        update projectRecord;
        
        projectRecord.Project_Stage__c = HH_CONSTANTS.CWMPProject_Stage_SiteWork;
        update projectRecord;
        
		projectRecord.Project_Stage__c = HH_CONSTANTS.CWMPProject_Stage_PostAssessment;
        update projectRecord;
        
        projectRecord.Project_Stage__c = HH_CONSTANTS.CWMPProject_Stage_ProjectComplete;
        projectRecord.Assessor_Email__c = 'test@gmail.com';
        update projectRecord;
        
        projectRecord.Project_Stage__c = HH_CONSTANTS.CWMPProject_Stage_NewProjectCreated;
        update projectRecord;
    }
}