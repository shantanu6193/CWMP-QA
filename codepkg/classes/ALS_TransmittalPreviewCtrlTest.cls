/**
 * Created by StackNexus Admin on 11-01-2021.
 */
@IsTest
public with sharing class ALS_TransmittalPreviewCtrlTest {
@IsTest
    public static void testTransmittalPreviewMethod()
{
    Date startDate = system.today()+1;
    Date EndDate = system.today()+10;
    Profile pf= [Select Id from profile where Name='System Administrator'];
    String orgId=UserInfo.getOrganizationId();
    String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
    Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
    String uniqueName=orgId+dateString+RandomId;
    User uu=new User(firstname = 'ABC',
            lastName = 'XYZ',
            email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = pf.Id
    );
    insert uu;
    Program__c prP = new Program__c(Name='Test Program Parent');
    insert prP;
    Program__c pr3 = new Program__c(Name='Test Program update', Parent_Program__c=prP.Id);
    insert pr3;
    Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
    insert inc;
    Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=pr3.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
    insert fp2;
    Account account =new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate);
    insert account;
    Project__c project =new Project__c(Funding_Opportunity_Name__c=fp2.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Start_Date__c = startDate,End_Date__c= EndDate,Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Obligating_Sub_Recipient__c=account.Id);
    insert project;
    Award__c award =new Award__c(Project__c=project.Id,Status__c=ALS_CONSTANTS.Award_Status_Active);
    insert award;
    Payment_Request__c paymentRequest =new  Payment_Request__c(Project__c=project.Id,PaymentType__c =ALS_CONSTANTS.PR_PaymentType_Reimbursement,ReimbursementStartDate__c = startDate,ReimbursementEndDate__c = EndDate);
    insert paymentRequest;
    Transmittal__c transmittal =new Transmittal__c(PaymentRequest__c=paymentRequest.Id);
    insert transmittal;

    Test.startTest();
        ALS_TransmittalPreviewController.getDetails(transmittal.Id);
    Test.stopTest();

}

}