@isTest 
public with sharing class HMA_ScoringChecklistTriggerTest {
    @isTest public static void testInsertScoringChecklist() {
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Application_Extension__c appExtension = HMA_TestHelper.getApplicationExension(true, newApplication.Id);

        Test.startTest();
        Scoring_Checklist__c sc = HMA_TestHelper.getScoringChecklist(true, newApplication.Id, appExtension.Id);
        sc.Checklist_Status__c = null;
        update sc;
        
        sc.Criteria_1_Score__c  = 20;
        sc.Criteria_1_Maximum_points_Possible__c = 10;

        sc.Criteria_2_Score__c   = 20;
        sc.Criteria_2_Maximum_points_Possible__c = 10;

        sc.Criteria_3_Score__c   = 20;
        sc.Criteria_3_Maximum_points_Possible__c = 10;
        
        sc.Criteria_4_Score__c   = 20;
        sc.Criteria_4_Maximum_points_Possible__c = 10;

        sc.Criteria_5_Score__c   = 20;
        sc.Criteria_5_Maximum_points_Possible__c = 10;

        sc.Criteria_6_Score__c   = 20;
        sc.Criteria_6_Maximum_points_Possible__c = 10;

        sc.Criteria_7_Score__c   = 20;
        sc.Criteria_7_Maximum_points_Possible__c = 10;

        sc.Criteria_8_Score__c   = 20;
        sc.Criteria_8_Maximum_points_Possible__c = 10;

        sc.Criteria_9_Score__c   = 20;
        sc.Criteria_9_Maximum_points_Possible__c = 10;

        sc.Criteria_10_Score__c   = 20;
        sc.Criteria_10_Maximum_points_Possible__c = 10;

        sc.Criteria_11_Score__c   = 20;
        sc.Criteria_11_Maximum_points_Possible__c = 10;

        sc.Criteria_12_Score__c   = 20;
        sc.Criteria_12_Maximum_points_Possible__c = 10;

        sc.Criteria_13_Score__c   = 20;
        sc.Criteria_13_Maximum_points_Possible__c = 10;

        sc.Criteria_14_Score__c   = 20;
        sc.Criteria_14_Maximum_points_Possible__c = 10;

        sc.Criteria_15_Score__c   = 20;
        sc.Criteria_15_Maximum_points_Possible__c = 10;

        sc.Criteria_16_Score__c   = 20;
        sc.Criteria_16_Maximum_points_Possible__c = 10;

        sc.Criteria_17_Score__c   = 20;
        sc.Criteria_17_Maximum_points_Possible__c = 10;

        sc.Criteria_18_Score__c   = 20;
        sc.Criteria_18_Maximum_points_Possible__c = 10;

        sc.Criteria_19_Score__c   = 20;
        sc.Criteria_19_Maximum_points_Possible__c = 10;

        sc.Criteria_20_Score__c   = 20;
        sc.Criteria_20_Maximum_points_Possible__c = 10;

        try{
            update sc;
        } catch(Exception e) {
            System.assert(e.getMessage().contains('Score should not more than Maximum Points'));
        }
        
        Test.stopTest();
    }
    @isTest public static void testInsertScoringChecklist1() {
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Application_Extension__c appExtension = HMA_TestHelper.getApplicationExension(true, newApplication.Id);

        Test.startTest();
        Scoring_Checklist__c sc = HMA_TestHelper.getScoringChecklist(false, newApplication.Id, appExtension.Id);
        insert sc;
        Test.stopTest();
    }
}