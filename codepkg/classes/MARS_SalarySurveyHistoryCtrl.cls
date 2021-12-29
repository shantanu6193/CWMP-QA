/**
 * Created by Pankaj on 08-04-2021.
 */

public without sharing class MARS_SalarySurveyHistoryCtrl {

 
    @AuraEnabled
    public static List<Agency_Salary_Survey__c> getAgencySalarySurveyHistory(String accountId) {
        return [SELECT Id, Start_Date__c, END_Date__c, Status__c, Name
                FROM Agency_Salary_Survey__c WHERE Account__c=:accountId ORDER BY Start_Date__c,CreatedDate DESC NULLS FIRST LIMIT 10];
    }
    @AuraEnabled
    public static List<Salary_Survey_Line_Items__c> getSalarySurveyLineItems(String agencySalarySurveyId) {
        return [SELECT Id, Classification_Title__c,Base_Rates__c,WC_and_or_UI__c,Are_you_adding_WC_UI__c,
                Current_Rate__c,Revised_Rate__c,MOU_MOA__c,P_T_P__c,Effective_Date__c
               FROM Salary_Survey_Line_Items__c WHERE Agency_Salary_Survey__c=:agencySalarySurveyId];
    }
    @AuraEnabled
    public static Map<String, Object> getData(String agencySalarySurveyId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('salarySurveyLines', getSalarySurveyLineItems(agencySalarySurveyId));

        Agency_Salary_Survey__c salarySurvey = [SELECT Id, Status__c, Name, Requested_Effective_Date__c,Reject_Reason__c
                                                FROM Agency_Salary_Survey__c WHERE Id=:agencySalarySurveyId LIMIT 1];
        returnMap.put('salarySurvey', salarySurvey);
        returnMap.put('contentVersions', getContentVersions(new List<String>{agencySalarySurveyId}));
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