public
with sharing class MarsAgencyRateAgreementHelper {
 public
  static void updateRelatedSurveyLineItemsToActive(
      Set<Id> approvedAgencySurveyList) {
    List<Agency_Rate_Agreement_Line_Item__c> updateSsli =
        new List<Agency_Rate_Agreement_Line_Item__c>();
    for (Agency_Rate_Agreement_Line_Item__c ssli :
         [ SELECT Id,
           Status__c from Agency_Rate_Agreement_Line_Item__c WHere
               Agency_Rate_Agreement__c IN:approvedAgencySurveyList ]) {
      System.debug('###: ssli: ' + ssli);
      ssli.Status__c = 'Active';
      updateSsli.add(ssli);
    }
    System.debug('### updateSsli: ' + updateSsli);
    Database.update(updateSsli, true);
  }
 public
  static void cloneNonSuppressionLineItems(Id surveyIds) {
    Map<Id, List<Agency_Rate_Agreement_Line_Item__c>> surveyWithLineItems =
        new Map<Id, List<Agency_Rate_Agreement_Line_Item__c>>();
    List<Agency_Rate_Agreement__c> updateAgencySurvey =
        new List<Agency_Rate_Agreement__c>();
    List<Agency_Rate_Agreement__c> InsertAgencySurvey =
        new List<Agency_Rate_Agreement__c>();
    for (Agency_Rate_Agreement__c assc :
         [ SELECT Id, Approval_Status__c, Agency__c,
           (SELECT Id, Status__c from Agency_Rate_Agreement_Line_Items__r)
               FROM Agency_Rate_Agreement__c WHERE Id =:surveyIds ]) {
      surveyWithLineItems.put(assc.id,
                              assc.Agency_Rate_Agreement_Line_Items__r);
      Agency_Rate_Agreement__c aupdate = new Agency_Rate_Agreement__c();
      aupdate.Id = assc.Id;
      aupdate.Approval_Status__c = 'Expired';
      updateAgencySurvey.add(aupdate);
      // Inserting new Parent
      Agency_Rate_Agreement__c ainsert = new Agency_Rate_Agreement__c();
      ainsert.Name = 'Agency Rate Agreement :' + system.now();
      ainsert.Agency__c = assc.Agency__c;
      InsertAgencySurvey.add(ainsert);
    }

    if (InsertAgencySurvey.size() > 0) {
      insert InsertAgencySurvey;
      Map<Id, Id> oldwithNewId = new Map<Id, Id>();
      List<Agency_Rate_Agreement__c> finalAgencySurvey =
          new List<Agency_Rate_Agreement__c>();
      for (Agency_Rate_Agreement__c ass : InsertAgencySurvey) {
        ass.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        finalAgencySurvey.add(ass);
        oldwithNewId.put(ass.Revised_From_Id__c, ass.Id);
      }
      List<Agency_Rate_Agreement_Line_Item__c> insertLineItems =
          new List<Agency_Rate_Agreement_Line_Item__c>();
      List<Agency_Rate_Agreement_Line_Item__c> oldLineItems =
          new List<Agency_Rate_Agreement_Line_Item__c>();
      for (Id parentOldSurvey : surveyWithLineItems.keySet()) {
        if (oldwithNewId.containsKey(parentOldSurvey)) {
          for (Agency_Rate_Agreement_Line_Item__c ssl :
               surveyWithLineItems.get(parentOldSurvey)) {
            Agency_Rate_Agreement_Line_Item__c newLineItem =
                ssl.clone(false, false, false, false);
            ssl.Status__c = 'Expired';
            oldLineItems.add(ssl);
            newLineItem.Agency_Rate_Agreement__c =
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