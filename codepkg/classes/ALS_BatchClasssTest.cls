/**
 * Created by StackNexus Admin on 12-05-2021.
 */
@IsTest
public with sharing class ALS_BatchClasssTest {
    @TestSetup static void setup() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
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
        Program__c prP = new Program__c(Name='Test Program Parent');
        insert prP;
        Program__c pr3 = new Program__c(Name='Test Program update', Parent_Program__c=prP.Id);
        insert pr3;
        Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
        insert inc;
        Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=pr3.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
        insert fp2;
        Account account=new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate );
        insert account;
        Contact contact = new Contact(FirstName = 'Test Contact', LastName = 'Contact Test' , Title = 'Developer', AccountId = account.Id);
        insert contact;
        AccountContactRole__c acRole = new AccountContactRole__c(Account_Name__c = account.Id, Contact_Name__c = contact.Id, Contact_Role_Global_List__c = ALS_CONSTANTS.ACRole_ContactRole_Employee, Status__c = ALS_CONSTANTS.ACRole_Status_Active);
        insert acRole;
        Incident_Subrecipient_Stage__c incsubStage = new Incident_Subrecipient_Stage__c(Incident__c =inc.Id,Account__c =account.Id);
        insert incsubStage;
        Project__c newProj =new Project__c(PaytoStateAdmin__c=ALS_CONSTANTS.Picklist_Yes,External_Id__c='Test1y',Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fp2.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Obligating_Sub_Recipient__c=account.Id,Start_Date__c=startDate,End_Date__c=EndDate);
        insert newProj;
        Project_Role__c pRole = new Project_Role__c(Project_Name__c = newProj.Id, Project_Role_Global_List__c = ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent, Contact_Type__c = ALS_CONSTANTS.ProjectRole_ContactType, AccountContactJunction__c = acRole.Id, Is_Mailing_Contact__c = ALS_CONSTANTS.Picklist_Yes, Has_Signing_Authority__c = ALS_CONSTANTS.Picklist_Yes);
        insert pRole;
        Award__c award =new Award__c(Project__c=newProj.Id,Status__c=ALS_CONSTANTS.Award_Status_Active);
        insert award;
        Amendment_Request__c amendmentRequest = new Amendment_Request__c(Project__c = newProj.Id, AmendmentType__c = ALS_CONSTANTS.Amendment_Type_MoneyExtension, SupplementAward__c = 1000, NewObligatedAmount__c = 2000);
        insert amendmentRequest;
        Payment_Request__c paymentRequest =new  Payment_Request__c(PaymentType__c =ALS_CONSTANTS.PR_PaymentType_Reimbursement,ExpenditurestoDate__c =1, Project__c=newProj.Id,Award__c=award.Id,TotalAdminShareAmount__c =5000000.00,External_Id__c='Test1');
        insert paymentRequest;
        Transmittal__c transmittal =new Transmittal__c(PaymentRequest__c=paymentRequest.Id,External_Id__c='Test1y6',TransmittalType__c= ALS_CONSTANTS.Transmittal_Type_State);
        insert transmittal;
        Payment__c payment =new Payment__c(PaymentRequest__c=paymentRequest.Id,Project__c=newProj.Id,StateAdminAmount__c =5000000.00,External_Id__c='Test2');
        insert payment;
    }

    @IsTest
    static void testBehavior() {
        String query ='SELECT Id FROM Project__c';
        String query1 ='SELECT Id FROM Payment_Request__c ';
        String query2 ='SELECT Id,Account__c, Incident__c FROM Incident_Subrecipient_Stage__c ';
        String query3 ='SELECT Id FROM Award__c ';
        String CRON_EXP = '0 6 * * * ?';
        String query4 ='SELECT Id, Account__c, Incident__c, Cumulative_State_Cost_Share_Flag__c, Incident__r.Declaration_Number__c FROM Incident_Subrecipient_Stage__c';
        String query5 = 'SELECT Id, Name, Incident_Name__c, Obligating_Sub_Recipient__c, Incident_Subrecipient_Summary__c,Incident_Subrecipient_Summary__r.Name FROM Project__c WHERE Incident_Name__c != NULL';
        String query6 = 'SELECT Id, Total_Federal_Amount_Requested__c, Total_State_Amount_Requested__c, Total_Admin_Amount_Requested__c, Total_Federal_Amount_Approved__c, Total_State_Amount_Approved__c, Total_Admin_Amount_Approved__c FROM Project__c';
        String query7 = 'SELECT Id, Name, Total_Project_Award__c, FundingSource__c, Federal_Project_Award__c, State_Project_Award__c, State_Share__c, FEMA_Share__c FROM Project__c';

        String query8= 'SELECT Id, Total_Project_Award__c, (SELECT Id FROM Amendment_Requests__r WHERE AmendmentType__c = \'Money Extension\' ORDER BY CreatedDate DESC) FROM Project__c WHERE External_Id__c != NULL';

        String query9 = 'SELECT Id, Name, Cumulative_State_Cost_Share_Flag__c FROM Incident_Subrecipient_Stage__c';
        String query10 = 'SELECT Id, Name, StateAdmin__c, Federal_Retention__c, State_Retention__c, Project_Number__c, Supplement_Number__c, (SELECT Id, Name, Project__c, Amendment_Request__c, Amendment_Request__r.FDSR__c, Amendment_Request__r.SupplementNumber__c, FEMA_Share__c, State_Share__c, Supplement_Award__c, AmountObligated__c, Federal_Retention__c, State_Retention__c, Federal_Retention_Share__c, State_Retention_Share__c, State_Admin__c, Federal_Project_Amount__c, State_Project_Amount__c, State_Admin_Amount__c, Previous_Amount_Obligated__c FROM Awards__r ORDER BY Amendment_Request__r.FDSR__c, CreatedDate ASC ) FROM Project__c';
        String query11 = 'SELECT Id, Name, (SELECT Id, Name, AccountContactJunction__r.Contact_Name__r.FirstName, AccountContactJunction__r.Contact_Name__r.LastName, AccountContactJunction__r.Contact_Name__r.Salutation, AccountContactJunction__r.Contact_Name__r.Title FROM Project_Roles__r WHERE Contact_Type__c = \''+ ALS_CONSTANTS.ProjectRole_ContactType +'\' AND Project_Role_Global_List__c = \'' + ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent +'\' LIMIT 1) FROM Project__c';
        String query12 = 'SELECT Id, Name, Incident__c, Declaration_Number__c, Account__c, FIPS__c FROM Incident_Subrecipient_Stage__c';
        String query13 = 'SELECT Id, Name, Account__c, Incident__c FROM Incident_Subrecipient_Stage__c';
        String query14 = 'SELECT Id, Name, Project_Number__c, Supplement_Number__c, Federal_Project_Award__c, State_Project_Award__c, Federal_Retention__c, State_Retention__c, (SELECT Id, Name, FDSR__c, SupplementNumber__c FROM Amendment_Requests__r ORDER BY FDSR__c DESC , CreatedDate DESC LIMIT 1) FROM Project__c';

        //System.schedule('UpdateAdminAmountOnProjectJob', CRON_EXP,  new UpdateAdminAmountOnProjectJob(query));
        //Database.executebatch( new UpdateAdminAmountOnProjectJob(query));
        System.schedule('LockRecordsJob', CRON_EXP, new LockRecordsJob(query1));
        Database.executebatch( new LockRecordsJob(query1));
        System.schedule('SummaryJunctionRollupJob', CRON_EXP, new SummaryJunctionRollupJob(query2));
        Database.executebatch( new SummaryJunctionRollupJob(query2));
        System.schedule('DeleteRecordsJob', CRON_EXP, new DeleteRecordsJob(query2));
        Database.executebatch( new DeleteRecordsJob(query2));
        System.schedule('UpdateSupplementAwardJob', CRON_EXP, new UpdateSupplementAwardJob(query3));
        Database.executebatch( new UpdateSupplementAwardJob(query3));
        System.schedule('UpdateExpenditureToDateOnProjectJob', CRON_EXP, new UpdateExpenditureToDateOnProjectJob(query3));
        Database.executebatch( new UpdateExpenditureToDateOnProjectJob(query));
        System.schedule('UpdateIncidentSubRecipeintStageRecordJob', CRON_EXP, new UpdateIncidentSubRecipeintStageRecordJob(query4));
        Database.executebatch( new UpdateIncidentSubRecipeintStageRecordJob(query4));
        //System.schedule('UpdateIncSubRecSummaryFieldOfProjectJob', CRON_EXP, new UpdateIncSubRecSummaryFieldOfProjectJob(query5));
        //Database.executebatch( new UpdateIncSubRecSummaryFieldOfProjectJob(query5));
        System.schedule('UpdateRequestedAndApprovedAmountJob', CRON_EXP, new UpdateRequestedAndApprovedAmountJob(query6));
        Database.executebatch( new UpdateRequestedAndApprovedAmountJob(query6));

        System.schedule('updateStateFederalAwardOfProjectJob', CRON_EXP, new updateStateFederalAwardOfProjectJob(query7));
        Database.executebatch( new updateStateFederalAwardOfProjectJob(query7));

        System.schedule('UpdateIncSubRecSummaryFieldOfProjectJob', CRON_EXP, new UpdateIncSubRecSummaryFieldOfProjectJob(query5));
        Database.executebatch( new UpdateIncSubRecSummaryFieldOfProjectJob(query5));

        System.schedule('UpdateProjectAmountFromAmendmentJob', CRON_EXP, new UpdateProjectAmountFromAmendmentJob(query8));
        Database.executebatch( new UpdateProjectAmountFromAmendmentJob(query8));

        System.schedule('ALS_UpdateStateCostShareFlagOfSummaryJob', CRON_EXP, new ALS_UpdateStateCostShareFlagOfSummaryJob(query9));
        Database.executebatch( new ALS_UpdateStateCostShareFlagOfSummaryJob(query9));

        System.schedule('REAL_UpdateAwardRecordNewFieldsBatch', CRON_EXP, new REAL_UpdateAwardRecordNewFieldsBatch(query10));
        Database.executebatch( new REAL_UpdateAwardRecordNewFieldsBatch(query10));

        System.schedule('REAL_UpdateAuthorizedAgentDetailsJob', CRON_EXP, new REAL_UpdateAuthorizedAgentDetailsJob(query11));
        Database.executebatch( new REAL_UpdateAuthorizedAgentDetailsJob(query11));

        System.schedule('REAL_UpdateIncSubSummaryNameJob', CRON_EXP, new REAL_UpdateIncSubSummaryNameJob(query12));
        Database.executebatch( new REAL_UpdateIncSubSummaryNameJob(query12));

        System.schedule('REAL_UpdateIncSubSummaryRollUpFieldsJob', CRON_EXP, new REAL_UpdateIncSubSummaryRollUpFieldsJob(query13));
        Database.executebatch( new REAL_UpdateIncSubSummaryRollUpFieldsJob(query13));

        System.schedule('REAL_UpdateLatProjVerAndSuppNumJob', CRON_EXP, new REAL_UpdateLatProjVerAndSuppNumJob(query14));
        Database.executebatch( new REAL_UpdateLatProjVerAndSuppNumJob(query14));
    }
}