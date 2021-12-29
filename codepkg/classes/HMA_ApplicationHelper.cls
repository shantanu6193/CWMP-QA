public without sharing class HMA_ApplicationHelper {
    public static void processToCreateWSAndWSLI(Set<Id> appIds) {
        try {
            //Map<String, Set<Id>> paramMap = new Map<String, Set<Id>>();
            Set<Id> appIdsOfPlanning = new Set<Id>();
            Set<Id> appIdsOfPhasedNo = new Set<Id>();
            Set<Id> appIdsOfPhasedYes = new Set<Id>();
            if(appIds.size() > 0) {
                List<Application__c> appDetailList = [SELECT Id, 
                                                                Application_Type__c, 
                                                                Subapplicant_Entity__c,
                                                                Is_this_project_phased__c,
                                                                (SELECT Id FROM Work_Schedules__r)
                                                                FROM Application__c WHERE Id IN: appIds];
    
                for(Application__c app : appDetailList) {
                    if(app.Application_Type__c == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PLANNING) {
                        appIdsOfPlanning.add(app.Id);
                    } else if(checkSubApplicationType(app.Application_Type__c) && app.Is_this_project_phased__c == 'No') {
                        appIdsOfPhasedNo.add(app.Id);
                    } else if(checkSubApplicationType(app.Application_Type__c) && app.Is_this_project_phased__c == 'Yes') {
                        appIdsOfPhasedYes.add(app.Id);
                    }
                }
                if(appIdsOfPlanning.size() > 0) {
                    HMA_ApplicationHelper.deleteWorkSchedules(appIdsOfPlanning);
                    HMA_ApplicationHelper.createWorkSchedules(new Map<String,Set<Id>>{'appIdsOfPlanning' => appIdsOfPlanning});
                }
                if(appIdsOfPhasedNo.size() > 0) {
                    HMA_ApplicationHelper.deleteWorkSchedules(appIdsOfPhasedNo);
                    HMA_ApplicationHelper.createWorkSchedules(new Map<String,Set<Id>>{'appIdsOfPhasedNo' => appIdsOfPhasedNo});
                }
                if(appIdsOfPhasedYes.size() > 0) {
                    HMA_ApplicationHelper.deleteWorkSchedules(appIdsOfPhasedYes);
                    HMA_ApplicationHelper.createWorkSchedules(new Map<String,Set<Id>>{'appIdsOfPhasedYes' => appIdsOfPhasedYes});
                }
            }
        } catch (Exception e) {
            System.debug('error_processToCreateWSAndWSLI: ' + e);
        }               
    }
    
    public static void createWorkSchedules(Map<String,Set<Id>> paramMap) {
        Set<Id> WSIds = new Set<Id>();
        List<Work_Schedule__c> workSchedules = new List<Work_Schedule__c>();
        Map<String, List<Work_Schedule__c>> filterClauseToWorkScheduleMap = new Map<String, List<Work_Schedule__c>>();
        for(Id appId : paramMap.values()[0]) {
            Work_Schedule__c ws = new Work_Schedule__c(Application__c = appId);
            workSchedules.add(ws);
        }        
        insert workSchedules;
        for(Work_Schedule__c workS : workSchedules) {
            WSIds.add(workS.Id);
            if(filterClauseToWorkScheduleMap.get(HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_WORK_SCHEDULE) == null) { 
                filterClauseToWorkScheduleMap.put(HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_WORK_SCHEDULE, new List<Work_Schedule__c>()); 
        }
            filterClauseToWorkScheduleMap.get(HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_WORK_SCHEDULE).add(workS);
        }    
        if(filterClauseToWorkScheduleMap.size() > 0) {
            boolean isDocumentConfigration = HMA_ApplicationHelper.createDocumentsByFilterClause(filterClauseToWorkScheduleMap, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_WORK_SCHEDULE);
            System.debug('isDocumentConfigration_Work_Schedule : '+ isDocumentConfigration);
        }        

        if(paramMap.keySet().contains('appIdsOfPlanning')) {
            HMA_ApplicationHelper.createWorkScheduleLineItems(WSIds);
            HMA_ApplicationHelper.createCloseoutWorkScheduleLineItems(WSIds);
        } else if(paramMap.keySet().contains('appIdsOfPhasedNo')) {
            HMA_ApplicationHelper.createCloseoutWorkScheduleLineItems(WSIds);
        } else if(paramMap.keySet().contains('appIdsOfPhasedYes')) {
            HMA_ApplicationHelper.createPhaseWorkScheduleLineItems(WSIds);
            HMA_ApplicationHelper.createCloseoutWorkScheduleLineItems(WSIds);
        }
    }



    public static void createWorkScheduleLineItems(Set<Id> WSIds) {
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        List<String> phasePicklistValues = new List<String>();
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_THE_PLANNING_PROCESS);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_HAZARD_IDENTIFICATION);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_RISK_ASSESSMENT);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_MITIGATION_STRATEGY);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PLAN_PREPARATION);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PLAN_DRAFTING);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PUBLIC_OUTREACH_MEETINGS_PUBLICHEARINGS);
        phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PLAN_ADOPTION);

        for(Id WSId : WSIds) {
            for(String phaseValue : phasePicklistValues) {                        
                Work_Schedule_Line_Item__c wsli = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Planning_Phase__c = phaseValue);
                WSLIList.add(wsli);
            }
        }            
        insert WSLIList;
    }
    public static void createPhaseWorkScheduleLineItems(Set<Id> WSIds) {
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        for(Id WSId : WSIds) {
            Work_Schedule_Line_Item__c wsliPhase1 = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = HMA_CONSTANTS.WSLI_PHASE_PHASE1);
            Work_Schedule_Line_Item__c wsliPhase2 = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = HMA_CONSTANTS.WSLI_PHASE_PHASE2);
            WSLIList.add(wsliPhase1);
            WSLIList.add(wsliPhase2);
        }
        insert WSLIList;
    }
    public static void createCloseoutWorkScheduleLineItems(Set<Id> WSIds) {
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        for(Id WSId : WSIds) {
            Work_Schedule_Line_Item__c wsli = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = 'Closeout', Planning_Phase__c = 'Closeout', Task_Name__c = 'Closeout', Description__c = 'Project Closeout line item', Duration_Months__c = '3');
            WSLIList.add(wsli);
        }
        insert WSLIList;
    }

    
    public static void deleteWorkSchedules(Set<Id> appIds) {
        List<Work_Schedule__c> wsList = new List<Work_Schedule__c>();
        wsList = [SELECT Id FROM Work_Schedule__c WHERE Application__c IN: appIds];
        if(wsList.size() > 0) {
            delete wsList;
        }
    }

    private static Boolean checkSubApplicationType(String subApplicationType) {
        return (subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PROJECT || 
                subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_5INITIATIVE || 
                subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PLANNING_RELATED ||
                subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_ADVANCE_ASSISTANCE) ? true : false;
    }

    public static void createApplicationExtension(Map<Id, String> appIdToUpdatedAppProjectType, Map<Id, String> appIdToSubApplicationTypeMap) {
        try {
            List<Application_Extension__c> appExList = new List<Application_Extension__c>();
            Map<String, List<Application_Extension__c>> filterClauseToAppExMap = new Map<String, List<Application_Extension__c>>();
            Set<Id> applicationExIds = new Set<Id>();
            delete[SELECT Id FROM Application_Extension__c WHERE Application__c IN: appIdToUpdatedAppProjectType.keySet()];
            for(Id appId : appIdToUpdatedAppProjectType.keySet()) {
                Application_Extension__c appEx = new Application_Extension__c();
                appEx.Application__c = appId;
                appExList.add(appEx);
            }
            insert appExList;
            for(Application_Extension__c appEx : appExList) {
                applicationExIds.add(appEx.Id);
                if( appIdToSubApplicationTypeMap.get(appEx.Application__c) == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PLANNING || 
                    appIdToSubApplicationTypeMap.get(appEx.Application__c) == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PLANNING_RELATED) {
                        if(filterClauseToAppExMap.get(appIdToSubApplicationTypeMap.get(appEx.Application__c)) == null) { 
                            filterClauseToAppExMap.put(appIdToSubApplicationTypeMap.get(appEx.Application__c), new List<Application_Extension__c>()); 
                        }
                        filterClauseToAppExMap.get(appIdToSubApplicationTypeMap.get(appEx.Application__c)).add(appEx);
                } else if(String.isNotEmpty(appIdToUpdatedAppProjectType.get(appEx.Application__c))) {
                    if(filterClauseToAppExMap.get(appIdToUpdatedAppProjectType.get(appEx.Application__c)) == null) { 
                        filterClauseToAppExMap.put(appIdToUpdatedAppProjectType.get(appEx.Application__c), new List<Application_Extension__c>()); 
                    }
                    filterClauseToAppExMap.get(appIdToUpdatedAppProjectType.get(appEx.Application__c)).add(appEx);
                }
            }
            if(applicationExIds.size() > 0) {
                HMA_ApplicationHelper.shareApplicationExtensionRecordsWithCommunityUser(applicationExIds);
            }            
            System.debug('filterClauseToAppExMap : '+ filterClauseToAppExMap);  
            if(filterClauseToAppExMap.size() > 0) {
                boolean isDocumentConfigration = HMA_ApplicationHelper.createDocumentsByFilterClause(filterClauseToAppExMap, HMA_CONSTANTS.PROGRAM_DOC_PARENT_OBJECT_APPLICATION_EXTENSION);
                System.debug('isDocumentConfigration_application_Extension : '+ isDocumentConfigration);
            }
        } catch (Exception e) {
            System.debug('error_createApplicationExtension : ' + e);
        }
    }
    public static void shareApplicationExtensionRecordsWithCommunityUser( Set<Id> applicationExIds) {   // TODO : Make it as genric
        List<Application_Extension__c> applicationExtensions = new List<Application_Extension__c>();
        List<Application_Extension__share> shareAppEx = new List<Application_Extension__share>();
        Map<Id, Id> applicationExIdToOwnerId = new Map<Id, Id>();

        applicationExtensions = [SELECT Id, Application__c, Application__r.Pre_Application__r.OwnerId, Application__r.Pre_Application__r.CreatedById FROM Application_Extension__c WHERE Id IN: applicationExIds];
        for(Application_Extension__c appEx : applicationExtensions) {
            applicationExIdToOwnerId.put(appEx.Id, appEx.Application__r.Pre_Application__r.CreatedById);
        }
        System.debug('applicationExIdToOwnerId------- : '+ applicationExIdToOwnerId);
        for(Id appExId : applicationExIdToOwnerId.keySet()) {
            Application_Extension__share shr = new Application_Extension__share();
            shr.ParentId = appExId;
            shr.UserOrGroupId = applicationExIdToOwnerId.get(appExId);
            shr.AccessLevel = 'Edit';
            shr.RowCause = Schema.Application_Extension__share.RowCause.Manual;
            shareAppEx.add(shr);
        }
        System.debug('shareAppEx------- : '+ shareAppEx);
        List<Database.SaveResult> sr = Database.insert(shareAppEx,false);
        System.debug('sr------- : '+ sr);
    }
    public static boolean createDocumentsByFilterClause(Map<String, List<SObject>> filterClauseToObjectMap, String programDocParentObject) {
        List<Program_Document__c> programDocuments = new List<Program_Document__c>();
        Map<String, List<Program_Document__c>> filterClauseToProgramDocMap = new Map<String, List<Program_Document__c>>();
        List<Document__c> docList = new List<Document__c>();
        Set<Id> documentIds = new Set<Id>();

        if(filterClauseToObjectMap.size() == 0) return false;
        programDocuments = [SELECT Id, Document_Name__c, Document_Format__c, Project_Stage__c, Is_Required__c, Description__c, Filter_Clause__c
                                FROM Program_Document__c WHERE Filter_Clause__c IN: filterClauseToObjectMap.keySet() AND Parent_Object__c =: programDocParentObject];

        for(Program_Document__c proDoc : programDocuments) {
            if(filterClauseToProgramDocMap.get(proDoc.Filter_Clause__c) == null) { 
                filterClauseToProgramDocMap.put(proDoc.Filter_Clause__c, new List<Program_Document__c>()); 
            }
            filterClauseToProgramDocMap.get(proDoc.Filter_Clause__c).add(proDoc);
        }
        System.debug('filterClauseToProgramDocMap--- : '+ filterClauseToProgramDocMap);
        if(filterClauseToProgramDocMap.size() > 0) {
            for(String filterClause : filterClauseToObjectMap.keySet()) {
                System.debug('filterClause--- : '+ filterClause);
                for(SObject objRec : filterClauseToObjectMap.get(filterClause)) {
                    Id objRecId = objRec.Id;
                    String objAPIName = objRecId.getSObjectType().getDescribe().getName();
                    if(filterClauseToProgramDocMap.get(filterClause) != null) {
                        for(Program_Document__c programDoc : filterClauseToProgramDocMap.get(filterClause)) {
                            Document__c doc = new Document__c();
                            doc.Document_Name__c = programDoc.Document_Name__c;
                            doc.Document_Format__c = programDoc.Document_Format__c;
                            if(objAPIName != 'Application__c' && objRec.get('Application__c') != null) {/*This field is required for create every type of document*/
                                doc.Application__c = (Id)objRec.get('Application__c');
                            }                    
                            if(objAPIName == 'Work_Schedule__c') {
                                doc.Work_Schedule__c = objRec.Id; 
                            } else if(objAPIName == 'Application_Extension__c') {
                                doc.Application_Extension__c = objRec.Id; 
                            } else if(objAPIName == 'Project_Site__c') {
                                doc.Project_Site__c = objRec.Id; 
                            } else if(objAPIName == 'Application__c') {
                                doc.Application__c = objRec.Id;
                            }          
                            doc.Status__c = 'Active';
                            doc.Stage__c = programDoc.Project_Stage__c;
                            doc.Is_Required__c = programDoc.Is_Required__c;
                            doc.Description__c = programDoc.Description__c;
                            docList.add(doc);
                        }
                    }                    
                }
            }
        }
        System.debug('Created_Document_List--- : '+ docList);
        if(docList.size() > 0){
           insert docList;
        }

        for(Document__c docu : docList) {
            documentIds.add(docu.Id);
        }
        if(documentIds.size() > 0) {
            //shareDocumentRecordsToCommunityUser(documentIds);
            return true;
        }
        return false;
    }
    public static boolean createDocumentRecForProjectSite(Map<String, List<Project_Site__c>> projectTypeToSiteMap, String programDocParentObject) {
        List<Program_Document__c> programDocuments = new List<Program_Document__c>();
        Map<String, List<Program_Document__c>> filterClauseToProgramDocMap = new Map<String, List<Program_Document__c>>();
        List<Document__c> docList = new List<Document__c>();
        Set<Id> documentIds = new Set<Id>();

        if(projectTypeToSiteMap.size() == 0) return false;
        programDocuments = [SELECT Id, Document_Name__c, Document_Format__c, Project_Stage__c, Is_Required__c, Description__c, Filter_Clause__c
                                FROM Program_Document__c WHERE Filter_Clause__c IN: projectTypeToSiteMap.keySet() AND Parent_Object__c =: programDocParentObject];
        System.debug('programDocuments--- : '+ programDocuments);
        for(Program_Document__c proDoc : programDocuments) {
            if(filterClauseToProgramDocMap.get(proDoc.Filter_Clause__c) == null) { 
                filterClauseToProgramDocMap.put(proDoc.Filter_Clause__c, new List<Program_Document__c>()); 
        }
            filterClauseToProgramDocMap.get(proDoc.Filter_Clause__c).add(proDoc);
        }
        if(filterClauseToProgramDocMap.size() > 0) {
            for(String projectType : projectTypeToSiteMap.keySet()) {
                System.debug('projectType--- : '+ projectType);
                for(Project_Site__c proSiteObj : projectTypeToSiteMap.get(projectType)) {                  
                    if(filterClauseToProgramDocMap.get(projectType) != null) {
                        for(Program_Document__c programDoc : filterClauseToProgramDocMap.get(projectType)) {
                    Document__c doc = new Document__c();
                    doc.Document_Name__c = programDoc.Document_Name__c;
                    doc.Document_Format__c = programDoc.Document_Format__c;
                            doc.Project_Site__c = proSiteObj.Id;             
                    doc.Status__c = 'Active';
                    doc.Stage__c = programDoc.Project_Stage__c;
                    doc.Is_Required__c = programDoc.Is_Required__c;
                    doc.Description__c = programDoc.Description__c;
                    docList.add(doc);
                }                
            }
                }
            }
        }
            insert docList;
        System.debug('Created_Document_List--- : '+ docList);
        for(Document__c docu : docList) {
            documentIds.add(docu.Id);
        }
        if(documentIds.size() > 0) {
            //shareDocumentRecordsToCommunityUser(documentIds);
        }
        return true;
    }
    /**
     * Share Document record with Community users*/
    public static void shareDocumentRecordsToCommunityUser( Set<Id> documentIds) {
        List<Document__c> documents = new List<Document__c>();
        List<Document__share> shareDoc = new List<Document__share>();
        Map<Id, Id> documentIdToOwnerId = new Map<Id, Id>();

        documents = [SELECT Id, Application__c, Application__r.Pre_Application__r.OwnerId, Application__r.Pre_Application__r.CreatedById FROM Document__c WHERE Id IN: documentIds];
        for(Document__c doc : documents) {
            documentIdToOwnerId.put(doc.Id, doc.Application__r.Pre_Application__r.CreatedById);
        }
        System.debug('documentIdToOwnerId------- : '+ documentIdToOwnerId);
        for(Id docId : documentIdToOwnerId.keySet()) {
            Document__share shr = new Document__share();
            shr.ParentId = docId;
            shr.UserOrGroupId = documentIdToOwnerId.get(docId);
            shr.AccessLevel = 'Read';
            shr.RowCause = Schema.Document__share.RowCause.Manual;
            shareDoc.add(shr);
        }
        List<Database.SaveResult> sr = Database.insert(shareDoc,false);
        System.debug('Document_Sharing_Result--- : '+ sr);
    }

    public static void checkACRoleAndCreateContactRoleForApplication(Map<Id, Application__c> preAppIdToApplicationMap) {
        Map<Id, List<Id>> accountIdToContactIds = new Map<Id, List<Id>>();
        Map<String, List<Id>> accountToContactIdsMap = new Map<String, List<Id>>();
        Map<Id, AccountContactRole__c> contactIdToExistACRoleMap = new Map<Id, AccountContactRole__c>();
        Map<Id, List<String>> contactIdToContactRoles = new Map<Id, List<String>>();
        Map<Id, Id> applicationIdToAccountIdMap = new Map<Id, Id>();
        List<Contact_Role__c> appContactRoles = new List<Contact_Role__c>();
        Set<Id> contactIds = new Set<Id>();

         /** Get Pre-Application ContactRole */
        List<Contact_Role__c > conRoles = [SELECT Id, Contact__c, Contact__r.Email, Pre_Application__c, Role__c FROM Contact_Role__c  
                                            WHERE Pre_Application__c IN: preAppIdToApplicationMap.keySet() AND Role__c includes('Responsible Representative', 'Primary Contact') ];

        for(Contact_Role__c role : conRoles) {
            Application__c app = preAppIdToApplicationMap.get(role.Pre_Application__c);
            if(accountIdToContactIds.get(app.Subapplicant_Entity__c) == null) {
                accountIdToContactIds.put(app.Subapplicant_Entity__c, new List<Id>()); 
            }
            accountIdToContactIds.get(app.Subapplicant_Entity__c).add(role.Contact__c);
            contactIds.add(role.Contact__c);
            if(contactIdToContactRoles.get(role.Contact__c) == null) {
                contactIdToContactRoles.put(role.Contact__c, new List<String>()); 
            }
            contactIdToContactRoles.get(role.Contact__c).add(role.Role__c);
            applicationIdToAccountIdMap.put(app.Id, app.Subapplicant_Entity__c);
        }
        /** Get AccountContactRoles which having Account_Name__c in accountIdToContactIds and Contact_Name__c in  contactIds */
        List<AccountContactRole__c> accConRoles = [SELECT Id, Contact_Name__c,Account_Name__c  FROM AccountContactRole__c WHERE Account_Name__c IN:accountIdToContactIds.keySet() AND Contact_Name__c IN:contactIds];
        for(AccountContactRole__c acRole : accConRoles) {
            /** AccountContactRoles are added in existing AccountContactRole Map with Contact Id (Means these AccountContactRoles not need to create)  */
            if(accountIdToContactIds.keySet().contains(acRole.Account_Name__c) && accountIdToContactIds.get(acRole.Account_Name__c).contains(acRole.Contact_Name__c)) {
                contactIdToExistACRoleMap.put(acRole.Contact_Name__c, acRole);
            }                
        }
        List<AccountContactRole__c> newCreatedACRoles = new List<AccountContactRole__c>();
        for(Id accId : accountIdToContactIds.keySet()) {
            List<Id> conIds = accountIdToContactIds.get(accId);
            for(Id conId : conIds) {
                /** Create AccountContactRoles which is not present in contactIdToExistACRoleMap */
                if(!contactIdToExistACRoleMap.keySet().contains(conId)) {
                    AccountContactRole__c acRole = new AccountContactRole__c();
                    acRole.Account_Name__c = accId;
                    acRole.Contact_Name__c = conId;
                    acRole.Contact_Role_Global_List__c = 'Employee';
                    acRole.Status__c = 'Active';
                    newCreatedACRoles.add(acRole);
                }
            }
        }
        insert newCreatedACRoles;
        for(AccountContactRole__c acRole : newCreatedACRoles) {
            /**  Add newly created AccountContactRoles in contactIdToExistACRoleMap */
            contactIdToExistACRoleMap.put(acRole.Contact_Name__c, acRole);
        }
        
        /**  Created Application Contact Role Records for specific ContactId  */
        for(Id appId : applicationIdToAccountIdMap.keySet()) {
            String appAccountId = applicationIdToAccountIdMap.get(appId);
            for(Id conId : accountIdToContactIds.get(appAccountId)) {
                if(contactIdToExistACRoleMap.get(conId) != null) {
                    Contact_Role__c applicationContactRole = new Contact_Role__c();
                    applicationContactRole.Application__c = appId;
                    applicationContactRole.Contact__c = conId;
                    applicationContactRole.AccountContactJunction__c = contactIdToExistACRoleMap.get(conId).Id;
                    if(contactIdToContactRoles.get(conId).size() > 1) {
                        applicationContactRole.Role__c = contactIdToContactRoles.get(conId)[0];
                        String removedRole = contactIdToContactRoles.get(conId).remove(0);
                    } else {
                        applicationContactRole.Role__c = contactIdToContactRoles.get(conId)[0];
                    }
                    appContactRoles.add(applicationContactRole);
                }                
            }
        }
        insert appContactRoles;
        System.debug('appContactRoles : '+appContactRoles);
    }

    public static Map<Id, Set<Id>> getDocumentRecordsFromApplication(Set<Id> applicationIds) {
        Map<Id, Set<Id>> returnMap = new Map<Id, Set<Id>>();
        List<Document__c> docRecords = [SELECT Id, Application__c, Document_Name__c  FROM Document__c WHERE Application__c IN: applicationIds];
        for(Document__c doc : docRecords) {
            if(returnMap.get(doc.Application__c) == null) {
                returnMap.put(doc.Application__c, new Set<Id>());
            }
            returnMap.get(doc.Application__c).add(doc.Id);
        }
        return returnMap;
    }



    /** This method is used for check User is present or not for Contact of AccountContactRole
     * for User check is Community Application User present or not, if not create it and if present update it
     * For User Share Application records with specified user
     * For Contact Create Community Application User records
     */
    public static void checkUserAndCreateCommunityApplicationUser(Set<Id> applicationIds) {
        Set<Id> userIds = new Set<Id>();
        Map<Id, Set<Id>> userIdToApplicationIdsMap = new Map<Id, Set<Id>>();
        Map<Id, Id> existingUserIdToContactIdMap = new Map<Id, Id>();
        Map<Id, Set<Id>> applicationIdToDocumentIdsMap = getDocumentRecordsFromApplication(applicationIds);
        Map<Id, Set<Id>> contactIdtoApplicationIdsMap = getContactIdsFromContactRoles(applicationIds);

        /** Finding the contactIds from Application Contact Role */
        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId IN: contactIdtoApplicationIdsMap.keySet()];
        for(User u : userList) {
            if(contactIdtoApplicationIdsMap.keySet().contains(u.ContactId)) {
                if(userIdToApplicationIdsMap.get(u.Id) == null) {
                    userIdToApplicationIdsMap.put(u.Id, new Set<Id>());
                }
                userIdToApplicationIdsMap.get(u.Id).addAll(contactIdtoApplicationIdsMap.get(u.ContactId));
                existingUserIdToContactIdMap.put(u.Id, u.ContactId);
                contactIdtoApplicationIdsMap.remove(u.ContactId);
            }
        }
        /** Used for check Community Application User present or not for specified User */
        if(userIdToApplicationIdsMap.size() > 0) {
            checkAndCreateCommunityApplicationToUserRecordsForUser(userIdToApplicationIdsMap, existingUserIdToContactIdMap, applicationIdToDocumentIdsMap);
        }     
        /** Check, Update and Create Community Application User records from Contact and specified Application */
        checkAndCreateCommunityApplicationToUserRecordsForContact(contactIdtoApplicationIdsMap);
    }
    // TODO : This method should use only incase of non fema users
    public static Map<Id, Set<Id>> getContactIdsFromContactRoles(Set<Id> applicationIds) {
        Map<Id, Set<Id>> contactIdtoApplicationIdsMap = new Map<Id, Set<Id>>();
        List<Contact_Role__c > conRoles = [SELECT   
                                                Id, 
                                                Contact__c, 
                                                AccountContactJunction__c, 
                                                AccountContactJunction__r.Contact_Name__c, 
                                                AccountContactJunction__r.Contact_Name__r.Email, 
                                                Application__c 
                                                FROM Contact_Role__c  
                                                WHERE Application__c IN: applicationIds];

        for(Contact_Role__c role : conRoles) {
            if(String.isNotEmpty(role.AccountContactJunction__r.Contact_Name__c)) {
                if(contactIdtoApplicationIdsMap.get(role.AccountContactJunction__r.Contact_Name__c) == null) {
                    contactIdtoApplicationIdsMap.put(role.AccountContactJunction__r.Contact_Name__c, new Set<Id>());
                }
                contactIdtoApplicationIdsMap.get(role.AccountContactJunction__r.Contact_Name__c).add(role.Application__c);
            }            
        }
        return contactIdtoApplicationIdsMap;
    }
    public static void checkAndCreateCommunityApplicationToUserRecordsForUser(Map<Id, Set<Id>> userIdToApplicationIdsMap, Map<Id, Id> existingUserIdToContactIdMap, Map<Id, Set<Id>> applicationIdToDocumentIdsMap) {
        //List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
        List<Community_Application_to_User__c> commAppUserList = new List<Community_Application_to_User__c>();
        Map<Id, Set<Id>> SObjectIdToUserIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> docIdToUserIds = new Map<Id, Set<Id>>();
        System.debug('userIdToApplicationIdsMap-----------'+userIdToApplicationIdsMap);
        System.debug('applicationIdToDocumentIdsMap-----------'+applicationIdToDocumentIdsMap);
        for(Id userId : userIdToApplicationIdsMap.keySet()) {
            for(Id appId : userIdToApplicationIdsMap.get(userId)) {
                if(applicationIdToDocumentIdsMap.get(appId) != null){
                for(Id documentId : applicationIdToDocumentIdsMap.get(appId)) {
                    /********** Preparing Map for Share Document records with User */
                        if(docIdToUserIds.get(documentId) == null) {
                            docIdToUserIds.put(documentId, new Set<Id>());
                        }
                        docIdToUserIds.get(documentId).add(userId);
                    /***************************************************************** */
                }
                }
                /********** Preparing Map for Share Application records with User */
                    if(SObjectIdToUserIds.get(appId) == null) {
                        SObjectIdToUserIds.put(appId, new Set<Id>());
                    }
                    SObjectIdToUserIds.get(appId).add(userId);
                /***************************************************************** */
            }
        }
        string communityApplicationId = [SELECT Id FROM Community_Application__c WHERE Name='HMA' LIMIT 1].Id;
        List<Community_Application_to_User__c> commAppUsers = [SELECT Id, 
                                                                        User__c, 
                                                                        Contact__c, 
                                                                        isActive__c, 
                                                                        Post_Active_Actions__c ,
                                                                        Community_Application__c,
                                                                        Community_Application__r.Name
                                                                        FROM Community_Application_to_User__c 
                                                                        WHERE User__c IN: userIdToApplicationIdsMap.keySet() AND Community_Application__r.Name = 'HMA'];

        for(Community_Application_to_User__c caUser : commAppUsers) {
            if(userIdToApplicationIdsMap.get(caUser.User__c) != null) {
                userIdToApplicationIdsMap.remove(caUser.User__c);
            }            
        }
        for(Id userId : userIdToApplicationIdsMap.keySet()) {
            Community_Application_to_User__c newCommAppUser = new Community_Application_to_User__c();
            newCommAppUser.isActive__c = true;
            newCommAppUser.Contact__c = existingUserIdToContactIdMap.get(userId);
            newCommAppUser.User__c = userId;
            newCommAppUser.Community_Application__c = communityApplicationId;
            //newCommAppUser.Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
            commAppUserList.add(newCommAppUser);
            //commAppActionClasses.clear();
        }
        insert commAppUserList;

        /** Share the Application record with specific User */
        if(SObjectIdToUserIds.size() > 0) {
            Boolean isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(SObjectIdToUserIds, 'Application__share', 'Edit', Schema.Application__share.RowCause.Shared_with_Contact_Roles__c);
            if(isRecordShared) {
                System.debug('Application Records shared Successfully.');
            }
        }

        /** Share the Document record with specific User */
        if(docIdToUserIds.size() > 0) {
            Boolean isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(docIdToUserIds, 'Document__share', 'Edit', Schema.Document__share.RowCause.Manual);
            if(isRecordShared) {
                System.debug('Document records of Application are shared Successfully.');
            }
        }
    }
    public static void checkAndCreateCommunityApplicationToUserRecordsForContact(Map<Id, Set<Id>> contactIdtoApplicationIdsMap) {
        List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
        List<Community_Application_to_User__c> commAppUserList = new List<Community_Application_to_User__c>();
        Map<Id, Set<Id>> contactIdtoApplicationIdsForCreate = new Map<Id, Set<Id>>();
        string communityApplicationId = [SELECT Id FROM Community_Application__c WHERE Name='HMA' LIMIT 1].Id;
              
        contactIdtoApplicationIdsForCreate = updateExistingCommunityApplicationToUserRecordsForContact(contactIdtoApplicationIdsMap);
         /** Created the Community Application User Records */
        for(Id conId : contactIdtoApplicationIdsForCreate.keySet()) {
            for(Id appId : contactIdtoApplicationIdsForCreate.get(conId)) {
                CommAppActionClass commAppActionClass = new CommAppActionClass();
                commAppActionClass.action = 'ShareSubApplication';
                commAppActionClass.value = appId;

                commAppActionClasses.add(commAppActionClass);
            }
            Community_Application_to_User__c newCommAppUser = new Community_Application_to_User__c();
            newCommAppUser.isActive__c = true;
            newCommAppUser.Contact__c = conId;
            newCommAppUser.User__c = null;
            newCommAppUser.Community_Application__c = communityApplicationId;
            newCommAppUser.Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
            commAppUserList.add(newCommAppUser);

            commAppActionClasses.clear();
        }
        insert commAppUserList;
    }
    public static Map<Id, Set<Id>> updateExistingCommunityApplicationToUserRecordsForContact( Map<Id, Set<Id>> contactIdtoApplicationIdsMap) {
        //List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
        List<Community_Application_to_User__c> commAppUserListToUpdate = new List<Community_Application_to_User__c>();
        List<Community_Application_to_User__c> commAppUsers = [SELECT Id, 
                                                                        User__c, 
                                                                        Contact__c, 
                                                                        isActive__c, 
                                                                        Post_Active_Actions__c ,
                                                                        Community_Application__c,
                                                                        Community_Application__r.Name
                                                                        FROM Community_Application_to_User__c 
                                                                        WHERE Contact__c IN: contactIdtoApplicationIdsMap.keySet() AND User__c = null AND Community_Application__r.Name = 'HMA' ];
        
        for(Community_Application_to_User__c caUser : commAppUsers) {
            List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
            if(contactIdtoApplicationIdsMap.get(caUser.Contact__c) != null) {
                if(caUser.Post_Active_Actions__c != null){
                    commAppActionClasses = (List<CommAppActionClass>)JSON.deserialize(caUser.Post_Active_Actions__c, List<CommAppActionClass>.class);
                }

                for(Id appId : contactIdtoApplicationIdsMap.get(caUser.Contact__c)) {
                    CommAppActionClass commAppActionClass = new CommAppActionClass();
                    commAppActionClass.action = 'ShareSubApplication';
                    commAppActionClass.value = appId;

                    commAppActionClasses.add(commAppActionClass);
                }
                caUser.Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
                caUser.isActive__c = false; 
                commAppUserListToUpdate.add(caUser);

                commAppActionClasses.clear();
                contactIdtoApplicationIdsMap.remove(caUser.Contact__c);
            }
        }
        update commAppUserListToUpdate;
        return contactIdtoApplicationIdsMap;
    }
    
    

    public static void prepareForSubApplicationApprovalEmail(Map<Id, Application__c> applicationIdToApplicationMap) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        List<Contact_Role__c > conRoles = [SELECT   
                                                Id, 
                                                Contact__c, 
                                                AccountContactJunction__c, 
                                                AccountContactJunction__r.Contact_Name__c, 
                                                AccountContactJunction__r.Contact_Name__r.Email, 
                                                Application__c 
                                                FROM Contact_Role__c  
                                                WHERE Application__c IN: applicationIdToApplicationMap.keySet() AND Role__c includes('Responsible Representative', 'Primary Contact')];

        for(Contact_Role__c role : conRoles) {
            mails = HMA_ApplicationHelper.sendEmail(applicationIdToApplicationMap.get(role.Application__c), new List<String>{role.AccountContactJunction__r.Contact_Name__r.Email}, new List<String>{}, 'HMA_Status_Approved_NOI_Approved', 'HMA_From_Email_Addresses', role.AccountContactJunction__r.Contact_Name__c);
        }
        Messaging.sendEmail(mails);
    }

    /*
    This method processes accountContactRole for Reponsible Representative. For now it is also used for primary contact i.e. Requestor
    We check if record for accountContactRole already exists with same account and contact.
    if record exists then we just assigne contactRole's accountContactJunction lookup with that record's id
    else we create new accountContactRole and then assign it to contactRole's accountContactJunction
    */

    public static void processAccountContactRole(Contact relatedContact, Contact_Role__c contactRoleDetail, String accountId) {
        //Get Account from User and Contact from relatedContacts then check whether accountcontactrole__c has records with those account and contact
        try {
            //Id accountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()]?.AccountId;
            System.debug('accountId---'+accountId+'--relatedContact--'+relatedContact.Id);
            List<AccountContactRole__c> accountContactRoleRecords = [SELECT Id FROM AccountContactRole__c WHERE Account_Name__c = :AccountId AND Contact_Name__c = :relatedContact.Id];
            //if record of accountcontactrole exists then populate it's Id on contact role record else create accountcontactrole record and populate it's id on contact role record
            System.debug('accountContactRoleRecord---'+accountContactRoleRecords);
            if(accountContactRoleRecords.size() > 0) {
                contactRoleDetail.AccountContactJunction__c = accountContactRoleRecords[0].Id;
            } else {
                AccountContactRole__c newAccountContactRoleRec = new AccountContactRole__c(Account_Name__c = accountId, Contact_Name__c = relatedContact.Id, Contact_Role_Global_List__c = 'Employee', Status__c = 'Active');
                insert newAccountContactRoleRec;
                contactRoleDetail.AccountContactJunction__c = newAccountContactRoleRec.Id;
            }
            System.debug('contactRoleDetail----'+contactRoleDetail);
            upsert contactRoleDetail;
        } catch(Exception e) {
            System.debug('Exception has occured---'+e.getStackTraceString());
            System.debug('Exception Message--'+e.getMessage());
        }
    }

    /*
    This method is used to prepare initial data for sending email and at the end we take htmlBody and Subject 
    of email and replace it's ContactROle with the actual ContactRole of the record and send the email.
    */

    public static void prepareDataForSendingEmail(Contact relatedContact, Contact_Role__c contactRoleDetail) {
        Set<String> toAddresses = new Set<String>();
        List<String> ccAddresses = new List<String>();
        Application__c subApp = new Application__c(Id = contactRoleDetail.Application__c);
        SObject sobj = (SObject) subApp;
        toAddresses.add(relatedContact.Email);
        List<String> toAddressList = new List<String>(toAddresses);
        List<Messaging.SingleEmailMessage> mails = HMA_ApplicationHelper.sendEmail(sobj, toAddressList, ccAddresses, 'HMA Responsible Representative Manage Subapp', 'HMA_From_Email_Addresses', relatedContact.Id);
        for(Messaging.SingleEmailMessage mail : mails) {
            System.debug('mail---'+mail);
            String role = contactRoleDetail.Role__c;
            String formattedContactRole = role.removeEnd(';');
            formattedContactRole = formattedContactRole.replace(';', ', ');
            mail.htmlBody = mail.htmlBody.replace('ContactRole', formattedContactRole);
            mail.subject = mail.subject.replace('ContactRole', formattedContactRole);
        }
        Messaging.sendEmail(mails);
    }

    /*
    This method processes community User for Responsible Representative. It is also used for Primary Contact i.e. Requestor
    We first get the application Id correspoding to HMA and then check whether the record for Community_Application_to_User__c record
    for the user and the applicationId. 
    If record exists then we take it's Post_Active_Actions__c, make it a list of it's wrapper class
        deserialize it and assign user and active checkbox values. Assign the new postAction serialize it 
    else create record assign post active action and then upsert the record.
    */

    public static void processCommunityUser(Contact relatedContact, Contact_Role__c contactRoleDetail, List<User> contactUsers) {
        //Get the application Id or Community Id
        Id applicationId = [SELECT Id FROM Community_Application__c WHERE Name = 'HMA' LIMIT 1]?.Id;
        List<Community_Application_to_User__c> communityApplicationToUsers = [SELECT Id, Post_Active_Actions__c, Contact__c, User__c
                                                                                    FROM Community_Application_to_User__c
                                                                                    WHERE Contact__c = :relatedContact.Id
                                                                                        AND Community_Application__c = :applicationId];
        //If user do not exists in community application to user then create it or just update the post active actions
        if(communityApplicationToUsers.size() > 0) {
            System.debug('CommunityApplicationToUsers---'+communityApplicationToUsers);
            String postActiveActions = communityApplicationToUsers[0].Post_Active_Actions__c;
            List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
            if(communityApplicationToUsers[0].Post_Active_Actions__c != null) {
                commAppActionClasses = (List<CommAppActionClass>)JSON.deserialize(communityApplicationToUsers[0].Post_Active_Actions__c, List<CommAppActionClass>.Class);
            }
            communityApplicationToUsers[0].User__c = contactUsers.size() > 0  ? contactUsers[0].Id:null;
            communityApplicationToUsers[0].isActive__c = contactUsers.size() > 0 ? true : false;
            CommAppActionClass postAction = new CommAppActionClass();
            postAction.action = 'ShareSubApplication';
            postAction.value = contactRoleDetail.Application__c;
            commAppActionClasses.add(postAction);
            communityApplicationToUsers[0].Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
            //TODO-share record with the responsible representative
            //Database.executeBatch(new UserRegistrationPostActionBatch(JSON.serialize(postActionColList),JSON.serialize(comAppUserObjLst)),1);
        } else {
            List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
            CommAppActionClass postAction = new CommAppActionClass();
            postAction.action = 'ShareSubApplication';
            postAction.value = contactRoleDetail.Application__c;
            communityApplicationToUsers = new List<Community_Application_to_User__c>();
            communityApplicationToUsers.add(new Community_Application_to_User__c(Contact__c = relatedContact.Id));
            commAppActionClasses.add(postAction);
            communityApplicationToUsers[0].Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
            communityApplicationToUsers[0].Community_Application__c = applicationId;
            communityApplicationToUsers[0].User__c = contactUsers.size() > 0  ? contactUsers[0].Id:null;
            communityApplicationToUsers[0].isActive__c = contactUsers.size() > 0 ? true : false;
        }
        upsert communityApplicationToUsers;
    }

    /*
    Share Subapplication with Responsible Representative. Also used for Primary Contact i.e. Requestor
    */

    public static void shareSubApplication(Contact relatedContact, Contact_Role__c contactRoleDetail, List<User> users) {
        Map<Id, Set<Id>> sobjectToUserIdSetMap = new Map<Id, Set<Id>>();
        Boolean isRecordShared = false;
        Set<Id> userIdSet = new Set<Id>();
        for(User u : users) {
            userIdSet.add(u.Id);
        }
        System.debug('userIdSet----------'+ userIdSet);
        sobjectToUserIdSetMap.put(contactRoleDetail.Application__c, userIdSet);
        if(contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE)
            || contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR)
            || contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR)) {
            isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(sobjectToUserIdSetMap, 'Application__share', 'Edit', Schema.Application__share.RowCause.Shared_with_Contact_Roles__c);
        } else if(contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER)) {
            System.debug('sobjectToUserIdSetMap_Viewer----------'+ sobjectToUserIdSetMap);
            isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(sobjectToUserIdSetMap, 'Application__share', 'Read', Schema.Application__share.RowCause.Shared_with_Contact_Roles__c);
        }
        if(isRecordShared) {
            System.debug('Records shared Successfully.');
            /**Used for share the Document records related to Application with User*/
            shareSubApplicationDocuments(contactRoleDetail.Application__c, userIdSet);
        }
    }
    public static void shareSubApplicationDocuments(Id subApplicationId, Set<Id> userIdSet) {
        Map<Id, Set<Id>> sobjectToUserIdSetMap = new Map<Id, Set<Id>>();
        Boolean isRecordShared = false;

        List<Document__c> docList = [SELECT Id, Application__c FROM Document__c WHERE Application__c =: subApplicationId];
        for(Document__c doc : docList) {
            sobjectToUserIdSetMap.put(doc.Id, userIdSet);
        }
        if(sobjectToUserIdSetMap.size() > 0) {
            isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(sobjectToUserIdSetMap, 'Document__share', 'Edit', Schema.Document__share.RowCause.Manual);
        }
        if(isRecordShared) {
            System.debug('Document Records shared Successfully.');
        }
    }
    public class CommAppActionClass {
        public String action;
        public String value;
    }

    public static List<Messaging.SingleEmailMessage> sendEmail(SObject sObj, List<String> toAddresses ,List<String> ccAddresses, String emailTemplate, String fromAddress, Id targetId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateToSend = [Select id from EmailTemplate where name =:emailTemplate LIMIT 1];
        String fromAddr = KeyValueHelper.getTextValue(fromAddress);
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        system.debug('.....'+templateToSend+'ssss'+sObj);
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            //mail.setTemplateId(templateToSend.Id);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(templateToSend.Id, targetId, (String.isNotEmpty(sObj.Id) ? sObj.Id : null));
            mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            mail.subject= String.isNotEmpty(singleEmail.subject) ? singleEmail.subject : '';
            mail.setWhatId(sObj.Id);
            mail.setTargetObjectId(targetId);
            mail.setSaveAsActivity(true);
            mails.add(mail);
            return mails;
        } catch(Exception e) {
            System.debug('Exception in mail---'+e);
        }
        return mails;
    }

    /** Used for Send email to HMA Analyst */
    public static List<Messaging.SingleEmailMessage> prepareForMailsSendToHmaAnalyst(Application__c applicationDetail, String emailTemplate) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        mails = HMA_ApplicationHelper.sendEmail(applicationDetail, 
                                                new List<String>{applicationDetail.Owner.Email}, 
                                                new List<String>{},
                                                emailTemplate, 
                                                HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                                applicationDetail.OwnerId);
                                                
        for(Messaging.SingleEmailMessage mail : mails) {
            mail.setSaveAsActivity(false);
        }
        return mails;
    }

    /***********************************************
    * Method Name : formatPlainBody
    * Author : Pankaj
    * Inputs : String plainBody
    * Description: This method replace \n with <br/> in string and return a string 
    *********************************************/
    @TestVisible
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

    public static String processAccount(Map<String, Object> recordDetailsMap) {
        String accountId='';
        Map<String, Id> accountByName = new Map<String, Id>();
        try {
            if(recordDetailsMap != null && recordDetailsMap.containsKey('accountRecord')) {
                String accountOwnerId = KeyValueHelper.getTextValue('SOC_OPS_Non_GovernmentOwnerId');
                AccountRecordWrapper accRecord = (AccountRecordWrapper) JSON.deserialize( JSON.serialize(recordDetailsMap.get('accountRecord')), AccountRecordWrapper.class);
                System.debug('accRecord---'+accRecord);
                //Case for Other
                if(accRecord.County != null) {
                    List<Account> accounts = [SELECT Id,Name FROM Account WHERE Name = :accRecord.County AND Entity_Type__c='County'];
                    for(Account acc : accounts) {
                        accountByName.put(acc.Name, acc.Id);
                    }
                    accountId = String.valueOf(accountByName.get(accRecord.County));
                } else if(accRecord.FederalTaxID != null) {
                    List<Account> accountToUpdateList = new List<Account>();
                    List<Account> accounts = [SELECT Id,Name,Federal_Tax_ID__c,ParentId,Entity_Type__c,Entity_Id__c,Owner.ContactId
                                                FROM Account WHERE Entity_Id__c = :accRecord.FederalTaxID AND Name = :accRecord.NonGovernmentalEntity];

                    System.debug('account for other category---'+accounts);
                    if(accounts.size() > 0) {
                        for(Account acc : accounts) {
                            if(acc.Owner.ContactId != null) {
                                acc.OwnerId = accountOwnerId;
                                accountToUpdateList.add(acc);
                            }
                        }
                        if(accountToUpdateList.size() > 0) {
                            update accountToUpdateList;
                            accountId = accountToUpdateList[0].Id;
                        } else {
                            accountId = accounts[0].Id;
                        }
                    }
                    Map<String, Id> countyAccToId = new Map<String, Id>();
                    String sopAccountName = KeyValueHelper.getTextValue('SOC_OPS_Non_Government_Parent_Name');
                    List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name = :accRecord.County AND Entity_Type__c = 'County'];
                    for(Account acnt : accountList) {
                        countyAccToId.put(acnt.name, acnt.Id);
                    }
                    if(accounts.isEmpty()) {
                        //We create a new account here
                        if(!String.isBlank(sopAccountName)) {
                            Account account = new Account();
                            account.Name = accRecord.NonGovernmentalEntity;
                            account.OwnerId = accountOwnerId;
                            if(accountList.size() > 0) {
                                account.ParentId = countyAccToId.get(accRecord.County);
                            }
                            account.Entity_Type__c = 'Non-Governmental Entity';
                            account.Entity_Id__c = accRecord.FederalTaxID;
                            account.ShippingCity = accRecord.CityName;
                            account.ShippingStreet = accRecord.StreetAddress;
                            account.ShippingState = accRecord.State;
                            account.ShippingPostalCode = accRecord.ZipPostalCode;
                            insert account;
                            accountId = account.id;
                        }
                    }
                }
                //Case for Health Care Facility
                if(accRecord.FacilityID != null) {
                    List<Account> accountToUpdateListHealth = new List<Account>();
                    List<Account> accounts = [SELECT Id, Federal_Tax_ID__c, ParentId, Entity_Id__c, Entity_Type__c, Owner.ContactId
                                                FROM Account WHERE Entity_Id__c = :accRecord.FacilityID AND Name = :accRecord.FacilityName];
                    
                    System.debug('accounts---'+accounts);
                    for(Account acc : accounts) {
                        if(acc.Owner.ContactId != null) {
                            System.debug('account owner---'+accountOwnerId);
                            acc.OwnerId = accountOwnerId;
                            accountToUpdateListHealth.add(acc);
                        }
                    }
                    if(accountToUpdateListHealth.size() > 0) {
                        System.debug('accountToUpdateList---'+accountToUpdateListHealth);
                        update accountToUpdateListHealth;
                        accountId = accountToUpdateListHealth[0].Id;
                    } else {
                        accountId = accounts[0].Id;
                    }
                    Map<String, Id> countyAccToId = new Map<String, Id>();
                    List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name = :accRecord.County AND Entity_Type__c = 'County'];
                    for(Account acnt : accountList) {
                        countyAccToId.put(acnt.name, acnt.Id);
                    }
                    if(accounts.isEmpty()) {
                        Account account = new Account();
                        account.Name = accRecord.FacilityName;
                        account.OwnerId = accountOwnerId;
                        if(accountList.size() > 0) {
                            account.ParentId = countyAccToId.get(accRecord.County);
                        }
                        account.Entity_Type__c = accRecord.NonGovernmentalEntity;
                        account.Entity_Id__c = accRecord.FacilityID;
                        account.ShippingCity = accRecord.CityName;
                        account.ShippingStreet = accRecord.StreetAddress;
                        account.ShippingState = accRecord.State;
                        account.ShippingPostalCode = accRecord.ZipPostalCode;
                        insert account;
                        accountId = account.id;
                    }
                }
            }
        } catch(Exception e) {
            System.debug('error exception in process account---'+e.getStackTraceString());
        }
        
        return accountId;
    }

    /*************************************************************** 
    Name : processApplicationsForFEMA
    Author : Rakesh
    Date : 26th July 2021
    Description : This method checks whether the accountContactJunction is present or not and then process it.
                    Currently this method is getting called from HMA_applicationTriggerHandler class
    ****************************************************************/
    public static void processApplicationsForFEMA(Set<Id> applicationIds) {
        if(applicationIds.size() < 0) return;
        Map<Id, List<Id>> appIdtoContactIdsMap = new Map<Id, List<Id>>();
        //TODO : which account to take
        Map<Id, Application__c> appIdtoApplicationMap = new Map<Id, Application__c>([SELECT Id, Status_Reason__c, Status__c, (SELECT Id, Contact__c, Contact__r.Email, Role__c FROM Contact_Roles__r
                                                                                        WHERE Role__c includes('FEMA EHP Analyst', 'FEMA Viewer', 'FEMA Programmatic Analyst'))
                                                                                        FROM Application__c
                                                                                        WHERE Id IN : applicationIds]);
        for(Application__c app : appIdtoApplicationMap.values()) {
            List<Id> tempContactIds = new List<Id>();
            for(Contact_Role__c crole : app.Contact_Roles__r) {
                tempContactIds.add(crole.Contact__c);
            }
            appIdtoContactIdsMap.put(app.Id, tempContactIds);
        }
        //Share the application and send the invite
        if(appIdtoContactIdsMap.size() > 0) {
            checkUserAndCreateCommunityApplicationUser(applicationIds);
            //assignPermissionSetBasedOnContactRole(appIdtoApplicationMap);
            sendInviteToContactRoleUsers(appIdtoApplicationMap);
        }
    }
    
    /*Send invitation to new contact role added under application */
    /*TODO: update contact HMA Invitation Sent and HMA Invitation Sent on flag once email sent*/
    public static void sendInviteToContactRoleUsers( Map<Id, Application__c> appIdtoApplicationMap) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> ccAddresses = new List<String>();

        for(Application__c app : appIdtoApplicationMap.values()) {
            for(Contact_Role__c contactRole : app.Contact_Roles__r) {
                String emailTemplateName = '';
                List<String> roles = contactRole.Role__c?.split(';');
                if(roles != null){
                if((app.Status__c.equals(HMA_CONSTANTS.APPLICATION_STATUS_FEMA_REVIEW) || app.Status__c.equals(HMA_CONSTANTS.APPLICATION_STATUS_FEMA_DECISION))
                            && (roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_EHP_ANALYST) != -1 ||
                            roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_PROGRAMMATIC_ANALYST) != -1 ||
                            roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_REVIEW) != -1)
                        ) {
                    emailTemplateName = HMA_CONSTANTS.HMA_FEMA_USER_INVITATION_FOR_APPLICATION_REVIEW;

                    }else if(roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR) != -1 ||
                            roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) != -1 ||
                            roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER) != -1 ||
                            roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR) != -1){
                    emailTemplateName = HMA_CONSTANTS.EMAIL_TEMPLATE_HMA_SEND_INVITE_CONTACT_ROLE_NOTIFICATION;
                }
                if(String.isNotEmpty(emailTemplateName)){
                        List<Messaging.SingleEmailMessage> tempMails = sendEmail((SObject) app, new List<String>{contactRole.Contact__r.Email}, ccAddresses, emailTemplateName, HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, contactRole.Contact__c);
                        if(tempMails != null && tempMails.size()>0){
                    String role = contactRole.Role__c;
                    String formattedContactRole = role.removeEnd(';');
                    formattedContactRole = formattedContactRole.replace(';', ', ');
                    tempMails[0].htmlBody = tempMails[0].htmlBody.replace('ContactRole', formattedContactRole);
                    tempMails[0].subject = tempMails[0].subject.replace('ContactRole', formattedContactRole);
                    //tempMails[0].htmlBody = generateDynamicUrlforCommunity(tempMails[0].htmlBody, conIdtoUserIdMap, crole.Contact__c);
                    mails.addAll(tempMails);
                }
            }
           }
        }
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails);
        }
    }

    public class AccountRecordWrapper {
        public String NonGovernmentalEntity;
        public String FederalTaxID;
        public String Facility;
        public String FacilityName;
        public String FacilityID;
        public String StreetAddress;
        public String CityName;
        public String County;
        public String State;
        public String ZipPostalCode;
    }

    /**This Methis is user for get contact Ids of Contact Role which having role as 'Responsible Representative', 'Primary Contact', 'Contributor' */
    public static Map<Id, Set<Id>> getContactIdsOfSubApplicants(Set<Id> applicationIds) {
        Map<Id, Set<Id>> contactIdtoApplicationIdsMap = new Map<Id, Set<Id>>();
        List<Contact_Role__c > conRoles = [SELECT   
                                                Id, 
                                                Contact__c, 
                                                Role__c,
                                                AccountContactJunction__c, 
                                                AccountContactJunction__r.Contact_Name__c, 
                                                AccountContactJunction__r.Contact_Name__r.Email, 
                                                Application__c 
                                                FROM Contact_Role__c  
                                                WHERE Application__c IN: applicationIds AND Role__c includes('Responsible Representative', 'Primary Contact', 'Contributor')];

        for(Contact_Role__c role : conRoles) {
            if(String.isNotEmpty(role.AccountContactJunction__r.Contact_Name__c)) {
                if(contactIdtoApplicationIdsMap.get(role.AccountContactJunction__r.Contact_Name__c) == null) {
                    contactIdtoApplicationIdsMap.put(role.AccountContactJunction__r.Contact_Name__c, new Set<Id>());
                }
                contactIdtoApplicationIdsMap.get(role.AccountContactJunction__r.Contact_Name__c).add(role.Application__c);
            }            
        }
        return contactIdtoApplicationIdsMap;
    }
    public static void updateScoringChecklistOESBriefSummary(Map<Id, Application__c> appIdToApplicationMap) {
        List<Scoring_Checklist__c> updateSC = new List<Scoring_Checklist__c>();
        List<Scoring_Checklist__c> scList = [SELECT Id, OES_Analyst_Brief_Summary__c, Application__c FROM Scoring_Checklist__c WHERE Application__c IN: appIdToApplicationMap.keySet()];
        for(Scoring_Checklist__c sc : scList) {
            Application__c app = appIdToApplicationMap.get(sc.Application__c);
            sc.OES_Analyst_Brief_Summary__c = app.OES_Analyst_Brief_Summary__c;
            updateSC.add(sc);
        }
        update updateSC;
    }

    /**Validate some fields when user changed Application status to FEMA Review */
    public static void validateAppWhenStatusIsFEMAReview(List<Application__c> femaApplications) {
        for(Application__c app : femaApplications) {
            if(app.Is_this_an_eligible_Activity__c != 'Yes') {
                app.Is_this_an_eligible_Activity__c.addError(HMA_CONSTANTS.APPLICATION_IS_THIS_AN_ELIGIBLE_ACTIVITY_VALUE_SHOULD_BE_YES);
            }
            if(app.Is_this_an_eligible_Subapplicant__c != 'Yes') {
                app.Is_this_an_eligible_Subapplicant__c.addError(HMA_CONSTANTS.APPLICATION_IS_THIS_AN_ELIGIBLE_SUBAPPLICANT_VALUE_SHOULD_BE_YES);
            }
            if(app.Is_BCR_verified_at_1_0_or_greater__c == 'No' || app.Is_BCR_verified_at_1_0_or_greater__c == 'Pending') {
                app.Is_BCR_verified_at_1_0_or_greater__c.addError(HMA_CONSTANTS.APPLICATION_IS_BCR_VERIFIED_AT_1_OR_GREATER_VALUE_SHOULD_BE_YES_OR_NOT_APPLICABLE);
            }
            if(app.Match_Letter__c != 'Yes') {
                app.Match_Letter__c.addError(HMA_CONSTANTS.APPLICATION_MATCH_LETTER_VALUE_SHOULD_BE_YES);
            }
            if(app.Maintenance_Letter__c != 'Yes') {
                app.Maintenance_Letter__c.addError(HMA_CONSTANTS.APPLICATION_MAINTENANCE_LETTER_VALUE_SHOULD_BE_YES);
            }
            if(app.Subapplication_Complete__c != 'Yes') {
                app.Subapplication_Complete__c.addError(HMA_CONSTANTS.APPLICATION_READY_TO_SUBMIT_VALUE_SHOULD_BE_YES);
            }
        }
    }
}