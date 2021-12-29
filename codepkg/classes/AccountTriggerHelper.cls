/***********************************************************************************************************************************
* Class Name   : AccountTriggerHelper
* Description  : AccountTriggerHelper Class to avoid duplicate accounts  
* Author       : Pankaj
* Created On   : 03/11/2020 
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            03/11/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class AccountTriggerHelper extends TriggerHelper{

    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : Trigger.new
    * Description: Execute Method which will checks the new account name and entity Id are not same as existing account.
    *********************************************/ 
    public override void processBeforeInsert() {
        Map<String, String> accountMap = new Map<String, String>();
        for(Account acc : (List<Account>)Trigger.new) {
            if(String.isNotBlank(acc.Entity_Id__c) && String.isNotBlank(acc.Name)) {
                accountMap.put(acc.Entity_Id__c, acc.Name);
            }
        }
        List<Account> accList = [SELECT Id, Name from Account where Entity_Id__c In: accountMap.keySet() AND Name In: accountMap.values()];
        if(accList.size() > 0) {
            for(Account acc : (List<Account>)Trigger.new) {
                acc.addError('Account with same name and entity Id exists, please choose existing account');
            }
        }
        insertUpdateParentAccount();
    }
     /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void processBeforeUpdate()  {
        insertUpdateParentAccount();
    } 

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Ricky
    * Inputs : -
    * Description: This method call after records are updating
    *********************************************/
    public override void processAfterUpdate() {
        updateIncidentSubSummaryNameUponFIPSChange();
    }

        /***********************************************
    * Method Name : insertUpdateShipmentOrder
    * Author : Pankaj
    * Inputs : -
    * Description: This method populate parent Id and Account OwnerId
    *********************************************/
    private  void insertUpdateParentAccount(){
        String sopNonGOVAccountId = KeyValueHelper.getTextValue('SOC_OPS_Non_Government_Parent_Id');
        String sopGOVAccountId = KeyValueHelper.getTextValue('SOC_OPS_Government_Parent_Id');
        String accountOwnerUser = KeyValueHelper.getTextValue('CRM_Admin_User');
        for(Account acc :  (List<Account>)Trigger.new){
            if(acc.Entity_Type__c == 'Non-Governmental Entity'){
                acc.ParentId = sopNonGOVAccountId;
            } else if(acc.Entity_Type__c == 'State Agency') {
                acc.ParentId = sopGOVAccountId;
            }
           acc.OwnerId = accountOwnerUser;
        }
    }

    /***********************************************
     * Method Name : updateIncidentSubSummaryNameUponFIPSChange
     * Author : Ricky
     * Inputs :
     * Description: This method updates the related Incident Sub Recipient Summary record Name upon FIPS ID update of Account record.
     *              Incident Sub Recipient Summary Name - "Declaration Number(Incident) - FIPS(Sub Recipient/Account)"
     *  *********************************************/
    private void updateIncidentSubSummaryNameUponFIPSChange() {
        List<Id> subRecipientIds = new List<Id>(); // Collection to collect the Account Ids whose FIPS Id has been changed.
        // Iterating Trigger.new collection to check if the FIPS Id of the record is changed.
        for (Account account : (List<Account>) Trigger.new) {
            Account oldRecord = (Account) Trigger.oldMap.get(account.Id);
            if (oldRecord.Sub_Recipient_FIPS__c != account.Sub_Recipient_FIPS__c) {
                subRecipientIds.add(account.Id);
            }
        }
        // Calling the Utility class to update the related Incident Sub Recipient records names.
        if (subRecipientIds?.size() > 0) {
            REAL_IncSubSummaryUtility summaryUtility = new REAL_IncSubSummaryUtility();
            summaryUtility.updateSummaryName(null, subRecipientIds);
        }
    }
}