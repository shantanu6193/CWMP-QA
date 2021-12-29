public
with sharing class MARSAdministrativeRateHelper {
 public
  static void updateRelatedSurveyLineItemsToActive(
      Set<Id> approvedAgencySurveyList) {
    List<Agency_Admin_Line_Items__c> updateSsli =
        new List<Agency_Admin_Line_Items__c>();
    for (Agency_Admin_Line_Items__c ssli :
         [ SELECT Id,
           Status__c from Agency_Admin_Line_Items__c WHere Agency_Administrative_Rates__c
           IN:approvedAgencySurveyList ]) {
      System.debug('###: ssli: ' + ssli);
      ssli.Status__c = 'Active';
      updateSsli.add(ssli);
    }
    System.debug('### updateSsli: ' + updateSsli);
    Database.update(updateSsli, true);
  }
 public
  static void cloneNonSuppressionLineItems(Id surveyIds, boolean isFutureDate,Date effectiveDate) {
    Map<Id, List<Agency_Admin_Line_Items__c>> surveyWithLineItems =
        new Map<Id, List<Agency_Admin_Line_Items__c>>();
    List<Agency_Admin_Rates__c> updateAgencySurvey =
        new List<Agency_Admin_Rates__c>();
    List<Agency_Admin_Rates__c> InsertAgencySurvey =
        new List<Agency_Admin_Rates__c>();
     String status='';
    for (Agency_Admin_Rates__c assc :
         [ SELECT Id, Approval_Status__c, Agency__c, Start_Date__c, End_Date__c,
           (SELECT Id, Status__c from Agency_Admin_Line_Items__r)
               FROM Agency_Admin_Rates__c WHERE Id =:surveyIds ]) {
       if(isFutureDate){
                      status='Revised'; 
                  }else{
                      status='Expired'; 
                  }
      surveyWithLineItems.put(assc.id,
                              assc.Agency_Admin_Line_Items__r);
      Agency_Admin_Rates__c aupdate = new Agency_Admin_Rates__c();
      aupdate.Id = assc.Id;
      aupdate.Approval_Status__c = status;
      aupdate.End_Date__c = effectiveDate.addDays(-1);
      updateAgencySurvey.add(aupdate);
      // Inserting new Parent
      Agency_Admin_Rates__c ainsert = new Agency_Admin_Rates__c();
      ainsert.Name = 'Agency Rate Agreement :' + system.now();
      ainsert.Agency__c = assc.Agency__c;
      ainsert.Start_Date__c = effectiveDate;
      InsertAgencySurvey.add(ainsert);
    }

    if (InsertAgencySurvey.size() > 0) {
      insert InsertAgencySurvey;
      Map<Id, Id> oldwithNewId = new Map<Id, Id>();
      List<Agency_Admin_Rates__c> finalAgencySurvey =
          new List<Agency_Admin_Rates__c>();
      for (Agency_Admin_Rates__c ass : InsertAgencySurvey) {
        ass.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        finalAgencySurvey.add(ass);
        oldwithNewId.put(ass.Revised_From_Id__c, ass.Id);
      }
      List<Agency_Admin_Line_Items__c> insertLineItems =
          new List<Agency_Admin_Line_Items__c>();
      List<Agency_Admin_Line_Items__c> oldLineItems =
          new List<Agency_Admin_Line_Items__c>();
      for (Id parentOldSurvey : surveyWithLineItems.keySet()) {
        if (oldwithNewId.containsKey(parentOldSurvey)) {
          for (Agency_Admin_Line_Items__c ssl :
               surveyWithLineItems.get(parentOldSurvey)) {
            Agency_Admin_Line_Items__c newLineItem =
                ssl.clone(false, false, false, false);
            ssl.Status__c = 'Expired';
            oldLineItems.add(ssl);
            newLineItem.Agency_Administrative_Rates__c =
                oldwithNewId.get(parentOldSurvey);
            insertLineItems.add(newLineItem);
          }
        }
      }
      try {
        insert insertLineItems;
        update oldLineItems;
        update finalAgencySurvey;
        update updateAgencySurvey;
      } catch (exception e) {
        system.debug('-------------' + e.getMessage());
      }
    }
  }
}