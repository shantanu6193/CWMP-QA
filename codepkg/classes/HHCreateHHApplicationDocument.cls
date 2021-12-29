/**
 * Created by StackNexus Admin on 24-08-2021.
 */

public without sharing class HHCreateHHApplicationDocument {

    List<Document__c> documentsToInsert = new List<Document__c>(); //To collect the list of Document to Insert...
    Map<Id, Set<Id>> programWithHHApplicationIds = new Map<Id, Set<Id>>(); //To store the Program with the Payment Request Ids which is inserted...
    public void handle(Set<Id> recordIds) {
        if(recordIds == null || recordIds.size() == 0) return;


        List<HH_Application__c> applications = [SELECT Program__c FROM HH_Application__c WHERE Id IN :recordIds];
        List<String> programIds = new List<String>();

        for (HH_Application__c Apps : applications) {
            if(programWithHHApplicationIds.get(Apps.Program__c) == null) {
                programWithHHApplicationIds.put(Apps.Program__c, new Set<Id>());
            }
            programWithHHApplicationIds.get(Apps.Program__c).add(Apps.Id);
            programIds.add(Apps.Program__c);
        }

        Map<Id, Program__c> programs = new Map<Id, Program__c>( [SELECT Id,
        (SELECT Id, Document_Name__c, Is_Required__c, Document_Category__c, Document_Creation_Method__c, Parent_Object__c , Document_Format__c
        FROM Program_Documents__r where Parent_Object__c=: HH_CONSTANTS.HH_Program_Document_ParentObject_Name)
        FROM Program__c WHERE Id IN :programIds] );
        for (Program__c program : programs.values()) {
            if(programWithHHApplicationIds.get(program.Id) == null) continue;
            for (Program_Document__c programDocument : program.Program_Documents__r) {
                getDocumentsForHHApplication(programDocument, program);
            }
        }
        insert documentsToInsert;
    }

    private void getDocumentsForHHApplication(Program_Document__c programDocument,Program__c program) {
        Set<Id> hhApplicationIds = new Set<Id>();
        //if (programDocument.Project_Document_Filter_Clause__c == null) {
            hhApplicationIds = programWithHHApplicationIds.get(program.Id);
        /*} else {
            hhApplicationIds = programWithHHApplicationIds.get(program.Id);
            List<HH_Application__c> App2 = Database.query('Select Id From HH_Application__c Where Id In:hhApplicationIds AND '
                    + programDocument.Project_Document_Filter_Clause__c);
            hhApplicationIds = new Set<Id>();
            for (HH_Application__c App : App2) {
                hhApplicationIds.add(App.Id);
            }
        }*/
        if(hhApplicationIds == null || hhApplicationIds.size() == 0) return ;

        for(String hhAppId : hhApplicationIds) {
            Document__c docToInsert = new Document__c();
            docToInsert.Document_Format__c = programDocument.Document_Format__c;
            docToInsert.Document_Name__c = programDocument.Document_Name__c;
            docToInsert.Document_Type__c = programDocument.Document_Category__c;
            docToInsert.HH_Application__c = hhAppId;
            docToInsert.Document_Creation_Method__c = programDocument.Document_Creation_Method__c;
            docToInsert.Is_Required__c = programDocument.Is_Required__c;
            documentsToInsert.add(docToInsert);
        }
    }
}