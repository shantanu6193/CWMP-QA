/**
 * Created by Sushant Patil on 10-06-2021.
 */

public without sharing class CustomDocumentCreateEdit {
    @AuraEnabled
    public static Map<String, Object> getDocumentInfo(String documentId,String masterRecordId){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<Document_Controller_Config__mdt> docControllerConfig = Document_Controller_Config__mdt.getall().values();//Get Records from Global Document Configuration Metadata
        Id recordId = masterRecordId;
        String objName = recordId.getSObjectType().getDescribe().getName();
        String className ;
        for(Document_Controller_Config__mdt mdt:docControllerConfig){
            if(mdt.Object_API_Name__c ==objName){
                className = mdt.Apex_Class_Name__c;
            }
        }
        if(className != null){
            Type type = Type.forName(className);
            DocumentUploadInterface docInterface = (DocumentUploadInterface) type.newInstance();
            resultMap.put('documentRecord', docInterface.executeEditAction(documentId));
        }else{
        String documentRecordId = documentId;
        Set<String> documentFields = new Set<String>();
        Map<String, Schema.SObjectField> documentFieldMap = Document__c.SObjectType.getDescribe().fields.getMap();
        documentFields.addAll(documentFieldMap.keySet());//Get all of the fields from Document__c object
        documentFields.add('Uploaded_By__r.Name');
        String queryDocs = 'Select ' + String.join((Iterable<String>) documentFields, ',')+' FROM Document__c WHERE Id ='+'\'' + documentRecordId +'\'';
        Document__c document =Database.query(queryDocs);
        resultMap.put('documentRecord', document);
        }
        return resultMap;
    }
    @AuraEnabled
    public static void saveDocumentInfo(String documentDetail , Boolean isEdit){
        Document__c documentRecord = (Document__c) JSON.deserialize(documentDetail, Document__c.class);//Deserialization of Document Record
       if(documentRecord != null && isEdit == false ){
           try{
               insert documentRecord;
           }catch (Exception e){
               throw new AuraHandledException('Insertion Failed..'+e);
           }
       }
       else if(documentRecord != null && isEdit == true ){
           try{
               update documentRecord;
           }catch (Exception e){
               throw new AuraHandledException('Failed to Update..'+e);
           }
       }
    }
}