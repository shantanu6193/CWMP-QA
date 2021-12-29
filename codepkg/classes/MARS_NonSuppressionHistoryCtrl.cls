public without sharing class MARS_NonSuppressionHistoryCtrl {
    
    @AuraEnabled
    public static List<Agency_Non_Suppression_Personnel__c > getAgencyNonSuppressionHistory(String accountId) {
        return [SELECT Id, Start_Date__c, End_Date__c, Approval_Status__c, Name, Reject_Reason__c
                FROM Agency_Non_Suppression_Personnel__c WHERE Agency__c=:accountId ORDER BY Start_Date__c,CreatedDate DESC NULLS FIRST LIMIT 10];
    }
    
    @AuraEnabled
    public static List<Agency_Non_Suppression_Line_Item__c > getAgencyNonSuppressionLineItems(String agencyNonSuppId) {
        return [SELECT Id, Classification_Title__c,Revised_Rate__c,MOU_MOA_GBR__c,
                Current_Rate__c,Effective_Date__c
               FROM Agency_Non_Suppression_Line_Item__c  WHERE Agency_Non_Suppression_Personnel__c=:agencyNonSuppId];
    }
    
    @AuraEnabled
    public static Map<String, Object> getData(String agencyNonSuppId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('nonSuppLines', getAgencyNonSuppressionLineItems(agencyNonSuppId));

        Agency_Non_Suppression_Personnel__c nonSuppSurvey = [SELECT Id, Approval_Status__c, Name,Reject_Reason__c,Start_Date__c
                                                FROM Agency_Non_Suppression_Personnel__c WHERE Id=:agencyNonSuppId LIMIT 1];
        returnMap.put('nonSuppSurvey', nonSuppSurvey);
        returnMap.put('contentVersions', getContentVersions(new List<String>{agencyNonSuppId}));
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