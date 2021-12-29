/***********************************************************************************************************************************
* Class Name   : HistoryTrackerHelper
* Description  : This helper class for history tracker fields are adding or updating
* Author       : Pankaj
* Created On   : 08/03/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              08/03/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HistoryTrackerHelper {

    /***********************************************
    * Method Name : processFieldTracking
    * Author : Pankaj
    * Inputs : -
    * Description: This method process the field tracking
    *********************************************/
    public static void processFieldTracking() {
        System.debug('Insert ------'+Trigger.isInsert);
        System.debug('Update ------'+Trigger.isUpdate);
        List<History_Tracker__c> fieldHistoryToUpsert = new List<History_Tracker__c>();
        if (Trigger.isInsert) {
            fieldHistoryToUpsert.addAll(HistoryTrackerHelper.trackAddition());
        } else if (Trigger.isUpdate) {
            fieldHistoryToUpsert.addAll(HistoryTrackerHelper.trackUpdate());
        } else if (Trigger.isDelete) {
            //fieldHistoryToInsert.addAll(HistoryTrackerHelper.trackDeletion());
        }
        System.debug('fieldHistoryToUpsert---' + fieldHistoryToUpsert);
        List<History_Tracker__c> fieldHistoryToUpsertList = new List<History_Tracker__c>();
        Set<Id> fieldHistoryIdSet = new  Set<Id>();
        for(History_Tracker__c tracker:fieldHistoryToUpsert){
            if(tracker.Id == null){
                fieldHistoryToUpsertList.add(tracker);
            }else{
               if(fieldHistoryIdSet.contains(tracker.Id) ==  false){
                   fieldHistoryIdSet.add(tracker.Id);
                   fieldHistoryToUpsertList.add(tracker);
               }
            }
        }
        upsert fieldHistoryToUpsertList;
        shareHistoryTrackerRecordToCommunityGroupBasedOnCounty(fieldHistoryToUpsertList);
    }

    /***********************************************
    * Method Name : trackAddition
    * Author : Pankaj
    * Inputs : -
    * Description: This method inserting\adding the field tracking data and return list of History Tracking
    *********************************************/
    private static List<History_Tracker__c> trackAddition() {
        List<History_Tracker__c> listFieldHistory = new List<History_Tracker__c>();
        Map<String, List<History_Tracker_Field_Configuration__mdt>> trackerConfigsObjectToFieldMap =getSObjectMetadata();
        Map<String, String> trackerConfigsObjectMap = getSObjectMetadataLookupObject();

        for(Sobject sobj : Trigger.New) {
            Id objId = sobj.Id;
            String objectTypeName = sobj.getSObjectType().getDescribe().getName();
            System.debug('objectTypeName------ ' + objectTypeName);

            if(trackerConfigsObjectToFieldMap.containsKey(objectTypeName)){
                for(History_Tracker_Field_Configuration__mdt fieldToProcess :trackerConfigsObjectToFieldMap.get(objectTypeName)) {
                History_Tracker__c toInsertHistoryTracker = new History_Tracker__c();
                toInsertHistoryTracker.Object_Name__c = objectTypeName;
                // CH01 Start
                toInsertHistoryTracker.Field_Name__c = fieldToProcess.MasterLabel;
                if(trackerConfigsObjectMap.containsKey(objectTypeName)){
                    toInsertHistoryTracker.put(trackerConfigsObjectMap.get(objectTypeName),objId);
                }

                 // CH01 End

                toInsertHistoryTracker.Field_API_Name__c = fieldToProcess.Field_API_Name__c;
                toInsertHistoryTracker.RecordId__c = objId;
                toInsertHistoryTracker.Old_Value__c = getFieldValueAsString(sobj,fieldToProcess.Field_API_Name__c);
                /* if(String.isNotEmpty(fieldToProcess.Message_Field_API_Name__c)){
                    toInsertHistoryTracker.Message__c = getFieldValueAsString(sobj,fieldToProcess.Message_Field_API_Name__c);
                }*/
                listFieldHistory.add(toInsertHistoryTracker);
            }

            }
        }
        return  listFieldHistory;
    }

    /***********************************************
    * Method Name : trackUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method updating the field tracking data and return list of History Tracking
    *********************************************/
    private static List<History_Tracker__c> trackUpdate() {
        List<History_Tracker__c> listFieldHistory = new List<History_Tracker__c>();
        Map<String, List<History_Tracker_Field_Configuration__mdt>> trackerConfigsObjectToFieldMap = getSObjectMetadata();
        Map<String, String> trackerConfigsObjectMap = getSObjectMetadataLookupObject();

        // Map<String, List<History_Tracker_Field_Configuration__mdt>> recordIdToFieldsInfo = new Map<String, List<History_Tracker_Field_Configuration__mdt>>();
        Map<String,List<String>> recordToChangedFieldsMap = new Map<String, List<String>>(); // Object ID  , Fields updated
        Map<String, list<String>> recordValueMap = new Map<String, List<String>>(); // Record Id  + Field name , Value
        Map<String, list<String>> recordMessageValueMap = new Map<String,list<String>>(); // Record Id  + Field name + Message Field Name , Value
        //CH0 start
        Map<String,List<String>> recordToChangedFieldsNameMap = new Map<String, List<String>>(); // Object ID  , Fields Name updated
        Map<String,String> updatedFieldsNameObjLabelMap = new Map<String,String>();
        //CH0 End
        String objectTypeName='';
        for (Sobject sobj : Trigger.New) {
            Id objId = sobj.Id;
            //String objectTypeName = sobj.getSObjectType().getDescribe().getName();
            objectTypeName = sobj.getSObjectType().getDescribe().getName();
            System.debug('objectTypeName' + objectTypeName);

            //trackerConfigsObjectToFieldMap - Holds all objects that needs tracking and Respective Fields
            if (trackerConfigsObjectToFieldMap.containsKey(objectTypeName)) {
                List<String> updatedFieldsOnRecordToTrack = new List<String>();
                //CH0 start
                List<String> updatedFieldsNameOnRecordToTrack = new List<String>();
                //CH0 End
                for (History_Tracker_Field_Configuration__mdt fieldToProcess : trackerConfigsObjectToFieldMap.get(objectTypeName)) {

                    String fieldName = fieldToProcess.Field_API_Name__c;
                    //CH0 start
                    String fieldLabel = fieldToProcess.MasterLabel;
                    //CH0 End
                    if (sobj.get(fieldName) != Trigger.oldMap.get(objId).get(fieldName)) {
                        updatedFieldsOnRecordToTrack.add(fieldName);
                        updatedFieldsNameOnRecordToTrack.add(fieldLabel);
                        updatedFieldsNameObjLabelMap.put(objId+'-'+fieldName,fieldLabel);
                        List<String> fieldValues =new List<String>();
                        String newVal = getFieldValueAsString(sobj,fieldName);
                        fieldValues.add(newVal);
                        //fieldValues.add(sobj.get(fieldName).toString());

                        String oldVal = getFieldValueAsString(Trigger.oldMap.get(objId),fieldName);
                        fieldValues.add(oldVal);
                        //fieldValues.add(Trigger.oldMap.get(objId).get(fieldName).toString());

                        recordValueMap.put(objId+'-'+fieldName,fieldValues);
                        List<String> fieldMessageValues =new List<String>();
                        if(fieldToProcess.Message_Field_API_Name__c!=null && String.isNotEmpty(fieldToProcess.Message_Field_API_Name__c) && sobj.get(fieldToProcess.Message_Field_API_Name__c) != null) {
                            fieldMessageValues.add(sobj.get(fieldToProcess.Message_Field_API_Name__c).toString());
                            //recordMessageValueMap.put(objId+'-'+fieldName+'-'+fieldToProcess.Message_Field_API_Name__c,fieldMessageValues);
                            recordMessageValueMap.put(objId + '-' + fieldName, fieldMessageValues);
                        }
                    }
                }

                if (updatedFieldsOnRecordToTrack.size() > 0) {
                    recordToChangedFieldsMap.put(objId, updatedFieldsOnRecordToTrack);
                }
                //CH0 Start
                if (updatedFieldsNameOnRecordToTrack.size() > 0) {
                    recordToChangedFieldsNameMap.put(objId, updatedFieldsNameOnRecordToTrack);
                }
                //CH0 End

            }
        }

        List<History_Tracker__c> toUpdate = [SELECT Id,New_Value__c,Old_Value__c,Duration__c,End_Date__c,Field_API_Name__c,RecordId__c,Message__c, HH_Application__c
                                                FROM History_Tracker__c
                                                WHERE RecordId__c IN : recordToChangedFieldsMap.keySet() AND Is_Latest_Record__c = TRUE ];
        Map<String, History_Tracker__c> existingHistoriesToUpdate =new Map<String, History_Tracker__c>();


        List<History_Tracker__c> HistoriesToUpsert =new List<History_Tracker__c>();

        for (History_Tracker__c record : toUpdate) {
            existingHistoriesToUpdate.put(record.RecordId__c+'-'+record.Field_API_Name__c,record);
        }

        for(String recordIdToProcess : recordToChangedFieldsMap.keySet()){
            List<String> recordsFieldNamesToProcess =recordToChangedFieldsMap.get(recordIdToProcess);
            for(String fieldName : recordsFieldNamesToProcess){
                if(existingHistoriesToUpdate.containsKey(recordIdToProcess+'-'+fieldName)){
                    History_Tracker__c toUpdateHistoryTracker = existingHistoriesToUpdate.get(recordIdToProcess+'-'+fieldName);
                    toUpdateHistoryTracker.New_Value__c = recordValueMap.get(recordIdToProcess+'-'+fieldName).get(0); //getFieldValueAsString(sobj,fieldToProcess.Field_API_Name__c);
                    toUpdateHistoryTracker.End_Date__c = Datetime.Now();

                    if(recordMessageValueMap.size()>0) {
                        toUpdateHistoryTracker.Message__c = recordMessageValueMap.get(recordIdToProcess + '-' + fieldName).get(0);
                    }
                    toUpdateHistoryTracker.Is_Latest_Record__c = False;
                    listFieldHistory.add(toUpdateHistoryTracker);

                    History_Tracker__c toInsertHistoryTracker = new History_Tracker__c();
                    toInsertHistoryTracker.Object_Name__c =  ((Id)recordIdToProcess).getSobjectType().getDescribe().getName();
                    toInsertHistoryTracker.Field_API_Name__c = fieldName;
                    // CH01 Start

                    toInsertHistoryTracker.Field_Name__c = updatedFieldsNameObjLabelMap.get(recordIdToProcess+'-'+fieldName);
                    // for(String fieldLabel : recordToChangedFieldsNameMap.get(recordIdToProcess)){
                    // if(recordToChangedFieldsNameMap.containsKey(recordIdToProcess)){
                    //     toInsertHistoryTracker.Field_Name__c = fieldLabel;
                    // }
                    // }

                    if(trackerConfigsObjectMap.containsKey(objectTypeName)){
                        toInsertHistoryTracker.put(trackerConfigsObjectMap.get(objectTypeName),recordIdToProcess);
                    }

                    // CH01 End

                    toInsertHistoryTracker.RecordId__c = recordIdToProcess;
                    toInsertHistoryTracker.Old_Value__c = recordValueMap.get(recordIdToProcess+'-'+fieldName).get(0);
                    /*if(String.isNotEmpty(fieldToProcess.Message_Field_API_Name__c)){
                        toInsertHistoryTracker.Message__c = getFieldValueAsString(sobj,fieldToProcess.Message_Field_API_Name__c);
                    }*/
                    listFieldHistory.add(toInsertHistoryTracker);
                }else{
                    History_Tracker__c toInsertHistoryTracker = new History_Tracker__c();
                    toInsertHistoryTracker.Object_Name__c =  ((Id)recordIdToProcess).getSobjectType().getDescribe().getName();
                    toInsertHistoryTracker.Field_API_Name__c = fieldName;

                    // CH01 Start
//                    for(String fieldLabel : recordToChangedFieldsNameMap.get(recordIdToProcess)){
//                        if(recordToChangedFieldsNameMap.containsKey(recordIdToProcess)){
//                            toInsertHistoryTracker.Field_Name__c = fieldLabel;
//                        }
//                    }
                    toInsertHistoryTracker.Field_Name__c = updatedFieldsNameObjLabelMap.get(recordIdToProcess+'-'+fieldName);
                    if(trackerConfigsObjectMap.containsKey(objectTypeName)){
                        toInsertHistoryTracker.put(trackerConfigsObjectMap.get(objectTypeName),recordIdToProcess);
                    }


                    // CH01 End

                    toInsertHistoryTracker.RecordId__c = recordIdToProcess;
                    toInsertHistoryTracker.Old_Value__c = recordValueMap.get(recordIdToProcess+'-'+fieldName).get(0);
                    listFieldHistory.add(toInsertHistoryTracker);
                }
        }

        }

        return listFieldHistory;
    }

    /***********************************************
    * Method Name : getSObjectMetadata
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of History_Tracker_Field_Configuration__mdt metadata
    *********************************************/
    public static Map<String, List<History_Tracker_Field_Configuration__mdt>> getSObjectMetadata() {

        Map<String, List<History_Tracker_Field_Configuration__mdt>> trackerConfigsObjectToFieldMap = new Map<String, List<History_Tracker_Field_Configuration__mdt>>();
        List<History_Tracker_Configuration__mdt> trackerConfigs = new List<History_Tracker_Configuration__mdt>();
        trackerConfigs = [
                SELECT Id, Object_API_Name__c, (SELECT ID,Field_API_Name__c,Message_Field_API_Name__c,MasterLabel From Related_Fields__r)
                from History_Tracker_Configuration__mdt
                Where Enabled__c = true
        ];

        for (History_Tracker_Configuration__mdt configRecord : trackerConfigs) {
            if (configRecord.Related_Fields__r.size() > 0) {
                trackerConfigsObjectToFieldMap.put(configRecord.Object_API_Name__c, configRecord.Related_Fields__r);
            }
        }

        return trackerConfigsObjectToFieldMap;

    }

    /***********************************************
    * Method Name : getFieldValueAsString
    * Author : Pankaj
    * Inputs : Sobject record, String fieldAPIName
    * Description: This method return field value as string
    *********************************************/
    public static String getFieldValueAsString(Sobject record, String fieldAPIName) {
        String value = '';
        String objectAPIName = String.valueOf(record.getSObjectType());
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        if(record.get(fieldAPIName) == null) return value;

        Schema.DisplayType FldType = fieldMap.get(fieldAPIName).getDescribe().getType();
        String fieldType = String.valueof(FldType);
        if(fieldType == 'DateTime') {
            value = getFormattedDateTime(Datetime.valueOf(record.get(fieldAPIName)));//.format('yyyy-MM-dd HH:mm:ss');
        } else if(fieldType == 'Double' || fieldType == 'Currency'){
            value = getFormattedNumber(Double.valueOf(record.get(fieldAPIName)), fieldMap.get(fieldAPIName).getDescribe().getScale(),
                    (fieldType == 'Currency'));
        }else if(fieldType == 'Email'){
            value = '<a href="mailto:'+String.valueOf(record.get(fieldAPIName))+'">'+String.valueOf(record.get(fieldAPIName))+'</a>';
        }
        else {
            value = String.valueOf(record.get(fieldAPIName));
        }
        return value;
    }

    /***********************************************
    * Method Name : getFormattedDateTime
    * Author : Pankaj
    * Inputs : DateTime dateTimeToFormat
    * Description: This method return date in specified format as string
    *********************************************/
    public static String getFormattedDateTime(DateTime dateTimeToFormat) {
        // todo - add in constant
        return dateTimeToFormat.format('M/d/yyyy h:mm a z');
    }

    /***********************************************
    * Method Name : getFormattedNumber
    * Author : Pankaj
    * Inputs : Double val, Integer decimalScaleVal, Boolean isCurrency
    * Description: This method return formatted number as string
    *********************************************/
    public static String getFormattedNumber(Double val, Integer decimalScaleVal, Boolean isCurrency) {
        String formattedNo = '';
        System.debug('val-----' + val);
        if (val != null) {
            String format =  '###,###,###,##0';
            decimalScaleVal = decimalScaleVal == null ? 0 : decimalScaleVal;
            if (decimalScaleVal > 0) {
                format += '.';
            }
            for (Integer i=0; i<decimalScaleVal; i++) {
                format += '0';
            }
            List<String> args = new String[]{'0','number',format};
            formattedNo = String.format(val.format(), args);
            if(isCurrency == true) {
                formattedNo = '$' + formattedNo;
            }
        }
        return formattedNo;
    }

    /***********************************************
    * Method Name : getSObjectMetadataLookupObject
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of string from History_Tracker_Configuration__mdt metadata
    *********************************************/
    public static Map<String, String> getSObjectMetadataLookupObject() {
        Map<String, String> trackerConfigsObjectMap = new Map<String, String>();
        List<History_Tracker_Configuration__mdt> trackerConfigs = [SELECT Id, Object_API_Name__c,Lookup_API_Name__c from History_Tracker_Configuration__mdt
                                                                    Where Enabled__c = true];
        if (trackerConfigs.size() > 0) {
        for (History_Tracker_Configuration__mdt configRecord : trackerConfigs) {
                trackerConfigsObjectMap.put(configRecord.Object_API_Name__c, configRecord.Lookup_API_Name__c);
            }
        }
        return trackerConfigsObjectMap;
    }

    /***********************************************
    * Method Name : shareHistoryTrackerRecordToCommunityGroupBasedOnCounty
    * Author : Ricky
    * Inputs : - List<History_Tracker__c> insertedHistoryTrackerList - List of inserted History Tracker record.
    * Description: This method use to share the History tracker record with Community User group based on County of the Application,
    *                   When the History tracker record is related to CWMP Application.
    *              - Public group of the related County is fetched from County Config Metadata.
    *              - Reason for sharing the History Tracker Record is that We need it in report,
    *                   where it shows how many days an Application was in the particular Stage/Status.
    *********************************************/
    public static void shareHistoryTrackerRecordToCommunityGroupBasedOnCounty(List<History_Tracker__c> insertedHistoryTrackerList) {
        /** Collection to collect the History Tracker record if the it is related to CWMP Application. */
        List<History_Tracker__c> cwmpApplicationHistoryTrackerList = new List<History_Tracker__c>();
        /** Set collection to collect the CWMP Application Id in order to Fetch the Application record to get the related County Name. */
        Set<Id> cmapApplicationIds = new Set<Id>();
        /** Condition to check Null pointer exception for the list collection from method input. */
        if (insertedHistoryTrackerList?.size() > 0) {
            /** Iterating History tracker records in order to get the CWMP Application Ids and History Tracker record,
             * if the record is related to CWMP Application. */
            for (History_Tracker__c historyTrackerRecord : insertedHistoryTrackerList) {
                /** This condition is added to check if the record is related to CWMP Application and Is inserted.
                 *      (Because we dont need to share the record upon Updation)
                 * Condition Criteria - 1 & 2
                 * Condition 1 - CWMP Application Field is not null.
                 * Condition 2 - New Value in History Tracker record is null. */
                if (historyTrackerRecord.HH_Application__c != null
                        && historyTrackerRecord.New_Value__c == null) {
                    cwmpApplicationHistoryTrackerList.add(historyTrackerRecord);
                    cmapApplicationIds.add(historyTrackerRecord.HH_Application__c);
                }
            }
        }
        /** Condition to check Null pointer exception for the cwmpApplicationHistoryTrackerList collection. */
        if (cwmpApplicationHistoryTrackerList?.size() > 0) {
            /** Fetching CWP Application records in order to get the related County of the Application. */
            Map<Id, HH_Application__c> cwmpAppIdToAppRecordMap = new Map<Id, HH_Application__c>([SELECT Id, Name, County__c
                                                                        FROM HH_Application__c WHERE Id IN : cmapApplicationIds]);
            /** Set collection to collect the County Name of the CWMP Applications. */
            Set<String> countySet = new Set<String>();
            /** Set collection to store Public group API name in order to fetch the records. */
            Set<String> PublicGroupAPINameSet = new Set<String>();
            /** Map collection to collect the Public group API name with County Name as Key. */
            Map<String, String> countyNameToPublicGroupAPINameMap = new Map<String, String>();
            /** Map collection to to collect the Public group record with group PAI name as key. */
            Map<String, Group> groupAPINameToGroupRecordMap = new Map<String, Group>();
            /** List collection to collect the History Tracker Share records to insert. */
            List<History_Tracker__Share> historyTrackerShareRecordToInsertList = new List<History_Tracker__Share>();

            /** Iterating cwmpAppIdToAppRecordMap collection record in order to collect the County Name of the CWMP Application. */
            for (HH_Application__c cwmApplicationRecord : cwmpAppIdToAppRecordMap.values()) {
                if (cwmApplicationRecord.County__c != null) {
                    countySet.add(cwmApplicationRecord.County__c);
                }
            }
            /** Fetching County Config metadata records in order to get the Public group API names. */
            List<County_Config__mdt> countyConfigList = [SELECT Id, Label, Public_Group_API_Name__c
                                                            FROM County_Config__mdt WHERE Label IN : countySet
                                                            AND Application_Type__c =: HH_CONSTANTS.HH_Application_APIName_CountyConfig];
            /** Checking for null pointer exception and Iterating County Config records list,
             * In order to fetch the Public Group API names in order to fetch the Group records. */
            if (countyConfigList?.size() > 0) {
                for (County_Config__mdt countyConfig : countyConfigList) {
                    countyNameToPublicGroupAPINameMap.put(countyConfig.Label, countyConfig.Public_Group_API_Name__c);
                    PublicGroupAPINameSet.add(countyConfig.Public_Group_API_Name__c);
                }
            }
            /** Checking for null pointer Exception for PublicGroupAPINameSet collection
             * before Fetching the Group records and Arranging in Map collection with Group Developer name as Key. */
            if (PublicGroupAPINameSet?.size() > 0) {
                List<Group> groupRecordList = [SELECT Id, DeveloperName FROM Group
                                                                WHERE DeveloperName IN : PublicGroupAPINameSet AND Type = 'Regular'];
                if (groupRecordList?.size() > 0) {
                    for (Group groupRecord  : groupRecordList) {
                        groupAPINameToGroupRecordMap.put(groupRecord.DeveloperName, groupRecord);
                    }
                }
            }
            /** Iterating cwmpApplicationHistoryTrackerList collection,
             * In order to share the record with the related County of the CWMP Application record. */
            for (History_Tracker__c historyTrackerRecordToShare : cwmpApplicationHistoryTrackerList) {
                /** checking for null pointer exception for the related Public Group record before creating the share record data. */
                if (groupAPINameToGroupRecordMap?.get(countyNameToPublicGroupAPINameMap?.get(cwmpAppIdToAppRecordMap?.get(historyTrackerRecordToShare?.HH_Application__c)?.County__c))?.Id != null) {
                    /** Creating History tracker Share records. */
                    History_Tracker__Share historyTrackerShare = new History_Tracker__Share();
                    historyTrackerShare.ParentId = historyTrackerRecordToShare.Id;
                    historyTrackerShare.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;
                    historyTrackerShare.RowCause = History_Tracker__Share.RowCause.CWMP_Sharing__c;
                    historyTrackerShare.UserOrGroupId = groupAPINameToGroupRecordMap?.get(countyNameToPublicGroupAPINameMap?.get(cwmpAppIdToAppRecordMap?.get(historyTrackerRecordToShare?.HH_Application__c)?.County__c))?.Id;
                    historyTrackerShareRecordToInsertList.add(historyTrackerShare);
                }
            }
            /** Checking for null pointer exception for the historyTrackerShareRecordToInsertList collection before inserting. */
            if (historyTrackerShareRecordToInsertList?.size() > 0) {
                insert historyTrackerShareRecordToInsertList;
            }
        }
    }
}