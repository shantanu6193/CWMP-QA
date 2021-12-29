public without sharing class HH_DocumentActionCtrl implements DocumentUploadInterface{
    /***********************************************
    * Method Name : handle
    * Author : Shantanu
    * Inputs :
    * Description: To check current object and and call other method as per object.
    ************************************************/
    public List<DocumentUploadCtrl.DocumentMetaInfoWrapper> executeAction(String masterRecordId, List<DocumentUploadCtrl.DocumentMetaInfoWrapper> docWrapperList) {
        Id recordId = masterRecordId;
        String masterObjectName = recordId.getSObjectType().getDescribe().getName();
        /** Check if current record object name is HH_Application__c if yes continue or return document details **/
        if(masterObjectName == HH_CONSTANTS.HHApplication_Object_APIName) {
            return handleHHApplicationActions(masterRecordId,docWrapperList);
        }
        return docWrapperList;
    }

    /***********************************************
    * Method Name : handleHHApplicationActions
    * Author : Sushant
    * Inputs :
    * Description: to check current user type and give access as per permission set.
    ************************************************/
    public List<DocumentUploadCtrl.DocumentMetaInfoWrapper> handleHHApplicationActions(String masterRecordId, List<DocumentUploadCtrl.DocumentMetaInfoWrapper> docWrapperList) {
        Boolean hideEdit = false;/** by default user can see edit icon on document upload component **/
        Boolean hideUpload = false ;/** by default user can see Upload icon on document upload component **/
        Boolean hideDelete = false ;/** by default user can see Delete icon on document upload component **/
        Boolean hideNew = false ;/** by default user can see New button on document upload component **/
        /** Get current record data to get details about stage and status **/
        List<HH_Application__c> app = [SELECT Stage__c,Status__c FROM HH_Application__c WHERE Id=:masterRecordId];
        if(app.size() == 0) {
            return docWrapperList;
        }
        /** To check current user is home owner on not **/
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName AND Assignee.Id =:UserInfo.getUserId()];
            /** If current user is homeOwner then hide all actions**/
        System.debug('permissionSetAssignments.size()--'+permissionSetAssignments.size());
            if(permissionSetAssignments.size() > 0){
                hideEdit = true;
                hideUpload = true;
                hideDelete = true;
                hideNew = true;
            /** If current user is not  homeOwner then show/hide all actions as per Stage and Status of Application**/
            }
//            else{
//                /** If current user has not access to Edit the record hide all Actions **/
//                if(HH_EditRequestCtrl.isApplicationEditable(masterRecordId) == false){
//                    hideEdit = true;
//                    hideUpload = true;
//                    hideDelete = true;
//                }
//            }

        /** Iterate all documents and give action access as per user **/
        for(DocumentUploadCtrl.DocumentMetaInfoWrapper pr:docWrapperList) {
            pr.hideEdit = hideEdit;
            Pr.hideNew = hideNew;
            pr.hideUpload = hideUpload;
            pr.hideDelete = hideDelete;
        }
        return docWrapperList;
    }

    /***********************************************
    * Method Name : executeDeleteAction
    * Author : Sushant.
    * Inputs :document Record Id,contentDocument Id
    * Description: Check Stage of Application action take decision to Delete document or not.
    ************************************************/
    public void executeDeleteAction(String docRecordId,String contentDocId) {
        if(docRecordId == null){
            throw new CustomException('Document Id is Null');
        }
        List<ContentVersion> cvList = new List<ContentVersion>();
        Document__c doc =[SELECT Id, Stage__c, Status__c, Document_Creation_Method__c, HH_Application__r.Stage__c, HH_Application__r.Status__c from Document__c where Id =:docRecordId];
        /** if Document is uploaded and Application stage is not Draft and status is not New then do not allow to delete document **/
        if(doc.Stage__c == HH_CONSTANTS.Document_Stage_Uploaded
            && doc.HH_Application__r.Stage__c != HH_CONSTANTS.HHApplication_Stage_Draft
            && doc.HH_Application__r.Status__c != HH_CONSTANTS.HHApplication_Status_New ){
            throw new CustomException(System.label.HH_Document_Edit_Delete);
        }else if (doc.HH_Application__r.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                && doc.HH_Application__r.Status__c == HH_CONSTANTS.HHApplication_Status_New ) {
                    /** if Document is system generated then only delete file **/
                    if (doc.Document_Creation_Method__c == HH_CONSTANTS.Document_CreationMethod_SystemGenerated) {
                        /** if Document is uploaded then delete file and update document **/
                        if(String.isNotEmpty(contentDocId) && String.isNotEmpty(docRecordId)) {
                            cvList = [SELECT  Id, PathOnClient, Title, VersionNumber From ContentVersion Where ContentDocumentId =: contentDocId order by VersionNumber DESC];
                            delete[SELECT  Id FROM ContentDocument WHERE Id = : contentDocId];
                            Document__c docToUpdate = new Document__c();
                            docToUpdate.Id = docRecordId;
                            docToUpdate.Stage__c = HH_CONSTANTS.Document_Stage_New;
                            docToUpdate.Date_Uploaded__c = null;
                            docToUpdate.Date_Time_Uploaded__c = null;
                            docToUpdate.Uploaded_By__c = null;
                            docToUpdate.Comments__c = null;
                            update docToUpdate;
                        /** if Document is system generated and file not Uploaded then show Error **/
                        }else if (String.isEmpty(contentDocId)) {
                            throw new CustomException(System.label.HH_Document_Edit_Delete);
            }
                    /** if Document is not system generated **/
                    }else if (doc.Document_Creation_Method__c != HH_CONSTANTS.Document_CreationMethod_SystemGenerated) {
                        /** if Document is not system generated and file is uploaded then delete file **/
            if(String.isNotEmpty(contentDocId) && String.isNotEmpty(docRecordId)) {
                cvList = [SELECT  Id, PathOnClient, Title, VersionNumber From ContentVersion Where ContentDocumentId =: contentDocId order by VersionNumber DESC];
                delete[SELECT  Id FROM ContentDocument WHERE Id = : contentDocId];
            }
                        /** if Document is not system generated and file not Uploaded then delete document**/
                        delete doc;
                    }
        /** if Document is not uploaded Application Stage is not draft and New then delete document **/
        }else if(doc.Stage__c != HH_CONSTANTS.Document_Stage_Uploaded
                && doc.HH_Application__r.Stage__c != HH_CONSTANTS.HHApplication_Stage_Draft
                && doc.HH_Application__r.Status__c != HH_CONSTANTS.HHApplication_Status_New ){
            delete doc;
        /** if Application Stage,Status is Appeal Approval Resubmit **/
        }else if(doc.HH_Application__r.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                && doc.HH_Application__r.Status__c == HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit ){
            /** if Document is not uploaded then delete Document **/
                if(doc.Stage__c != HH_CONSTANTS.Document_Stage_Uploaded){
                    delete doc;
            /** if Document is  uploaded do not allow to delete**/
                }else {
                    throw new CustomException(System.label.HH_Document_Edit_Delete);
                }
        }
    }

    /***********************************************
    * Method Name : executeEditAction
    * Author : Sushant
    * Inputs :
    * Description: Check Stage of Application action take decision to Edit document or not.
    ************************************************/
    public Document__c executeEditAction(String docRecordId) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        if(docRecordId == null){
            throw new CustomException('Document Id is Null');
        }
        String documentRecordId = docRecordId;
        Set<String> documentFields = new Set<String>();
        /** Get all document fields **/
        Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
        documentFields.addAll(documentFieldMap.keySet());//Get all of the fields from Document__c object
        documentFields.add('Uploaded_By__r.Name');
        documentFields.add('HH_Application__r.Stage__c');
        documentFields.add('HH_Application__r.Status__c');
        String queryDocs = 'Select ' + String.join((Iterable<String>) documentFields, ',')+' FROM Document__c WHERE Id ='+'\'' + documentRecordId +'\'';
        /** If Program_Document__c has edit filter criteria then update dynamic query **/
        Document__c doc = Database.query(queryDocs);
        /** If Application Stage is Not Draft and Status is not New and Document is Uploaded then user cannot Edit Document **/
        if(doc.Stage__c == HH_CONSTANTS.Document_Stage_Uploaded
                && doc.HH_Application__r.Stage__c != HH_CONSTANTS.HHApplication_Stage_Draft
                && doc.HH_Application__r.Status__c != HH_CONSTANTS.HHApplication_Status_New ){
            throw new CustomException('Application not editable');
        /** If Application Stage is Draft and Status is Appeal Approval Resubmit and Document is Uploaded then user cannot Edit Document **/
        }else if(doc.Stage__c == HH_CONSTANTS.Document_Stage_Uploaded
                && doc.HH_Application__r.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                && doc.HH_Application__r.Status__c == HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit ){
            throw new CustomException('Application not editable');
        }else{
            return doc; /** if document is in editable stage then return Document record details **/
        }
    }

    public class CustomException extends Exception{

    }
}