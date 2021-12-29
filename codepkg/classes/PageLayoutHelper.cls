/**
 * Created by harsh on 27-01-2021.
 */

public without sharing class PageLayoutHelper {

    public static Map<String, Object> getPageLayoutDetails(String pageLayoutId){
        System.debug('pageLayoutId: '+pageLayoutId);
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, List<Page_Field__mdt>> pageFieldMap = new Map<String, List<Page_Field__mdt>>();

        Page_Field__mdt[] pageDetails = [SELECT Id, Label, Field_API_Name__c, Field_Type__c, Required__c, Display_Label__c, Sequence__c, DeveloperName,
                                        Hide_Field_API_Name__c, Hide_Field_Operator__c, Hide_Field_Value__c, Search_Class_Name__c, Static_Content__c,Controller_Field__c,
                                        Related_To_Object_Name__c, Is_Read_Only__c, Column_Size__c, Help_Text__c, Table_Object__c, Table_Columns__c, Table_Record_Limit__c, Table_Additional_Config__c,
                                        Validation_Pattern__c, Validation_Error_Message__c, Placeholder__c, Max_Length__c,
                                        Document_Table_Columns__c, Filter_Document_Types__c, Enable_Field_Specific_Doc__c, Field_Criteria_value__c, Field_Specific_Value__c,
                                        Table_Where_Clause__c,Table_Parent_Relationship_Field_API__c,Table_Name__c, Multiple_Table_Query__c,
                                        Enable_Field_Formula__c, Field_Formula_Configuration__c, Hide_Field_Custom_Attribute__c, User_Defined_Picklist_Values__c,
                                        Enabled_Minimum_Value__c, Minimum_Value_Configuration__c, Enabled_Maximum_Value__c, Maximum_Value_Configuration__c,
                                        Enable_Channel_Message__c, Channel_Event_Name__c, Channel_Event_Config__c,
                                        Page_Section__c, Page_Section__r.Label, Page_Section__r.DeveloperName, Page_Section__r.Page_Layout__c, Page_Section__r.Sequence__c,
                                        Page_Section__r.Hide_Field_API_Name__c, Page_Section__r.Hide_Field_Operator__c, Page_Section__r.Hide_Field_Value__c,
                                        Page_Section__r.Hide_Field_API_Name_2__c, Page_Section__r.Hide_Field_Operator_2__c, Page_Section__r.Hide_Field_Value_2__c,
                                        Page_Section__r.Page_Layout__r.SObject__r.ObjectApiName__c, Page_Section__r.Page_Layout__r.Label,
                                        Page_Section__r.Page_Layout__r.Redirect_To__c, Page_Section__r.Page_Layout__r.Redirect_Type__c,
                                        Page_Section__r.Page_Layout__r.Redirect_To_Previous__c
                                        FROM Page_Field__mdt
                                        WHERE Active__c = true AND Page_Section__r.Page_Layout__c =: String.escapeSingleQuotes(pageLayoutId)
                                        ORDER BY Sequence__c];
        List<PageSectionWrapper> pageSections = new List<PageSectionWrapper>();
        List<String> pageSectionIds = new List<String>();
        List<Page_Field__mdt> pageFields = new List<Page_Field__mdt>();
        List<String> relatedObjects = new List<String>();
        List<String> relatedToSObjectsAPINames = new List<String>();
        returnMap.put('subScribeMessageChannel', false);
        for(Page_Field__mdt pageField: pageDetails){
            /*Get Page Layout name*/
            if(returnMap.get('pageLayout') == null){ returnMap.put('pageLayout', pageField.Page_Section__r.Page_Layout__r);}
            if(returnMap.get('pageLayoutName') == null){ returnMap.put('pageLayoutName', pageField.Page_Section__r.Page_Layout__r.Label);}
            if(returnMap.get('pageLayoutObject') == null){ returnMap.put('pageLayoutObject', pageField.Page_Section__r.Page_Layout__r.SObject__r.ObjectApiName__c);}
            if(returnMap.get('pageRedirectType') == null){ returnMap.put('pageRedirectType', pageField.Page_Section__r.Page_Layout__r.Redirect_Type__c);}
            if(returnMap.get('pageRedirectTo') == null){ returnMap.put('pageRedirectTo', pageField.Page_Section__r.Page_Layout__r.Redirect_To__c);}
            if(returnMap.get('pageRedirectToPrevious') == null){ returnMap.put('pageRedirectToPrevious', pageField.Page_Section__r.Page_Layout__r.Redirect_To_Previous__c);}
            if(pageField.Enable_Channel_Message__c){ returnMap.put('subScribeMessageChannel', pageField.Enable_Channel_Message__c);}

            /*Prepare page section*/
            if(!pageSectionIds.contains(pageField.Page_Section__c)){
                pageSections.add(new PageSectionWrapper(pageField.Page_Section__r));
                pageSectionIds.add(pageField.Page_Section__c);
            }
            //pageFields.add(pageField);

            /*Prepare page section wise fields*/
            if(pageFieldMap.get(pageField.Page_Section__c) == null){ pageFieldMap.put(pageField.Page_Section__c, new List<Page_Field__mdt>()); }
            pageFieldMap.get(pageField.Page_Section__c).add(pageField);

            /*Prepare related object list*/
            if(String.isNotBlank(pageField.Field_API_Name__c) && pageField.Field_API_Name__c.contains('__r')){
                List<String> parts = pageField.Field_API_Name__c.split('\\.');
                if(parts.size() > 0 && !relatedObjects.contains(parts[0])){
                    relatedObjects.add(parts[0]);//.replace('__r','__c')
                }
            }

            if(pageField.Related_To_Object_Name__c != null && !relatedToSObjectsAPINames.contains(pageField.Related_To_Object_Name__c)){
                relatedToSObjectsAPINames.add(pageField.Related_To_Object_Name__c);
            }
        }

        pageSections.sort();
        returnMap.put('pageSections',pageSections);
        returnMap.put('pageFields',pageFieldMap);
        returnMap.put('relatedObjects',relatedObjects);
        returnMap.put('relatedSObjectsMetaInfo',describeSObject(relatedToSObjectsAPINames));
        returnMap.put('pageValidations', getPageLayoutValidations(pageLayoutId));
        System.debug('returnMap: '+returnMap);
        return returnMap;
    }

    public static Map<String, Object> prepareQueryDetails(String pageLayoutId) {
        Map<String, Object> returnMap = new Map<String, Object>();

        Page_Field__mdt[] pageDetails = [
                SELECT Id, Label, Field_API_Name__c, Field_Type__c, Required__c, Display_Label__c, Sequence__c, DeveloperName,
                        Hide_Field_API_Name__c,
                        Page_Section__c, Page_Section__r.Label, Page_Section__r.Page_Layout__c, Page_Section__r.Sequence__c,
                        Page_Section__r.Page_Layout__r.SObject__r.ObjectApiName__c, Page_Section__r.Page_Layout__r.Label,
                        Page_Section__r.Hide_Field_API_Name__c, Page_Section__r.Hide_Field_API_Name_2__c
                FROM Page_Field__mdt
                WHERE Active__c = true AND Page_Section__r.Page_Layout__r.Id = :String.escapeSingleQuotes(pageLayoutId)
                ORDER BY Sequence__c
        ];

        Set<String> fieldAPIsSet = new Set<String>();
        fieldAPIsSet.add('Id');
        for (Page_Field__mdt pageField : pageDetails) {
            /*Get Page Layout name*/
            if (returnMap.get('pageLayoutName') == null) {
                returnMap.put('pageLayoutName', pageField.Page_Section__r.Page_Layout__r.Label);
            }
            if (returnMap.get('pageLayoutObject') == null) {
                returnMap.put('pageLayoutObject', pageField.Page_Section__r.Page_Layout__r.SObject__r.ObjectApiName__c);
            }

            if (String.isNotBlank(pageField.Field_API_Name__c)) {
                fieldAPIsSet.add(pageField.Field_API_Name__c);
            }
            if (String.isNotBlank(pageField.Hide_Field_API_Name__c)) {
                fieldAPIsSet.add(pageField.Hide_Field_API_Name__c);
            }

            if(String.isNotBlank(pageField.Page_Section__r.Hide_Field_API_Name__c)){
                fieldAPIsSet.add(pageField.Page_Section__r.Hide_Field_API_Name__c);
            }
            if(String.isNotBlank(pageField.Page_Section__r.Hide_Field_API_Name_2__c)){
                fieldAPIsSet.add(pageField.Page_Section__r.Hide_Field_API_Name_2__c);
            }

        }

        List<String> fieldAPIList = new List<String>();
        fieldAPIList.addAll(fieldAPIsSet);
        returnMap.put('fieldAPIs', String.join(fieldAPIList, ','));

        return returnMap;
    }

    public static Map<String, Object> describeSObject(List<String> sObjectTypes){
        Map<String, Object> returnMap = new Map<String, Object>();
        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(sObjectTypes);
        for(Schema.DescribeSobjectResult res : results) {
            System.debug('sObject Label: ' + res.getSObjectType());
            List<Schema.RecordTypeInfo> recordTypeInfos = res.getRecordTypeInfos();
            returnMap.put(String.valueOf(res.getSObjectType()), '');
            for(Schema.RecordTypeInfo rt: recordTypeInfos){
                if(rt.isDefaultRecordTypeMapping()){
                    System.debug('Object Name: '+res.getLabel()+' RecordTypeName: '+ rt.getDeveloperName()+' RecordTypeId: '+rt.getRecordTypeId());
                    returnMap.put(String.valueOf(res.getSObjectType()), rt.getRecordTypeId());
                }
            }
        }
        System.debug('describeSObject returnMap:'+returnMap);
        return returnMap;
    }

    public static Map<String, Set<String>> getFieldDependencies(String objectName, String controllingField, String dependentField) {
        Map<String, Set<String>> controllingInfo = new Map<String, Set<String>>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getValue(), new Set<String>());
        }
        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            //toLowerCase can be changed to uppercase and getLabel() can be changed to getValue() based on requirement.
            for (Integer curr : hexString.getChars()) {
                Integer val = (curr >= 65) ? (curr - 65 + 10) : (curr - 48);
                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());
                }
                baseCount += 4;
            }

        }
        System.debug('controllingInfo: '+controllingInfo);
        return controllingInfo;
    }
    public class MyPickListInfo{
      public String validFor;
    }

    public static Map<String, Object> preparePageLayoutDetails(String recordId, String pageTemplateName, String pageLayoutName, String sequence){
            System.debug('recordId----'+recordId);
            System.debug('pageTemplateName----'+pageTemplateName);
            System.debug('sequence----'+sequence);

            Map<String, Object> returnMap = new Map<String, Object>();
            Page_Layout__mdt pageLayout = new Page_Layout__mdt();
            String objectAPIName = getObjectName(recordId);
            String pageTemplateConfigName = '';
            System.debug('objectAPIName----'+objectAPIName);
            if(String.isEmpty(pageLayoutName)){
                //Get Application Template from application record
                pageTemplateConfigName = (String) getPageTemplateConfig(recordId, objectAPIName).get('Page_Template_Config_Name__c');
                pageLayout = findPageLayout(objectAPIName, sequence, pageTemplateConfigName);
                System.debug('page layout developer name: '+pageLayout.DeveloperName);
                System.debug('page layout Id: '+pageLayout.Id);
                pageLayoutName = pageLayout.Id;
            }else{
                pageLayout = getPageLayoutById(pageLayoutName);
            }
            if(pageLayout.SObject__r.ObjectApiName__c != objectAPIName){
                System.debug('Object API not matching');
            }
            returnMap = getPageLayoutDetails(pageLayoutName);
            returnMap.put('pageLayoutName', pageLayoutName);
            returnMap.put('pageLayout', pageLayout);
            returnMap.put('pageSequence', pageLayout.Sequence__c);
            returnMap.put('nextPageSequence', pageLayout.Sequence__c + 1);
            returnMap.put('nextPageLayout', findNextPageLayout(objectAPIName, String.valueOf(pageLayout.Sequence__c)));
            returnMap.put('previousPageLayout', findPreviousPageLayout(objectAPIName, String.valueOf(pageLayout.Sequence__c - 2)));
            returnMap.put('previousPageSequence', pageLayout.Sequence__c - 2);
            returnMap.put('pageTemplateConfigName', pageTemplateConfigName);
            System.debug('returnMap: '+returnMap);
            return returnMap;
    }

    private static Page_Layout__mdt findPageLayout(String sObjectName, String sequence, String pageTemplateName){
        String query = 'SELECT Id, DeveloperName, Sequence__c, SObject__r.ObjectApiName__c from Page_Layout__mdt ';// WHERE SObject__r.ObjectApiName__c=:sObjectName ';
                if(String.isNotEmpty(sequence)){
                    Decimal sequenceNumber = Decimal.valueOf(sequence);
                    query += 'WHERE Sequence__c >:sequenceNumber ';
                }
                /*if(String.isNotEmpty(pageTemplateName)){
                    query += 'AND Page_Template_Config__r.Page_Template_Name__c =:pageTemplateName ';
                }*/
        query += ' ORDER BY Sequence__c NULLS LAST LIMIT 1 ';
        Page_Layout__mdt[] pageLayouts = Database.query(query);
        if(pageLayouts.size() == 0){
            throw new AuraHandledException('Page Layout not configured for Object');
        }
        return pageLayouts[0];
    }

    public static String getObjectName(String recordId){
        Id masterRecordId = recordId;
        return masterRecordId.getSObjectType().getDescribe().getName();
    }
    /**
     * Page_Template_Config_Name__c field must created on every object where Page Template support provided
    */
    private static SObject getPageTemplateConfig(String recordId, String objectAPIName){
        String query = 'Select Id, Page_Template_Config_Name__c from '+objectAPIName+' Where Id=:recordId';
        SObject[] records = Database.query(query);
        if(records.size() == 0){
            throw new AuraHandledException('Page Template Name not configured for sObject record');
        }
        return records[0];
    }

    private static Page_Layout__mdt findNextPageLayout(String sObjectName, String sequence){
        try{
           return findPageLayout(sObjectName, sequence, '');
        }catch (Exception e){
            return new Page_Layout__mdt();
        }
    }

    private static Page_Layout__mdt findPreviousPageLayout(String sObjectName, String sequence){
        try{
           return findPageLayout(sObjectName, sequence, '');
        }catch (Exception e){
            return new Page_Layout__mdt();
        }
    }


    private static Page_Layout__mdt getPageLayoutById(String pageLayoutId){
        return [SELECT Id, DeveloperName, Label, Sequence__c, SObject__r.ObjectApiName__c FROM Page_Layout__mdt WHERE Id=:pageLayoutId];
    }

    public static Map<String, Object> getPageDetails(String recordId, String programTemplatePageId, String orderBy){
        Map<String, Object> returnMap = new Map<String, Object>();
        /*String objectAPIName = getObjectName(recordId);
        SObject recordDetails = getRecordDetails(recordId, objectAPIName);
        System.debug('recordDetails--'+recordDetails);
        Program_Template_Page__mdt[] programTemplatePages = getProgramTemplatePages(programTemplatePageId);
        System.debug('programTemplatePages size= '+ programTemplatePages.size());
        Program_Template_Page__mdt programTemplatePage = findProgramTemplatePage(recordDetails, programTemplatePages);*/
        Program_Template_Page__mdt programTemplatePage = null;
        if(String.isEmpty(programTemplatePageId)){
            programTemplatePage = (Program_Template_Page__mdt) findNextProgramTemplatePage(recordId, programTemplatePageId, orderBy).get('nextProgramTemplatePage');
        }else{
            programTemplatePage = getProgramTemplatePage(programTemplatePageId);
        }
        //Program_Template_Page__mdt programTemplatePage = getProgramTemplatePage(programTemplatePageId);
        returnMap = getPageLayoutDetails(programTemplatePage.Page_Layout_Config__c);
        returnMap.put('programTemplatePage', programTemplatePage);
        returnMap.put('pageLayout', programTemplatePage.Page_Layout_Config__r);

        //returnMap.putAll(getRecordDetails1(recordId, objectAPIName, programTemplatePage.Page_Layout_Config__c));
        return returnMap;
    }

    public static Map<String, Object> handleNextPreviousProgramTemplatePage(String buttonAction, String recordId, String programTemplatePageId){
        String orderBy = 'ASC';
        if(buttonAction.equals('previous')){
            orderBy = 'DESC';
        }
        return findNextProgramTemplatePage(recordId, programTemplatePageId, orderBy); 
    }

    public static Map<String, Object> findNextProgramTemplatePage(String recordId, String programTemplatePageId, String orderBy){
        System.debug('findNextProgramTemplatePage:::::: programTemplatePageId-----'+programTemplatePageId);
        Map<String, Object> returnMap = new Map<String, Object>();
        String objectAPIName = getObjectName(recordId);
        /*Get Record Type Name to get Program Template Page */
        String recordType = getRecordTypeName(objectAPIName, recordId);
        //System.debug('recordType---'+recordType);
        if(recordType == null){
            returnMap.put('isSuccess', false);
            returnMap.put('errorMsg', 'Program Template Not configured for current object');
            return returnMap;
        }
        SObject recordDetails = getRecordDetails(recordId, objectAPIName);
        //System.debug('recordDetails--'+recordDetails);
        Program_Template_Page__mdt[] programTemplatePages = getProgramTemplatePages(programTemplatePageId, recordType, orderBy);
        System.debug('programTemplatePages size= '+ programTemplatePages.size());
        Program_Template_Page__mdt programTemplatePage = findProgramTemplatePage(recordDetails, programTemplatePages);
        System.debug('programTemplatePage--'+programTemplatePage);
        returnMap.put('nextProgramTemplatePage', programTemplatePage);
        return returnMap;
    }

    public static String getRecordTypeName(String objectAPIName, String recordId){
        String query = 'SELECT Id, RecordtypeId FROM '+objectAPIName+' where Id =:recordId';
        System.debug('getRecordTypeName-- '+query);
        SObject[] records = Database.query(query);
        if(records.size() > 0){
            System.debug('records[0]---'+records[0]);
            String recordTypeId = (String) records[0].get('RecordTypeId');
            return Schema.getGlobalDescribe().get(objectAPIName) .getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        }
        return null;
    }

    private static Program_Template_Page__mdt getProgramTemplatePage(String programTemplatePageId){
        String query = 'SELECT Id, DeveloperName, Page_Previous_Next_Button__c, Program_Template__r.DeveloperName, Sequence__c, Page_Layout_Config__r.DeveloperName, Page_Layout_Config__r.Label, Page_Layout_Config__r.Layout_Header_Label__c, Page_Layout_Config__r.SObject__r.ObjectApiName__c,' +
                'Render_Criteria_Field_API_Name_1__c, Render_Criteria_FieldAPI_Name_1_Operator__c, Render_Criteria_Field_API_Name_1_Value__c, Render_Criteria_Field_API_Name_2__c, Render_Criteria_FieldAPI_Name_2_Operator__c, Render_Criteria_Field_API_Name_2_Value__c ' +
                'from Program_Template_Page__mdt WHERE Active__c=true AND Id =:programTemplatePageId ';
        return Database.query(query);
    }
    /*programTemplateName = HMGP*/
    private static Program_Template_Page__mdt[] getProgramTemplatePages(String programTemplatePageId, String programTemplateName, String orderBy){
        /*Get current page sequence*/
        Decimal sequence = 0;
        //String orderBy = 'ASC';
        if(String.isNotEmpty(programTemplatePageId)){
            Program_Template_Page__mdt currentProgramTemplatePage = getProgramTemplatePage(programTemplatePageId);//Custom metadata queries not count against SOQL limits if Long textarea field not in the query
            sequence = currentProgramTemplatePage.Sequence__c;
        }

        String query = 'SELECT Id, DeveloperName, Page_Previous_Next_Button__c, Program_Template__r.DeveloperName, Sequence__c, Page_Layout_Config__r.DeveloperName, Page_Layout_Config__r.Label, Page_Layout_Config__r.Layout_Header_Label__c, Page_Layout_Config__r.SObject__r.ObjectApiName__c,' +
                       'Render_Criteria_Field_API_Name_1__c, Render_Criteria_FieldAPI_Name_1_Operator__c, Render_Criteria_Field_API_Name_1_Value__c, Render_Criteria_Field_API_Name_2__c, Render_Criteria_FieldAPI_Name_2_Operator__c, Render_Criteria_Field_API_Name_2_Value__c ' +
                       'from Program_Template_Page__mdt WHERE Active__c=true AND Program_Template__r.DeveloperName =:programTemplateName ';
                    /*if(String.isNotEmpty(programTemplatePageId)){
                        query += ' AND Id >:programTemplatePageId ';
                    }*/
                    if(sequence != null && orderBy.equals('ASC')){
                        query += ' AND Sequence__c >:sequence ';
                    }else if(sequence != null && orderBy.equals('DESC')){
                        query += ' AND Sequence__c <:sequence ';
                    }

        query +='ORDER BY Sequence__c '+orderBy;

        if(String.isEmpty(programTemplatePageId)){
            query +=' LIMIT 1';
        }
        System.debug('Page Template page Query---'+query);
        return Database.query(query);
    }

    private static SObject getRecordDetails(String recordId, String objectAPIName){
        Id masterRecordId = recordId;
        Map<String, Schema.SObjectField> objectFieldMap = masterRecordId.getSObjectType().getDescribe().fields.getMap();
        Set<String> objectFields = objectFieldMap.keySet();
        String objectQuery = 'select ' + String.join((Iterable<String>) objectFields, ',') + ' from '+objectAPIName+' Where Id =: masterRecordId';
        //SObject sObjectRecord = Database.query(objectQuery);
        return Database.query(objectQuery);
    }

    private static Program_Template_Page__mdt findProgramTemplatePage(sObject recordDetails, Program_Template_Page__mdt[] programTemplatePages){

        for(Program_Template_Page__mdt programTemplatePage: programTemplatePages){
            System.debug('programTemplatePages developer Name----'+programTemplatePage.Page_Layout_Config__r.DeveloperName);
            System.debug('programTemplatePages Id----'+programTemplatePage.Page_Layout_Config__c);
            Boolean renderCriteria1 = isValid(recordDetails, programTemplatePage.Render_Criteria_Field_API_Name_1__c, programTemplatePage.Render_Criteria_FieldAPI_Name_1_Operator__c, programTemplatePage.Render_Criteria_Field_API_Name_1_Value__c);
            Boolean renderCriteria2 = isValid(recordDetails, programTemplatePage.Render_Criteria_Field_API_Name_2__c, programTemplatePage.Render_Criteria_FieldAPI_Name_2_Operator__c, programTemplatePage.Render_Criteria_Field_API_Name_2_Value__c);
            System.debug('renderCriteria1----------------------------------------'+renderCriteria1);
            System.debug('renderCriteria2----------------------------------------'+renderCriteria2);
            if(renderCriteria1 && renderCriteria2){ return programTemplatePage; }
        }
        return null;
    }

    private static Boolean isValid(SObject record, String leftOperand, String operator, String rightOperand){
        System.debug('record---'+record);
        System.debug('operator---'+operator);
        System.debug('rightOperand---'+rightOperand);
        if(leftOperand ==null || rightOperand == null) return true;

        List<String> values = rightOperand.split(',');
        System.debug('values---'+values);
        String recordValue = (String) record.get(leftOperand);
        System.debug('recordValue---'+recordValue);
        switch on operator{
            when 'Equal'{
                if(values.contains(recordValue)){
                    return true;
                }
            }
            when 'Not Equal'{
                if(!values.contains(recordValue)){
                    return true;
                }
            }
            when else {
                return false;
            }
        }
        return false;
    }

    public static Map<String, Object> getRecordDetails1(String recordId, String pageLayoutId, String objectAPIName){
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isSuccess', false);
        Map<String, Object> pageLayoutDetails = PageLayoutHelper.prepareQueryDetails(pageLayoutId);
        String query = '';
        if(objectAPIName.equals(pageLayoutDetails.get('pageLayoutObject'))){
            query = 'Select '+pageLayoutDetails.get('fieldAPIs')+' FROM '+pageLayoutDetails.get('pageLayoutObject')+' WHERE Id=:recordId';
        }else{
            query = 'Select '+pageLayoutDetails.get('fieldAPIs')+' FROM '+pageLayoutDetails.get('pageLayoutObject')+' WHERE '+objectAPIName+'=:recordId';
        }
        System.debug('query: '+query);
        List<sObject> sObjectList = Database.query(query);
        System.debug('sObjectList : '+ sObjectList);
        returnMap.put('recordDetails', null);
        if(sObjectList.size() > 0){
            returnMap.put('recordDetails', sObjectList.get(0));
            returnMap.put('isSuccess', true);
        }
        return returnMap;
    }

    public static Map<String, Object> getListOfTable(String query) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isSuccess', false);
        if(String.isBlank(query)) return returnMap;
        List<sObject> sObjectList = Database.query(query);
        returnMap.put('recordDetails', null);
        if(sObjectList?.size() > 0) {
            returnMap.put('recordDetails', sObjectList);
            returnMap.put('isSuccess', true);
        }
        return returnMap;
    }

    /**
     * This method used to find project site page for application
     * */
    public static Map<String, Object> getProgramTemplatePageForProjectSite(String parentId, String parentProgramTemplatePageId, String sequence){
        Map<String, Object> returnMap = new Map<String, Object>();
        //Find program template using parentId
        //Find Program Template Page where Program Template id = Step1.Id AND Render Matching Criteria
        //Find Program Template Site Page where Program Template Page Id = Step2.Id and Order By Sequence__c
        String objectAPIName = getObjectName(parentId);
        String recordType = getRecordTypeName(objectAPIName, parentId);
        System.debug('recordType---'+recordType);
        if(recordType == null){
            returnMap.put('isSuccess', false);
            returnMap.put('errorMsg', 'Program Template Not configured for current object');
            return returnMap;
        }
        SObject recordDetails = getRecordDetails(parentId, objectAPIName);
        System.debug('recordDetails--'+recordDetails);
        //TODO: we can avoid below code line 483 to line 492 by passing current page programTemplateId from URL
        Program_Template_Page__mdt[] programTemplatePages = getProgramTemplatePagesForSites(null, recordType, '0');//Sequence is 0 because page site page will consider only one
        System.debug('programTemplatePages size= '+ programTemplatePages.size());
        Program_Template_Page__mdt programTemplatePage = findProgramTemplatePageForSite(recordDetails, programTemplatePages);
        System.debug('programTemplatePage---'+programTemplatePage);
        if(programTemplatePage == null){
            returnMap.put('isSuccess', false);
            returnMap.put('errorMsg', 'Program Template Not configured for Project site');
            return returnMap;
        }
        //TODO: Will use the programTemplatePageId from URL to get Project site page
        Program_Site_Page__mdt[] programSitePages = getProgramSitePages(programTemplatePage.Id, '0');
        System.debug('programSitePages size---'+programSitePages.size());
        if(programSitePages.size() == 0){
            returnMap.put('isSuccess', false);
            returnMap.put('errorMsg', 'Project Site Not configured.');
            return returnMap;
        }
        returnMap.put('sitePages', programSitePages[0]);//Considering first page of project site because it will call only for first page
        System.debug('site Page layout----'+programSitePages[0].Page_Layout_Config__c);
        returnMap.putAll(getPageLayoutDetails(programSitePages[0].Page_Layout_Config__c));
        returnMap.put('isSuccess', true);
        System.debug(returnMap.get('isSuccess'));
        return returnMap;
    }

    private static Program_Template_Page__mdt[] getProgramTemplatePagesForSites(String programTemplatePageId, String programTemplateName, String sequence){
        String query = 'SELECT Id, DeveloperName, Page_Previous_Next_Button__c, Program_Template__r.DeveloperName, Sequence__c, Page_Layout_Config__r.DeveloperName, Page_Layout_Config__r.Label, Page_Layout_Config__r.SObject__r.ObjectApiName__c,' +
                'Render_Criteria_Field_API_Name_1__c, Render_Criteria_FieldAPI_Name_1_Operator__c, Render_Criteria_Field_API_Name_1_Value__c, Render_Criteria_Field_API_Name_2__c, Render_Criteria_FieldAPI_Name_2_Operator__c, Render_Criteria_Field_API_Name_2_Value__c ' +
                'from Program_Template_Page__mdt WHERE Active__c=true AND Program_Template__r.DeveloperName =:programTemplateName ';
        if(String.isNotEmpty(sequence)){
            Decimal seq = Decimal.valueOf(sequence);
            query += ' AND Sequence__c >:seq ';
        }
        query +='ORDER BY Sequence__c ';
        if(String.isEmpty(sequence)){
            query +=' LIMIT 1';
        }
        System.debug('getProgramTemplatePagesForSites Page Template page Query---'+query);
        return Database.query(query);
    }
    /*Get valid Program Template page For Site page*/
    private static Program_Template_Page__mdt findProgramTemplatePageForSite(sObject recordDetails, Program_Template_Page__mdt[] programTemplatePages){

        for(Program_Template_Page__mdt programTemplatePage: programTemplatePages){
            System.debug('programTemplatePages developer Name----'+programTemplatePage.Page_Layout_Config__r.DeveloperName);
            System.debug('programTemplatePages Id----'+programTemplatePage.Page_Layout_Config__c);
            Boolean renderCriteria1 = isValidProgramTemplatePageForSite(recordDetails, programTemplatePage.Render_Criteria_Field_API_Name_1__c, programTemplatePage.Render_Criteria_FieldAPI_Name_1_Operator__c, programTemplatePage.Render_Criteria_Field_API_Name_1_Value__c);
            Boolean renderCriteria2 = isValidProgramTemplatePageForSite(recordDetails, programTemplatePage.Render_Criteria_Field_API_Name_2__c, programTemplatePage.Render_Criteria_FieldAPI_Name_2_Operator__c, programTemplatePage.Render_Criteria_Field_API_Name_2_Value__c);
            System.debug('isValidProgramTemplatePageForSite renderCriteria1----------------------------------------'+renderCriteria1);
            System.debug('isValidProgramTemplatePageForSite renderCriteria2----------------------------------------'+renderCriteria2);
            if(renderCriteria1 && renderCriteria2){ return programTemplatePage; }
        }
        return null;
    }

    private static Boolean isValidProgramTemplatePageForSite(SObject record, String leftOperand, String operator, String rightOperand){
        System.debug('record---'+record);
        System.debug('operator---'+operator);
        System.debug('rightOperand---'+rightOperand);
        if(leftOperand ==null || rightOperand == null) return false;

        List<String> values = rightOperand.split(',');
        System.debug('values---'+values);
        String recordValue = (String) record.get(leftOperand);
        System.debug('recordValue---'+recordValue);
        switch on operator{
            when 'Equal'{
                if(values.contains(recordValue)){
                    return true;
                }
            }
            when 'Not Equal'{
                if(!values.contains(recordValue)){
                    return true;
                }
            }
            when else {
                return false;
            }
        }
        return false;
    }

    private static Program_Site_Page__mdt[] getProgramSitePages(String programTemplatePageId, String sequence){
        //[SELECT id, Page_Layout_Config__c, Page_Layout_Config__r.DeveloperName, Program_Template_Page__c, Sequence__c  from Program_Site_Page__mdt WHERE Program_Template_Page__c=: programTemplatePageId];
        String query = 'SELECT Id, Program_Template_Page__c, Page_Layout_Config__c, Page_Layout_Config__r.DeveloperName, Sequence__c  from Program_Site_Page__mdt WHERE Program_Template_Page__c=: programTemplatePageId ';
        if(String.isNotEmpty(sequence)){
            Decimal seq = Decimal.valueOf(sequence);
            query += ' AND Sequence__c >:seq';
        }
        return Database.query(query);
    }

    /*Get Custom validation */
    private static Page_Layout_Validation__mdt[] getPageLayoutValidations(String pageLayoutId){
        return [SELECT Id, Expression__c, Field_API_Name__c, Error_Message__c FROM Page_Layout_Validation__mdt WHERE Page_Layout_Config__c=:pageLayoutId];
    }
}