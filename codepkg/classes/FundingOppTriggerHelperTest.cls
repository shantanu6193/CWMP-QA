@IsTest
public with sharing class FundingOppTriggerHelperTest {
    @TestSetup private static void setup() {
        Program__c pr1 = new Program__c(Name='Test Program 1');
        insert pr1;
        Program__c pr2 = new Program__c(Name='Test Program 2', Parent_Program__c=pr1.Id);
        insert pr2;
        Incident__c in1 = new Incident__c(Name = 'Test Incident 1',Declaration_Number__c='3241');
        insert in1;
        List<Funding_Opportunity__c> lstTrigger=new List<Funding_Opportunity__c>();
        for(integer counter=1; counter<=5 ;counter++)
        {
            Funding_Opportunity__c fp1=new Funding_Opportunity__c();
            fp1.Name='Test FP '+counter;
            fp1.Program_Name__c=pr2.Id;
            fp1.Incident_Name__c=in1.Id;
            lstTrigger.add(fp1);
        } 
        insert lstTrigger;
    }
    public static testMethod void testFundingOppTriggerHelper(){
        Test.startTest();
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
        Date EndDate = system.today()+10;
            Program__c prP = new Program__c(Name='Test Program Parent');
            insert prP;
            Program__c prC = new Program__c(Name='Test Program Child', Parent_Program__c=prP.Id);
            insert prC;
            Program__c pr3 = new Program__c(Name='Test Program update', Parent_Program__c=prP.Id);
            insert pr3;
            Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
            insert inc;
            Funding_Opportunity__c fp1=new Funding_Opportunity__c(Name='Test FP2 ',Program_Name__c=prP.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
            try {
                insert fp1;
            }
            catch(Exception e) {
                //System.assert(e.getMessage().contains('Please select the program record,which is having associated parent program.'));
                System.assert(e.getMessage().contains(System.Label.REAL_ProgramWithParentProgramException));
            }
            Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP2 ',Program_Name__c=prC.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
            insert fp2;
            Funding_Opportunity__c fp3=new Funding_Opportunity__c(Name='Test FP3 ',Program_Name__c=pr3.Id,Incident_Name__c=inc.Id, Owner__c=uu.Id);
            insert fp3;
            Account account=new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c =startDate,FFATAExpirationDate__c =EndDate);
            insert account;
            Project__c pr=new Project__c(Total_Project_Award__c=1000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fp2.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Obligating_Sub_Recipient__c=account.Id,Start_Date__c=startDate,End_Date__c=EndDate);
            insert pr; 
            try {
                fp2.Program_Name__c=pr3.Id;
                update fp2;
            }
            catch(Exception e) {
                //System.assert(e.getMessage().contains('You are not allowed to change the Program and Incident, If there is a Project associated to it.'));
                System.assert(e.getMessage().contains(System.Label.REAL_PreventChangingProgramIncidentOfFundingOpp));
            }
        test.stopTest();
    }
}