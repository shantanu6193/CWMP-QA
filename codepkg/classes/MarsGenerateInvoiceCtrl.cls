/**
 * Created by Pankaj on 2021-05-27.
 */

public with sharing class MarsGenerateInvoiceCtrl {

    @AuraEnabled
    public static Map<String, Object> getF42Entries(String selectedSRRecordId, String selectedIncidentRecordId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        if(String.isEmpty(selectedIncidentRecordId)) {
            throw new AuraHandledException('Please select Incident');
        }
        String query = 'SELECT Id,Strike_Team__c,Name,Status__c,CreatedBy.Name,Account__r.Name,DI_Committed_to_Incident_Date__c FROM F42__c WHERE Incident__c=:selectedIncidentRecordId AND Status__c =\'APPROVED\' AND Id NOT IN(Select F_42__c From F_42_Invoices__c)';
        if(String.isNotEmpty(selectedSRRecordId)) {
            query += ' AND Account__c=:selectedSRRecordId ';
        }
        List<F42__c> getF42Entries = Database.query(query);
        returnMap.put('getF42Entries', getF42Entries);
        List<Funding_Rule__c> fundingRules = [SELECT Id,Rule_Type__c,Name,Funding_Source_1__c,Funding_Source_1__r.Name,Funding_Source_1_Percent__c,
        Funding_Source_2__c,Funding_Source_2__r.Name,Funding_Source_2_Percent__c,Funding_Source_3__c,Funding_Source_3__r.Name,Funding_Source_3_Percent__c,
        Funding_Source_4__c,Funding_Source_4__r.Name,Funding_Source_4_Percent__c,Funding_Source_5__c,Funding_Source_5__r.Name,Funding_Source_5_Percent__c FROM Funding_Rule__c WHERE Incident__c=:selectedIncidentRecordId];
        
        returnMap.put('fundingRules', fundingRules);

        String query1 = 'SELECT Id,Strike_Team__c,Name,Status__c,CreatedBy.Name,Account__r.Name,Submission_Date__c FROM Reimbursement__c WHERE Incident__c=:selectedIncidentRecordId AND F_42__c = null AND Status__c =\'Approved\' AND Id NOT IN(Select Expense_Claim__c From F_42_Invoices__c)';
        if(String.isNotEmpty(selectedSRRecordId)) {
            query1 += ' AND Account__c=:selectedSRRecordId ';
        }
        List<Reimbursement__c> getExpenseClaimData = Database.query(query1);
        returnMap.put('getExpenseClaimData', getExpenseClaimData);

        return returnMap;
    }

    /***********************************************
    * Method Name : apexSearchIncident
    * Author : Pankaj
    * Inputs : String searchTerm, String entityTypeFilter
    * Description: This method return list of LookupSearchResult from Account
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchIncident(String searchTerm) {
        // Prepare query paramters
        //searchTerm += '*';
        String query = 'Select Id,Name,Declaration_Number__c,Order_No__c From Incident__c Where Name != null AND Available_for_Application__c INCLUDES (\'MARS\')';
        if(String.isNotEmpty(searchTerm)) {
            //query += ' AND (Name like\'%' + searchTerm + '%\')';
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR Order_No__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit 200';
        system.debug('query===='+query);
        List<Incident__c> incidents = Database.query(query);

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productIcon = 'standard:account';
        for (Incident__c opProductReference : incidents) {
            results.add(
                new LookupSearchResult(
                        opProductReference.Id,
                        'Account',
                        productIcon,
                        opProductReference.Name,
                        'Order #'+opProductReference.Order_No__c,
                        //(opProductReference.Order_No__c != null ? opProductReference.Order_No__c  : ''),
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
    * Method Name : apexSearchAgency
    * Author : Pankaj
    * Inputs : String searchTerm, String entityTypeFilter
    * Description: This method return list of LookupSearchResult from Account
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchAgency(String searchTerm) {
        // Prepare query paramters
        //searchTerm += '*';
        String query = 'Select Id,Name,Entity_Type__c From Account ';
        if(String.isNotEmpty(searchTerm)) {
            query += ' Where Name like\'%' + searchTerm + '%\'' + ' and Entity_Type__c = \'Fire Agency\'';
        }
        query += ' Limit 200';
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);
        // Prepare results
        // Extract Accounts & convert them into LookupSearchResult
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String productIcon = 'standard:account';
        for (Account opProductReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opProductReference.Id,
                            'Account',
                            productIcon,
                            opProductReference.Name,
                            (opProductReference.Entity_Type__c != null ? opProductReference.Entity_Type__c  : ''),
                            opProductReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    @AuraEnabled
    public static List<String> generateInvoice(String incidentNumber, String agencyId, List<String> f42s, String fundingRuleId, List<String> expenseClaims) {
        System.debug('IncidentNumber=='+incidentNumber+' agencyId=='+agencyId+'  f42s=='+f42s);
        String parentInvoiceId = null;
        return MARSInvoiceHelper.createInvoiceStaging(incidentNumber, agencyId, f42s, fundingRuleId, parentInvoiceId, 'Invoice', expenseClaims);
        //return MarsGenerateInvoiceHelper.createStagingInvoice(incidentNumber, agencyId, f42s, fundingRuleId, parentInvoiceId, 'Invoice', expenseClaims);
    }
}