public without sharing class MARS_AgencyAdminRates_PDF {
    public String signature {get; set;}
    public Agency_Admin_Rates__c  agencyAdminRate {get; set;}
    public list<string> programNames {get; set;}
    public MARS_AgencyAdminRates_PDF() {
        agencyAdminRate = [SELECT Id, Start_Date__c, END_Date__c, Approval_Status__c, Name, Agency__r.MACS_ID__c,Agency__r.Name,Administrative_Rate_Indirect_Cost_Direct__c,CreatedBy.Name,
                                Data_For_Use_In__c, Total_Direct_Amount__c,FY_From__c, FY_To__c, Administrative_Total_Indirect_Direct__c, Total_Indirect_Amount__c,
                                (SELECT Id, Name, Direct__c,Indirect__c, Effective_Date__c, Total__c
                                FROM Agency_Admin_Line_Items__r) 
                            FROM Agency_Admin_Rates__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')];
       
        List<ContentVersion> signDco = getContentVersions(new List<String>{ApexPages.currentPage().getParameters().get('id')});
        if(signDco.size() > 0){
            signature ='/sfc/servlet.shepherd/version/download/'+signDco[0].Id ;
        }
        programNames = new list<string>{'Emergency Medical Services','General Administration','Information Technology','Logistics/Procurement/Supply/Minor Fire Equipment',
                                        'Public Information Office',
                                        'Telecommunications',
                                        'Arson Investigation', 
                                        'Community Education',
                                        'Facilities',
                                        'Fire Comm. Center/Dispatch/Comm. & Control Center',
                                        'Fire Hazard Reduction Program',
                                        'Fleet',
                                        'Hazardous Materials Response Program',
                                        'Mapping',
                                        'Operations',
                                        'Prevention',
                                        'Training',
                                        'Urban Search and Rescue'
                                    };
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