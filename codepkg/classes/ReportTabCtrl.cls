/**
* Created by Pankaj on 25-09-2019.
 *
 * @description show list of available reports for customer.
 *               Show list of reports from from report config custom metadata
 *               On report config we have base object field and report will be visible only if user has access to base report.
*/

public with sharing class ReportTabCtrl {

    /**
     * @return return report data.
     *          Reports - List of available reports for this user.
     *          shipToEntities - List of ship to Entities available for this user.
     *
     * @description get list of active reports from report config.
     *              Check if user has access to base object related to report config only then add to list.
     */
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getReportData() {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('reports', getReportFolders());
        /*AppUtils.throwExceptionForGuestUser();*/

        return returnMap;

    }

    /**
     * @return list of ship to entities accessible for current user.
     *
     * @description get list of Supplier account relationships and from it show list of ship to entities
     */
    /*private static List<Account> getShipToEntities() {
        Map<String, Object> retMap = Order_DetailsCtrl.loadAllRelatedSAR(null, false);
        List<Supplier_Account_Relation__c> supplierAccountRelations = (List<Supplier_Account_Relation__c>)retMap.get('SupplierAccountRelations');
        List<Account> accounts = new List<Account>();
        Set<String> addedAccounts = new Set<String>();
        for (Supplier_Account_Relation__c supplierAccountRelation : supplierAccountRelations) {
            if (addedAccounts.contains(supplierAccountRelation.Ship_To_Entity__c)) continue;
            addedAccounts.add(supplierAccountRelation.Ship_To_Entity__c);
            accounts.add(supplierAccountRelation.Ship_To_Entity__r);
        }
        return accounts;
    }*/

    /**
     * @return list of report config with user based object access
     *
     * @description get report config based on module and
     */
    private static List<Report_Config__mdt> getReportFolders() {
        List<Report_Config__mdt> reportConfigs = [SELECT Id,Report_Name__c,Sequence__c,Report_Help_Text__c, Base_Object_API_NAME__c
        FROM Report_Config__mdt
        WHERE Module__c = 'PHOS' ORDER BY Sequence__c asc];
        /*List<Report_Config__mdt> reportConfigsToReturn = new List<Report_Config__mdt>();
        for (Report_Config__mdt reportConfig : reportConfigs) {
            if(reportConfig.Base_Object_API_NAME__c == 'Order__c' && Schema.sObjectType.Order.isAccessible()) {
                reportConfigsToReturn.add(reportConfig);
            }
        }*/
        return reportConfigs;
    }

    /**
     * @param reportId - Report user has selected
     * @param shipToEntityId - Selected ship to Entity on UI
     * @param timeFilter - Selected type of time
     * @param startDate - selected start date for Report
     * @param endDate - Selected end date for Report
     *
     * @return
     */
    @AuraEnabled
    public static String generatingReportURL(String reportId, String shipToEntityId, String timeFilter, Date startDate, Date endDate) {
       // AppUtils.throwExceptionForGuestUser();
        String refLIInfo;
        String filterString;
        Report_Config__mdt reportConfig = [SELECT Id,Report_Help_Text__c,Report_Name__c,Order_Date_Field_API__c,Report_Id__c, Custom_Report_URL__c
        FROM Report_Config__mdt
        WHERE Id=:reportId];

        if(String.isNotBlank(reportConfig.Custom_Report_URL__c)) {
            refLIInfo = '/' + reportConfig.Custom_Report_URL__c;
            filterString = '&reportFilters=';
        } else {
            refLIInfo = '/' + reportConfig.Report_Id__c;
            filterString = '?reportFilters=';
        }
        List<Map<String, String>> paramList = new List<Map<String, String>>();
        if (String.isNotEmpty(timeFilter)) {

            if (timeFilter == 'Custom') {
                Map<String, String> StartDateParamMap = new Map<String, String>();
                StartDateParamMap.put('operator', 'greaterOrEqual');
                StartDateParamMap.put('value', String.valueOf(startDate));
                StartDateParamMap.put('column', reportConfig.Order_Date_Field_API__c);
                paramList.add(StartDateParamMap);

                Map<String, String> EndDateParamMap = new Map<String, String>();
                EndDateParamMap.put('operator', 'lessOrEqual');
                EndDateParamMap.put('value', String.valueOf(endDate));
                EndDateParamMap.put('column', reportConfig.Order_Date_Field_API__c);
                paramList.add(EndDateParamMap);

            } else {
                Map<String, String> paramMap = new Map<String, String>();
                paramMap.put('operator', 'equals');
                paramMap.put('value', timeFilter);
                paramMap.put('column', reportConfig.Order_Date_Field_API__c);
                paramList.add(paramMap);
            }
        }
        filterString +=  JSON.serialize(paramList);
        System.debug('URL.getSalesforceBaseUrl().toExternalForm()------'+URL.getSalesforceBaseUrl().toExternalForm());
        System.debug('URL.getSalesforceBaseUrl().toExternalForm()------'+refLIInfo);
        System.debug('URL.getSalesforceBaseUrl().toExternalForm()------'+filterString);
        PageReference myVfPageURL = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/phos' + refLIInfo + filterString); 
        return String.valueOf(myVfPageURL.getUrl());
    }
}