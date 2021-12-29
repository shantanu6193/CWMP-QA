public without sharing class HMA_RequestForInformationCtrl {

    @AuraEnabled
    public static Map<String, Object> processOnRFI(String applicationId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {      
            List<Request_For_Information__c> updatedRFIs = new List<Request_For_Information__c>();
            returnMap.put('isSuccess', true);
            List<Request_For_Information__c> rfiRecords = HMA_Utility.getApplicationRFIs(new Set<String>{applicationId}, 
                                                                                        new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA, 
                                                                                                        HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC, 
                                                                                                        HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC, 
                                                                                                        HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP},  
                                                                                        new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_DRAFT});
            if(rfiRecords.size() == 0) {
                returnMap.put('isSuccess', false);
                return returnMap;
            }
            for(Request_For_Information__c rfi : rfiRecords) {
                rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT;
                updatedRFIs.add(rfi);
            }
            update updatedRFIs;
            // Boolean isEmailSent = sendEmailToSubApplicants(applicationId, HMA_CONSTANTS.HMA_RFI_SENT_TO_SUBAPPLICANT_NOTIFICATION);
            // if(isEmailSent == false) {
            //     returnMap.put('isSuccess', false);
            // }                       
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            throw new AuraHandledException(e.getMessage());
        } 
        return returnMap;
    }
    @AuraEnabled
    public static Map<String, Object> getRFIRecordDetails(String rfiRecordId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            returnMap.put('isSuccess', true);
            if(String.isEmpty(rfiRecordId)) {
                returnMap.put('isSuccess', false);
                return returnMap;
            }
            Request_For_Information__c rfiRecord = [SELECT Id, Status__c, Application__c, Description__c, FEMA_Comments__c, Analyst_Comment__c, Subapplicant_Comment__c, RFI_Deadline__c, RFI_Type__c, Subapplicant_Status__c FROM Request_For_Information__c WHERE Id =: rfiRecordId];
            returnMap.put('rfiRecord', rfiRecord);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Object> getRFIRelatedDocuments(String recordId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            List<String> contentDocumentIds = new List<String>();
            List<ContentVersion> contentVersionsList = new List<ContentVersion>();
            returnMap.put('isSuccess', true);
            if(String.isEmpty(recordId)) {
                returnMap.put('isSuccess', false);
                return returnMap;
            }
            List<ContentDocumentLink> contentDocLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
            for(ContentDocumentLink cdl : contentDocLinks) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            if(contentDocumentIds.size() > 0) {
                contentVersionsList = [SELECT  Id, 
                                                Title, 
                                                FileType,
                                                ContentDocumentId, 
                                                CreatedById,
                                                CreatedBy.UserRole.Name
                                        FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
            }
            returnMap.put('documents', contentVersionsList);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }
    @AuraEnabled
    public static Map<String, Object> updateRFIRecordAndSendNotification(String rfiRecord, String applicationId, String actionName) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            returnMap.put('isSuccess', true);
            Request_For_Information__c rfi = (Request_For_Information__c) JSON.deserialize(rfiRecord, Request_For_Information__c.class);
            rfi.Application__c = applicationId;
            if(actionName == 'Submit') {
                rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED;
            } else if(actionName == 'RequestForExtension') {
                rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REQUESTED;
            } else if(actionName == 'FEMASubmit') {
                rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SUBMITTED_TO_CAL_OES_ANALYST;
            }
            upsert rfi;
            returnMap.put('rfiRecord', rfi);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            returnMap.put('error',e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
            }
    @AuraEnabled
    public static Map<String, Object> attachUploadedFilesToRFI(List<String> contentDocumentIds, String rfiId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            returnMap.put('isSuccess', true);
            List<ContentDocumentLink> newLinkList = new List<ContentDocumentLink>();
            List<ContentDocumentLink> contentDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: contentDocumentIds];
            System.debug('contentDocLinks :'+contentDocLinks);
            
            for(ContentDocumentLink link : contentDocLinks) {
                ContentDocumentLink newLink = new ContentDocumentLink();
                newLink.ContentDocumentId = link.ContentDocumentId;
                newLink.LinkedEntityId = rfiId;
                newLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                newLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                newLinkList.add(newLink);
            }
            insert newLinkList;
            returnMap.put('docLink', newLinkList);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            returnMap.put('error',e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> deleteContentDocument(String contentDocId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        try {            
            if(String.isNotEmpty(contentDocId)) {
                returnMap.put('isSuccess', true);
                cvList = [SELECT  Id, PathOnClient, Title, VersionNumber From ContentVersion Where ContentDocumentId =: contentDocId order by VersionNumber DESC];
                delete[SELECT  Id FROM ContentDocument WHERE Id = : contentDocId];
            }
            returnMap.put('contentDocId', contentDocId);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            System.debug('error :'+ e);
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }

    /** Used for Send email to 'Responsible Representative', 'Primary Contact', 'Contributor' */
    public static Boolean sendEmailToSubApplicants(String applicationId, String emailTemplate) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        Application__c applicationDetail = [SELECT Id, (SELECT   
                                                            Id, 
                                                            Contact__c, 
                                                            AccountContactJunction__c, 
                                                            AccountContactJunction__r.Contact_Name__c, 
                                                            AccountContactJunction__r.Contact_Name__r.Email, 
                                                            Application__c 
                                                            FROM Contact_Roles__r  
                                                            WHERE Role__c includes('Responsible Representative', 'Primary Contact', 'Contributor'))
                                            FROM Application__c WHERE Id =: applicationId];
        
        for(Contact_Role__c role : applicationDetail.Contact_Roles__r) {
            mails = HMA_ApplicationHelper.sendEmail(applicationDetail, 
                                                    new List<String>{role.AccountContactJunction__r.Contact_Name__r.Email}, 
                                                    new List<String>{},
                                                    emailTemplate, 
                                                    HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                                    role.AccountContactJunction__r.Contact_Name__c);
            allMails.addAll(mails);
        }
        if(allMails.size() == 0) {
            return false;
        }     
        Messaging.sendEmail(allMails);    
        return true;
    }

    /** Used for Send email to HMA Analyst */
    public static Boolean sendEmailToHmaAnalyst(String applicationId, String emailTemplate) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Application__c applicationDetail = [SELECT Id, 
                                                    OwnerId, 
                                                    Owner.UserRole.Name,
                                                    Owner.Email
                                            FROM Application__c WHERE Id =: applicationId AND Owner.UserRole.Name =: HMA_CONSTANTS.HMA_USER_ROLE_HMA_ANALYST];

        mails = HMA_ApplicationHelper.sendEmail(applicationDetail, 
                                                new List<String>{applicationDetail.Owner.Email}, 
                                                new List<String>{},
                                                emailTemplate, 
                                                HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                                applicationDetail.OwnerId);
                                                
        if(mails.size() == 0) {
            return false;
        }
        for(Messaging.SingleEmailMessage mail : mails) {
            mail.setSaveAsActivity(false);
        }
        Messaging.sendEmail(mails);
        return true;
    }

    /*************************************************************** 
    Name : changeRFIStatus
    Author : Rakesh
    Date : 28th July 2021
    Description : This method takes two parameters rfiId and operation.
                    Operation is of two types 1. TimeExtensionRequest
                                              2. SubmitRFI
                    Based on oeprations status of rfi is changed.
    ****************************************************************/

    @AuraEnabled
    public static Map<String, Object> changeRFIStatus(Id rfiId, String operation) {
        Map<String, Object> returnMap = new Map<String, Object>();
        if(rfiId == null || String.isBlank(operation)) {
            returnMap.put('IsSuccess', false);
            return returnMap;
        }
        Map<Id, Request_For_Information__c> requestForInformationMap = new Map<Id, Request_For_Information__c>([SELECT Id, Status__c, RFI_Type__c
                                                                                                                    FROM Request_For_Information__c
                                                                                                                    WHERE Id = :rfiId]);
        if(requestForInformationMap.containsKey(rfiId)) {
            Request_For_Information__c rfi = requestForInformationMap.get(rfiId);
            if(operation.equals('TimeExtensionRequest')) {
                rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED;
            } else if(operation.equals('SubmitRFI')) {
                rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED_BY_CAL_OES_ANALYST;
            }
            update rfi;
            returnMap.put('IsSuccess', true);
            returnMap.put('RFIRecord', (Object) rfi);
        } else {
            returnMap.put('IsSuccess', false);
        }
        return returnMap;
    }

    /*************************************************************** 
    Name : loadRFIRecord
    Author : Rakesh
    Date : 28th July 2021
    Description : This method takes one parameter rfiId
                    and return the queried result.
    ****************************************************************/

    @AuraEnabled
    public static Map<String, Object> loadRFIRecord(Id rfiId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        if(rfiId == null) {
            returnMap.put('IsSuccess', false);
            return returnMap;
        }
        Map<Id, Request_For_Information__c> requestForInformationMap = new Map<Id, Request_For_Information__c>([SELECT Id, Status__c, RFI_Type__c
                                                                                                    FROM Request_For_Information__c
                                                                                                    WHERE Id = :rfiId]);
        if(requestForInformationMap.containsKey(rfiId)) {
            returnMap.put('IsSuccess', true);
            returnMap.put('RFIRecord', (Object) requestForInformationMap.get(rfiId));
        } else {
            returnMap.put('IsSuccess', false);
        }
        System.debug('returnMap---'+returnMap);
        return returnMap;
    }

    
}