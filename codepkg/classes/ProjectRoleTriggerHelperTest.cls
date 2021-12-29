@IsTest
public with sharing class ProjectRoleTriggerHelperTest {
     @IsTest public static void testBehaviour() {
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
         Incident__c inc = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',
                 State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
         insert inc;
         Funding_Opportunity__c fp1=new Funding_Opportunity__c(Name='Test FP ',Program_Name__c=prC.Id,
                 Incident_Name__c=inc.Id, Owner__c=uu.Id);
         insert fp1;
         Account acc = new Account(Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account',
                 Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =startDate,
                 FFATAExpirationDate__c =EndDate );
         insert acc;
         List<Project__c> projectList = new List<Project__c>();
         Project__c pr1=new Project__c(Obligating_Sub_Recipient__c=acc.Id,Start_Date__c=startDate,End_Date__c=EndDate,
                 Name='Test Project 1', Funding_Opportunity_Name__c=fp1.Id, Stage__c=ALS_CONSTANTS.Project_Stage_New);
         projectList.add(pr1);
         Project__c pr2=new Project__c(Obligating_Sub_Recipient__c=acc.Id,Start_Date__c=startDate,End_Date__c=EndDate,
                 Name='Test Project 2', Funding_Opportunity_Name__c=fp1.Id, Stage__c=ALS_CONSTANTS.Project_Stage_New);
         projectList.add(pr2);
         insert projectList;
         Contact con = new Contact(lastName = 'Test Contact', AccountId=acc.Id);
         insert con;
         AccountContactRole__c aconRole=new AccountContactRole__c(Account_Name__c=acc.Id, Contact_Name__c=con.Id,
                 Contact_Role_Global_List__c=ALS_CONSTANTS.ACRole_ContactRole_Employee);
         insert aconRole;
         Project_Role__c pRole1 = new Project_Role__c( AccountContactJunction__c=aconRole.Id, Project_Name__c=projectList[0].Id,
                 Project_Role_Global_List__c=ALS_CONSTANTS.ProjectRole_Role_Accounting);
         insert pRole1;
         Project_Role__c pRole3 = new Project_Role__c( AccountContactJunction__c=aconRole.Id, Project_Name__c=projectList[0].Id,
                 Project_Role_Global_List__c=ALS_CONSTANTS.ProjectRole_Role_Accounting);
         Project_Role__c pRole2 = new Project_Role__c( AccountContactJunction__c=aconRole.Id, Project_Name__c=projectList[0].Id,
                 Project_Role_Global_List__c=ALS_CONSTANTS.ProjectRole_Role_Applicant);

         Project_Role__c pRole4 = new Project_Role__c( AccountContactJunction__c=aconRole.Id, Project_Name__c=projectList[1].Id,
                 Project_Role_Global_List__c=ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent,
                 Contact_Type__c = ALS_CONSTANTS.ProjectRole_ContactType);

        test.startTest();
             try{
                 insert pRole3;
             }
             catch(Exception e)
             {
                 System.assert(e.getMessage().contains(System.Label.REAL_ProjectRole_DuplicateError));
             }
             try{
                 insert pRole2;
             }
             catch(Exception e)
             {
                 System.assert(e.getMessage().contains(System.Label.REAL_ProjectRole_DuplicateError));
             }
             try{
                 Project_Role__c projectRole2 =new Project_Role__c();
                 projectRole2.Id=pRole2.Id;
                 projectRole2.Project_Role_Global_List__c=ALS_CONSTANTS.ProjectRole_Role_Accounting;
                 Update projectRole2;
             }
             catch(Exception e)
             {
                 System.assert(e.getMessage().contains(System.Label.REAL_ProjectRole_DuplicateError));
             }

         insert pRole4;
         pRole4.Project_Role_Global_List__c = ALS_CONSTANTS.ProjectRole_Role_Applicant;
         update pRole4;

         pRole4.Project_Role_Global_List__c = ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent;
         update pRole4;

         test.stopTest();
     }
}