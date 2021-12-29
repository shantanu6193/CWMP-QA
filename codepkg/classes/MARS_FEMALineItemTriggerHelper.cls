/***********************************************************************************************************************************
* Class Name   : MARS_FEMALineItemTriggerHelper
* Description  : This is helper class for FEMA Line Item trigger
* Author       : Chandrabhan
* Created On   : 06/15/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                06/15/2021       Initial Implementation
**************************************************************************************************************************************/


public without sharing class MARS_FEMALineItemTriggerHelper extends TriggerHelper {
    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Chandrabhan
    * Inputs : -
    * Description: This method call after records are updated
    *********************************************/
    public override void processAfterUpdate() {
        updateCFAARecords();
    }

    /***********************************************
    * Method Name : updateCFAARecords
    * Author : Chandrabhan
    * Inputs : -
    * Description: if CFAA Straight Time Rate are changed then update Special Equipment Line Item rate
    *********************************************/
    private void updateCFAARecords() {
        Map<Id, FEMA_Code_LineItem__c> IdFEMALineItemMapBatch = new Map<Id, FEMA_Code_LineItem__c>();
        Map<Id, FEMA_Code_LineItem__c> oldCFAARecord = (Map<Id, FEMA_Code_LineItem__c>)Trigger.oldMap;
        for(FEMA_Code_LineItem__c femaRec : (List<FEMA_Code_LineItem__c>)Trigger.new ) {
            if((oldCFAARecord != null || oldCFAARecord.get(femaRec.Id) != null) && (oldCFAARecord.get(femaRec.Id).Current_Rate__c != femaRec.Current_Rate__c )) {
        	    IdFEMALineItemMapBatch.put(femaRec.Id,femaRec);
            }
        }
        if(IdFEMALineItemMapBatch.size() > 0){
            database.executeBatch(new MARS_FEMAUpdateRate_Batch(IdFEMALineItemMapBatch),200); // Calling batch class.
        }
    }
    
}