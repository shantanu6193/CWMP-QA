/***********************************************************************************************************************************
* Class Name   : PA_EMMIEAmountUpdateBatchTest
* Description  : This class is used  to test code coverage of Apex Batch : PA_EMMIEAmountUpdateBatch
* Author       : Digambar
* Created On   : 06/09/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Digambar             06/09/2021       Initial Implementation

* Note:- todo write setup method 
**************************************************************************************************************************************/
@isTest
public with sharing class PA_EMMIEAmountUpdateBatchTest{

    public PA_EMMIEAmountUpdateBatchTest() {

    }
/***********************************************************************************************************************************
* Method  Name   : testEMMIEAmountUpdateBatch
* Description  : this method is used  to test code coverage of Apex Batch : PA_EMMIEAmountUpdateBatch 
* Author       : Digambar
* Created On   : 06/09/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------*/
@isTest 
public static void testEMMIEAmountUpdateBatch(){
    system.debug('#testEMMIEAmountUpdateBatch START...');
    //Program name
    Program__c parentProgramName = PA_EMMIEAmountUpdateBatchTestHelper.getParentProgramName(true);
    Program__c programName =  PA_EMMIEAmountUpdateBatchTestHelper.getProgramName(true,  parentProgramName);
    system.debug('#programName :'+ programName);

    // Account Subrecipent 
    Account account = PA_EMMIEAmountUpdateBatchTestHelper.getAccountSubrecipent(true);
    system.debug('#account :'+ account);

    //incident 
    Incident__c incident = PA_EMMIEAmountUpdateBatchTestHelper.getIncident(true);
    system.debug('#incident :'+ incident);

    // funding opportunity
    Funding_Opportunity__c fundingOpportunity = PA_EMMIEAmountUpdateBatchTestHelper.getfundingOpportunity(true, programName , incident);
    system.debug('#fundingOpportunity :'+ fundingOpportunity);
    
    // create project
    List<Project__c> projectList = PA_EMMIEAmountUpdateBatchTestHelper.getProjects (true,  10, programName, fundingOpportunity, incident, account);
    system.debug('#projectList :'+ projectList);
    
    //EMMIE records
    List<EMMIE_Project_Staging__c>  emmieList = PA_EMMIEAmountUpdateBatchTestHelper.getEMMIERecords(projectList, incident);
    system.debug('#emmieList :'+ emmieList);

    //project closeout
    List<Project_Closeout__c> projectCloseoutList = PA_EMMIEAmountUpdateBatchTestHelper.getProjectCloseoutRecords(projectList);
    system.debug('#projectCloseoutList :'+ projectCloseoutList);

    //awards
    List<Award__c> awardsList = PA_EMMIEAmountUpdateBatchTestHelper.getAwardsRecords(projectList);
    system.debug('#awardsList :'+ awardsList);

    //TEST
    Test.startTest();
    PA_EMMIEAmountUpdateBatch EMMIEAmountUpdateBatch = new PA_EMMIEAmountUpdateBatch();
    Id batchId = Database.executeBatch(EMMIEAmountUpdateBatch, 500);       
    System.assert(true);
    Test.stopTest();


}
}