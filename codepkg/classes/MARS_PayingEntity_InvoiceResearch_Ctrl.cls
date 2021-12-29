/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-14-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-14-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class MARS_PayingEntity_InvoiceResearch_Ctrl {
   
    @AuraEnabled
    public static list<Invoice_Payment__c> getInvoicePayments(string agencyId, string incidentId, Date startDate, Date endDate){
        try {
            string accountId =  [Select Id, Contact.AccountId From User Where Id =: UserInfo.getUserId()].Contact.AccountId;
            string query = 'SELECT Id, Status__c, Invoice__c, Invoice_Percent__c, Invoice_Amount__c, ';
            query += ' Paid_Amount__c, Invoice__r.Invoice_Number__c, Invoice__r.Name, ';
            query += ' Invoice__r.Incident__r.Name, Invoice__r.Account__r.Name, Date_Of_Payment__c, CreatedDate ';
            query += ' FROM Invoice_Payment__c ';
            query += ' WHERE Status__c IN (\'Paid\', \'Partially Paid\') ';
            query += ' AND Funding_Source__r.Account__c = :accountId '; 

            if(string.isNotBlank(incidentId)){
                query+= ' AND Invoice__r.Incident__c =: incidentId ';
            }
            if(string.isNotBlank(agencyId)){
                query+= ' AND Invoice__r.Account__c =:agencyId ';
            }
            if(startDate != null && endDate != null){
                query += ' AND Date_Of_Payment__c >=:startDate AND Date_Of_Payment__c <=: endDate ';
            }

            query+= ' order by Date_Of_Payment__c desc LIMIT 500';
            system.debug('Query******** '+query);
            return Database.query(query);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



}