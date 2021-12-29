/**
 * Created by Nehab.
 */

public with sharing class ALS_AccountContacts_Ctrl {
    @AuraEnabled(cacheable=true)
    //Get Contact Role Details related to current Account Id.
    public static Map<String, Object> getAccountContactsInfo(String masterRecordId ,String refreshDate){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<AccountContactRole__c> getAccountContactsList = [Select Id ,Account_Name__c , Contact_Name__c, Contact_Name__r.FirstName ,
                                                          Contact_Name__r.LastName , Contact_Name__r.Title ,Contact_Role_Global_List__c, Contact_Name__r.Name , Status__c
                                                          From AccountContactRole__c where Account_Name__c = : masterRecordId]; //Role__c **

        resultMap.put('accountContacts',getAccountContactsList);
        return resultMap;
    }

    //Delete selected Records
    @AuraEnabled
    public Static Map<String,Object> deleteRecords(String recordToDelete){
        String objId = recordToDelete;
        Map<String, Object> resultMap = new Map<String, Object>();
        AccountContactRole__c accountContactsRole =[SELECT Id FROM AccountContactRole__c WHERE Id = : objId ] ;
        if (accountContactsRole != null) {
           Delete accountContactsRole;
        }
        return null;
    }
    }