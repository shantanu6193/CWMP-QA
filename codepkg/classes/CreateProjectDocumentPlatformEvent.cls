/**
 * Created by Pankaj on 20-11-2020.
 *
 * @description - This class is responsible to add dependant documents to project.
 *                  Document will get copied from Program document.
 *                  todo - change this class to platform event
 */

public without sharing class CreateProjectDocumentPlatformEvent {
    List<Document__c> documentsToInsert = new List<Document__c>();
    Map<Id, Set<Id>> programWithProjectIds = new Map<Id, Set<Id>>();

    public void handle(Set<Id> recordIds) {
        if(recordIds == null || recordIds.size() == 0) return;


        List<Project__c> projects = [SELECT Program_Name__c FROM Project__c WHERE Id IN :recordIds];
        List<String> programIds = new List<String>();

        for (Project__c project : projects) {
            if(programWithProjectIds.get(project.Program_Name__c) == null) {
                programWithProjectIds.put(project.Program_Name__c, new Set<Id>());
            }
            programWithProjectIds.get(project.Program_Name__c).add(project.Id);
            programIds.add(project.Program_Name__c);
        }

        Map<Id, Program__c> programs = new Map<Id, Program__c>( [SELECT Id,
                    (SELECT Id, Project_Document_Filter_Clause__c, Document_Name__c, Is_Required__c, Document_Category__c, Parent_Object__c , Document_Format__c
                        FROM Program_Documents__r where Parent_Object__c=: ALS_CONSTANTS.PDocument_ParentObject_Project)
                    FROM Program__c WHERE Id IN :programIds] );
        for (Program__c program : programs.values()) {
            if(programWithProjectIds.get(program.Id) == null) continue;
            for (Program_Document__c programDocument : program.Program_Documents__r) {
             //   if (programDocument.Parent_Object__c == 'Project') {
                    getDocumentsForProject(programDocument, program);
            //    }
            }
        }
        insert documentsToInsert;

    }

    private void getDocumentsForProject(Program_Document__c programDocument, Program__c program) {
        Set<Id> projectIds = new Set<Id>();
        if (programDocument.Project_Document_Filter_Clause__c == null) {
            projectIds = programWithProjectIds.get(program.Id);
        } else {
            projectIds = programWithProjectIds.get(program.Id);
            List<Project__c> projects2 = Database.query('Select Id From Project__c Where Id In:projectIds AND '
                    + programDocument.Project_Document_Filter_Clause__c);
            projectIds = new Set<Id>();
            for (Project__c project : projects2) {
                projectIds.add(project.Id);
            }
        }
        if(projectIds == null || projectIds.size() == 0) return ;
        
        for(String projectId : projectIds) {
            Document__c docToInsert = new Document__c();
            docToInsert.Document_Format__c = programDocument.Document_Format__c;
            docToInsert.Document_Name__c = programDocument.Document_Name__c;
            docToInsert.Document_Type__c = programDocument.Document_Category__c;//Disaster
            docToInsert.ProjectId__c = projectId;
            docToInsert.Is_Required__c = programDocument.Is_Required__c;
            documentsToInsert.add(docToInsert);
        }
    }

}