/**
         * Created by nehab
         */

public with sharing class ALS_ProjectsPreviewController_Ctrl {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProjectsInfo(String masterRecordId, String refreshDate, String srcObject){//Get details of selected record
        Map<String, Object> resultMap = new Map<String, Object>();
        String query = ' Select Id, Name, Project_Name__r.Name, AccountContactJunction__r.Name, Project_Role_Global_List__c, AccountContactJunction__r.Contact_Role_Global_List__c, AccountContactJunction__c,' +
                ' AccountContactJunction__r.Contact_Name__r.Name,AccountContactJunction__r.Contact_Name__r.Title, AccountContactJunction__r.Account_Name__r.Name, Owner.Name' +
                ' from Project_Role__c where ';

        switch on srcObject {
            when 'Incident' {
                query += ' Incident__c = :masterRecordId ';
            }
            when 'Incident-Subrecipient' {
                query += ' Incident_Subrecipient_Summary__c = :masterRecordId ';
            }
            when 'Subrecipient' {
                query += ' Subrecipient__c = :masterRecordId ';
            }
            when else {
                query += ' Project_Name__c = : masterRecordId ';
            }
        }

        List<Project_Role__c> getProjectsList = Database.query(query);

        resultMap.put('projectJunctions',getProjectsList);
        return resultMap;
    }

     @AuraEnabled
     //Delete Selected Record
     public Static Map<String,Object> deleteRecords(String recordToDelete){
     String objId = recordToDelete;
     Map<String, Object> resultMap = new Map<String, Object>();
     Project_Role__c projectsRole =[SELECT Id FROM Project_Role__c WHERE Id = : objId ] ;
     if (projectsRole != null) {
        Delete projectsRole;
     }
     return null;
    }
}