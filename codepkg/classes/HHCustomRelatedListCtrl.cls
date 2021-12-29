/**
 * Created by StackNexus Admin on 07-09-2021.
 */

public without sharing class HHCustomRelatedListCtrl {
    @AuraEnabled(cacheable=true)
    //Get Application_Contact__c data related to HH_Application__c record
    public static Map<String, Object> getRecordInfo(String masterRecordId, String filter, String refresh){
        Map<String, Object> resultMap = new Map<String, Object>();
        String query ='Select Id,Name,First_Name__c,Last_Name__c,toLabel(Relationship_to_Homeowner__c), toLabel(Head_of_Household__c), HH_Application__c,Annual_Income__c,Date_of_Birth__c From Application_Contact__c where HH_Application__c ='+'\''+masterRecordId+'\''+' AND '+filter;
        System.debug('Query--- '+query);
        List<Application_Contact__c> getApplicationContactList = Database.query(query);
        resultMap.put('applicationContacts',getApplicationContactList);
        return resultMap;
    }
}