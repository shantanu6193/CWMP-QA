/***********************************************************************************************************************************
* Class Name   : ContentDocumentLinkTriggerHelper
* Description  : This class for sharing notes to community user
* Author       : Pankaj
* Created On   : 05/15/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             05/15/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class ContentDocumentLinkTriggerHelper extends TriggerHelper { 

    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method set default sharing to public read only. so that notes created by Internal users should be visible to community users
    *********************************************/
    public override void processBeforeInsert() {
        // set default sharing to public read only. so that notes created by Internal users should be visible to community users
        for(ContentDocumentLink cont : (List<ContentDocumentLink>)Trigger.new) {
            cont.Visibility = 'AllUsers';
        }
    }

    public override void processAfterInsert() {
        if(System.isFuture() == false && System.isQueueable() == false && System.isBatch() == false
                && System.isScheduled() == false) {
            processDocGenAssociation();
        }
    }

    private void processDocGenAssociation() {
        List<ContentDocumentLink> contDocLinkList = (List<ContentDocumentLink>)Trigger.new;
        /* 
        String docGenSalesforceUserId = KeyValueHelper.getTextValue('DocGenAdminUserId');
        if(Id.valueOf(docGenSalesforceUserId) != UserInfo.getUserId()) return;
        */

        linkingDocumentToContentDocumentLinksForDocGen(contDocLinkList);
    }

    public void linkingDocumentToContentDocumentLinksForDocGen(List<ContentDocumentLink> contentDocLinkList){
        List<ContentDocumentLink> updateDocList = new List<ContentDocumentLink>();
        Set<Id> contDocIds = new Set<Id>();
        List<String> docNameList = new List<String>();
        List<String> recIdVal = new List<String>();
        List<sObject> sobjResultVal;
        String docGenRecId;
        String docGenRecAPIName;

        if(contentDocLinkList.size() > 0){
            Id recIdValSingle;
            for(ContentDocumentLink contDocLink: contentDocLinkList){
                contDocIds.add(contDocLink.ContentDocumentId);
                recIdVal.add(contDocLink.LinkedEntityId);
                String linkedEntityId = contDocLink.LinkedEntityId;
                if(linkedEntityId.startsWith('005') == false) {
                    recIdValSingle = Id.valueOf(recIdVal[0]);
                }
            }

            if(recIdValSingle != null) {
                String objectName = recIdValSingle.getSObjectType().getDescribe().getName();
                docGenRecId = recIdValSingle;
                docGenRecAPIName = objectName;
                if(recIdValSingle != null && (docGenRecAPIName == 'Project__c' || docGenRecAPIName == 'Closeout_Task__c'
                        || docGenRecAPIName == 'Project_Closeout__c' || docGenRecAPIName == 'Payment_Request__c')){
                   sobjResultVal =  Database.query('SELECT Id,Name FROM ' + objectName + ' WHERE Id = :recIdValSingle Limit 1');
                }
            }
            
        }
       
        if(sobjResultVal != null && sobjResultVal.size() > 0){
            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId, Description, Title,
                                                    Document_Type__c, FileType
                                                    FROM  ContentVersion 
                                                    WHERE ContentDocumentId IN: contDocIds ];
            if(contentVersionList.size() > 0) {
                for(ContentVersion contVersionVal: contentVersionList) {
                    for(ContentDocumentLink contDocLink: contentDocLinkList) {
                        String docTitle =   contVersionVal.Title;
                        //doc gen Files
                        DateTime todayDate = Datetime.now();
                        String formattedTodaysDate = '_'+ todayDate.format('yyyy-MM-dd');
                        if(docTitle.contains(String.valueOf(sobjResultVal[0].get('Name')) )) {
                            docTitle = docTitle.replace('_'+String.valueOf(sobjResultVal[0].get('Name')), '');
                            docTitle = docTitle.replace(formattedTodaysDate, '');
                            docNameList.add(docTitle);
                        } else if(docTitle.contains( formattedTodaysDate )) {
                            docTitle = docTitle.replace(formattedTodaysDate, '');
                            docNameList.add(docTitle);
                        } else {
                            docNameList.add(docTitle);
                        }
                        
                    }
                }
            }
            
            String additionalFilterClause = '';
            if(docGenRecAPIName == 'Project__c') {
                additionalFilterClause = ' and ProjectId__c=:docGenRecId';
            } else if(docGenRecAPIName == 'Closeout_Task__c') {
                additionalFilterClause = ' and Closeout_Task__c=:docGenRecId';
            } else if(docGenRecAPIName == 'Project_Closeout__c') {
                additionalFilterClause = ' and Project_Closeout__c=:docGenRecId';
            } else if(docGenRecAPIName == 'Payment_Request__c') {
                additionalFilterClause = ' and PaymentRequest__c=:docGenRecId';
            }

            //***********************
            //String query = 'SELECT Id, Document_Name__c, Original_File_Name__c, Document_Type__c, Name,CreatedById FROM Document__c WHERE  Original_File_Name__c IN:docNameList and Date_Uploaded__c = NULL';
            String query = 'SELECT Id, Document_Name__c, Original_File_Name__c, Document_Type__c, Name,CreatedById, ProjectId__c, PaymentRequest__c, Closeout_Task__c, Project_Closeout__c FROM Document__c WHERE  Original_File_Name__c IN:docNameList and Date_Uploaded__c = NULL';
            //***********************
            query += additionalFilterClause;
            List<Document__c> docValList = Database.query(query);
            if(docValList.size() == 0){
                return ;
            }
            Id newVal = contentDocLinkList[0].ContentDocumentId;
            Id sobjIdVal = (Id) sobjResultVal[0].get('Id');
            List<ContentDocumentLink> contentDCLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId
                                                            FROM ContentDocumentLink
                                                            WHERE ContentDocumentId =:newVal and LinkedEntityId=:sobjIdVal];
            //check if document record have already file attached. In that case create new version for same document record.
            List<Id> docsIds = new List<Id>();
            for (Document__c document : docValList) {
                docsIds.add(document.Id);
            }
                    List<ContentDocumentLink> contentDocumentLinksForDocuments = [
                            SELECT ContentDocumentId, LinkedEntityId
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId In:docsIds
                    ];
            Map<Id, Id> docWithContentDocId = new Map<Id, Id>();
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinksForDocuments) {
                docWithContentDocId.put(contentDocumentLink.LinkedEntityId, contentDocumentLink.ContentDocumentId);
            }
            
            //******************* 
            //Set<Id> documentIdToUploadedDoc = new Set<Id>();
            Map<String, String> documentIdToLinkedObjectMap = new  Map<String, String>();
            //******************* 
                for(Document__c docVal : docValList) {
                    docVal.Date_Uploaded__c = System.today();
                    for(ContentDocumentLink cdLink : contentDCLinkList){
                        ContentDocumentLink newCdl = cdLink.clone();
                        newCdl.LinkedEntityId = docVal.Id;
                        updateDocList.add(newCdl);
                        // get list of documents for which we have to create new versions for existing document
                        if(docWithContentDocId.get(docVal.Id) != null) {
                            //***************************
                            //documentIdToUploadedDoc.add(docVal.Id);
                            if(docGenRecAPIName == 'Project__c') {
                                documentIdToLinkedObjectMap.put(docVal.Id, docVal.ProjectId__c);
                            } else if(docGenRecAPIName == 'Closeout_Task__c') {
                                documentIdToLinkedObjectMap.put(docVal.Id, docVal.Closeout_Task__c);
                            } else if(docGenRecAPIName == 'Project_Closeout__c') {
                                documentIdToLinkedObjectMap.put(docVal.Id, docVal.Project_Closeout__c);
                        }else if (docGenRecAPIName == 'Payment_Request__c') {
                            documentIdToLinkedObjectMap.put(docVal.Id, docVal.PaymentRequest__c);
                            }
                            //***************************
                        }
                    }
                }
            TriggerHelper.skipTrigger = true;
            System.debug('updateDocList ....===>'+updateDocList);
            System.debug('docValList ....===>'+docValList);
            upsert updateDocList;
            upsert docValList;
            TriggerHelper.skipTrigger = false;
            if(documentIdToLinkedObjectMap.size() > 0) {
                System.enqueueJob(new UpdateDocumentVersion(documentIdToLinkedObjectMap));
            }
        }
    }

    public class UpdateDocumentVersion implements Queueable {
        Map<String, String> documentIdToLinkedObjectMap;
        public UpdateDocumentVersion(Map<String, String> documentIdToLinkedObjectMap) {
            this.documentIdToLinkedObjectMap = documentIdToLinkedObjectMap;
        }
        public void execute(QueueableContext context) {
            system.debug('#UpdateDocumentVersion In Action...');
            system.debug('#documentIdToLinkedObjectMap :'+documentIdToLinkedObjectMap);
            for (String docId : documentIdToLinkedObjectMap.keySet()) {
                ALS_DocumentUpload_Ctrl.saveFileDetails(docId, null, documentIdToLinkedObjectMap.get(docId));
            }
        }
    }



}