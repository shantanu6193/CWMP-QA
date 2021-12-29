public without sharing class MARS_FireAgency_Research_Ctrl {
    
    @AuraEnabled
    public static list<Salary_Survey_Line_Items__c> getSalarySurveyItems(string accountId, Date dayOfRecord){
        try {
            string parentId;
            list<Agency_Salary_Survey__c> surveys = [SELECT Id, Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Salary_Survey__c
                                                    WHERE Account__c = :accountId
                                                    AND Status__c != 'Rejected' AND (NOT Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];

            if(!surveys.isEmpty()){
                parentId = surveys[0].Id;
                List<String> contentDocIds = new List<String>();
                for(ContentDocumentLink contentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId]) {
                    contentDocIds.add(contentDocLink.ContentDocumentId);
                }
                List<ContentVersion> cvs = [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
                from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true order by ContentModifiedDate desc];

                LIST<Salary_Survey_Line_Items__c> items = [SELECT Id, Name, Classification_Title__c, Base_Rates__c, WC_and_or_UI__c, Are_you_adding_WC_UI__c, Revised_Rate__c, Agency_Salary_Survey__r.Start_Date__c, 
                            Agency_Salary_Survey__r.End_Date__c, Agency_Salary_Survey__r.Status__c, Agency_Salary_Survey__r.Reject_Reason__c,Agency_Salary_Survey__c,
                            Agency_Salary_Survey__r.Name, Agency_Salary_Survey__r.CreatedBy.LastName, Agency_Salary_Survey__r.CreatedBy.FirstName
                        FROM Salary_Survey_Line_Items__c 
                        WHERE Agency_Salary_Survey__c = :parentId];
                if(cvs.Size() > 0){
                    items[0].Name = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ cvs[0].Id + '&operationContext=CHATTER&contentId=' + contentDocIds[0];
                }
                return items;
            }else{
                return new list<Salary_Survey_Line_Items__c>();
            }
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //'/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ pacvId + '&operationContext=CHATTER&contentId=' + pacdId;

    @AuraEnabled
    public static list<Agency_Non_Suppression_Line_Item__c> getNonsupressionItems(string accountId, Date dayOfRecord){
        try {
            string parentId;
            list<Agency_Non_Suppression_Personnel__c> parentRecords = [SELECT Id, Approval_Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Non_Suppression_Personnel__c
                                                    WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];
          
                if(!parentRecords.isEmpty()) {  
                    parentId = parentRecords[0].Id;   

                List<String> contentDocIds = new List<String>();
                for(ContentDocumentLink contentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId]) {
                    contentDocIds.add(contentDocLink.ContentDocumentId);
                }
                List<ContentVersion> cvs = [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
                    from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true order by ContentModifiedDate desc];                     
                List<Agency_Non_Suppression_Line_Item__c> items = [SELECT Id, Name, Classification_Title__c,Current_Rate__c, Revised_Rate__c,  Agency_Non_Suppression_Personnel__r.Start_Date__c, 
                Agency_Non_Suppression_Personnel__r.Reject_Reason__c, Agency_Non_Suppression_Personnel__r.Approval_Status__c,
                Agency_Non_Suppression_Personnel__r.Name, Agency_Non_Suppression_Personnel__r.CreatedBy.LastName,
                 Agency_Non_Suppression_Personnel__r.CreatedBy.FirstName,Agency_Non_Suppression_Personnel__c
                        FROM Agency_Non_Suppression_Line_Item__c 
                        WHERE Agency_Non_Suppression_Personnel__c = :parentId];
                if(cvs.Size() > 0){
                    items[0].Name = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ cvs[0].Id + '&operationContext=CHATTER&contentId=' + contentDocIds[0];                        
                }
                 return items;
            }else{
                return new list<Agency_Non_Suppression_Line_Item__c>();
            }
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<Agency_Special_Equipment_Line_Item__c> getSpecialEquipmentItems(string accountId, Date dayOfRecord){
        try {
            string parentId;
            list<Agency_Special_Equipment__c> parentRecords = [SELECT Id, Approval_Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Special_Equipment__c
                                                    WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];
         
                                                            
            if(!parentRecords.isEmpty()) {  
                parentId = parentRecords[0].Id;    

                List<String> contentDocIds = new List<String>();
                for(ContentDocumentLink contentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId]) {
                    contentDocIds.add(contentDocLink.ContentDocumentId);
                }
                List<ContentVersion> cvs = [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
                    from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true order by ContentModifiedDate desc];          
           // if(string.isNotBlank(parentId)){
                List<Agency_Special_Equipment_Line_Item__c> items = [SELECT Id, Name, Special_Equipment_Type__c,FEMA_CODE__c, Current_Rate__c, Revised_Rate__c, Description__c,
                        Agency_Special_Equipment__r.Start_Date__c, Agency_Special_Equipment__r.Approval_Status__c,
                        Agency_Special_Equipment__r.Reject_Reason__c, Agency_Special_Equipment__r.End_Date__c,
                        Agency_Special_Equipment__r.CreatedBy.LastName, Agency_Special_Equipment__r.CreatedBy.FirstName,Agency_Special_Equipment__c
                        FROM Agency_Special_Equipment_Line_Item__c 
                        WHERE Agency_Special_Equipment__c = :parentId];
            if(cvs.Size() > 0){
                items[0].Name = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ cvs[0].Id + '&operationContext=CHATTER&contentId=' + contentDocIds[0];                        
            }
                return items;                
            }else{
                return new list<Agency_Special_Equipment_Line_Item__c>();
            }
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static agreementResearch getAgreementLineItems(string accountId, Date dayOfRecord){
        try {
            set<string> parentIds = new set<string>();
            list<Agency_Rate_Agreement__c> parentRecords = [SELECT Id, Approval_Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Rate_Agreement__c
                                                    WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1000];
            for(Agency_Rate_Agreement__c parent: parentRecords){
                parentIds.add(parent.Id);

            }
            agreementResearch result = new agreementResearch();
            if(!parentIds.isEmpty()){
                result.agreementLines = [SELECT Id, Name, Start_Date__c, End_Date__c,MOU_MOA__c, OT__c, PTP__c,Agency_Rate_Agreement__r.Start_Date__c,
                            Agency_Rate_Agreement__r.End_Date__c , Agency_Rate_Agreement__r.Reject_Reason__c,Agency_Rate_Agreement__r.Approval_Status__c,
                            Agency_Rate_Agreement__r.Level_2_Comments__c
                        FROM Agency_Rate_Agreement_Line_Item__c 
                        WHERE Agency_Rate_Agreement__c = :parentIds];

                set<String> contentDocIds = new set<String>();
                for(ContentDocumentLink contentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in: parentIds]) {
                    contentDocIds.add(contentDocLink.ContentDocumentId);
                }
                result.contentVersions = [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
                from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true order by ContentModifiedDate desc];
            
            }else{
                result.agreementLines =  new list<Agency_Rate_Agreement_Line_Item__c>();
                result.contentVersions = new list<ContentVersion>();
            }

            return result;
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<Agency_Admin_Line_Items__c> getAdminLineItems(string accountId, Date dayOfRecord){
        try {
            string parentId;
            list<Agency_Admin_Rates__c> parentRecords = [SELECT Id, Approval_Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Admin_Rates__c
                                                    WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];
        

            //if(string.isNotBlank(parentId)){
            if(!parentRecords.isEmpty()) {  
                parentId = parentRecords[0].Id;    
                List<String> contentDocIds = new List<String>();
                for(ContentDocumentLink contentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId]) {
                        contentDocIds.add(contentDocLink.ContentDocumentId);
                }
                List<ContentVersion> cvs = [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
                    from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true order by ContentModifiedDate desc];                       
                List<Agency_Admin_Line_Items__c> items = [SELECT Id, Name, Direct__c, Indirect__c, Effective_Date__c, Total__c, 
                        Agency_Administrative_Rates__r.Total_Indirect_Amount__c, 
                        Agency_Administrative_Rates__r.Total_Direct_Amount__c,
                        Agency_Administrative_Rates__r.Administrative_Total_Indirect_Direct__c,
                        Agency_Administrative_Rates__r.Administrative_Rate_Indirect_Cost_Direct__c,
                        Agency_Administrative_Rates__r.Start_Date__c,
                        Agency_Administrative_Rates__r.Approval_Status__c,
                        Agency_Administrative_Rates__r.Reject_Reason__c,Agency_Administrative_Rates__c,
                        Agency_Administrative_Rates__r.CreatedBy.LastName, Agency_Administrative_Rates__r.CreatedBy.FirstName
                        FROM Agency_Admin_Line_Items__c 
                        WHERE Agency_Administrative_Rates__c = :parentId];
                if(cvs.Size() > 0){
                    items[0].Name = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ cvs[0].Id + '&operationContext=CHATTER&contentId=' + contentDocIds[0];                        
                }
                return items;   
            }else{
                return new list<Agency_Admin_Line_Items__c>();
            }
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class agreementResearch{
        @AuraEnabled
        public list<ContentVersion> contentVersions {get; set;}
        @AuraEnabled
        public list<Agency_Rate_Agreement_Line_Item__c> agreementLines {get; set;}
    }

    

}