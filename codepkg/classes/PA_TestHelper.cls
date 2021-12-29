/***********************************************************************************************************************************
* Class Name   : PA_TestHelper
* Description  : This class dummey  record while test clases of related PA
* Author       : Dayal
* Created On   : 26/08/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             26/08/2021       Initial Implementation
**************************************************************************************************************************************/
@isTest(SeeAllData=false)
public  class PA_TestHelper {
    
    public static List<Project__c> getProjects (boolean create, Program__c programName, Funding_Opportunity__c fundingOpportunity, Incident__c incident, Account account){        
        
        List<Project__c> projectList  = new List<Project__c>();
        Project__c project  = new Project__c();
        project.Name = 'Test Project covid ';
        project.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project.Program_Name__c = programName.Id;
        project.Incident_Name__c = incident.Id;
        project.Obligating_Sub_Recipient__c = account.Id;
        project.Total_Project_Award__c = 1000.00;
        project.Project_Number__c	= 'PW-1';

        projectList.add(project);

        Project__c project1  = new Project__c();
        project1.Name = 'Test fire Forest ';
        project1.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project1.Program_Name__c = programName.Id;
        project1.Incident_Name__c = incident.Id;
        project1.Obligating_Sub_Recipient__c = account.Id;
        project1.Total_Project_Award__c = 5000000.00;
        project1.FundingSource__c = 'Federal Only';
        project.Project_Number__c	= 'PW-2';
       
        projectList.add(project1);

        Project__c project2  = new Project__c();
        project2.Name = 'Test Earthquake';
        project2.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project2.Program_Name__c = programName.Id;
        project2.Incident_Name__c = incident.Id;
        project2.Obligating_Sub_Recipient__c = account.Id;
        project2.Total_Project_Award__c = 1000.00;
        project.Project_Number__c	= 'PW-3';

        projectList.add(project2);

        if(create)
            insert projectList;

        return projectList;   
    }
  
    // create the parent accout
    public static Account getParentAccount(boolean create){
        Account newAccount = new Account();
        newAccount.Name = 'NewTest13'+system.now()+Math.random();
        newAccount.BillingStreet='rewxe';
        newAccount.BillingCountry='USA-11';
        newAccount.BillingState='NSdY';
        newAccount.Queue_Name__c = 'COVID_Contributions_Group_Initial';
        newAccount.BillingPostalCode='3425345';
        newAccount.Phone='544534334';
        newAccount.Entity_Type__c = 'Region';
        newAccount.Entity_Id__c = '234543';
        newAccount.Account_Name__c = 'Test';
        if(create)
            insert newAccount;
        return newAccount;
    }

    //Create the Subrecipent / Account
    public static Account getAccountSubrecipent(boolean create){       
        Account newAccount = new Account();
        Account newParentAccount = getParentAccount(create);
        newAccount.Name = 'Test PA Account'+ system.now()+Math.random();       
        newAccount.ParentId = newParentAccount.Id;      
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';       
        newAccount.Entity_Type__c = 'County';
        newAccount.Entity_Id__c = '23454453';
        newAccount.Sub_Recipient_FIPS__c = '000-92006';
       
        if(create)
            insert newAccount;
            return newAccount;
    } 

    // create Contact
    public static Contact getContact(boolean create,  Account acc) {  
        
        Contact contact = new Contact();
        contact.Firstname='FirstNameportal';
        contact.Lastname='LastNameportal';
        contact.Email='email@portal.com';
        contact.Phone ='923-875-1274';
        contact.AccountId = acc.Id;

        if(create)
            insert contact;
        return contact;
    }
   
