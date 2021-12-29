/***********************************************************************************************************************************
* Class Name   : HH_EmailMessageTriggerHandler
* Description  : Handle object trigger operations
* Author       : Ricky
* Created On   : 09/12/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              09/12/2021       Initial Implementation
**************************************************************************************************************************************/
public with sharing class HH_EmailMessageTriggerHandler extends TriggerHandler implements TriggerInterface {
    public override void beforeInsert() {
        /** This method is used to make the Email message visible to External user when related Record Id is CWMP Application.  */
        makeCWMPApplicationRelatedEmailMessageRecordPublic();
    }

    /***********************************************
    * Method Name : makeCWMPApplicationRelatedEmailMessageRecordPublic
    * Author : Ricky
    * Description: This method is used to make the Email message visible to External user when related Record Id is CWMP Application.
    *********************************************/
    private void makeCWMPApplicationRelatedEmailMessageRecordPublic() {
        for (EmailMessage emailMessageRecord : (List<EmailMessage>)Trigger.new) {
            Id myId = emailMessageRecord.RelatedToId;
            String sobjectName = myId?.getSobjectType()?.getDescribe()?.getName();
            if (sobjectName == HH_CONSTANTS.HHApplication_Object_APIName) {
                emailMessageRecord.IsExternallyVisible = true;
            }
        }
    }
}