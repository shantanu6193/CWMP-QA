public without sharing class DocuSignStatusTriggerHelper extends TriggerHelper{
    /***********************************************
    * Method Name : processBeforeInsert
    * Author : 
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processBeforeInsert() {}

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Digambar
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processBeforeUpdate() {}

    /***********************************************
    * Method Name : processBeforeDelete
    * Author : 
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processBeforeDelete() {}

    /***********************************************
    * Method Name : processBeforeUndelete
    * Author : 
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processBeforeUndelete() {}

    /***********************************************
    * Method Name : processAfterInsert
    * Author : Digambar
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processAfterInsert() {
        List<dfsle__EnvelopeStatus__c> docuSignStatusList =  (List<dfsle__EnvelopeStatus__c>)Trigger.new;
        String fileName = '';
        system.debug('#docuSignStatusList :' + docuSignStatusList);
        List<String> closeoutTaskIdsToUpdateList = new List<String>();
        Map<String,String> closeoutTaskToFilenameMap = new Map<String,String>();
        for(dfsle__EnvelopeStatus__c docuSignStatus : docuSignStatusList){
            //check if Salesforce Source ID is Closeout_Task__c & status is sent
            Id potentialCloseoutTaskId = Id.valueOf(docuSignStatus.dfsle__SourceId__c);
            String objectName = potentialCloseoutTaskId.getSObjectType().getDescribe().getName();
            system.debug('#objectName :' + objectName);
            system.debug('#status :' + docuSignStatus.dfsle__Status__c);
            if(objectName.equals('Closeout_Task__c') && docuSignStatus.dfsle__Status__c.equalsIgnoreCase('sent')){
                 //fileName = docuSignStatus.dfsle__EmailSubject__c + '.pdf';
                fileName = 'Envelope_' + docuSignStatus.dfsle__DocuSignId__c + '.pdf';
                closeoutTaskToFilenameMap.put(docuSignStatus.dfsle__SourceId__c, fileName);
            }
        }
        //generateDocument(closeoutTaskIdsToUpdateList, fileName);
        updateFIRDoc(closeoutTaskToFilenameMap);
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : 
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processAfterUpdate() {
        List<dfsle__EnvelopeStatus__c> docuSignStatusNewList =  (List<dfsle__EnvelopeStatus__c>)Trigger.new;
        List<dfsle__EnvelopeStatus__c> docuSignStatusOldList =  (List<dfsle__EnvelopeStatus__c>)Trigger.old;
        system.debug('#docuSignStatusNewList :' + docuSignStatusNewList);
        system.debug('#docuSignStatusOldList :' + docuSignStatusOldList);
        List<String> closeoutTaskIdsToUpdateList = new List<String>();
        List<String> closeoutTaskIdsGARList = new List<String>();
        Integer triggerRecordsCounter = 0;
        for(dfsle__EnvelopeStatus__c docuSignStatus : docuSignStatusNewList){
            //check if Salesforce Source ID is Closeout_Task__c & status is updated
            Id potentialCloseoutTaskId = Id.valueOf(docuSignStatus.dfsle__SourceId__c);
            String objectName = potentialCloseoutTaskId.getSObjectType().getDescribe().getName();
            system.debug('#objectName :' + objectName);
            system.debug('#status :' + docuSignStatus.dfsle__Status__c);
            if(objectName.equals('Closeout_Task__c') && docuSignStatus.dfsle__Status__c.equalsIgnoreCase('Completed')){
                closeoutTaskIdsToUpdateList.add(docuSignStatus.dfsle__SourceId__c);
            }
        }
        //attachDocuSignContentDocumentLink(closeoutTaskIdsToUpdateList);

         //Check Approval Status is GAR & Update Closeout Task fields 
        List<Closeout_Task__c> closeoutTaskToUpdateGARDocuSignStatusList = new List<Closeout_Task__c>();
        Key_Value_Store__mdt mtdtGARStatus = Key_Value_Store__mdt.getInstance('PA_DocuSign_GAR_Approval_Status');
        System.debug('#mtdtGARStatus: '+mtdtGARStatus);
        System.debug('#mtdtGARStatus VALUE: '+mtdtGARStatus.Text_Value__c);
        Key_Value_Store__mdt mtdtApprovalComment = Key_Value_Store__mdt.getInstance('PA_DocuSign_Approval_Comment');
        System.debug('#mtdtApprovalComment: '+mtdtApprovalComment);
        System.debug('#mtdtApprovalComment VALUE: '+mtdtApprovalComment.Text_Value__c);
        closeoutTaskToUpdateGARDocuSignStatusList = [SELECT Id, Name, Docusign_Status__c, Approval_Status__c
                                                  FROM Closeout_Task__c
                                                  WHERE Approval_Status__c =: mtdtGARStatus.Text_Value__c
                                                     AND Id IN :closeoutTaskIdsToUpdateList
                                                 ];
        system.debug('#closeoutTaskToUpdateGARDocuSignStatusList Before Status Update :'+closeoutTaskToUpdateGARDocuSignStatusList);                                                 
        for(Closeout_Task__c closeoutTask : closeoutTaskToUpdateGARDocuSignStatusList){
                closeoutTask.Docusign_Status__c = 'GAR COMPLETE';
                closeoutTask.Approval_Stage__c = 'Approved';
                closeoutTask.Approval_Comment__c = mtdtApprovalComment.Text_Value__c;
                closeoutTaskIdsGARList.add(closeoutTask.Id);
        }                
        system.debug('#closeoutTaskToUpdateGARDocuSignStatusList After Status Update :'+closeoutTaskToUpdateGARDocuSignStatusList);
        system.debug('#closeoutTaskIdsGARList :'+closeoutTaskIdsGARList);
        update closeoutTaskToUpdateGARDocuSignStatusList; 

        //Update Closeout Task fields 
        List<Closeout_Task__c> closeoutTaskToUpdateDocuSignStatusList = new List<Closeout_Task__c>();
        
        for(String closeoutTaskId : closeoutTaskIdsToUpdateList){
                if(!closeoutTaskIdsGARList.contains(closeoutTaskId)){
                    Closeout_Task__c closeoutTask = new Closeout_Task__c(Id = closeoutTaskId, Docusign_Status__c = 'COMPLETE', Approval_Stage__c = 'Approved', Approval_Comment__c = mtdtApprovalComment.Text_Value__c);
                    closeoutTaskToUpdateDocuSignStatusList.add(closeoutTask);
                }
        }
        update closeoutTaskToUpdateDocuSignStatusList;
    }

    /***********************************************
    * Method Name : processAfterDelete
    * Author : 
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processAfterDelete() {}

    /***********************************************
    * Method Name : processAfterUndelete
    * Author : 
    * Inputs : -
    * Description: 
    *********************************************/
    public override void processAfterUndelete() {}

     /***********************************************
    * Method Name : generateDocument
    * Author : Digambar
    * Inputs : List<String> closeoutTaskIdsToUpdateList
    * Description: This method create Document object
    TO - DO > Check DocuSign template of current updated Docusign status & further consider Document to be handel
    *********************************************/
    private static void generateDocument(List<String> closeoutTaskIdsToUpdateList, String fileName) {

        List<Closeout_Task__c> closeoutTaskList = new List<Closeout_Task__c>();
        List<Document__c> docListVal = new List<Document__c>();
        for(String recordId : closeoutTaskIdsToUpdateList){
            //Check if FIR Sign Document is already created and not uploaded
            Key_Value_Store__mdt mtdtFIRDocName = Key_Value_Store__mdt.getInstance('PA_FIR_Document_Name');
            System.debug('#mtdtFIRDocName: '+mtdtFIRDocName);
            System.debug('#mtdtFIRDocName VALUE: '+mtdtFIRDocName.Text_Value__c);

            Integer count = [SELECT COUNT() 
                            FROM Document__c
                            WHERE Closeout_Task__c =: recordId
                                AND Document_Name__c =: mtdtFIRDocName.Text_Value__c
                                AND Date_Uploaded__c = NULL];
            system.debug('#COUNT :'+count);
            //Create Document
            if(count == 0){
                
                Document__c docObj = new Document__c();
                docObj.Document_Name__c = mtdtFIRDocName.Text_Value__c;
                docObj.Original_File_Name__c = fileName;
                docObj.Document_Type__c = 'Closeout';
                docObj.Closeout_Task__c = recordId;
                docListVal.add(docObj);
                system.debug('#docListVal :'+docListVal);
            }       
            //Update DocuSign Status
            Closeout_Task__c closeoutTask = new Closeout_Task__c(Id = recordId, Docusign_Status__c = 'PENDING');
            closeoutTaskList.add(closeoutTask);
        }

        //Insert Documents
        if(!docListVal.isEmpty()){
            
                insert docListVal;
            
        }
            
        
        //Update Closeout Task
            update closeoutTaskList;
        
    }

    /***********************************************
    * Method Name : updateFIRDoc
    * Author : Digambar
    * Inputs : List<String> closeoutTaskIdsToUpdateList
    * Description: This method create Document object
    *********************************************/
    private static void updateFIRDoc(Map<String,String> closeoutTaskToFilenameMap) {
        List<Closeout_Task__c> closeoutTaskList = new List<Closeout_Task__c>();
        //Get CloseoutTask Document To Be Attached
        Key_Value_Store__mdt mtdtFIRDocName = Key_Value_Store__mdt.getInstance('PA_Signed_FIR_Document_Name');
        List<Document__c> documentList = [SELECT Id, Closeout_Task__c
                                         FROM Document__c
                                         WHERE Closeout_Task__c IN: closeoutTaskToFilenameMap.keySet()
                                         AND Document_Name__c =: mtdtFIRDocName.Text_Value__c 
                                         AND Document_Type__c = 'Signed FIR'
                                         ];   
        for( Document__c doc : documentList){
                doc.Original_File_Name__c = closeoutTaskToFilenameMap.get(doc.Closeout_Task__c);
                doc.Date_Uploaded__c = NULL;
        }
        update documentList;
        
        //Update DocuSign Status
        for(String recordId : closeoutTaskToFilenameMap.keySet()){
                Closeout_Task__c closeoutTask = new Closeout_Task__c(Id = recordId, Docusign_Status__c = 'PENDING');
                closeoutTaskList.add(closeoutTask);
        }
        //Update Closeout Task
        update closeoutTaskList;
    }
    //********************************************************************************************************************************   
}