    // create the Incident 
    public static Incident__c getIncident(boolean create){

        Incident__c incident = new Incident__c();
        incident.Name = 'Test Covide';
        incident.Incident_Type__c = 'Emergency';
        incident.Event_Type__c = 'Fire';
        incident.Stage__c	 = 'Active';  
        incident.Declaration_Number__c  = '2019-05';

        incident.Incident_Type__c  = 'Emergency';
        incident.State_Declaration_Number__c  = '3456-66';
        incident.Cost_Share_Eligibility__c  = 'Federal Only';
        incident.Total_Incident_Amount_Awarded__c  = 378256764870.00;
        incident.Total_Incident_Amount_Available__c  = 378256764870.75;
        incident.Total_Incident_Amount_Disbursed__c  = 4096385;
        incident.State_Small_Project_Threshold__c  = 2500;
        incident.Federal_Small_Project_Threshold__c  = 2500;     
       
        if(create)
            insert incident;
        return incident;
    }

    //create Parent Program 
    public static Program__c getParentProgramName(boolean create){

         Program__c parentProgramName = new Program__c();
         parentProgramName.Name = 'Public Assistance';
         parentProgramName.Stage__c = 'Closed';           
       
        if(create)
            insert parentProgramName;
        return parentProgramName;
    }

    //create Program PA - Federal
    public static Program__c getProgramName(boolean create, Program__c parentProgramName){        
        Program__c programName = new Program__c();
        programName.Name = 'PA - Federal';
        programName.Stage__c = 'Active';
        programName.Parent_Program__c = parentProgramName.Id;        
        if(create)
           insert programName;
        return programName;
    }
    //create Program CDAA (State Funding)
    public static Program__c getProgramNameCDAA(boolean create, Program__c parentProgramName){        
        Program__c programName = new Program__c();
        programName.Name = 'CDAA (State Funding)';
        programName.Stage__c = 'Active';
        programName.Parent_Program__c = parentProgramName.Id;        
        if(create)
           insert programName;
        return programName;
    }
    //create Program PA - FMAG
    public static Program__c getProgramNameFMAG(boolean create, Program__c parentProgramName){        
        Program__c programName = new Program__c();
        programName.Name = 'PA - FMAG';
        programName.Stage__c = 'Active';
        programName.Parent_Program__c = parentProgramName.Id;        
        if(create)
           insert programName;
        return programName;
    }


    // Create Disaster Grant/ Funding Opportunity
    public static Funding_Opportunity__c getfundingOpportunity(boolean create, Program__c programName , Incident__c incident){     

        Funding_Opportunity__c fundingOpportunity = new Funding_Opportunity__c();

        fundingOpportunity.Name = 'Test Funding Opprtunity';
        fundingOpportunity.Program_Name__c = programName.Id;
        fundingOpportunity.Incident_Name__c = incident.Id;
        fundingOpportunity.Stage__c = 'Draft';
        
        if(create)
           insert fundingOpportunity;
        return fundingOpportunity;
    }
    // file upload 
    public static ContentVersion getContentVersion(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.Type__c ='Test';
        Insert cv;
        return cv;
    }
    // file upload for portal user
    public static ContentVersion getContentVersion_Finalize(){
        ContentVersion c = new ContentVersion();
        c.Title = 'Test Document portal';
        c.PathOnClient = 'TestDocument.pdf1';
        c.VersionData = Blob.valueOf('Test Content1');
        c.IsMajorVersion = true;
        c.Type__c ='Test1';
        Insert c;
        return c;
    }
    
    // Create Incident Subrecipient Summary
    public static Incident_Subrecipient_Stage__c getIncidentSubrecipientStage(boolean create, Account account, Incident__c incident){     

        Incident_Subrecipient_Stage__c incidentSubrecipientStage = new Incident_Subrecipient_Stage__c();

        incidentSubrecipientStage.Incident__c = incident.Id;
        incidentSubrecipientStage.Account__c = account.Id;       
        incidentSubrecipientStage.Stage__c = 'Active';
        
        if(create)
            insert incidentSubrecipientStage;
        return incidentSubrecipientStage;
    }

   

