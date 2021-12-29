/***********************************************************************************************************************************
* Class Name   : PHOS_RequestorAgecyLookupCtrl
* Description  : This class for get the search records
* Author       : Pankaj
* Created On   : 09/10/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              09/10/2020      Initial Implementation
**************************************************************************************************************************************/

Public without sharing class PHOS_RequestorAgecyLookupCtrl {

    private final static Integer MAX_RESULTS = 9999;
    
    /***********************************************
    * Method Name : apexSearchAgency
    * Author : Pankaj
    * Inputs : String searchTerm, String entityTypeFilter
    * Description: This method return list of LookupSearchResult from Account
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchAgency(String searchTerm, String entityTypeFilter) {
        // Prepare query paramters
        //searchTerm += '*';
        String query = 'Select Id,Name,Entity_Type__c From Account Where Entity_Type__c != null';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }
        if(String.isNotEmpty(entityTypeFilter)) {
            query += ' AND Entity_Type__c =: entityTypeFilter';
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);
        // Prepare results
        List<LookupSearchResult> results = searchAgency(accounts, true);
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : searchAgency
    * Author : Pankaj
    * Inputs : List<Account> accounts, Boolean showSubtitle
    * Description: This method return list of LookupSearchResult from Account
    *********************************************/
    private static List<LookupSearchResult> searchAgency( List<Account> accounts, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productIcon = 'standard:account';
        for (Account opProductReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opProductReference.Id,
                            'Account',
                            productIcon,
                            opProductReference.Name,
                            showSubtitle ? (opProductReference.Entity_Type__c != null ? opProductReference.Entity_Type__c  : '') : null,
                            opProductReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : getPicklistData
    * Author : Pankaj
    * Inputs : String objectName, String fieldName
    * Description: This method return list of string from specified object's picklist
    *********************************************/
    @AuraEnabled
    public static List<String> getPicklistData(String objectName, String fieldName) {
        Map<String,Object> returnMap = new Map<String, Object>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult results = objType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = results.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> pickListValuesList= new List<String>();
        for( Schema.PicklistEntry pickListVal : picklistValues){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    /***********************************************
    * Method Name : getCounty
    * Author : Pankaj
    * Inputs : -
    * Description: This method return list of string from Account with entity type is County
    *********************************************/
    @AuraEnabled
    public static List<Account> getCounty() {
        List<Account> accList = [SELECT Id, Name from Account where Entity_Type__c = 'County'];
        return accList;
    }
}