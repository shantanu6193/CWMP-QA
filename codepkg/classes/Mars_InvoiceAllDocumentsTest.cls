@isTest
public class Mars_InvoiceAllDocumentsTest {

    
    @isTest
    static void test() {
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Incident__c inci = new Incident__c();
        inci.Name = 'testIncident';
        insert inci;
        
        F42_Entry__c f42EntryRec = new F42_Entry__c();
        f42EntryRec.Name = 'testf42EntryRec';
        f42EntryRec.Account__c = acc.Id;
        insert f42EntryRec;
        
        F42__c f42Rec = new F42__c();
        f42Rec.Account__c = acc.Id;
        f42Rec.Incident__c = inci.Id;
        f42Rec.F42_Entry__c = f42EntryRec.Id;
        f42Rec.Strike_Team__c = 'test team';
        f42Rec.Incident_Request_Number__c = '4321';
        f42Rec.DI_Committed_to_Incident_Date__c = System.today();
        f42Rec.DI_Redispatched_Date__c = System.today() + 10;
        insert f42Rec;
        Incident__c incident = new Incident__c();
        incident.Name = 'testIncident';
        incident.Description__c = 'testIncident';
        insert incident;
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = acc.Id;
        invoice.Incident__c = incident.Id;
        invoice.Name = 'testInvoice';
        insert invoice;
        
        F_42_Invoices__c child = new F_42_Invoices__c();
        child.F_42__c = f42Rec.Id;
        child.Invoice__c = invoice.Id;
        insert child;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = f42EntryRec.Id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = f42Rec.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        MARS_Invoice_AllDocuments.getAllRelatedFiles(invoice.Id);
    }
}