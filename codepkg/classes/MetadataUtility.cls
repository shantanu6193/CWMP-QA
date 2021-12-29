//get user app name and fetch metadata 
public inherited sharing class MetadataUtility extends TriggerHandler {
    public static List<Trigger_Config__mdt> triggerConfigs;
    
    public MetadataUtility() {
        
    }

    //static initialization 
    {
        triggerConfigs = new List<Trigger_Config__mdt>();
    }

    //Fetch all the metadata Types related to trigger Configuration and SObject Config
    public static Map<String, Object> fetchAllMetadataTypes(String sobjectName) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Object sobjectConfigs = [SELECT ObjectAPIName__c, Bypass_Trigger_Execution__c,
                                        Applicable_Trigger_Handlers__c,Skip_Validation_Rules__c 
                                    FROM SObject__mdt 
                                    WHERE ObjectAPIName__c = :sobjectName LIMIT 1];
        List<Object> triggerConfigs = [SELECT Criteria_Name__c,Criteria_Operator__c,
                                        Criteria_Field_API_Name__c,
                                        Criteria_Value__c,Id,
                                        Is_Active__c,Label
                                    FROM Trigger_Config__mdt 
                                    WHERE SObject__r.ObjectApiName__c = :sobjectName];
        List<Object> validationRuleConfigs = [SELECT Label, Is_Active__c, SObject__c, Error_Message__c
                                                FROM Validation_Rule_Config__mdt
                                                WHERE SObject__r.ObjectAPIName__c = :sobjectName AND Is_Active__c = true];
        returnMap.put('SobjectConfig', sobjectConfigs);
        returnMap.put('ValidationRuleConfigs', validationRuleConfigs);
        returnMap.put('TriggerConfigs', triggerConfigs);
        return returnMap;
    }

    //get current app name for logged in user
    public static String getCurrentAppName() {
        UserAppInfo userApp = [SELECT Id, AppDefinitionId
                                        FROM UserAppInfo WHERE UserId = :UserInfo.getUserId()  ORDER BY CreatedDate DESC LIMIT 1];
        String appName = [SELECT DurableId, Label, DeveloperName FROM AppDefinition
                                            Where DurableId = :userApp.AppDefinitionId LIMIT 1].DeveloperName;
        return appName;
    }

    //get validation rule for sobject
    public static List<Validation_Rule_Config__mdt> getValidationRules(String sobjectName) {
        return [SELECT Label, Is_Active__c, SObject__c FROM Validation_Rule_Config__mdt WHERE SObject__r.ObjectAPIName__c = :sobjectName];
    }

    //Get the application Specific metadata type configuration data 
    public static List<Application_Config__mdt> fetchApplicationConfig() {
        List<Application_Config__mdt> applicationConfigMdtList = [SELECT Id, Bypass_Trigger_Execution__c,
                                                                    Project__c, Sequence__c,Class_to_Execute__c
                                                                    FROM Application_Config__mdt
                                                                    WHERE Bypass_Trigger_Execution__c = false
                                                                    ORDER BY Sequence__c];
        return applicationConfigMdtList;
    }

    
}