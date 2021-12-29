public without sharing class MARS_ApprovedAgreementPDFQACtrl {
   
    @AuraEnabled
    public static String getStatus(string agreementId) {
        String status = '';
        List<Agency_Rate_Agreement__c>  agencyRateAgreement = [SELECT Id, Approval_Status__c FROM Agency_Rate_Agreement__c WHERE Id=:agreementId LIMIT 1];
        if(agencyRateAgreement != null && !agencyRateAgreement.isEmpty()) {
            status = agencyRateAgreement[0].Approval_Status__c;
        }
        return status;
    }
}