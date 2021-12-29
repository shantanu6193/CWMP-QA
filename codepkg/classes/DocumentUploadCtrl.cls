/**
 * Created by harsh on .
 */

public without sharing class DocumentUploadCtrl {

    @AuraEnabled
    public static Map<String, Object> getDocumentInfo(String masterRecordId, List<String> documentTypes, List<String> columnList, String lookupFieldAPIName) {
        try{

            Id userId = System.UserInfo.getUserId();
            User currUser = [SELECT Id, IsPortalEnabled, (SELECT PermissionSet.Name
            FROM PermissionSetAssignments) FROM User WHERE Id =: userId];
            if(masterRecordId==null) { new AuraHandledException('Record Id can not be null');}
            //Map<String, Object> recordIdDetails = validateAndRetrieveDocumentMetaCongiguration(masterRecordId);

            Map<String, Object> resultMap = new Map<String, Object>();
            Map<String, Document__c> documentNameToDocumentMap = new Map<String, Document__c>();
            List<DocumentMetaInfoWrapper> docWrapperList = new List<DocumentMetaInfoWrapper>();
            List<Document__c> docsList = new List<Document__c>();
            Set<String> documentFields = new Set<String>();
            System.debug('Inside  if -- '+columnList);
            if(columnList != null && columnList.size() > 0){
                /** Component was showing Error on line "documentNameToProgramDocumentMap.get(doc.Document_Name__c)"
                 * if Document upload support custom metadata does not contain Document_Name__c field **/
                if(!columnList.contains('Document_Name__c')){
                    columnList.add('Document_Name__c');
                }
                if(!columnList.contains('Date_Uploaded__c')){
                    columnList.add('Date_Uploaded__c');
                }
                documentFields.addAll(columnList);
            }else{
                Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
                documentFields.addAll(documentFieldMap.keySet());//Get all of the fields from Document__c object
                System.debug('Inside  else - - '+documentFieldMap.keySet());
            }
            Set<String> documentFieldsLabel = new Set<String>();
            /** check if filed type is Picklist then upend field with toLabel(fieldsName) for Language support **/
            for(String docFields:documentFields){
                String objectName = 'Document__c';
                SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                DescribeSObjectResult d = r.getDescribe();
                if(d.fields.getMap().get(docFields).getDescribe().getType().name() == 'PICKLIST'){
                    if(docFields == 'Document_Format__c'){
                        documentFieldsLabel.add(docFields);
                    }else{
                    String replacedValue = docFields.replace(docFields, 'toLabel('+docFields+')');
                    documentFieldsLabel.add(replacedValue);
                    }
                }else{
                    documentFieldsLabel.add(docFields);
                }
            }
            if(!documentFields.contains('Document_Format__c')){
                System.debug('Document_Format__c not contained');
            }else{
                System.debug('Document_Format__c contained');
            }
            String queryDocs = 'Select ' + String.join((Iterable<String>) documentFieldsLabel, ',') + ' ,' + //' Document_Format__c, ' +
                    ' (Select ContentDocumentID From ContentDocumentLinks) from Document__c Where '+ lookupFieldAPIName + ' =:masterRecordId ';
            if(!documentTypes.isEmpty()){
                queryDocs+=  'AND Document_Name__c IN: documentTypes ';
            }
            Id recordId = masterRecordId;
            String objName = recordId.getSObjectType().getDescribe().getName();
            if(objName == HH_CONSTANTS.HHApplication_Object_APIName){
                List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName AND Assignee.Id =:UserInfo.getUserId()];
                if(permissionSetAssignments.size() >0){
                    queryDocs += ' AND Document_Type__c IN(\''+HH_CONSTANTS.Document_DocumentType_Rental+'\',\''+HH_CONSTANTS.Document_DocumentType_PropertyOwnerID+'\',\''+HH_CONSTANTS.Document_DocumentType_ProofOfOwnership+'\')';
                }
                queryDocs+= 'ORDER BY Document_Name__c';
            }

            System.debug('Doc-queryDocs--------: '+queryDocs);
            docsList = Database.query(queryDocs);
            System.debug('Doc-docsList--------: '+docsList);
            Map<String,String> contentDocIdTODocumentNameMap = new Map<String, String>();
            for (Document__c doc : docsList) {
                documentNameToDocumentMap.put(doc.Id, doc);
                if(doc.ContentDocumentLinks!=null &&  doc.ContentDocumentLinks.size() > 0) {
                    System.debug('Doc-ContentDocumentLinks--------: '+doc.ContentDocumentLinks);
                    contentDocIdTODocumentNameMap.put(doc.ContentDocumentLinks[0].ContentDocumentId, doc.Id);
                }
            }

            Map<String,ContentVersion> documentNameToVersionCountMap = getDocumentVersionCount(contentDocIdTODocumentNameMap);
            Map<String, Program_Document__c> documentNameToProgramDocumentMap = getProgramDocumentRecords(documentNameToDocumentMap.keySet());
            for (Document__c doc : documentNameToDocumentMap.values()) {
                DocumentMetaInfoWrapper docWrapper = new DocumentMetaInfoWrapper();
                docWrapper.documentRecord = doc;
                if (doc.ContentDocumentLinks != null && doc.ContentDocumentLinks.size() > 0) {
                    docWrapper.contentDocumentLink = doc.ContentDocumentLinks[0];
                }
                docWrapper.programDocumentRecord = documentNameToProgramDocumentMap.get(doc.Document_Name__c) != null ? documentNameToProgramDocumentMap.get(doc.Document_Name__c) : new Program_Document__c();
                docWrapper.ContentVersionRecord = documentNameToVersionCountMap.get(doc.Id);
                docWrapper.currentUser = currUser;
                docWrapperList.add(docWrapper);
            }
            /** If Current object is HH Application then to handle control actions as per current user  **/
            //HH_DocumentActionCtrl docCtrl = new HH_DocumentActionCtrl(masterRecordId, docWrapperList);
            List<Document_Controller_Config__mdt> docControllerConfig = Document_Controller_Config__mdt.getall().values();//Get Records from Global Document Configuration Metadata
            String className ;
            for(Document_Controller_Config__mdt mdt:docControllerConfig){
                if(mdt.Object_API_Name__c ==objName){
                    className = mdt.Apex_Class_Name__c;
                }
            }
            System.debug('classNameclassName-- '+className);
            if(className != null){
                Type type = Type.forName(className);
                System.debug('typetypetype-- '+type);
                DocumentUploadInterface docInterface = (DocumentUploadInterface) type.newInstance();
                System.debug('docInterface-- '+docInterface);
                resultMap.put('docWrapperList', docInterface.executeAction(masterRecordId, docWrapperList));
            return resultMap;
            }else {
                resultMap.put('docWrapperList',docWrapperList);
                return resultMap;
            }
//            resultMap.put('docWrapperList',docWrapperList);
//            return resultMap;
        }catch(Exception e){
            System.debug('Error: '+ e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> validateAndRetrieveDocumentMetaConfiguration(String recordId){
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isValid', true);
        Id masterRecordIdVersion = recordId;
        String masterObjName = masterRecordIdVersion.getSObjectType().getDescribe().getName();
        System.debug('Doc-masterObjName--------: '+masterObjName);
        Document_Upload_Support__mdt docSupport =[SELECT Lookup_Field_Name__c,Object_API_Name__c, Table_Columns__c FROM Document_Upload_Support__mdt WHERE Object_API_Name__c = : masterObjName];
        System.debug('Doc-docSupport--------: '+docSupport);
        //String lookupFieldName;
        if(!String.isEmpty(docSupport.Lookup_Field_Name__c)) {
            //lookupFieldName  = docSupport.Lookup_Field_Name__c;
            returnMap.put('lookupFieldName', docSupport.Lookup_Field_Name__c);
        }else{
            returnMap.put('isValid', false);
        }
        if(!String.isEmpty(docSupport.Table_Columns__c)) {
            returnMap.put('tableColumns', docSupport.Table_Columns__c);
        }
        return returnMap;
    }

    private static Map<String,ContentVersion> getDocumentVersionCount(Map<String,String> contentDocIdTODocumentNameMap){
        //List<AggregateResult> contentVersionsCount = [SELECT COUNT(Id),ContentDocumentId From ContentVersion Where ContentDocumentId IN : contentDocIdTODocumentNameMap.keySet() GROUP BY ContentDocumentId];
        /** Updated Query to fetch File Name and version number for File Name and Version column**/
        List<ContentVersion> contentVersions =[select Id,ContentDocumentId,VersionNumber,IsLatest,PathOnClient from ContentVersion Where ContentDocumentId IN : contentDocIdTODocumentNameMap.keySet() AND IsLatest = true];
        Map<String,ContentVersion> documentNameToVersionCountMap = new Map<String, ContentVersion>();
        for(ContentVersion arr:contentVersions){
            documentNameToVersionCountMap.put(contentDocIdTODocumentNameMap.get((String)arr.get('ContentDocumentId')),arr);
        }
        return documentNameToVersionCountMap;
    }

    private static Map<String, Program_Document__c> getProgramDocumentRecords(Set<String> documentNameList){
        List<Program_Document__c> programDocumentsList = new List<Program_Document__c>();
        Map<String, Program_Document__c> documentNameToProgramDocumentMap = new Map<String, Program_Document__c>();

        Map<String, Schema.SObjectField> programDocumentFieldMap = Program_Document__c.sObjectType.getDescribe().fields.getMap();
        Set<String> programDocumentFields = programDocumentFieldMap.keySet();//Get all of the fields from Document__c object
        String queryProgramDocs = 'select ' + String.join((Iterable<String>) programDocumentFields, ',') + ' from Program_Document__c Where Document_Name__c IN: documentNameList';
        System.debug('queryProgramDocs+++++'+queryProgramDocs);
        programDocumentsList = Database.query(queryProgramDocs);

        for (Program_Document__c pDoc : programDocumentsList) {
            System.debug('****pDoc****' + pDoc);
            documentNameToProgramDocumentMap.put(pDoc.Document_Name__c, pDoc);
            System.debug('****documentNameToProgramDocumentMap****' + documentNameToProgramDocumentMap);
        }
        return documentNameToProgramDocumentMap;
    }

    @AuraEnabled
    public static void deleteContentDocument(String contentDocId, String recordId, String documentId) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        try {
            Id masterRecordIdVersion = recordId;
            String masterObjName = masterRecordIdVersion.getSObjectType().getDescribe().getName();
                List<Document_Controller_Config__mdt> docControllerConfig = Document_Controller_Config__mdt.getall().values();//Get Records from Global Document Configuration Metadata
                String className = null ;
            /** If Current object is HH Application then Call Apex class HH Document Action Controller **/
            for(Document_Controller_Config__mdt mdt:docControllerConfig){
                    if(mdt.Object_API_Name__c ==masterObjName){
                        className = mdt.Apex_Class_Name__c;
                }
            }
            if(className == 'HH_DocumentActionCtrl'){
                    Type type = Type.forName(className);
                    DocumentUploadInterface docInterface = (DocumentUploadInterface) type.newInstance();
                    /** Call Apex class HH Document Action Controller **/
                docInterface.executeDeleteAction(documentId, contentDocId);
                }else{
                if(String.isNotEmpty(contentDocId) && String.isNotEmpty(documentId)) {
                cvList = [SELECT  Id, PathOnClient, Title, VersionNumber From ContentVersion Where ContentDocumentId =: contentDocId order by VersionNumber DESC];
                System.debug('cvList : -----'+ cvList);
                //delete cvList[0];
                delete[SELECT  Id FROM ContentDocument WHERE Id = : contentDocId];
                // delete ContentDocumentLinkList;
                //return true;
            }
                }
        } catch (Exception e) {
            System.debug('error :'+ e);
            throw new AuraHandledException(e.getMessage());
        }
        //return false;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDocumentsWithDocumentInfo(String masterRecordId ,String refreshDate) {
        Map<String, Object> resultMap = new Map<String, Object>();
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
        Map<String, Document__c> documentNameToDocumentMap = new Map<String, Document__c>();

        Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
        //Get all of the fields on the object - Document__c
        Set<String> documentFields = documentFieldMap.keySet();
        // Build a Dynamic Query String to fetch 'Documents'.

        //String queryDocs = 'select ' + String.join((Iterable<String>) documentFields, ',') + ' ,( SELECT ContentDocumentID FROM ContentDocumentLinks)  from Document__c Where ProjectId__c= \'' + masterRecordId + '\'';
        String queryDocs = 'select ' + String.join((Iterable<String>) documentFields, ',') + ' ,( SELECT ContentDocumentID FROM ContentDocumentLinks)  from Document__c Where  ' +lookupFieldName+ ' = \'' + masterRecordId + '\'';
        System.debug('queryDocs++++++ '+queryDocs);
        docsList = Database.query(queryDocs);

        Map<String,String> ContentDocIdTODocumentNameMap = new Map<String, String>();
        for (Document__c doc : docsList) {
            documentNameToDocumentMap.put(doc.Document_Name__c, doc);
            if(doc.ContentDocumentLinks!=null &&  doc.ContentDocumentLinks.size() > 0) {
                ContentDocIdTODocumentNameMap.put(doc.ContentDocumentLinks[0].ContentDocumentId, doc.Document_Name__c);
            }
        }

        List<Program_Document__c> programDocumentsList = new List<Program_Document__c>();
        Map<String, Program_Document__c> documentNameToProgramDocumentMap = new Map<String, Program_Document__c>();

        Map<String, Schema.SObjectField> programDocumentFieldMap = Program_Document__c.sObjectType.getDescribe().fields.getMap();
        // Get all of the fields on the object - Program_Document__c
        Set<String> programDocumentFields = programDocumentFieldMap.keySet();


        List<String> strList = new List<String>();
        strList.add('\'' + '' + '\'');
        for (String str : documentNameToDocumentMap.keySet()) {
            strList.add('\'' + str + '\'');
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

        //List<AggregateResult> contentVersionsCount = [SELECT COUNT(Id),ContentDocumentId From ContentVersion Where ContentDocumentId IN : ContentDocIdTODocumentNameMap.keySet() GROUP BY ContentDocumentId];
        /** Updated Query to fetch File Name and version number for File Name and Version column**/
        List<ContentVersion> contentVersions =[select Id,ContentDocumentId,VersionNumber,IsLatest,PathOnClient from ContentVersion Where ContentDocumentId IN : contentDocIdTODocumentNameMap.keySet() AND IsLatest = true];

        Map<String,ContentVersion> documentNameToVersionCountMap = new Map<String, ContentVersion>();
        for(ContentVersion arr:contentVersions){
            documentNameToVersionCountMap.put(ContentDocIdTODocumentNameMap.get((String)arr.get('ContentDocumentId')),arr);
        }

        //Create the Wrapper List Items for Each Document
        for (Document__c doc : documentNameToDocumentMap.values()) {
            DocumentMetaInfoWrapper docWrapper = new DocumentMetaInfoWrapper();
            docWrapper.documentRecord = doc;
            if (doc.ContentDocumentLinks != null && doc.ContentDocumentLinks.size() > 0) {
                docWrapper.contentDocumentLink = doc.ContentDocumentLinks[0];
            }
            docWrapper.programDocumentRecord = documentNameToProgramDocumentMap.get(doc.Document_Name__c);
            docWrapper.ContentVersionRecord = documentNameToVersionCountMap.get(doc.Document_Name__c);
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
        public ContentVersion ContentVersionRecord { get; set; }

        @AuraEnabled
        public User currentUser { get; set; }

        @AuraEnabled
        public Account accountRecord { get; set; }

        @AuraEnabled
        public Incident_Subrecipient_Stage__c summaryRecord { get; set; }

        /** added hideEdit,hideDelete,hideUpload to hide show actions for HH Portal users as per permission set**/
        @AuraEnabled
        public Boolean hideEdit {get; set; }

        @AuraEnabled
        public Boolean hideNew {get; set; }

        @AuraEnabled
        public Boolean hideDelete {get; set; }

        @AuraEnabled
        public Boolean hideUpload {get; set; }

//        public DocumentMetaInfoWrapper() {
//            this.hideEdit = false;
//            this.hideDelete = false;
//            this.hideUpload = false;
//        }

    }

    @AuraEnabled
    public static Map<String, Object> saveFileDetails(String documentRecordId, String uploadedFileName ,String recordId) {
        Document__c document = [SELECT Id,Stage__c , Document_Type__c, Document_Name__c,Uploaded_By__c,Date_Uploaded__c,Date_Time_Uploaded__c,
        (SELECT ContentDocumentId ,ContentDocument.CreatedDate , ContentDocument.Id , ContentDocument.Title
        FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC )
        from Document__c Where Id = :documentRecordId];
        //Document__c document = [SELECT Id,Stage__c ,Document_Name__c,Uploaded_By__c,Date_Uploaded__c,ProjectId__r.Name,PaymentRequest__r.Name,PaymentRequest__r.Project__r.Name,(SELECT ContentDocumentId ,ContentDocument.CreatedDate , ContentDocument.Id , ContentDocument.Title FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC  )  from Document__c Where Id = :documentRecordId];
        if (document.Stage__c != ALS_CONSTANTS.Document_Stage_Uploaded) {
            document.Stage__c = ALS_CONSTANTS.Document_Stage_Uploaded;
        }
//        Id masterRecordIdVersion = recordId;
//        String masterObjName = masterRecordIdVersion.getSObjectType().getDescribe().getName();
//        /** If current object is HH Application then update file Name with Document type - File name **/
//        if(masterObjName == HH_CONSTANTS.HHApplication_Object_APIName) {
//            String documentName = document.Document_Type__c+' - '+uploadedFileName;
//            System.debug('documentName---- '+documentName);
//            document.Document_Name__c = documentName;
//        }
            document.Date_Uploaded__c = System.today();
            document.Date_Time_Uploaded__c = System.now();
            document.Uploaded_By__c = UserInfo.getUserId();
            document.Global_Document__c =false;
            update document;

        /*if(document.ContentDocumentLinks.size()==1) {
            ContentDocument toUpdate = [SELECT Id,Title from ContentDocument Where Id = :document.ContentDocumentLinks[0].ContentDocumentId];
            if(document.ProjectId__r.Name !=null) {
                toUpdate.Title = document.ProjectId__r.Name + ' - ' + document.Document_Name__c;
            }
            if(document.PaymentRequest__r.Name !=null) {
                toUpdate.Title = document.PaymentRequest__r.Project__r.Name + ' - ' + document.PaymentRequest__r.Name + ' - ' + document.Document_Name__c;
            }
            update toUpdate;
        }*/


        if(document.ContentDocumentLinks.size()==2) {
            ContentVersion recentVersion = [Select Id,PathOnClient,Title,VersionData From ContentVersion Where ContentDocumentId = :document.ContentDocumentLinks[1].ContentDocumentId LIMIT 1];
            System.debug('This is Versions : '+recentVersion);
            ContentVersion cv = new ContentVersion();
            cv.ContentDocumentId = document.ContentDocumentLinks[0].ContentDocumentId;
            cv.PathOnClient = recentVersion.PathOnClient;
            cv.VersionData = recentVersion.VersionData;
            cv.Title = document.ContentDocumentLinks[0].ContentDocument.Title;
            System.debug(cv);
            insert cv;
            //@neha --- Revisit to delete
            //ContentDocument toDelete = [SELECT Id from ContentDocument Where Id = :document.ContentDocumentLinks[1].ContentDocumentId];
            ContentDocumentLink toDelete = [SELECT Id FROM  ContentDocumentLink Where Id=: document.ContentDocumentLinks[1].Id];
            delete toDelete;
            document.Global_Document__c =false;
            update document;
        }

        Map<String, Object> resultMap = new Map<String, Object>();
        String test ='';
        resultMap =getDocumentsWithDocumentInfo(recordId,test);

        return resultMap;
    }

    /***********************************************
  * Method Name : getSourceGlobalDocumentListInfo
  * Author : Sushant.
  * Inputs : - String recordId ,String documentRecordName, String documentRecordId;
  * Description: This Method used to fetch Source document information related to Destination Document using custom metadata
  *********************************************/
    @AuraEnabled
    public static Map<String, Object> getSourceGlobalDocumentListInfo(String destinationRecordId ,String documentRecordName, String documentRecordId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        String destinationObjectDocumentName = documentRecordName;//Current Document Name on which we have to Copy document.
        Id destinationObjectId = destinationRecordId;//Current Record Id.
        Set<String> documentFields = new Set<String>();//List of Document Fields.
        Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
        documentFields.addAll(documentFieldMap.keySet());//Get all of the fields from Document__c object.
        String destinationObjName = destinationObjectId.getSObjectType().getDescribe().getName();//Get Name of Primary object.
        List<Global_Document_Configuration__mdt> allGlobalDocumentConfigurationRecords = Global_Document_Configuration__mdt.getall().values();//Get Records from Global Document Configuration Metadata
        List<Global_Document_Source_Configuration__mdt> allGlobalDocumentSourceConfigurationRecords = Global_Document_Source_Configuration__mdt.getall().values();//Get Records from Global Document Source Configuration Metadata
        Set<Id> DestnationRecordMetaDataId = new Set<Id>();//Metadata Id Set
        List<Global_Document_Source_Configuration__mdt> globalDocSourceMtdList = new List<Global_Document_Source_Configuration__mdt>();//List of Source Documents
        String DestinationToDocumentRelationship;//Relation Name on Document to Destination Object.
        List<String> sourceObjectRelationList  = new List<String>();// List of Destination to Source relationship Name
        List<String> sourceObjectDocumentName = new List<String>();//List of Document Name on Source objects.
        List<String> sourceObjectLookupNameOnDocument = new List<String>();//List of Source object Lookup Name on Document Object.
        List<String> universalDocuments = new List<String>();//List of Name of Documents which are Universal.
        List<String> otherFieldsFromDestinationObject =new List<String>();

        for (Global_Document_Configuration__mdt customMetaData : allGlobalDocumentConfigurationRecords) {//Filter Metadata to get Records related to DestinationObjectDocumentName and destinationObjName.
            if (customMetaData.Document_Name_On_Destination_Object__c == destinationObjectDocumentName && customMetaData.Destination_Object__c == destinationObjName) {
                DestnationRecordMetaDataId.add(customMetaData.Id);
                DestinationToDocumentRelationship = customMetaData.Document_Destination_Relationshi_Name__c;
                String splitString = customMetaData.Fields_To_Get_From_Destination_Objects__c;
                If(splitString != null) {
                    List<String> splitList = splitString.split(',');
                    String otherfieldsToretrievefromDestination = '' ;
                    for (integer i = 0; i < splitList.size(); i++) {
                        if (i == 0) {
                            otherfieldsToretrievefromDestination += DestinationToDocumentRelationship + '.' + splitList[i].deleteWhitespace();
                        } else {
                            otherfieldsToretrievefromDestination += +', ' + DestinationToDocumentRelationship + '.' + splitList[i].deleteWhitespace();
                        }
                    }
                    otherFieldsFromDestinationObject.add(otherfieldsToretrievefromDestination);
                }
            }
        }

        //String destinationToSourceRelationConcatString = ' ';
        for(Global_Document_Source_Configuration__mdt customMetaData: allGlobalDocumentSourceConfigurationRecords){
            if (DestnationRecordMetaDataId.contains(customMetaData.Global_Document_Configuration__c)) {//Fetch Records Related to current Global_Document_Configuration__mdt
                globalDocSourceMtdList.add(customMetaData);
                sourceObjectRelationList.add(customMetaData.Destination_To_Source_Relationship__c);
                sourceObjectDocumentName.add(customMetaData.Document_Name_On_Source_Object__c);
                sourceObjectLookupNameOnDocument.add(customMetaData.Document_Source_Relationship_Name__c);
                if (customMetaData.Is_Universal__c == true) {//If universal document then add to universalDocuments to upend Document Name.
                    universalDocuments.add(customMetaData.Document_Name_On_Source_Object__c);
                }
                otherFieldsFromDestinationObject.add(DestinationToDocumentRelationship + '.' + customMetaData.Destination_To_Source_Relationship__c + '.Id');
                String splitString = customMetaData.Fields_To_Get_From_Source_Objects__c;
                If(splitString != null){
                List<String> splitList = splitString.split(',');
                String otherfieldsToretrievefromSource = '' ;
                for (integer i = 0; i < splitList.size(); i++) {
                    if (i == 0) {
                        otherfieldsToretrievefromSource += DestinationToDocumentRelationship + '.' + customMetaData.Destination_To_Source_Relationship__c + '.' + splitList[i].deleteWhitespace();
                    } else {
                        otherfieldsToretrievefromSource += +', ' + DestinationToDocumentRelationship + '.' + customMetaData.Destination_To_Source_Relationship__c + '.' + splitList[i].deleteWhitespace();
                    }
                }
                    otherFieldsFromDestinationObject.add(otherfieldsToretrievefromSource);
            }

            }
        }

        String otherFieldstoRetrieveFromDestination =' ';
        for(Integer i=0;i<otherFieldsFromDestinationObject.size();i++){
            if(i==0){
                otherFieldstoRetrieveFromDestination += otherFieldsFromDestinationObject[i];
            }else{
                otherFieldstoRetrieveFromDestination += +','+otherFieldsFromDestinationObject[i];
            }
        }
        String securityEnforcedString = ' WITH SECURITY_ENFORCED';
        String finalDestinationDocumentQuery = 'SELECT Id ,'+otherFieldstoRetrieveFromDestination+',(SELECT ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.Id, ContentDocument.Title FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC ) from Document__c Where Id = '+'\''+documentRecordId+'\'' ;
        System.debug('temp = = '+otherFieldsFromDestinationObject);
        System.debug('finalDestinationDocumentQuery = -- '+finalDestinationDocumentQuery);

        Document__c destinationDocument;
        try{
            SObject destinationDocumentRecord = Database.query(finalDestinationDocumentQuery);
            destinationDocument = (Document__c) destinationDocumentRecord;//Record Detail of Destination Document.
        }catch (Exception e){
            throw new AuraHandledException('Document does not exist !! ');
        }
        List<Id> SourceObjectIdsList = new List<Id>();//Source Documents Ids
        for(String str:sourceObjectRelationList){
            Id sourceObjectId = (Id) destinationDocument.getSobject(DestinationToDocumentRelationship).getSobject(str).get('Id');//To get Ids of Source Document.
            SourceObjectIdsList.add(sourceObjectId);
        }
        //Creating String for Dynamic query
        String DocumentNameConcat ='( Document_Name__c ';
        for(Integer i=0;i<sourceObjectDocumentName.size();i++){
            if(i==0){
                DocumentNameConcat += +' = \''+sourceObjectDocumentName[i]+'\'';
            }else{
                DocumentNameConcat += +' OR Document_Name__c = \''+sourceObjectDocumentName[i]+'\'';
            }
        }
        String LookupNameConcat ='(';
        for(Integer i=0;i<sourceObjectLookupNameOnDocument.size();i++){
            for(Integer j=0;j<SourceObjectIdsList.size();j++){
                if(i==0){
                    if(j==0){
                        LookupNameConcat += sourceObjectLookupNameOnDocument[i]+' =\''+SourceObjectIdsList[j]+'\'';
                    }else{
                        LookupNameConcat += +' OR '+ sourceObjectLookupNameOnDocument[i]+' =\''+SourceObjectIdsList[j]+'\'';
                    }
                }else{
                    LookupNameConcat += +' OR '+ sourceObjectLookupNameOnDocument[i]+' =\''+SourceObjectIdsList[j]+'\'';
                }
            }
        }

        //Query to fetch Source object Documents.
        String sourceObjectDocumentQuery = 'SELECT ' + String.join((Iterable<String>) documentFields,' , ')+' ,(SELECT ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.Id, ContentDocument.Title ' +
                'FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC) From Document__c WHERE '+DocumentNameConcat+') AND '+LookupNameConcat+')';
       System.debug('sourceObjectDocumentQuery = '+sourceObjectDocumentQuery);
        List<Document__c> SourceObjectDocumentList;//List of Documents of Source objects
        try {
            List<SObject> sourceDocumentQueryResult = Database.query(sourceObjectDocumentQuery);
            SourceObjectDocumentList = (List<Document__c>) sourceDocumentQueryResult;
        }catch (Exception e){
            throw new AuraHandledException('Document does not exist !');
        }
        List<Document__c> documentsListToDisplay = new  List<Document__c>();
        List<GlobalDocumentInfoWrapper> globalDocWrapperList = new List<GlobalDocumentInfoWrapper>();//Wrap All document related info in one wrapper
        for(Document__c doc:SourceObjectDocumentList){
            if(doc.ContentDocumentLinks.size() >0){
                documentsListToDisplay.add(doc);
                GlobalDocumentInfoWrapper globalDocWrapper = new GlobalDocumentInfoWrapper();
                globalDocWrapper.documentRecord = doc;
                globalDocWrapper.docLabel = customDocumentNameLabel(doc, destinationDocument , (List<String>) universalDocuments );
                globalDocWrapperList.add(globalDocWrapper);
            }
        }
        if(globalDocWrapperList.size() > 0){
            resultMap.put('sourceDocumentList',globalDocWrapperList);
        }else{
            throw new AuraHandledException('Document does not exist !!!');
        }
        return resultMap;
    }
    /***********************************************
* Method Name : customDocumentNameLabel
* Author : Sushant.
* Inputs : -Document__c doc,Document__c destinationDocument ,List<string> universalDocuments
* Description: This Method used to create custom document name.
*********************************************/

    @AuraEnabled
    public static String customDocumentNameLabel(Document__c doc,Document__c destinationDocument ,List<string> universalDocuments ){

                if(doc.Account__c != null){
                    String fipsLabelStringAccount = destinationDocument.ProjectId__r.FIPS_ID__c == null?'':destinationDocument.ProjectId__r.FIPS_ID__c+': ';
                    if (universalDocuments.contains(doc.Document_Name__c)) {
                       return  fipsLabelStringAccount + doc.Document_Name__c + ': ' + 'UNIV';//If Source object is "Is Universal" then Add "UNIV" in last of Name
                    } else {
                        return fipsLabelStringAccount + doc.Document_Name__c;
                    }
                }else if(doc.Incident_Subrecipient_Summary__c != null){
                    String fipsLabelStringStage = destinationDocument.ProjectId__r.FIPS_ID__c == null?'':destinationDocument.ProjectId__r.FIPS_ID__c+': ';
                    String drNumberLabelString = destinationDocument.ProjectId__r.Declaration_Number__c == null?'':': DR '+destinationDocument.ProjectId__r.Declaration_Number__c;
                    return  fipsLabelStringStage +doc.Document_Name__c+drNumberLabelString;//Add DR number and FIPS to Document Name
                }else if(doc.Incident__c != null){
                    String fipsLabelStringStage = destinationDocument.ProjectId__r.FIPS_ID__c == null?'':destinationDocument.ProjectId__r.FIPS_ID__c+': ';
                    String drNumberLabelString = destinationDocument.ProjectId__r.Declaration_Number__c == null?'':': DR '+destinationDocument.ProjectId__r.Declaration_Number__c;
                    return  fipsLabelStringStage +doc.Document_Name__c+drNumberLabelString;//Add DR number and FIPS to Document Name
                }else{
                    return doc.Document_Name__c;//If object name is none of above one then directly add Document name.
                }
            }

    /***********************************************
* Method Name : GlobalDocumentInfoWrapper
* Author : Sushant.
* Inputs : -
* Description: This Method used to Wrap document Record and Document Label to Document Wrapper.
*********************************************/
    public class GlobalDocumentInfoWrapper {
        @AuraEnabled
        public Document__c documentRecord { get; set; }

        @AuraEnabled
        public String docLabel { get; set; }
    }

    /***********************************************
* Method Name : validateAndRetrieveCloneDocumentMetaConfiguration
* Author : Sushant.
* Inputs : - String recordId
* Description: This method is used to fetch Columns to display on table from REAL_Document_Attach_Support__mdt Metadata.
*********************************************/
    @AuraEnabled
    public static Map<String, Object> validateAndRetrieveCloneDocumentMetaConfiguration(String destinationRecordId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Id destinationObjectId = destinationRecordId;
        String destinationObjectApiName = destinationObjectId.getSObjectType().getDescribe().getName();
        //Query to get which columns to Display on Table
        REAL_Document_Attach_Support__mdt cloneDocumentTableColumnSupport =[SELECT Table_Columns__c,Object_API_Name__c FROM REAL_Document_Attach_Support__mdt WHERE Object_API_Name__c = : destinationObjectApiName];
        if(!String.isEmpty(cloneDocumentTableColumnSupport.Table_Columns__c)) {
            returnMap.put('cloneGlobalDocumentTableColumns', cloneDocumentTableColumnSupport.Table_Columns__c);
        }else{
            throw new AuraHandledException('Table column data not available.');
        }
        return returnMap;
    }

    /***********************************************
* Method Name : UpdateDocumentAttributes
* Author : Sushant.
* Inputs : - String sourceDocument, String destinationDocument
* Description: This Method used to update document fields on Destination object from selected source document object fields.
*********************************************/
    public static void UpdateDocumentAttributes(Document__c sourceDocument, Document__c destinationDocument) {
        Document__c sourceDocumentDetails = sourceDocument;
        Document__c destinationDocumentDetails = destinationDocument;
        System.debug('sourceDocumentDetails = '+sourceDocumentDetails);
        System.debug('destinationDocumentDetails = '+destinationDocumentDetails);
        if(sourceDocumentDetails != null){
            destinationDocumentDetails.ExpirationDate__c =  sourceDocumentDetails.ExpirationDate__c == null?null:sourceDocumentDetails.ExpirationDate__c;
            destinationDocumentDetails.Date_Of_Signature__c =  sourceDocumentDetails.Date_Of_Signature__c == null?null:sourceDocumentDetails.Date_Of_Signature__c;
            destinationDocumentDetails.Date_Of_Fiscal_Year_End__c = sourceDocumentDetails.Date_Of_Fiscal_Year_End__c == null?null:sourceDocumentDetails.Date_Of_Fiscal_Year_End__c;
            destinationDocumentDetails.Approval_Date__c =sourceDocumentDetails.Approval_Date__c == null?null:sourceDocumentDetails.Approval_Date__c;
            destinationDocumentDetails.Letter_Date__c = sourceDocumentDetails.Letter_Date__c == null?null:sourceDocumentDetails.Letter_Date__c;
            if(destinationDocumentDetails.Stage__c != 'Uploaded'){
                destinationDocumentDetails.Stage__c = 'Uploaded';
            }
            destinationDocumentDetails.Date_Uploaded__c = System.today();
            destinationDocumentDetails.Date_Time_Uploaded__c = System.now();
            destinationDocumentDetails.Uploaded_By__c = UserInfo.getUserId();
            destinationDocumentDetails.Global_Document__c = true;
            update destinationDocumentDetails;
        }
    }
    /***********************************************
 * Method Name : cloneGlobalDocument
 * Author : Sushant.
 * Inputs : - String sourceDocumentId, String destinationDocumentId, String recordId;
 * Description: This Method used to upload document from selected source document.
 *********************************************/
    @AuraEnabled
    public static Map<String, Object> cloneGlobalDocument(String sourceDocumentId, String destinationDocumentId, String destinationRecordId) {
        System.debug('sourceDocumentId = '+sourceDocumentId);
        System.debug('destinationDocumentId = '+destinationDocumentId);
        System.debug('recordId = '+destinationRecordId);
        Set<String> documentFields = new Set<String>();//List of Document Fields.
        Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
        documentFields.addAll(documentFieldMap.keySet());//Get all of the fields from Document__c object
        String destinationDocQuery = 'SELECT ' + String.join((Iterable<String>) documentFields,' , ')+',(SELECT ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.Id, ContentDocument.Title FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC) From Document__c WHERE Id ='+'\''+destinationDocumentId+'\'';
        //Document Record detail of Destination Object.
        Document__c docOnDestinationObject;
        try{
             docOnDestinationObject = Database.query(destinationDocQuery);
        } catch (Exception e){
            throw new AuraHandledException('Document Not found..');
        }

        String sourceDocQuery = 'SELECT ' + String.join((Iterable<String>) documentFields,' , ')+',(SELECT ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.Id, ContentDocument.Title FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate ASC) From Document__c WHERE Id ='+'\''+sourceDocumentId+'\'';
        //Document Record detail of Source Object.
        Document__c docOnSourceObject;
        try{
             docOnSourceObject = Database.query(sourceDocQuery);
        } catch (Exception e){
            throw new AuraHandledException('Document Not found...');
        }
                    try {
                            ContentDocumentLink sourceConDocumentLink = (ContentDocumentLink) docOnSourceObject.ContentDocumentLinks;
                            ContentVersion recentVersion = [Select Id,PathOnClient,Title,VersionData From ContentVersion Where ContentDocumentId = :sourceConDocumentLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];

                        if (docOnDestinationObject?.ContentDocumentLinks?.size() > 0) {//If Is available on Destination Object
                                ContentVersion cv = new ContentVersion();
                                cv.ContentDocumentId = docOnDestinationObject.ContentDocumentLinks[0].ContentDocumentId;
                                cv.PathOnClient = recentVersion.PathOnClient;
                                cv.VersionData = recentVersion.VersionData;
                                cv.Title = docOnDestinationObject.ContentDocumentLinks[0].ContentDocument.Title;
                                insert cv;

                            } else {//If Is not available  Destination Object
                                ContentVersion cVersion = new ContentVersion();
                                cVersion.PathOnClient = recentVersion.PathOnClient;
                                cVersion.Title = recentVersion.Title;
                                cVersion.VersionData = recentVersion.VersionData;
                                Insert cVersion;
                                //After saved the Content Verison, get the ContentDocumentId
                                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id].ContentDocumentId;
                                //Insert ContentDocumentLink
                                ContentDocumentLink cDocLink = new ContentDocumentLink();
                                cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                                cDocLink.LinkedEntityId = docOnDestinationObject.Id;//Add attachment parentId
                                Insert cDocLink;
                            }
                        UpdateDocumentAttributes(docOnSourceObject,docOnDestinationObject);
                    } catch (Exception e) {
                        throw new AuraHandledException('Document File not available on Master record..');
                    }
        Map<String, Object> resultMap = new Map<String, Object>();
        String test ='';
        resultMap = getDocumentsWithDocumentInfo(destinationRecordId,test);

        return resultMap;
        }



    /*public static boolean checkProDocConfigAndCreateDocuments(List<SObject> objectRecords, String programDocFilterClause, String programDocParentObject) {
        List<Program_Document__c> programDocuments = new List<Program_Document__c>();
        List<Document__c> docList = new List<Document__c>();
        Set<Id> documentIds = new Set<Id>();
        if(objectRecords.size() > 0) {
            //Map<Elevation, list<ProhramDocument>>
            programDocuments = [SELECT Id, Document_Name__c, Document_Format__c, Project_Stage__c, Is_Required__c, Description__c, Filter_Clause__c
            FROM Program_Document__c WHERE Filter_Clause__c =: programDocFilterClause AND Parent_Object__c =: programDocParentObject];
        }

        System.debug('programDocuments--- : '+ programDocuments);
        if(programDocuments.size() > 0) {
            //Map for loop
            //Elevation -> List<ProjectSIte>
            //values- project site
            for(SObject objRec : objectRecords) {
                Id objRecId = objRec.Id;
                String objAPIName = objRecId.getSObjectType().getDescribe().getName();
                System.debug('objAPIName--- : '+ objAPIName);
                //Map<Elevation, list<ProhramDocument>>
                for(Program_Document__c programDoc : programDocuments) {
                    Document__c doc = new Document__c();
                    doc.Document_Name__c = programDoc.Document_Name__c;
                    //doc.Document_Type__c = programDoc.Document_Name__c;
                    doc.Document_Format__c = programDoc.Document_Format__c;
                    if(objRec.get('Application__c') != null) {
                        doc.Application__c = (Id)objRec.get('Application__c');
                    }
                    if(objAPIName == 'Work_Schedule__c') {
                        doc.Work_Schedule__c = objRec.Id;
                    } else if(objAPIName == 'Application_Extension__c') {
                        doc.Application_Extension__c = objRec.Id;
                    } else if(objAPIName == 'Project_Site__c') {
                        doc.Project_Site__c = objRec.Id;
                    }
                    doc.Status__c = 'Active';
                    doc.Stage__c = programDoc.Project_Stage__c;
                    doc.Is_Required__c = programDoc.Is_Required__c;
                    doc.Description__c = programDoc.Description__c;
                    docList.add(doc);
                }
            }
            insert docList;
            System.debug('Created_Document_List--- : '+ docList);
            for(Document__c docu : docList) {
                documentIds.add(docu.Id);
            }
            if(documentIds.size() > 0) {
                DocumentUploadCtrl.shareDocumentRecordsToCommunityUser(documentIds);
            }
            return true;
        }
        return false;
    }*/

    /*public static void shareDocumentRecordsToCommunityUser( Set<Id> documentIds) {
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
    }*/
}