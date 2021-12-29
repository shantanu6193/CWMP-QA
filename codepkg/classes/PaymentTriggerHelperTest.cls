/**
 * Created by StackNexus Admin on 11-01-2021.
 */
@IsTest
public with sharing class PaymentTriggerHelperTest {
@IsTest
        public static void testPaymentMethod() {
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
                Account account=new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate);
            insert account;
            List<Project__c> projectList = new List<Project__c>();
                Project__c newProj =new Project__c( Incident_Name__c =inc.Id, Name ='TestProject', Total_Project_Award__c=1000, State_Share__c=10,
                    FEMA_Share__c =80, FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState, Funding_Opportunity_Name__c=fp2.Id,
                    Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                    End_Date__c=EndDate, PaytoStateAdmin__c = ALS_CONSTANTS.Picklist_Yes, StateAdmin__c = 10);
            //insert newProj;
            projectList.add(newProj);
                Project__c newProj2 =new Project__c(Incident_Name__c =inc.Id, Total_Project_Award__c=1000, State_Share__c=10, FEMA_Share__c =80,
                        FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState, Funding_Opportunity_Name__c=fp2.Id,
                        Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate,
                        End_Date__c=EndDate);
            projectList.add(newProj2);
            insert projectList;
            Award__c award =new Award__c(Project__c=projectList[0].Id,Status__c=ALS_CONSTANTS.Award_Status_Active);
            insert award;
                List<Payment_Request__c> prList =  new List<Payment_Request__c>();
                Payment_Request__c paymentRequest =new  Payment_Request__c(Project__c=projectList[0].Id,Award__c=award.Id,
                        PaymentType__c = ALS_CONSTANTS.PR_PaymentType_Reimbursement, ExpenditurestoDate__c = 500,
                        ApprovedStatePaymentAmount__c = 40, ApprovedFederalPaymentAmount__c = 40, Allow_Admin_Payment__c = true,
                        TotalAdminShareAmount__c = 4);
            insert paymentRequest;
                Test.startTest();
                Payment__c payment =new Payment__c(PaymentRequest__c=paymentRequest.Id,Project__c=projectList[1].Id, StateAmountPaid__c = 40);
            insert payment;

                Incident_Subrecipient_Stage__c incidentSubrecipientStage = new Incident_Subrecipient_Stage__c(Account__c = account.Id,
                           Incident__c = inc.Id);
                insert incidentSubrecipientStage;
                Payment__c closeoutPayment =new Payment__c(AmountPaid__c = incidentSubrecipientStage.Available_State_Admin_Amount__c,
                        FederalAmountPaid__c =incidentSubrecipientStage.Available_State_Amount__c,
                        StateAmountPaid__c=incidentSubrecipientStage.Available_State_Amount__c,
                        Incident_Subrecipient_Summary__c = incidentSubrecipientStage.Id,
                        Payment_Type__c =ALS_CONSTANTS.Payment_PaymentType_CloseoutPayment);
                insert closeoutPayment;

            try{
                update payment;
            }
            catch(Exception e) {
            }

            try{
           delete payment;
            }
            catch(Exception e) {
            }
                 try{
                   undelete payment;
    }
                 catch(Exception e) {

                }
                Test.stopTest();
        }
}