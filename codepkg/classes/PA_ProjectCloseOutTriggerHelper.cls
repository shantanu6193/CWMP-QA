/**
* Class Name   : PA_ProjectCloseOutTriggerHelper
* Description   : This trigger heloper is used to populate Declaration Number ,Project closeout Request
                  Number when project closeout is created ,and also  calculate NSPo and NSPU amount of closeout Task or Closeout request
                  generated or if any project closeout is updated then NSPU and NSPO amount is updated on this perticular closeout
                  request and closeout task 
* Author       : Dayal
* Created On   : 28/05/2021
* Modification Log:  
* -------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* -------------------------------------------------------------------------------------------------------------------------------
* Dayal             28/05/2021       Initial Implementation
**/

public without sharing class PA_ProjectCloseOutTriggerHelper extends TriggerHelper{

    /********************************************************************************
    * Method Name : processBeforeInsert
    * Author : Prajakta
    * Inputs : -
    * Description: This method will called before project closeout  record is inserted.
    *********************************************************************************/

    public override void processBeforeInsert() {
        populateDeclarationNumber();
    }

    /********************************************************************************
   * Method Name : processBeforeUpdate
   * Author      : Prajakta
   * Inputs      : -
   * Descriptio n: This method will called before project closeout  record is updated.
   *********************************************************************************/

    public override void processBeforeUpdate() {
        avoidProjectCloseoutNameUpdate();
    }

        /********************************************************************************
* Method Name : processAfterInsert
* Author      : Dayal
* Inputs      : -
* Description: This method will called after  project closeout  record is created.
**********************************************************************************/

    public override void processAfterInsert() {
        List<Project_Closeout__c> projectCloseOutList =  (List<Project_Closeout__c>)Trigger.new;

        projectCloseOutAmountCalculation(projectCloseOutList);
        populateNameField(projectCloseoutList);
       
    }

    /************************************************************************************
    * Method Name : processAfterUpdate
    * Author      : Dayal
    * Inputs      : -
    * Description: This method will called after  project closeout  record is updated by closeout task.
    ************************************************************************************/

    public override void processAfterUpdate() {
        List<Project_Closeout__c> projectCloseOutList =  (List<Project_Closeout__c>)Trigger.new;

         projectCloseOutAmountCalculation(projectCloseOutList);       
    }

    /***********************************************
    * Method Name : processAfterDelete
    * Author      : Dayal
    * Inputs      : -
    * Description: this method is invoked if any project closeout is deleted from CloseOut Task or CloseOut Request 
    *********************************************/

    public override void processAfterDelete() {
        List<Project_Closeout__c> projectCloseOutList =  (List<Project_Closeout__c>)Trigger.old;  

        projectCloseOutAmountCalculation(projectCloseOutList);  
  
    }

    /***************************************************************************
    * Method Name : populateDeclarationNumber
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to populate Declaration Number.
    ***************************************************************************/

    private void populateDeclarationNumber(){
        Set<String> projecttIds = new Set<String>();
        List<Project_Closeout__c> projectCloseoutList =  new List<Project_Closeout__c>();
        for (Project_Closeout__c projCloseout : (List<Project_Closeout__c>)Trigger.new) {
            projCloseout.Date_Project_Marked_100_Complete__c = system.today();
            //added filter clause project Name should not null
            if (projCloseout.Project_Name__c != null) {
                projecttIds.add(projCloseout.Project_Name__c);
                projectCloseoutList.add(projCloseout);
            }
        }

        //added filter clause get project ids
        if (projecttIds.size() > 0) {
            Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>([SELECT Id, Incident_Name__r.Declaration_Number__c
            FROM Project__c WHERE Id IN  : projecttIds]);
            for (Project_Closeout__c prjCloseout : projectCloseoutList) {
                Project__c proj = idToProjectMap.get(prjCloseout.Project_Name__c);
                prjCloseout.Declaration_Number__c = proj.Incident_Name__r.Declaration_Number__c;
                //prjCloseout.Percent_Complete_To_Date__c = proj.Percent_Complete_To_Date__c;
                //prjCloseout.Project_Completion_Date__c = proj.Project_Completion_Date__c;

            }
        }
    }
    
   
   /***********************************************************************
   * Method Name : populateNameField
   * Author : Dayal
   * Inputs : -projectCloseoutList
   * Description: This method is used to populate Name Field.
   ***********************************************************************/

    private void populateNameField(List<Project_Closeout__c> projectCloseoutList){
        List<Project_Closeout__c> updatedProjectCloseoutList = new List<Project_Closeout__c>();
            for(Project_Closeout__c   projectCloseOut : projectCloseoutList){
                Project_Closeout__c projectCloseOutInstance = new Project_Closeout__c();
                projectCloseOutInstance.Id = projectCloseOut.Id;
                
                //project closeut number should not empty
                if(String.isNotEmpty(projectCloseOut.Project_Closeout_Number__c)){
                    projectCloseOutInstance.Name =  projectCloseOut.Project_Closeout_Number__c;

                    // Decalration  number and project number shoul not empty
                    if(String.isNotEmpty(projectCloseOut.Declaration_Number__c) && String.isNotEmpty(projectCloseOut.Project_Number__c)){
                        projectCloseOutInstance.Name += ' (' + projectCloseOut.Declaration_Number__c +' / '+projectCloseOut.Project_Number__c +')';
                       
                    }else if(String.isNotEmpty(projectCloseOut.Declaration_Number__c)){
                        projectCloseOutInstance.Name +=  ' (' + projectCloseOut.Declaration_Number__c  + ')';
                    }else if(String.isNotEmpty(projectCloseOut.Project_Number__c)){
                        projectCloseOutInstance.Name +=  ' (' + projectCloseOut.Project_Number__c + ')';
                    }
                }               

                updatedProjectCloseoutList.add(projectCloseOutInstance);
            }

            TriggerHelper.skipTrigger = true;
       
        try {
            update updatedProjectCloseoutList;
        }catch(Exception err) {
                    ServiceUtility.logMessage('PA_ProjectCloseOutTriggerHelper', 'populateNameField'
                                              ,err.getMessage(), null, 'Public Assistance');
    }
        TriggerHelper.skipTrigger = false;

    }

    /***********************************************************************************************
    * Method Name : projectCloseOutAmountCalculation
    * Author : Dayal
    * Inputs : -projectCloseOutList
    * Description: This method check closeout task id and closeOutRequest Id which are created or updated
    ***********************************************************************************************/

    private void  projectCloseOutAmountCalculation(List<Project_Closeout__c> projectCloseOutList){
       Set<Id> closeOutIDSet =  new Set <Id>();
       Set<Id> closeOutTaskIDSet =  new Set <Id>();
         for(Project_Closeout__c projectCloseOut : projectCloseOutList){
             // Closeout Request should not null
             if(projectCloseOut.Closeout_Request__c != null){
                closeOutIDSet.add(projectCloseOut.Closeout_Request__c);
             }

             // get old project closeout id
             if(Trigger.oldMap != null && Trigger.oldMap.get(projectCloseOut.Id) != null && ((Project_Closeout__c)Trigger.oldMap.get(projectCloseOut.Id)).Closeout_Request__c != null) {
                 closeOutIDSet.add(((Project_Closeout__c)Trigger.oldMap.get(projectCloseOut.Id)).Closeout_Request__c);
             }

            // closeout Task should not null
            if(projectCloseOut.Closeout_Task__c != null){
                closeOutTaskIDSet.add(projectCloseOut.Closeout_Task__c);
            }
            if(Trigger.oldMap != null && Trigger.oldMap.get(projectCloseOut.Id) != null && ((Project_Closeout__c)Trigger.oldMap.get(projectCloseOut.Id)).Closeout_Task__c != null) {
                closeOutTaskIDSet.add(((Project_Closeout__c)Trigger.oldMap.get(projectCloseOut.Id)).Closeout_Task__c);
            }
        }
        //closeout Id get 
         if(closeOutIDSet.Size() > 0){            
            projectCloseOutRequestAmountCalculation(closeOutIDSet,projectCloseOutList);
        }
        
        if(closeOutTaskIDSet.Size() > 0){
            projectCloseOutTaskAmountCalculation(closeOutTaskIDSet);  
            calculateTotalSmallProjectAwardsANDProjectAmountClaimed(closeOutTaskIDSet);   
            calculateCloseoutTaskCalOESRecommendedAmount(closeOutTaskIDSet);
             //update closeout task field 
             updateFIRField(closeOutTaskIDSet);
        }

    }

    /*****************************************************************************************
    * Method Name : projectCloseOutRequestAmountCalculation
    * Author q    : Dayal
    * Inputs      : -Set<Id> closeOutIDSet, List<Project_Closeout__c> projectCloseOutList)
    * Description: This method calculate NSPO Amount and NSPU Amount of closeout Request once project closeout Request created
    *******************************************************************************************/

    private  void projectCloseOutRequestAmountCalculation(Set<Id> closeOutIDSet, List<Project_Closeout__c> projectCloseOutList){
        AggregateResult[] groupedResults =  [SELECT Closeout_Request__c, sum(Total_Project_Award__c)totalProjectAward , sum(Total_Amount_Claimed__c)totalAmountSpent
        FROM Project_Closeout__c where  Closeout_Request__c  In:closeOutIDSet and Project_Name__r.Was_Ever_Large__c = false and Project_Name__r.Funding_Opportunity_Name__r.Program_Name__r.Name =: PA_CONSTANTS.PA_PROGRAM_FEDERAL group by Closeout_Request__c];

        Map <Id, Closeout_Request__c> closeoutRequestMap = new Map <Id, Closeout_Request__c>();
        for (Id closeoutId : closeOutIDSet) {
            Closeout_Request__c closeoutRequest = new Closeout_Request__c(Id=closeoutId, NSPO_Amount__c = 0, NSPU_Amount__c = 0);
            closeoutRequestMap.put(closeoutRequest.Id, closeoutRequest);
        }
        if(groupedResults.size() > 0){
            for (AggregateResult ar : groupedResults)  {
                  Closeout_Request__c closeoutRequest = closeoutRequestMap.get((Id)ar.get('Closeout_Request__c'));

                //totalProjectAward is greater than totalAmountSpent 
                if( (Double)ar.get('totalProjectAward') > (Double) ar.get('totalAmountSpent')){
                    closeoutRequest.NSPU_Amount__c = (Double)ar.get('totalProjectAward') - (Double)ar.get('totalAmountSpent');
                    closeoutRequest.NSPO_Amount__c = 0;
                }else  if( (Double)ar.get('totalProjectAward') < (Double) ar.get('totalAmountSpent')){
                    closeoutRequest.NSPU_Amount__c = 0;
                    closeoutRequest.NSPO_Amount__c = (Double)ar.get('totalAmountSpent') - (Double)ar.get('totalProjectAward');

                }else {
                    closeoutRequest.NSPO_Amount__c = 0;
                    closeoutRequest.NSPU_Amount__c = 0;
                }
            }
        } 
        // get closeout Request  to update 
        if(closeoutRequestMap.values().size() > 0){
           // update closeoutRequestList;
            database.update(closeoutRequestMap.values());
        }
       
    }

    /***********************************************************************************************
    * Method Name : projectCloseOutTaskAmountCalculation
    * Author : Dayal
    * Inputs : -closeOutTaskIDSet
    * Description : This method calculate NSPO Amount and NSPU Amount of closeout Task once project closeout is updated
                     with closeout task
    ***********************************************************************************************/

    private  void projectCloseOutTaskAmountCalculation(Set<Id> closeOutTaskIDSet){
        AggregateResult[] groupedResults =  [SELECT Closeout_Task__c, sum(Total_Project_Award__c)totalProjectAward , sum(Total_Amount_Claimed__c)totalAmountSpent
          FROM Project_Closeout__c where  Closeout_Task__c  In:closeOutTaskIDSet and Project_Name__r.Was_Ever_Large__c = false and Project_Name__r.Funding_Opportunity_Name__r.Program_Name__r.Name =: PA_CONSTANTS.PA_PROGRAM_FEDERAL group by Closeout_Task__c];
        AggregateResult[] groupedResult =  [SELECT Closeout_Task__c,COUNT(Id)totalNoOfProjects
        FROM Project_Closeout__c where  Closeout_Task__c  In:closeOutTaskIDSet group by Closeout_Task__c];
        Map <Id, Closeout_Task__c> closeOutTaskMap = new Map <Id, Closeout_Task__c>();
        for (Id recId : closeOutTaskIDSet) {
            closeOutTaskMap.put(recId, new Closeout_Task__c(Id=recId, NSPU_Amount__c=0, NSPO_Amount__c = 0,Total_Number_Of_Projects__c = 0));
        }
        // Get project closeout whoes project is small and program name is federal 
        if(groupedResults.size() >0) {
            for (AggregateResult ar : groupedResults)  {
                Closeout_Task__c closeoutTask = closeOutTaskMap.get((Id)ar.get('Closeout_Task__c'));

                //Compair total project award and total amount spent
                if( (Double)ar.get('totalProjectAward') > (Double) ar.get('totalAmountSpent')){               
                        closeoutTask.NSPU_Amount__c = (Double)ar.get('totalProjectAward') - (Double)ar.get('totalAmountSpent');
                        closeoutTask.NSPO_Amount__c = 0;
                }else  if( (Double)ar.get('totalProjectAward') < (Double) ar.get('totalAmountSpent')){              
                        closeoutTask.NSPU_Amount__c = 0;
                        closeoutTask.NSPO_Amount__c = (Double)ar.get('totalAmountSpent') - (Double)ar.get('totalProjectAward');

                    }else {          
                    closeoutTask.NSPU_Amount__c = 0;
                    closeoutTask.NSPO_Amount__c = 0;
                }
            }   
        }

        //Get project closeout whoes project is small and program name is federal 
        if(groupedResult.size() >0) {
            for (AggregateResult ar : groupedResult)  {
                Closeout_Task__c closeoutTask = closeOutTaskMap.get((Id)ar.get('Closeout_Task__c'));
                closeoutTask.Total_Number_Of_Projects__c = (Integer)ar.get('totalNoOfProjects') ;
            }
        }
            if(closeOutTaskMap.values().size() > 0) {
                database.update(closeOutTaskMap.values());
            }
    }

    /************************************************************************
    * Method Name : calculateTotalSmallProjectAwardsANDProjectAmountClaimed
    * Author : Atul
    * Inputs : -closeOutTaskIDSet
    * Description : This method calculate Small Project Award Amount and Project Amount
                     Claimed of closeout Task once project closeout is updated with closeout task

    *************************************************************************/
      private void calculateTotalSmallProjectAwardsANDProjectAmountClaimed(Set<Id> closeOutTaskID){ 

        AggregateResult[] groupedResults =  [SELECT Closeout_Task__c, sum(Total_Project_Award__c)totalProjectAward , sum(Total_Amount_Claimed__c)totalAmountSpent
        FROM Project_Closeout__c where  Closeout_Task__c  In:closeOutTaskID and Project_Name__r.Was_Ever_Large__c = false group by Closeout_Task__c]; 
        List <Closeout_Task__c> closeOutTaskList = new List <Closeout_Task__c>();
        
        for (AggregateResult ar : groupedResults)  {
            Closeout_Task__c closeoutTask = new Closeout_Task__c(id = (String)ar.get('Closeout_Task__c')); 
            closeoutTask.Total_Small_Project_Award__c = (Double)ar.get('totalProjectAward');
            closeoutTask.Total_Small_Project_Amount_Claimed__c = (Double)ar.get('totalAmountSpent');
            closeOutTaskList.add(closeoutTask);
        }
        update closeOutTaskList;
     }

    /****************************************************************************************
    * Method Name : calculateCloseoutTaskCalOESRecommendedAmount
    * Author : Digambar
    * Inputs : closeOutTaskIDSet
    * Description : This method calculate Cal OES Recommended Amount of closeout task.
                    Cal OES Recommended Amount is the sum of Cal OES Recommended Amount of all relevant Project Closeouts
    *****************************************************************************************/

    private void calculateCloseoutTaskCalOESRecommendedAmount(Set<Id> closeOutTaskID){ 

        AggregateResult[] groupedResults =  [SELECT Closeout_Task__c, SUM(Cal_OES_Recommended_Amount__c)totalCalOESRecommendedAmount 
                                             FROM Project_Closeout__c 
                                             WHERE  Closeout_Task__c  IN:closeOutTaskID  GROUP BY Closeout_Task__c]; 
        List <Closeout_Task__c> closeOutTaskList = new List <Closeout_Task__c>();
        
        for (AggregateResult ar : groupedResults)  {
            Closeout_Task__c closeoutTask = new Closeout_Task__c(id = (String)ar.get('Closeout_Task__c')); 
            closeoutTask.Total_Cal_OES_Recommended_Amount__c = (Double)ar.get('totalCalOESRecommendedAmount');
            closeOutTaskList.add(closeoutTask);
        }
        update closeOutTaskList;
     }

    /******************************************************************************************
   * Method Name : populateNameField
   * Author : Dayal
   * Inputs : closeoutTaskList
   * Description: This method is used to update Fir  Field.
    ********************************************************************************************/

    private void updateFIRField(Set<Id> closeOutTaskIDSet){
        List<Closeout_Task__c> updatedCloseoutTaskList = new List<Closeout_Task__c>();         
        /* retrive the project closeout accroding to closeout task */        
        double  spFEMAApprovedAmount = 0;
        double  spClaimedCost  = 0;
        double  spFIREligibleCost = 0;
        double  spAdjustments = 0;
        double  lpFEMAApprovedAmount = 0;
        double  lpClaimedCost  = 0;
        double  lpFIREligibleCost = 0;
        double  lpAdjustments = 0;  
       
        List<Project_Closeout__c> projectCloseoutList = [SELECT Id, FEMA_Obligated_Amount__c, Total_Amount_Claimed__c, Cal_OES_Recommended_Amount__c,
                                                         Adjustment_s__c, IsSmallProject__c, Closeout_Task__r.Id FROM Project_Closeout__c WHERE Closeout_Task__r.Id =: closeoutTaskIdSet];                                              
            
            for(ID closeOutTaskId : closeoutTaskIdSet){
                Closeout_Task__c closeOutTaskInstance = new Closeout_Task__c();
                closeOutTaskInstance.Id = closeOutTaskId;            

                for(Project_Closeout__c projectCloseOut : projectCloseoutList){  

                    projectCloseOut.FEMA_Obligated_Amount__c = projectCloseOut.FEMA_Obligated_Amount__c != null ? projectCloseOut.FEMA_Obligated_Amount__c : 0;
                    projectCloseOut.Total_Amount_Claimed__c = projectCloseOut.Total_Amount_Claimed__c != null ? projectCloseOut.Total_Amount_Claimed__c : 0;
                    projectCloseOut.Cal_OES_Recommended_Amount__c = projectCloseOut.Cal_OES_Recommended_Amount__c != null ?  projectCloseOut.Cal_OES_Recommended_Amount__c : 0;
                    
                    //Compair closeout task id and is selected project is small or not
                    if(projectCloseOut.Closeout_Task__r.Id == closeOutTaskId && projectCloseOut.IsSmallProject__c == true){
                        spFEMAApprovedAmount += projectCloseOut.FEMA_Obligated_Amount__c;
                        spClaimedCost += projectCloseOut.Total_Amount_Claimed__c ;
                        spFIREligibleCost += projectCloseOut.Cal_OES_Recommended_Amount__c;
                        spAdjustments += projectCloseOut.Adjustment_s__c;
                       
                    } else{ 
                        // large project                       
                        lpFEMAApprovedAmount += projectCloseOut.FEMA_Obligated_Amount__c;
                        lpClaimedCost += projectCloseOut.Total_Amount_Claimed__c ;
                        lpFIREligibleCost += projectCloseOut.Cal_OES_Recommended_Amount__c;
                        lpAdjustments += projectCloseOut.Adjustment_s__c;                       
                    }
                }               
                // small project
                closeOutTaskInstance.SP_FEMA_Approved_Amount__c = spFEMAApprovedAmount;
                closeOutTaskInstance.SP_Claimed_Cost__c = spClaimedCost;
                closeOutTaskInstance.SP_FIR_Eligible_Cost__c = spFIREligibleCost;
                closeOutTaskInstance.SP_Adjustment_s__c = spAdjustments;              

                // large project
                closeOutTaskInstance.LP_FEMA_Approved_Amount__c = lpFEMAApprovedAmount;
                closeOutTaskInstance.LP_Claimed_Cost__c = lpClaimedCost;
                closeOutTaskInstance.LP_FIR_Eligible_Cost__c = lpFIREligibleCost;
                closeOutTaskInstance.LP_Adjustment_s__c = lpAdjustments;           

                // total  calculation
                closeOutTaskInstance.Total_FEMA_Approved_Amount__c = lpFEMAApprovedAmount + spFEMAApprovedAmount;
                closeOutTaskInstance.Total_Claimed_Cost__c = lpClaimedCost + spClaimedCost;
                closeOutTaskInstance.Total_FIR_Eligible_Cost__c = lpFIREligibleCost + spFIREligibleCost;
                closeOutTaskInstance.Total_Project_Adjustment_s__c = lpAdjustments + spAdjustments;

                updatedCloseoutTaskList.add(closeOutTaskInstance);               

            }

            update updatedCloseoutTaskList;
        }

        /*******************************************************************
        * Method Name : processBeforeUpdate
        * Author      : Prajakta
        * Inputs      : -
        * Description : This method will called before project closeout record is updated to avoid updating project closeout name.
        ********************************************************************/
        public  static void avoidProjectCloseoutNameUpdate() {
            for(Project_Closeout__c original: (List<Project_Closeout__c>)Trigger.new) {
                Project_Closeout__c toCompare = (Project_Closeout__c)Trigger.oldMap.get(original.Id);//here we compare old version and new.
                if (original.Name != toCompare.Name) {
                    original.addError('You do not have permission to change Project Closeout Name');
                }
            }
        }
}