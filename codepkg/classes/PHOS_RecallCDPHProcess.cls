/***********************************************************************************************************************************
* Class Name   : PHOS_RecallCDPHProcess
* Description  : This class for call recall CDPH approval Process
* Author       : Pankaj
* Created On   : 04/03/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/03/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class PHOS_RecallCDPHProcess {

    /***********************************************
    * Method Name : recallCDPHProcess
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method submit records to approval
    *********************************************/
    /*
    @InvocableMethod(label='Recall Request for CDPH' description='Recall Request for CDPH')
    public static void recallCDPHProcess(List<Id> orderIds) {
        if(orderIds !=null && orderIds.size() > 0){
            ProcessInstanceWorkitem[] workItems = [
                    SELECT Id
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :orderIds.get(0)
                    AND ProcessInstance.Status = 'Pending'];

            if(workItems != null && workItems.size() > 0){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction('Removed');
                pwr.setComments('Removed by System');
                pwr.setWorkItemId(workItems[0].id);
                Approval.ProcessResult result = Approval.process(pwr);
            }

        }

    }*/
}