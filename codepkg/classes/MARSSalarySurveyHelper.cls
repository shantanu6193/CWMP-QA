/***********************************************************************************************************************************
 * Class Name   : SalarySurveyHelper
 * Description  : This is Helper class for SalarySurveyTrigger
 * Author       : Aneesha
 * Created On   : 03/14/2020
 * Modification Log:
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aneesha                03/14/2020       Initial Implementation
 **************************************************************************************************************************************/
public without sharing
class MARSSalarySurveyHelper{
    //using this approval controller
    public static void updateRelatedSurveyLineItemsToActive(Set<Id> approvedAgencySurveyList) {
        List<Salary_Survey_Line_Items__c> updateSsli = new List<Salary_Survey_Line_Items__c>();
        for (Salary_Survey_Line_Items__c ssli :
         [ SELECT Id, Base_Rates__c, WC_and_or_UI__c, Current_Rate__c, Revised_Rate__c, Status__c
           from Salary_Survey_Line_Items__c WHere Agency_Salary_Survey__c IN: approvedAgencySurveyList]){
               System.debug('###: ssli: ' + ssli);
             
             ssli.WC_and_or_UI__c = 'No';
               ssli.Current_Rate__c = ssli.Revised_Rate__c; 
               ssli.Revised_Rate__c = null;
               ssli.Status__c = 'Active';
              updateSsli.add(ssli);
          }
        System.debug('### updateSsli: ' + updateSsli);
        Database.update(updateSsli, true);
    }

  public static void cloneTheSurveyLineItems(Id surveyId) {
    Map<Id, List<Salary_Survey_Line_Items__c>> surveyWithLineItems =
        new Map<Id, List<Salary_Survey_Line_Items__c>>();
    List<Agency_Salary_Survey__c> updateAgencySurvey =
        new List<Agency_Salary_Survey__c>();
    List<Agency_Salary_Survey__c> InsertAgencySurvey =
        new List<Agency_Salary_Survey__c>();
    for (Agency_Salary_Survey__c assc :
         [ SELECT Id, Status__c, Account__c, Start_Date__c, END_Date__c,
           Actual_Admin_Rate__c, Workers_Comp_Insurance_Rate__c,
           Unemployment_Insurance_Rate__c, Revised_From_Id__c,
           (SELECT Id, Account__c, Base_Rates__c, CFAA__c, CFAA_Line_Items__c,
            Classification_Title__c, Current_Rate__c, Effective_Date__c,
            WC_and_or_UI__c, Line_Item_Type__c, Revised_Rate__c,
            Type__c from Salary_Survey_Line_Items__r)
               FROM Agency_Salary_Survey__c WHERE Id =: surveyId ]) {
      surveyWithLineItems.put(assc.id, assc.Salary_Survey_Line_Items__r);
      Agency_Salary_Survey__c aupdate = new Agency_Salary_Survey__c();
      aupdate.Id = assc.Id;
      aupdate.END_Date__c = System.today();
      aupdate.Status__c = 'Expired';
      aupdate.IsArchive__c = true;
      updateAgencySurvey.add(aupdate);
      // Inserting new Parent
      Agency_Salary_Survey__c ainsert = new Agency_Salary_Survey__c();
      ainsert.Name = 'Salary Survey For Agency :' + system.now();
      ainsert.Account__c = assc.Account__c;
      ainsert.Revised_From_Id__c = assc.Id;
      ainsert.Start_Date__c = System.today();
      ainsert.Actual_Admin_Rate__c = assc.Actual_Admin_Rate__c;
      ainsert.Unemployment_Insurance_Rate__c =
          assc.Unemployment_Insurance_Rate__c;
      ainsert.Workers_Comp_Insurance_Rate__c =
          assc.Workers_Comp_Insurance_Rate__c;
      InsertAgencySurvey.add(ainsert);
    }

    if (InsertAgencySurvey.size() > 0) {
      insert InsertAgencySurvey;
      Map<Id, Id> oldwithNewId = new Map<Id, Id>();
      List<Agency_Salary_Survey__c> finalAgencySurvey =
          new List<Agency_Salary_Survey__c>();
      for (Agency_Salary_Survey__c ass : InsertAgencySurvey) {
        ass.status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        finalAgencySurvey.add(ass);
        oldwithNewId.put(ass.Revised_From_Id__c, ass.Id);
      }
      List<Salary_Survey_Line_Items__c> insertLineItems =
          new List<Salary_Survey_Line_Items__c>();
      List<Salary_Survey_Line_Items__c> oldLineItems =
          new List<Salary_Survey_Line_Items__c>();
      for (Id parentOldSurvey : surveyWithLineItems.keySet()) {
        if (oldwithNewId.containsKey(parentOldSurvey)) {
          for (Salary_Survey_Line_Items__c ssl :
               surveyWithLineItems.get(parentOldSurvey)) {
            Salary_Survey_Line_Items__c newLineItem =
                ssl.clone(false, false, false, false);
            ssl.Status__c = 'Expired';
            oldLineItems.add(ssl);
            newLineItem.Agency_Salary_Survey__c =
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