public without sharing class HMA_Utility {
   
    /** 
     **************** Parameters **************************
     * Map<Id, Set<Id>> SObjectIdToUserIds : Object Record Id to set of User or Group Ids
     * String shareObjectName : Object Share Api Name like Application__share
     * String strAccessLevel : Access level like Read or Edit
     * String strRowCause : Record Sharing Reason Ex: for Application__c - Schema.Application__share.RowCause.Manual
     */
    public static Boolean shareCustomObjectRecordsWithUser(Map<Id, Set<Id>> SObjectIdToUserIds, String shareObjectName, String strAccessLevel, String strRowCause) {
        List<SObject> lstObjects = new List<SObject>();
        if(SObjectIdToUserIds.size() == 0 && String.isEmpty(shareObjectName) && !shareObjectName.contains('__share')) return false;
        SObjectType objectType = Schema.getGlobalDescribe().get(shareObjectName);
        for(Id sObjId : SObjectIdToUserIds.keySet()) {
            for(Id userId : SObjectIdToUserIds.get(sObjId)) {
                SObject shareRecord = objectType.newsObject();
                shareRecord.put('ParentId', sObjId);
                shareRecord.put('UserOrGroupId', userId);
                shareRecord.put('AccessLevel', strAccessLevel);
                shareRecord.put('RowCause', strRowCause);
                lstObjects.add(shareRecord);
            }
        }
        if(!lstObjects.isEmpty()) {
            insert lstObjects;
            
            return true;
        }   
        return false;
    }
    /**
     * Method used to get Application related RFIs
     * Set<String> appIds : Application Ids
     * Set<String> RFITypes : RFI Types
     * Set<String> status : RFI Status
     * String strRowCause : Record Sharing Reason Ex: for Application__c - Schema.Application__share.RowCause.Manual
    */
    public static List<Request_For_Information__c> getApplicationRFIs(Set<String> appIds, Set<String> RFITypes, Set<String> status){
        //Request_For_Information__c[] rfiList = [SELECT Id, Analyst_Comment__c, Subapplicant_Comment__c, RFI_Deadline__c, Name, Application__c from Request_For_Information__c WHERE Id IN: RFIIds AND RFI_Type__c IN: RFITypes AND Status__c IN: status];
        String query = 'SELECT Id, Name, Analyst_Comment__c, Subapplicant_Comment__c, RFI_Deadline__c, Application__c from Request_For_Information__c WHERE Application__c IN: appIds ';
                    if(RFITypes.size() > 0){
                        query += ' AND RFI_Type__c IN: RFITypes ';
                    }
                    if(status.size() > 0){
                        query += ' AND Status__c IN: status';
                    }
        return Database.query(query);
    }

    public static SObject convertSIdToSObject(String sobjectName ,Id sId) {
        SObject app = (SObject) (Type.forName('Schema.'+sobjectName).newInstance());
        app.Id = sId;
        return app;
    }
    

    /** This method is used for share Document records related to Application With Responsible Representative, Requestor, Contributor */
    public static void shareApplicationRelatedDocumentsWithSpecificUser(Map<Id, Set<Id>> applicationIdToUserIds) {
        Map<Id, Set<Id>> documentIdToUserIdsMap = new Map<Id, Set<Id>>();
        List<Document__c> docRecords = [SELECT Id, Application__c, Document_Name__c  FROM Document__c WHERE Application__c IN: applicationIdToUserIds.keySet()];
        System.debug('docRecords------------'+ docRecords);
        for(Document__c doc : docRecords) {
            if(documentIdToUserIdsMap.get(doc.Id) == null) {
                documentIdToUserIdsMap.put(doc.Id, new Set<Id>());
            }
            documentIdToUserIdsMap.get(doc.Id).addAll(applicationIdToUserIds.get(doc.Application__c));
        }
        System.debug('documentIdToUserIdsMap-App-----------'+ documentIdToUserIdsMap);
        if(documentIdToUserIdsMap.size() > 0) {
            Boolean isRecordShared = shareCustomObjectRecordsWithUser(documentIdToUserIdsMap, 'Document__share', 'Edit', Schema.Document__share.RowCause.Manual);
            if(isRecordShared) {
                System.debug('Document records of Application are shared Successfully.');
            }
        }
    }

    /** This method is used for share Document records related to Project Site With Responsible Representative, Requestor, Contributor */
    public static void shareProjectSiteRelatedDocumentsWithSpecificUser(Map<Id, Set<Id>> applicationIdToUserIds) {
        Map<Id, Set<Id>> projectSiteToUserIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> documentIdToUserIdsMap = new Map<Id, Set<Id>>();

        List<Project_Site__c> projectSites = [SELECT Id, Application__c FROM Project_Site__c WHERE Application__c IN: applicationIdToUserIds.keySet()];
        System.debug('projectSites------------'+ projectSites);
        for(Project_Site__c proSite : projectSites) {
            if(projectSiteToUserIds.get(proSite.Id) == null) {
                projectSiteToUserIds.put(proSite.Id, new Set<Id>());
            }
            projectSiteToUserIds.get(proSite.Id).addAll(applicationIdToUserIds.get(proSite.Application__c));
        }
        System.debug('projectSiteToUserIds-PS-----------'+ projectSiteToUserIds);
        List<Document__c> docRecords = [SELECT Id, Application__c, Project_Site__c, Document_Name__c  FROM Document__c WHERE Project_Site__c IN: projectSiteToUserIds.keySet()];
        System.debug('docRecords-PS-----------'+ docRecords);
        for(Document__c doc : docRecords) {
            if(documentIdToUserIdsMap.get(doc.Id) == null) {
                documentIdToUserIdsMap.put(doc.Id, new Set<Id>());
            }
            documentIdToUserIdsMap.get(doc.Id).addAll(projectSiteToUserIds.get(doc.Project_Site__c));
        }
        System.debug('documentIdToUserIdsMap-PS-----------'+ documentIdToUserIdsMap);
        if(documentIdToUserIdsMap.size() > 0) {
            Boolean isRecordShared = shareCustomObjectRecordsWithUser(documentIdToUserIdsMap, 'Document__share', 'Edit', Schema.Document__share.RowCause.Manual);
            if(isRecordShared) {
                System.debug('Document records of Project Site are shared Successfully.');
            }
        }
    }
}