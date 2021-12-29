public without sharing class HMA_ProjectSiteTriggerHandler extends TriggerHelper {

    public override void processBeforeInsert()  {
        
    }

    public override void processBeforeDelete() {

    }

    public override void processAfterDelete() {
        Set<Id> appIds = new Set<Id>();
        for(Project_Site__c projectSiteDeleted : (List<Project_Site__c>) Trigger.Old) {
            appIds.add(projectSiteDeleted.Application__c);
        }
        processNumProjectSites(appIds);
    }

    public override void processAfterInsert()  {
        List<Project_Site__c> projectSites = new List<Project_Site__c>();
        List<Project_Site__c> projectSitesPreEvent = new List<Project_Site__c>();
        Map<String, List<Project_Site__c>> projectTypeToSiteMap = new Map<String, List<Project_Site__c>>();
        Map<Id, Set<Id>> applicationIdToProjectSiteIdsMap = new Map<Id, Set<Id>>();
        Set<Id> applicationIds = new Set<Id>();
        for(Project_Site__c projectSite : (List<Project_Site__c>) Trigger.New) {
            applicationIds.add(projectSite.Application__c);
            projectSites.add(projectSite);  //*******TODO : Use Project filter clause
            if(String.isNotEmpty(projectSite.Project_Type_formula__c)) {
                if(projectTypeToSiteMap.get(projectSite.Project_Type_formula__c) == null) { 
                    projectTypeToSiteMap.put(projectSite.Project_Type_formula__c, new List<Project_Site__c>()); 
                }
                projectTypeToSiteMap.get(projectSite.Project_Type_formula__c).add(projectSite);
            }
            /** Map for share ProjectSite Documents With Roles */
            if(applicationIdToProjectSiteIdsMap.get(projectSite.Application__c) == null) { 
                applicationIdToProjectSiteIdsMap.put(projectSite.Application__c, new Set<Id>()); 
            }
            applicationIdToProjectSiteIdsMap.get(projectSite.Application__c).add(projectSite.Id);

            /*If only Pre-Event*/
            if(projectSite.Pre_Event_or_Current_Market_Value_F__c == HMA_CONSTANTS.PRE_EVENT_VALUE){
                projectSitesPreEvent.add(projectSite);
            }
        }

        processNumProjectSites(applicationIds);
        if(projectSites.size() > 0) {
            //TODO : Project filter clause should be dynamic            
            //DocumentUploadCtrl.checkProDocConfigAndCreateDocuments(projectSites, HMA_CONSTANTS.PROJECT_TYPE_ACQUISITION_DEMO_RELOCATION, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_PROJECT_SITE);
        }
        if(projectTypeToSiteMap.size() > 0) {  //TODO : Change to generic methos
                HMA_ApplicationHelper.createDocumentRecForProjectSite(projectTypeToSiteMap, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_PROJECT_SITE);
        }
        createDocumentRecordsForProjectSite(projectSitesPreEvent);

        /** Share Project Site Document Records with contact which having Role as 'Responsible Representative', 'Primary Contact', 'Contributor' */
        shareProjectSiteDocumentsWithRoles(applicationIdToProjectSiteIdsMap);
    }

    private static void createDocumentRecordsForProjectSite(Project_Site__c[] projectSites){
        Map<String, List<Project_Site__c>> filterClauseToProjectSiteMap = new Map<String, List<Project_Site__c>>();
        // FEMA Form 009-3
        //Signed Duplication of Benefits Affidavit
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
        //DocumentUploadCtrl.checkProDocConfigAndCreateDocuments(projectSites, HMA_CONSTANTS.PRE_EVENT_VALUE, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_PROJECT_SITE);

    }

    //This method processes application records when project sites are inserted or deleted.
    private static void processNumProjectSites(Set<Id> appIds) {
        if(appIds?.size() == 0) return;
        List<Application__c> applicationListToBeUpdated = [SELECT Id, No_of_Project_Sites__c, (SELECT Id FROM Project_Sites__r) 
                                                            FROM Application__c WHERE Id in :appIds];
        for(Application__c app : applicationListToBeUpdated) {
            app.No_of_Project_Sites__c = app.Project_Sites__r?.size();
        }
        update applicationListToBeUpdated;
    }

    public static void shareProjectSiteDocumentsWithRoles(Map<Id, Set<Id>> applicationIdToProjectSiteIdsMap) {
        Map<Id, Set<Id>> SObjectIdToUserIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> projectSiteIdToUserIdsMap = new Map<Id, Set<Id>>();

        Map<Id, Set<Id>> contactIdToProjectSiteIdsMap = prepareContactIdToRelatedProjectSites(applicationIdToProjectSiteIdsMap);
        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId IN: contactIdToProjectSiteIdsMap.keySet()];
        for(User u : userList) {
            if(u.Id != UserInfo.getUserId()) {
                for(Id projectSiteId : contactIdToProjectSiteIdsMap.get(u.ContactId)) {
                    if(projectSiteIdToUserIdsMap.get(projectSiteId) == null) {
                        projectSiteIdToUserIdsMap.put(projectSiteId, new Set<Id>());
                    }
                    projectSiteIdToUserIdsMap.get(projectSiteId).add(u.Id);
                }
            }            
        }
        List<Document__c> docList = [SELECT Id, Project_Site__c FROM Document__c WHERE Project_Site__c IN: projectSiteIdToUserIdsMap.keySet()];
        for(Document__c doc : docList) {
            if(SObjectIdToUserIds.get(doc.Id) == null) {
                SObjectIdToUserIds.put(doc.Id, new Set<Id>());
            }
            SObjectIdToUserIds.get(doc.Id).addAll(projectSiteIdToUserIdsMap.get(doc.Project_Site__c));
        }
        /** Share the Document record with specific User */
        System.debug('SObjectIdToUserIds-------------'+ SObjectIdToUserIds);
        if(SObjectIdToUserIds.size() > 0) {
            Boolean isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(SObjectIdToUserIds, 'Document__share', 'Edit', Schema.Document__share.RowCause.Manual);
            
            if(isRecordShared) {
                System.debug('Project Site Document Records shared Successfully.');
            }
        }
    }
    public static Map<Id, Set<Id>> prepareContactIdToRelatedProjectSites(Map<Id, Set<Id>> applicationIdToProjectSiteIdsMap) {
        Map<Id, Set<Id>> contactIdToProjectSiteIdsMap = new Map<Id,Set<Id>>();
        List<Contact_Role__c > conRoles = [SELECT   
                                                Id, 
                                                Contact__c, 
                                                AccountContactJunction__c, 
                                                AccountContactJunction__r.Contact_Name__c, 
                                                AccountContactJunction__r.Contact_Name__r.Email, 
                                                Application__c 
                                                FROM Contact_Role__c  
                                                WHERE Application__c IN: applicationIdToProjectSiteIdsMap.keySet() 
                                                AND Role__c includes('Responsible Representative', 'Primary Contact', 'Contributor')];

        for(Contact_Role__c role : conRoles) {
            if(String.isNotEmpty(role.AccountContactJunction__r.Contact_Name__c)) {
                if(contactIdToProjectSiteIdsMap.get(role.AccountContactJunction__r.Contact_Name__c) == null) {
                    contactIdToProjectSiteIdsMap.put(role.AccountContactJunction__r.Contact_Name__c, new Set<Id>());
                }
                contactIdToProjectSiteIdsMap.get(role.AccountContactJunction__r.Contact_Name__c).addAll(applicationIdToProjectSiteIdsMap.get(role.Application__c));
            }
        }
        return contactIdToProjectSiteIdsMap;
    }
}