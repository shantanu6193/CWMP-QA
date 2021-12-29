@isTest
private class MARS_GenerateInvoiceCtrl_Test {
  @isTest
  static void testGenerateInvoiceCtrl(){
        MARSInvoiceHelper.InvoicePDF currentRecord = new  MARSInvoiceHelper.InvoicePDF();
 		Account testAccount = MARS_TestHelper.getAccount(true);
        F42__c f42Rec = MARS_TestHelper.getF42(false);
        Incident__c incident = MARS_TestHelper.getIncident(true);
        f42Rec.Incident__c = incident.Id;
        f42Rec.Account__c = testAccount.Id;
        insert f42Rec;
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = testAccount.Id;
        invoice.Status__c = 'Pending For Local Agency Approval';
        invoice.Invoice_Json__c = JSON.serialize(currentRecord);
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
        PageReference testPage = Page.MARS_GenerateInvoice; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(invoice.Id));
        MARS_GenerateInvoiceCtrl test = new MARS_GenerateInvoiceCtrl();   
    }
}