public without sharing class MARS_GenerateInvoiceCtrl {
    public MARSInvoiceHelper.InvoicePDF currentRecord {get; set;}
    public String signature {get; set;}
    public String skipF42s {get; set;}
    public Invoice__c invoice {get; set;}
    public MARS_GenerateInvoiceCtrl() {
        Invoice__c invoiceRecord = [SELECT Id,Invoice_Json__c,Printed_Title__c,Printed_Name__c,Approved_Date__c,Name,Invoice_Number_For_Json__c FROM Invoice__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')];
        skipF42s = ApexPages.currentPage().getParameters().get('skipF42s');
        invoice = invoiceRecord;
        currentRecord = (MARSInvoiceHelper.InvoicePDF)JSON.deserialize(invoiceRecord.Invoice_Json__c, MARSInvoiceHelper.InvoicePDF.class);
        if(skipF42s == 'Yes') {
            currentRecord.f24RecordsList = new  List<MARSInvoiceHelper.F24Records>();
        }
        List<ContentVersion> signDco = getContentVersions(new List<String>{ApexPages.currentPage().getParameters().get('id')});
        if(signDco.size() > 0)
            signature ='/sfc/servlet.shepherd/version/download/'+signDco[0].Id;
    }
    private static List<ContentVersion> getContentVersions(List<String> recordIds) {

        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true AND Title LIKE 'Signature%' order by ContentModifiedDate desc];
    }
   
}