/**
 * Created by StackNexus Admin on 11-01-2021.
 */
@IsTest
public with sharing class ProjectServiceJunctionTriggerHelperTest {
@IsTest
    public static void testProjectServiceJunctionMethod()
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
        insert uu;
        Date startDate = system.today()+1;
        Date EndDate = system.today()+90;
        Program__c prP = new Program__c(Name='Test Program Parent');
        insert prP;
        Program__c prC = new Program__c(Name='Test Program Child', Parent_Program__c=prP.Id);
        insert prC;
        Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
        insert inc;
        Account account=new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account', Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c =startDate, FFATAExpirationDate__c =EndDate);
        insert account;
        ServiceLocation__c serviceLocation2 = new ServiceLocation__c(Name='12345678');
        insert serviceLocation2;
        Funding_Opportunity__c fp1=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=prC.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
        insert fp1;
        Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP2 ',Program_Name__c=prC.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
        insert fp2;
        ServiceLocation__c serviceLocation = new ServiceLocation__c(Name='1234567');
        insert serviceLocation;
        FundingOppServiceLocationJunction__c fundingOppServiceLocationJunction =new FundingOppServiceLocationJunction__c(Funding_Opportunity__c=fp1.Id,Service_Location__c=serviceLocation.Id);
        insert fundingOppServiceLocationJunction;
        Project__c newProj =new Project__c(Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fp1.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=account.Id,Start_Date__c=startDate,End_Date__c=EndDate);
        insert newProj;
        Project__c newProj1 =new Project__c(Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fp2.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Obligating_Sub_Recipient__c=account.Id,Start_Date__c=startDate,End_Date__c=EndDate);
        insert newProj1;
        Project_Service_Location_Junction__c projectServiceLocationJunction = new Project_Service_Location_Junction__c(Project__c = newProj.Id,Service_Location__c = serviceLocation2.Id);
        Project_Service_Location_Junction__c projectServiceLocationJunction1 = new Project_Service_Location_Junction__c(Project__c = newProj.Id,Service_Location__c = serviceLocation.Id);
        insert projectServiceLocationJunction1;

        test.startTest();
            try
            {
                insert projectServiceLocationJunction;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.REAL_ProjServiceLoc));
            }

            try
            {
                projectServiceLocationJunction1.Project__c = newProj1.Id;
                Update projectServiceLocationJunction1;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains(System.Label.REAL_ProjServiceLoc));
            }

        test.stopTest();
    }
}