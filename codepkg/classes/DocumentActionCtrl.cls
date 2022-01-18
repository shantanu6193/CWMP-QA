public with sharing class DocumentActionCtrl {
    private String masterRecordId;
    private String masterObjectName;
    private List<DocumentUploadCtrl.DocumentMetaInfoWrapper> docWrapperList;

    /***********************************************
    * Method Name : DocumentActionCtrl
    * Author : Shantanu
    * Inputs : masterRecordId,docWrapperList
    * Description: Constructor.
    ************************************************/
    public DocumentActionCtrl( String masterRecordId, List<DocumentUploadCtrl.DocumentMetaInfoWrapper> docWrapperList)  {
        this.masterRecordId = masterRecordId;
        Id recordId = masterRecordId;
        this.masterObjectName = recordId.getSObjectType().getDescribe().getName();
        this.docWrapperList = docWrapperList;
    }
    /***********************************************
    * Method Name : handle
    * Author : Shantanu
    * Inputs :
    * Description: To check current object and and call other method as per object.
    ************************************************/
    public List<DocumentUploadCtrl.DocumentMetaInfoWrapper> handle() {
        /** Check if current record object name is HH_Application__c if yes continue or return document details **/
        if(masterObjectName == HH_CONSTANTS.HHApplication_Object_APIName) {
            return handleHHApplicationActions();
        }
        return docWrapperList;
    }

    /***********************************************
    * Method Name : handleHHApplicationActions
    * Author : Sushant
    * Inputs :
    * Description: to check current user type and give access as per permission set.
    ************************************************/
    public List<DocumentUploadCtrl.DocumentMetaInfoWrapper> handleHHApplicationActions() {
        Boolean hideEdit = false;/** by default user can see edit icon on document upload component **/
        Boolean hideUpload = false ;/** by default user can see Upload icon on document upload component **/
        Boolean hideDelete = false ;/** by default user can see Delete icon on document upload component **/
        /** Get current record data to get details about stage and status **/
        List<HH_Application__c> app = [SELECT Stage__c,Status__c FROM HH_Application__c WHERE Id=:masterRecordId];
        if(app.size() == 0) {
            return docWrapperList;
        }
        /** To check current user is home owner on not **/
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE (PermissionSet.Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName OR PermissionSet.Name =: HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName) AND Assignee.Id =:UserInfo.getUserId()];
            /** If current user is homeOwner then hide all actions**/
            if(permissionSetAssignments.size() > 0){
                hideEdit = true;
                hideUpload = true;
                hideDelete = true;
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
            pr.hideUpload = hideUpload;
            pr.hideDelete = hideDelete;
        }
        return docWrapperList;
    }
}