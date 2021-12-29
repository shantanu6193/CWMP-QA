/**
* Class Name   : PA_ProjectRemove
* Description   : This class script is used to remove the  Remove Project Closeout from Closeout Request,
                  Remove Project from Closeout Request. Remove the checklist from project        
                  Calculate all the amount fields on Closeout Request once again.
* Author       : Dayal
* Created On   : 28/10/2021
* Modification Log:  
* -------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* -------------------------------------------------------------------------------------------------------------------------------
* Dayal            28/10/2021      Initial Implementation
**/

public without sharing class PA_ProjectRemove {

    /*******************************************************************************
    * Method Name  : removeProject
    * Description  :  This class script is used to remove the  Remove Project Closeout from Closeout Request,
                      Remove Project from Closeout Request. Remove the checklist from project        
                      Calculate all the amount fields on Closeout Request once again.   
    * Inputs       : String projectNumber 
    * Author       : Dayal
    * Created On   : 28/10/2021
    * Modification Log:  
    * *****************************************************************************/
    
    public static void removeProject(String projectNumber) {
          
        Project__c project  = [Select Id, Name, Project_Number__c, Closeout_Request__c, CloseOut_Task__c from Project__c 
                                     where Project_Number__c =:projectNumber]; 
        
        // retive the project closeout as per project 
        Project_Closeout__c projectCloseout = [Select Id, Name, Project_Name__c, Closeout_Request__c, Closeout_Task__c, Status__c, Total_Amount_Claimed__c from Project_Closeout__c 
                                     where Project_Name__r.Id =:project.Id];
           
         // retive the check list as per project selected
        List<Closeout_Checklist__c> checklist = [ Select Id, Name, Checklist__c, Project__r.Name from  Closeout_Checklist__c
                                                where Project__r.Id =: project.Id];
         
          
        // remove the closoeut request from project closoeut
        projectCloseout.Closeout_Request__c = null;
        projectCloseout.Total_Amount_Claimed__c = null;
        projectCloseout.Status__c = 'Request for Information';
        projectCloseout.Closeout_Task__c = null;
        update projectCloseout;
         
        // remove the project from closoeut request
        project.Closeout_Request__c = null;
        project.Closeout_Task__c = null;
        update project;
 
        // remove the check list from project
        delete checklist;     
      }
}