@IsTest
    public with sharing class ProjectTriggerHelperTest {
    @TestSetup private static void setup() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        Profile pf= [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
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

        List<Program__c> proList1 = new List<Program__c>();
        Program__c prP1 = new Program__c(Name=ALS_CONSTANTS.Program_HMA, Master_Label_Program_Name__c = ALS_CONSTANTS.Program_HMA);
        //insert prP1;
        proList1.add(prP1);
        Program__c prP2 = new Program__c(Name = ALS_CONSTANTS.Program_PA, Master_Label_Program_Name__c = ALS_CONSTANTS.Program_PA);
        //insert prP2;
        proList1.add(prP2);
        insert proList1;

        List<Program__c> programList = new List<Program__c>();
        Program__c prC1 = new Program__c(Name='Test Program Child', Parent_Program__c=proList1[0].Id);
        programList.add(prC1);
        Program__c prC2 = new Program__c(Name='Test Program update', Parent_Program__c=proList1[0].Id);
        programList.add(prC2);

        Program__c prC3 = new Program__c(Name = ALS_CONSTANTS.Program_PA_Federal, Parent_Program__c = proList1[1].Id, Master_Label_Program_Name__c = ALS_CONSTANTS.Program_PA_Federal);
        programList.add(prC3);
        Program__c prC4 = new Program__c(Name = ALS_CONSTANTS.Program_CDAA, Parent_Program__c = proList1[1].Id, Master_Label_Program_Name__c = ALS_CONSTANTS.Program_CDAA);
        programList.add(prC4);
        insert programList;

        List<Program_Document__c> pdList = new List<Program_Document__c>();
        Program_Document__c pgd1 = new Program_Document__c(Document_Name__c='Test Program Document', Document_Category__c=ALS_CONSTANTS.PDocument_DocumentCategory_Compliance, Document_Creation_Method__c=ALS_CONSTANTS.PDocument_DocumentCreationMethod_ManuallyUploaded, Document_Format__c=ALS_CONSTANTS.PDocument_DocumentFormat_PDF, Program__c = programList[0].Id);
        pdList.add(pgd1);
        Program_Document__c pgd2 = new Program_Document__c(Document_Name__c='Test Program Document', Document_Category__c=ALS_CONSTANTS.PDocument_DocumentCategory_Obligating, Document_Creation_Method__c=ALS_CONSTANTS.PDocument_DocumentCreationMethod_ManuallyUploaded, Document_Format__c=ALS_CONSTANTS.PDocument_DocumentFormat_PDF, Program__c = programList[1].Id, Project_Document_Filter_Clause__c='Incident_Name__c != null');
        pdList.add(pgd2);
        insert pdList;

        List<Incident__c> incidentList = new List<Incident__c>();
        Incident__c inc1 = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
        incidentList.add(inc1);
        Incident__c inc2 = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4408',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
        incidentList.add(inc2);
        insert incidentList;


        List<Account> accList = new List<Account>();
        Account account1=new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test1@gmail.com',Name ='Test Account 1' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c = System.today() + 1 , FFATAExpirationDate__c =System.today() + 1 );
        accList.add(account1);
        Account account2 = new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test2@gmail.com',Name ='Test Account 2' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c = System.today() + 1, FFATAExpirationDate__c =System.today() + 1);
        accList.add(account2);
        insert accList;

        Incident_Subrecipient_Stage__c summary = new Incident_Subrecipient_Stage__c(Account__c = accList[0].Id, Incident__c = incidentList[0].Id);
        insert summary;

        List<Funding_Opportunity__c> foList = new List<Funding_Opportunity__c>();
        Funding_Opportunity__c fp1=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=programList[0].Id, Owner__c=uu.Id);
        foList.add(fp1);
        Funding_Opportunity__c fp2=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=programList[1].Id,Incident_Name__c=incidentList[0].Id, Owner__c=uu.Id);
        foList.add(fp2);

        Funding_Opportunity__c fp3=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=programList[2].Id, Incident_Name__c=incidentList[1].Id, Owner__c=uu.Id);
        foList.add(fp3);
        Funding_Opportunity__c fp4=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=programList[3].Id,Incident_Name__c=incidentList[1].Id, Owner__c=uu.Id);
        foList.add(fp4);
        insert foList;
    }

    @IsTest
    public static void testProjectTriggerHelper() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        List<Account> accList = [SELECT Id, Name, Sub_Recipient_FIPS__c, DUNS_Expiration_Date__c, FFATAExpirationDate__c, Entity_Type__c FROM Account];
        List<Funding_Opportunity__c> foList = [SELECT Id, Name, Program_Name__c, Incident_Name__c FROM Funding_Opportunity__c];

        List<Project__c> projectList = new List<Project__c>();
        Project__c project1=new Project__c(Total_Project_Award__c=1000, State_Share__c=10, FEMA_Share__c =80,
                FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState, Funding_Opportunity_Name__c=foList[1].Id,
                Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c=accList[0].Id, Start_Date__c=startDate,
                End_Date__c=EndDate, Project_Number__c = '1-0', Supplement_Number__c = '11',
                PaytoStateAdmin__c = ALS_CONSTANTS.Picklist_Yes, StateAdmin__c = 10, Reviewed_By_Manager__c = ALS_CONSTANTS.Picklist_Yes);
        projectList.add(project1);
        Project__c project2=new Project__c(Total_Project_Award__c=1000, PaytoStateAdmin__c = ALS_CONSTANTS.Picklist_Yes,
                State_Share__c=50,FEMA_Share__c =50,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,
                Funding_Opportunity_Name__c=foList[0].Id, Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,
                Obligating_Sub_Recipient__c=accList[1].Id, Start_Date__c=startDate, End_Date__c=EndDate,
                Project_Number__c = '2-0', Supplement_Number__c = '21');
        projectList.add(project2);

        Project__c project3=new Project__c(Total_Project_Award__c = 1000, State_Share__c = 10, FEMA_Share__c = 80,
                FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, Funding_Opportunity_Name__c = foList[2].Id,
                Stage__c = ALS_CONSTANTS.Project_Stage_ActivePayment, Obligating_Sub_Recipient__c = accList[0].Id, Start_Date__c = startDate,
                End_Date__c=EndDate, Project_Number__c = '3-0', Supplement_Number__c = '31');
        projectList.add(project3);
        Project__c project4=new Project__c(Total_Project_Award__c = 1000, State_Share__c = 10, FEMA_Share__c = 80,
                FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState, Funding_Opportunity_Name__c = foList[3].Id,
                Stage__c = ALS_CONSTANTS.Project_Stage_New, Obligating_Sub_Recipient__c = accList[0].Id, Start_Date__c=startDate,
                End_Date__c=EndDate, Project_Number__c = '4-0', Supplement_Number__c = '41');
        projectList.add(project4);
        Project__c project5=new Project__c(Total_Project_Award__c = 1000, Damage_Category__c = ALS_CONSTANTS.Project_DamageCategory_ZManagement,
                State_Share__c = 10,FEMA_Share__c = 80,FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState,
                Funding_Opportunity_Name__c = foList[3].Id, Stage__c = ALS_CONSTANTS.Project_Stage_New, Obligating_Sub_Recipient__c=accList[0].Id,
                Start_Date__c = startDate, End_Date__c = EndDate, Project_Number__c = '5-0', Supplement_Number__c = '51',
                Reverse_Calculation__c = true, Federal_Project_Award__c = 750, State_Project_Award__c = 200);
        projectList.add(project5);
        Project__c project6 = new Project__c(Total_Project_Award__c = 1000, Damage_Category__c = ALS_CONSTANTS.Project_DamageCategory_ZManagement,
                State_Share__c = 10, FEMA_Share__c = 80, FundingSource__c = ALS_CONSTANTS.Project_FundingSource_FederalAndState,
                Funding_Opportunity_Name__c = foList[3].Id, Stage__c = ALS_CONSTANTS.Project_Stage_New, Obligating_Sub_Recipient__c = accList[0].Id,
                Start_Date__c = startDate, End_Date__c = EndDate, External_Id__c = 'TEST-673596758963564', Project_Number__c = '6-0',
                Supplement_Number__c = '61', Reviewed_By_Manager__c = ALS_CONSTANTS.Picklist_Yes);
        projectList.add(project6);

        Test.startTest();
        insert projectList;
        projectList[0].Project_Number__c = '11-0';
        projectList[1].Total_Project_Award__c = 2000;
        projectList[1].Reviewed_By_Manager__c = ALS_CONSTANTS.Picklist_Yes;
        update projectList;
        Document__c doc = new Document__c(Document_Name__c ='Test', ProjectId__c = projectList[4].Id);
        insert doc;
        try {
            projectList[4].Stage__c = ALS_CONSTANTS.Project_Stage_ActivePayment;
            update projectList[4];
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains(System.Label.REAL_Project_RequiredDocumentError));
        }
            try {
            projectList[5].Funding_Opportunity_Name__c = foList[1].Id;
            update projectList[5];
            }
            catch(Exception e) {
            System.assert(e.getMessage().contains(System.Label.REAL_Project_FOError));
            }

        projectList[1].Stage__c = ALS_CONSTANTS.Project_Stage_Withdrawn;
        projectList[1].Reason_To_Withdraw__c = 'Test Project Withdrawn';
        update projectList[1];

        //delete projectList[0];
        //undelete projectList[0];

        Test.stopTest();
    }
}