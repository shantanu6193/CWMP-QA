/**
 * Created by Chandrabhan on 016-04-2021.
 */
public without sharing class MARS_AdministrativeRateHistoryCtrl {
    @AuraEnabled
    public static List<Agency_Admin_Rates__c> getAdminRateHistory(String accountId) {
        return [SELECT Id, Start_Date__c, End_Date__c, Approval_Status__c, Name
                FROM Agency_Admin_Rates__c WHERE Agency__c=:accountId ORDER BY Start_Date__c,CreatedDate DESC NULLS FIRST LIMIT 10];
                
    }
    @AuraEnabled
    public static List<Agency_Admin_Line_Items__c> getAdminRateLineItems(String agencyAdminRateId) {
        return [SELECT Id, Direct__c,Indirect__c,Effective_Date__c,Name,Status__c,Total__c
               FROM Agency_Admin_Line_Items__c WHERE Agency_Administrative_Rates__c=:agencyAdminRateId];
    }
    @AuraEnabled
    public static Map<String, Object> getData(String agencyAdminRateId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('adminRateLines', getAdminRateLineItems(agencyAdminRateId));

        Agency_Admin_Rates__c agencyAdminRate = [SELECT Id, Approval_Status__c, Name,Reject_Reason__c,Administrative_Total_Indirect_Direct__c,
                                                Administrative_Rate_Indirect_Cost_Direct__c, Total_Direct_Amount__c,Total_Indirect_Amount__c,Start_Date__c
                                                FROM Agency_Admin_Rates__c WHERE Id=:agencyAdminRateId LIMIT 1];
        returnMap.put('agencyAdminRate', agencyAdminRate);
        returnMap.put('contentVersions', getContentVersions(new List<String>{agencyAdminRateId}));
        return returnMap;
    }
    private static List<ContentVersion> getContentVersions(List<String> recordIds) {
        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        system.debug('==contentDocIds==='+contentDocIds);
        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true AND (NOT Title LIKE '%signature%') order by ContentModifiedDate desc];
    }
}