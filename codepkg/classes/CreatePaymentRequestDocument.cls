public without sharing class CreatePaymentRequestDocument {
    List<Document__c> documentsToInsert = new List<Document__c>(); //To collect the list of Document to Insert...
    Map<Id, Set<Id>> programWithPaymentRequestIds = new Map<Id, Set<Id>>(); //To store the Program with the Payment Request Ids which is inserted...
    List <Id> recordIds = new List<Id>();
    //recordIds.add('a0Y35000000noXuEAI');

    public void handle(Set<Id> recordIds) {
        //Fetching all the Payment Requests whose Id are present in recordId collection...
        List<Payment_Request__c> paymentRequests = [SELECT Id ,Project__r.Program_Name__c FROM Payment_Request__c WHERE Id IN :recordIds];
        List<String> programIds = new List<String>();

        //Adding the value to the "programWithPaymentRequestIds" collection.....
        for (Payment_Request__c paymentRequestToProcess : paymentRequests) {
        if(programWithPaymentRequestIds.get(paymentRequestToProcess.Project__r.Program_Name__c) == null) {
        programWithPaymentRequestIds.put(paymentRequestToProcess.Project__r.Program_Name__c, new Set<Id>());
        }
        programWithPaymentRequestIds.get(paymentRequestToProcess.Project__r.Program_Name__c).add(paymentRequestToProcess.Id);
            programIds.add(paymentRequestToProcess.Project__r.Program_Name__c);
        }

        //Selecting the Program and associated Program Documents which is to be created on Payment Request...
        Map<Id, Program__c> programs = new Map<Id, Program__c>( [SELECT Id,
        (SELECT Id, Project_Document_Filter_Clause__c, Document_Name__c,Is_Required__c,  Document_Category__c, Parent_Object__c,Document_Format__c
        FROM Program_Documents__r where Parent_Object__c=: ALS_CONSTANTS.PDocument_ParentObject_PR)
        FROM Program__c WHERE Id IN :programIds] );

        for (Program__c program : programs.values()) {
        if(programWithPaymentRequestIds.get(program.Id) == null) continue;
        for (Program_Document__c programDocument : program.Program_Documents__r) {
            getDocumentsForPaymentRequest(programDocument, program);
        }
        }

        insert documentsToInsert;

    }

    private void getDocumentsForPaymentRequest(Program_Document__c programDocument, Program__c program) {
        Set<Id> paymentRequestIds = new Set<Id>();
        if (programDocument.Project_Document_Filter_Clause__c == null) {
        paymentRequestIds = programWithPaymentRequestIds.get(program.Id);
        }else {
        paymentRequestIds = programWithPaymentRequestIds.get(program.Id);
        List<Payment_Request__c> prList = Database.query('Select Id From Payment_Request__c Where Id In:paymentRequestIds AND '
        + programDocument.Project_Document_Filter_Clause__c);
        paymentRequestIds = new Set<Id>();
        for (Payment_Request__c pr : prList) {
        paymentRequestIds.add(pr.Id);
        }
    }

        if(paymentRequestIds == null || paymentRequestIds.size() == 0) return ;
        //Creating the Document for Payment Request by fetching the data from Program Document.....
        for(String prId : paymentRequestIds) {
            Document__c docToInsert = new Document__c();
            docToInsert.Document_Format__c = programDocument.Document_Format__c;
            docToInsert.Document_Name__c = programDocument.Document_Name__c;
            docToInsert.Document_Type__c = programDocument.Document_Category__c;//Disaster
            docToInsert.PaymentRequest__c = prId;
            docToInsert.Is_Required__c = programDocument.Is_Required__c;
            documentsToInsert.add(docToInsert); //Adding document record to collection to insert...
        }
    }
}