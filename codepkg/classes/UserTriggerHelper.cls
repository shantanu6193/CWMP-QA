/***********************************************************************************************************************************
* Class Name   : UserTriggerHelper
* Description  : This is helper class for user trigger
* Author       : Pankaj
* Created On   : 04/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                04/09/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class UserTriggerHelper extends TriggerHelper {
    
    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are inserted and update the contact
    *********************************************/
    /*
    public override void   processAfterInsert() {
        List<String> accountNames = new List<String>();
        for (User userRec : (List<User>)Trigger.new) {
            if(String.isNotEmpty(userRec.ContactId) && String.isNotEmpty(userRec.County__c)) {
                accountNames.add(userRec.County__c);
            }
        }

        if (accountNames.size() > 0) {
            Map<String, Account> accountByName = new Map<String, Account>();
            List<Account> accounts = [SELECT Id,Name FROM Account WHERE Name IN :accountNames];
            for (Account account : accounts) {
                accountByName.put(account.Name, account);
            }
            List<Contact> contactsToUpdate = new List<Contact>();
            for (User userRec : (List<User>)Trigger.new) {
                if(String.isNotEmpty(userRec.ContactId) && String.isNotEmpty(userRec.County__c)) {
                    contactsToUpdate.add(new Contact(Id=userRec.ContactId, AccountId=accountByName.get(userRec.County__c).Id));
                }
            }
            //System.assertEquals('contactsToUpdate--', String.valueOf(contactsToUpdate));
            updateContacts(JSON.serialize(contactsToUpdate));
            //update contactsToUpdate;
        }
    }

    @Future
    public static void updateContacts(String contactJSON) {
        List<Contact> contacts = (List<Contact>)JSON.deserialize(contactJSON, List<Contact>.class);
        update contacts;
    }
    */

}