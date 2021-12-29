public without sharing class MARS_AgencySalarySurveyCtrl {
    public String signature {get; set;}
    public Agency_Salary_Survey__c  agencySalarySurvey {get; set;}
    public Datetime currentDateTime { get;set;}
    public MARS_AgencySalarySurveyCtrl() {
        Datetime now = Datetime.now(); 
        Integer offset = UserInfo.getTimezone().getOffset(now); 
        currentDateTime = now.addSeconds(offset/1000);
        agencySalarySurvey = [SELECT Id, Start_Date__c, END_Date__c, Status__c, Name, Account__r.MACS_ID__c,Account__r.Name,Requested_Effective_Date__c,CreatedBy.Name,
                                (SELECT Id, Classification_Title__c,Base_Rates__c,WC_and_or_UI__c,Are_you_adding_WC_UI__c,
                                Current_Rate__c,Revised_Rate__c,MOU_MOA__c,P_T_P__c,Effective_Date__c
                                FROM Salary_Survey_Line_Items__r) FROM Agency_Salary_Survey__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')];
       
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