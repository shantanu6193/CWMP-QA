public class MARSNonSuppressionScreenCtrl {
    @AuraEnabled
    public static List<Agency_Non_Suppression_Personnel__c> getAgencyNonSuppressionLatest(String accountId) {
        
        return [SELECT Id, Start_Date__c, END_Date__c, Approval_Status__c, Name, Reject_Reason__c
                FROM Agency_Non_Suppression_Personnel__c WHERE Agency__c=:accountId AND (Approval_Status__c =: MARS_Constants.SURVEY_STATUS_PENDING_REVIEW OR Approval_Status__c =: MARS_Constants.SURVEY_STATUS_REVIEWED) ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
    }
    
    @AuraEnabled
    public static List<Agency_Non_Suppression_Line_Item__c > getAgencyNonSuppressionLineItems(String agencyNonSuppId) {
        return [SELECT Classification_Title__c,Revised_Rate__c,MOU_MOA_GBR__c,
                Current_Rate__c,Effective_Date__c
               FROM Agency_Non_Suppression_Line_Item__c  WHERE Agency_Non_Suppression_Personnel__c=:agencyNonSuppId];
    }
    
    @AuraEnabled
    public static responseWrapper getData(String accountId) {
        Map<String, Agency_Rate_Agreement_Line_Item__c> agencyAgreementMap = getAgreementLineItemMap(accountId);
        List<Agency_Non_Suppression_Personnel__c> obj = getAgencyNonSuppressionLatest(accountId);
        List<Agency_Non_Suppression_Line_Item__c> lstNonSupLineItems = new List<Agency_Non_Suppression_Line_Item__c>();
         responseWrapper objWrap = new responseWrapper();
        if (!obj.isEmpty()) {
            objWrap.agencyNonSuppPer = obj[0];
            lstNonSupLineItems = getAgencyNonSuppressionLineItems(obj[0].id);
             objWrap.disableSubmit = obj[0].Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW ? true:false;
  
        }
        
        for(Agency_Non_Suppression_Line_Item__c objItem: lstNonSupLineItems){
            objItem.MOU_MOA_GBR__c = agencyAgreementMap.containsKey(objItem.Classification_Title__c)? agencyAgreementMap.get(objItem.Classification_Title__c).PTP__c:false;
        }
        objWrap.nonSuppItemList = lstNonSupLineItems;
       
       
        return objWrap;
    }
    
    @AuraEnabled
    public static void submitNonSuppLines(String data, String accountId, String effectiveDate, String signatureBlob) {
        List<Agency_Non_Suppression_Line_Item__c> lineItemsForUpdateList = (List<Agency_Non_Suppression_Line_Item__c>)JSON.deserialize( data, List<Agency_Non_Suppression_Line_Item__c>.class);
        Account accountRecord = [SELECT Id,MACS_ID__c FROM Account WHERE Id =: accountId];
        Agency_Non_Suppression_Personnel__c agencynonSupp = processAgencyNonSuppPendingForApproval(accountId, Date.valueOf(effectiveDate));
        for (Agency_Non_Suppression_Line_Item__c nonSuppLineItems : lineItemsForUpdateList) {
            nonSuppLineItems.Effective_Date__c = Date.valueOf(effectiveDate);
            nonSuppLineItems.Name = nonSuppLineItems.Classification_Title__c+'-'+accountRecord.MACS_ID__c;
            nonSuppLineItems.Agency_Non_Suppression_Personnel__c = agencynonSupp.Id;
        }
        insert lineItemsForUpdateList;

        if(signatureBlob != null) {
            SignatureHelper.saveSign(signatureBlob, agencynonSupp.Id);
        }
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('RecordId', agencynonSupp.Id);
        Flow.Interview.MARS_Non_Suppression_Submittion_Notify_Internal_People flow1 = new Flow.Interview.MARS_Non_Suppression_Submittion_Notify_Internal_People( paramMap );
        flow1.start();
    }
    
    private static Agency_Non_Suppression_Personnel__c processAgencyNonSuppPendingForApproval(String accountId, Date effectDate) {
       /* List<Agency_Non_Suppression_Personnel__c> agentSalarySurvey =
        [ Select Id, Approval_Status__c From Agency_Non_Suppression_Personnel__c Where Agency__c
                =:accountId and Approval_Status__c = :MARS_Constants.SURVEY_STATUS_PENDING_REVIEW LIMIT 1 ];*/

        Agency_Non_Suppression_Personnel__c ass = new Agency_Non_Suppression_Personnel__c();
            ass.Agency__c = accountId;
            ass.Name = 'Non Suppression For Agency ' + System.now().format();
            ass.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        	ass.Start_Date__c = effectDate;
        insert ass;
        return ass;
    }
    
    private static Map<String, Agency_Rate_Agreement_Line_Item__c> getAgreementLineItemMap(String accountId) {
        Map<String, Agency_Rate_Agreement_Line_Item__c> agencyAgreementMap =
                new Map<String, Agency_Rate_Agreement_Line_Item__c>();
        for (Agency_Rate_Agreement_Line_Item__c eachRecord :
        [ SELECT Id, Name, OT__c,
                PTP__c FROM Agency_Rate_Agreement_Line_Item__c Where
                Agency_Rate_Agreement__r.Agency__c =:accountId ]) {
            for (String name : eachRecord.Name.split(';')) {
                agencyAgreementMap.put(name, eachRecord);
            }
        }
        return agencyAgreementMap;
    }
    
    
    public class responseWrapper{
        @AuraEnabled 
        public List<Agency_Non_Suppression_Line_Item__c> nonSuppItemList = new List<Agency_Non_Suppression_Line_Item__c>();
        @AuraEnabled
        public boolean disableSubmit;
        @AuraEnabled
        public Agency_Non_Suppression_Personnel__c agencyNonSuppPer = new Agency_Non_Suppression_Personnel__c();
    }

}