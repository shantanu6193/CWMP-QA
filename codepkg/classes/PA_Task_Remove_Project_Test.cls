/*************************************************************************************
* Class Name   : PA_Task_Remove_Project_Test
* Description  : This class used  for check the test cover of PACloseoutTaskRemoveProjectController
* Author       : Dayal
* Created On   : 26/08/2021
* Modification Log:  
* -----------------------------------------------------------------------
* Developer             Date             Description 
* -----------------------------------------------------------------------
* Dayal             26/08/2021       Initial Implementation
**************************************************************************************/
@isTest
public  class PA_Task_Remove_Project_Test {

    /******************************************************************************************************
    * Method  Name   : test_Remove_project_From_Closeout_Task
    * Description  : this method test the closeout Request , closeout Task and Remove project from task method of PA_RequestCloseoutController, PACloseoutTaskRemoveProjectControllerc and paInitCloseoutTaskController 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void test_Remove_project_Details(){
        //parent program create
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //Fedral Program Name
        Program__c programName =  PA_TestHelper.getProgramName(true,  parentProgramName);
        //incident create
        Incident__c incident = PA_TestHelper.getIncident(true);
        //funding opportunity create
        Funding_Opportunity__c fundingOpportunity = PA_TestHelper.getfundingOpportunity(true, programName, incident);
  
        //Account Subrecipent create
        Account account = PA_TestHelper.getAccountSubrecipent(true);
        //project creaate
        List<Project__c> projectList = PA_TestHelper.getProjects (true,  programName, fundingOpportunity, incident, account);       
        
        // creeate the project closoeut
        List<Project_Closeout__c> projectCloseoutList = PA_TestHelper.createProjectCloseout (projectList); 
      
        String projectDataList = '[{\"Id\":\"'+projectList[0].Id+'\",\"Total_Amount_Claimed__c\":\"500\"},{\"Id\":\"'+projectList[1].Id+'\",\"Total_Amount_Claimed__c\":\"4000\"},{\"Id\":\"'+projectList[2].Id+'\",\"Total_Amount_Claimed__c\":\"500\"}]';      
       
        Test.startTest();
        //Get Content Documents
        ContentVersion cv = PA_TestHelper.getContentVersion();        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<String> documentIdList = new List<String>();
        List<String> fileNames = new  List<String> ();
        documentIdList.add(conDocId);
        fileNames.add(cv.Title);

        //create checklist
        String checkList = PA_TestHelper.getCheckList(true, projectList);

        // closeout requested  Created ;    
        // closeout requested  Created ;    
        String authorizedAgent = 'authorizedAgent';
        String SignedP4DocumentAvailable = 'no';
        String closeoutRequestId = PA_RequestCloseoutController.initiateCloseout(projectDataList, documentIdList, fileNames, account.Id, incident.Id, checkList, programName.name, authorizedAgent, SignedP4DocumentAvailable);
        System.assert(closeoutRequestId.length() > 0);

        //get project List for create closeOut Task
        List<Project__c> projectDetailList = new List<Project__c>();
        projectDetailList = paInitCloseoutTaskController.getProjectsForSR(account.Id, incident.Id, programName.name);
        System.assert(projectDetailList.size() > 0);

        //create closeOutTask 
        List<String>  selectedProjectIdList = new List<String>();
        selectedProjectIdList.add(projectDetailList[0].Id); 
        selectedProjectIdList.add(projectDetailList[2].Id);     

        String closeoutTaskId = paInitCloseoutTaskController.initCloseoutTask(selectedProjectIdList, account.Id, incident.Id, '', programName.name);
        System.assert(closeoutTaskId.length() > 0);
        
        // given isSelfAccessCloseoutTaskUser
        Closeout_Task__c closeoutTask = [Select Id, Name, OwnerId from Closeout_Task__c where Id =:closeoutTaskId]; 

        // PA_TestHelper.PermissionSet(true);
        paInitCloseoutTaskController.isSelfAccessCloseoutTaskUser(closeoutTask.OwnerId);

        //create closeout Task Add project existing closeout Task
        String selectedTargetCloseoutTaskId = closeoutTaskId;
        List<String>  selectedProjectIdList1 = new List<String>();
        selectedProjectIdList1.add(projectDetailList[1].Id);

        String closeoutTaskId1 = paInitCloseoutTaskController.initCloseoutTask(selectedProjectIdList1, account.Id, incident.Id, '', programName.name);
        System.assert(closeoutTaskId1.length() > 0);

        /* !!!!!!!!!!!!!!!!!!!!!!-- Closeout Task Remove Controller Test Case !!!!!!!!!!!!!!!!!!!!!!--*/
       
