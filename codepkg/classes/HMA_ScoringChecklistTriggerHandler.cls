public without sharing class HMA_ScoringChecklistTriggerHandler extends TriggerHelper {
    public HMA_ScoringChecklistTriggerHandler() {

    }
    // public override void beforeTrigger() {
       
    // }

    public override void processBeforeInsert() {
        beforeTriggerProcess();
        scoringCriteriaScoreValidation((List<Scoring_Checklist__c>) Trigger.New);
    } 
    public override void processAfterInsert() {
        
    }
    public override void processBeforeUpdate() {
        beforeTriggerProcess();
        scoringCriteriaScoreValidation((List<Scoring_Checklist__c>) Trigger.New);
    } 
    public override void processAfterUpdate() {

    }

    public static void populateOESAnalystBriefSummary(Map<Id, List<Scoring_Checklist__c>> applicationIdToScoringChecklistsMap) {
        List<Application__c> applications = [SELECT Id, OES_Analyst_Brief_Summary__c FROM Application__c WHERE Id IN: applicationIdToScoringChecklistsMap.keySet()];
        for(Application__c app : applications) {
            for(Scoring_Checklist__c sc : applicationIdToScoringChecklistsMap.get(app.Id)) {
                sc.OES_Analyst_Brief_Summary__c = app.OES_Analyst_Brief_Summary__c;
            }
        }

    }
    public static void scoringCriteriaScoreValidation(List<Scoring_Checklist__c> scoringChecklist) {
        for(Scoring_Checklist__c sc : scoringChecklist) {
            if(sc.Criteria_1_Score__c > sc.Criteria_1_Maximum_points_Possible__c) {
                sc.Criteria_1_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
            if(sc.Criteria_2_Score__c > sc.Criteria_2_Maximum_points_Possible__c) {
                sc.Criteria_2_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_3_Score__c > sc.Criteria_3_Maximum_points_Possible__c) {
                sc.Criteria_3_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_4_Score__c > sc.Criteria_4_Maximum_points_Possible__c) {
                sc.Criteria_4_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            }
            if(sc.Criteria_5_Score__c > sc.Criteria_5_Maximum_points_Possible__c) {
                sc.Criteria_5_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
            if(sc.Criteria_6_Score__c > sc.Criteria_6_Maximum_points_Possible__c) {
                sc.Criteria_6_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_7_Score__c > sc.Criteria_7_Maximum_points_Possible__c) {
                sc.Criteria_7_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_8_Score__c > sc.Criteria_8_Maximum_points_Possible__c) {
                sc.Criteria_8_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            }
            if(sc.Criteria_9_Score__c > sc.Criteria_9_Maximum_points_Possible__c) {
                sc.Criteria_9_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
            if(sc.Criteria_10_Score__c > sc.Criteria_10_Maximum_points_Possible__c) {
                sc.Criteria_10_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_11_Score__c > sc.Criteria_11_Maximum_points_Possible__c) {
                sc.Criteria_11_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_12_Score__c > sc.Criteria_12_Maximum_points_Possible__c) {
                sc.Criteria_12_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            }
            if(sc.Criteria_13_Score__c > sc.Criteria_13_Maximum_points_Possible__c) {
                sc.Criteria_13_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
            if(sc.Criteria_14_Score__c > sc.Criteria_14_Maximum_points_Possible__c) {
                sc.Criteria_14_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_15_Score__c > sc.Criteria_15_Maximum_points_Possible__c) {
                sc.Criteria_15_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_16_Score__c > sc.Criteria_16_Maximum_points_Possible__c) {
                sc.Criteria_16_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            }
            if(sc.Criteria_17_Score__c > sc.Criteria_17_Maximum_points_Possible__c) {
                sc.Criteria_17_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            }
            if(sc.Criteria_18_Score__c > sc.Criteria_18_Maximum_points_Possible__c) {
                sc.Criteria_18_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
            if(sc.Criteria_19_Score__c > sc.Criteria_19_Maximum_points_Possible__c) {
                sc.Criteria_19_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
             if(sc.Criteria_20_Score__c > sc.Criteria_20_Maximum_points_Possible__c) {
                sc.Criteria_20_Score__c.addError(HMA_CONSTANTS.SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE);
            } 
        }
    }
    public static void linkApplicationExtensionToSC(Map<Id, List<Scoring_Checklist__c>> applicationIdToScoringChecklistsMap) {
        List<Application_Extension__c> applicationExt = [SELECT Id, Application__c FROM Application_Extension__c WHERE Application__c IN: applicationIdToScoringChecklistsMap.keySet()];
        for(Application_Extension__c appExt : applicationExt) {
            for(Scoring_Checklist__c sc : applicationIdToScoringChecklistsMap.get(appExt.Application__c)) {
                sc.Application_Extension__c = appExt.Id;
            }
        }
    }
    public static void beforeTriggerProcess() {
        Map<Id, List<Scoring_Checklist__c>> applicationIdToScoringChecklistsMap = new Map<Id, List<Scoring_Checklist__c>>();
        for(Scoring_Checklist__c sc : (List<Scoring_Checklist__c>) Trigger.New) {
            if(sc.Checklist_Status__c == null) {
                sc.Checklist_Status__c = 'Draft';
            }
            if(String.isNotBlank(sc.Application__c)) {                
                if(applicationIdToScoringChecklistsMap.get(sc.Application__c) == null) {
                    applicationIdToScoringChecklistsMap.put(sc.Application__c, new List<Scoring_Checklist__c>());
                }
                applicationIdToScoringChecklistsMap.get(sc.Application__c).add(sc);
            }
        }
        if(applicationIdToScoringChecklistsMap.size() > 0) {
            populateOESAnalystBriefSummary(applicationIdToScoringChecklistsMap);
            linkApplicationExtensionToSC(applicationIdToScoringChecklistsMap);
        }
    }
}