public without sharing class MARS_AgencyPageTabCtrl {

    @AuraEnabled
    public static Map<String, Object> getData(String recordId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Account accountInfo = [SELECT Id,Name,Entity_Type__c, Chief_Name__c,MACS_ID__c from Account WHERE Id =:recordId];
        returnMap.put('accountInfo', AccountInfo);
        return returnMap;
    }
}