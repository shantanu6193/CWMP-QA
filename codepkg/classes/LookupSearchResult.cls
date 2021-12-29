/***********************************************************************************************************************************
* Class Name   : LookupSearchResult
* Description  : Class used to serialize a single Lookup search result item and the Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
* Author       : Pankaj
* Created On   : 06/05/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               06/05/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class LookupSearchResult implements Comparable {
    private Id id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    private SObject sObj;

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, SObject sObj) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.sObj = sObj;
    }

    /***********************************************
    * Method Name : getId
    * Author : Pankaj
    * Inputs : -
    * Description: This method return Id
    *********************************************/
    @AuraEnabled
    public Id getId() {
        return id;
    }

    /***********************************************
    * Method Name : getSObject
    * Author : Pankaj
    * Inputs : -
    * Description: This method return SObject
    *********************************************/
    @AuraEnabled
    public SObject getSObject() {
        return sObj;
    }

    /***********************************************
    * Method Name : getSObjectType
    * Author : Pankaj
    * Inputs : -
    * Description: This method return SObject Type
    *********************************************/
    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    /***********************************************
    * Method Name : getIcon
    * Author : Pankaj
    * Inputs : -
    * Description: This method return icon
    *********************************************/
    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    /***********************************************
    * Method Name : getTitle
    * Author : Pankaj
    * Inputs : -
    * Description: This method return title
    *********************************************/
    @AuraEnabled
    public String getTitle() {
        return title;
    }

    /***********************************************
    * Method Name : getSubtitle
    * Author : Pankaj
    * Inputs : -
    * Description: This method return subtitle
    *********************************************/
    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    /***********************************************
    * Method Name : compareTo
    * Author : Pankaj
    * Inputs : Object compareTo
    * Description: This method allow to sort search results based on title
    *********************************************/
    public Integer compareTo(Object compareTo) {
        LookupSearchResult other = (LookupSearchResult) compareTo;
        if (this.getTitle() == null) {
            return (other.getTitle() == null) ? 0 : 1;
        }
        if (other.getTitle() == null) {
            return -1;
        }
        return this.getTitle().compareTo(other.getTitle());
    }


    /***********************************************
    * Method Name : saveNewRecord
    * Author : Pankaj
    * Inputs : String objectName, Map<String, String> paramMap
    * Description: This generic method to create new record of specific object when no records present in search results
    *********************************************/
    @AuraEnabled
    public static LookupSearchResult saveNewRecord(String objectName, Map<String, String> paramMap){
        if(String.isBlank(objectName))
            return null;
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        System.debug('object type---'+objType);
        SObject genericObj = objType.newSObject();
        for(String key : paramMap.keySet()) {
            genericObj.put(key, paramMap.get(key));
        }
        Database.SaveResult sr = Database.insert(genericObj, true);
        if(sr.getId() == null) {
            return null;
        }
        LookupSearchResult res = new LookupSearchResult(
                genericObj.Id,
                String.valueOf(objType),
                'standard:account',
                paramMap.get('Name'),
                null,
                genericObj
        );
        return res;
    }
}