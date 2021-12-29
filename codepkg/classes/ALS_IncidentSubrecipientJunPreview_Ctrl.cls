/**
 * Created by Sushant on 18-01-2021.
 */

public with sharing class ALS_IncidentSubrecipientJunPreview_Ctrl {
    @AuraEnabled(cacheable=true)
 public static Map<String, Object> getIncidentSubrecipientInfo(String masterRecordId ,String refreshDate){
        Map<String, Object> resultMap = new Map<String, Object>();
        Id masterRecordIdVersion = masterRecordId;
        String masterObjName = masterRecordIdVersion.getSObjectType().getDescribe().getName();
        String FieldName;
        if(masterObjName =='Account'){
            FieldName ='Account__c';
        }else if(masterObjName =='Incident__c'){
            FieldName ='Incident__c';
        }

        String query='Select Name,Id,Account__r.Name, Incident__r.Name, Stage__c From Incident_Subrecipient_Stage__c where '+FieldName+' = '+'\'' + masterRecordId + '\'';
        List<Incident_Subrecipient_Stage__c> getIncidentSubrecipient =Database.query(query);
        resultMap.put('incidentSubrecipient',getIncidentSubrecipient);
        return resultMap;
 }

}