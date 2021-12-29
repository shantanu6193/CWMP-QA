/**
 * Created by StackNexus Admin on 11-01-2021.
 */
@IsTest
public with sharing class ALS_TransmittalUtilityTest {
    @TestSetup private static void setup() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        //Profile and User Test Data...
        Profile pf= [SELECT Id FROM Profile WHERE Name='System Administrator'];
    String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
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
        //Program Record Test Data....
    Program__c prP = new Program__c(Name='Test Program Parent');
    insert prP;

        List<Program__c> childProgramList = new List<Program__c>();
        Program__c prC = new Program__c(Name='Test Program Child', Parent_Program__c=prP.Id);
        childProgramList.add(prC);
        insert childProgramList;

        //Incident Record Test Data...
    Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
    insert inc;

        //Funding Opp Test Data...
        Funding_Opportunity__c fp1=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=childProgramList[0].Id,Incident_Name__c=inc.Id, Owner__c = uu.Id);
        insert fp1;
        ServiceLocation__c  serviceLocation = new ServiceLocation__c(Name = 'SL-001');
        insert serviceLocation;
        FundingOppServiceLocationJunction__c foSlJunction = new FundingOppServiceLocationJunction__c(Funding_Opportunity__c = fp1.Id, Service_Location__c = serviceLocation.Id);
        insert foSlJunction;

        //Account Record Test Data...
        Account acc1 = new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate );
        insert acc1;

        Incident_Subrecipient_Stage__c stage = new Incident_Subrecipient_Stage__c(Account__c = acc1.Id, Incident__c = inc.Id, Stage__c = ALS_CONSTANTS.PR_Stage_New);
        insert stage;

        // Project Record test Data ...
        List<Project__c> projectList = new List<Project__c>();
        Project__c pr1=new Project__c(Name='Test Project 1',StateAdmin__c=0, Start_Date__c = startDate, End_Date__c =EndDate,
                Total_Project_Award__c=1000, Funding_Opportunity_Name__c = fp1.Id, FEMA_Share__c = 75,
                PaytoStateAdmin__c =ALS_CONSTANTS.Picklist_Yes,Federal_Retention__c = 10, State_Share__c = 18.75,
                State_Retention__c = 10,  Obligating_Sub_Recipient__c = acc1.Id, Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,
                FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState);
        projectList.add(pr1);
        Project__c pr2 = new Project__c(Name = 'Test Project 2',Funding_Opportunity_Name__c = fp1.Id,Total_Project_Award__c=1000,
                Start_Date__c = startDate, End_Date__c = EndDate, Obligating_Sub_Recipient__c = acc1.Id, FEMA_Share__c = 75,
                State_Share__c = 18.75,PaytoStateAdmin__c =ALS_CONSTANTS.Picklist_No, Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,
                FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState);
        projectList.add(pr2);
        insert projectList;

        List<Payment_Request__c> prlist = new List<Payment_Request__c>();
        Payment_Request__c payRequest1 =new Payment_Request__c(Project__c=projectList[0].Id,Stage__c = ALS_CONSTANTS.PR_Stage_New,
                ExpenditurestoDate__c =1000, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = 700, ApprovedStatePaymentAmount__c = 150);
        prlist.add(payRequest1);
        Payment_Request__c payRequest2 =new Payment_Request__c(Project__c=projectList[1].Id,Stage__c = ALS_CONSTANTS.PR_Stage_New,
                ExpenditurestoDate__c =1000, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = 700, ApprovedStatePaymentAmount__c = 150);
        prlist.add(payRequest2);
        Payment_Request__c payRequest3 =new Payment_Request__c(Project__c=projectList[1].Id,Stage__c = ALS_CONSTANTS.PR_Stage_New,
                ExpenditurestoDate__c =0, PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Offset,
                PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = -200, ApprovedStatePaymentAmount__c = -50);
        prlist.add(payRequest3);
        insert prlist;
    }

    @IsTest
    public static void testALS_TransmittalUtility() {
        Map<Id, Payment_Request__c> prIdToPrMap = new Map<Id, Payment_Request__c>([SELECT Id, Name, Project__c, Stage__c, PaymentDelivery__c, ExpenditurestoDate__c,
                ApprovedStatePaymentAmount__c, ApprovedFederalPaymentAmount__c  FROM Payment_Request__c]);
        Map<Id, Incident_Subrecipient_Stage__c> summaryIdToSummaryMap = new Map<Id, Incident_Subrecipient_Stage__c>([SELECT Id, Name,
                    Account__c, Incident__c, Available_Federal_Amount__c, Available_State_Amount__c, Available_State_Admin_Amount__c
                FROM Incident_Subrecipient_Stage__c]);
        Test.startTest();
    List<Id> listIds =new List<Id>();
        listIds.addAll(prIdToPrMap.keySet());
        listIds.addAll(summaryIdToSummaryMap.keySet());
        ALS_TransmittalUtiity.createTransmittalRecord(listIds);
        List<Transmittal__c> trList = [SELECT Id, Name, Stage__c FROM Transmittal__c WHERE PaymentRequest__c IN : listIds];
        ALS_TransmittalUtiity.submitForApproval(trList);
        Test.stopTest();
    }
}