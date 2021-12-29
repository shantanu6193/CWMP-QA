/*************************************************************************************
* Class Name   : PA_ProjectCloseoutFlowHelper_Test
* Description  : test the PA_ProjectCloseoutCreationFlowHelper 
* Author       : Dayal
* Created On   : 17/11/2021
* Modification Log:  
* -----------------------------------------------------------------------
* Developer             Date             Description 
* -----------------------------------------------------------------------
* Dayal               17/11/2021     Initial Implementation
**************************************************************************************/
@isTest
public with sharing class PA_ProjectCloseoutFlowHelper_Test {

/***********************************************************************************************************************************
* Method  Name   : testgetProjectsForSR
* Description  : this method test the getProjectsForSR method of PA_RequestCloseoutController class 
* Author       : Dayal
* Created On   : 30/08/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------*/
@isTest 
public static void testCreateProjectCloseout() {
    
    List<Project__c> projectList1 = new List<Project__c> ();
   
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
    List<Project__c>  projectList= PA_TestHelper.getProjects (true,  programName, fundingOpportunity, incident, account);

    List<PA_ProjectCloseoutCreationFlowHelper.projectListData> data = new  List<PA_ProjectCloseoutCreationFlowHelper.projectListData>();

    PA_ProjectCloseoutCreationFlowHelper.projectListData projectListData = new PA_ProjectCloseoutCreationFlowHelper.projectListData();

    projectListData.inputCollection = new List<Project__c>();
    projectListData.inputCollection.addAll(projectList);

    data.add(projectListData);
    test.startTest();
    PA_ProjectCloseoutCreationFlowHelper.createProjectCloseout(data);
    Test.stopTest();
   
   
  

}
}