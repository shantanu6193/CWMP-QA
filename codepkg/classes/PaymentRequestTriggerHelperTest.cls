@IsTest
public with sharing class PaymentRequestTriggerHelperTest {
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
                State_Retention__c = 10,  Obligating_Sub_Recipient__c = acc1.Id, Stage__c=ALS_CONSTANTS.Project_Stage_New,
                FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Status__c = ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery);
        projectList.add(pr1);
        Project__c pr2 = new Project__c(Name = 'Test Project 2',Funding_Opportunity_Name__c = fp1.Id,Total_Project_Award__c=1000,
                Start_Date__c = startDate, End_Date__c = EndDate, Obligating_Sub_Recipient__c = acc1.Id, FEMA_Share__c = 75,
                State_Share__c = 18.75,PaytoStateAdmin__c =ALS_CONSTANTS.Picklist_No, Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,
                FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState);
        projectList.add(pr2);
        Project__c pr3 = new Project__c(Name = 'Test Project 3',Funding_Opportunity_Name__c = fp1.Id,Total_Project_Award__c=1000,
                Start_Date__c = startDate, End_Date__c = EndDate, Obligating_Sub_Recipient__c = acc1.Id, FEMA_Share__c = 75,
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalOnly);
        projectList.add(pr3);
        Project__c pr4 = new Project__c(Name = 'Test Project 4',Funding_Opportunity_Name__c = fp1.Id,Total_Project_Award__c=1000,
                Start_Date__c = startDate, End_Date__c = EndDate, Obligating_Sub_Recipient__c = acc1.Id, State_Share__c = 75,
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, FundingSource__c=ALS_CONSTANTS.Project_FundingSource_StateOnly);
        projectList.add(pr4);
        insert projectList;
    }
        
    /*@IsTest
    public static void testPaymentRequestMethod1() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        List<Project__c> projectList = [SELECT Id, Name, Total_Project_Award__c, State_Share__c,FEMA_Share__c, Start_Date__c, End_Date__c,
                PaytoStateAdmin__c, Federal_Retention__c, State_Retention__c, StateAdmin__c FROM Project__c];
        List<ServiceLocation__c> sls = [SELECT Id FROM ServiceLocation__c];
        Incident_Subrecipient_Stage__c stage = [SELECT Id, Name, Stage__c FROM Incident_Subrecipient_Stage__c LIMIT 1];

        //Payment Request Test Data...
        Payment_Request__c payRequest =new Payment_Request__c(Project__c=projectList[0].Id,PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Advance);
        Payment_Request__c payRequest1 =new Payment_Request__c(Project__c=projectList[0].Id,Stage__c = ALS_CONSTANTS.PR_Stage_New,
                ExpenditurestoDate__c =900, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                Service_Location__c = sls[0].Id);
        List<Payment_Request__c> prlist = new List<Payment_Request__c>();
        Payment_Request__c payRequest2 =new Payment_Request__c(Project__c=projectList[1].Id, ExpenditurestoDate__c =900,
                Stage__c = ALS_CONSTANTS.PR_Stage_New);
        prlist.add(payRequest2);
        insert prlist;

        Test.startTest();
        //preventPaymentRequestCreation().....
        try {
            insert payRequest1;
        } catch (Exception e1) {
            System.assert(e1.getMessage().contains(System.Label.REAL_PR_ActivePaymentError));
        }

        //selectAdvancePaymentType().....
        try {
            insert payRequest;
        }
        catch (Exception e2) {
            System.assert(e2.getMessage().contains(System.Label.REAL_PR_PaymentTypeAdvanceError));
        }

        payRequest1.Project__c = projectList[1].Id;
        insert payRequest1;

        payRequest1.ExpenditurestoDate__c =2000;
        payRequest1.Allow_Admin_Payment__c = true;
        update payRequest1;

        List<Id> listIds =new List<Id>();
        listIds.add(prlist[0].Id);
        listIds.add(stage.Id);
        //ALS_TransmittalUtiity.createTransmittalRecord(listIds);

        Transmittal__c tr1 = new Transmittal__c(PaymentRequest__c = prlist[0].Id, Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved);
        insert tr1;

        try {
            prlist[0].Reason_To_Withdraw__c = 'Test PR Withdrawn with Posted TR.';
            prlist[0].Stage__c = ALS_CONSTANTS.PR_Stage_Withdrawn;
            update prlist[0];
        }
        catch (Exception e2) {
            System.assert(e2.getMessage().contains(System.Label.REAL_PR_TransmittalPaidError));
        }

        tr1.Stage__c = ALS_CONSTANTS.Stage_New;
        update tr1;

        update prlist[0];

        try {
            prlist[0].Stage__c = ALS_CONSTANTS.PR_Stage_Processing;
            update prlist[0];
        }
        catch (Exception e2) {
            System.assert(e2.getMessage().contains(System.Label.REAL_PR_TransmittalWithdrawnError));
        }

        List<Transmittal__c> trList1 = [SELECT Id FROM Transmittal__c WHERE PaymentRequest__c =: prlist[0].Id];
        delete trList1;

        delete prlist[0];
        Test.stopTest();
    }*/

    /*@IsTest
    public static void testPaymentRequestMethod2() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        List<Project__c> projectList = [SELECT Id, Name, Total_Project_Award__c, State_Share__c,FEMA_Share__c, Start_Date__c, End_Date__c,
                PaytoStateAdmin__c, Federal_Retention__c, State_Retention__c, StateAdmin__c FROM Project__c];
        List<ServiceLocation__c> sls = [SELECT Id FROM ServiceLocation__c];
        Incident_Subrecipient_Stage__c stage = [SELECT Id, Name, Stage__c FROM Incident_Subrecipient_Stage__c LIMIT 1];

        List<Payment_Request__c> prlist = new List<Payment_Request__c>();
        Payment_Request__c payRequest1 =new Payment_Request__c(Project__c=projectList[2].Id, ExpenditurestoDate__c =900,
                Stage__c = ALS_CONSTANTS.PR_Stage_PaymentProcessing, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, ReimbursementStartDate__c = startDate,
                ReimbursementEndDate__c = EndDate);
        prlist.add(payRequest1);
        Payment_Request__c payRequest2 =new Payment_Request__c(Project__c=projectList[3].Id, ExpenditurestoDate__c =900,
                Stage__c = ALS_CONSTANTS.PR_Stage_PaymentProcessing, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard,
                PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, ReimbursementStartDate__c = startDate,
                ReimbursementEndDate__c = EndDate);
        prlist.add(payRequest2);

        Test.startTest();
        insert prlist;
        Test.stopTest();
    }*/


    /*@IsTest
    public static void testPaymentRequestMethod()
    {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        List<Project__c> projectList = [SELECT Id, Name, Total_Project_Award__c, State_Share__c,FEMA_Share__c, Start_Date__c, End_Date__c,
                PaytoStateAdmin__c, Federal_Retention__c, State_Retention__c, StateAdmin__c FROM Project__c];
        List<ServiceLocation__c> sls = [SELECT Id FROM ServiceLocation__c];
        Incident_Subrecipient_Stage__c stage = [SELECT Id, Name, Stage__c FROM Incident_Subrecipient_Stage__c LIMIT 1];

        //Payment Request Test Data...
        Payment_Request__c payRequest =new Payment_Request__c(Project__c=projectList[0].Id,PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Advance);
        Payment_Request__c payRequest1 =new Payment_Request__c(Project__c=projectList[0].Id,Stage__c=ALS_CONSTANTS.PR_Stage_New, ExpenditurestoDate__c =900, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate, PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard, Service_Location__c = sls[0].Id);
        List<Payment_Request__c> prlist = new List<Payment_Request__c>();
        Payment_Request__c payRequest2 =new Payment_Request__c(Project__c=projectList[1].Id, ExpenditurestoDate__c =900, Stage__c = ALS_CONSTANTS.PR_Stage_New);
        prlist.add(payRequest2);
        //insert payRequest2;
        Payment_Request__c payRequest3 =new Payment_Request__c(Project__c=projectList[1].Id, ExpenditurestoDate__c =900, Stage__c = ALS_CONSTANTS.PR_Stage_PaymentProcessing, PaymentDelivery__c = ALS_CONSTANTS.PR_PaymentDelivery_Standard, PaymentType__c=ALS_CONSTANTS.PR_PaymentType_Reimbursement, ReimbursementStartDate__c = startDate, ReimbursementEndDate__c = EndDate);
        //prlist.add(payRequest3);
        insert prlist;
        //insert payRequest3;
        Test.startTest();  
        //preventPaymentRequestCreation().....
        try {
            insert payRequest1;
        } catch (Exception e1) {
            System.assert(e1.getMessage().contains(System.Label.REAL_PR_ActivePaymentError));
        }

        //selectAdvancePaymentType().....
                try {
                    insert payRequest;
        }
        catch (Exception e2) {
            System.assert(e2.getMessage().contains(System.Label.REAL_PR_PaymentTypeAdvanceError));
                }
                    
        payRequest1.Project__c = projectList[1].Id;
                    insert payRequest1;
                
        payRequest1.ExpenditurestoDate__c =2000;
        update payRequest1;

        List<Id> listIds =new List<Id>();
        listIds.add(prlist[0].Id);
        listIds.add(stage.Id);
        ALS_TransmittalUtiity.createTransmittalRecord(listIds);
                
        Transmittal__c tr1 = new Transmittal__c(PaymentRequest__c = prlist[0].Id, Stage__c = ALS_CONSTANTS.Transmittal_Stage_Approved);
        insert tr1;

        try {
            prlist[0].Reason_To_Withdraw__c = 'Test PR Withdrawn with Posted TR.';
            prlist[0].Stage__c = ALS_CONSTANTS.PR_Stage_Withdrawn;
            update prlist[0];
        }
        catch (Exception e2) {
            System.assert(e2.getMessage().contains(System.Label.REAL_PR_TransmittalPaidError));
        }

        tr1.Stage__c = ALS_CONSTANTS.Stage_New;
        update tr1;

        update prlist[0];

        try {
            prlist[0].Stage__c = ALS_CONSTANTS.PR_Stage_Processing;
            update prlist[0];
                }
        catch (Exception e2) {
            System.assert(e2.getMessage().contains(System.Label.REAL_PR_TransmittalWithdrawnError));
                }

        List<Transmittal__c> trList = [SELECT Id FROM Transmittal__c WHERE PaymentRequest__c =: prlist[0].Id];
        delete trList;

        stage.Stage__c = ALS_CONSTANTS.Summary_Stage_Closed;
        update stage;
        Test.stopTest();

        delete prlist[0];
        undelete prlist[0];
    }*/
}