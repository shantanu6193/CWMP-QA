/**
 * Created by Chandrabhan on 06-04-2021.
 */
public without sharing class MARS_InvoiceListCtrl {
     
    @AuraEnabled
    public static Map<String, Object> getInvoiceList(String agencyId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Invoice__c> pendingApprovalInvoiceList = [SELECT Id,Account__c,Account__r.Name,Incident__c,Incident__r.Name,Name,Status__c,CreatedDate, LastModifiedDate FROM Invoice__c WHERE Account__c =: agencyId AND  Status__c = 'Pending For Local Agency Approval' ORDER BY CreatedDate DESC];
        returnMap.put('pendingApprovalInvoiceList', pendingApprovalInvoiceList);
        List<Invoice__c> approvedInvoiceList = [SELECT Id,Account__c,Account__r.Name,Incident__c,Incident__r.Name,Name,Status__c,CreatedDate, LastModifiedDate FROM Invoice__c WHERE Account__c =: agencyId AND Status__c in ('Local Agency Approved','Paid', 'Partially Paid') ORDER BY CreatedDate DESC];
        returnMap.put('approvedInvoiceList', approvedInvoiceList);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> getInvoiceData(String invoiceId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Invoice__c invoiceRecord = [SELECT Id,Account__c,Account__r.Name,Incident__c,Incident__r.Name,Name,Status__c FROM Invoice__c WHERE Id =: invoiceId];
        returnMap.put('invoiceRecord', invoiceRecord);
        returnMap.put('contentVersions', getContentVersions(new List<String>{invoiceId}));
        return returnMap;
    }
   
    private static List<ContentVersion> getContentVersions(List<String> recordIds) {
        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        return [SELECT Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension,VersionData
        FROM ContentVersion WHERE ContentDocumentId IN:contentDocIds AND IsLatest=true ORDER BY ContentModifiedDate DESC LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean saveSignature(Id invoiceId, String signatureBlob, String printedTitle, String printedName) {
        if(signatureBlob != null && invoiceId != null && printedTitle != null && printedName != null) {
            SignatureHelper.saveSign(signatureBlob, invoiceId);
            Invoice__c invoiceRecord = [SELECT Id,Status__c,Printed_Name__c,Printed_Title__c,ApprovedBy__c,Approved_Date__c FROM Invoice__c WHERE Id =: invoiceId];
            invoiceRecord.Status__c = 'Local Agency Approved';
            invoiceRecord.Printed_Name__c = printedName;
            invoiceRecord.Printed_Title__c = printedTitle;
            invoiceRecord.ApprovedBy__c = UserInfo.getUserId();
            invoiceRecord.Approved_Date__c = System.now();
            update invoiceRecord;

            Map<String, String> paramMap = new Map<String, String>();
            paramMap.put('invoiceId', invoiceId);
            Flow.Interview.MARS_Invoice_Notify_Internal_People flow1 = new Flow.Interview.MARS_Invoice_Notify_Internal_People(paramMap);
            flow1.start();
            return true;
        }

        return false;
    }
    @AuraEnabled
    public static Boolean approveInvoice(Id invoiceId /*String printedTitle, String printedName*/) {
        if(invoiceId !=null /*&& printedTitle != null && printedName != null*/) {
            Account account ;
            Invoice__c invoiceRecord = [SELECT Id,Status__c,Name,Account__c,Invoice_Number_For_Json__c FROM Invoice__c WHERE Id =:invoiceId];
            if(invoiceRecord != null) {
                account = [SELECT Id,MACS_ID__c FROM Account WHERE Id =: invoiceRecord.Account__c];
            }
            String pdfUrl = KeyValueHelper.getTextValue('MARS_Community_PDF_Generate_URL');
            PageReference pr = new PageReference(pdfUrl+InvoiceId+'&skipF42s=Yes');
            Blob content;
            if(Test.isRunningTest()) { 
              	content = blob.valueOf('Unit.Test');
                } else {
                  content = pr.getContent();
                }
            //Blob content = pr.getContent();
           
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cv.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cv.Title = 'Local Agency Signed ' +invoiceRecord.Name +'.pdf';//Name of the file
            cv.PathOnClient = invoiceRecord.Name +'.pdf';//File name with extention
            cv.VersionData = content;
            cv.IsMajorVersion = true;
            Insert cv;
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
           
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = InvoiceId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'I';
            cdl.Visibility = 'AllUsers';
            Insert cdl;        
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static Boolean rejectInvoice(Id invoiceId, String comments) {
        if(comments != null && invoiceId != null) {
            Invoice__c invoiceRecord = [SELECT Id,Status__c,RejectedBy__c,Rejected_Date__c,Reject_Reason__c FROM Invoice__c WHERE Id =: invoiceId];
            invoiceRecord.Status__c = 'Local Agency Rejected';
            invoiceRecord.RejectedBy__c = UserInfo.getUserId();
            invoiceRecord.Reject_Reason__c = comments;
            invoiceRecord.Rejected_Date__c = System.now();
            update invoiceRecord;
            Map<String, String> paramMap = new Map<String, String>();
            paramMap.put('invoiceId', invoiceId);
            Flow.Interview.MARS_Invoice_Notify_Internal_People flow1 = new Flow.Interview.MARS_Invoice_Notify_Internal_People(paramMap);
            flow1.start();
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Map<String, Object> getInvoiceDownloadURL(String invoiceId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('contentVersions', getContentVersions(new List<String>{invoiceId}));
        return returnMap;
    }
     
    @AuraEnabled
    public static String getContentVersionPreview(String previewId) {
        List<ContentDocumentLink> contentDocumentIdList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId =: previewId ORDER BY SystemModStamp DESC LIMIT 1];
        if (contentDocumentIdList.isEmpty()) {
            return '';
        }
        ContentVersion contentVerionRec = [Select Id, ContentUrl From ContentVersion Where ContentDocumentId =: contentDocumentIdList[0].ContentDocumentId AND IsLatest = true];
        List<ContentDistribution> distributionList = [SELECT Id, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId =: contentDocumentIdList[0].ContentDocumentId];
        if (!distributionList.isEmpty()) {
            return distributionList[0].DistributionPublicUrl;
        }
        ContentDistribution cd = new ContentDistribution();
        cd.Name = contentDocumentIdList[0].ContentDocumentId;
        cd.ContentVersionId = contentVerionRec.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= false;
        insert cd;
        return [SELECT Id, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE Id =: cd.Id].DistributionPublicUrl;
    }
    /*
    @AuraEnabled
    public static Map<String, Object> getInvoiceSupportDocDownloadURL(String invoiceId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('contentVersions', getContentVersionsSupportDoc(new List<String>{invoiceId}));
        return returnMap;
    }
    
    private static List<ContentVersion> getContentVersionsSupportDoc(List<String> recordIds) {
        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        return [SELECT Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension,VersionData
        FROM ContentVersion WHERE ContentDocumentId IN:contentDocIds AND IsLatest=true AND  Title LIKE '%Supported_Documents%' ORDER BY ContentModifiedDate DESC LIMIT 1];
    }*/
}