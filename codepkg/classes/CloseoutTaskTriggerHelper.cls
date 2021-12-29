/*
* Class Name   : CloseoutTaskTriggerHelper
* Description  : This helper is used to pupulate declaration Number, Closeout task Number when closeout task generated
                 also given the grant edit permisson to closeout task or change the owner of closeout task.
* Author       : Digamber
* Created On   : 28/05/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Digamber             28/05/2021       Initial Implementation
**/

public without sharing class CloseoutTaskTriggerHelper extends TriggerHelper{
	public static Boolean skipNameValidation = false;

    /*********************************************************************************
    * Method Name : processBeforeUpdate
    * Author : Digambar
    * Inputs : -
    * Description: This method will called before closeout task record is updated & execute validations.
    ***********************************************************************************/

    public override void processBeforeUpdate() {
        updateCloseoutTaskStatus();
        avoidCloseoutTaskNameUpdate();
    }

    /*******************************************************************
    * Method Name : processBeforeUpdate
    * Author      : Prajakta
    * Inputs      : -
    * Description : This method will called before closeout task record is updated. This method is used to changed status and date assigned.
    ********************************************************************/
    public  static void updateCloseoutTaskStatus() {
        List<Closeout_Task__c> closeoutTaskList =  (List<Closeout_Task__c>)Trigger.new;
        List<Closeout_Task__c> closeoutTaskOldList =  (List<Closeout_Task__c>)Trigger.old;
        
        Integer triggerRecordsCounter = 0;
        for(Closeout_Task__c closeoutTask : closeoutTaskList) {

            // added the filter clause current closeout task owner should not contain old task owner
            if(closeoutTask.OwnerId != closeoutTaskOldList.get(triggerRecordsCounter).OwnerId) {
                    Key_Value_Store__mdt mtdt = Key_Value_Store__mdt.getInstance('PA_Closeout_Task_Assigned_Date_Status');
                
                // added filter clause it check the closeout task contain the status or not
                if(mtdt.Text_Value__c.contains(closeoutTask.Status__c)) {
                            closeoutTask.Status__c = 'Assigned';
                            closeoutTask.Date_Assigned__c = Date.today();
                    }       
                }       
               
                triggerRecordsCounter++;
        } 
    }

    /*******************************************************************
    * Method Name : processBeforeUpdate
    * Author      : Prajakta
    * Inputs      : -
    * Description : This method will called before closeout request record is updated to avoid updating closeout task name.
    ********************************************************************/
    public  static void avoidCloseoutTaskNameUpdate() {
        if(skipNameValidation == true) return;
        for(Closeout_Task__c original: (List<Closeout_Task__c>)Trigger.new) {
            Closeout_Task__c toCompare = (Closeout_Task__c)Trigger.oldMap.get(original.Id);//here we compare old version and new.
            if (original.Name != toCompare.Name) {
                original.addError('You do not have permission to change Closeout Task Name');
            }
        }
    }

    /***************************************************************************************
    * Method Name : processBeforeInsert
    * Author : Prajakta
    * Inputs : -
    * Description: This method will called before closeout task record is inserted.
    ****************************************************************************************/

    public override void processBeforeInsert() {
        populateDeclarationNumber();
    }

    /****************************************************************************************
    * Method Name : populateDeclarationNumber
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to populate Declaration Number.
    ***************************************************************************************/
    private void populateDeclarationNumber(){
        Set<String> incidentIds = new Set<String>();
        List<Closeout_Task__c> closeoutTaskList =  new List<Closeout_Task__c>();
        for (Closeout_Task__c closeoutTask : (List<Closeout_Task__c>)Trigger.new) {

            //added the filter clause closeout task incident should not null
            if (closeoutTask.Incident__c != null) {
                incidentIds.add(closeoutTask.Incident__c);
                closeoutTaskList.add(closeoutTask);
            }
        }
        if (incidentIds.size() > 0) {
            Map<Id, Incident__c> idToIncidentMap = new Map<Id, Incident__c>([SELECT Id, Declaration_Number__c
            FROM Incident__c WHERE Id IN  : incidentIds]);
            for (Closeout_Task__c closeoutTsk : closeoutTaskList) {
                Incident__c incident = idToIncidentMap.get(closeoutTsk.Incident__c);
                closeoutTsk.Declaration_Number__c = incident.Declaration_Number__c;
            }
        }
    }

    /**************************************************************************************
   * Method Name : processAfterInsert
   * Author : Prajakta
   * Inputs : -
   * Description: This method will called after  closeout task record is created.
   **************************************************************************************/

    public override void processAfterInsert() {
        List<Closeout_Task__c> closeoutTaskList =  (List<Closeout_Task__c>)Trigger.new;
        populateNameField(closeoutTaskList);
    }

    /*************************************************************************************
   * Method Name : populateNameField
   * Author : Prajakta
   * Inputs : -
   * Description: This method is used to populate Name Field.
   **************************************************************************************/

    private void populateNameField(List<Closeout_Task__c> closeoutTaskList){
        List<Closeout_Task__c> updatedCloseoutTaskList = new List<Closeout_Task__c>();
            for(Closeout_Task__c closeOutTask : closeoutTaskList){
                Closeout_Task__c closeOutTaskInstance = new Closeout_Task__c();
                closeOutTaskInstance.Id = closeOutTask.Id;

                //added filter clause closeout task number should not empty
                if(String.isNotEmpty(closeOutTask.Task_Number__c)){
                    closeOutTaskInstance.Name =  closeOutTask.Task_Number__c;
                    if(String.isNotEmpty(closeOutTask.Declaration_Number__c) && String.isNotEmpty(closeOutTask.FIPS__c)){
                        closeOutTaskInstance.Name +=  ' (' +closeOutTask.Declaration_Number__c +' / FIPS: '+ closeOutTask.FIPS__c + ')';                        
                    }else if(String.isNotEmpty(closeOutTask.Declaration_Number__c)){
                        closeOutTaskInstance.Name += ' (' + closeOutTask.Declaration_Number__c + ')';
                    }else if(String.isNotEmpty(closeOutTask.FIPS__c)){
                        closeOutTaskInstance.Name += ' (FIPS: ' + closeOutTask.FIPS__c + ')';
                    }
                }

                updatedCloseoutTaskList.add(closeOutTaskInstance);
            }
            skipNameValidation = true;
            //TriggerHelper.skipTrigger = true;
            update updatedCloseoutTaskList;

        }

    /*****************************************************************************************************
    * Method Name : processAfterUpdate
    * Author : Digambar
    * Inputs : -
    * Description: This method will called after closeout task record is updated & execute access sharing.
    *******************************************************************************************************/
    public override void processAfterUpdate() {
        List<Closeout_Task__c> closeoutTaskList =  (List<Closeout_Task__c>)Trigger.new;
        List<Closeout_Task__c> closeoutTaskOldList =  (List<Closeout_Task__c>)Trigger.old;
        List<Closeout_Task__c> ownerChangedCloseoutTaskList = new List<Closeout_Task__c>();

        Integer triggerRecordsCounter = 0;
        for(Closeout_Task__c closeoutTask : closeoutTaskList){
            if(closeoutTask.OwnerId != closeoutTaskOldList.get(triggerRecordsCounter).OwnerId){
            
                ownerChangedCloseoutTaskList.add(closeoutTask);
            }
            triggerRecordsCounter++;
        }   
        
        //Update Project Closeout Owner
        changeProjectCloseoutOwner(ownerChangedCloseoutTaskList);
                    
        //Grant Project Edit Access
        grantEditAccessToProjects(ownerChangedCloseoutTaskList);  
    }

    /*********************************************************************************************
    * Method Name : updateProjectCloseout
    * Author : Digambar
    * Inputs : -
    * Description: This method will change owner of relevant project closeout records.
    **********************************************************************************************/

    public void changeProjectCloseoutOwner(List<Closeout_Task__c> ownerChangedCloseoutTaskList){

        List<Project_Closeout__c> projectCloseoutList = [SELECT Id,  Closeout_Task__r.OwnerId FROM  Project_Closeout__c WHERE Closeout_Task__c IN:ownerChangedCloseoutTaskList];
        for(Project_Closeout__c projectCloseout : projectCloseoutList){
            projectCloseout.OwnerId = projectCloseout.Closeout_Task__r.OwnerId;
        }
      
        update projectCloseoutList;
        
    }

    /**********************************************************************************************
    * Method Name : grantEditAccessToProjects
    * Author : Digambar
    * Inputs : -
    * Description: This method will grant edit access to relevant projects.
    *********************************************************************************************/
    public void grantEditAccessToProjects(List<Closeout_Task__c> ownerChangedCloseoutTaskList){
            // Create a new list of sharing objects for Project to be inserted
            List<Project__Share> projectShareListToInsert  = new List<Project__Share>();
            //Grant Project Edit Access
            List<Project__c> projectList = [SELECT Id, Closeout_Task__r.OwnerId FROM  Project__c WHERE Closeout_Task__c IN:ownerChangedCloseoutTaskList];
            for(Project__c project : projectList){
                    //Revoke shared access to projects old owner
                    List<Project__Share> sharesToDelete = [SELECT Id 
											               FROM Project__Share 
											               WHERE RowCause IN('CloseoutTaskAssignment__c', 'CloseoutTaskMoveProject__c')
											               AND ParentId =: project.Id 
											               LIMIT 200];
                    // project share should not empty                                      
                    if(!sharesToDelete.isEmpty()){
                    Database.Delete(sharesToDelete, false);
                    }

                    // Declare variables for Project sharing object
                    Project__Share projectShare = new Project__Share();
                    
                    // Set the ID of record being shared
                    projectShare.ParentId = project.Id;
                    
                    // Set the ID of user or group being granted access
                    projectShare.UserOrGroupId = project.Closeout_Task__r.OwnerId;
                    
                    // Set the access level
                    projectShare.AccessLevel = 'edit';
                    
                    // Set the Apex sharing reason 
                    projectShare.RowCause = Schema.Project__Share.RowCause.CloseoutTaskAssignment__c;
                    
                    // Add objects to list for insert
                    projectShareListToInsert.add(projectShare);
            }                
             //Insert sharing records and capture save result 
             // The false parameter allows for partial processing if multiple records are passed into the operation 
             Database.SaveResult[] projectShareListDBResults = Database.insert(projectShareListToInsert,false);
            
            // Create counter
            Integer i=0;
            // Process the save results
             for(Database.SaveResult dbResult : projectShareListDBResults){
                if(!dbResult.isSuccess()){
                    // Get the first save result error
                    // Check if the error is related to a trivial access level
                    // Access levels equal or more permissive than the object's  
                    // default access level are not allowed. 
                    // These sharing records are not required and thus an insert exception is acceptable
                    Database.Error err = dbResult.getErrors()[0];                 
                }
                i++; 
            }
    }

}