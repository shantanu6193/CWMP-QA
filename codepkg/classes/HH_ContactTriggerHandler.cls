/***********************************************************************************************************************************
* Class Name   : ContactTriggerHandler
* Description  : Contact Trigger Handler Class
* Author       : Ricky
* Created On   : 10/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              10/08/2021       Initial Implementation
**************************************************************************************************************************************/

public with sharing class HH_ContactTriggerHandler extends TriggerHandler implements TriggerInterface {
    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Ricky
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void beforeInsert() {
        /** This method is used to copy the Physical Address to Mailing Address,
         * when the "Is Mailing Address Different?" field value is set to "No". */
        copyPhysicalAddressToMailingAddress();
    }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Ricky
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void beforeUpdate() {
        /** This method is used to copy the Physical Address to Mailing Address,
         * when the "Is Mailing Address Different?" field value is set to "No". */
        copyPhysicalAddressToMailingAddress();
    }

    /***********************************************
     * Method Name : copyPhysicalAddressToMailingAddress
     * Author : Ricky
     * Inputs :
     * Description: This method is used to copy the Physical(Other/Payment) Address to Mailing Address,
     *              when the "Is Mailing Address Different?" field value is set to "No".
     ************************************************/
    private void copyPhysicalAddressToMailingAddress() {
        /** Collection to collect the Contact record which needs to be processed. */
        List<Contact> contactToProcessList = new List<Contact>();

        /** While Insert - Collecting only those Contact in which "Is Mailing Address Different?" field value is set to "No". */
        if (Trigger.isInsert) {
            for (Contact contactToProcess : (List<Contact>) Trigger.new) {
                if (contactToProcess.Is_Mailing_Address_Different__c == HH_CONSTANTS.PickList_No) {
                    contactToProcessList.add(contactToProcess);
                }
            }
        }
        /** While Update -
         * 1.1. "Is Mailing Address Different?" field value is changed.
         * 1.2. "Other Street/Payment Street" field value is changed.
         * 1.3. "Other City/Payment City" field value is changed.
         * 1.4. "Other State/Payment State" field value is changed.
         * 1.5. "Other Postal Code/Payment Postal Code" field value is changed.
         * 1.6. "Other Country/Payment Country" field value is changed.
         * 2. New value of "Is Mailing Address Different?" field value is set to "No".
         * Note - The reason for not updating the Mailing Address upon "Is Mailing Address Different?" field value is set to Yes" is that,
         *          User might change the Address at the Same time while updating the Picklist field, then in that case it will erase all the value. */
        if (Trigger.isUpdate) {
            for (Contact contactToProcess : (List<Contact>) Trigger.new) {
                Contact oldRecord = (Contact) Trigger.oldMap.get(contactToProcess.Id);
                if ((contactToProcess.Is_Mailing_Address_Different__c != oldRecord.Is_Mailing_Address_Different__c
                            || contactToProcess.Physical_Street__c != oldRecord.Physical_Street__c
                            || contactToProcess.Physical_City__c != oldRecord.Physical_City__c
                            || contactToProcess.Physical_State__c != oldRecord.Physical_State__c
                            || contactToProcess.Physical_Zip_Postal_Code__c != oldRecord.Physical_Zip_Postal_Code__c
                            || contactToProcess.Physical_Country__c != oldRecord.Physical_Country__c)
                        && contactToProcess.Is_Mailing_Address_Different__c == HH_CONSTANTS.PickList_No) {
                    contactToProcessList.add(contactToProcess);
                }
            }
        }

        if (contactToProcessList?.size() > 0) {
            /** Iterating the "contactToProcessList" collection and copying the Payment Address to Mailing Address. */
            for (Contact contactToProcess : contactToProcessList) { 
                contactToProcess.Is_Mailing_Address_a_Foreign_Address__c = contactToProcess.Is_Physical_Address_a_Foreign_Address__c == null ? null : contactToProcess.Is_Physical_Address_a_Foreign_Address__c;
                contactToProcess.MailingStreet = contactToProcess.Physical_Street__c == null ? null : contactToProcess.Physical_Street__c;
                contactToProcess.MailingCity = contactToProcess.Physical_City__c == null ? null : contactToProcess.Physical_City__c;
                contactToProcess.MailingState = contactToProcess.Physical_State__c == null ? null : contactToProcess.Physical_State__c;
                contactToProcess.MailingPostalCode = contactToProcess.Physical_Zip_Postal_Code__c == null ? null : contactToProcess.Physical_Zip_Postal_Code__c;
                contactToProcess.MailingCountry = contactToProcess.Physical_Country__c == null ? null : contactToProcess.Physical_Country__c;
            }
        }
    }
}