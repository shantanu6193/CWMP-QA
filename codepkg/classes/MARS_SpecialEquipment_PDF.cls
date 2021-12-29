public without sharing class MARS_SpecialEquipment_PDF {
    public String signature {get; set;}
    public Agency_Special_Equipment__c  specialEquipment {get; set;}
    public MARS_SpecialEquipment_PDF() {
        specialEquipment = [SELECT Id, Start_Date__c, END_Date__c, Approval_Status__c, Name, Agency__r.MACS_ID__c,Agency__r.Name,CreatedBy.Name,
                                (SELECT Id, Name, Special_Equipment_Type__c, Description__c, FEMA_CODE__c, Current_Rate__c
                                FROM Agency_Special_Equipment_Line_Items__r) 
                            FROM Agency_Special_Equipment__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')];
       
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