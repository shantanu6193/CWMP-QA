public without sharing class MARS_NonSuppressionPDFCtrl {
    public String signature {get; set;}
    public Agency_Non_Suppression_Personnel__c  agency_Non_Suppression_Personnel {get; set;}
    public Datetime currentDateTime { get;set;}
    public MARS_NonSuppressionPDFCtrl() {
        Datetime now = Datetime.now(); 
        Integer offset = UserInfo.getTimezone().getOffset(now); 
        currentDateTime = now.addSeconds(offset/1000);

        agency_Non_Suppression_Personnel=[
            SELECT Agency__c,Approval_Status__c,End_Date__c,Id,Name,Reject_Reason__c,Start_Date__c,Agency__r.MACS_ID__c,Agency__r.Name,CreatedBy.Name,
                (Select Id, Name,Agency_Non_Suppression_Personnel__c,Classification_Title__c, Current_Rate__c,
                Effective_Date__c,MOU_MOA_GBR__c,Revised_Rate__c,Status__c
                 From Agency_Non_Suppression_Line_Items__r)        
            FROM Agency_Non_Suppression_Personnel__c  
            WHERE Id =: ApexPages.currentPage().getParameters().get('id')
        ];

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