/**
 * Created by Sushant on 07-01-2021.
 */

public with sharing class ALS_TransmittalPreviewController {
    //Reusable method for getting All fields of record
    public static List<String> getAllFields(String objectName) {
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<string> selectFields = new List<string>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());
            }
        }
        return selectFields;
    }
    @AuraEnabled
    //Get all Details of Related record Id
    public Static Map<String,Object> getDetails(String transmittalId) {
        String recordId =transmittalId;
        Map<String, Object> resultMap = new Map<String, Object>();
        List<String> TansmittalFieldsToQuery = getAllFields('Transmittal__c');
        TansmittalFieldsToQuery.add('ApplicantName__r.Name');
        TansmittalFieldsToQuery.add('ObligatedAgency__r.Name');
        TansmittalFieldsToQuery.add('ProgramName__r.Name');
        String query = 'Select ' + String.join(TansmittalFieldsToQuery, ', ')+' From Transmittal__c Where Id = \'' + recordId + '\'';
        Transmittal__c transmittal = Database.query(query);
        system.debug(transmittal);
        resultMap.put('TransmittalObj',transmittal);
        return resultMap;
    }

}