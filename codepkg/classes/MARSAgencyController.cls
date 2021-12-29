public
class MARSAgencyController {
  @AuraEnabled public static Boolean updateTheParentToApproved(
      String salaryId) {
    try {
      Id sObjectID = (salaryId != null ? Id.valueOf(salaryId) : null);
      String sObjName = sObjectID.getSObjectType().getDescribe().getName();
      if (sObjName == 'Agency_Salary_Survey__c') {
        Agency_Salary_Survey__c ass = new Agency_Salary_Survey__c();
        ass.Id = salaryId;
        ass.Status__c = 'Approved';
        update ass;
        MARSSalarySurveyHelper.updateRelatedSurveyLineItemsToActive(
            new Set<Id>{salaryId});
        return true;
      } else if (sObjName == 'Agency_Special_Equipment__c') {
        Agency_Special_Equipment__c ase = new Agency_Special_Equipment__c();
        ase.Id = salaryId; 
        ase.Approval_Status__c = 'Approved';
        update ase;
        updateRelatedSurveyLineItemsToActive(
            new Set<Id>{salaryId});
        return true;
      } else if (sObjName == 'Agency_Non_Suppression_Personnel__c') {
        Agency_Non_Suppression_Personnel__c ase =
            new Agency_Non_Suppression_Personnel__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Approved';
        update ase;
        MARSNonSuppressionPersnlHelper.updateRelatedSurveyLineItemsToActive(
            new Set<Id>{salaryId});
        return true;
      } else if (sObjName == 'Agency_Rate_Agreement__c') {
        Agency_Rate_Agreement__c ase = new Agency_Rate_Agreement__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Approved';
        update ase;
        MarsAgencyRateAgreementHelper.updateRelatedSurveyLineItemsToActive(
            new Set<Id>{salaryId});
      } else if (sObjName == 'Agency_Admin_Rates__c') {
        Agency_Admin_Rates__c ase = new Agency_Admin_Rates__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Approved';
        update ase;
        MARSAdministrativeRateHelper.updateRelatedSurveyLineItemsToActive(
            new Set<Id>{salaryId});
      }

    } catch (exception e) {
      return false;
    }
    return false;
  }

  /*@AuraEnabled public static Boolean checkingExistingStatus(String salaryId) {
    String currentStatus =
        [ Select Id, Status__c from Agency_Salary_Survey__c where Id
          =:salaryId LIMIT 1 ]
            .Status__c;
    system.debug('===========' + currentStatus);
    if (currentStatus != 'Pending for Approval') {
      return true;
    } else {
      return false;
    }
  }*/

