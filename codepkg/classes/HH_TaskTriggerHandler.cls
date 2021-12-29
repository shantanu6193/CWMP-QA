/***********************************************************************************************************************************
* Class Name   : HH_TaskTriggerHandler
* Description  : Handle object trigger operations
* Author       : Ricky
* Created On   : 30/11/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              30/11/2021       Initial Implementation
**************************************************************************************************************************************/
public with sharing class HH_TaskTriggerHandler  extends TriggerHandler implements TriggerInterface {

    public override void beforeInsert() {
        makeCWMPApplicationRelatedTaskRecordPublic();
    }

    /***********************************************
    * Method Name : makeCWMPApplicationRelatedTaskRecordPublic
    * Author : Ricky
    * Description: This method is used to make the Task record visible to External user when related Record Id is CWMP Application.
    *********************************************/
    private void makeCWMPApplicationRelatedTaskRecordPublic() {
        for (Task taskRecord : (List<Task>)Trigger.new) {
            Id myId = taskRecord.WhatId;
            String sobjectName = myId?.getSobjectType()?.getDescribe()?.getName();
            if (sobjectName == HH_CONSTANTS.HHApplication_Object_APIName) {
                taskRecord.IsVisibleInSelfService = true;
            }
        }
    }
}