    // create Checklist of project while submiting closeout request
    public static String getCheckList(Boolean create, List<Project__c> projectList){
         // check list create
         Closeout_Checklist__c closeoutCheckList = new Closeout_Checklist__c();
         closeoutCheckList.Checklist__c =  'Have you submitted Cost Summary and all documentation for claimed costs?';
         closeoutCheckList.Response__c = 'Test  Responce';
         closeoutCheckList.Comment__c = 'Test Coment';
         closeoutCheckList.Project__c = projectList[0].Id;
 
         Closeout_Checklist__c closeoutCheckList1 = new Closeout_Checklist__c();
         closeoutCheckList1.Checklist__c =  'Have you submitted Cost Summary and all documentation';
         closeoutCheckList1.Response__c = 'Test  Responce';
         closeoutCheckList1.Comment__c = 'Test Coment';
         closeoutCheckList1.Project__c = projectList[1].Id;
 
        // insert closeoutCheckList;
         List<Closeout_Checklist__c> checkListData = new List<Closeout_Checklist__c>();
         checkListData.add(closeoutCheckList);
         checkListData.add(closeoutCheckList1);
         
         if(create)
            insert checkListData;
         String checkListStr = JSON.serialize(checkListData);
         return checkListStr;
    }
    // create Standered user
    public static User getStandardUser(boolean create)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName='standarduser'+Math.random()+'@govbd.dev');
        if(create)
            insert u;
        return u;
    }   

    // create the parent account for portal user
    public static Account getParentAccountPortalUser(boolean create){
        Account newAccount = new Account();
        newAccount.Name = 'NewTest134'+system.now()+Math.random();
        newAccount.BillingStreet='rewxe1';
        newAccount.BillingCountry='USA-11';
        newAccount.BillingState='NSdY1';
        newAccount.Queue_Name__c = 'COVID_Contributions_Group_Initial1';
        newAccount.BillingPostalCode='34253451';
        newAccount.Phone='5445343341';
        newAccount.Entity_Type__c = 'Region1';
        newAccount.Entity_Id__c = '2345431';
        newAccount.Account_Name__c = 'Test1';
        if(create)
            insert newAccount;
        return newAccount;
    }

    //create portal user
    public static User getPortalUser() {  
        Profile profile = [select Id,name from Profile where Name like 'CalOES Portal User' limit 1];
      
        User ps = [SELECT Id,Name FROM User where Id =: UserInfo.getUserId() ];      
        Account newAccount = new Account();
        Account newParentAccount = getParentAccountPortalUser(true);
        newAccount.Name = 'NewTestpaPortal'+system.now()+Math.random();      
        newAccount.ParentId = newParentAccount.Id;    
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'Portaltest23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c = 'County';
        newAccount.Entity_Id__c = '23454453';       
        insert newAccount;

        Contact portalContact = new Contact();
        portalContact.Firstname='FirstNameportalPA';
        portalContact.Lastname='LastNameportalPA';
        portalContact.Email='emailPa@portal.com';
        portalContact.Phone ='923-875-1279';
        portalContact.AccountId = newAccount.Id;
        insert portalContact;

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User portalUser = new User(
            Username = uniqueName+'@acme.com',  
            ProfileId = profile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = portalContact.Id,
            IsActive = true
           // UserRoleId = portalRole.Id           
        );
        insert portalUser;
        return   portalUser;   
        
    }

    
    // create the project closout 
    public static List<Project_Closeout__c> createProjectCloseout ( List<Project__c> projectCloseOutList) {
        List<Project_Closeout__c> projectCloseoutToInitiateList = new List<Project_Closeout__c>(); 
        List<Group> recordOwner= [SELECT Id FROM Group  WHERE DeveloperName ='Public_Assistance_Analyst' AND Type='Queue'];   

        for(Project__c projRec : projectCloseOutList) {           
                Project_Closeout__c closeoutInitiate = new Project_Closeout__c();
                closeoutInitiate.Project_Name__c = projRec.Id;
                closeoutInitiate.Status__c = 'Request for Closeout';
                
                if(recordOwner.size() > 0) {
                    closeoutInitiate.OwnerId = recordOwner[0].Id;
                }
                projectCloseoutToInitiateList.add(closeoutInitiate);

        }

        if(projectCloseoutToInitiateList.size() > 0) {
            insert projectCloseoutToInitiateList;
        }
        return projectCloseoutToInitiateList;
    }
  
}