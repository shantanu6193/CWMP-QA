public with sharing class HMA_ApplicationExtensionTriggerCtrl extends TriggerHelper {
    public HMA_ApplicationExtensionTriggerCtrl() {

    }
    public override void processBeforeInsert() {
        Map<Id, Application_Extension__c> appIdToAppExtensionMap = new Map<Id, Application_Extension__c>();
        for(Application_Extension__c appEx : (List<Application_Extension__c>) Trigger.New) {
            if(appEx.Application__c != null) {
                appIdToAppExtensionMap.put(appEx.Application__c, appEx);
            }
        }
        if(appIdToAppExtensionMap.size() > 0) {
            fillAppExtensionFromPreApplication(appIdToAppExtensionMap);
        }
    }

    public override void processAfterInsert() {
        Map<String, List<Application_Extension__c>> filterClauseToAppExMap = new Map<String, List<Application_Extension__c>>();
        createProjectBudgetProjectCost();
        for(Application_Extension__c appEx : (List<Application_Extension__c>) Trigger.New) {
            if(filterClauseToAppExMap.get(HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_APPLICATION_EXTENSION) == null) { 
                filterClauseToAppExMap.put(HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_APPLICATION_EXTENSION, new List<Application_Extension__c>()); 
            }
            filterClauseToAppExMap.get(HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_APPLICATION_EXTENSION).add(appEx);
        }
        if(filterClauseToAppExMap.size() > 0) {
            boolean isDocumentConfigration = HMA_ApplicationHelper.createDocumentsByFilterClause(filterClauseToAppExMap, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_APPLICATION_EXTENSION);
            System.debug('isDocumentConfigration_application_Extension : '+ isDocumentConfigration);
        }
    }

    public override void processAfterUpdate() {
        Set<Id> appIds = new Set<Id>();
        Set<Id> appExtensionIdsForCreateDocumentRecordsOnProjectSites = new Set<Id>();
        Set<Id> appExtensionIdsForDeleteDocumentRecordsOnProjectSites = new Set<Id>();
        for(Application_Extension__c appExt : (List<Application_Extension__c>) Trigger.New) {
            if(appExt.Have_all_specific_sites__c == HMA_CONSTANTS.PICKLIST_VALUE_NO && appExt.Project_Type_Formula__c == HMA_CONSTANTS.PROJECT_TYPE_ACQUISITION_DEMO_RELOCATION) {
                appIds.add(appExt.Application__c); 
            }else if(appExt.Is_plan_encompass_multiple_jurisdictions__c == HMA_CONSTANTS.PICKLIST_VALUE_NO && (appExt.Project_Type_Formula__c == HMA_CONSTANTS.PROJECT_TYPE_NEW_PLAN || appExt.Project_Type_Formula__c == HMA_CONSTANTS.PROJECT_TYPE_PLAN_UPDATE)){
                appIds.add(appExt.Application__c);
            }
            Application_Extension__c oldRecord = (Application_Extension__c) Trigger.oldMap.get(appExt.Id);
            Application_Extension__c newRecord = (Application_Extension__c) Trigger.newMap.get(appExt.Id);
            if(oldRecord.Pre_Event_or_Current_Market_Value__c != appExt.Pre_Event_or_Current_Market_Value__c && appExt.Pre_Event_or_Current_Market_Value__c == HMA_CONSTANTS.PRE_EVENT_VALUE){
                appExtensionIdsForCreateDocumentRecordsOnProjectSites.add(appExt.Id);
            }else if(appExt.Pre_Event_or_Current_Market_Value__c != HMA_CONSTANTS.PRE_EVENT_VALUE){
                appExtensionIdsForDeleteDocumentRecordsOnProjectSites.add(appExt.Id);
            }
        }
        processApplicationRecords(appIds);
        createDocumentRecordsForProjectSite(appExtensionIdsForCreateDocumentRecordsOnProjectSites);
        deleteDocumentRecordsForProjectSite(appExtensionIdsForDeleteDocumentRecordsOnProjectSites);
    }

    private static void processApplicationRecords(Set<Id> appIds) {
        if(appIds?.size() > 0) {
            delete [SELECT Id FROM Project_Site__c WHERE Application__c IN :appIds];
        }
    }

    private static void createDocumentRecordsForProjectSite(Set<Id> applicationExtensionId){
        Map<String, List<Project_Site__c>> filterClauseToProjectSiteMap = new Map<String, List<Project_Site__c>>();
        // FEMA Form 009-3
        //Signed Duplication of Benefits Affidavit
        if(applicationExtensionId?.size() == 0) return;
        Project_Site__c[] projectSites = [SELECT Id,Application__c, Application_Extension__c from Project_Site__c WHERE Application_Extension__c IN:applicationExtensionId];
        if(projectSites?.size() == 0) return;
        for(Project_Site__c objRec : projectSites) {
            if(filterClauseToProjectSiteMap.get(HMA_CONSTANTS.PRE_EVENT_VALUE) == null) { 
                filterClauseToProjectSiteMap.put(HMA_CONSTANTS.PRE_EVENT_VALUE, new List<Project_Site__c>()); 
            }
            filterClauseToProjectSiteMap.get(HMA_CONSTANTS.PRE_EVENT_VALUE).add(objRec);
        }
        if(filterClauseToProjectSiteMap.size() > 0) {
            boolean isDocumentConfigration = HMA_ApplicationHelper.createDocumentsByFilterClause(filterClauseToProjectSiteMap, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_PROJECT_SITE);
            System.debug('isDocumentConfigration_createDocumentRecordsForProjectSite : '+ isDocumentConfigration);
        }
        //TODO : Project filter clause should be dynamic
        //DocumentUploadCtrl.checkProDocConfigAndCreateDocuments(projectSites, HMA_CONSTANTS.PRE_EVENT_VALUE, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_PROJECT_SITE);

    }
    private static void deleteDocumentRecordsForProjectSite(Set<Id> applicationExtensionId){
        /**It will delete FEMA Form 009-3 AND Signed Duplication of Benefits Affidavit**/
        if(applicationExtensionId?.size() == 0) return;
        Set<String> docTypeToDelete = new Set<String>{'FEMA Form 009-0-3', 'Signed Duplication of Benefits Affidavit' };
        Delete [SELECT Id from Document__c WHERE Project_Site__r.Application_Extension__c IN:applicationExtensionId AND Document_Name__c IN:docTypeToDelete];
    }


    //This method creates project budget and project cost record for each application and each project budget.
    public static void createProjectBudgetProjectCost() {
        try{
            List<Project_Budget__c> projectBudgetList = new List<Project_Budget__c>();
            for(Application_Extension__c appExtension: (List<Application_Extension__c>) Trigger.new){
                projectBudgetList.add(new Project_Budget__c(Application_Extension__c = appExtension.Id, Application__c = appExtension.Application__c, Type__c=HMA_CONSTANTS.PROJECT_BUDGET_TYPE_MANAGEMENT_COST));
                projectBudgetList.add(new Project_Budget__c(Application_Extension__c = appExtension.Id, Application__c = appExtension.Application__c, Type__c=HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT));
            }
            if(projectBudgetList.size() > 0){
                insert projectBudgetList;
                Id managementCostRecordTypeId = Schema.SObjectType.Project_Cost__c.getRecordTypeInfosByDeveloperName()
                                    .get(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_MANAGEMENT_COST).getRecordTypeId();
                Id projectRecordTypeId = Schema.SObjectType.Project_Cost__c.getRecordTypeInfosByDeveloperName()
                                    .get(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT).getRecordTypeId();
                List<Project_Cost__c> projectCostList = new List<Project_Cost__c>();
                for(Project_Budget__c pb : projectBudgetList) {
                    if(String.isNotBlank(pb.Type__c) && pb.Type__c.equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_MANAGEMENT_COST)) {
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_PRE_AWARD, RecordTypeId=managementCostRecordTypeId));
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_STAFF_TIME, RecordTypeId=managementCostRecordTypeId));
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_TRAVEL_EXPENSES, RecordTypeId=managementCostRecordTypeId));
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_EQUIPMENT_EXPENSES, RecordTypeId=managementCostRecordTypeId));
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_SUPPLIES, RecordTypeId=managementCostRecordTypeId));
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_INDIRECT_COST, RecordTypeId=managementCostRecordTypeId));
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, Type__c=HMA_CONSTANTS.PROJECT_COST_TYPE_OTHER, RecordTypeId=managementCostRecordTypeId));
                    } else {
                        projectCostList.add(new Project_Cost__c(Project_Budget__c = pb.Id, RecordTypeId=projectRecordTypeId));
                    }
                }
                insert projectCostList;
            }
        } catch(System.DmlException e) {
            throw new CustomExceptionController.CustomMessageException(e.getMessage());
        } catch(System.NullpointerException e) {
            throw new CustomExceptionController.CustomMessageException(e.getMessage());
        }
    }
    /*Set Pre_Application field values to Application Extension */
    public static void fillAppExtensionFromPreApplication(Map<Id, Application_Extension__c> appIdToAppExtensionMap) {
        Map<Id, Application__c> appDetails = new Map<Id, Application__c>([SELECT Id, Pre_Application__r.Percentage_Level_Of_Design__c,Pre_Application__r.Is_Project_Site_Identified__c
        FROM Application__c WHERE Id IN: appIdToAppExtensionMap.keySet() AND Pre_Application__c != null]);

        for(Application_Extension__c appExt: (List<Application_Extension__c>)Trigger.new){
            if(String.isNotEmpty(appExt.Application__c)){
                Application__c application = appDetails.get(appExt.Application__c);
                if(application.Pre_Application__r.Percentage_Level_Of_Design__c != null) {
                    appExt.Percentage_Level_Of_Design__c = application.Pre_Application__r.Percentage_Level_Of_Design__c;
                }
                if(application.Pre_Application__r.Is_Project_Site_Identified__c != null) {
                    appExt.Have_all_specific_sites__c = application.Pre_Application__r.Is_Project_Site_Identified__c;
                }
            }
        }
    }
}