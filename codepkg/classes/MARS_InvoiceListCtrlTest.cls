@isTest
private class MARS_InvoiceListCtrlTest {
    @isTest
    static void testGetInvoiceList() {
        Account testAccount = MARS_TestHelper.getAccount(true);
        F42__c f42Rec = MARS_TestHelper.getF42(false);
        Incident__c incident = MARS_TestHelper.getIncident(true);
        f42Rec.Incident__c = incident.Id;
        f42Rec.Account__c = testAccount.Id;
        insert f42Rec;
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Invoice__c invoice1 = new Invoice__c();
        invoice1.Account__c = testAccount.Id;
        invoice1.Status__c = 'Pending For Local Agency Approval';
        invoiceList.add(invoice1); 
        Invoice__c invoice2 = new Invoice__c();
        invoice2.Account__c = testAccount.Id;
        invoice2.Status__c = 'Paid';
        invoiceList.add(invoice2); 
        insert invoiceList;
        test.startTest();
        Map<String, Object> result = MARS_InvoiceListCtrl.getInvoiceList(testAccount.Id);
        System.assert(result.size() > 0);
        test.stopTest();
    }    
    @isTest
    static void testGetInvoiceData() {
        Account testAccount = MARS_TestHelper.getAccount(true);
        F42__c f42Rec = MARS_TestHelper.getF42(false);
        Incident__c incident = MARS_TestHelper.getIncident(true);
        f42Rec.Incident__c = incident.Id;
        f42Rec.Account__c = testAccount.Id;
        insert f42Rec;
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = testAccount.Id;
        invoice.Status__c = 'Pending For Local Agency Approval';
        insert invoice;
        ContentVersion cv = MARS_TestHelper.getContentVersion();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = invoice.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        test.startTest();
        Map<String, Object> result = MARS_InvoiceListCtrl.getInvoiceData(invoice.Id);
        System.assert(result.size() > 0);
        Map<String, Object> result1 = MARS_InvoiceListCtrl.getInvoiceDownloadURL(invoice.Id);
        System.assert(result1.size() > 0);
        String result2 = MARS_InvoiceListCtrl.getContentVersionPreview(invoice.Id);
        System.assertNotEquals(result2, null);
        test.stopTest();
    }    
    @isTest
    static void testApproveRejctInvoice() {
        Account testAccount = MARS_TestHelper.getAccount(true);
        F42__c f42Rec = MARS_TestHelper.getF42(false);
        Incident__c incident = MARS_TestHelper.getIncident(true);
        f42Rec.Incident__c = incident.Id;
        f42Rec.Account__c = testAccount.Id;
        insert f42Rec;
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = testAccount.Id;
        invoice.Status__c = 'Pending For Local Agency Approval';
        insert invoice;
        ContentVersion cv = MARS_TestHelper.getContentVersion();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = invoice.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        //String pdfUrl = KeyValueHelper.getTextValue('MARS_Community_PDF_Generate_URL');
        //PageReference pr = new PageReference(pdfUrl+invoice.Id);
        //Blob content = pr.getContent();
        //Blob signiture = Blob.valueof('       ');
        //String signStr = JSON.serialize(signiture);
        test.startTest();
        Boolean result = MARS_InvoiceListCtrl.saveSignature(invoice.Id,'Test signature','Manager','Test');
        System.assertNotEquals(false,result);
        Boolean result1 = MARS_InvoiceListCtrl.approveInvoice(invoice.Id);
        System.assertNotEquals(result1, false);
        Boolean result2 = MARS_InvoiceListCtrl.rejectInvoice(invoice.Id,'Invoice is Rejected');
        System.assertNotEquals(false,result2);
        test.stopTest();
    }    
}