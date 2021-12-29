/**
 * Created by nehab on 28-10-2020.
 */

public with sharing class ALS_ContactAccounts_Ctrl {

    @AuraEnabled(cacheable=true)
    //Get Contact role data related to Contact record
    public static Map<String, Object> getContactAccountsInfo(String masterRecordId, String refreshDate){
        Map<String, Object> resultMap = new Map<String, Object>();

        List<AccountContactRole__c> getContactAccountsList = [Select Id ,Account_Name__c , Contact_Name__c  ,Contact_Role_Global_List__c , Status__c, Account_Name__r.Name
                                                          From AccountContactRole__c where Contact_Name__c =:masterRecordId]; //Role__c **

        resultMap.put('contactAccounts',getContactAccountsList);
        return resultMap;
    }

    //Call on Delete
    @AuraEnabled
    public Static Map<String,Object> deleteRecords(String recordToDelete){//To Delete selected Contact Role Record

    String objId = recordToDelete;
    Map<String, Object> resultMap = new Map<String, Object>();
    AccountContactRole__c accountContactsRole =[SELECT Id FROM AccountContactRole__c WHERE Id = : objId ] ;
    if (accountContactsRole != null) {
        Delete accountContactsRole;
    }
    return null;
}
}