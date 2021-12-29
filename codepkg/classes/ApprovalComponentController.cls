public with sharing class ApprovalComponentController {
    public ApprovalComponentController() {

    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getConfigInfoObjectandFieldAPIName(){
        Map<String,String> resultMap = new Map<String, String>();

        Key_Value_Store__mdt keyValStoreObjVal = Key_Value_Store__mdt.getInstance('PA_Approval_Config_Object_API_Name');
        System.debug('Getting Key Val Store Obj Val==='+keyValStoreObjVal);
        System.debug('Getting Key Val Store Obj Text Val==='+keyValStoreObjVal.Text_Value__c);
        List<String> approvalOptionVal = new List<String>();
        if(keyValStoreObjVal.Text_Value__c != null){
            approvalOptionVal = keyValStoreObjVal.Text_Value__c.split(';');
        }
        System.debug('approvalOptionVal==='+keyValStoreObjVal.Text_Value__c);
        return approvalOptionVal;
    }

    @AuraEnabled
    public static void createApprovalCloseOutTask(String approvalSelection, String commentsVal, 
                                                    List<String> contDocsIdLst,  String relatedRecordId){
        try {
            String projectOwnerId = [SELECT Id,OwnerId FROM Project__c WHERE Id=:relatedRecordId].OwnerId;
            Task tsk = new Task();
            tsk.Subject = 'FEMA '+approvalSelection;
            tsk.OwnerId = projectOwnerId;
            tsk.WhatId = relatedRecordId;
            if(String.isNotEmpty(commentsVal)){
                tsk.Description = approvalSelection+' with following comments:'+ commentsVal;
            }
            
            //linking files to taskId
            if(contDocsIdLst != null && contDocsIdLst.size() > 0){
                if(contDocsIdLst.size() > 0){
                    List<ContentDocumentLink> insertcontDocLinkLst = new List<ContentDocumentLink>();
                    
                    for(String contentDocId: contDocsIdLst){
                        ContentDocumentLink newContDoclnk = new ContentDocumentLink();
                        newContDoclnk.LinkedEntityId = relatedRecordId; 
                        newContDoclnk.ContentDocumentId = contentDocId;
                        newContDoclnk.ShareType = 'V';
                        insertcontDocLinkLst.add(newContDoclnk);
                        
                    }
                    insert  insertcontDocLinkLst;
                    tsk.hasAttachment__c = true;
                }                                  
            } else{
                    tsk.hasAttachment__c = false;
            }  
             insert tsk;   
        } catch (Exception ex) {
            System.debug('Exception Message is===='+ex.getMessage());
        }
    }
}