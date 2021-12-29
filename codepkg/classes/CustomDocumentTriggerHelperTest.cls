/**
 * Created by StackNexus Admin on 11-01-2021.
 */
@IsTest
public with sharing class CustomDocumentTriggerHelperTest {
    @IsTest
    public static void testCustomDocument()
    {
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
        Test.startTest();
        Date startDate = system.today()+1;
        Date EndDate = system.today()+90;
            insert uu;
            Program__c prP = new Program__c(Name='Test Program Parent');
            insert prP;
            Program__c pr3 = new Program__c(Name='Test Program update', Parent_Program__c=prP.Id);
            insert pr3;
            Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
            insert inc;
            Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=pr3.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
            insert fp2;
            Account account=new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =startDate,FFATAExpirationDate__c = EndDate );
            insert account;
            Project__c pr2=new Project__c(Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fp2.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Obligating_Sub_Recipient__c=account.Id, Start_Date__c=startDate, End_Date__c=EndDate);
            insert pr2;
            Document__c doc2 = new Document__c(Document_Name__c = 'Test Document2',Stage__c = ALS_CONSTANTS.Document_Stage_Uploaded, ProjectId__c=pr2.Id);
            insert doc2;
            Document__c doc =new Document__c();
            doc.Id =doc2.Id;
            doc.Document_Name__c='Test';
            update doc;
        Test.stopTest();
    }
}