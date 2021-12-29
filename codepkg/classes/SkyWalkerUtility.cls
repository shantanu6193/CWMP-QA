/***********************************************************************************************************************************
* Class Name   : SkyWalkerUtility
* Description  : This class for get the utility
* Author       : Pankaj
* Created On   : 04/21/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                04/21/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class SkyWalkerUtility {

    /*
    Read the docs here
    https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_SObjectType.htm#apex_class_Schema_SObjectType
    */
    /***********************************************
    * Method Name : getSObjectType
    * Author : Pankaj
    * Inputs : String objectName
    * Description: This method return Schema.SObjectType of specified object
    *********************************************/
    public static Schema.SObjectType getSObjectType(String objectName) {
        return Schema.getGlobalDescribe().get(objectName) == null ? null : Schema.getGlobalDescribe().get(objectName);
    }

    /*
    Read the docs here
    https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_SObjectField.htm#apex_class_Schema_SObjectField
    */
    /***********************************************
    * Method Name : getSObjectField
    * Author : Pankaj
    * Inputs : String objectName, String fieldName
    * Description: This method return Schema.SObjectField of specified object and field
    *********************************************/
    public static Schema.SObjectField getSObjectField(String objectName, String fieldName) {
        Schema.SObjectType sObjectType = SkyWalkerUtility.getSObjectType(objectName);

        if (sObjectType == null) return null;

        Map<String, Schema.SObjectField> sobjTypeFieldMap = sObjectType.getDescribe().fields.getMap();
        if (!sobjTypeFieldMap.containsKey(fieldName)) return null;

        return sobjTypeFieldMap.get(fieldName);
    }

    /***********************************************
    * Method Name : getSObjectPickListFields
    * Author : Pankaj
    * Inputs : String objectName
    * Description: This method return list of map of strings picklist values of specified object
    *********************************************/
    public static List<Map<String,String>>  getSObjectPickListFields(String objectName) {
        List<Map<String,String>>  sobjectPicklistFields = new List<Map<String,String>> ();
        Schema.SObjectType sObjectType = SkyWalkerUtility.getSObjectType(objectName);

        System.debug('sObjectType=='+sObjectType);

        if (sObjectType == null) return null;

        Map<String, Schema.SObjectField> sobjTypeFieldMap = sObjectType.getDescribe().fields.getMap();
        System.debug('sobjTypeFieldMap=='+sobjTypeFieldMap);
        for(Schema.SObjectField field : sobjTypeFieldMap.values()){
            System.debug('type=='+field.getDescribe().getType());
            if(field.getDescribe().getType().name() == 'PICKLIST'){
                Map<String,String> picklistField = new Map<String,String>();
                picklistField.put('Value',field.getDescribe().getName());
                picklistField.put('Label',field.getDescribe().getLabel());
                sobjectPicklistFields.add(picklistField);
            }
        }

        return sobjectPicklistFields;
    }

    /***********************************************
    * Method Name : getSObjectField
    * Author : Pankaj
    * Inputs : Schema.SObjectType sObjectType, String fieldName
    * Description: This method return Schema.SObjectField
    *********************************************/
    public static Schema.SObjectField getSObjectField(Schema.SObjectType sObjectType, String fieldName) {
        Map<String, Schema.SObjectField> sobjTypeFieldMap = sObjectType.getDescribe().fields.getMap();
        if (!sobjTypeFieldMap.containsKey(fieldName)) return null;
        return sobjTypeFieldMap.get(fieldName);
    }

    /***********************************************
    * Method Name : convertStringToDate
    * Author : Pankaj
    * Inputs : String dateString
    * Description: This method convert string to date and return date
    *********************************************/
    public static Date convertStringToDate(String dateString) {
        try {
            return dateString == null ? null : Date.parse(dateString.replaceAll('-', '/'));
        } catch (Exception e) {
            return null;
        }
    }

    /***********************************************
    * Method Name : convertStringToDecimal
    * Author : String decimalString
    * Inputs : String decimalString
    * Description: This method convert string to Decimal value and return decimal value 
    *********************************************/
    public static Decimal convertStringToDecimal(String decimalString) {
        return decimalString == null ? null : Decimal.valueOf(decimalString);
    }

    /***********************************************
    * Method Name : generateToken
    * Author : Pankaj
    * Inputs : Integer length
    * Description: This method return string of token
    *********************************************/
    public static String generateToken(Integer length) {
        DateTime d = System.now();
        Long ll = d.getTime();
        String newS = '' + ll;
        String algorithmName = 'HMacSHA1';
        Blob mac = Crypto.generateMac(algorithmName, Blob.valueOf(newS), Blob.valueOf(String.valueOf(Math.random() * 10000)));

        String token = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');
        token = token.replaceAll('%', 'p');
        Integer tokenLength = token.length();
        if (length > 0 && token.length() > length) {
            Integer startingPnt = tokenLength - length;
            return token.substring(startingPnt, tokenLength);
        } else {
            return token;
        }
    }
}