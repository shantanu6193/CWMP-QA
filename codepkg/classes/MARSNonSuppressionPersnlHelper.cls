public without sharing class MARSNonSuppressionPersnlHelper {
  public static void updateRelatedSurveyLineItemsToActive(Set<Id> approvedAgencySurveyList) {
        List<Agency_Non_Suppression_Line_Item__c> updateSsli = new List<Agency_Non_Suppression_Line_Item__c>();
        for (Agency_Non_Suppression_Line_Item__c ssli :
         [ SELECT Id, Status__c, Current_Rate__c, Revised_Rate__c 
           from Agency_Non_Suppression_Line_Item__c WHere Agency_Non_Suppression_Personnel__c IN: approvedAgencySurveyList]){
               System.debug('###: ssli: ' + ssli);
               ssli.Current_Rate__c = ssli.Revised_Rate__c;
               ssli.Revised_Rate__c = null;
               ssli.Status__c = 'Active';
              updateSsli.add(ssli);
          }
        System.debug('### updateSsli: ' + updateSsli);
        Database.update(updateSsli, true);
    }
public static void cloneNonSuppressionLineItems(Id surveyIds,boolean isFutureDate,Date effectiveDate) {
        Map<Id, List<Agency_Non_Suppression_Line_Item__c>> surveyWithLineItems =
            new Map<Id, List<Agency_Non_Suppression_Line_Item__c>>();
        List<Agency_Non_Suppression_Personnel__c> updateAgencySurvey =
            new List<Agency_Non_Suppression_Personnel__c>();
        List<Agency_Non_Suppression_Personnel__c> InsertAgencySurvey =
            new List<Agency_Non_Suppression_Personnel__c>();
        String status = '';
        for (Agency_Non_Suppression_Personnel__c assc :
             [ SELECT Id, Approval_Status__c, Agency__c, Start_Date__c, End_Date__c,
              (SELECT Id, Status__c,
               Current_Rate__c, Classification_Title__c, Effective_Date__c,
               Revised_Rate__c from Agency_Non_Suppression_Line_Items__r)
              FROM Agency_Non_Suppression_Personnel__c WHERE Id =: surveyIds ]) {
                  if(isFutureDate){
                      status='Revised'; 
                  }else{
                      status='Expired'; 
                  }
                  surveyWithLineItems.put(assc.id, assc.Agency_Non_Suppression_Line_Items__r);
                  Agency_Non_Suppression_Personnel__c aupdate = new Agency_Non_Suppression_Personnel__c();
                  aupdate.Id = assc.Id;
                  aupdate.Approval_Status__c = status;
                  aupdate.End_Date__c = effectiveDate.addDays(-1);
                  updateAgencySurvey.add(aupdate);
                  // Inserting new Parent
                  Agency_Non_Suppression_Personnel__c ainsert = new Agency_Non_Suppression_Personnel__c();
                  ainsert.Name = 'Non Suppression Personnel :' + system.now();
                  ainsert.Agency__c = assc.Agency__c;
                  ainsert.Revised_From_Id__c = aupdate.Id;
                 ainsert.Start_Date__c = effectiveDate;
                  InsertAgencySurvey.add(ainsert);
              }
        
        if (InsertAgencySurvey.size() > 0) {
            insert InsertAgencySurvey;
            Map<Id, Id> oldwithNewId = new Map<Id, Id>();
            List<Agency_Non_Suppression_Personnel__c> finalAgencySurvey =
                new List<Agency_Non_Suppression_Personnel__c>();
            for (Agency_Non_Suppression_Personnel__c ass : InsertAgencySurvey) {
                ass.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
                finalAgencySurvey.add(ass);
                oldwithNewId.put(ass.Revised_From_Id__c, ass.Id);
            }
            List<Agency_Non_Suppression_Line_Item__c> insertLineItems =
                new List<Agency_Non_Suppression_Line_Item__c>();
            List<Agency_Non_Suppression_Line_Item__c> oldLineItems =
                new List<Agency_Non_Suppression_Line_Item__c>();
            for (Id parentOldSurvey : surveyWithLineItems.keySet()) {
                if (oldwithNewId.containsKey(parentOldSurvey)) {
                    for (Agency_Non_Suppression_Line_Item__c ssl :
                         surveyWithLineItems.get(parentOldSurvey)) {
                             Agency_Non_Suppression_Line_Item__c newLineItem =
                                 ssl.clone(false, false, false, false);
                             ssl.Status__c = status;
                             oldLineItems.add(ssl);
                             newLineItem.Status__c = '';
                             newLineItem.Agency_Non_Suppression_Personnel__c =
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