/***********************************************************************************************************************************
* Class Name   : PA_EMMIEAmountUpdateBatchTestHelper
* Description  : Helper class for PA_EMMIEAmountUpdateBatchTest to create test data
* Author       : Digambar
* Created On   : 06/09/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Digambar             06/09/2021      Initial Implementation
**************************************************************************************************************************************/

@isTest(SeeAllData=false)
public with sharing class PA_EMMIEAmountUpdateBatchTestHelper {
    
    public PA_EMMIEAmountUpdateBatchTestHelper() {

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
       
        if(create)
            insert newAccount;
            return newAccount;
    } 

    // create the Incident 
    public static Incident__c getIncident(boolean create){

        Incident__c incident = new Incident__c();
        incident.Name = 'Test Covid';
        incident.Incident_Type__c = 'Emergency';
        incident.Event_Type__c = 'Fire';
        incident.Stage__c	 = 'Active';  
        incident.Declaration_Number__c  = '2019-05';

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

   public static List<Project__c> getProjects (boolean create, Integer noOfRecords, Program__c programName, Funding_Opportunity__c fundingOpportunity, Incident__c incident, Account account){        
        
    List<Project__c> projectList  = new List<Project__c>();
    for(Integer z=0; z<noOfRecords; z++){
        Project__c project  = new Project__c();
        project.Name = 'Test Project covid '+z;
        project.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project.Program_Name__c = programName.Id;
        project.Incident_Name__c = incident.Id;
        project.Obligating_Sub_Recipient__c = account.Id;
        project.Total_Project_Award__c = 1000.00;
        project.Latest_Project_Version__c = 'PW-' + 100 + z + '-0';
        projectList.add(project);
    }
    
    if(create)
        insert projectList;

    return projectList;   
    }

    
    public static List<EMMIE_Project_Staging__c> getEMMIERecords(List<Project__c> projectList, Incident__c incident){
        List<EMMIE_Project_Staging__c> EMMIEList = new List<EMMIE_Project_Staging__c>();
        Integer counter = 0;
        for(Project__c project : projectList){
                //SELECT Id, Name, Amount__c, DR__c, PW__c, VER__c
                counter++;
                EMMIE_Project_Staging__c emmie = new EMMIE_Project_Staging__c();
                emmie.name = 'test' + counter++;
                emmie.Amount__c = 1000 + counter;
                emmie.DR__c = incident.Declaration_Number__c;
                emmie.PW__c = project.Latest_Project_Version__c.split('-')[1];
                emmie.VER__c = '0';
                EMMIEList.add(emmie);
        }
        insert EMMIEList;
        return EMMIEList;
    }

    public static List<Project_Closeout__c> getProjectCloseoutRecords(List<Project__c> projectList){
        List<Project_Closeout__c> projectCloseoutList = new List<Project_Closeout__c>();
        Integer counter = 0;
        for(Project__c project : projectList){
                counter++;
                Project_Closeout__c projectCloseout = new Project_Closeout__c();
                projectCloseout.Project_Name__c	 = project.id;
                projectCloseout.Total_Amount_Claimed__c = 3000;
                projectCloseoutList.add(projectCloseout);
        }
        insert projectCloseoutList;

    return projectCloseoutList; 
    }

    public static List<Award__c> getAwardsRecords(List<Project__c> projectList){
        List<Award__c> awardsList = new List<Award__c>();
        Integer counter = 0;
        for(Project__c project : projectList){
                counter++;
                Award__c award = new Award__c();
                award.Project__c = project.id;
                award.FDSR__c = project.Latest_Project_Version__c;
                awardsList.add(award);
        }
        insert awardsList;
    return awardsList; 

    }
}