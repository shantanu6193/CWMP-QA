public without sharing class Mars_ReimbursementHistoryCtrl {
    @AuraEnabled
    public static List<Reimbursement__c> getReimbursementHistory(String accountId) {
        return [SELECT Id, Name,Total_Reimbursement_Amount__c,Printed_Name__c,Submission_Date__c,Strike_Team__c,
                Account__r.Name,Incident__r.Name,Comments__c,Status__c,Incident_Order_Number__c,Incident_Request_Number__c,Mutual_Aid_Staff_Comments__c
                FROM Reimbursement__c WHERE Account__c=:accountId ORDER BY CreatedDate DESC NULLS FIRST LIMIT 10];
    } 
    @AuraEnabled
    public static List<Reimbursement_Line_Item__c > getReimbursementLineItems(String reimbursemenId) {
        return [SELECT Id,Date__c, City__c,Meal__c, Lodging__c, MISC__c, Description__c, Amount__c
               FROM Reimbursement_Line_Item__c  WHERE Reimbursement__c=:reimbursemenId];
    }
    @AuraEnabled
    public static Map<String, Object> getData(String reimbursemenId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String signature='';
        returnMap.put('ReimbursementLineItems', getReimbursementLineItems(reimbursemenId));

        Reimbursement__c reimbursement = [SELECT Id, Name,Total_Reimbursement_Amount__c,Printed_Name__c,Submission_Date__c,Status__c,Approver_Comments__c,
                                            MACIDs__c,Strike_Team__c,Incident_Order_Number__c,Incident_Request_Number__c,Unit_Number__c,Incident__r.Name,Mutual_Aid_Staff_Comments__c,
                                            Comments__c,Meal_Total__c,MISC_Total__c,Lodging_Total__c FROM Reimbursement__c WHERE Id=:reimbursemenId LIMIT 1];
        returnMap.put('Reimbursement', reimbursement);
        returnMap.put('contentVersions', getContentVersions(new List<String>{reimbursemenId}));
        List<ContentVersion> signDco = getSignContentVersions(new List<String>{reimbursemenId});
        if(signDco.size() > 0)
            signature ='/sfc/servlet.shepherd/version/download/'+signDco[0].Id;
        returnMap.put('signature',signature);
        return returnMap;
    }
    private static List<ContentVersion> getContentVersions(List<String> recordIds) {

        Set<Id> contentDocIds = new Set<Id>();
        System.debug('recordIds---' + recordIds);
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        system.debug('==contentDocIds==='+contentDocIds);
        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest = true AND Type__c != null order by ContentModifiedDate desc];
    }
    private static List<ContentVersion> getSignContentVersions(List<String> recordIds) {

        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true AND Title LIKE 'Signature%' order by ContentModifiedDate desc];
    }
}