public class MARS_Invoice_AllDocuments {
    
    private static final String DOWNLOAD_URL = '/sfc/servlet.shepherd/version/download/';
    @AuraEnabled
    public static InvoiceDocumentsWrapper getAllRelatedFiles(Id recordId) {
       // Map<string, List<ContentDocumentLink>> mapDoc = new Map<string, List<ContentDocumentLink>>();
        Invoice__c objInvoice = [select id, (select id,F_42__c,F_42__r.Name,Expense_Claim__c,Expense_Claim__r.name,name from F_42_Invoices__r) from Invoice__c where id =:recordId];
        //set<id> setChildIds = new set<id>();
        map<id, string> mapRec = new map<id, string>();
        /*for(F42__c objF42: objInvoice.F_42s__r){
            mapRec.put(objF42.id, objF42.Name);
            setChildIds.add(objF42.id);
        }*/
        for(F_42_Invoices__c objExp: objInvoice.F_42_Invoices__r){
            mapRec.put(objExp.Expense_Claim__c, objExp.Expense_Claim__r.name);
            //setChildIds.add(objExp.Expense_Claim__c);
            //setChildIds
            mapRec.put(objExp.F_42__c, objExp.F_42__r.Name);
        }
        Map<Id, Id> contentIdLinkedIdMap = new Map<Id, Id>();
        for(ContentDocumentLink objCon: [Select id,LinkedEntityId, ContentDocumentId, ContentDocument.title from ContentDocumentLink where LinkedEntityId in :mapRec.keyset() order by ContentDocument.CreatedDate asc]){
           contentIdLinkedIdMap.put(objCon.ContentDocumentId, objCon.LinkedEntityId);
            /* if(mapDoc.containsKey(objCon.LinkedEntityId)){
                List<ContentDocumentLink> lstDoc = new List<ContentDocumentLink>();
                lstDoc = mapDoc.get(objCon.LinkedEntityId);
                lstDoc.add(objCon);
                mapDoc.put(mapRec.get(objCon.LinkedEntityId), lstDoc);}
        
        else{
            mapDoc.put(mapRec.get(objCon.LinkedEntityId), new List<ContentDocumentLink>{objCon});
        }*/
        }
        InvoiceDocumentsWrapper wrapper = new InvoiceDocumentsWrapper();
        Map<String, List<ContentVersion>> mapDoc = new Map<String, List<ContentVersion>>();
        Map<Id, String> contentVersionToObjectId = new Map<Id, String>();
        Map<String, String> allContentVersionURLsMap = new Map<String, String>();
        for (ContentVersion eachContentVersion : [Select Id, Title, ContentDocumentId From ContentVersion Where ContentDocumentId IN: contentIdLinkedIdMap.keySet() and IsLatest = true AND (NOT Title LIKE '%signature%')]) {
            String recName = mapRec.get(contentIdLinkedIdMap.get(eachContentVersion.ContentDocumentId));
            if (mapDoc.containsKey(recName)) {
                mapDoc.get(recName).add(eachContentVersion);
            } else {
                mapDoc.put(recName, new List<ContentVersion>{eachContentVersion});
            }
            if (allContentVersionURLsMap.containsKey(recName)) {
                 allContentVersionURLsMap.put(recName, allContentVersionURLsMap.get(recName) + '/' + eachContentVersion.Id);
            } else {
                allContentVersionURLsMap.put(recName, DOWNLOAD_URL + eachContentVersion.Id);
            }
        }
        wrapper.mapDocs = mapDoc;
        wrapper.allContentVersionURLsMap = allContentVersionURLsMap;
        system.debug('mapDoc: '+mapDoc);
        return wrapper;
    }
    
    public class InvoiceDocumentsWrapper {
        @AuraEnabled
        public  Map<String, List<ContentVersion>> mapDocs {get; set;}
        @AuraEnabled
        public  Map<String, String> allContentVersionURLsMap {get; set;}
        @AuraEnabled
        public Map<Id, String> recordToURLMapping {get; set;}
    }

}