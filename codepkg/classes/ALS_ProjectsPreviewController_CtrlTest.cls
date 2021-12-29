@isTest
public with sharing class ALS_ProjectsPreviewController_CtrlTest {
    @isTest
    public static void Testals_ProjectTestMethod() {
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
        Account acc = new Account(Name='test1222',Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Contact con =new Contact(LastName='Test contact',AccountId=acc.Id);
        insert con;
        Project__c proj =new Project__c(Name='Test project',Funding_Opportunity_Name__c =fOpp.Id,Obligating_Sub_Recipient__c = acc.Id,Start_Date__c=startDate,End_Date__c=EndDate);
        insert proj;
        AccountContactRole__c accConRole = new AccountContactRole__c(Account_Name__c=acc.ID,Contact_Name__c=con.Id);
        insert accConRole;
        Project_Role__c pRole=new Project_Role__c(AccountContactJunction__c = accConRole.Id);
        insert pRole;
        test.startTest();
            ALS_ProjectsPreviewController_Ctrl.getProjectsInfo(pRole.Id,'','Project');
            ALS_ProjectsPreviewController_Ctrl.deleteRecords(pRole.Id);
        test.stopTest();
    }
}