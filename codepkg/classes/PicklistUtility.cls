/***********************************************************************************************************************************
* Class Name   : PicklistUtility
* Description  : This class for picklist values
* Author       : Pankaj
* Created On   : 04/21/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/21/2020      Initial Implementation
**************************************************************************************************************************************/


public with sharing class PicklistUtility {

    /***********************************************
    * Method Name : getPicklistOptions
    * Author : Pankaj
    * Inputs : String objectName, String fieldName
    * Description: This method return list of map of string from specified object name and field name
    *********************************************/
    public static List<Map<String, String>> getPicklistOptions(String objectName, String fieldName) {
        Schema.SObjectField sObjectField = SkyWalkerUtility.getSObjectField(objectName, fieldName);

        if (sObjectField == null) return null;

        List<Map<String, String>> pickListOptions = new List<Map<String, String>>();
        List<Schema.PicklistEntry> picklistEntries = sObjectField.getDescribe().getPicklistValues();

        for (Schema.PicklistEntry f : picklistEntries) {
            Map<String, String> options = new Map<String, String>();
            options.put('value', f.getValue());
            options.put('label', f.getLabel());
            pickListOptions.add(options);
        }
        return pickListOptions;
    }

    /***********************************************
    * Method Name : getPicklistOptions
    * Author : Pankaj
    * Inputs : Schema.SObjectType sObjectType, String fieldName
    * Description: This method return list of map of strings from specified object type and field name
    *********************************************/
    public static List<Map<String, String>> getPicklistOptions(Schema.SObjectType sObjectType, String fieldName) {
        Schema.SObjectField sObjectField = SkyWalkerUtility.getSObjectField(sObjectType, fieldName);

        if (sObjectField == null) return null;
        List<Map<String, String>> pickListOptions = new List<Map<String, String>>();
        List<Schema.PicklistEntry> picklistEntries = sObjectField.getDescribe().getPicklistValues();

        for (Schema.PicklistEntry f : picklistEntries) {
            Map<String, String> options = new Map<String, String>();
            options.put('value', f.getValue());
            options.put('label', f.getLabel());
            pickListOptions.add(options);
        }
        return pickListOptions;
    }

    /*public static Map<String, List<Map<String, String>>> getDependentPicklistOptions(Schema.SObjectType sObjectType, String fieldName) {

        Map<String, List<Map<String, String>>> dependentPicklistValuesMap = new Map<String, List<Map<String, String>>>();

        Schema.SObjectField sObjectField = SkyWalkerUtility.getSObjectField(sObjectType, fieldName);

        if (sObjectField == null) return null;

        Map<Object, List<String>> dependentPicklistValues = PickListUtility.getDependentPicklistValues(sObjectField);

        for (Object controllingValue : dependentPicklistValues.keySet()) {
            List<String> dependentValues = dependentPicklistValues.get(controllingValue);
            String controllingString = controllingValue + '';
            List<Map<String, String>> pickListOptions = new List<Map<String, String>>();
            for (String dependentValue : dependentValues) {
                Map<String, String> options = new Map<String, String>();
                options.put('value', dependentValue);
                options.put('label', dependentValue);
                pickListOptions.add(options);
            }
            dependentPicklistValuesMap.put(controllingString, pickListOptions);
        }
        return dependentPicklistValuesMap;
    }

    public static Map<String, List<Map<String, String>>> getDependentPicklistOptions(String objectName, String fieldName) {

        Map<String, List<Map<String, String>>> dependentPicklistValuesMap = new Map<String, List<Map<String, String>>>();

        Schema.SObjectField sObjectField = SkyWalkerUtility.getSObjectField(objectName, fieldName);

        if (sObjectField == null) return null;

        Map<Object, List<String>> dependentPicklistValues = PickListUtility.getDependentPicklistValues(sObjectField);

        for (Object controllingValue : dependentPicklistValues.keySet()) {
            List<String> dependentValues = dependentPicklistValues.get(controllingValue);
            String controllingString = controllingValue + '';
            List<Map<String, String>> pickListOptions = new List<Map<String, String>>();
            for (String dependentValue : dependentValues) {
                Map<String, String> options = new Map<String, String>();
                options.put('value', dependentValue);
                options.put('label', dependentValue);
                pickListOptions.add(options);
            }
            dependentPicklistValuesMap.put(controllingString, pickListOptions);
        }
        return dependentPicklistValuesMap;
    }

    public static Map<Object, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
                (control.getType() == Schema.DisplayType.Boolean
                        ? null
                        : control.getPicklistValues()
                );

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) if (entry.isActive()) {
            List<String> base64chars =
                    String.valueOf
                            (((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')
                            ).split('');
            for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                Object controlValue =
                        (controlEntries == null
                                ? (Object) (index == 1)
                                : (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
                if (controlValue == null
                        || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0
                        ) continue;
                if (!dependentPicklistValues.containsKey(controlValue)) {
                    dependentPicklistValues.put(controlValue, new List<String>());
                }
                dependentPicklistValues.get(controlValue).add(entry.getLabel());
            }
        }
        return dependentPicklistValues;
    }*/
}