public without sharing class Mars_ReimbursementReviewCtrl {
    @AuraEnabled
    public static List<Reimbursement__c> getReimbursementReviewList(String accountId) {
        return [SELECT Id, Name,Total_Reimbursement_Amount__c,Printed_Name__c,Submission_Date__c,Strike_Team__c,
                Account__r.Name,Incident__r.Name,Comments__c,Status__c,Incident_Order_Number__c,Incident_Request_Number__c,Mutual_Aid_Staff_Comments__c
                FROM Reimbursement__c WHERE Account__c=:accountId AND Id NOT IN(Select Expense_Claim__c From F_42_Invoices__c) ORDER BY Status__c ASC];
    }
    @AuraEnabled
    public static List<Reimbursement_Line_Item__c > getReimbursementLineItems(String reimbursemenId) {
        return [SELECT Id,Date__c, City__c,Meal__c, Lodging__c, MISC__c, Description__c, Amount__c
               FROM Reimbursement_Line_Item__c  WHERE Reimbursement__c=:reimbursemenId];
    }
    @AuraEnabled
    public static Map<String, Object> getData(String reimbursemenId) {
        String signature='';
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('ReimbursementLineItems', getReimbursementLineItems(reimbursemenId));

        Reimbursement__c reimbursement = [SELECT Id, Name,Total_Reimbursement_Amount__c,Printed_Name__c,Submission_Date__c,Status__c,Approver_Comments__c,Unit_Number__c,
                                            Incident__r.Name,F_42__r.Name,Attachment_Type__c,Strike_Team__c,Incident_Order_Number__c,Incident_Request_Number__c,MACIDs__c,Mutual_Aid_Staff_Comments__c,
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

    @AuraEnabled
    public static void saveComments(String reimbursemenId, String attachmentType, String fileUpdateWrapper, String comments, String accountId) {
        if(fileUpdateWrapper != null && reimbursemenId != null) {
            Reimbursement__c  expenseRecord = [SELECT Id,MACIDs__c,Strike_Team__c,Unit_Number__c FROM Reimbursement__c WHERE Id =:reimbursemenId];
            String UnitNo = expenseRecord.Unit_Number__c != null ? expenseRecord.Unit_Number__c : '';
            String strikeNo = expenseRecord.Strike_Team__c != null ? expenseRecord.Strike_Team__c : '';
            String MackId = expenseRecord.MACIDs__c != null ? expenseRecord.MACIDs__c : '';
            String fileName = MackId +'-'+strikeNo +'-'+ UnitNo;
            List<FileUpdateWrapper> fileDocUpdateList = (List<FileUpdateWrapper>)JSON.deserialize(fileUpdateWrapper, List<FileUpdateWrapper>.class);
            if(fileDocUpdateList.size() > 0){
                Map<String,String> cvIdMap = new Map<String,String>();
                for(FileUpdateWrapper fuw : fileDocUpdateList){
                    cvIdMap.put(fuw.contentVersionId,fuw.Type);
                }
                Set<Id> cdIdSet = new Set<Id>();
                List<ContentVersion> cvUpdateList = [SELECT Id,Type__c,ContentDocumentId,Title FROM ContentVersion WHERE Id=:cvIdMap.keySet()];
                for(ContentVersion cvRec : cvUpdateList){
                    cdIdSet.add(cvRec.ContentDocumentId);
                    if(cvIdMap.containsKey(cvRec.Id) && cvRec.Type__c == null){
                        cvRec.Type__c = cvIdMap.get(cvRec.Id);
                        cvRec.Title = fileName;
                    }
                }
                if(!cvUpdateList.isEmpty() && cvUpdateList != null) 
                    update cvUpdateList;
                System.debug('ContentDocumentLink 84==>'+cvUpdateList.size());

                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                List<ContentDocumentLink> cdlExt = new List<ContentDocumentLink>();
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: accountId AND ContentDocumentId=:cdIdSet]) {
                                                ContentDocumentLink cloned = cdl.clone();
                                                cloned.LinkedEntityId = reimbursemenId;
                                                cloned.ShareType = cdl.ShareType;
                                                cdlList.add(cloned);
                                                cdlExt.add(cdl);
                                                }
                insert cdlList; // new CDL records
                delete cdlExt; // delete old CDL records
            }
        }
        if(reimbursemenId != null && comments != null) {
            List<Reimbursement__c> reimbRecord = [SELECT Id, Approver_Comments__c, Status__c, Attachment_Type__c FROM Reimbursement__c WHERE Id =:reimbursemenId];
            if(reimbRecord.size() > 0) {
                reimbRecord[0].Approver_Comments__c = comments;
                reimbRecord[0].Status__c = 'CALOES Review';
                reimbRecord[0].Attachment_Type__c = attachmentType;
                update reimbRecord;
            }
        }
    }
    @AuraEnabled 
    public static void deleteFile(String contentVersionId){
        ContentVersion data = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE  Id=:contentVersionId limit 1];
        ContentDocument cd = new ContentDocument();
        cd.Id = data.ContentDocumentId;
        delete cd;
    }
    public class FileUpdateWrapper {
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
        public String Type{get;set;}
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