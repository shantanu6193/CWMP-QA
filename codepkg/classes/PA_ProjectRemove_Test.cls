/***********************************************************************************************************************************
* Class Name   : PA_ProjectRemove_Test
* Description  : This class used  for the remove the closeou task and closoeut request from project 
* Author       : Dayal
* Created On   : 17/11/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             17/11/2021       Initial Implementation
**************************************************************************************************************************************/
@isTest
public with sharing class PA_ProjectRemove_Test {
        /* ------------------ Closeout Task Merge Controller Test Case ------------------------*/

    /***********************************************************************************************************************************
    * Method  Name   : removeProject
    * Description    : this method is used to remove the project closeout task and closeout request 
    * Author         : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
  
    @isTest 
    public static void removeProject() {        
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

        //Get Content Documents external portal
        ContentVersion cvPortal = PA_TestHelper.getContentVersion_Finalize();        
        Id conDocIdPortal = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvPortal.Id].ContentDocumentId;
        List<String> documentIdListPortal = new List<String>();
        List<String> fileNamesPortal = new  List<String> ();
        documentIdListPortal.add(conDocIdPortal);
        fileNamesPortal.add(cvPortal.Title);

      
        //create checklist
        String checkList = PA_TestHelper.getCheckList(true, projectList);
         
        // closeout requested  Created ;    
        String authorizedAgent = 'authorizedAgent';
        String SignedP4DocumentAvailable = 'no';
        String closeoutRequestId = PA_RequestCloseoutController.initiateCloseout(projectDataList, documentIdList, fileNames, account.Id, incident.Id, checkList, programName.name, authorizedAgent, SignedP4DocumentAvailable);
        System.assert(closeoutRequestId.length() > 0);

        String FinalizedCloseoutRequest = PA_RequestCloseoutController.finalizeClosoeutRequest(projectDataList, documentIdListPortal, fileNamesPortal, checkList, programName.name, authorizedAgent, SignedP4DocumentAvailable, closeoutRequestId);
        System.assert(FinalizedCloseoutRequest.length() > 0);




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
        
        // call here this method
        PA_ProjectRemove.removeProject(projectList[0].Project_Number__c);
        test.stopTest(); 
    }       


}