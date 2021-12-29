public with sharing class HH_CheckExistingDraftApplicationsCtrl {
    
    @AuraEnabled
    public static Map<String,Object> getExistingDraftApplicationsCount() {
        Map<String,Object> result = new Map<String,Object>();
        Integer appCount = [SELECT Count() FROM HH_Application__c 
                            WHERE OwnerId =:UserInfo.getUserId() AND 
                            Stage__c =: HH_CONSTANTS.HHApplication_Stage_Draft AND
                            Status__c != :HH_CONSTANTS.HHApplication_Status_Withdrawn];
        result.put('totalDraftApplications', appCount);
        return result;                    
    }
}