         //isFullAccessCloseoutTaskUserWire of PACloseoutTaskRemoveProjectController get This method will return boolean that specified user is all access user 
        Map<String,String> isFullAccessCloseoutTaskUserWire = PACloseoutTaskRemoveProjectController.isFullAccessCloseoutTaskUserWire(closeoutTaskId, '');
        System.assert(isFullAccessCloseoutTaskUserWire.size() > 0);

        //apexSearchCloseoutTask of PACloseoutTaskRemoveProjectController search closeout Task 
        List<LookupSearchResult> apexSearchCloseoutTask = PACloseoutTaskRemoveProjectController.apexSearchCloseoutTask(closeoutTask.Name);
        System.assert(apexSearchCloseoutTask.size() > 0);
       
        //remove projecr apex Search Target Closeout Task 
        List<LookupSearchResult> apexSearchTargetCloseoutTask= PACloseoutTaskRemoveProjectController.apexSearchTargetCloseoutTask(closeoutTask.Name, closeoutTaskId1);
        System.assert(apexSearchTargetCloseoutTask.size() > 0);          
            
        Test.stopTest();         
    }

    /***********************************************************************************************************************************
    * Method  Name   : test_Remove_Projects_Target_Task
    * Description    : -
    * Author         : Dayal
    * Created On     : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void test_Remove_Project_From_CloseoutTask(){
        //parent program create
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //Fedral Program Name
        Program__c programName =  PA_TestHelper.getProgramName(true,  parentProgramName);
        //incident create
        Incident__c incident = PA_TestHelper.getIncident(true);
        //funding opportunity create
        Funding_Opportunity__c fundingOpportunity = PA_TestHelper.getfundingOpportunity(true, programName, incident);
  
        //Account Subrecipent create
        Account account = PA_TestHelper.getAccountSubrecipent(true);
        
        // create the project 
        Project__c project  = new Project__c();
        project.Name = 'Test fire Forest ';
        project.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project.Program_Name__c = programName.Id;
        project.Incident_Name__c = incident.Id;
        project.Obligating_Sub_Recipient__c = account.Id;
        project.Total_Project_Award__c = 5000000.00;
        project.FundingSource__c = 'Federal Only';

        insert project;
       
        //Get Content Documents
        ContentVersion cv = PA_TestHelper.getContentVersion();        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<String> documentIdList = new List<String>();

        // create the check list for create the project
        Closeout_Checklist__c closeoutCheckList = new Closeout_Checklist__c();
        closeoutCheckList.Checklist__c =  'Have you submitted Cost Summary and all documentation for claimed costs?';
        closeoutCheckList.Response__c = 'Test  Responce';
        closeoutCheckList.Comment__c = 'Test Coment';
        closeoutCheckList.Project__c = project.Id;
        insert closeoutCheckList;

        String checkList = JSON.serialize(closeoutCheckList);
         
        // closeout requested  Created ;    
        Closeout_Request__c closeoutRequest = new Closeout_Request__c();      
        closeoutRequest.Request_Date__c = System.today();
        closeoutRequest.Subrecipient__c = account.Id;
        closeoutRequest.Incident__c = incident.Id;

        upsert closeoutRequest;

        //Create the project closeout
        Project_Closeout__c projectCloseout = new Project_Closeout__c();
        projectCloseout.Closeout_Request__c = closeoutRequest.Id;
        projectCloseout.Project_Name__c = project.Id;
        projectCloseout.Total_Amount_Claimed__c = 500.00;
        projectCloseout.Status__c = 'Request for Closeout';

        upsert projectCloseout;

        // added document 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = closeoutRequest.Id;
        cdl.ShareType = 'I';
        upsert cdl;

        //Create the closout task
        Closeout_Task__c  closeoutTask = new Closeout_Task__c();
        closeoutTask.Reviewer__c = UserInfo.getUserId();
        closeoutTask.Incident__c = incident.Id;
        closeoutTask.Subrecipient_Name__c = account.Id;        
        closeoutTask.Status__c = 'Pending Assignment';
        closeoutTask.RecordTypeId =  Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_Federal').getRecordTypeId();
        upsert closeoutTask;
     
        //update the project closeout with closout task
        projectCloseout.Closeout_Task__c = closeoutTask.Id;
        upsert projectCloseout;

        //update the project with closout task
        project.Closeout_Task__c = closeoutTask.Id;
        upsert project;

        //getProjectsForCR of PACloseoutTaskRemoveProjectController get project name as per closeout task selected       
        List<Project__c> getProjectsForRemoveList = PACloseoutTaskRemoveProjectController.getProjectsForCR(closeoutTask.Id);

        //check PACloseoutTaskRemoveProjectController apexCheckNspo projectList in closeout for removeProjects 
        List<String>  selectedSmallProjectsRemoveIdList = new List<String>();
        Integer selectedLargeProjectRemoveCount = 0;
        for(Project__c project1 : getProjectsForRemoveList){           
            if(project1.IsLargeProject__c == true){
                selectedLargeProjectRemoveCount = selectedLargeProjectRemoveCount + 1;
            }else{
                selectedSmallProjectsRemoveIdList.add(project1.Id);
            }
        } 
        Test.startTest();
        // remove project while passing targate closeout task is empty
        Boolean projectRemove = PACloseoutTaskRemoveProjectController.removeProjects(selectedSmallProjectsRemoveIdList, selectedLargeProjectRemoveCount, closeoutTask.Id, '', getProjectsForRemoveList);
       //System.assert(projectRemove = true);
        Test.stopTest();
    }

    /***********************************************************************************************************************************
    * Method  Name   : test_Remove_Targate_Project_From_CloseoutTask
    * Description    : -
    * Author         : Dayal
    * Created On     : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/

    @isTest 
    public static void test_Remove_Targate_Project_From_CloseoutTask(){
        //parent program create
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //Fedral Program Name
        Program__c programName =  PA_TestHelper.getProgramName(true,  parentProgramName);
        //incident create
        Incident__c incident = PA_TestHelper.getIncident(true);
        //funding opportunity create
        Funding_Opportunity__c fundingOpportunity = PA_TestHelper.getfundingOpportunity(true, programName, incident);
        
        //Account Subrecipent create
        Account account = PA_TestHelper.getAccountSubrecipent(true);

        // create the project-  Test fire Forest
        Project__c project  = new Project__c();
        project.Name = 'Test fire Forest ';
        project.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project.Program_Name__c = programName.Id;
        project.Incident_Name__c = incident.Id;
        project.Obligating_Sub_Recipient__c = account.Id;
        project.Total_Project_Award__c = 5000000.00;
        project.FundingSource__c = 'Federal Only';
   
        insert project;

        // create the project 2
        Project__c project1  = new Project__c();
        project1.Name = 'Test Covid ';
        project1.Funding_Opportunity_Name__c = fundingOpportunity.Id;
        project1.Program_Name__c = programName.Id;
        project1.Incident_Name__c = incident.Id;
        project1.Obligating_Sub_Recipient__c = account.Id;
        project1.Total_Project_Award__c = 6000000.00;
        project1.FundingSource__c = 'Federal Only';

        insert project1;
    
        //Get Content Documents
        ContentVersion cv = PA_TestHelper.getContentVersion();        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<String> documentIdList = new List<String>();
      
        // create the check list for create the project
        Closeout_Checklist__c closeoutCheckList = new Closeout_Checklist__c();
        closeoutCheckList.Checklist__c =  'Have you submitted Cost Summary and all documentation for claimed costs?';
        closeoutCheckList.Response__c = 'Test  Responce';
        closeoutCheckList.Comment__c = 'Test Coment';
        closeoutCheckList.Project__c = project.Id;
        insert closeoutCheckList;

        String checkList = JSON.serialize(closeoutCheckList);
       
        // closeout requested  Created ;    
        Closeout_Request__c closeoutRequest = new Closeout_Request__c();      
        closeoutRequest.Request_Date__c = System.today();
        closeoutRequest.Subrecipient__c = account.Id;
        closeoutRequest.Incident__c = incident.Id;

        upsert closeoutRequest;

        //Create the project closeout for Test fire Forest projrct  
        Project_Closeout__c projectCloseout = new Project_Closeout__c();
        projectCloseout.Closeout_Request__c = closeoutRequest.Id;
        projectCloseout.Project_Name__c = project.Id;
        projectCloseout.Total_Amount_Claimed__c = 500.00;
        projectCloseout.Status__c = 'Request for Closeout';

        upsert projectCloseout;

        //Create the project closeout for Test Covid 
        Project_Closeout__c projectCloseout1 = new Project_Closeout__c();
        projectCloseout1.Closeout_Request__c = closeoutRequest.Id;
        projectCloseout1.Project_Name__c = project1.Id;
        projectCloseout1.Total_Amount_Claimed__c = 500.00;
        projectCloseout1.Status__c = 'Request for Closeout';

        upsert projectCloseout1;

        // added document 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = closeoutRequest.Id;
        cdl.ShareType = 'I';
        upsert cdl;
  
        //Create the closout task for Test fire Forest project

        Closeout_Task__c  closeoutTask = new Closeout_Task__c();
        closeoutTask.Reviewer__c = UserInfo.getUserId();
        closeoutTask.Incident__c = incident.Id;
        closeoutTask.Subrecipient_Name__c = account.Id;        
        closeoutTask.Status__c = 'Pending Assignment';
        closeoutTask.RecordTypeId =  Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_Federal').getRecordTypeId();
        upsert closeoutTask;

        //Create the closout task for Test Covid project

        Closeout_Task__c  closeoutTask1 = new Closeout_Task__c();
        closeoutTask1.Reviewer__c = UserInfo.getUserId();
        closeoutTask1.Incident__c = incident.Id;
        closeoutTask1.Subrecipient_Name__c = account.Id;        
        closeoutTask1.Status__c = 'Pending Assignment';
        closeoutTask1.RecordTypeId =  Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_Federal').getRecordTypeId();
        upsert closeoutTask1;
    
        //update the project closeout with closout task
        projectCloseout.Closeout_Task__c = closeoutTask.Id;
        upsert projectCloseout;

        projectCloseout1.Closeout_Task__c = closeoutTask1.Id;
        upsert projectCloseout1;
       
        //update the project with closout task
        project.Closeout_Task__c = closeoutTask.Id;
        upsert project;

        project1.Closeout_Task__c = closeoutTask1.Id;
        upsert project1;
       
       
        //getProjectsForCR of PACloseoutTaskRemoveProjectController get project name as per closeout task selected       
        List<Project__c> getProjectsForRemoveList = PACloseoutTaskRemoveProjectController.getProjectsForCR(closeoutTask.Id);
       
          
        //check PACloseoutTaskRemoveProjectController apexCheckNspo projectList in closeout for removeProjects 
        List<String>  selectedSmallProjectsRemoveIdList = new List<String>();
        Integer selectedLargeProjectRemoveCount = 0;
        for(Project__c projects1 : getProjectsForRemoveList){           
            if(projects1.IsLargeProject__c == true){
                selectedLargeProjectRemoveCount = selectedLargeProjectRemoveCount + 1;
            }else{
                selectedSmallProjectsRemoveIdList.add(projects1.Id);
            }
        } 
        
        String targetCloseoutTaskId = closeoutTask1.Id;
        Test.startTest();
        // remove project while passing targate closeout task 
        PACloseoutTaskRemoveProjectController.removeProjects(selectedSmallProjectsRemoveIdList, selectedLargeProjectRemoveCount, closeoutTask.Id, targetCloseoutTaskId, getProjectsForRemoveList);
        Test.stopTest();
    }

    /**********************************************************************************************************************
    * Method  Name   : test_Remove_Project_Closeout_Task_Grant_Access
    * Description  : this method test the closeout Request , closeout Task and Remove project from task method of PA_RequestCloseoutController, PACloseoutTaskRemoveProjectControllerc and paInitCloseoutTaskController 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * ----------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void test_Closeout_Task_Grant_Access(){
        //parent program create
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //Fedral Program Name
        Program__c programName =  PA_TestHelper.getProgramName(true,  parentProgramName);
        //incident create
        Incident__c incident = PA_TestHelper.getIncident(true);
        //funding opportunity create
        Funding_Opportunity__c fundingOpportunity = PA_TestHelper.getfundingOpportunity(true, programName, incident);
  
        //Account Subrecipent create
        Account account = PA_TestHelper.getAccountSubrecipent(true);
        //project creaate
        List<Project__c> projectList = PA_TestHelper.getProjects (true,  programName, fundingOpportunity, incident, account);       
        // creeate the project closoeut
        List<Project_Closeout__c> projectCloseoutList = PA_TestHelper.createProjectCloseout (projectList); 
        
        String projectDataList = '[{\"Id\":\"'+projectList[0].Id+'\",\"Total_Amount_Claimed__c\":\"500\"},{\"Id\":\"'+projectList[1].Id+'\",\"Total_Amount_Claimed__c\":\"4000\"},{\"Id\":\"'+projectList[2].Id+'\",\"Total_Amount_Claimed__c\":\"500\"}]';      
       
        Test.startTest();
         //Get Content Documents internal portal
        ContentVersion cv = PA_TestHelper.getContentVersion();        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<String> documentIdList = new List<String>();
         List<String> fileNames = new  List<String> ();
        documentIdList.add(conDocId);
         fileNames.add(cv.Title);
 

        //create checklist
        String checkList = PA_TestHelper.getCheckList(true, projectList);
         
        // closeout requested  Created ;  
         String authorizedAgent = 'authorizedAgent';
         String SignedP4DocumentAvailable = 'no';
         String closeoutRequestId = PA_RequestCloseoutController.initiateCloseout(projectDataList, documentIdList, fileNames, account.Id, incident.Id, checkList, programName.name, authorizedAgent, SignedP4DocumentAvailable);
        System.assert(closeoutRequestId.length() > 0);
 

        //get project List for create closeOut Task
        List<Project__c> projectDetailList = new List<Project__c>();
        projectDetailList = paInitCloseoutTaskController.getProjectsForSR(account.Id, incident.Id, programName.name);
        System.assert(projectDetailList.size() > 0);

        //create closeOutTask 
        List<String>  selectedProjectIdList = new List<String>();
        selectedProjectIdList.add(projectDetailList[0].Id); 
        selectedProjectIdList.add(projectDetailList[2].Id); 

        String closeoutTaskId = paInitCloseoutTaskController.initCloseoutTask(selectedProjectIdList, account.Id, incident.Id, '', programName.name);
        System.assert(closeoutTaskId.length() > 0);
        
        // given isSelfAccessCloseoutTaskUser
        Closeout_Task__c closeoutTask = [Select Id, Name, OwnerId from Closeout_Task__c where Id =:closeoutTaskId]; 

        // PA_TestHelper.PermissionSet(true);
        paInitCloseoutTaskController.isSelfAccessCloseoutTaskUser(closeoutTask.OwnerId);

        //create closeout Task Add project existing closeout Task
        String selectedTargetCloseoutTaskId = closeoutTaskId;
        List<String>  selectedProjectIdList1 = new List<String>();
        selectedProjectIdList1.add(projectDetailList[1].Id);

        String closeoutTaskId1 = paInitCloseoutTaskController.initCloseoutTask(selectedProjectIdList1, account.Id, incident.Id, '', programName.name);
        System.assert(closeoutTaskId1.length() > 0);

        //grant edit acess
        paInitCloseoutTaskController.grantEditAccessToProjects(selectedProjectIdList, closeoutTask);

        //getProjectsForCR of PACloseoutTaskRemoveProjectController get project name as per closeout task selected       
        List<Project__c> getProjectsForRemoveList = PACloseoutTaskRemoveProjectController.getProjectsForCR(closeoutTaskId);
        System.assert(getProjectsForRemoveList.size() > 0);
        
        String targetCloseoutTaskId = closeoutTaskId1;

        // grantEditAccessToProjects given grant access to project if loged user should not have PM and Daps spacial prmisson
        Closeout_Task__c closeoutTaskTargate = [Select Id, Name, OwnerId from Closeout_Task__c where Id =:targetCloseoutTaskId];  
       
        PACloseoutTaskRemoveProjectController.grantEditAccessToProjects(getProjectsForRemoveList, closeoutTaskTargate);
        
        // getSalesforceCustomBaseURL
        PACloseoutTaskRemoveProjectController.getSalesforceCustomBaseURL();
      
        Test.stopTest();         
    }

}