public with sharing class HH_CustomRelatedListRFICtrl {
    

     /***********************************************
   * Method Name : getRFIRecords
   * Author : Shantanu
   * Inputs : String applicationId
   * Description: This method will fetch RFI records for provided CWMP Application Id
   *********************************************/
    @AuraEnabled
    public static  Map<String,Object> getRFIRecords(String applicationId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            List<Request_For_Information__c> rfiList = [SELECT Id,Name,toLabel(Status__c)Status__l, Status__c, CWMP_Application__r.County__c,RFI_Deadline__c,Description__c,CreatedDate
                                                 FROM Request_For_Information__c WHERE CWMP_Application__c =:applicationId 
                                                 ORDER BY LastModifiedDate DESC];
            result.put('rfiList', rfiList);
            result.put('rfiListCount', rfiList.size());
            List<User> userRecord = [SELECT Id, Name, Profile.Name, AccountId, ContactId,
            (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
            FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            if(userRecord[0].Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin) {
                result.put('isRFICreatable',true);    
            }
            if(userRecord?.size()==1){
                result.put('isExternalUser', userRecord[0].AccountId != null);
                result.put('isRFICreatable',true);
                for(PermissionSetAssignment perSet : userRecord[0].PermissionSetAssignments){
                    if(perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName) {
                        result.put('isRFICreatable',false);
                        result.put('isHomeowner', true);
                        result.put('isCommunityUser', false);
                        result.put('isCaloesUser', false);
                        result.put('isFemaUser', false);
                        break;
                    } else if (perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName) {
                        result.put('isRFICreatable',true);
                        result.put('isHomeowner', false);
                        result.put('isCommunityUser', true);
                        result.put('isCaloesUser', false);
                        result.put('isFemaUser', false);
                        break;
                    } else if (perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName) {
                        result.put('isRFICreatable',false);
                        result.put('isHomeowner', false);
                        result.put('isCommunityUser', false);
                        result.put('isCaloesUser', true);
                        result.put('isFemaUser', false);
                        break;     
                    } else if (perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName) {
                        result.put('isRFICreatable',false);
                        result.put('isHomeowner', false);
                        result.put('isCommunityUser', false);
                        result.put('isCaloesUser', false);
                        result.put('isFemaUser', true);
                        break;
                    }
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}