/***********************************************************************************************************************************
* Class Name   : PHOS_WarehouseSearchCtrl
* Description  : This class for PHOS warehouse search 
* Author       : Pankaj
* Created On   : 09/29/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              09/29/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_WarehouseSearchCtrl {
    private final static Integer MAX_RESULTS = 9999;
    
    /***********************************************
    * Method Name : apexSearchWarehouse
    * Author : Pankaj
    * Inputs : String selectedWarehouse, String searchTerm
    * Description: This method return list of LookupSearchResult from Inventory
    *********************************************/
    @AuraEnabled
    public static List<LookupSearchResult> apexSearchWarehouse(String selectedWarehouse, String searchTerm) {
        // Prepare query paramters
        //System.debug('--selectedWarehouse--'+selectedWarehouse+'---searchTerm--'+searchTerm);
        Map<String,String> warehouseMap = new  Map<String,String>();
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        List<Id> accountIds = new List<Id>();

        List<Warehouse_Config__mdt> wareHouseAccountConfig = [SELECT Id,Account_Id__c,isActive__c,Send_Email__c,Creation_Status__c
                                                                FROM Warehouse_Config__mdt WHERE MasterLabel =:selectedWarehouse];

        if(wareHouseAccountConfig != null){
            for(Warehouse_Config__mdt tempWarehouse : wareHouseAccountConfig) {
                accountIds.add(tempWarehouse.Account_Id__c);
            }

            /*List<Inventory__c> inventoryList = [SELECT Id,SKU_Id__c,Warehouse_Code__c, Warehouse_Code_And_SKU_Id__c,
                                                Warehouse_Product__r.Product__r.Minimum_Order_Quantity__c,Remaining_Inventory__c,
                                                Warehouse_Product__r.Warehouse__c,Warehouse_Product__r.Product__r.Name FROM Inventory__c
                                                WHERE Warehouse_Product__r.Warehouse__c IN :accountIds];*/
            String query = 'SELECT Id,SKU_Id__c,Remaining_Inventory__c,Warehouse_Product__r.Product__r.Name FROM Inventory__c WHERE Warehouse_Product__r.Warehouse__c IN:accountIds';
            if(String.isNotBlank(searchTerm)) {
                query += ' AND (SKU_Id__c like\'%' + searchTerm + '%\'';
                query += ' OR Warehouse_Product__r.Product__r.Name like\'%' + searchTerm + '%\')';
            }
            query += ' Limit ' + MAX_RESULTS;
            system.debug('query===='+query);
            List<Inventory__c> inventoryList = Database.query(query);

            results= searchWarehouse(inventoryList, true);
        }
        System.debug('results---' + results);
        return results;
        // Prepare results
       
    }

    /***********************************************
    * Method Name : searchWarehouse
    * Author : Pankaj
    * Inputs : List<Inventory__c> inventories, Boolean showSubtitle
    * Description: This method return list of LookupSearchResult from Inventory
    *********************************************/
    private static List<LookupSearchResult> searchWarehouse( List<Inventory__c> inventories, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
       String productIcon = 'standard:product';
       //String productIcon = '';
        for (Inventory__c opProductReference : inventories) {
            results.add(
                    new LookupSearchResult(
                        opProductReference.Id,
                            'Inventory__c',
                            productIcon,
                            opProductReference.SKU_Id__c,
                            showSubtitle ? (opProductReference.Warehouse_Product__r.Product__r.Name != null ? opProductReference.Warehouse_Product__r.Product__r.Name  : '') : null,
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