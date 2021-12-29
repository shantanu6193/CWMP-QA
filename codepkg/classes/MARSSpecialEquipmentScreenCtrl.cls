public class MARSSpecialEquipmentScreenCtrl {
 
   @AuraEnabled
    public static List<Agency_Special_Equipment__c> getSpecialEquipmentLatest(String accountId) {
         
        return [SELECT Id, Start_Date__c, End_Date__c, Approval_Status__c, Name, Reject_Reason__c
                FROM Agency_Special_Equipment__c WHERE Agency__c=:accountId AND (Approval_Status__c =: MARS_Constants.SURVEY_STATUS_PENDING_REVIEW OR Approval_Status__c =: MARS_Constants.SURVEY_STATUS_REVIEWED) ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
    }
    
    @AuraEnabled
    public static List<Agency_Special_Equipment_Line_Item__c > getSpecialEquipmentLineItems(String agencySplEquipId) {
        return [SELECT Special_Equipment_Type__c ,Revised_Rate__c,Effective_Date__c, Description__c,FEMA_CODE__c
               FROM Agency_Special_Equipment_Line_Item__c  WHERE Agency_Special_Equipment__c=:agencySplEquipId];
    }
    
    @AuraEnabled
    public static responseWrapper getData(String accountId) {
        List<Agency_Special_Equipment__c> obj = getSpecialEquipmentLatest(accountId);
        List<Agency_Special_Equipment_Line_Item__c> lstSpecEquipItems = new List<Agency_Special_Equipment_Line_Item__c>();
        responseWrapper objWrap = new responseWrapper();
        
        if (!obj.isEmpty()) {
          lstSpecEquipItems = getSpecialEquipmentLineItems(obj[0].id);   
             objWrap.disableSubmit = obj[0].Approval_Status__c == MARS_Constants.SURVEY_STATUS_PENDING_REVIEW ? true:false;
             objWrap.specEquip = obj[0];
        }
       
        objWrap.specEquipList = lstSpecEquipItems;
       
        return objWrap;
    }
    
    @AuraEnabled
    public static void submitSpecEquipLines(String data, String accountId, String effectiveDate, String signatureBlob) {
        List<Agency_Special_Equipment_Line_Item__c> lineItemsForUpdateList = (List<Agency_Special_Equipment_Line_Item__c>)JSON.deserialize( data, List<Agency_Special_Equipment_Line_Item__c>.class);
        Account accountRecord = [SELECT Id,MACS_ID__c FROM Account WHERE Id =: accountId];
        Agency_Special_Equipment__c agencySplEquip = processAgencySplEquiPendingForApproval(accountId, Date.valueOf(effectiveDate));
        for (Agency_Special_Equipment_Line_Item__c splEquipLineItems : lineItemsForUpdateList) {
            splEquipLineItems.Effective_Date__c = Date.valueOf(effectiveDate);
            splEquipLineItems.Agency_Special_Equipment__c = agencySplEquip.Id;
            splEquipLineItems.Name = splEquipLineItems.Special_Equipment_Type__c+'-'+accountRecord.MACS_ID__c;
        }
        insert lineItemsForUpdateList;

        if(signatureBlob != null) {
            SignatureHelper.saveSign(signatureBlob, agencySplEquip.Id);
        }
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('RecordId', agencySplEquip.Id);
        Flow.Interview.MARS_Special_Equipment_Submittion_Notify_Internal_People flow1 = new Flow.Interview.MARS_Special_Equipment_Submittion_Notify_Internal_People( paramMap );
        flow1.start();
    }
    
    private static Agency_Special_Equipment__c processAgencySplEquiPendingForApproval(String accountId, Date effectDate) {
        Agency_Special_Equipment__c ass = new Agency_Special_Equipment__c();
             ass.Agency__c = accountId;
            ass.Name = 'Special Equipment ' + System.now().format();
            ass.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        	ass.Start_Date__c = effectDate;
            insert ass;
        
        return ass;
    }
    
    public class responseWrapper{
        @AuraEnabled 
        public List<Agency_Special_Equipment_Line_Item__c> specEquipList = new List<Agency_Special_Equipment_Line_Item__c>();
        @AuraEnabled
        public boolean disableSubmit;
        @AuraEnabled   
        public Agency_Special_Equipment__c specEquip = new Agency_Special_Equipment__c();
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFemaCode(String searchTerm, List<String> selectedIds) {
        String query = 'SELECT Id,Name, Equipment__c, HP__c, Current_Rate__c FROM FEMA_Code_LineItem__c WHERE FEMA_Code__r.Status__c = \'Active\' ';
        searchTerm = searchTerm.replace(' ','%');
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR Equipment__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit ' + 50;
        system.debug('Query '+query);
        List<FEMA_Code_LineItem__c> lineItems = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String icon = 'utility:lightning_extension';
        for (FEMA_Code_LineItem__c code : lineItems) {
            results.add(
                    new LookupSearchResult(
                            code.Id,
                            'FEMA CODE',
                            icon,
                            code.Name,
                            code.Equipment__c+', HP-'+code.HP__c,
                            code
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        return results;
    }
}