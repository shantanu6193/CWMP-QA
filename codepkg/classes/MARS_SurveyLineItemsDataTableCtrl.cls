public without sharing class MARS_SurveyLineItemsDataTableCtrl {
    public 
    static final String CLASSIFICATION_TITLE = 'Classification_Title__c';
public
    static final String BASE_RATES = 'Base_Rates__c';
public
    static final String SPECIAL_EQUIPMENT_TYPE = 'Special_Equipment_Type__c';
public
    static final String CURRENT_RATE = 'Current_Rate__c';
public
    static final String LINE_ITEM_TYPE_PERSONNEL = 'Personnel';
public
    static final String LINE_ITEM_TYPE_SPECIAL_EQUIPMENT = 'Special Equipment';
public
    static final String LINE_ITEM_TYPE_NON_SUPRESSION = 'Non-Supression';
public
    static final String FIELD_SET_PERSONNEL = 'Personnel_Survey_Line_Item_Fields';
public
    static final String FIELD_SET_NON_SUPRESSION =
    'Non_Supression_Survey_Line_Item_Fields';
public
    static final String FIELD_SET_SPECIAL_EQUIPMENT =
    'Special_Equipment_Survey_Line_Item_Field';
// clang-format off
private
    static final Map<String, String> FIELD_SET_TO_LINE_ITEM_TYPE_MAP =
    new Map<String, String>{
        FIELD_SET_NON_SUPRESSION => LINE_ITEM_TYPE_NON_SUPRESSION,
            FIELD_SET_PERSONNEL => LINE_ITEM_TYPE_PERSONNEL,
            FIELD_SET_SPECIAL_EQUIPMENT => LINE_ITEM_TYPE_SPECIAL_EQUIPMENT};
                private
                static final Map<String, String> COLUMN_TYPE_MAP =
                new Map<String, String>{'date' => 'date-local'};
                    // clang-format on
                    private
                    static final Set<String> NON_EDITABLE_FIELD_SET = new Set<String>{
                        CLASSIFICATION_TITLE, BASE_RATES,          SPECIAL_EQUIPMENT_TYPE,
                            CURRENT_RATE,         'Effective_Date__c', 'MOU_MOA_GBR__c'};
                                private static final Map<String, String> CHILD_PARENT_OBJECT_MAP = new Map<String, String>{
                                    'Salary_Survey_Line_Items__c' => 'Agency_Salary_Survey__c',
                                        'Agency_Non_Suppression_Line_Item__c' => 'Agency_Non_Suppression_Personnel__c',
                                        'Agency_Special_Equipment_Line_Item__c' => 'Agency_Special_Equipment__c'
                                        };
                                            
                                            public
                                            static List<Schema.FieldSetMember> getFieldSetMemberList(String fieldSetName,
                                                                                                     String objectName) {
                                                                                                         System.debug('###: fieldSetName: ' + fieldSetName);
                                                                                                         System.debug('###: objectName: ' + objectName);
                                                                                                         System.debug('###:  Schema.getGlobalDescribe().get(objectName): ' +
                                                                                                                      Schema.getGlobalDescribe().get(objectName));
                                                                                                         return Schema.getGlobalDescribe()
                                                                                                             .get(objectName)
                                                                                                             .getDescribe()
                                                                                                             .FieldSets.getMap()
                                                                                                             .get(fieldSetName)
                                                                                                             .getFields();
                                                                                                     }
@AuraEnabled public static Boolean getRelationshipStrength(String accountId) {
    User userRec = [ SELECT Id, ContactId FROM User WHERE Id
                    =:UserInfo.getUserId() LIMIT 1 ];
    AccountContactRelation acr = [
        SELECT Id,
        Relationship_Strength__c FROM AccountContactRelation WHERE ContactId
        =:userRec.ContactId AND AccountId
        =:accountId LIMIT 1
    ];
    return acr.Relationship_Strength__c == 'Primary';
}

@AuraEnabled 
public static DataTableResponse getDataTableAndCreatePersonnelRecordsIfNotExisting(String accountId, String fieldSetName,String objectName) {
    System.debug('###: getDataTableAndCreatePersonnelRecordsIfNotExisting');
    List<sObject> sObjectRecordsList = new List<sObject>();
    Boolean isEditable = getRelationshipStrength(accountId);
    try {
        DataTableResponse dataTableResponse = getDataTableColumnsAndFieldsToQueryList(objectName, fieldSetName,isEditable);
            String query = constructQueryString( objectName, dataTableResponse.fieldsListToQuery, accountId);
                System.debug('###: Query: ' + query);
                sObjectRecordsList = Database.query(query);
                System.debug('###: sObjectRecordsList: ' + sObjectRecordsList);
                if (sObjectRecordsList.isEmpty() && objectName == 'Salary_Survey_Line_Items__c') {
                    sObjectRecordsList = createSurveyLineItems(accountId, FIELD_SET_TO_LINE_ITEM_TYPE_MAP.get(fieldSetName));
                } else if (objectName == 'Salary_Survey_Line_Items__c') {
                    Map<String, Agency_Rate_Agreement_Line_Item__c> agencyAgreementMap = getAgreementLineItemMap(accountId);
                    for (Salary_Survey_Line_Items__c surveyLinetItem :(List<Salary_Survey_Line_Items__c>)sObjectRecordsList) {
                        System.debug('### Agree contains Key ' +agencyAgreementMap.containsKey(surveyLinetItem.Classification_Title__c));
                        surveyLinetItem.P_T_P__c = agencyAgreementMap.containsKey(surveyLinetItem.Classification_Title__c)
                                                    ? agencyAgreementMap.get(surveyLinetItem.Classification_Title__c).PTP__c: false;
                                                                                surveyLinetItem.MOU_MOA__c =
                        agencyAgreementMap.containsKey(surveyLinetItem.Classification_Title__c) ? agencyAgreementMap.get(surveyLinetItem.Classification_Title__c).OT__c: false;
                        System.debug('surveyLinetItem ' + surveyLinetItem.P_T_P__c);
                    }
                } else if (objectName == 'Agency_Non_Suppression_Line_Item__c') {
                    Map<String, Agency_Rate_Agreement_Line_Item__c> agencyAgreementMap = getAgreementLineItemMap(accountId);
                    for (Agency_Non_Suppression_Line_Item__c eachItem :(List<Agency_Non_Suppression_Line_Item__c>)sObjectRecordsList) {
                        eachItem.MOU_MOA_GBR__c = agencyAgreementMap.containsKey(eachItem.Classification_Title__c) ? agencyAgreementMap.get(eachItem.Classification_Title__c).PTP__c : false;
                    }
                }
                                                               
                if (objectName == 'Agency_Rate_Agreement_Line_Item__c') {
                    List<String> personnelNamesList = getNonSuppressionPersonnelNameList(accountId);
                    List<String> resourceTypeOptions = new List<String>();
                    for (CFAA_Line_Items__c eachItem : getCFAALineItems()) {
                        resourceTypeOptions.add(eachItem.Personnel_Role__c);
                    }
                    resourceTypeOptions.addAll(personnelNamesList);
                    dataTableResponse.agreementResourceTypeOptions = resourceTypeOptions;                                                
                }
                dataTableResponse.sObjectRecordsList = sObjectRecordsList;
                dataTableResponse.parentRecord = getParentRecord(accountId, objectName);
                 return dataTableResponse;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

private static SObject getParentRecord(String accountId, String objectName) {
    List<SObject> sObjectsList = new List<SObject>();
    if (objectName == 'Salary_Survey_Line_Items__c') {
        sObjectsList = [SELECT Id, Start_Date__c FROM Agency_Salary_Survey__c WHERE Account__c =: accountId AND Status__c NOT IN ('Expired', 'Revised')];
    } else if (objectName == 'Agency_Non_Suppression_Line_Item__c') {
        sObjectsList = [SELECT Id, Start_Date__c FROM Agency_Non_Suppression_Personnel__c WHERE Agency__c =: accountId  AND Approval_Status__c NOT IN ('Expired', 'Revised')];
    } else if (objectName == 'Agency_Special_Equipment_Line_Item__c') {
        sObjectsList = [SELECT Id, Start_Date__c FROM Agency_Special_Equipment__c WHERE Agency__c =: accountId  AND Approval_Status__c NOT IN ('Expired', 'Revised')];
    }
    if (sObjectsList.isEmpty()) {
        return null;
    } else {
        return sObjectsList[0];
    }
}

private
    static DataTableResponse getDataTableColumnsAndFieldsToQueryList(
        String objectName, String fieldSetName, Boolean isEditable) {
            DataTableResponse dataTableResponse = new DataTableResponse();
            List<DataTableColumns> dataTableColumnsList = new List<DataTableColumns>();
            List<String> fieldsListToBeQueried = new List<String>();
            for (Schema.FieldSetMember eachFieldSetMember :
                 getFieldSetMemberList(fieldSetName, objectName)) {
                     Boolean editable = isEditable;
                     String fieldPath = String.valueOf(eachFieldSetMember.getFieldPath());
                     String type = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
                     if (NON_EDITABLE_FIELD_SET.contains(fieldPath) && editable) {
                         editable = false;
                     }
                     if (type == 'date') {
                         type = 'date-local';
                     }
                     dataTableColumnsList.add(
                         new DataTableColumns(String.valueOf(eachFieldSetMember.getLabel()),
                                              fieldPath, type, editable, false));
                     fieldsListToBeQueried.add(
                         String.valueOf(eachFieldSetMember.getFieldPath()));
                 }
            dataTableResponse.dataTableColumnsList = dataTableColumnsList;
            dataTableResponse.fieldsListToQuery = fieldsListToBeQueried;
            dataTableResponse.isTableEditable = isEditable;
            return dataTableResponse;
        }

@AuraEnabled(cacheable = true) public static DataTableResponse
    getDataTableResponse(String accountId, String fieldSetName,
                         String objectName,
                         DataTableResponse dataTableResponse) {
                             System.debug('###": dataTableResponse: ' + dataTableResponse);
                             List<sObject> sObjectRecordsList = new List<sObject>();
                             String query = constructQueryString(
                                 objectName, dataTableResponse.fieldsListToQuery, accountId);
                             System.debug('### query: ' + query);
                             dataTableResponse.sObjectRecordsList = Database.query(query);
                             System.debug('###: sObjectRecordsList: ' +
                                          dataTableResponse.sObjectRecordsList);
                             
                             return dataTableResponse;
                         }

@AuraEnabled(cacheable = true) public static DataTableResponse
    getAdminDataTableResponse(String accountId, String fieldSetName,
                              String objectName) {
                                  fieldSetName = 'Administrative_Screen_Field_Set';
                                  objectName = 'Salary_Survey_Line_Items__c';
                                  List<DataTableColumns> dataTableColumnsList = new List<DataTableColumns>();
                                  DataTableResponse dataTableResponse = new DataTableResponse();
                                  List<String> fieldsListToBeQueried = new List<String>();
                                  List<sObject> sObjectRecordsList = new List<sObject>();
                                  for (Schema.FieldSetMember eachFieldSetMember :
                                       getFieldSetMemberList(fieldSetName, objectName)) {
                                           System.debug('###: NON_EDITABLE_FIELD_SET: ' + NON_EDITABLE_FIELD_SET);
                                           System.debug('###: eachFieldSetMember: ' + eachFieldSetMember);
                                           System.debug('###: eachFieldSetMember.getType(): ' +
                                                        String.valueOf(eachFieldSetMember.getType()).toLowerCase());
                                           Boolean editable = true;
                                           String fieldPath = String.valueOf(eachFieldSetMember.getFieldPath());
                                           System.debug('###: fieldPath: ' + fieldPath);
                                           if (NON_EDITABLE_FIELD_SET.contains(fieldPath)) {
                                               editable = false;
                                           }
                                           System.debug('###: editable: ' + editable);
                                           String type = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
                                           if (type == 'date') {
                                               type = 'date-local';
                                           }
                                           dataTableColumnsList.add(
                                               new DataTableColumns(String.valueOf(eachFieldSetMember.getLabel()),
                                                                    fieldPath, type, editable, false));
                                           fieldsListToBeQueried.add(
                                               String.valueOf(eachFieldSetMember.getFieldPath()));
                                       }
                                  if (dataTableColumnsList.isEmpty()) {
                                      return null;
                                  }
                                  if (!fieldsListToBeQueried.isEmpty()) {
                                      String query =
                                          constructQueryString(objectName, fieldsListToBeQueried, accountId);
                                      System.debug('### query: ' + query);
                                      sObjectRecordsList = Database.query(query);
                                      if (sObjectRecordsList.isEmpty() && fieldSetName == FIELD_SET_PERSONNEL) {
                                          //  sObjectRecordsList = createSurveyLineItems(accountId);
                                      }
                                      dataTableResponse.sObjectRecordsList = sObjectRecordsList;
                                      System.debug('###: sObjectRecordsList: ' +
                                                   dataTableResponse.sObjectRecordsList);
                                      dataTableResponse.dataTableColumnsList = dataTableColumnsList;
                                  }
                                  return dataTableResponse;
                              }

@AuraEnabled public static Salary_Survey_Line_Items__c
    getSurveyLineItemRecord(Id recordId) {
        system.debug(recordId);
        try {
            return [ SELECT Id, Base_Rates__c, Revised_Rate__c,
                    Current_Rate__c From Salary_Survey_Line_Items__c Where Id
                    =:recordId ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

@AuraEnabled public static string upsertSurveyLineItem(String data,
                                                       String accountId,
                                                       String effectiveDate) {
                                                           System.debug('###: data: ' + data);
                                                           System.debug('###: accountId: ' + accountId);
                                                           // String formattedData = data.replaceAll('"Effective_Date__c":""',
                                                           // '"Effective_Date__c":'+'"' +String.valueOf(System.today()) + '"');
                                                           // System.debug('###: formattedData: ' + formattedData);
                                                           try {
                                                               List<Salary_Survey_Line_Items__c> lineItemsForUpdateList =
                                                                   (List<Salary_Survey_Line_Items__c>)JSON.deserialize(
                                                                       data, List<Salary_Survey_Line_Items__c>.class);
                                                               if (String.isNotBlank(effectiveDate)) {
                                                                   for (Salary_Survey_Line_Items__c eachItem : lineItemsForUpdateList) {
                                                                       eachItem.Effective_Date__c = Date.valueOf(effectiveDate);
                                                                       if (eachItem.Revised_Rate__c == null) {
                                                                           eachItem.Revised_Rate__c = eachItem.Base_Rates__c;
                                                                       }
                                                                   }
                                                               }
                                                               System.debug('###: lineItemsForUpdateList: ' + lineItemsForUpdateList);
                                                               upsert lineItemsForUpdateList;
                                                               Agency_Salary_Survey__c assRec = getAgencySalarySurvey(accountId);
                                                               Boolean isRecChanged = false;
                                                               if (String.isBlank(assRec.Status__c)) {
                                                                   isRecChanged = true;
                                                                   assRec.Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
                                                               } else if (assRec.Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED) {
                                                                   MARSSalarySurveyHelper.cloneTheSurveyLineItems(assRec.Id);
                                                               }
                                                               if (isRecChanged) {
                                                                   update assRec;
                                                               }
                                                               return 'Success';
                                                           } catch (Exception e) {
                                                               return e.getMessage();
                                                           }
                                                       }

@AuraEnabled public static string upsertNonPersonnelLineItem(
    Object data, String accountId, String effectiveDate) {
        try {
            List<Agency_Non_Suppression_Line_Item__c> lineItemsForUpdateList =
                (List<Agency_Non_Suppression_Line_Item__c>)JSON.deserialize(
                    JSON.serialize(data),
                    List<Agency_Non_Suppression_Line_Item__c>.class);
            System.debug('###: lineItemsForUpdateList: ' + lineItemsForUpdateList);
            upsert lineItemsForUpdateList;
            Agency_Non_Suppression_Personnel__c anspRec =
                getNonSuppressionPersonnelAgency(accountId);
            System.debug('###: anspRec: ' +  anspRec);
            if (anspRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW) {
              anspRec.Start_Date__c = Date.valueOf(effectiveDate);
            update anspRec;   
            }
           
            if (anspRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED) {
                MARSNonSuppressionPersnlHelper.cloneNonSuppressionLineItems(anspRec.Id, Date.valueOf(effectiveDate)>System.today(), Date.valueOf(effectiveDate));
            }
            
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

@AuraEnabled public static string upsertSpecialEquipLineItem(
    Object data, String accountId, String effectiveDate) {
        try {
            List<Agency_Special_Equipment_Line_Item__c> lineItemsForUpdateList =
                (List<Agency_Special_Equipment_Line_Item__c>)JSON.deserialize(
                    JSON.serialize(data),
                    List<Agency_Special_Equipment_Line_Item__c>.class);
            System.debug('###: lineItemsForUpdateList: ' + lineItemsForUpdateList);
            upsert lineItemsForUpdateList;
            Agency_Special_Equipment__c aseRec = getAgencySpecialEquipment(accountId);
            aseRec.Start_Date__c = Date.valueOf(effectiveDate);
            Boolean isRecUpdate = false;
            if (String.isBlank(aseRec.Approval_Status__c)) {
                aseRec.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
                 aseRec.Start_Date__c = Date.valueOf(effectiveDate);
                isRecUpdate = true;
            } else if (aseRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW) {
                 aseRec.Start_Date__c = Date.valueOf(effectiveDate);
                isRecUpdate = true;
            } else if (aseRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED) {
                cloneTheSurveyLineItems(aseRec.Id,Date.valueOf(effectiveDate)>System.today(),Date.valueOf(effectiveDate));
            }
            if (isRecUpdate) {
               update aseRec; 
            }
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

@AuraEnabled public static string upsertAgencyAgreementLineItem(
    Object data, String accountId) {
        try {
            List<Agency_Rate_Agreement_Line_Item__c> lineItemsForUpdateList =
                (List<Agency_Rate_Agreement_Line_Item__c>)JSON.deserialize(
                    JSON.serialize(data),
                    List<Agency_Rate_Agreement_Line_Item__c>.class);
            System.debug('###: lineItemsForUpdateList: ' + lineItemsForUpdateList);
            upsert lineItemsForUpdateList;
            Agency_Rate_Agreement__c araRec = getAgreementLineItem(accountId);
            if (araRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED) {
                MarsAgencyRateAgreementHelper.cloneNonSuppressionLineItems(araRec.Id);
            }
            
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

private
    static Map<String, Agency_Rate_Agreement_Line_Item__c>
    getAgreementLineItemMap(String accountId) {
        Map<String, Agency_Rate_Agreement_Line_Item__c> agencyAgreementMap =
            new Map<String, Agency_Rate_Agreement_Line_Item__c>();
        for (Agency_Rate_Agreement_Line_Item__c eachRecord :
             [ SELECT Id, Name, OT__c,
              PTP__c FROM Agency_Rate_Agreement_Line_Item__c Where
              Agency_Rate_Agreement__r.Agency__c =:accountId ]) {
                  for (String name : eachRecord.Name.split(';')) {
                      agencyAgreementMap.put(name, eachRecord);
                  }
              }
        return agencyAgreementMap;
    }

private
    static List<String> getNonSuppressionPersonnelNameList(String accountId) {
        List<String> activePersonnelList = new List<String>();
        for (Agency_Non_Suppression_Line_Item__c eachItem :
             [ Select Id, Classification_Title__c,
              Name From Agency_Non_Suppression_Line_Item__c Where
              Agency_Non_Suppression_Personnel__r.Agency__c
              =:accountId AND Status__c = 'Active' ]) {
                  activePersonnelList.add(eachItem.Classification_Title__c);
              }
        return activePersonnelList;
    }

private
    static List<Salary_Survey_Line_Items__c> createSurveyLineItems(
        String accountId, String lineItemType) {
            List<Salary_Survey_Line_Items__c> surveyLineItemsList =
                new List<Salary_Survey_Line_Items__c>();
            List<String> personnelRole = new List<String>();
            Agency_Salary_Survey__c ass = getAgencySalarySurvey(accountId);
            Map<String, Agency_Rate_Agreement_Line_Item__c> agencyAgreementMap =
                getAgreementLineItemMap(accountId);
            SYstem.debug('#####agencyAgreementMap:' + agencyAgreementMap);
            if (lineItemType.equals(LINE_ITEM_TYPE_PERSONNEL)) {
                for (CFAA_Line_Items__c eachRecord : getCFAALineItems()) {
                    surveyLineItemsList.add(new Salary_Survey_Line_Items__c(
                        Agency_Salary_Survey__c = ass.Id,
                        // Account__c = ass.Account__c,
                        Line_Item_Type__c = LINE_ITEM_TYPE_PERSONNEL,
                        Classification_Title__c = eachRecord.Personnel_Role__c,
                        Base_Rates__c = eachRecord.Straight_Time_Rate__c,
                        Order__c = eachRecord.Order_No__c, CFAA__c = eachRecord.CFAA__c));
                }
            }
            
            /*else if (lineItemType.equals(LINE_ITEM_TYPE_NON_SUPRESSION)) {
Set<String> classTypesSet =
new Set<String>{'Non-Supression Type 1', 'Non-Supression Type 2',
'Non-Supression Type 3'};
for (String eachRecord : classTypesSet) {
surveyLineItemsList.add(new Salary_Survey_Line_Items__c(
Agency_Salary_Survey__c = ass.Id,
//Account__c = accountId,
Line_Item_Type__c = LINE_ITEM_TYPE_NON_SUPRESSION,
Classification_Title__c = eachRecord,
Effective_Date__c = System.today()));
}
} else if (lineItemType.equals(LINE_ITEM_TYPE_SPECIAL_EQUIPMENT)) {
for (String eachOption : getSpecialEquipmentTypePicklistOptions()) {
surveyLineItemsList.add(new Salary_Survey_Line_Items__c(
Agency_Salary_Survey__c = ass.Id,
Special_Equipment_Type__c = eachOption,
//Account__c = accountId,
Line_Item_Type__c = LINE_ITEM_TYPE_SPECIAL_EQUIPMENT,
Effective_Date__c = System.today()));
}
} */ system.debug('surveyLineItemsList: ' + surveyLineItemsList);
            Database.insert(surveyLineItemsList);
            for (Salary_Survey_Line_Items__c surveyLinetItem : surveyLineItemsList) {
                surveyLinetItem.P_T_P__c =
                    agencyAgreementMap.containsKey(
                        surveyLinetItem.Classification_Title__c)
                    ? agencyAgreementMap.get(surveyLinetItem.Classification_Title__c)
                    .OT__c
                    : false;
                surveyLinetItem.MOU_MOA__c =
                    agencyAgreementMap.containsKey(
                        surveyLinetItem.Classification_Title__c)
                    ? agencyAgreementMap.get(surveyLinetItem.Classification_Title__c)
                    .PTP__c
                    : false;
                System.debug('surveyLinetItem ' + surveyLinetItem.P_T_P__c);
            }
            
            return surveyLineItemsList;
        }

/* public
static List<String> getSpecialEquipmentTypePicklistOptions() {
List<String> options = new List<String>();
Schema.DescribeFieldResult fieldResult =
Salary_Survey_Line_Items__c.Special_Equipment_Type__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
for (Schema.PicklistEntry f : ple) {
options.add(f.getValue());
}
return options;
}*/

private
    static List<CFAA_Line_Items__c> getCFAALineItems() {
        return [
            SELECT Id, Personnel_Role__c, Straight_Time_Rate__c, Order_No__c,
            CFAA__r.Start_Date__c, CFAA__r.END_Date__c,
            CFAA__c FROM CFAA_Line_Items__c Where CFAA__c != null and
            CFAA__r.Start_Date__c <= today and CFAA__r.END_Date__c >= today and
            RecordType.Name = 'Personnel Base Rate' ORDER BY Order_No__c ASC
        ];
    }

private
    static Agency_Salary_Survey__c getAgencySalarySurvey(String accountId) {
        List<Agency_Salary_Survey__c> agentSalarySurvey =
            [ Select Id, Status__c From Agency_Salary_Survey__c Where Account__c
             =:accountId and Status__c != 'Expired' LIMIT 1 ];
        System.debug('###: agentSalarySurvey: ' + agentSalarySurvey);
        if (agentSalarySurvey.isEmpty()) {
            Agency_Salary_Survey__c ass = new Agency_Salary_Survey__c();
            ass.Account__c = accountId;
            ass.Name = 'Salary Survey For Agency ' + System.now();
            // ass.Status__c=MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
            Database.insert(ass);
            return ass;
        }
        return agentSalarySurvey[0];
    }

@AuraEnabled public static Salary_Survey_Line_Items__c createSSLI(
    Salary_Survey_Line_Items__c ssli, String accountId, String fieldSetName) {
        system.debug('###: sssli: ' + ssli + '---------' + accountId);
        ssli.Agency_Salary_Survey__c = getAgencySalarySurvey(accountId).Id;
        ssli.Line_Item_Type__c = FIELD_SET_TO_LINE_ITEM_TYPE_MAP.get(fieldSetName);
        //ssli.Name = ssli.Classification_Title__c;
        ssli.Effective_Date__c = System.today();
        System.debug('###ssli: ' + ssli);
        insert ssli;
        system.debug(ssli);
        return ssli;
    }

public
    class DataTableResponse {
        public
            DataTableResponse() {
                this.dataTableColumnsList = dataTableColumnsList;
                this.sObjectRecordsList = sObjectRecordsList;
            }
        
        @AuraEnabled public List<DataTableColumns> dataTableColumnsList {
            get;
            set;
        }
        @AuraEnabled public List<sObject> sObjectRecordsList {
            get;
            set;
        }
        @AuraEnabled public List<String> fieldsListToQuery {
            get;
            set;
        }
        @AuraEnabled public Boolean isTableEditable {
            get;
            set;
        }
        @AuraEnabled public List<String> agreementResourceTypeOptions {
            get;
            set;
        }
        @AuraEnabled public sObject parentRecord {get; set;}
    }

public class DataTableColumns {
    public
        DataTableColumns(String label, String fieldName, String fieldType,
                         Boolean editable, Boolean sortable) {
                             this.label = label;
                             this.fieldName = fieldName;
                             this.type = fieldType;
                             this.editable = editable;
                             this.sortable = sortable;
                         }
    @AuraEnabled public String label {
        get;
        set;
    }
    @AuraEnabled public String fieldName {
        get;
        set;
    }
    @AuraEnabled public String type {
        get;
        set;
    }
    @AuraEnabled public Boolean editable {
        get;
        set;
    }
    @AuraEnabled public Boolean sortable {
        get;
        set;
    }
}

private static String
    constructQueryString(String objectName, List<String> fieldsListToBeQueried,
                         String accountId) {
                             string wherecondition;
                             String expVal = 'Expired';
                             if (objectName == 'Salary_Survey_Line_Items__c') {
                                 wherecondition = ' WHERE Agency_Salary_Survey__r.Account__c =\'' +
                                     accountId + '\' AND Status__c !=\'' + expVal +
                                     '\' Order By Order__c ASC';
                             } else if (objectName == 'Agency_Rate_Agreement_Line_Item__c') {
                                 wherecondition =
                                     ' WHERE Agency_Rate_Agreement__r.Agency__c =\'' + accountId + '\'';
                             } else if (objectName == 'Agency_Special_Equipment_Line_Item__c') {
                                 wherecondition = ' WHERE Agency_Special_Equipment__r.Agency__c =\'' +
                                     accountId + '\' AND Status__c !=\'' + expVal + '\'';
                             } else if (objectName == 'Agency_Non_Suppression_Line_Item__c') {
                                 wherecondition =
                                     ' WHERE Agency_Non_Suppression_Personnel__r.Agency__c =\'' +
                                     accountId + '\' AND Status__c !=\'' + expVal + '\'';
                             }
                             return 'SELECT Id, ' + String.join(fieldsListToBeQueried, ',') + ' FROM ' +
                                 objectName + wherecondition;
                         }

private
    static Agency_Rate_Agreement__c getAgreementLineItem(String accountId) {
        List<Agency_Rate_Agreement__c> agencyRateAgreement =
            [ Select Id,
             Approval_Status__c from Agency_Rate_Agreement__c Where Agency__c
             =:accountId AND Approval_Status__c NOT IN ('Expired', 'Revised') Limit 1 ];
        if (agencyRateAgreement.isEmpty()) {
            Agency_Rate_Agreement__c arg = new Agency_Rate_Agreement__c();
            arg.Agency__c = accountId;
            arg.Name = 'Agency Rate Agreement ' + System.now();
            arg.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
            Database.insert(arg);
            return arg;
        }
        return agencyRateAgreement[0];
    }

private
    static Agency_Non_Suppression_Personnel__c getNonSuppressionPersonnelAgency(
        String accountId) {
            List<Agency_Non_Suppression_Personnel__c> nonSuppressionPersonnelAgency =
                [ Select Id, Approval_Status__c from Agency_Non_Suppression_Personnel__c
                 Where Agency__c =:accountId AND Approval_Status__c NOT IN ('Expired', 'Revised') Limit 1 ];
            if (nonSuppressionPersonnelAgency.isEmpty()) {
                Agency_Non_Suppression_Personnel__c ansp =
                    new Agency_Non_Suppression_Personnel__c();
                ansp.Agency__c = accountId;
                ansp.Name = 'Agency Non Personnel ' + System.now();
                ansp.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
                Database.insert(ansp);
                return ansp;
            }
            return nonSuppressionPersonnelAgency[0];
        }

private
    static Agency_Special_Equipment__c getAgencySpecialEquipment(
        String accountId) {
            List<Agency_Special_Equipment__c> agencySpecialEquipment =
                [ Select Id,
                 Approval_Status__c from Agency_Special_Equipment__c Where Agency__c
                 =:accountId AND Approval_Status__c NOT IN ('Expired', 'Revised') Limit 1 ];
            if (agencySpecialEquipment.isEmpty()) {
                Agency_Special_Equipment__c ase = new Agency_Special_Equipment__c();
                ase.Agency__c = accountId;
                ase.Name = 'Agency Special Equipment ' + System.now();
                ase.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
                Database.insert(ase);
                /*Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setComments('Submitting approval request using Trigger');
req.setObjectId(ase.id);
Approval.ProcessResult result = Approval.process(req);
return ase;*/
            }
            return agencySpecialEquipment[0];
        }

@AuraEnabled public static Agency_Rate_Agreement_Line_Item__c
    createAgreeLineItem(Agency_Rate_Agreement_Line_Item__c objRec,
                        String accountId) {
                            System.debug('###: objRec: ' + objRec);
                            Agency_Rate_Agreement__c araRec = getAgreementLineItem(accountId);
                            objRec.Agency_Rate_Agreement__c = araRec.Id;
                            insert objRec;
                            update araRec;
                            
                            if (araRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED) {
                                
                                MarsAgencyRateAgreementHelper.cloneNonSuppressionLineItems(araRec.Id);
                            }
                            return objRec;
                        }

@AuraEnabled public static Agency_Non_Suppression_Line_Item__c
    createNonSuppressionPersonnelLineItem(
        Agency_Non_Suppression_Line_Item__c objRec, String accountId, String effectiveDate) {
            System.debug('###: objRec: ' + objRec);
            Agency_Non_Suppression_Personnel__c anspRec =
                getNonSuppressionPersonnelAgency(accountId);
            objRec.Agency_Non_Suppression_Personnel__c = anspRec.Id;
            objRec.Effective_Date__c = Date.valueOf(effectiveDate);
             if (anspRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW) {
            anspRec.Start_Date__c = Date.valueOf(effectiveDate);
             update anspRec;   
             }
           insert objRec;
            if (anspRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED) {
                MARSNonSuppressionPersnlHelper.cloneNonSuppressionLineItems(anspRec.Id, Date.valueOf(effectiveDate)>System.today(), Date.valueOf(effectiveDate));
            }
            return objRec;
        }

    @AuraEnabled 
    public static Agency_Special_Equipment_Line_Item__c createSpecialEquipLineItem(Agency_Special_Equipment_Line_Item__c objRec,
                                String accountId, String effectiveDate) {
                                    System.debug('###: objRec: ' + objRec);
                                    Agency_Special_Equipment__c parentRec =
                                    getAgencySpecialEquipment(accountId);
                                    objRec.Agency_Special_Equipment__c = parentRec.Id;
                                    objRec.Effective_Date__c = Date.valueOf(effectiveDate);
                                    insert objRec;
                                                                    
                                    if (parentRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW) {
                                            parentRec.Start_Date__c = Date.valueOf(effectiveDate); 
                                            update parentRec;
                                    }
                                    if (parentRec.Approval_Status__c == MARS_Constants.SURVEY_STATUS_REVIEWED){
                                        cloneTheSurveyLineItems(parentRec.Id, Date.valueOf(effectiveDate)>System.today(), Date.valueOf(effectiveDate));
                                        }
                                    return objRec;
    }                             

    @AuraEnabled  
    public static List<ContentDocument> getFiles(String recordId){ 
        Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }    
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds];        
    } 
    
    public static void cloneTheSurveyLineItems(Id surveyIds,boolean isFutureDate,Date effectiveDate) {
        Map<Id, List<Agency_Special_Equipment_Line_Item__c>> surveyWithLineItems =
            new Map<Id, List<Agency_Special_Equipment_Line_Item__c>>();
        String status='';
        List<Agency_Special_Equipment__c> updateAgencySurvey =
            new List<Agency_Special_Equipment__c>();
        List<Agency_Special_Equipment__c> InsertAgencySurvey =
            new List<Agency_Special_Equipment__c>();
        for (Agency_Special_Equipment__c assc :
             [ SELECT Id, Approval_Status__c,Agency__c, Start_Date__c, END_Date__c,
              Revised_From_Id__c,
              (SELECT Id,
               Current_Rate__c, Effective_Date__c,
               Revised_Rate__c,Special_Equipment_Type__c from Agency_Special_Equipment_Line_Items__r)
              FROM Agency_Special_Equipment__c WHERE Id =: surveyIds ]) {
                  surveyWithLineItems.put(assc.id, assc.Agency_Special_Equipment_Line_Items__r);
                  Agency_Special_Equipment__c aupdate = new Agency_Special_Equipment__c();
                  aupdate.Id = assc.Id;
                  aupdate.END_Date__c =effectiveDate.addDays(-1);
                  if(isFutureDate){
                      status='Revised'; 
                  }else{
                      status='Expired'; 
                  }
                  aupdate.Approval_Status__c = status;

                  updateAgencySurvey.add(aupdate);
                  // Inserting new Parent
                  Agency_Special_Equipment__c ainsert = new Agency_Special_Equipment__c();
                  ainsert.Name = 'Special Equipment For Agency :' + system.now();
                  ainsert.Agency__c = assc.Agency__c;
                  ainsert.Revised_From_Id__c = assc.Id;
                  ainsert.Start_Date__c = effectiveDate;
                  InsertAgencySurvey.add(ainsert);
              }
        
        if (InsertAgencySurvey.size() > 0) {
            insert InsertAgencySurvey;
            Map<Id, Id> oldwithNewId = new Map<Id, Id>();
            List<Agency_Special_Equipment__c> finalAgencySurvey =
                new List<Agency_Special_Equipment__c>();
            for (Agency_Special_Equipment__c ass : InsertAgencySurvey) {
                ass.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
                finalAgencySurvey.add(ass);
                oldwithNewId.put(ass.Revised_From_Id__c, ass.Id);
            }
            List<Agency_Special_Equipment_Line_Item__c> insertLineItems =
                new List<Agency_Special_Equipment_Line_Item__c>();
            List<Agency_Special_Equipment_Line_Item__c> oldLineItems =
                new List<Agency_Special_Equipment_Line_Item__c>();
            for (Id parentOldSurvey : surveyWithLineItems.keySet()) {
                if (oldwithNewId.containsKey(parentOldSurvey)) {
                    for (Agency_Special_Equipment_Line_Item__c ssl :
                         surveyWithLineItems.get(parentOldSurvey)) {
                             Agency_Special_Equipment_Line_Item__c newLineItem =
                                 ssl.clone(false, false, false, false);
                             ssl.Status__c = status;
                             oldLineItems.add(ssl);
                             newLineItem.Agency_Special_Equipment__c =
                                 oldwithNewId.get(parentOldSurvey);
                             insertLineItems.add(newLineItem);
                         }
                }
            }
            try {
                insert insertLineItems;
                update oldLineItems;
                update finalAgencySurvey;
                update updateAgencySurvey;
            } catch (exception e) {
                system.debug('-------------' + e.getMessage());
            }
        }
    }
}