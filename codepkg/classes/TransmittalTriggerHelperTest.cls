/**
 * Created by Ricky on 02-06-2021.
 */
@IsTest
public with sharing class TransmittalTriggerHelperTest {
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
        Payment_Request__c payRequest1 =new Payment_Request__c(Project__c=projectList[0].Id,Stage__c = ALS_CONSTANTS.PR_Stage_InReview,
                ExpenditurestoDate__c =1000, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = 700, ApprovedStatePaymentAmount__c = 150);
        prlist.add(payRequest1);
        Payment_Request__c payRequest2 =new Payment_Request__c(Project__c=projectList[1].Id,Stage__c = ALS_CONSTANTS.PR_Stage_InReview,
                ExpenditurestoDate__c =1000, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = 700, ApprovedStatePaymentAmount__c = 150);
        prlist.add(payRequest2);
        Payment_Request__c payRequest3 =new Payment_Request__c(Project__c=projectList[0].Id,Stage__c = ALS_CONSTANTS.PR_Stage_PaymentProcessing,
                ExpenditurestoDate__c =0, PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Offset,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = -100);
        prlist.add(payRequest3);
        Payment_Request__c payRequest4 =new Payment_Request__c(Project__c=projectList[1].Id,Stage__c = ALS_CONSTANTS.PR_Stage_PaymentProcessing,
                ExpenditurestoDate__c =0, PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Offset,
                Service_Location__c = serviceLocation.Id, ApprovedFederalPaymentAmount__c = 100);
        prlist.add(payRequest4);
        insert prlist;
        List<Id> prIdList = new List<Id>();
        for (Payment_Request__c pr : prlist) {
            prIdList.add(pr.Id);
        }
        RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
        lockUnlock.lockRecord(prIdList);
    }

    /*@IsTest
    public static void testTransmittalTriggerHelper() {
        List<Payment_Request__c> prList = [SELECT Id, Name, ExpenditurestoDate__c, PaymentType__c, PaymentDelivery__c, Project__c, ReimbursementStartDate__c, ReimbursementEndDate__c, ApprovedStatePaymentAmount__c, ApprovedFederalPaymentAmount__c FROM Payment_Request__c];

        Transmittal__c tr6 = new Transmittal__c(PaymentRequest__c = prList[2].Id, TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal,
                PaymentType__c = ALS_CONSTANTS.PR_PaymentType_Offset, ApprovedAmount__c = -100,
                Stage__c = ALS_CONSTANTS.Transmittal_Stage_InReview);
        insert tr6;

        List<Transmittal__c> transmittalList1 = new List<Transmittal__c>();
        Transmittal__c tr1 = new Transmittal__c(PaymentRequest__c = prList[0].Id, TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_State,
                Stage__c = ALS_CONSTANTS.Transmittal_Stage_InReview);
        transmittalList1.add(tr1);
        Transmittal__c tr2 = new Transmittal__c(PaymentRequest__c = prList[0].Id, TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal,
                Stage__c = ALS_CONSTANTS.Transmittal_Stage_InReview);
        transmittalList1.add(tr2);
        Transmittal__c tr3 = new Transmittal__c(PaymentRequest__c = prList[1].Id, TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_State,
                External_Id__c = prList[1].Id);
        transmittalList1.add(tr3);
        Transmittal__c tr4 = new Transmittal__c(PaymentRequest__c = prList[1].Id, TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal);
        transmittalList1.add(tr4);
        Transmittal__c tr5 = new Transmittal__c(PaymentRequest__c = prList[3].Id, TransmittalType__c = ALS_CONSTANTS.Transmittal_Type_Federal,
                PaymentType__c = ALS_CONSTANTS.PR_PaymentType_Offset, ApprovedAmount__c = 100, Adjusted_For_Offset__c = tr6.Id,
                Stage__c = ALS_CONSTANTS.Transmittal_Stage_InReview);
        transmittalList1.add(tr5);

        Test.startTest();
        insert transmittalList1;
        List<Id> trIdList = new List<Id>();
        for (Transmittal__c tr : transmittalList1) {
            trIdList.add(tr.Id);
        }
        RecordLockUnlockClass lockUnlock = new RecordLockUnlockClass();
        lockUnlock.lockRecord(trIdList);

        List<Transmittal__c> trToUpdateList = new List<Transmittal__c>();
        transmittalList1[4].Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved;
        trToUpdateList.add(transmittalList1[4]);
        transmittalList1[0].Stage__c = ALS_CONSTANTS.Transmittal_Stage_Rejected;
        trToUpdateList.add(transmittalList1[0]);
        update trToUpdateList;
        //update transmittalList1[0];
        Test.stopTest();
    }*/
}