/***********************************************************************************************************************************
* Class Name   : PHOS_ProductSearchCtrl
* Description  : This class for search the products
* Author       : Pankaj
* Created On   : 09/08/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              09/08/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_ProductSearchCtrl {
    private final static Integer MAX_RESULTS = 9999;
    
    /***********************************************
    * Method Name : apexSearchProduct
    * Author : Pankaj
    * Inputs : String searchTerm
    * Description: This method return list of LookupSearchResult from all active Product2
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchProduct(String searchTerm) {
        // Prepare query paramters
        //searchTerm += '*';
        User user = ApexUtils.getCurrentUserDetails();
        String query = 'Select Id, Name, ProductCode, Family from Product2 where IsActive = true AND Available_to_use_in_PHOS__c = true ';
        if(user.Account != null && String.isNotBlank(user.Account.Product_Filter_Clause__c)) {
            query += user.Account.Product_Filter_Clause__c;
        }else if(user.Account != null && user.Account.Parent != null && String.isNotBlank(user.Account.Parent.Product_Filter_Clause__c)) {
            query += user.Account.Parent.Product_Filter_Clause__c;
        } else if(user.Account != null){
            query += ' AND Hide_for_PHOS_Portal_Users__c != true ';
            if(user.Contact.Account.Entity_Type__c == 'Non-Governmental Entity') {
                String nonGovernmentalEntityProductFilter = KeyValueHelper.getTextValue('Non_Governmental_Entity_Product_Filter');
                if(String.isNotBlank(nonGovernmentalEntityProductFilter)){
                    query += nonGovernmentalEntityProductFilter;
                }
            } else if(user.Contact.Account.Entity_Type__c == 'Health Care Facility') {
                String healthCareFacilityProductFilter = KeyValueHelper.getTextValue('Health_Care_Facility_Product_Filter');
                if(String.isNotBlank(healthCareFacilityProductFilter)) {
                    query += healthCareFacilityProductFilter;
                }   
            }
        }
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\'';
            query += ' OR Family like\'%' + searchTerm + '%\')';
        }
       
        query += ' ORDER BY Name';
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Product2> products = Database.query(query);
        // Prepare results
        List<LookupSearchResult> results = searchProduct(products, true);
       /* List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Extract Products & convert them into LookupSearchResult
        String productIcon = 'standard:product';
        for (Product2 opProductReference : products) {
                results.add(
                        new LookupSearchResult(
                                opProductReference.Id,
                                'Product2',
                                productIcon,
                                opProductReference.Name, 
                                null,
                                opProductReference
                        )
            );
        }

        // Optionnaly sort all results on title
        //results.sort();*/
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : searchProduct
    * Author : Pankaj
    * Inputs : List<Product2> products, Boolean showSubtitle
    * Description: This method return list of LookupSearchResult from Products
    *********************************************/
    private static List<LookupSearchResult> searchProduct( List<Product2> products, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productIcon = 'standard:product';
        for (Product2 opProductReference : products) {
            results.add(
                    new LookupSearchResult(
                        opProductReference.Id,
                            'Product2',
                            productIcon,
                            opProductReference.Name,
                            showSubtitle ? (opProductReference.Family != null ? opProductReference.Family  : '') : null,
                            opProductReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }
    
}