/***********************************************************************************************************************************
* Class Name   : PA_RequestCloseoutControllerTest
* Description  : This class used  for check the test cover of PA_RequestCloseoutController
* Author       : Dayal
* Created On   : 26/08/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             26/08/2021       Initial Implementation
**************************************************************************************************************************************/
@isTest

public class PA_RequestCloseoutControllerTest {

/***********************************************************************************************************************************
* Method  Name   : testgetProjectsForSR
* Description  : this method test the getProjectsForSR method of PA_RequestCloseoutController class 
* Author       : Dayal
* Created On   : 30/08/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void testGetProjectsForSR(){
        List<Project__c> projectList = new List<Project__c> ();
        //parent program
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //program  name 
        Program__c programName =  PA_TestHelper.getProgramName(true,  parentProgramName);
        //incident 
        Incident__c incident = PA_TestHelper.getIncident(true);
        // funding opportunity
        Funding_Opportunity__c fundingOpportunity = PA_TestHelper.getfundingOpportunity(true, programName , incident);

        // Account Subrecipent 
        Account account = PA_TestHelper.getAccountSubrecipent(true);
        // create project
         PA_TestHelper.getProjects (true,  programName, fundingOpportunity, incident, account);

       Test.startTest();
       projectList = PA_RequestCloseoutController.getProjectsForSR(account.Id , incident.Id , programName.Name);        
       System.assert(projectList.size() > 0);
       Test.stopTest();
    }

/***********************************************************************************************************************************
* Method  Name   : tesApexSearchIncident
* Description  : this method test the apexSearchIncident method of PA_RequestCloseoutController class 
* Author       : Dayal
* Created On   : 30/08/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void tesApexSearchIncident(){
        List<LookupSearchResult>  lookupsearch= new  List<LookupSearchResult>();
        List<LookupSearchResult>  lookupsearcloseoutInitTask= new  List<LookupSearchResult>();      
        String searchTerm ;
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //program  name 
        Program__c programName =  PA_TestHelper.getProgramName(true,  parentProgramName);
        //incident 
        Incident__c incident = PA_TestHelper.getIncident(true);
        searchTerm = incident.Name;
        // funding opportunity
        Funding_Opportunity__c fundingOpportunity = PA_TestHelper.getfundingOpportunity(true, programName , incident);
        // Account Subrecipent 
        Account account = PA_TestHelper.getAccountSubrecipent(true);
        // create project
        PA_TestHelper.getProjects (true,  programName, fundingOpportunity, incident, account);

        //test apex search incident of PA_RequestCloseoutController and paInitCloseoutTaskController 
        Test.startTest();

        lookupsearch = PA_RequestCloseoutController.apexSearchIncident(searchTerm);
        lookupsearcloseoutInitTask = paInitCloseoutTaskController.apexSearchIncident(searchTerm);         
        System.assert(lookupsearch.size() > 0);
        System.assert(lookupsearcloseoutInitTask.size() > 0);

        Test.stopTest();
    }

    /***********************************************************************************************************************************
    * Method  Name   : tesApexSearchAgency
    * Description  : this method test the apexSearchAgency method of PA_RequestCloseoutController class 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void tesApexSearchAgency(){
        List<LookupSearchResult>  lookupsearch = new  List<LookupSearchResult>(); 
        List<LookupSearchResult>  lookupsearchInitcloseoutTask = new  List<LookupSearchResult>();     
        String searchTermAccount ;
        String searchTermIncidentId ;
    
        // Account Subrecipent create
        Account account = PA_TestHelper.getAccountSubrecipent(true);
        searchTermAccount = account.Name;

        //incident create
        Incident__c incident = PA_TestHelper.getIncident(true);
        searchTermIncidentId = incident.Id;

        //ncident Subrecipient stage create
         PA_TestHelper.getIncidentSubrecipientStage(true, account, incident);


        Test.startTest();
        lookupsearch = PA_RequestCloseoutController.apexSearchAgency(searchTermAccount);   
        lookupsearchInitcloseoutTask = paInitCloseoutTaskController.apexSearchAgency(searchTermAccount, searchTermIncidentId);     
        System.assert(lookupsearch.size() > 0);
        System.assert(lookupsearchInitcloseoutTask.size() > 0);
        Test.stopTest();
    }

     /***********************************************************************************************************************************
    * Method  Name   : tesGetUserSubrecipientDetails
    * Description  : this method test the getUserSubrecipientDetails method of PA_RequestCloseoutController class 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void tesGetUserSubrecipientDetails(){       
        list<sObject>  User = new   list<sObject>();   
        Test.startTest();
         User = PA_RequestCloseoutController.getUserSubrecipientDetails();        
        System.assert(User.size() > 0);
        Test.stopTest();
    }

     /***********************************************************************************************************************************
    * Method  Name   : tesGetReviewMetadata
    * Description  : this method test the getReviewMetadata method of PA_RequestCloseoutController class 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void tesGetReviewMetadata(){
        List<PA_Project_Closeout_Review_Checklist__mdt>  reviewMetadata= new   List<PA_Project_Closeout_Review_Checklist__mdt>();   
        String searchTerm ;
        //parent program
        Program__c parentProgramName = PA_TestHelper.getParentProgramName(true);
        //program  name 
        Program__c programName =  PA_TestHelper.getProgramName(true, parentProgramName);
        searchTerm = programName.Name;
        
        Test.startTest();
        reviewMetadata = PA_RequestCloseoutController.getReviewMetadata(searchTerm);        
        System.assert(reviewMetadata.size() > 0);
        Test.stopTest();
    }

      /***********************************************************************************************************************************
    * Method  Name   : testinitiateCloseoutRequestFederal
    * Description  : this method test the closeout Request , closeout Task and Remove project from task method of PA_RequestCloseoutController, PACloseoutTaskRemoveProjectControllerc and paInitCloseoutTaskController 
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void testinitiateCloseoutRequestFederal(){
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
               
        String projectDataList = '[{\"Id\":\"'+projectList[0].Id+'\",\"Total_Amount_Claimed__c\":\"0\"},{\"Id\":\"'+projectList[1].Id+'\",\"Total_Amount_Claimed__c\":\"0\"},{\"Id\":\"'+projectList[2].Id+'\",\"Total_Amount_Claimed__c\":\"\"}]';      
       Test.startTest();
        //Get Content Documents
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
		User user =  PA_TestHelper.getPortalUser();  

        Closeout_Request__c closeoutRequest = new Closeout_Request__c(Id = closeoutRequestId, Requestor__c = user.Id);      
        upsert closeoutRequest;
        
        PA_RequestCloseoutController.getCloseoutRequestDetailsOnCommunity(closeoutRequestId);
       
        String closeoutRequestStatus = PA_RequestCloseoutController.getCloseoutRequestStatus(closeoutRequestId);
        System.assert(closeoutRequestStatus.length() > 0);
        
        Closeout_Request__c closeoutRequst = [Select Id,Name,Declaration_Number__c,Entity_Type__c,Incident__c,NSPO_Amount__c,NSPU_Amount__c,Program_Name__c,Requestor__c,Status__c,Subrecipient__c from Closeout_Request__c where Id =: closeoutRequestId];
        
        String FinalizedCloseoutRequest = PA_RequestCloseoutController.finalizeClosoeutRequest(projectDataList, documentIdListPortal, fileNamesPortal, checkList, programName.name, authorizedAgent, SignedP4DocumentAvailable, closeoutRequestId);
        System.assert(FinalizedCloseoutRequest.length() > 0);        
      
        test.stopTest();    
    }       
   
    /***********************************************************************************************************************************
    * Method  Name   : finalizeClosoeutRequest
    * Description  : this finalize the closeout request
    * Author       : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest 
    public static void finalizeClosoeutRequest(){
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
      // Test.startTest();
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

        Test.startTest();
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

        

        //search closeout task
        List<LookupSearchResult> apex_Search_CloseoutTask = paInitCloseoutTaskController.apexSearchCloseoutTask(closeoutTask.Name, account.Id, incident.Id, programName.name);
        System.assert(apex_Search_CloseoutTask.size() > 0);

        //check apexCheckNspo projectList in closeout
        List<String>  selectedSmallProjectsIdList = new List<String>();
        Integer selectedLargeProjectCount = 0;
        for(Project__c project : projectDetailList){           
            if(project.Was_Ever_Large__c == true){
                selectedLargeProjectCount = selectedLargeProjectCount + 1;
            }else{
                selectedSmallProjectsIdList.add(project.Id);
            }
        } 
       
        //selected targe closeout task is not empty     
        Boolean nspo = paInitCloseoutTaskController.apexCheckNSPO( selectedSmallProjectsIdList, selectedLargeProjectCount, closeoutTaskId);
        System.assert(nspo == false);

        //selected targe closeout task is  empty 
        Boolean nspo1 = paInitCloseoutTaskController.apexCheckNSPO( selectedSmallProjectsIdList, selectedLargeProjectCount, '');      
        System.assert(nspo1 == false);

        test.stopTest();    
    }       
    
    /***********************************************************************************************************************************
    * Method  Name   : testPortalUserCloseoutRequestCreate
    * Description  : this method is used to test the closeout request while it create from portal
    * Author       : Dayal
    * Created On   : 06/09/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------*/
  
    @isTest 
    public static void testPortalUserCloseoutRequestCreate(){ 

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

        //create the portal user
        User user =  PA_TestHelper.getPortalUser();  

        System.runAs(user){
        PermissionSet  Permissionset =[SELECT CreatedById,Id,Name FROM PermissionSet WHERE Name = 'PA_Community_User'];
       
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = user.Id;
        psa.PermissionSetId = Permissionset.Id;
        insert psa;

        test.startTest();
         
              
        String closeoutRequestId = PA_RequestCloseoutController.initiateCloseout(projectDataList, documentIdList, fileNames, account.Id, incident.Id, checkList, programName.name,'','');
        

        test.stopTest();   
        }
    }
}