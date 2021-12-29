/**
 * Created by StackNexus Admin on 11-01-2021.
 */
@IsTest
public with sharing class AmendmentRequestTriggerHelperTest {
    @TestSetup private static void setup() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        Program__c prP = new Program__c(Name=ALS_CONSTANTS.Program_HMA, Master_Label_Program_Name__c = ALS_CONSTANTS.Program_HMA);
        insert prP;
        Program__c pr3 = new Program__c(Name='Test Program update', Parent_Program__c=prP.Id);
        insert pr3;
        Incident__c inc = new Incident__c(Name = 'Test Incident FP', Declaration_Number__c = '4456',
                State_Small_Project_Threshold__c=200, Federal_Small_Project_Threshold__c=200);
        insert inc;
        Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP ', Program_Name__c=pr3.Id, Incident_Name__c=inc.Id);
        insert fp2;
        Account account=new Account(Name ='Test Account', DUNS__c = '1234', Sub_Recipient_FIPS__c='1234', Email_Address__c='test@gmail.com',
                Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate);
        insert account;

        List<Project__c> projectList = new List<Project__c>();
        Project__c project1 =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Name = 'Project Abc 1', Project_Number__c = '1-0',
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                End_Date__c=EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c=10,
                FEMA_Share__c =80, Total_Project_Award__c=1000, StateAdmin__c = 0, Federal_Retention__c = 10, State_Retention__c = 10,
                Federal_Project_Award__c = 800, State_Project_Award__c = 100);
        projectList.add(project1);
        Project__c project2 =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Name = 'Project Abc 2', Project_Number__c = '2-0',
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                End_Date__c=EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c=10,
                FEMA_Share__c =80, Total_Project_Award__c=1000, StateAdmin__c = 0, Federal_Retention__c = 10, State_Retention__c = 10);
        projectList.add(project2);
        Project__c project3 =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Name = 'Project Abc 3', Project_Number__c = '3-0',
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                End_Date__c=EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c=10,
                FEMA_Share__c =80, Total_Project_Award__c=1000, StateAdmin__c = 0, Federal_Retention__c = 10, State_Retention__c = 10);
        projectList.add(project3);
        Project__c project4 =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Name = 'Project Abc 4',  Project_Number__c = '4-0',
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                End_Date__c=EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c=10,
                FEMA_Share__c =80, Total_Project_Award__c=1000, StateAdmin__c = 0, Federal_Retention__c = 10, State_Retention__c = 10);
        projectList.add(project4);
        Project__c project5 =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Name = 'Project Abc 5', Project_Number__c = '5-0',
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                End_Date__c=EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c=10,
                FEMA_Share__c =80, Total_Project_Award__c=1000, StateAdmin__c = 0, Federal_Retention__c = 10, State_Retention__c = 10);
        projectList.add(project5);
        Project__c project6 =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Name = 'Project Abc 6', Project_Number__c = '6-0',
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                End_Date__c=EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c=10,
                FEMA_Share__c =80, Total_Project_Award__c=1000, StateAdmin__c = 0, Federal_Retention__c = 10, State_Retention__c = 10);
        projectList.add(project6);
        insert projectList;

        List<Award__c> initialAwardToInsertList = new List<Award__c>();
        Award__c award6 = new Award__c(Project__c = projectList[5].Id, Supplement_Award__c = projectList[5].Total_Project_Award__c,
                AmountObligated__c = projectList[5].Total_Project_Award__c, FEMA_Share__c = projectList[5].FEMA_Share__c,
                State_Share__c = projectList[5].State_Share__c, State_Admin__c = projectList[5].StateAdmin__c,
                Federal_Retention__c = projectList[5].Federal_Retention__c, State_Retention__c = projectList[5].State_Retention__c,
                Federal_Project_Amount__c = 800, State_Project_Amount__c = 100, State_Admin_Amount__c = 0,
                AwardStartDate__c = startDate, AwardEndDate__c = EndDate);
        initialAwardToInsertList.add(award6);
        insert initialAwardToInsertList;

        List<Payment_Request__c> prList = new List<Payment_Request__c>();
        Payment_Request__c pRequest1 = new Payment_Request__c(PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement,
                Project__c = projectList[0].Id, ExpenditurestoDate__c = 1500, ReimbursementStartDate__c = startDate,
                ReimbursementEndDate__c = EndDate, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Stage__c = ALS_CONSTANTS.PR_Stage_New);
        insert pRequest1;
    }
    @IsTest
	public static void testAmendmentRequest() {
        Date startDate = System.today()+2;
        Date EndDate = System.today()+11;
        Test.startTest();
        List<Project__c> projectList = [SELECT Id, Name, Total_Project_Award__c, State_Share__c,FEMA_Share__c, Start_Date__c, End_Date__c,
                StateAdmin__c, Federal_Project_Award__c, State_Project_Award__c, TotalProjectStateAdminShare__c FROM Project__c];

        Amendment_Request__c amendmentRequest11 =new Amendment_Request__c(SupplementAward__c = 2000, AmendmentType__c=ALS_CONSTANTS.Amendment_Type_MoneyExtension);
        try {
            insert amendmentRequest11;
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.REAL_Amendment_ProjectRequired));
        }
        List<Amendment_Request__c> amendmentList = new List<Amendment_Request__c>();
        amendmentRequest11.Project__c = projectList[0].Id;
        amendmentRequest11.FDSR__c = '1-1';
        amendmentRequest11.NewObligatedAmount__c = 3000;
        amendmentList.add(amendmentRequest11);
        Amendment_Request__c amendmentRequest12 =new Amendment_Request__c(TimeExtensionEndDate__c=EndDate,
                TimeExtensionStartDate__c=startDate, AmendmentType__c=ALS_CONSTANTS.Amendment_Type_TimeExtension,Project__c=projectList[1].Id,
                Reviewed_By_Manager__c = ALS_CONSTANTS.Picklist_Yes);
        amendmentList.add(amendmentRequest12);
        Amendment_Request__c amendmentRequest13 =new Amendment_Request__c(AmendmentType__c=ALS_CONSTANTS.Amendment_Type_PercentageChange,
                Project__c=projectList[2].Id, FEMA_Share__c = 80, State_Share__c =20);
        amendmentList.add(amendmentRequest13);
        Amendment_Request__c amendmentRequest14 =new Amendment_Request__c(AmendmentType__c=ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange,
                Project__c=projectList[3].Id, FEMA_Share__c = 80, State_Share__c =25, SupplementAward__c = 2000, NewObligatedAmount__c = 3000);
        amendmentList.add(amendmentRequest14);
        Amendment_Request__c amendmentRequest15 =new Amendment_Request__c(AmendmentType__c=ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension,
                Project__c=projectList[4].Id, TimeExtensionEndDate__c=EndDate, TimeExtensionStartDate__c=startDate, SupplementAward__c = 2000,
                NewObligatedAmount__c = 3000);
        amendmentList.add(amendmentRequest15);
        Amendment_Request__c amendmentRequest16 =new Amendment_Request__c(AmendmentType__c=ALS_CONSTANTS.Amendment_Type_MoneyExtension,
                Project__c=projectList[5].Id, SupplementAward__c = 2000, NewObligatedAmount__c = 3000, FDSR__c = '6-1');
        amendmentList.add(amendmentRequest16);
        insert amendmentList;
        Amendment_Request__c amendmentRequest17 =new Amendment_Request__c(TimeExtensionEndDate__c=EndDate,
                TimeExtensionStartDate__c=startDate, AmendmentType__c=ALS_CONSTANTS.Amendment_Type_TimeExtension,
                Project__c=projectList[5].Id);
        insert amendmentRequest17;

        List<Award__c> awardOfAmendmentList = new List<Award__c>();
        Award__c award11 =new Award__c(Project__c=projectList[0].Id, Amendment_Request__c = amendmentList[0].Id,
                Status__c=ALS_CONSTANTS.Award_Status_Active, Supplement_Award__c = amendmentList[0].SupplementAward__c,
                AmountObligated__c = amendmentList[0].NewObligatedAmount__c, AwardStartDate__c = projectList[0].Start_Date__c,
                AwardEndDate__c = projectList[0].End_Date__c, FEMA_Share__c = projectList[0].FEMA_Share__c,
                State_Share__c = projectList[0].State_Share__c, State_Admin__c = 0,
                Federal_Project_Amount__c = 1600, State_Project_Amount__c = 200, State_Admin_Amount__c = 0,
                Federal_Supplement_Amount__c = 800, State_Supplement_Amount__c = 200, State_Admin_Supplement_Amount__c = 0);
        awardOfAmendmentList.add(award11);
        Award__c award12 =new Award__c(Project__c=projectList[1].Id, Amendment_Request__c = amendmentList[1].Id,
                Status__c=ALS_CONSTANTS.Award_Status_Active, AwardEndDate__c = amendmentList[1].TimeExtensionEndDate__c,
                AwardStartDate__c=amendmentList[1].TimeExtensionStartDate__c , AmountObligated__c = 1000,
                FEMA_Share__c = projectList[1].FEMA_Share__c, State_Share__c = projectList[1].State_Share__c,
                State_Admin__c = 0, Federal_Project_Amount__c = 800, State_Project_Amount__c = 100,
                State_Admin_Amount__c = 0, Federal_Supplement_Amount__c = 0, State_Supplement_Amount__c = 0,
                State_Admin_Supplement_Amount__c = 0);
        awardOfAmendmentList.add(award12);
        Award__c award13 =new Award__c(Project__c=projectList[2].Id, Amendment_Request__c = amendmentList[2].Id,
                Status__c=ALS_CONSTANTS.Award_Status_Active, AmountObligated__c = 1000,
                AwardStartDate__c = projectList[2].Start_Date__c, AwardEndDate__c = projectList[2].End_Date__c,
                FEMA_Share__c = amendmentList[2].FEMA_Share__c, State_Share__c = amendmentList[2].State_Share__c,
                State_Admin__c = 0, Federal_Project_Amount__c = 800, State_Project_Amount__c = 200,
                State_Admin_Amount__c = 0, Federal_Supplement_Amount__c = 0, State_Supplement_Amount__c = 100,
                State_Admin_Supplement_Amount__c = 0);
        awardOfAmendmentList.add(award13);
        Award__c award16 =new Award__c(Project__c=projectList[5].Id, Amendment_Request__c = amendmentList[5].Id,
                Status__c=ALS_CONSTANTS.Award_Status_Inactive, AmountObligated__c = amendmentList[5].NewObligatedAmount__c,
                AwardStartDate__c = projectList[5].Start_Date__c, AwardEndDate__c = projectList[5].End_Date__c,
                FEMA_Share__c = projectList[5].FEMA_Share__c, State_Share__c = projectList[5].State_Share__c,
                State_Admin__c = projectList[5].StateAdmin__c, Federal_Project_Amount__c = 2400, State_Project_Amount__c = 300,
                State_Admin_Amount__c = 0, Federal_Supplement_Amount__c = 1600, State_Supplement_Amount__c = 200,
                State_Admin_Supplement_Amount__c = 0);
        awardOfAmendmentList.add(award16);
        Award__c award17 =new Award__c(Project__c=projectList[5].Id, Amendment_Request__c = amendmentList[5].Id,
                Status__c=ALS_CONSTANTS.Award_Status_Active, AmountObligated__c = 3000,
                AwardStartDate__c = startDate, AwardEndDate__c = EndDate,
                FEMA_Share__c = projectList[5].FEMA_Share__c, State_Share__c = projectList[5].State_Share__c,
                State_Admin__c = projectList[5].StateAdmin__c, Federal_Project_Amount__c = 2400, State_Project_Amount__c = 300,
                State_Admin_Amount__c = 0, Federal_Supplement_Amount__c = 0, State_Supplement_Amount__c = 0,
                State_Admin_Supplement_Amount__c = 0);
        awardOfAmendmentList.add(award17);
        insert awardOfAmendmentList;

        amendmentList[0].SupplementAward__c = 3000;
        amendmentList[0].FDSR__c = '1-2';
        amendmentList[0].Reviewed_By_Manager__c = ALS_CONSTANTS.Picklist_No;

        amendmentList[1].TimeExtensionStartDate__c= startDate;
        amendmentList[1].TimeExtensionEndDate__c=EndDate;

        amendmentList[2].FEMA_Share__c = 75;
        amendmentList[2].State_Share__c = 25;
        //amendmentList[2].FDSR__c = '3-1';

        amendmentList[3].SupplementAward__c = 3000;
        amendmentList[3].NewObligatedAmount__c = 4000;

        amendmentList[4].SupplementAward__c = 3000;
        amendmentList[4].NewObligatedAmount__c = 4000;

        /*amendmentList[5].AmendmentType__c = ALS_CONSTANTS.Amendment_Type_TimeExtension;
        amendmentList[5].TimeExtensionEndDate__c = EndDate;
        amendmentList[5].TimeExtensionStartDate__c = startDate;
        amendmentList[5].SupplementAward__c = 0;
        amendmentList[5].NewObligatedAmount__c = 0;*/

        update amendmentList;
        //delete amendmentList[5];
        Test.stopTest();
    }
}