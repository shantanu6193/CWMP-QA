public without sharing class MARS_ResourceAgreementCtrl {
    private final static Integer MAX_RESULTS = 9999;
    
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> apexSearchCFAA_Line_Items(String searchTerm, String agencyId) {
        system.debug('agencyId===='+agencyId+'=>searchTerm=='+searchTerm);
        // Prepare query paramters
        //searchTerm += '*'; 
        User user = ApexUtils.getCurrentUserDetails();
        String query = 'Select Id, Personnel_Role__c,Order_No__c from CFAA_Line_Items__c where CFAA__c != null and '+
           'CFAA__r.Start_Date__c <= today and (CFAA__r.END_Date__c >= today OR CFAA__r.End_Date__c = null) and RecordType.Name = \'Personnel Base Rate\'';
        
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Personnel_Role__c like\'%' + searchTerm + '%\')';
        }
        query += ' ORDER BY Order_No__c ASC';
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<CFAA_Line_Items__c> agreementList = Database.query(query);
        List<LookupSearchResult> results = searchapexSearchCFAA_Line_Items(agreementList, true);
        System.debug('results---' + results);
        List<Agency_Non_Suppression_Personnel__c>  agencyNonSupPer = [SELECT Id FROM Agency_Non_Suppression_Personnel__c WHERE Agency__c=:agencyId AND Approval_Status__c =: MARS_Constants.SURVEY_STATUS_REVIEWED ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
        if(agencyNonSupPer.size() > 0) {
            List<Agency_Non_Suppression_Line_Item__c> nonSupLineItem = [SELECT Id, Classification_Title__c FROM Agency_Non_Suppression_Line_Item__c  WHERE Agency_Non_Suppression_Personnel__c=:agencyNonSupPer[0].Id];
            // Prepare results
            List<LookupSearchResult> results1 = searchapexNonSupp_Line_Items(nonSupLineItem,true);
            System.debug('results1---' + results1);
            results.addAll(results1);
        }

        return results;
    }

    private static List<LookupSearchResult> searchapexSearchCFAA_Line_Items( List<CFAA_Line_Items__c> agreementList, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productIcon = 'standard:user_role';
        for (CFAA_Line_Items__c agreementReference : agreementList) {
            results.add(new LookupSearchResult(
                            agreementReference.Id,
                            'CFAA_Line_Items__c',
                            productIcon,
                            agreementReference.Personnel_Role__c,
                            null,
                            agreementReference
                    )
            );
        }
        // Optionnaly sort all results on title
        //results.sort();
        System.debug('results---' + results);
        return results;
    }
    private static List<LookupSearchResult> searchapexNonSupp_Line_Items( List<Agency_Non_Suppression_Line_Item__c> agreementList, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productIcon = 'standard:user_role';
        for (Agency_Non_Suppression_Line_Item__c agreementReference : agreementList) {
            results.add(new LookupSearchResult(
                            agreementReference.Id,
                            'Agency_Non_Suppression_Line_Item__c',
                            productIcon,
                            agreementReference.Classification_Title__c,
                            null,
                            agreementReference
                    )
            );
        }
        // Optionnaly sort all results on title
        //results.sort();
        System.debug('results---' + results);
        return results;
    }
    @AuraEnabled 
    public static void createAgreeLineItem(String agreementList,String accountId,String startDate,String endDate, String fileUpdateWrapper,String agreementType) {
        Agency_Rate_Agreement__c araRec = getAgencyRateAgreement(accountId);
        araRec.Start_Date__c = Date.valueOf(startDate);
        if(endDate != null && !String.isEmpty(endDate))
            araRec.End_Date__c = Date.valueOf(endDate);
        araRec.Agreement_Type__c = agreementType;
        update araRec;
        List<Agency_Rate_Agreement_Line_Item__c> lineItemsForUpdateList = (List<Agency_Rate_Agreement_Line_Item__c>)JSON.deserialize(agreementList, List<Agency_Rate_Agreement_Line_Item__c>.class);
        for (Agency_Rate_Agreement_Line_Item__c agreementLineItems : lineItemsForUpdateList) {
            agreementLineItems.Agency_Rate_Agreement__c = araRec.Id;
        }
        insert lineItemsForUpdateList;

        if(fileUpdateWrapper != null) {
            List<FileUpdateWrapper> fileDocUpdateList = (List<FileUpdateWrapper>)JSON.deserialize(fileUpdateWrapper, List<FileUpdateWrapper>.class);
            if(fileDocUpdateList.size() > 0){
                Map<String,String> cvIdMap = new Map<String,String>();
                for(FileUpdateWrapper fuw : fileDocUpdateList){
                    cvIdMap.put(fuw.contentVersionId,fuw.Type);
                }
                Set<Id> cdIdSet = new Set<Id>();
                List<ContentVersion> cvUpdateList = [SELECT Id,Type__c,ContentDocumentId FROM ContentVersion WHERE Id=:cvIdMap.keySet()];
                for(ContentVersion cvRec : cvUpdateList){
                    cdIdSet.add(cvRec.ContentDocumentId);
                    if(cvIdMap.containsKey(cvRec.Id) && cvRec.Type__c == null){
                        cvRec.Type__c = cvIdMap.get(cvRec.Id);
                    }
                }
                if(!cvUpdateList.isEmpty() && cvUpdateList != null) 
                    update cvUpdateList;
                System.debug('ContentDocumentLink 84==>'+cvUpdateList.size());

                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                List<ContentDocumentLink> cdlExt = new List<ContentDocumentLink>();
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:accountId AND ContentDocumentId=:cdIdSet]) {
                                                ContentDocumentLink cloned = cdl.clone();
                                                cloned.LinkedEntityId = araRec.Id;
                                                cloned.ShareType = cdl.ShareType;
                                                cdlList.add(cloned);
                                                cdlExt.add(cdl);
                                                }
                insert cdlList; // new CDL records
                delete cdlExt; // delete old CDL records

            }
        }
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('RecordId', araRec.Id);
        Flow.Interview.MARS_Agreement_Submittion_Notify_Internal_People flow1 = new Flow.Interview.MARS_Agreement_Submittion_Notify_Internal_People( paramMap );
        flow1.start();

        //return objRec;
    }
    private static Agency_Rate_Agreement__c getAgencyRateAgreement(String accountId) {
        Agency_Rate_Agreement__c arg = new Agency_Rate_Agreement__c();
        List<Agency_Rate_Agreement__c> agencyRateAgreement =[Select Id,Approval_Status__c from Agency_Rate_Agreement__c Where Agency__c=:accountId AND Approval_Status__c =: MARS_Constants.SURVEY_STATUS_PENDING_REVIEW Limit 1];
        if (agencyRateAgreement.isEmpty()) {
            arg.Agency__c = accountId;
            arg.Name = 'Agency Rate Agreement ' + System.now().format();
            arg.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        } else {
            arg = agencyRateAgreement.get(0);
            delete [SELECT Id FROM Agency_Rate_Agreement_Line_Item__c WHERE Agency_Rate_Agreement__c=:arg.Id];
        }
        upsert arg;
        return arg;
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

    @AuraEnabled
    public static Map<String, Object> getData(String accountId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Agency_Rate_Agreement__c> agencyRateAgr = [SELECT Id,Approval_Status__c
                FROM Agency_Rate_Agreement__c WHERE Agency__c =:accountId ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
        Boolean ispendingforAppoval = false;
        if(agencyRateAgr.size() > 0) {
            ispendingforAppoval = agencyRateAgr[0].Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW ? true:false;
        }
        returnMap.put('disableSubmit', ispendingforAppoval);
        return returnMap;
    }
}