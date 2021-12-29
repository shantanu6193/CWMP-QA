/***********************************************************************************************************************************
* Class Name   : HH_EventTriggerHandler
* Description  : Handle object trigger operations
* Author       : Ricky
* Created On   : 30/11/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              30/11/2021       Initial Implementation
**************************************************************************************************************************************/
public with sharing class HH_EventTriggerHandler extends TriggerHandler implements TriggerInterface {
    public override void beforeInsert() {
        makeCWMPApplicationRelatedEventRecordPublic();
    }

    /***********************************************
    * Method Name : makeCWMPApplicationRelatedEventRecordPublic
    * Author : Ricky
    * Description: This method is used to make the Event record visible to External user when related Record Id is CWMP Application.
    *********************************************/
    private void makeCWMPApplicationRelatedEventRecordPublic() {
        for (Event eventRecord : (List<Event>)Trigger.new) {
            Id myId = eventRecord.WhatId;
            String sobjectName = myId?.getSobjectType()?.getDescribe()?.getName();
            if (sobjectName == HH_CONSTANTS.HHApplication_Object_APIName) {
                eventRecord.IsVisibleInSelfService = true;
            }
        }
    }
}