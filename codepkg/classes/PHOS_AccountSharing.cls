/***********************************************************************************************************************************
* Class Name   : PHOS_AccountSharing
* Description  : This class for Sharing accounts to region user
* Author       : Pankaj
* Created On   : 11/06/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              11/06/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_AccountSharing {

    /***********************************************
    * Method Name : contactSharingWithMultipleAccounts
    * Author : Pankaj
    * Inputs : List<Id> contactIds
    * Description: This method create account contact relation when click on flow button of contact details page
    *********************************************/
    @InvocableMethod(label='Contact Sharing With Multiple Accounts' description='PHOS User Contact Sharing With Multiple Accounts')
    public static void contactSharingWithMultipleAccounts(List<Id> contactIds) {
        Set<Id> currentAccountSet = new Set<Id>();
        Set<Id> allAccountForACRSet = new Set<Id>();
        for(Contact contactRec:[SELECT Id,AccountId FROM Contact  WHERE Id IN : contactIds]){
            if(contactRec.AccountId  != null){
                currentAccountSet.add(contactRec.AccountId);
            }
        }
        if(currentAccountSet.size() == 0) return;

        for(Account accountRec:[SELECT Id,Name FROM Account  WHERE ParentId IN : currentAccountSet]){
            if(accountRec.Id  != null){
                allAccountForACRSet.add(accountRec.Id);
            }
        }
        if(allAccountForACRSet.size() == 0) return;

        for(Account accountRec:[SELECT Id,Name FROM Account  WHERE ParentId IN : allAccountForACRSet]){
            if(accountRec.Id  != null){
                allAccountForACRSet.add(accountRec.Id);
            }
        }   
        Map<Id, Set<Id>> contactIdWithAccountIds = new Map<Id, Set<Id>>();
        for(AccountContactRelation accountContactRelation : [SELECT AccountId, ContactId ,Id FROM AccountContactRelation
                                                        WHERE AccountId IN : allAccountForACRSet]) {
            if(contactIdWithAccountIds.get(accountContactRelation.ContactId) == null) {
                contactIdWithAccountIds.put(accountContactRelation.ContactId, new Set<Id>());
            }
            contactIdWithAccountIds.get(accountContactRelation.ContactId).add(accountContactRelation.AccountId);
        }
        List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
        for(Id conId : contactIds) {
            Set<Id> existingAccounts = contactIdWithAccountIds.get(conId);
            for (Id accountId : allAccountForACRSet) {
                if(existingAccounts != null && !existingAccounts.isEmpty() && existingAccounts.contains(accountId)) {
                    continue;
                }
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = accountId;
                acr.ContactId = conId;
                accountContactList.add(acr);
            }
        }
        if(accountContactList.size() > 0){
            insert accountContactList ;
        }
    }

}