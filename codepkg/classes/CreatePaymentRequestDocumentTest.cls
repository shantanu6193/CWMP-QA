/**
 * Created by StackNexus Admin on 12-01-2021.
 */
@IsTest
public with sharing class CreatePaymentRequestDocumentTest {
    @IsTest
    public static void testCreatePaymentRequestDocumentMenthod() {
        set<Id> prIds = new set<Id>();
        Date startDate = system.today()+1;
        Date EndDate = system.today()+10;
        Profile pf = [Select Id from profile where Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + RandomId;
        User uu = new User(firstname = 'ABC',
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
        Program__c prP = new Program__c(Name = 'Test Program Parent');
        insert prP;
        Program__c prC = new Program__c(Name = 'Test Program Child', Parent_Program__c = prP.Id);
        insert prC;
        Program__c prC1 = new Program__c(Name = 'Test Program Child1', Parent_Program__c = prP.Id);
        insert prC1;
        Program_Document__c pgd2 = new Program_Document__c(Parent_Object__c = 'Payment Request', Document_Name__c = 'Test Program Document', Document_Category__c = ALS_CONSTANTS.PDocument_DocumentCategory_Obligating, Document_Creation_Method__c = ALS_CONSTANTS.PDocument_DocumentCreationMethod_ManuallyUploaded, Document_Format__c = ALS_CONSTANTS.PDocument_DocumentFormat_PDF, Program__c = prC.Id, Project_Document_Filter_Clause__c = 'Id != null');
        insert pgd2;
        Program_Document__c pgd3 = new Program_Document__c(Parent_Object__c = 'Payment Request', Document_Name__c = 'Test Program Document', Document_Category__c = ALS_CONSTANTS.PDocument_DocumentCategory_Obligating, Document_Creation_Method__c = ALS_CONSTANTS.PDocument_DocumentCreationMethod_ManuallyUploaded, Document_Format__c = ALS_CONSTANTS.PDocument_DocumentFormat_PDF, Program__c = prC.Id);
        insert pgd3;
        Incident__c inc = new Incident__c(Name = 'Test Incident FP', Declaration_Number__c = '4407');
        insert inc;
        Account account = new Account(Name = 'Test Account', Entity_Type__c = ALS_CONSTANTS.Account_EntityType_City);
        insert account;
        Funding_Opportunity__c fp1 = new Funding_Opportunity__c(Name = 'Test FP ', Program_Name__c = prC.Id, Incident_Name__c = inc.Id, Owner__c = uu.Id);
        insert fp1;
        Project__c newProj = new Project__c(Program_Name__c = prC1.Id, Funding_Opportunity_Name__c = fp1.Id, Stage__c = ALS_CONSTANTS.Project_Stage_Closeout, Obligating_Sub_Recipient__c = account.Id, Start_Date__c = startDate, End_Date__c =EndDate, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, State_Share__c = 20, FEMA_Share__c = 70);
        insert newProj;
        Award__c award = new Award__c(Project__c = newProj.Id);
        insert award;
        Payment_Request__c payRequest = new Payment_Request__c(Award__c = award.Id, Project__c = newProj.Id, ExpenditurestoDate__c = 2000);
        insert payRequest;
        prIds.add(payRequest.Id);
        CreateProjectDocumentPlatformEvent projDoc = new CreateProjectDocumentPlatformEvent();

        Test.startTest();
        projDoc.handle(prIds);
        Test.stopTest();
    }
}