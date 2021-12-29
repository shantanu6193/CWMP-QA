public without sharing class MARS_FileListCtrl {
    @AuraEnabled
    public static Map<String, Object> getContents(String recordId, List<String> otherRecordIds, String dateFieldAPIName, String fileTypesToHide) {
        Map<String, Object> returnMap = new Map<String, Object>();
        recordId = String.isNotBlank(recordId) ? string.escapeSingleQuotes(recordId) : recordId;
        dateFieldAPIName = String.isNotBlank(dateFieldAPIName) ? string.escapeSingleQuotes(dateFieldAPIName) : dateFieldAPIName;

        returnMap.put('contentVersions', getContentVersions(new List<String>{recordId}, fileTypesToHide));
        returnMap.put('otherContentVersions', getContentVersions(otherRecordIds, fileTypesToHide));
        if(String.isNotEmpty(dateFieldAPIName)) {
            String objectAPIName = String.valueOf(Id.valueOf(recordId).getSobjectType());
            String query = 'select ' + dateFieldAPIName + ' from ' + objectAPIName + ' where Id=:recordId';
            SObject sobj = Database.query(query);
            Datetime dateTimeToCompare = (DateTime)sobj.get(dateFieldAPIName);
            returnMap.put('dateTime', dateTimeToCompare);
        } else {
            returnMap.put('dateTime', null);
        }
        return returnMap;
    }

    private static List<ContentVersion> getContentVersions(List<String> otherRecordIds, String fileTypesToHide) {

        Set<Id> contentDocIds = new Set<Id>();
        System.debug('otherRecordIds---' + otherRecordIds);
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(otherRecordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }
        List<String> filesToHide = new List<String>();
        if(String.isNotEmpty(fileTypesToHide)) {
            filesToHide = fileTypesToHide.split(',');
        }
        system.debug('==contentDocIds==='+contentDocIds);
        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND Type__c NOT IN :filesToHide and IsLatest=true and ContentDocument.FileType != 'SNOTE' order by ContentModifiedDate desc];
    }

    @Auraenabled
    public static Map<String, Object> deleteFile(String fileId, String recordId, List<String> otherRecordIds, String dateFieldAPIName, String fileTypesToHide) {
        system.debug('==fileId=in delteFileById==='+fileId);
        system.debug('==recordId=in delteFileById==='+recordId);
        ContentDocument fileToDelete=[SELECT Id,Title,FileType,CreatedDate,Owner.Name FROM ContentDocument where id=:fileId];
        delete fileToDelete;
        return getContents(recordId, otherRecordIds, dateFieldAPIName, fileTypesToHide); //fetchContentDocument();
    }
    /*
    @AuraEnabled 
    public static List<contentDocument> fetchContentDocument(){
        return [Select id,Title,FileType,Description,CreatedBy.Name,ContentSize,CreatedDate,Owner.Name From contentDocument Limit 10];
    }*/
    /*@AuraEnabled
    public static string DownloadAttachment(Id DownloadAttachmentID)
    {
         system.debug('DownloadAttachment called==');
        //ContentVersion oldCV = [Select Id,Title from ContentVersion Where ContentDocumentId=:DownloadAttachmentID and IsLatest = true ];
        String fullFileURL = 'https://graphiterx--dev.cs40.my.salesforce.com';
        //URL.getSalesforceBaseUrl().toExternalForm();
        String URlDownload = fullFileURL+'/sfc/servlet.shepherd/version/download/'+DownloadAttachmentID;
        system.debug('Download URL:' +URlDownload);
        return URlDownload;
    }*/
   }