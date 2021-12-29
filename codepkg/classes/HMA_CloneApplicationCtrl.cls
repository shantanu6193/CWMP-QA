public without sharing class HMA_CloneApplicationCtrl {
    private SObjectType type;
    private static Id clonedApplicationId;
    private static HMA_CloneApplicationCtrl obj = new HMA_CloneApplicationCtrl();

    private static Set<String> relationshipsToClone = new Set<String>{'Application_Extensions__r',
                                                                    'Project_Budgets__r', 
                                                                    'Project_Costs__r',
                                                                    'Project_Cost_Line_Items__r',
                                                                    'Work_Schedules__r',
                                                                    'Work_Schedules_Line_Items__r',
                                                                    'Documents__r'};
    //'Request_For_Informations__r', 'Scoring_Checklists__r',

    private static Map<String, Object> returnMap = new Map<String, Object>();
    public HMA_CloneApplicationCtrl() {
    }

    @AuraEnabled
    public static Map<String, Object> CloneApplication(String applicationId) {
        Savepoint sp = Database.setSavepoint(); 
        try {
            Application_Extension__c appExtension;
            List<SObject> applicationClonedRecords = obj.SObjectDeepClone(new Set<Id>{(Id) applicationId}, relationshipsToClone);

            returnMap.put('isSuccess', false);
            if(applicationClonedRecords.size() == 0) return returnMap;

            TriggerHelper.skipTrigger = true;

            String oldAppOwnerId = [SELECT Id, Pre_Application__r.OwnerId FROM Application__c WHERE Id = :applicationId]?.Pre_Application__r.OwnerId;

            applicationClonedRecords[0].put('Status__c', HMA_CONSTANTS.APPLICATION_STATUS_DRAFT);
            applicationClonedRecords[0].put('Status_Reason__c', HMA_CONSTANTS.APPLICATION_STATUS_REASON_NOT_STARTED);
            applicationClonedRecords[0].put('Parent_Application__c', applicationId);
            applicationClonedRecords[0].put('Is_Any_Open_RFI__c', false);
            if(String.isNotBlank(oldAppOwnerId) && oldAppOwnerId.startsWith('005')) {
                applicationClonedRecords[0].put('OwnerId', oldAppOwnerId);
            }
            insert applicationClonedRecords[0];
            Application__c oldApplication = new Application__c(Id=applicationId, Child_Application__c = applicationClonedRecords[0].Id);
            update oldApplication;
            clonedApplicationId = applicationClonedRecords[0].Id;

            //To fix error 'aggregate query has too many rows for direct assignment, use for loop' separate query is needed 
            Contact_Role__c[] contactRoles = [SELECT Role__c, AccountContactJunction__c, Type__c, Application_Extension__c, Contact__c, Application__c FROM Contact_Role__c WHERE Application__c = :applicationId];

            if(applicationClonedRecords[0].getSobjects('Application_Extensions__r') != null) {
                appExtension = cloneApplicationExtension((List<Application_Extension__c>) applicationClonedRecords[0].getSobjects('Application_Extensions__r'));
            }
            // if(applicationClonedRecords[0].getsobjects('Scoring_Checklists__r') != null) {
            //     cloneScoringChecklist((List<Scoring_Checklist__c>) applicationClonedRecords[0].getsobjects('Scoring_Checklists__r'), appExtension.Id);
            // }
            if(applicationClonedRecords[0].getSobjects('Work_Schedules__r') != null) {
                cloneWorkSchedule((List<Work_Schedule__c>) applicationClonedRecords[0].getSobjects('Work_Schedules__r'));
            }
            if(contactRoles.size() > 0) {
                cloneContactRoles(contactRoles);
            }
            returnMap.put('applicationRecord', applicationClonedRecords[0]);
            if(returnMap.get('contactRoleRecords') != null) {
                shareClonedRecordsWithCommunityUser((List<Contact_Role__c>) returnMap.get('contactRoleRecords'));
            }
            
            returnMap.put('isSuccess', true);
            TriggerHelper.skipTrigger = false;
        } catch (Exception e) {
            Database.rollback(sp);
            returnMap.put('isSuccess', false);
            returnMap.put('error', e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
        return returnMap;
    }
    public static void shareClonedRecordsWithCommunityUser(List<Contact_Role__c> contactRoleRecords) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Set<Id>> SObjectIdToUserIds = new Map<Id, Set<Id>>();
        for(Contact_Role__c conRole : contactRoleRecords) {
            if(String.isNotBlank(conRole.Contact__c)) {
                contactIds.add(conRole.Contact__c);
            }
        }
        List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN : contactIds];
        for(User u : users) {
            if(SObjectIdToUserIds.get(clonedApplicationId) == null) {
                SObjectIdToUserIds.put(clonedApplicationId, new Set<Id>());
            }
            // if(u.Id != UserInfo.getUserId()) {
            //     SObjectIdToUserIds.get(clonedApplicationId).add(u.Id);
            // }  
            SObjectIdToUserIds.get(clonedApplicationId).add(u.Id);          
        }
        /** Share the Application record with specific User */
        if(SObjectIdToUserIds.size() > 0) {
            Boolean isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(SObjectIdToUserIds, 'Application__share', 'Edit', Schema.Application__share.RowCause.Shared_with_Contact_Roles__c);
            if(isRecordShared) {
                System.debug('Cloned Application Records shared Successfully.');
                /**Used for share the Document records related to Application with User*/
                HMA_ApplicationHelper.shareSubApplicationDocuments(clonedApplicationId, SObjectIdToUserIds.get(clonedApplicationId));
            }
        }
    }
    public static void cloneContactRoles(List<Contact_Role__c> contactRoles) {
        Set<Id> contactRoleIds = new Set<Id>();
        for(Contact_Role__c contactRole : contactRoles) {
            contactRoleIds.add(contactRole.Id);
        }
        List<Contact_Role__c> contactRoleRecords = (List<Contact_Role__c>) obj.SObjectDeepClone(contactRoleIds, relationshipsToClone);
        for(Contact_Role__c cr : contactRoleRecords) {
            cr.Application__c = clonedApplicationId;
        }
        insert contactRoleRecords;
        returnMap.put('contactRoleRecords', contactRoleRecords);
    }
    public static void cloneWorkSchedule(List<Work_Schedule__c> workSchedules) {
        /** We consider there is only one Work Schedule record related to Application */
        List<Work_Schedule__c> workScheduleRecords = (List<Work_Schedule__c>) obj.SObjectDeepClone(new Set<Id>{workSchedules[0].Id}, relationshipsToClone);
        workScheduleRecords[0].Application__c = clonedApplicationId;

        insert workScheduleRecords[0];
        if(workScheduleRecords[0].getsobjects('Documents__r') != null) {
            cloneDocuments((List<Document__c>) workScheduleRecords[0].getsobjects('Documents__r'), workScheduleRecords[0].Id);
        }
        if(workScheduleRecords[0].getSobjects('Work_Schedules_Line_Items__r') != null) {
            cloneWorkScheduleLineItems((List<Work_Schedule_Line_Item__c>) workScheduleRecords[0].getSobjects('Work_Schedules_Line_Items__r'), workScheduleRecords[0].Id);
        }
        returnMap.put('workScheduleRecords', workScheduleRecords[0]);
    }
    public static void cloneWorkScheduleLineItems(List<Work_Schedule_Line_Item__c> workScheduleLineItems, Id workScheduleId) {
        Set<Id> wsliIds = new Set<Id>();
        for(Work_Schedule_Line_Item__c wsli : workScheduleLineItems) {
            wsliIds.add(wsli.Id);
        }
        List<Work_Schedule_Line_Item__c> workScheduleLineItemRecords = (List<Work_Schedule_Line_Item__c>) obj.SObjectDeepClone(wsliIds, relationshipsToClone);
        for(Work_Schedule_Line_Item__c wsli : workScheduleLineItemRecords) {
            wsli.Work_Schedule__c = workScheduleId;
        }

        insert workScheduleLineItemRecords;
        returnMap.put('workScheduleLineItemRecords', workScheduleLineItemRecords);
    }
    /*public static void cloneScoringChecklist(List<Scoring_Checklist__c> scoringChecklists, Id applicationExtensionId) {
        Set<Id> scIds = new Set<Id>();
        for(Scoring_Checklist__c sc : scoringChecklists) {
            scIds.add(sc.Id);
        }
        List<Scoring_Checklist__c> scoringChecklistRecords = (List<Scoring_Checklist__c>) obj.SObjectDeepClone(scIds, relationshipsToClone);
        for(Scoring_Checklist__c sc : scoringChecklistRecords) {
            sc.Application__c = clonedApplicationId;
            if(String.isNotBlank(applicationExtensionId)) {
                sc.Application_Extension__c = applicationExtensionId;
            }
        }

        insert scoringChecklistRecords;
        returnMap.put('scoringChecklistRecords', scoringChecklistRecords);
    }*/
    public static Application_Extension__c cloneApplicationExtension(List<Application_Extension__c> appExtensions) {
        /** We consider there is only one Application Extension record related to Application */
        List<Application_Extension__c> appExtensionRecords = (List<Application_Extension__c>) obj.SObjectDeepClone(new Set<Id>{appExtensions[0].Id}, relationshipsToClone);
        appExtensionRecords[0].Application__c = clonedApplicationId;

        insert appExtensionRecords[0];
        System.debug('appExtensionRecord : '+ appExtensionRecords[0]);
        
        if(appExtensionRecords[0].getsobjects('Documents__r') != null) {
            cloneDocuments((List<Document__c>) appExtensionRecords[0].getsobjects('Documents__r'), appExtensionRecords[0].Id);
        }
        if(appExtensionRecords[0].getsobjects('Project_Budgets__r') != null) {
            cloneProjectBudget((List<Project_Budget__c>) appExtensionRecords[0].getsobjects('Project_Budgets__r'), appExtensionRecords[0].Id);
        }        
        returnMap.put('appExtensionRecord', appExtensionRecords[0]);
        return appExtensionRecords[0];
    }
    public static void cloneDocuments(List<Document__c> documents, Id sObjectId) {
        Set<Id> documentIds = new Set<Id>();
        String returnMapKey = 'documentRecords';
        String parentObject = sObjectId.getSobjectType().getDescribe().getName();
        for(Document__c doc : documents) {
            documentIds.add(doc.Id);
        }
        List<SObject> documentCloneRecords = obj.SObjectDeepClone(documentIds, relationshipsToClone);
        List<Document__c> documentRecords = (List<Document__c>) documentCloneRecords;
        for(Document__c doc : documentRecords) {
            if(parentObject == 'Application_Extension__c') {
                returnMapKey = 'applicationExtensionDocuments';
                doc.Application_Extension__c = sObjectId;
            } else if(parentObject == 'Work_Schedule__c'){
                returnMapKey = 'workScheduleDocuments';
                doc.Work_Schedule__c = sObjectId;
            }
            doc.Application__c = clonedApplicationId;
            doc.Stage__c = 'New';
        }

        insert documentRecords;
        returnMap.put(returnMapKey, documentRecords);
    }
    public static void cloneProjectBudget(List<Project_Budget__c> projectBudgets, Id appExtensionId) {
        Set<Id> projectBudgetIds = new Set<Id>();
        Map<Id, List<Project_Cost__c>> pbIdToProjectCostListMap = new Map<Id, List<Project_Cost__c>>();
        for(Project_Budget__c pb : projectBudgets) {
            projectBudgetIds.add(pb.Id);
        }
        List<SObject> pbCloneRecords = obj.SObjectDeepClone(projectBudgetIds, relationshipsToClone);
        List<Project_Budget__c> pbRecords = (List<Project_Budget__c>) pbCloneRecords;
        for(Project_Budget__c pb : pbRecords) {
            pb.Application_Extension__c = appExtensionId;
            pb.Application__c = clonedApplicationId;
                     
        }

        insert pbRecords;
        for(Project_Budget__c pb : pbRecords) {
            if(pb.getsobjects('Project_Costs__r') != null) {
                pbIdToProjectCostListMap.put(pb.Id, new List<Project_Cost__c>());
                pbIdToProjectCostListMap.get(pb.Id).addAll((List<Project_Cost__c>) pb.getsobjects('Project_Costs__r'));
            }   
        }
        if(pbIdToProjectCostListMap.size() > 0) {
            cloneProjectCosts(pbIdToProjectCostListMap);
        }
        returnMap.put('projectBudgetRecords', pbRecords);
    }
    public static void cloneProjectCosts(Map<Id, List<Project_Cost__c>> pbIdToProjectCostListMap) {
        Map<Id, List<Project_Cost_Line_Item__c>> pcTopcliListMap = new Map<Id, List<Project_Cost_Line_Item__c>>();
        List<Project_Cost__c> clonePCRecords = new List<Project_Cost__c>();
        for(Id pbId : pbIdToProjectCostListMap.keySet()) {
            Set<Id> pcIds = new Set<Id>();
            for(Project_Cost__c pc : pbIdToProjectCostListMap.get(pbId)) {
                pcIds.add(pc.Id);
            }
            /**
             * We called SObjectDeepClone method from for loop beacuse we know there is always two records of Project_Budget__c
             */
            List<SObject> pcCloneRecords = obj.SObjectDeepClone(pcIds, relationshipsToClone);
            List<Project_Cost__c> pcRecords = (List<Project_Cost__c>) pcCloneRecords;
            for(Project_Cost__c clonedPC : pcRecords) {
                clonedPC.Project_Budget__c = pbId;
                clonePCRecords.add(clonedPC);
            }   
        }

        insert clonePCRecords;
        for(Project_Cost__c pc : clonePCRecords) {
            if(pc.getSobjects('Project_Cost_Line_Items__r') != null) {
                pcTopcliListMap.put(pc.Id, new List<Project_Cost_Line_Item__c>());
                pcTopcliListMap.get(pc.Id).addAll((List<Project_Cost_Line_Item__c>) pc.getSobjects('Project_Cost_Line_Items__r'));
            }
        }
        if(pcTopcliListMap.size() > 0) {
            cloneProjectCostLineItems(pcTopcliListMap);
        }
        returnMap.put('projectCostRecords', clonePCRecords);
    }
    public static void cloneProjectCostLineItems(Map<Id, List<Project_Cost_Line_Item__c>> pcTopcliListMap) {
        List<Project_Cost_Line_Item__c> clonePCLIRecords = new List<Project_Cost_Line_Item__c>();
        for(Id pcId : pcTopcliListMap.keySet()) {
            Set<Id> pcliIds = new Set<Id>();
            for(Project_Cost_Line_Item__c pcli : pcTopcliListMap.get(pcId)) {
                pcliIds.add(pcli.Id);
            }
            /**
             * We called SObjectDeepClone method from for loop beacuse we know there is always limited records of Project_Cost_Line_Item__c
             */
            List<SObject> pcliCloneRecords = obj.SObjectDeepClone(pcliIds, relationshipsToClone);
            List<Project_Cost_Line_Item__c> pcliRecords = (List<Project_Cost_Line_Item__c>) pcliCloneRecords;
            for(Project_Cost_Line_Item__c clonedPCLI : pcliRecords) {
                clonedPCLI.Project_Cost__c = pcId;
                clonePCLIRecords.add(clonedPCLI);
            }   
        }

        insert clonePCLIRecords;
        returnMap.put('projectCostLineItemRecords', clonePCLIRecords);
    }




    /**
     * This is common used for clone SObject
     * Parameters : 
     * Set<Id> toCloneIds : Sobject Ids for clone
     * Set<String> relationshipsToClone : Objects related to Cloned sObject for clone
     */
    public  List<SObject> SObjectDeepClone(Set<Id> toCloneIds, Set<String> relationshipsToClone) {
        List<SObject> clonedRecords = new List<SObject>();
        Id sObjectId = new List<Id> (toCloneIds).get(0);
        this.type = sObjectId.getSObjectType();
        Map<string, ChildRelationshipProps> relationshipMap = mapStringsToRelations(relationshipsToClone);
        List<SObject> toCloneRecords = retrieveSObject(toCloneIds, relationshipMap);
        /**Parameters : 
         * clone(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber) */
        for(SObject toCloneRecord : toCloneRecords) {
            SObject clonedRecord = toCloneRecord.clone(false, false, false, false);
            clonedRecords.add(clonedRecord);
        }
        
        return clonedRecords;
    }

    private Map<string, ChildRelationshipProps> mapStringsToRelations(Set<String> relationshipStrings) {
        Map<string, ChildRelationshipProps> relationshipMap = new Map<string, ChildRelationshipProps>();
        Map<String, ChildRelationship> childRelationshipNameToRelationMap = new Map<String, ChildRelationship>();
        System.debug('type--------------'+ type);
        List<Schema.ChildRelationship> childRelationships = type.getDescribe().getChildRelationships();
        for (ChildRelationship rel : childRelationships) {
            String relName = rel.getRelationshipName();
            if (relName != null) {
                childRelationshipNameToRelationMap.put(rel.getRelationshipName().toUpperCase(), rel);
            }
        }
        for (String relStr : relationshipStrings) {
            relStr = relStr.toUpperCase();
            if (childRelationshipNameToRelationMap.containsKey(relStr)) {
                ChildRelationship rel = childRelationshipNameToRelationMap.get(relStr);
                relationshipMap.put(rel.getRelationshipName().toUpperCase(), new ChildRelationshipProps(rel));
            } 
        }
        return relationshipMap;
    }

    private List<SObject> retrieveSObject(Set<Id> toCloneIds, Map<string, ChildRelationshipProps> relationshipMap) {
        List<String> selectFields = getCreatableFields(type);

        /**This is used for generate Sub-query */
        for (String relationName : relationshipMap.keySet()) {
            ChildRelationshipProps rel = relationshipMap.get(relationName);
            List<String> relationFields = getCreatableFields(rel.sObjectType);
            if (relationFields.size() > 0) {
                /**Adding child Object(Application_Extensions__r, Request_For_Informations__r, etc.) query in selectFields */
                String childObjectQuery = buildQuery(relationFields, relationName, null);
                selectFields.add('(' + childObjectQuery + ')');
            }
        }

        /**This is used for generate Main-query (means Application query with child Object) */
        String mainQuery = buildQuery(selectFields,
                                        type.getDescribe().getName(),
                                        'ID IN: toCloneIds ');

        System.debug('Query : '+ mainQuery);
        return ((List<SObject>) Database.query(mainQuery));
    }

    private List<String> getCreatableFields(SObjectType objType) {
        DescribeSObjectResult describe = objType.getDescribe();
        /**Genrate a map of field name and field token */
        Map<String, Schema.SObjectField> fMap = describe.Fields.getMap();
        List<String> creatableFields = new List<String>();
        if(fMap.size() > 0) {
            /**loop through all field tokens (ft) */
            for (Schema.SObjectField ft : fMap.values()) { 
                /**describe each field (fd) */
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
                /**Check for is field creatable */
                if (fd.isCreateable() && !fd.isUnique()) {                    
                    creatableFields.add(fd.getName());
                }
            }
        }
        return creatableFields;
    }

    private string buildQuery(String[] fields, String fromObj, string whereClause) {
        String qry = 'SELECT ' + String.join(fields, ',') + ' FROM ' + fromObj;
        if (!String.isEmpty(whereClause)) {
            qry += ' WHERE ' + whereClause;
        }
        return qry;
    }

    /**seralizable subset of ChildRelationship properties that we need */
    private class ChildRelationshipProps {
        public SObjectType sObjectType;
        public SObjectField field;
        public ChildRelationshipProps(ChildRelationship rel) {
            this.sObjectType = rel.getChildSObject();
            this.field = rel.getField();
        }
    }

}