@isTest
public with sharing class ALS_ProjectJunctionEditControllerTest {
     @isTest
     public static void TestaLS_ProjectJunctionEditController_CtrlTestMethod() {
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
         Program__c parentProg =new Program__c(Name='Test ParentProgram');
         insert parentProg;
         Program__c prog =new Program__c(Name='Test program',Parent_Program__c =parentProg.Id);
         insert prog;
         Funding_Opportunity__c fOpp = new Funding_Opportunity__c(Name='Funding Opp Name',Owner__c = uu.Id, Program_Name__c = prog.Id);
         insert fOpp;
         Account acc = new Account(DUNS__c = '1234',Sub_Recipient_FIPS__c='1234',Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City,DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c = EndDate);
         insert acc;
         Contact con =new Contact(LastName='Test contact',AccountId=acc.Id);
         insert con;
         Project__c proj =new Project__c(Total_Project_Award__c=10000,State_Share__c=10,FEMA_Share__c =80,FundingSource__c=ALS_CONSTANTS.Project_FundingSource_FederalAndState,Funding_Opportunity_Name__c=fOpp.Id,Stage__c=ALS_CONSTANTS.Project_Stage_ActivePayment,Obligating_Sub_Recipient__c=acc.Id,Start_Date__c=startDate,End_Date__c=EndDate);
         insert proj;
         AccountContactRole__c accConRole = new AccountContactRole__c(Account_Name__c=acc.ID,Contact_Name__c=con.Id);
         insert accConRole;
         Project_Role__c pRole=new Project_Role__c(AccountContactJunction__c = accConRole.Id);
         insert pRole;


         String AccountDetail =JSON.serialize(acc);
         String ContactDetail =JSON.serialize(con);
         String ProjectDetail =proj.Id ;// JSON.serialize(proj);
         String ProjectRoleDetail =JSON.serialize(pRole);
         String ContactRoleDetail =JSON.serialize(accConRole);

         Account acc1 = new Account(Name='test12221',Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
         insert acc1;
         Contact con1 =new Contact(LastName='Test contact1',AccountId=acc1.Id);
         insert con1;
         AccountContactRole__c accConRole1 = new AccountContactRole__c(Account_Name__c=acc1.ID,Contact_Name__c=con1.Id,Contact_Role_Global_List__c=ALS_CONSTANTS.ACRole_ContactRole_Employee);
         insert accConRole1;
         String ContactRoleDetail1 =JSON.serialize(accConRole1);
         Contact conDetail =new Contact(LastName='Test contact1',AccountId=acc1.Id);
         String ContactDetail1=JSON.serialize(conDetail);

         Boolean isEdit =TRUE;

         try{
        	 ALS_ProjectJunctionEditController_Ctrl.saveDetails(ProjectDetail,AccountDetail,ProjectRoleDetail,ContactDetail,ContactRoleDetail,isEdit,'Project','');
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('Script-thrown exception'));
            }
         
         
         
         Boolean isEdit1 =FALSE;
         test.startTest();
            try{
            ALS_ProjectJunctionEditController_Ctrl.saveDetails(ProjectDetail,AccountDetail,ProjectRoleDetail,ContactDetail,ContactRoleDetail,isEdit1,'Project','');
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('Script-thrown exception'));
            }
            try{
            ALS_ProjectJunctionEditController_Ctrl.saveDetails(ProjectDetail,AccountDetail,ProjectRoleDetail,ContactDetail,ContactRoleDetail1,isEdit1,'Project','');
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('Script-thrown exception'));
            }
            try{
            ALS_ProjectJunctionEditController_Ctrl.saveDetails(ProjectDetail,AccountDetail,ProjectRoleDetail,ContactDetail1,ContactRoleDetail1,isEdit1,'Project','');
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('INVALID_FIELD_FOR_INSERT_UPDATE'));
            }
             ALS_ProjectJunctionEditController_Ctrl.getDetails(pRole.Id);
       test.stopTest();
     }
}