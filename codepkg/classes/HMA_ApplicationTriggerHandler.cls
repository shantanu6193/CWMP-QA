public with sharing class HMA_ApplicationTriggerHandler extends TriggerHelper {
    //private ApplicationValidationRuleHandler validationRuleHandler;
    Set<String> preAppIds = new Set<String>();
    public HMA_ApplicationTriggerHandler() {
        
    }

    public override void processBeforeInsert() {
        
    } 
    public override void processAfterInsert() {
        //TODO: Add HMGP record type check
        Map<Id, String> appIdToAppProjectType = new Map<Id, String>();
        Map<Id, String> appIdToSubApplicationTypeMap = new Map<Id, String>();
        Map<Id, Application__c> preAppIdToApplicationMap = new Map<iD, Application__c>();
        Map<Id, Application__c> applicationIdToApplicationMap = new Map<iD, Application__c>();
        
        if(Trigger.newMap.keySet().size() > 0) {
            HMA_ApplicationHelper.processToCreateWSAndWSLI(Trigger.newMap.keySet());
            //HMA_ApplicationHelper.createProjectBudgetProjectCost(Trigger.newMap.keySet());
        }
        for(Application__c app : (List<Application__c>) Trigger.New) {
            if(app.Pre_Application__c != null) {
                preAppIdToApplicationMap.put(app.Pre_Application__c, app); 
            }
            
            appIdToAppProjectType.put(app.Id, app.Project_Type__c);
            appIdToSubApplicationTypeMap.put(app.Id, app.Application_Type__c);
            applicationIdToApplicationMap.put(app.Id, app);
            preAppIds.add(app.Pre_Application__c);
        }
        if(appIdToAppProjectType.size() > 0) {
            HMA_ApplicationHelper.createApplicationExtension(appIdToAppProjectType, appIdToSubApplicationTypeMap);
        }
        createDocumentsForApplicationRecords();
        /** Creating Application Contact Role */
        if(preAppIdToApplicationMap.size() > 0) {
            HMA_ApplicationHelper.checkACRoleAndCreateContactRoleForApplication(preAppIdToApplicationMap);
        }       
        

        /** This method is used for check User is present or not for Contact of AccountContactRole
         * for User check is Community Application User present or not, if not create it and if present update it
         * For User Share Application records with specified user
         * For Contact Create Community Application User records
         */
        HMA_ApplicationHelper.checkUserAndCreateCommunityApplicationUser(Trigger.newMap.keySet());
        
        /** Send Email to Contact Role(Responsible Representative and Requestor) */
        //HMA_ApplicationHelper.prepareForSubApplicationApprovalEmail(applicationIdToApplicationMap);
    }

    private void createDocumentsForApplicationRecords(){
        /*To create application Record related documents*/
        Map<String, List<Application__c>> filterClauseToApplicationMap = new Map<String, List<Application__c>>();
        /*Key="Application" is default value and filter clause to get Application related documents from Program Document Object*/
        filterClauseToApplicationMap.put('Application', new List<Application__c>());
        filterClauseToApplicationMap.get('Application').addAll((List<Application__c>)Trigger.new);
        /*It will create configured doc for application and share with community user*/
        HMA_ApplicationHelper.createDocumentsByFilterClause(filterClauseToApplicationMap, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_APPLICATION);
    }
    public override void processBeforeUpdate() {
        List<Application__c> femaApplications = new List<Application__c>();
        for(Application__c newApp : (List<Application__c>) Trigger.New) {
             /**Validate some fields when user changed Application status to FEMA Review */
             if(newApp.Status__c.equals(HMA_CONSTANTS.APPLICATION_STATUS_FEMA_REVIEW)) {
                femaApplications.add(newApp);
            }
        }
        /**Validate some fields when user changed Application status to FEMA Review */
        if(femaApplications.size() > 0) {
            HMA_ApplicationHelper.validateAppWhenStatusIsFEMAReview(femaApplications);
        }
    } 
    public override void processAfterUpdate() {
        Map<Id, Application__c> applicationIdToApplicationMap = new Map<Id, Application__c>();
        //Set for getting the FEMA Review applications
        Set<Id> statusFEMAReviewAppIds = new Set<Id>();
        for(Application__c app : (List<Application__c>) Trigger.New) {
                Application__c oldApp = (Application__c) trigger.oldMap.get(app.Id);
                Application__c newApp = (Application__c) trigger.newMap.get(app.Id);
                /**
                 * If application OES Analyst Brief Summary is changed 
                 * */
                if(oldApp.OES_Analyst_Brief_Summary__c != newApp.OES_Analyst_Brief_Summary__c) {
                    applicationIdToApplicationMap.put(app.Id, App);                    
                }

                /**
                 * If application status is changed to FEMA Review and Status is changed to FEMA Decision
                 * Fema Review to fema decision no invitation required 
                 * */
                if(oldApp.Status__c != HMA_CONSTANTS.APPLICATION_STATUS_FEMA_REVIEW && newApp.Status__c.equals(HMA_CONSTANTS.APPLICATION_STATUS_FEMA_REVIEW)) {
                            statusFEMAReviewAppIds.add(newApp.Id);
                }
        }
        /**
         * If any applications have status as FEMA Review then check AccountContactJunction for them and process them accordingly
         */
        if(statusFEMAReviewAppIds.size() > 0) {
            HMA_ApplicationHelper.processApplicationsForFEMA(statusFEMAReviewAppIds);
        }
        if(applicationIdToApplicationMap.size() > 0) {
            HMA_ApplicationHelper.updateScoringChecklistOESBriefSummary(applicationIdToApplicationMap);
        }
    }

}