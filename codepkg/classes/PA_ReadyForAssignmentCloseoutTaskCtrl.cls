/**
* Class Name   : PA_ReadyForAssignmentCloseoutTaskCtrl
* Description  : This class used  to change the status of the closeout task
* Author       : Dayal
* Created On   : 23/06/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             23/06/2021       Initial Implementation
 */

public without sharing class PA_ReadyForAssignmentCloseoutTaskCtrl {

    /***********************************************************************************************
    * Method  Name   : getCloseOutTaskDetails
    * Description    : This method is used to update the closeout task staus 
    * Return         : -
    * Inputs         : String closeOutTaskId
    * Author         : Dayal
    * Created On     : 26/05/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/
   
    @AuraEnabled
    public static void getCloseOutTaskDetails(String closeOutTaskId){

            Closeout_Task__c closeoutTask = new Closeout_Task__c();
            closeoutTask.Id = closeOutTaskId;
            closeoutTask.Status__c = 'Pending Assignment';
            update closeoutTask;
        

    }

}