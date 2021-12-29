/***********************************************************************************************************************************
* Class Name   : DIP_Mark_Lead_Unresponsive_Scheduler
* Description  : This is Schedulable class for DIP mark Lead unresponsive batch
* Author       : Pankaj
* Created On   : 04/23/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             04/23/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class DIP_Mark_Lead_Unresponsive_Scheduler implements Schedulable{


    public void execute(SchedulableContext Sctx) {
        DIP_Mark_Lead_Unresponsive_Batch bc = new DIP_Mark_Lead_Unresponsive_Batch();
        Database.executeBatch(bc,200);
    }
}