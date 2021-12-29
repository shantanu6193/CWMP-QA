/**
 * Created by Chandrabhan on 016-04-2021.
 */
public without sharing class MARS_ResourceAgreementHistoryCtrl {
    @AuraEnabled
    public static List<Agency_Rate_Agreement__c> getAgreementHistory(String accountId) {
        return [SELECT Id, Start_Date__c, End_Date__c, Approval_Status__c, Name
                FROM Agency_Rate_Agreement__c WHERE Agency__c=:accountId ORDER BY Start_Date__c,CreatedDate DESC NULLS FIRST LIMIT 10];
                
    }
    @AuraEnabled
    public static List<Agency_Rate_Agreement_Line_Item__c> getAgreementLineItems(String agreementId) {
        return [SELECT Id, End_Date__c,Start_Date__c,PTP__c,OT__c,Status__c,Name,Agency_Rate_Agreement__r.Start_Date__c, Agency_Rate_Agreement__r.End_Date__c
               FROM Agency_Rate_Agreement_Line_Item__c WHERE Agency_Rate_Agreement__c=:agreementId];
    }
    @AuraEnabled
    public static Map<String, Object> getData(String agreementId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('agreementLines', getAgreementLineItems(agreementId));

        Agency_Rate_Agreement__c agreementRec = [SELECT Id, Approval_Status__c, Name,Reject_Reason__c,Level_2_Comments__c,Start_Date__c
                                                    FROM Agency_Rate_Agreement__c WHERE Id=:agreementId LIMIT 1];
        returnMap.put('agreementRec', agreementRec);
        returnMap.put('contentVersions', getContentVersions(new List<String>{agreementId}));
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
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true order by ContentModifiedDate desc];
    }

}