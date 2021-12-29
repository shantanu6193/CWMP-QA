/***********************************************************************************************************************************
* Class Name   : PA_MergeCloseoutTask_Controller_Test
* Description  : This class used  for check the test cover of PA_MergeCloseoutTaskController
* Author       : Dayal
* Created On   : 20/09/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             20/09/2021       Initial Implementation
**************************************************************************************************************************************/
@isTest
public with sharing class PA_MergeCloseoutTask_Controller_Test {

     /* ------------------ Closeout Task Merge Controller Test Case ------------------------*/

    /***********************************************************************************************************************************
    * Method  Name   : test_Merg_CloseoutTask_Details
    * Description    : this method test merge closeout Task 
    * Author         : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
  
    @isTest 
    public static void test_Merg_CloseoutTask_Details(){        
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
       
        test.startTest();
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
       
      
        //create closeout Task Add project existing closeout Task
        String selectedTargetCloseoutTaskId = closeoutTaskId;
        List<String>  selectedProjectIdList1 = new List<String>();
        selectedProjectIdList1.add(projectDetailList[1].Id);

        String closeoutTaskId1 = paInitCloseoutTaskController.initCloseoutTask(selectedProjectIdList1, account.Id, incident.Id, '', programName.name);
    
        /* ~~~~~~~~~~~~~~~~~~ Closeout Task Merge Controller Test Case ~~~~~~~~~~~~~~~~~~ ------*/
       
        // getCloseOutTaskDetails
        Map<String,Object> getCloseOutTaskDetails = PA_MergeCloseoutTaskController.getCloseOutTaskDetails(closeoutTaskId);
        System.assert(getCloseOutTaskDetails.size() > 0);

        // getProjects Associated CloseOut Task
        List<Project__c> getProjectsAssociatedCloseOutTask = PA_MergeCloseoutTaskController.getProjectsAssociatedCloseOutTask(incident.Id, account.Id, closeoutTaskId);
        System.assert(getProjectsAssociatedCloseOutTask.size() > 0);
        String targetCloseoutTaskId = closeoutTaskId1;
        Closeout_Task__c closeoutTaskTargate = [Select Id, Name, OwnerId from Closeout_Task__c where Id =:targetCloseoutTaskId];
        // apex Search Closeout Task
        List<LookupSearchResult> searchCloseOutTask = PA_MergeCloseoutTaskController.apexSearchCloseoutTask(closeoutTaskTargate.Name, incident.Id, account.Id, closeoutTaskId);
        System.assert(searchCloseOutTask.size() > 0);

        test.stopTest();     
           
    }       

    /***********************************************************************************************************************************
    * Method  Name   : test_Merg_CloseoutTask
    * Description  : this method test merge closeout Task 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
  
    @isTest 
    public static void test_Merg_CloseoutTask(){        
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
       
      
        //create closeout Task Add project existing closeout Task
        String selectedTargetCloseoutTaskId = closeoutTaskId;
        List<String>  selectedProjectIdList1 = new List<String>();
        selectedProjectIdList1.add(projectDetailList[1].Id);
        test.startTest();
        String closeoutTaskId1 = paInitCloseoutTaskController.initCloseoutTask(selectedProjectIdList1, account.Id, incident.Id, '', programName.name);
    
        /* ~~~~~~~~~~~~~~~~~~ Closeout Task Merge Controller Test Case ~~~~~~~~~~~~~~~~~~ -----*/
        //test.startTest();
        String targetCloseoutTaskId = closeoutTaskId1;
        Closeout_Task__c closeoutTaskTargate = [Select Id, Name, OwnerId from Closeout_Task__c where Id =:targetCloseoutTaskId];
       
        // merge Selected CloseOut Task
        String masterCloseoutTaskId = closeoutTaskId;
        PA_MergeCloseoutTaskController.mergeSelectedCloseOutTask(closeoutTaskTargate.Id, masterCloseoutTaskId);

        // getSalesforceCustomBaseURL
        PA_MergeCloseoutTaskController.getSalesforceCustomBaseURL();  
       
        test.stopTest();     
           
    } 
    
}