  @AuraEnabled public static Boolean updateTheParentToExpired(String salaryId,String rejectReason) {
    try {
      Id sObjectID = (salaryId != null ? Id.valueOf(salaryId) : null);
      String sObjName = sObjectID.getSObjectType().getDescribe().getName();
      if (sObjName == 'Agency_Salary_Survey__c') {
        Agency_Salary_Survey__c ass = new Agency_Salary_Survey__c();
        ass.Id = salaryId;
        ass.Status__c = 'Expired';
        ass.Reject_Reason__c=rejectReason;
        update ass;
        List<Salary_Survey_Line_Items__c> updateSsli =
            new List<Salary_Survey_Line_Items__c>();
        for (Salary_Survey_Line_Items__c ssli :
             [ SELECT Id, Base_Rates__c, WC_and_or_UI__c, Current_Rate__c,
               Revised_Rate__c,
               Status__c from Salary_Survey_Line_Items__c WHere
                   Agency_Salary_Survey__c
               =:salaryId and Status__c != 'Expired' ]) {
          System.debug('###: ssli: ' + ssli);

          ssli.WC_and_or_UI__c = 'No';
          ssli.Current_Rate__c = ssli.Revised_Rate__c;
          ssli.Revised_Rate__c = null;
          ssli.Status__c = 'Expired';
          updateSsli.add(ssli);
        }
        System.debug('### updateSsli: ' + updateSsli);
        Database.update(updateSsli, true);
        return true;
      } else if (sObjName == 'Agency_Special_Equipment__c') {
        Agency_Special_Equipment__c ase = new Agency_Special_Equipment__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Expired';
        ase.Reject_Reason__c=rejectReason;
        update ase;
        List<Agency_Special_Equipment_Line_Item__c> updateSsli =
            new List<Agency_Special_Equipment_Line_Item__c>();
        for (Agency_Special_Equipment_Line_Item__c ssli :
             [ SELECT Id, Current_Rate__c, Effective_Date__c, Revised_Rate__c,
               Special_Equipment_Type__c from
                   Agency_Special_Equipment_Line_Item__c WHERE
                       Agency_Special_Equipment__c
               =:salaryId and Status__c != 'Expired' ]) {
          ssli.Status__c = 'Expired';
          updateSsli.add(ssli);
        }
        Database.update(updateSsli, true);
        return true;
      } else if (sObjName == 'Agency_Non_Suppression_Personnel__c') {
        Agency_Non_Suppression_Personnel__c ase =
            new Agency_Non_Suppression_Personnel__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Expired';
        ase.Reject_Reason__c=rejectReason;
        update ase;
        List<Agency_Non_Suppression_Line_Item__c> updateSsli =
            new List<Agency_Non_Suppression_Line_Item__c>();
        for (Agency_Non_Suppression_Line_Item__c ssli :
             [ SELECT Id, Status__c from Agency_Non_Suppression_Line_Item__c
                              WHere Agency_Non_Suppression_Personnel__c
               =:salaryId and Status__c != 'Expired' ]) {
          System.debug('###: ssli: ' + ssli);
          ssli.Status__c = 'Expired';
          updateSsli.add(ssli);
        }
        Database.update(updateSsli, true);
        return true;
      } else if (sObjName == 'Agency_Rate_Agreement__c') {
        Agency_Rate_Agreement__c ase = new Agency_Rate_Agreement__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Expired';
        ase.Reject_Reason__c=rejectReason;
        update ase;
        List<Agency_Rate_Agreement_Line_Item__c> updateSsli =
            new List<Agency_Rate_Agreement_Line_Item__c>();
        for (Agency_Rate_Agreement_Line_Item__c ssli :
             [ SELECT Id, Status__c from Agency_Rate_Agreement_Line_Item__c
                              WHere Agency_Rate_Agreement__c
               =:salaryId and Status__c != 'Expired' ]) {
          System.debug('###: ssli: ' + ssli);
          ssli.Status__c = 'Expired';
          updateSsli.add(ssli);
        }
        Database.update(updateSsli, true);
        return true;
      } else if (sObjName == 'Agency_Admin_Rates__c') {
        Agency_Admin_Rates__c ase = new Agency_Admin_Rates__c();
        ase.Id = salaryId;
        ase.Approval_Status__c = 'Expired';
        ase.Reject_Reason__c=rejectReason;
        update ase;
        List<Agency_Admin_Line_Items__c> updateSsli =
            new List<Agency_Admin_Line_Items__c>();
        for (Agency_Admin_Line_Items__c ssli :
             [ SELECT Id, Status__c from Agency_Admin_Line_Items__c WHere
                              Agency_Administrative_Rates__c
               =:salaryId and Status__c != 'Expired' ]) {
          System.debug('###: ssli: ' + ssli);
          ssli.Status__c = 'Expired';
          updateSsli.add(ssli);
        }
        Database.update(updateSsli, true);
        return true;
      }
    } catch (exception e) {
      return false;
    }
    return false;
  }

  public static void updateRelatedSurveyLineItemsToActive(Set<Id> approvedAgencySurveyList) {
    List<Agency_Special_Equipment_Line_Item__c> updateSsli = new List<Agency_Special_Equipment_Line_Item__c>();
    for (Agency_Special_Equipment_Line_Item__c ssli :
         [ SELECT Id,Current_Rate__c, Revised_Rate__c, Status__c
          from Agency_Special_Equipment_Line_Item__c WHere Agency_Special_Equipment__c IN: approvedAgencySurveyList]){
              System.debug('###: ssli: ' + ssli);
              ssli.Current_Rate__c = ssli.Revised_Rate__c;
              ssli.Revised_Rate__c = null;
              ssli.Status__c = 'Active';
              updateSsli.add(ssli);
          }
    System.debug('### updateSsli: ' + updateSsli);
    Database.update(updateSsli, true);
}
}