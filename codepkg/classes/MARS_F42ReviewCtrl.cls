public without sharing class MARS_F42ReviewCtrl {
  @AuraEnabled(Cacheable = true) public static List<F42__c> getAdditionalInfoRequiredF42(string accountId) {
    system.debug('accountId: ' + accountId);
    system.debug('rows: ' +[ select id, Name from F42__c where Account__c =:accountId ]);
    return [select Id, Incident_Name__c, Incident_Order__c, Strike_Team__c, Incident_Request_Number__c, DI_Committed_to_Incident_Date__c, 
            DI_Redispatched_Date__c, ER_UNIT__c, OH_ICS_Title__c, Status__c 
            FROM F42__c 
            WHERE Account__c=:accountId 
            AND Invoice__c = null
            ORDER BY Status__c ASC];
  }

  @AuraEnabled public static F42Wrapper
      getIndividualF42(String Id) {
    System.debug('### Id: ' + Id);
    F42Wrapper wrapper = new F42Wrapper();
    wrapper.f42Rec = getF42Record(Id);
    wrapper.personnelInfoRecs = getPersonnelInfoRecords(Id);
    wrapper.actualHoursRecs = getActualHoursRecords(Id);
    wrapper.commentRecs = getCommentRecords(Id);
          wrapper.mutualStaffComment = getLatestMutualStaffComment(Id);
          wrapper.documentLink = getSignatureFile(Id);
          wrapper.f42DocumentLink = getF42EntrySignatureFile(Id);
    return wrapper;
  }
    
    @AuraEnabled
    public static String updateAgencyPrimaryUserComment(String comment, String f42Id) {
        F_42_Review_Comments__c  newComment = new F_42_Review_Comments__c (Comment__c = comment, F_42__c = f42Id, Comment_By__c = 'Agency Primary User');
        insert newComment;
        update new F42__c(Id = f42Id, Status__c = 'Caloes Review');
        return 'success';
    }

 private
  static F42__c getF42Record(String Id) {
    return [ SELECT Id,
             Name, CreatedDate,
            Status__c,
             Account__r.Name,
             Account__r.MACS_ID__c,
             Account__r.Mars_Agency_Designator__c,
             DI_Committed_to_Incident_Date__c,
            DI_Committed_to_Incident_Time__c,
             Incident_Order__c,
             Incident_Request_Number__c,
             Incident_Name__c,
             DT_NEW_INCIDENT__r.Name,
             DT_NEW_INCIDENT__r.Incident_Start_Date__c,
             DT_NEW_INCIDENT_REQUEST__c,
             DT_NEW_INCIDENT__r.Order_No__c,
             DF_OLD_INCIDENT__r.Name,
             DF_OLD_INCIDENT_REQUEST__c,
             DI_REDISPATCHED__c,
            DI_Redispatched_Date__c,
            DF_Dispatch_From_End_Date__c,
            Submission_Time__c,
            DT_Dispatch_To_Start_Date__c,
            DI_Redispatched_Time__c,
             SV_LICENSE__c,
             SV_BEGINNING_ODODMETER__c,
             SV_ENDING_ODOMETER__c,
             SV_TOTAL_MILES__c,
             ER_APPARATUS__c,
             ER_TYPE__c,
             DF_OLD_INCIDENT__r.Order_No__c,
             DF_OLD_INCIDENT__r.Incident_Start_Date__c,
            DF_OLD_INCIDENT__r.Incident_End_Date__c,
             ER_LICENSE_NUMBER__c,
             ER_CDF_OES_VEHICLE__c,
             ER_FEMA_CODES__c,
             SN_LOSS_DAMAGE_CLAIM__c,
             SN_SUPPLY_NUMBER__c,
             DI_REPORTING_LOCATION__c,
             DI_RETURN_FROM_INCIDENT__c,
            DI_Return_from_Incident_Date__c,
            DI_Return_from_Incident_Time__c,
             DI_COMMITTED_TO_INCIDENT_FORMULA__c,
             PA_PRINTED_NAME__c,
            PA_Date__c,
             PA_ICS_POSITION_TITLE__c,
             PA_Cal_OES_REPRESENTATIVE__c,
            OH_ICS_Title__c,
            OH_OTHER_ICS_TITLE__c,
            ICS_Title_Description__c,
            DI_Mobilization_Center_Preposition__c, OH_OVERHEAD_TYPE__c,
            SV_VEHICLE_OWNERSHIP__c, SV_TYPE__c, ER_SPECIAL_EQUIPMENT__c, PA_PAYING_AGENCY__c,
             ER_UNIT__c, PI_NUMBER_OF_PERSONNEL_ON_APPARATUS__c, PI_DOCUMENTATION_ONLY__c,
            RA_YOUR_PHONE__c, RA_YOUR_NAME__c, RA_YOUR_TITLE__c, Strike_Team__c,PA_CALOESREP_DATE__c FROM F42__c WHERE Id =:Id LIMIT 1 ];
  }

 private
  static List<F_42_Personnel_Info__c> getPersonnelInfoRecords(String f42Id) {
    return [ SELECT Id, Name, MACS_ID__c, Rank_Job_Title__c,
             SSN__c, CDF__c, Portal_To_Portal__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM F_42_Personnel_Info__c WHERE F_42__c =:f42Id ];
  }

 private
  static List<F_42_Actual_Hours__c> getActualHoursRecords(String f42Id) {
    return [ SELECT Id, Name, Date__c, Start_Time__c, End_Time__c,
             Hours__c FROM F_42_Actual_Hours__c WHERE F_42__c =:f42Id ];
  }

 private
  static List<F_42_Comment__c> getCommentRecords(String f42Id) {
    return [ SELECT Id, Name, Date__c, Comment__c, Time__c FROM F_42_Comment__c WHERE F_42__c
             =:f42Id ];
  }
    
    private static String getLatestMutualStaffComment(String f42Id) {
        List<F_42_Review_Comments__c> commentsRec = [SELECT Id, Comment__c, Comment_By__c FROM F_42_Review_Comments__c WHERE F_42__c =: f42Id
                                             AND Comment_By__c = 'Mutual Aid Staff' ORDER BY CreatedDate DESC LIMIT 1];
        return !commentsRec.isEmpty() ? commentsRec[0].Comment__c : '';
    }
    
    private static String  getSignatureFile(String Id) {
        List<ContentDocumentLink> contentDocumentIdList = [SELECT Id, ContentDocumentId, ShareType FROM ContentDocumentLink Where LinkedEntityId =: Id AND ContentDocument.Title LIKE '%Responding Agency Signature%' ORDER BY SystemModStamp DESC LIMIT 1];
        if (contentDocumentIdList.isEmpty()) {
            return '';
        }
        ContentVersion contentVersion = [Select Id, ContentUrl From ContentVersion Where ContentDocumentId =: contentDocumentIdList[0].ContentDocumentId AND IsLatest = true];
        return  '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ contentVersion.Id + '&operationContext=CHATTER&contentId=' + contentDocumentIdList[0].ContentDocumentId;
    }
    
     private static String  getF42EntrySignatureFile(String Id) {
        Id f43EntryId = [Select Id, F42_Entry__c From F42__c Where Id = : Id LIMIT 1].F42_Entry__c;
         if (String.isBlank(f43EntryId)) {
             return '';
         }
        List<ContentDocumentLink> contentDocumentIdList = [SELECT Id, ContentDocumentId, ShareType FROM ContentDocumentLink Where LinkedEntityId =: f43EntryId AND ContentDocument.Title LIKE '%Paying Agency Signature%' ORDER BY SystemModStamp DESC LIMIT 1];

        if (contentDocumentIdList.isEmpty()) {
            return '';
        }
        ContentVersion contentVersion = [Select Id, ContentUrl From ContentVersion Where ContentDocumentId =: contentDocumentIdList[0].ContentDocumentId AND IsLatest = true];
        return  '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ contentVersion.Id + '&operationContext=CHATTER&contentId=' + contentDocumentIdList[0].ContentDocumentId;
    }

 public
  class F42Wrapper {
    @AuraEnabled public F42__c f42Rec {
      get;
      set;
    }
    @AuraEnabled public List<F_42_Personnel_Info__c> personnelInfoRecs {
      get;
      set;
    }
    @AuraEnabled public List<F_42_Actual_Hours__c> actualHoursRecs {
      get;
      set;
    }
    @AuraEnabled public List<F_42_Comment__c> commentRecs {
      get;
      set;
    }
    @AuraEnabled public String mutualStaffComment {get; set;}
    @AuraEnabled public String documentLink {get; set;}
      @AuraEnabled public String f42DocumentLink {get; set;}
  }
}