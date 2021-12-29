/**
 * Created by Pankaj on 2021-06-06.
 */

public without sharing class DocumentGeneratorCtrl {

    @AuraEnabled(Cacheable=true)
    public static List<Document_Generation_Config__mdt> getDocumentConfig(String moduleName, String filterCriteria, String filterCriteria2, String recordId) {
        System.debug('Provided Module Name===='+moduleName);
        String filterCriteriaValue1; // Variable to store the Actual value of the field used in filter criteria of the Lightning record page.
        String filterCriteriaValue2; // Variable to store the Actual value of the field used in filter criteria 2 of the Lightning record page.
        Id recordIds= recordId; // variable to store the current record Id passes from LWC.
        String objectAPIName = recordIds.getSobjectType().getDescribe().getName(); // Fetching the object API name of the current record.
        // Query string to fetch the current object record with the fields used in Filter criteria.
        String stringQuery ='Select Id';
        if(String.isNotBlank(filterCriteria)){
            stringQuery += ', '+filterCriteria;
        }
        if(String.isNotBlank(filterCriteria2)){
            stringQuery += ', ' + filterCriteria2 ;
        }
        stringQuery += ' FROM ' +objectAPIName+' where Id =\''+recordIds+'\'';
        System.debug('stringQuery Val============'+stringQuery);
        SObject queryResult = Database.query(stringQuery); // Querying the current record data.

        // Fetching the value of field which is used in first filter criteria passes from current record page component.
        if(String.isNotBlank(filterCriteria)){
        filterCriteriaValue1 = String.valueOf(queryResult.get(filterCriteria));
        }
        
        // Fetching the value of field which is used in second filter criteria passes from current record page component.
        if(String.isNotBlank(filterCriteria2)){
        filterCriteriaValue2 = String.valueOf(queryResult.get(filterCriteria2));
        }
        

        // Preparing query string for Querying the Docu gen metadata.
        String query = 'SELECT Doc_Generate_URL__c, MasterLabel, Module__c, Id, Primaray_Object_API_Name__c, Primary_Object_Label__c, Primaray_Object_Filter_Clauses__c, Document_Name__c, Filter_Criteria2__c FROM Document_Generation_Config__mdt WHERE Module__c = \'' + moduleName + '\'';
        // Adding first filter condition in Query by checking null pointer exception.
        if (filterCriteriaValue1 != null) {
            query += ' AND Filter_Criteria__c = \''+ filterCriteriaValue1 + '\'';
        }
        // Adding second filter condition in Query by checking null pointer exception.
        if (filterCriteriaValue2 != null) {
            query += ' AND ((Filter_Criteria2__c != NULL AND Filter_Criteria2__c = \''+ filterCriteriaValue2 + '\') OR Filter_Criteria2__c = NULL)';
        }

        // Querying the metadata and return the list to page.
        List<Document_Generation_Config__mdt> documentGenerationConfigs = Database.query(query);
        return documentGenerationConfigs;
    }

    /*@AuraEnabled(Cacheable=true)
    public static List<Document_Generation_Config__mdt> getDocumentConfigOld(String moduleName,String filterCriteria,String recordId) {
        System.debug('Provided Module Name===='+moduleName);
        String filterCriteriaValue1;
        Id recordIds= recordId;
        String objectAPIName = recordIds.getSobjectType().getDescribe().getName();
        String stringQuery ='Select Id, '+filterCriteria+' FROM ' +objectAPIName+' where Id =\''+recordIds+'\'';
        SObject queryResult = Database.query(stringQuery);

        filterCriteriaValue1 = String.valueOf(queryResult.get(filterCriteria));

        String query = 'SELECT Doc_Generate_URL__c, MasterLabel, Module__c, Id, Primaray_Object_API_Name__c, Primary_Object_Label__c, Primaray_Object_Filter_Clauses__c, Document_Name__c FROM Document_Generation_Config__mdt WHERE Module__c = \'' + moduleName + '\'';
        if (filterCriteriaValue1 != null) {
            query += ' AND Filter_Criteria__c = \''+ filterCriteriaValue1 + '\'';
        }
        List<Document_Generation_Config__mdt> documentGenerationConfigs = Database.query(query);

        return documentGenerationConfigs;
    }*/

    @AuraEnabled()
    public static Map<String,String> getDocuSignUrl(String docId, String SourceID){
        System.debug('Record Val==='+SourceID);
        String primaryValObj = 'false';
        String relObj1ValObj = 'false';
        String relObj2ValObj = 'false';
        String relObj3ValObj = 'false';
        Map<String,String> resultMap = new Map<String,String>();
        List<Document_Generation_Config__mdt> documentGenerationConfigs = [SELECT Doc_Generate_URL__c,MasterLabel,Id,
                Primaray_Object_API_Name__c,Primary_Object_Label__c,
                Primaray_Object_Filter_Clauses__c,	Related_Object1_API_Name__c, Related_Object1_Label__c,
                Related_Object1_Filter_Clauses__c, Related_Object2_API_Name__c, Related_Object2_Filter_Clauses__c,
                Related_Object2_Label__c, 	Related_Object3_API_Name__c, Related_Object3_Filter_Clauses__c,
                Related_Object3_Label__c,Document_Name__c
        FROM Document_Generation_Config__mdt
        WHERE Id=:docId];
        PageReference pageRef = new PageReference(documentGenerationConfigs[0].Doc_Generate_URL__c);
        //  pageRef.getParameters().put('{RecordId}',SourceID);
        //  pageRef.getParameters().put('Project__c.Id',SourceID);
        // Getting of Data from Sobject.....
        Id reCId = Id.valueOf(SourceID);
        String sobjName = reCId.getSobjectType().getDescribe().getName();
        if(String.isNotBlank(documentGenerationConfigs[0].Primaray_Object_API_Name__c)){
            String dynPrimarayQuery = 'SELECT Id, '+sobjName+'  FROM '+ documentGenerationConfigs[0].Primaray_Object_API_Name__c +' WHERE '+sobjName+'=\'' + reCId + '\'';
            System.debug('dynSoqlQuery Val======'+dynPrimarayQuery);

            List<SObject> sobjValLst = Database.query(dynPrimarayQuery);
            System.debug('dynSoqlQuery Val======'+sobjValLst);
            if(sobjValLst.size() > 0){
                primaryValObj = 'true';
            }
        }

        if(String.isNotBlank(documentGenerationConfigs[0].Related_Object1_API_Name__c)){
            String dynRelObj1Query = 'SELECT Id, '+sobjName+'  FROM '+ documentGenerationConfigs[0].Related_Object1_API_Name__c +' WHERE '+sobjName+'=\'' + reCId + '\'';
            System.debug('dynSoqlQuery Val======'+dynRelObj1Query);

            List<SObject> sobjValLst = Database.query(dynRelObj1Query);
            System.debug('dynSoqlQuery Val======'+sobjValLst);
            if(sobjValLst.size() > 0){
                relObj1ValObj = 'true';
            }
        }

        if(String.isNotBlank(documentGenerationConfigs[0].Related_Object2_API_Name__c)){
            String dynRelObj2Query = 'SELECT Id, '+sobjName+'  FROM '+ documentGenerationConfigs[0].Related_Object2_API_Name__c +' WHERE '+sobjName+'=\'' + reCId + '\'';
            System.debug('dynSoqlQuery Val======'+dynRelObj2Query);

            List<SObject> sobjValLst = Database.query(dynRelObj2Query);
            System.debug('dynSoqlQuery Val======'+sobjValLst);
            if(sobjValLst.size() > 0){
                relObj2ValObj = 'true';
            }
        }

        if(String.isNotBlank(documentGenerationConfigs[0].Related_Object3_API_Name__c)){
            String dynRelObj3Query = 'SELECT Id, '+sobjName+'  FROM '+ documentGenerationConfigs[0].Related_Object3_API_Name__c +' WHERE '+sobjName+'=\'' + reCId + '\'';
            System.debug('dynSoqlQuery Val======'+dynRelObj3Query);

            List<SObject> sobjValLst = Database.query(dynRelObj3Query);
            System.debug('dynSoqlQuery Val======'+sobjValLst);
            if(sobjValLst.size() > 0){
                relObj3ValObj = 'true';
            }
        }
        resultMap.put('pageRefURL', pageRef.getUrl());
        resultMap.put('Primaray_Object_API_Name__c', documentGenerationConfigs[0].Primaray_Object_API_Name__c);
        resultMap.put('ShowPrimarayLookup', primaryValObj);
        resultMap.put('Primary_Object_Label__c', documentGenerationConfigs[0].Primary_Object_Label__c);
        resultMap.put('Primaray_Object_Filter_Clauses__c', documentGenerationConfigs[0].Primaray_Object_Filter_Clauses__c);
        resultMap.put('Related_Object1_API_Name__c', documentGenerationConfigs[0].Related_Object1_API_Name__c);
        resultMap.put('ShowRelObj1Lookup', relObj1ValObj);
        resultMap.put('Related_Object1_Label__c', documentGenerationConfigs[0].Related_Object1_Label__c);
        resultMap.put('Related_Object1_Filter_Clauses__c', documentGenerationConfigs[0].Related_Object1_Filter_Clauses__c);
        resultMap.put('Related_Object2_API_Name__c', documentGenerationConfigs[0].Related_Object2_API_Name__c);
        resultMap.put('ShowRelObj2Lookup', relObj2ValObj);
        resultMap.put('Related_Object2_Label__c', documentGenerationConfigs[0].Related_Object2_Label__c);
        resultMap.put('Related_Object2_Filter_Clauses__c', documentGenerationConfigs[0].Related_Object2_Filter_Clauses__c);
        resultMap.put('Related_Object3_API_Name__c', documentGenerationConfigs[0].Related_Object3_API_Name__c);
        resultMap.put('ShowRelObj3Lookup', relObj3ValObj);
        resultMap.put('Related_Object3_Label__c', documentGenerationConfigs[0].Related_Object3_Label__c);
        resultMap.put('Related_Object3_Filter_Clauses__c', documentGenerationConfigs[0].Related_Object3_Filter_Clauses__c);

        return resultMap;
    }

    @AuraEnabled
    public static void updateRelatedObj(String relatedObj1Id, String relatedObj2Id, String relatedObj3Id,
            String defaultRecordId, String primaryRecId, String seclectedDocId){
        try {
            List<Document_Generation_Config__mdt> documentGenerationConfigs = [SELECT Id, Module__c
            FROM Document_Generation_Config__mdt
            WHERE Id=:seclectedDocId];
            String moduleName = documentGenerationConfigs[0].Module__c;
            System.debug('Module Names.....'+moduleName);
            if(moduleName == 'REAL'){
                realAwardUpdation(relatedObj1Id, relatedObj2Id, relatedObj3Id, defaultRecordId, primaryRecId);
            }

            SObject sobj1;
            SObject sobj2;
            SObject sobj3;
            RecordLockUnlockClass lockUnlockClass = new RecordLockUnlockClass();

            if(String.isNotEmpty(relatedObj1Id)){
                sobj1 = Id.valueOf(relatedObj1Id).getSobjectType().newSObject(relatedObj1Id);
                if (Approval.isLocked(relatedObj1Id)) {
                    List<Id> recordIds = new List<Id>();
                    recordIds.add(relatedObj1Id);
                    lockUnlockClass.unlockRecord(recordIds);
                update sobj1;
                    lockUnlockClass.lockRecord(recordIds);
                }
                else {
                    update sobj1;
                }
                //update sobj1;
            }
            if(String.isNotEmpty(relatedObj2Id)){
                sobj2 = Id.valueOf(relatedObj2Id).getSobjectType().newSObject(relatedObj2Id);
                if (Approval.isLocked(relatedObj2Id)) {
                    List<Id> recordIds = new List<Id>();
                    recordIds.add(relatedObj2Id);
                    lockUnlockClass.unlockRecord(recordIds);
                update sobj2;
                    lockUnlockClass.lockRecord(recordIds);
                }
                else {
                    update sobj2;
                }
                //update sobj2;
            }
            if(String.isNotEmpty(relatedObj3Id)){
                sobj3 = Id.valueOf(relatedObj3Id).getSobjectType().newSObject(relatedObj3Id);
                if (Approval.isLocked(relatedObj3Id)) {
                    List<Id> recordIds = new List<Id>();
                    recordIds.add(relatedObj3Id);
                    lockUnlockClass.unlockRecord(recordIds);
                update sobj3;
                    lockUnlockClass.lockRecord(recordIds);
                }
                else {
                    update sobj3;
                }
                //update sobj3;
            }

            //Generation of Document__c Records..............
            generationOfDocumentsObj(defaultRecordId, primaryRecId, seclectedDocId,
                    relatedObj1Id, relatedObj2Id, relatedObj3Id);
        } catch (Exception e) {
            System.debug('Error Line---'+e.getLineNumber()+'Error Msg...'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // For Real Specific Code to update Award associated with project.....
    public static void realAwardUpdation(String relateObjId1Str, String relateObjId2Str, String relateObjId3Str, String defaultRecId, String primaryRecId){
        Id relatedObj1Id;
        Id relatedObj2Id;
        Id relatedObj3Id;
        Id primaryRecIdVal;
        String relatObj1APIName;
        String relatObj2APIName;
        String relatObj3APIName;
        String primaryObjAPIName;

        if(String.isNotBlank(relateObjId1Str)){
            relatedObj1Id = Id.valueOf(relateObjId1Str);
            relatObj1APIName = relatedObj1Id.getSobjectType().getDescribe().getName();
        }

        if(String.isNotBlank(relateObjId2Str)){
            relatedObj2Id = Id.valueOf(relateObjId2Str);
            relatObj2APIName = relatedObj2Id.getSobjectType().getDescribe().getName();
        }

        if(String.isNotBlank(relateObjId3Str)){
            relatedObj3Id = Id.valueOf(relateObjId3Str);
            relatObj3APIName = relatedObj3Id.getSobjectType().getDescribe().getName();
        }

        if(String.isNotBlank(primaryRecId)){
            primaryRecIdVal = Id.valueOf(primaryRecId);
            primaryObjAPIName = primaryRecIdVal.getSobjectType().getDescribe().getName();
        }



        if(relatObj1APIName == 'Amendment_Request__c'){
            List<Award__c> awardList = [SELECT Id, Amendment_Request__c
            FROM Award__c
            WHERE Amendment_Request__c=:relatedObj1Id and Project__c=:defaultRecId];
            if(awardList.size() > 0){
                SObject   awardSobj = Id.valueOf(awardList[0].Id).getSobjectType().newSObject(awardList[0].Id);
                update awardSobj;
            }
        } else if(relatObj2APIName == 'Amendment_Request__c'){
            List<Award__c> awardList = [SELECT Id, Amendment_Request__c
            FROM Award__c
            WHERE Amendment_Request__c=:relatedObj2Id and Project__c=:defaultRecId];
            if(awardList.size() > 0){
                SObject   awardSobj = Id.valueOf(awardList[0].Id).getSobjectType().newSObject(awardList[0].Id);
                update awardSobj;
            }
        } else if(relatObj3APIName == 'Amendment_Request__c'){
            List<Award__c> awardList = [SELECT Id, Amendment_Request__c
            FROM Award__c
            WHERE Amendment_Request__c=:relatedObj3Id and Project__c=:defaultRecId];
            if(awardList.size() > 0){
                SObject   awardSobj = Id.valueOf(awardList[0].Id).getSobjectType().newSObject(awardList[0].Id);
                update awardSobj;
            }
        } else if(primaryObjAPIName == 'Amendment_Request__c'){
            List<Award__c> awardList = [SELECT Id, Amendment_Request__c
            FROM Award__c
            WHERE Amendment_Request__c=:primaryObjAPIName and Project__c=:defaultRecId];
            if(awardList.size() > 0){
                SObject   awardSobj = Id.valueOf(awardList[0].Id).getSobjectType().newSObject(awardList[0].Id);
                update awardSobj;
            }
        } else{
            List<Award__c> awardList = [SELECT Id, Amendment_Request__c
            FROM Award__c
            WHERE Amendment_Request__c = null and Project__c=:defaultRecId];

            if(awardList.size() > 0){
                SObject  awardSobj = Id.valueOf(awardList[0].Id).getSobjectType().newSObject(awardList[0].Id);
                update awardSobj;
            }
        }

    }

    public static void generationOfDocumentsObj(String defaultRecId, String primaryRecId, String docIdVal, String relObj1,
            String relObj2, String relObj3){
        System.debug('Value provided for Gen Docu....'+defaultRecId+'  '+' '+primaryRecId+' '+docIdVal);
        List<SObject> sobjVal = new List<SObject>();
        String recDeaultName = '';
        String primaryRecName = '';
        String relObj1Name = '';
        String relObj2Name = '';
        String relObj3Name = '';

        Datetime todaysDate = Datetime.now();
        if(String.isNotBlank(defaultRecId)) {
            Id defaultIdVal = Id.valueOf(defaultRecId);
            String sobjName =  defaultIdVal.getSobjectType().getDescribe().getName();
            String  dynSoqlQry= 'SELECT Id, Name FROM '+sobjName+ ' WHERE Id=\''+defaultRecId+'\'';
            sobjVal = Database.query(dynSoqlQry);
            recDeaultName = String.valueOf(sobjVal[0].get('Name'));
        }
        if(String.isNotBlank(primaryRecId)){
            Id defaultIdVal = Id.valueOf(primaryRecId);
            String sobjName =  defaultIdVal.getSobjectType().getDescribe().getName();
            String  dynSoqlQry= 'SELECT Id, Name FROM '+sobjName+ ' WHERE Id=\''+primaryRecId+'\'';
            sobjVal = Database.query(dynSoqlQry);
            primaryRecName = String.valueOf(sobjVal[0].get('Name'));
        }
        if(String.isNotBlank(relObj1)){
            Id defaultIdVal = Id.valueOf(relObj1);
            String sobjName =  defaultIdVal.getSobjectType().getDescribe().getName();
            String  dynSoqlQry= 'SELECT Id, Name FROM '+sobjName+ ' WHERE Id=\''+relObj1+'\'';
            sobjVal = Database.query(dynSoqlQry);
            relObj1Name = String.valueOf(sobjVal[0].get('Name'));
        }
        if(String.isNotBlank(relObj2)){
            Id defaultIdVal = Id.valueOf(relObj2);
            String sobjName =  defaultIdVal.getSobjectType().getDescribe().getName();
            String  dynSoqlQry= 'SELECT Id, Name FROM '+sobjName+ ' WHERE Id=\''+relObj2+'\'';
            sobjVal = Database.query(dynSoqlQry);
            relObj2Name = String.valueOf(sobjVal[0].get('Name'));
        }
        if(String.isNotBlank(relObj3)){
            Id defaultIdVal = Id.valueOf(relObj3);
            String sobjName =  defaultIdVal.getSobjectType().getDescribe().getName();
            String  dynSoqlQry= 'SELECT Id, Name FROM '+sobjName+ ' WHERE Id=\''+relObj3+'\'';
            sobjVal = Database.query(dynSoqlQry);
            relObj3Name = String.valueOf(sobjVal[0].get('Name'));
        }
        List<Docu_Generation_Individual_Child_Config__mdt> docGenIndividualLst = [SELECT Id, Original_File_Name__c, New_File_Name__c, Document__c,
                Document_Generation_Config__c, Attachment_for_Primary_Record__c,
                Attachment_for_Related_Object1__c, Attachment_for_Related_Object2__c,
                Attachment_for_Related_Object3__c
        FROM  Docu_Generation_Individual_Child_Config__mdt
        WHERE Document_Generation_Config__c =:docIdVal];

        System.debug('Docu_Generation_Individual_Child_Config__mdt list....'+docGenIndividualLst);
        if(docGenIndividualLst.size() > 0){
            List<Document__c> docListVal = new List<Document__c>();
            for(Docu_Generation_Individual_Child_Config__mdt docIndivualVal: docGenIndividualLst){

                Document__c docObj = new Document__c();
                // Assign of Default Rec Id Creation based......
                if(String.isNotBlank(defaultRecId)) {
                    // Document Object creation...
                    docObj.Document_Name__c = String.isNotBlank(docIndivualVal.New_File_Name__c)?docIndivualVal.New_File_Name__c:docIndivualVal.Original_File_Name__c; // +'_'+recDeaultName+'__'+todaysDate.format('yyyy-MM-dd');
                    docObj.Original_File_Name__c = docIndivualVal.Original_File_Name__c;
                    docObj.Document_Type__c = docIndivualVal.Document__c;
                    Id recordIdVal = Id.valueOf(defaultRecId);

                    String defaultObjectName = recordIdVal.getSobjectType().getDescribe().getName();
                    System.debug('defaultObjectName===='+defaultObjectName);

                    docObj = docGenRefAssignment(defaultObjectName, docObj, defaultRecId);
                }
                System.debug('DocObj Val1===='+docListVal);

                // Assign of Primary Rec Id Creation based......
                if(String.isNotBlank(primaryRecId) && docIndivualVal.Attachment_for_Primary_Record__c){
                    docObj.Document_Name__c += '_'+primaryRecName;
                    Id primaryRecordIdVal = Id.valueOf(primaryRecId);

                    String primarySobjectAPIName = primaryRecordIdVal.getSobjectType().getDescribe().getName();
                    System.debug('primarySobjectAPIName===='+primarySobjectAPIName);

                    docObj = docGenRefAssignment(primarySobjectAPIName, docObj, primaryRecId);
                }

                //Assign of Related Obj1 Rec Id Creation based......
                if(String.isNotBlank(relObj1) && docIndivualVal.Attachment_for_Related_Object1__c){
                    docObj.Document_Name__c += '_'+ relObj1Name;
                    Id relObj1IdVal = Id.valueOf(relObj1);

                    String relObj1APIName = relObj1IdVal.getSobjectType().getDescribe().getName();
                    System.debug('relObj1APIName===='+relObj1APIName);
                    docObj = docGenRefAssignment(relObj1APIName, docObj, relObj1);
                }

                //Assign of Related Obj2 Rec Id Creation based......
                if(String.isNotBlank(relObj2) && docIndivualVal.Attachment_for_Related_Object2__c){
                    docObj.Document_Name__c += '_'+relObj2Name;
                    Id relObj2IdVal = Id.valueOf(relObj2);

                    String relObj2APIName = relObj2IdVal.getSobjectType().getDescribe().getName();
                    System.debug('relObj2APIName===='+relObj2APIName);

                    docObj = docGenRefAssignment(relObj2APIName, docObj, relObj2);
                }

                //Assign of Related Obj3 Rec Id Creation based......
                if(String.isNotBlank(relObj3) && docIndivualVal.Attachment_for_Related_Object3__c){
                    docObj.Document_Name__c += '_'+relObj3Name;
                    Id relObj3IdVal = Id.valueOf(relObj3);

                    String relObj3APIName = relObj3IdVal.getSobjectType().getDescribe().getName();
                    System.debug('relObj3APIName===='+relObj3APIName);
                    docObj = docGenRefAssignment(relObj3APIName, docObj, relObj3);
                }

                docObj.Document_Name__c += '__'+todaysDate.format('yyyy-MM-dd');
                docListVal.add(docObj);
                System.debug('DocObj Val2===='+ docListVal);
            }
            // Creation of Document Obj......
            System.debug('docListVal....'+ docListVal);
            if(docListVal.size() > 0){
                insert docListVal;
            }
        }
    }

    /*public static void generationOfDocumentsObj(String defaultRecId, String primaryRecId, String docIdVal, String relObj1,
                                                String relObj2, String relObj3){
        System.debug('Value provided for Gen Docu....'+defaultRecId+'  '+' '+primaryRecId+' '+docIdVal);
        List<Sobject> sobjVal = new List<Sobject>();
        String recDeaultName ='';
        DateTime todaysDate = Datetime.now();
        if(String.isNotBlank(defaultRecId)){
            Id defaultIdVal = Id.valueOf(defaultRecId);
            String sobjName =  defaultIdVal.getSobjectType().getDescribe().getName();
            String  dynSoqlQry= 'SELECT Id, Name FROM '+sobjName+ ' WHERE Id=\''+defaultRecId+'\'';
            sobjVal = Database.query(dynSoqlQry);
            recDeaultName = String.valueOf(sobjVal[0].get('Name'));
        }
        List<Docu_Generation_Individual_Child_Config__mdt> docGenIndividualLst = [SELECT Id, Original_File_Name__c, New_File_Name__c, Document__c,
                                                                                   Document_Generation_Config__c, Attachment_for_Primary_Record__c,
                                                                                   Attachment_for_Related_Object1__c, Attachment_for_Related_Object2__c,
                                                                                   Attachment_for_Related_Object3__c
                                                                                   FROM  Docu_Generation_Individual_Child_Config__mdt
                                                                                   WHERE Document_Generation_Config__c =:docIdVal];

        System.debug('Docu_Generation_Individual_Child_Config__mdt list....'+docGenIndividualLst);
        if(docGenIndividualLst.size() > 0){
            List<Document__c> docListVal = new List<Document__c>();
            for(Docu_Generation_Individual_Child_Config__mdt docIndivualVal: docGenIndividualLst){


                // Assign of Default Rec Id Creation based......
                if(String.isNotBlank(defaultRecId)){
                    // Document Object creation...


                    Document__c docObj1 = new Document__c();


                    docObj1.Document_Name__c = String.isNotBlank(docIndivualVal.New_File_Name__c)?docIndivualVal.New_File_Name__c:docIndivualVal.Original_File_Name__c+'_'+recDeaultName+'__'+todaysDate.format('yyyy-MM-dd');
                    docObj1.Original_File_Name__c = docIndivualVal.Original_File_Name__c;
                    docObj1.Document_Type__c = docIndivualVal.Document__c;
                    Id recordIdVal = Id.valueOf(defaultRecId);

                    String sobjectName = recordIdVal.getSObjectType().getDescribe().getName();
                    System.debug('SobjName===='+sobjectName);

                    docObj1 = docGenRefAssignment(sobjectName, docObj1, defaultRecId);
                    docListVal.add(docObj1);
                }
                System.debug('DocObj Val1===='+docListVal);

                // Assign of Primary Rec Id Creation based......
                if(String.isNotBlank(primaryRecId) && docIndivualVal.Attachment_for_Primary_Record__c){
                    // Document Object creation...
                    Document__c docObj2 = new Document__c();
                    docObj2.Document_Name__c = docIndivualVal.New_File_Name__c;
                    docObj2.Original_File_Name__c = docIndivualVal.Original_File_Name__c;
                    docObj2.Document_Type__c = docIndivualVal.Document__c;
                    Id primaryRecordIdVal = Id.valueOf(primaryRecId);

                    String primarySobjectName = primaryRecordIdVal.getSObjectType().getDescribe().getName();
                    System.debug('primarySobjectName===='+primarySobjectName);

                    docObj2 = docGenRefAssignment(primarySobjectName, docObj2, primaryRecId);
                    docListVal.add(docObj2);
                }

                //Assign of Related Obj1 Rec Id Creation based......
                if(String.isNotBlank(relObj1) && docIndivualVal.Attachment_for_Related_Object1__c){
                    // Document Object creation...
                    Document__c docObj3 = new Document__c();
                    docObj3.Document_Name__c = docIndivualVal.New_File_Name__c;
                    docObj3.Original_File_Name__c = docIndivualVal.Original_File_Name__c;
                    docObj3.Document_Type__c = docIndivualVal.Document__c;
                    Id relObj1IdVal = Id.valueOf(relObj1);

                    String primarySobjectName = relObj1IdVal.getSObjectType().getDescribe().getName();
                    System.debug('relObj1===='+primarySobjectName);
                    docObj3 = docGenRefAssignment(primarySobjectName, docObj3, relObj1);
                    docListVal.add(docObj3);
                }

                //Assign of Related Obj2 Rec Id Creation based......
                if(String.isNotBlank(relObj2) && docIndivualVal.Attachment_for_Related_Object2__c){
                    // Document Object creation...
                    Document__c docObj4 = new Document__c();
                    docObj4.Document_Name__c = docIndivualVal.New_File_Name__c;
                    docObj4.Original_File_Name__c = docIndivualVal.Original_File_Name__c;
                    docObj4.Document_Type__c = docIndivualVal.Document__c;
                    Id relObj2IdVal = Id.valueOf(relObj2);

                    String primarySobjectName = relObj2IdVal.getSObjectType().getDescribe().getName();
                    System.debug('relObj2===='+primarySobjectName);

                    docObj4 = docGenRefAssignment(primarySobjectName, docObj4, relObj2);
                    docListVal.add(docObj4);
                }

                //Assign of Related Obj3 Rec Id Creation based......
                if(String.isNotBlank(relObj3) && docIndivualVal.Attachment_for_Related_Object3__c){
                    // Document Object creation...
                    Document__c docObj5 = new Document__c();
                    docObj5.Document_Name__c = docIndivualVal.New_File_Name__c;
                    docObj5.Original_File_Name__c = docIndivualVal.Original_File_Name__c;
                    docObj5.Document_Type__c = docIndivualVal.Document__c;
                    Id relObj3IdVal = Id.valueOf(relObj3);

                    String primarySobjectName = relObj3IdVal.getSObjectType().getDescribe().getName();
                    System.debug('relObj3===='+primarySobjectName);
                    docObj5 = docGenRefAssignment(primarySobjectName, docObj5, relObj3);
                    docListVal.add(docObj5);
                }
                System.debug('DocObj Val2===='+docListVal);
        }
        // Creation of Document Obj......
        System.debug('docListVal....'+docListVal);
        if(docListVal.size() > 0){
            insert docListVal;
        }
    }
 }*/

    public static Document__c docGenRefAssignment(String sobjectName, Document__c docObj, String defaultRecIdStr){
        System.debug('Entered Doc Gen Ref Assignment....');
        System.debug('sobjectName Val....'+sobjectName);
        System.debug('docObj Val....'+docObj);
        System.debug('defaultRecIdStr Val....'+defaultRecIdStr);
        switch on sobjectName {
            when 'Closeout_Task__c' {		// when block 1
                docObj.Closeout_Task__c = defaultRecIdStr;
            }
            when 'Project_Closeout__c' {		// when block 1
                docObj.Project_Closeout__c = defaultRecIdStr;
            }
            when 'Incident__c' {		// when block 2
                docObj.Incident__c = defaultRecIdStr;
            }
            when 'Payment_Request__c' {		// when block 3
                docObj.PaymentRequest__c = defaultRecIdStr;
            }
            when 'Project__c' {		// when block 3
                docObj.ProjectId__c = defaultRecIdStr;
            }
            /*when 'Project_Site__c' {		// when block 3
                docObj.Project_Site__c = defaultRecIdStr;
            }*/
            /*when 'Work_Schedule__c' {		// when block 3
                docObj.Work_Schedule__c = defaultRecIdStr;
            }*/
            when 'Amendment_Request__c'{
                docObj.AmendmentRequest__c = defaultRecIdStr;
            }
            when else {		  // default block, optional
                // code block 4
            }
        }
        return docObj;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchPrimaryObject(String searchTerm, String searchFilterClauses, String searchObjAPIName, String mergeRecIdReplacer) {
        String query = 'Select Id, Name  From '+searchObjAPIName+' Where Name != null ';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND  Name like\'%' + searchTerm + '%\'';
        }
        if(String.isNotEmpty(searchFilterClauses)){
            searchFilterClauses = searchFilterClauses.replace('{recordId}', mergeRecIdReplacer);
            query += ' AND '+searchFilterClauses+'';
        }

        query += ' Limit 200';
        system.debug('query===='+query);
        List<Sobject> searchResultList = Database.query(query);

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String productIcon = 'standard:account';
        for (Sobject searchResultObj : searchResultList) {
            // SObject sobjVal = searchResultObj.Id.getSobjectType().newSObject(searchResultObj.Id);
            results.add(
                    new LookupSearchResult(
                            searchResultObj.Id,
                            'Account',
                            productIcon,
                            (String)searchResultObj.get('Name'),
                            ((String)searchResultObj.get('Name') !=null ? (String)searchResultObj.get('Name'): ''),
                            searchResultObj
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    @AuraEnabled
    public static Map<String,String> handleRelatedObjRel(String defaultRecId, String relObj1, String relObj2){
        try {
            Map<String,String> resultMap = new Map<String, String>();
            List<Payment_Request__c> prList = [SELECT Id, Award__c, Award__r.Amendment_Request__c, Project__c FROM Payment_Request__c
            WHERE Project__c =:defaultRecId and Id=:relObj2 and Award__r.Amendment_Request__c=:relObj1];

            if(prList.size() > 0){
                resultMap.put('isRelated', 'true');
            }else{
                resultMap.put('isRelated', 'false');
            }

            return resultMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}