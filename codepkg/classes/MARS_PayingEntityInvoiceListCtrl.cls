public without sharing class MARS_PayingEntityInvoiceListCtrl {

    @AuraEnabled
    public static Map<String, List<Object>> getInvoiceList() {
       Map<String, List<Object>> returnMap = new Map<String, List<Object>>();
       Id agencyId = getLoggedInUser().Contact.AccountId;
       List<Invoice_Payment__c> pendingPayments = [SELECT Id, Status__c, Invoice__c, Invoice_Percent__c, Invoice_Amount__c, 
                                                    Paid_Amount__c, Invoice__r.Name,
                                                    Invoice__r.Incident__r.Name, Invoice__r.Account__r.Name, CreatedDate
                                                    FROM Invoice_Payment__c 
                                                    WHERE Status__c = 'Pending'
                                                    AND Invoice__r.Status__c = 'Pending For Paying Entity Approval'
                                                    AND Funding_Source__r.Account__c = :agencyId
                                                    order by createddate desc];       
        returnMap.put('payingEntityInvoiceList', pendingPayments);
        List<Invoice_Payment__c> paidPayments = [SELECT Id, Status__c, Invoice__c, Invoice_Percent__c, Invoice_Amount__c, 
                                                    Paid_Amount__c, Invoice__r.Name,
                                                    Invoice__r.Incident__r.Name, Invoice__r.Account__r.Name, Date_Of_Payment__c
                                                    FROM Invoice_Payment__c 
                                                    WHERE Status__c IN ('Paid', 'Partially Paid')
                                                    AND Invoice__r.Status__c IN ('Paid', 'Partially Paid')
                                                    AND Funding_Source__r.Account__c = :agencyId
                                                    order by createddate desc];       
        returnMap.put('payingEntityInvoiceList', pendingPayments);
        returnMap.put('paidPayments', paidPayments);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String, List<Object>> getInvoiceListByFilter(String invoiceNumber, String incidentName, String macId) {
       Map<String, List<Object>> returnMap = new Map<String, List<Object>>();
       
       Id agencyId = getLoggedInUser().Contact.AccountId;
        System.debug('###: agencyId Filter: ' + agencyId);
       String query = 'SELECT Id, Status__c, Invoice__c, Invoice_Percent__c, Invoice_Amount__c, '+ 
                                                    'Paid_Amount__c, Invoice__r.Invoice_Number__c, Invoice__r.Name, ' +
                                                    'Invoice__r.Incident__r.Name, Invoice__r.Account__r.Name, CreatedDate '+
                                                    'FROM Invoice_Payment__c ' + 
                                                    'WHERE Status__c = \'Pending\' '+
                                                    'AND Invoice__r.Status__c = \'Pending For Paying Entity Approval\' ' +
                                                    'AND Funding_Source__r.Account__c = :agencyId ';
       if (String.isNotBlank(invoiceNumber)) {
          query += 'AND Invoice__r.Invoice_Number__c LIKE \'%' + invoiceNumber + '%\'';         
                                                                 }
        if (String.isNotBlank(incidentName)) {
            query += 'AND invoice__r.Incident__r.Name LIKE \'%'+ incidentName +'%\'';
        }
        if (String.isNotBlank(macId)) {
             query += 'AND Funding_Source__r.Account__r.MACS_ID__c LIKE \'%' + macId + '%\'';
        }
        query += ' order by createddate desc';
        System.debug('###: Query: '  +query);
       List<Invoice_Payment__c> pendingPayments = Database.query(query);
                                                                 
        System.debug('###: pendingPayments: ' + pendingPayments);  
         System.debug('###: pendingPayments: ' + pendingPayments.size()); 
        returnMap.put('payingEntityInvoiceList', pendingPayments);
        return returnMap;
    }
    

    
    private static User getLoggedInUser() {
        return [Select Id, Contact.AccountId From User Where Id =: UserInfo.getUserId()];
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
        FROM ContentVersion WHERE ContentDocumentId IN:contentDocIds AND IsLatest=true AND Title LIKE 'Invoice%' ORDER BY ContentModifiedDate DESC LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean saveSignature(Id invoiceId, String signatureBlob) {
        if(signatureBlob != null && invoiceId != null ) {
            SignatureHelper.saveSign(signatureBlob, invoiceId);
           
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean approvePaymentInvoice(String invoicePaymentId, String paidAmount, Date dateOfPayment, String comments) {
        Invoice_Payment__c invoicePaymentRec = [SELECT Id, Status__c, Invoice__c, Invoice_Amount__c, Paid_Amount__c, Date_Of_Payment__c, Payment_Comments__c,
                                                Payment_Recorded_By__c FROM Invoice_Payment__c WHERE Id =: invoicePaymentId];
        Double paidAmountVal = Double.valueOf(paidAmount);
        String status;
        System.debug('###: dateOfPayment: ' + dateOfPayment);
        System.debug('###: paidAmountVal: ' + paidAmountVal);
        System.debug('###: invoicePaymentRec.Invoice_Amount__c: ' + invoicePaymentRec.Invoice_Amount__c);
        if (invoicePaymentRec.Invoice_Amount__c > paidAmountVal) {
            status = 'Partially Paid';
        } else  {
            status = 'Paid';
        }
        invoicePaymentRec.Status__c = status;
        invoicePaymentRec.Paid_Amount__c = paidAmountVal;
        invoicePaymentRec.Payment_Comments__c = comments;
        invoicePaymentRec.Date_Of_Payment__c = dateOfPayment;
        invoicePaymentRec.Payment_Recorded_By__c = getLoggedInUser().Id;
        update invoicePaymentRec;

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('invoicePaymentId', invoicePaymentId);
        Flow.Interview.MARS_Invoice_Notify_Internal_People_From_Paying_Agency flow1 = new Flow.Interview.MARS_Invoice_Notify_Internal_People_From_Paying_Agency(paramMap);
        flow1.start();

        return true;
    }
    
     @AuraEnabled
    public static Boolean rejectPaymentInvoice(String invoicePaymentId, String comments) {
        Invoice_Payment__c invoicePaymentRec = [SELECT Id, Status__c, Payment_Comments__c
                                                FROM Invoice_Payment__c WHERE Id =: invoicePaymentId];
        invoicePaymentRec.Rejection_Reason__c = comments;
        invoicePaymentRec.Status__c = 'Rejected';
        update invoicePaymentRec;

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('invoicePaymentId', invoicePaymentId);
        Flow.Interview.MARS_Invoice_Notify_Internal_People_From_Paying_Agency flow1 = new Flow.Interview.MARS_Invoice_Notify_Internal_People_From_Paying_Agency(paramMap);
        flow1.start();

        return true;
    }
    
    @AuraEnabled
    public static Boolean approveInvoice(Id invoiceId,String printedTitle, String printedName) {
        if(invoiceId !=null && printedTitle != null && printedName != null) {
            String pdfUrl = KeyValueHelper.getTextValue('MARS_Community_PDF_Generate_URL');
            PageReference pr = new PageReference(pdfUrl+InvoiceId);
            Blob content;
            if (Test.isRunningTest()) {
                content = Blob.valueOf('Unit test');
            } else {
               content = pr.getContent(); 
            }
            
            ContentVersion cv = new ContentVersion();
              cv.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
               cv.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            
            cv.PathOnClient = 'Invoice-'+System.now() +'.pdf';//File name with extention
           
            cv.Title = 'Invoice-'+System.now() +'.pdf';//Name of the file
            //cv.PathOnClient = 'Invoice.pdf';
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
            Invoice__c invoiceRecord = [SELECT Id,Status__c,Printed_Name__c,Printed_Title__c,ApprovedBy__c,Approved_Date__c FROM Invoice__c WHERE Id =: invoiceId];
            invoiceRecord.Status__c = 'Pending For Paying Entity Approval';
            invoiceRecord.Printed_Name__c = printedName;
            invoiceRecord.Printed_Title__c = printedTitle;
            invoiceRecord.ApprovedBy__c = UserInfo.getUserId();
            invoiceRecord.Approved_Date__c = System.now();
            update invoiceRecord;
            //System.enqueueJob(new GeneratePDFFromInvoice(String.valueOf(invoiceId)));
            
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static Boolean rejectInvoice(Id invoiceId, String comments) {
        if(comments != null && invoiceId != null) {
            Invoice__c invoiceRecord = [SELECT Id,Status__c,RejectedBy__c,Rejected_Date__c,Reject_Reason__c FROM Invoice__c WHERE Id =: invoiceId];
            invoiceRecord.Status__c = 'Paying Entity Rejected';
            invoiceRecord.RejectedBy__c = UserInfo.getUserId();
            invoiceRecord.Reject_Reason__c = comments;
            invoiceRecord.Rejected_Date__c = System.now();
            update invoiceRecord;
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
        List<ContentDocumentLink> contentDocumentIdList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId =: previewId ORDER BY SystemModStamp DESC LIMIT 1];
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
    }
    */
}