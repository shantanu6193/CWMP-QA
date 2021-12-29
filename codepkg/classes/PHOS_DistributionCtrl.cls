/***********************************************************************************************************************************
* Class Name   : PHOS_DistributionCtrl
* Description  : This class for PHOS distribution plan
* Author       : Pankaj
* Created On   : 08/27/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              08/27/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_DistributionCtrl {
    private final static Integer MAX_RESULTS = 1000;
    
    /***********************************************
    * Method Name : getOrderProducts
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return map of order products
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrderProducts(String orderId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = [SELECT Description__c,Id,Order__c,ProductCode__c,Product_Code__c,Product_Family__c,Product_Name__c,Product__c,
                                                    Quantity_Back_Ordered__c,Quantity_Filled__c,Quantity__c,Status__c,Warehouse_Info__c,Fulfilment_Entity_Warehouse__c,Total_Actual_Quantity__c,Total_Proposed_Quantity__c,
                                                    ( SELECT Actual_Quantity_Distribution__c,County__c,Distribution_Notes__c,Facility_Code__c,Facility__r.Name,Sequence__c,
                                                            Facility_Name__c, Facility_Category__c, Facility__c,Id,Name,Order_Product__c,Proposed_Quantity_Distribution__c from Product_Distribution_Plans__r ORDER BY Facility_Name__c ASC)
                                                    FROM Order_Product__c where Order__c =: orderId];
        returnMap.put('OrderItems',orderItems);
        return returnMap;
    }

    /***********************************************
    * Method Name : submitRequest
    * Author : Pankaj
    * Inputs : String recordData, Boolean isQuickSave
    * Description: This method upsert distribution plan and return map of updated order products 
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> submitRequest(String recordData, Boolean isQuickSave) {
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            System.debug('recordData----'+recordData);
            recordData = recordData.replace('index','Sequence__c');
            List<Id> distributionPlanIds = new List<Id>();
            List<Id> orderProductIds = new List<Id>();
            List<Product_Distribution_Plan__c> distributionPlanList = new List<Product_Distribution_Plan__c>();
            List<Order_Product__c> orderProductList = (List<Order_Product__c>) JSON.deserialize(recordData, List<Order_Product__c>.class);
            System.debug('recordData----'+orderProductList);
            for(Order_Product__c orderProduct : orderProductList) {
                for(Product_Distribution_Plan__c productRec : orderProduct.Product_Distribution_Plans__r) {
                    if(String.isBlank(productRec.Order_Product__c)) {
                        productRec.Order_Product__c = orderProduct.Id;
                    }
                    distributionPlanList.add(productRec);
                    if(productRec.Id != null) {
                        distributionPlanIds.add(productRec.Id);
                    }
                }
                orderProductIds.add(orderProduct.Id);
            }

            OrderProductTriggerHelper.skipOrderProductTrigger = true;
            // delete records which are deleted on UI
            delete [SELECT Id FROM Product_Distribution_Plan__c WHERE Order_Product__c IN :orderProductIds AND Id NOT IN :distributionPlanIds];

            upsert distributionPlanList;

            //Create Distribution Plan Version
            AppUtils.generateSnapshotInJSONForDistributionPlan(orderProductList[0].Order__c);

            if(!isQuickSave) {
                returnMap.put('OrderId',orderProductList[0].Order__c);
            }
            else {
                Map<String, Object> orderProdMap = getOrderProducts(orderProductList[0].Order__c);
                returnMap.put('OrderItems',orderProdMap.get('OrderItems'));
            }
            //upsert distributionPlanList;
            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***********************************************
    * Method Name : apexSearchFacility
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from account with entity type is Health Care Facility
    *********************************************/
    @AuraEnabled
    public static List<LookupSearchResult> apexSearchFacility(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String facility = 'Health Care Facility';
        searchTerm = searchTerm.replace(' ','%');
        String query = 'Select Entity_Id__c, Parent.Name, Parent.Id, Id, Name, Facility_Category__c From Account';
        query += ' Where Entity_Type__c = \'' + facility + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND (Name like\'%' + searchTerm + '%\' OR Parent.Name like\'%' + searchTerm + '%\' OR Entity_Id__c like\'%' + searchTerm + '%\')' ;
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);

        List<LookupSearchResult> results = searchAccount(accounts, true);
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : searchAccount
    * Author : Pankaj
    * Inputs : List<Account> accounts, Boolean showSubtitle
    * Description: This method return list of LookupSearchResult from account
    *********************************************/
    private static List<LookupSearchResult> searchAccount( List<Account> accounts, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            showSubtitle ? ((opAccountReference.Parent.Name != null ? opAccountReference.Parent.Name + ' . ' : '') + (opAccountReference.Entity_Id__c != null ? opAccountReference.Entity_Id__c : '')) : null,
                            opAccountReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : checkCommunityUser
    * Author : Pankaj
    * Inputs : String recordId
    * Description: This method return map of IsCommunityUser(true\false)
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> checkCommunityUser(String recordId) {
        map<String, Object> returnMap = new Map<String, Object>();
        Boolean isCommunityUser = ApexUtils.checkCommunityUser();
        returnMap.put('IsCommunityUser',isCommunityUser);
        return returnMap;
    }

    /***********************************************
    * Method Name : getCounty
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of accounts with entity type is County
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getCounty() {
        Map<String, Object> returnMap = new Map<String ,Object>();
        List<Account> countyList = [SELECT Id, Name from Account where Entity_Type__c = 'County'];
        returnMap.put('CountyList',countyList);
        return  returnMap;
    }
}