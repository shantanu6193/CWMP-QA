public without sharing class MARS_DeniedAgreementPDFCtrl {
    public String signature {get; set;}
    public Agency_Rate_Agreement__c  agency_Rate_Agreement {get; set;}
    public Datetime CurrentDateTime { get;set;}

    public MARS_DeniedAgreementPDFCtrl() {
        Datetime now = Datetime.now(); 
        Integer offset = UserInfo.getTimezone().getOffset(now); 
        CurrentDateTime = now.addSeconds(offset/1000);
        
        agency_Rate_Agreement = [SELECT Id, Start_Date__c, End_Date__c,Approval_Status__c, Name,Agreement_Type__c, Agency__r.MACS_ID__c,Agency__r.Name,CreatedBy.Name,Reject_Reason__c,
            (SELECT Id, Name,Start_Date__c,End_Date__c,OT__c,
            MOU_MOA__c,PTP__c, Status__c
            FROM Agency_Rate_Agreement_Line_Items__r) FROM Agency_Rate_Agreement__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')];

        List<ContentVersion> signDco = getContentVersions(new List<String>{ApexPages.currentPage().getParameters().get('id')});
        if(signDco.size() > 0)
            signature ='/sfc/servlet.shepherd/version/download/'+signDco[0].Id;

    }
    private static List<ContentVersion> getContentVersions(List<String> recordIds) {

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