/**
         * Created by nehab on 02-10-2020.
         */

public without sharing class ALS_DocumentUpload_Ctrl {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDocumentsWithDocumentInfo(String masterRecordId ,String refreshDate) {
        Map<String, Object> resultMap = new Map<String, Object>();
        Project__c project = new Project__c();
        Payment_Request__c paymentRequest = new Payment_Request__c();
        Amendment_Request__c Amendment = new Amendment_Request__c();
        if(masterRecordId==null) {
            new AuraHandledException('Record Id can not be null');
        }

        Id masterRecordIdVersion = masterRecordId;
        String masterObjName = masterRecordIdVersion.getSObjectType().getDescribe().getName();
        String q='select Id,Name from '+  masterObjName  +' where Id = '+'\'' + masterRecordId + '\'';
        Document_Upload_Support__mdt docSupport =[SELECT Lookup_Field_Name__c,Object_API_Name__c FROM Document_Upload_Support__mdt WHERE Object_API_Name__c = : masterObjName];
        SObject test =Database.query(q);
        String lookupFieldName;
        if(!String.isEmpty(docSupport.Lookup_Field_Name__c)) {
            lookupFieldName  = docSupport.Lookup_Field_Name__c;
        }else{
            throw new AuraHandledException('we do not support document creation on this record');
        }

        List<DocumentMetaInfoWrapper> docWrapperList = new List<DocumentMetaInfoWrapper>();

        List<Document__c> docsList = new List<Document__c>();
        Map<Id, Document__c> documentIdToDocumentMap = new Map<Id, Document__c>();

        Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
        //Get all of the fields on the object - Document__c
        Set<String> documentFields = documentFieldMap.keySet();
        // Build a Dynamic Query String to fetch 'Documents'.

        String queryDocs = 'select ' + String.join((Iterable<String>) documentFields, ',') + ' ,( SELECT ContentDocumentID FROM ContentDocumentLinks)  from Document__c Where  ' +lookupFieldName+ ' = \'' + masterRecordId + '\'';
        System.debug('queryDocs++++++ '+queryDocs);
        docsList = Database.query(queryDocs);

        Map<String,String> ContentDocIdTODocumentNameMap = new Map<String, String>();
        for (Document__c doc : docsList) {
            documentIdToDocumentMap.put(doc.Id, doc);
            if(doc.ContentDocumentLinks!=null &&  doc.ContentDocumentLinks.size() > 0) {
                ContentDocIdTODocumentNameMap.put(doc.ContentDocumentLinks[0].ContentDocumentId, doc.Id);
            }
        }

        List<Program_Document__c> programDocumentsList = new List<Program_Document__c>();
        Map<String, Program_Document__c> documentNameToProgramDocumentMap = new Map<String, Program_Document__c>();

        Map<String, Schema.SObjectField> programDocumentFieldMap = Program_Document__c.sObjectType.getDescribe().fields.getMap();
        // Get all of the fields on the object - Program_Document__c
        Set<String> programDocumentFields = programDocumentFieldMap.keySet();


        List<String> strList = new List<String>();
        strList.add('\'' + '' + '\'');

        for (Document__c doc : documentIdToDocumentMap.values()) {
            strList.add('\'' + doc.Document_Name__c + '\'');
        }

        // Build a Dynamic Query String to get 'Program Document' Records .\
        String queryProgramDocs = 'select ' + String.join((Iterable<String>) programDocumentFields, ',') + ' from Program_Document__c Where Document_Name__c IN (' + String.join((Iterable<String>) strList, ',') + ')';
        System.debug('queryProgramDocs+++++'+queryProgramDocs);
        programDocumentsList = Database.query(queryProgramDocs);

        for (Program_Document__c pDoc : programDocumentsList) {
            System.debug('****pDoc****' + pDoc);
            documentNameToProgramDocumentMap.put(pDoc.Document_Name__c, pDoc);
            System.debug('****documentNameToProgramDocumentMap****' + documentNameToProgramDocumentMap);
        }


        //  ContentDocIdTODocumentNameMap.put(doc.ContentDocumentLinks[0].ContentDocumentId,doc.Document_Name__c);
        List<AggregateResult> contentVersionsCount = [SELECT COUNT(Id),ContentDocumentId From ContentVersion Where ContentDocumentId IN : ContentDocIdTODocumentNameMap.keySet() GROUP BY ContentDocumentId];
        Map<String,Integer> documentNameToVersionCountMap = new Map<String, Integer>();
        for(AggregateResult arr:contentVersionsCount){
            documentNameToVersionCountMap.put(ContentDocIdTODocumentNameMap.get((String)arr.get('ContentDocumentId')),(Integer)arr.get('expr0'));
        }

        //Create the Wrapper List Items for Each Document
        for (Document__c doc : documentIdToDocumentMap.values()) {
            DocumentMetaInfoWrapper docWrapper = new DocumentMetaInfoWrapper();
            docWrapper.documentRecord = doc;
            if (doc.ContentDocumentLinks != null && doc.ContentDocumentLinks.size() > 0) {
                docWrapper.contentDocumentLink = doc.ContentDocumentLinks[0];
            }
            docWrapper.programDocumentRecord = documentNameToProgramDocumentMap.get(doc.Document_Name__c);
            docWrapper.versionCount = documentNameToVersionCountMap.get(doc.Id);
            //docWrapper.allowedFileTypes = '';
            docWrapperList.add(docWrapper);
        }

        //resultMap.put('ProjectName', project.Name);
        resultMap.put('docWrapperList', docWrapperList);
        resultMap.put('lookupFieldName', lookupFieldName);
        return resultMap;
    }


// wrapper class for Document and Program Document with @AuraEnabled and {get;set;} properties and
    public class DocumentMetaInfoWrapper {
        @AuraEnabled
        public Document__c documentRecord { get; set; }

        @AuraEnabled
        public ContentDocumentLink contentDocumentLink { get; set; }

        @AuraEnabled
        public Program_Document__c programDocumentRecord { get; set; }

        @AuraEnabled
        public Integer versionCount { get; set; }

    }


    @AuraEnabled
    public static Map<String, Object> saveFileDetails(String documentRecordId, String uploadedFileId ,String recordId) {
        List<Document__c> document = [SELECT Id,Stage__c, Global_Document__c, Document_Name__c,Uploaded_By__c,Date_Uploaded__c,ProjectId__r.Name,PaymentRequest__r.Name,PaymentRequest__r.Project__r.Name,(SELECT ContentDocumentId ,ContentDocument.CreatedDate , ContentDocument.Id , ContentDocument.Title FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC  )  from Document__c Where Id = :documentRecordId];
        if(document[0].Stage__c != 'Uploaded') {
            document[0].Stage__c = 'Uploaded';
            document[0].Date_Uploaded__c = System.today();
            document[0].Uploaded_By__c = UserInfo.getUserId();

            update document;
        }

        if(document[0].ContentDocumentLinks.size()==1 ) {
            List<ContentDocument> toUpdate = [SELECT Id,Title from ContentDocument Where Id = :document[0].ContentDocumentLinks[0].ContentDocumentId];
            if(document[0].ProjectId__r.Name !=null) {
                toUpdate[0].Title = document[0].ProjectId__r.Name + ' - ' + document[0].Document_Name__c;
            }
            if(document[0].PaymentRequest__r.Name !=null) {
                toUpdate[0].Title = document[0].PaymentRequest__r.Project__r.Name + ' - ' + document[0].PaymentRequest__r.Name + ' - ' + document[0].Document_Name__c;
            }
            update toUpdate;
        }
        Set<Id> contentDocIdSet = new  Set<Id>();
        if(document[0].ContentDocumentLinks.size() > 0) {
            for(ContentDocumentLink link : document[0].ContentDocumentLinks){
                contentDocIdSet.add(link.ContentDocumentId);
            }
        }

        if(contentDocIdSet.size () > 1) {
            String contentDocumentId;
            if(document[0].ContentDocumentLinks.size () > 1){
                contentDocumentId = document[0].ContentDocumentLinks[1].ContentDocumentId;
            }else{
                contentDocumentId = document[0].ContentDocumentLinks[0].ContentDocumentId;
            }

            List<ContentVersion> recentVersion = [Select Id,PathOnClient,Title,VersionData From ContentVersion Where ContentDocumentId = : contentDocumentId LIMIT 1];
            System.debug('This is Versions : '+recentVersion[0]);
            ContentVersion cv = new ContentVersion();
            cv.ContentDocumentId = document[0].ContentDocumentLinks[0].ContentDocumentId;
            cv.PathOnClient = recentVersion[0].PathOnClient;
            cv.VersionData = recentVersion[0].VersionData;
            //cv.Title = document.ContentDocumentLinks[0].ContentDocument.Title;
            cv.Title = recentVersion[0].Title;
            System.debug(cv);
            insert cv;
            //@neha --- Revisit to delete
            List<String> contentLinkIdsToDelete = new  List<String>();
            for(integer i=1;i<document[0].ContentDocumentLinks.size();i++){
                contentLinkIdsToDelete.add(document[0].ContentDocumentLinks[i].Id);
            }
            if(!contentLinkIdsToDelete.isEmpty()){
                List<ContentDocumentLink> toDelete = [SELECT Id FROM  ContentDocumentLink Where Id IN:contentLinkIdsToDelete];
            delete toDelete;
            }
        }

        Map<String, Object> resultMap = new Map<String, Object>();
        String test ='';
        resultMap =getDocumentsWithDocumentInfo(recordId,test);

        return resultMap;

    }
}