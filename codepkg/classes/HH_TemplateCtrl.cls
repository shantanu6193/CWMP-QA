public without sharing class HH_TemplateCtrl {
    /***********************************************
   * Method Name : getUserName
   * Author : Shantanu
   * Description: This method return's username
   *********************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getUserName() {
        Map<String,Object> result = new Map<String,Object>();
        List<User> userRecord = [SELECT Id, Name, Profile.Name, AccountId, ContactId,
            (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
            FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if(userRecord?.size()==1){
            for(PermissionSetAssignment perSet:userRecord[0].PermissionSetAssignments){
                if(perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName) {
            result.put('isNotHomeOwner', 'false' );
                    result.put('isNotFEMAUser','true'); 
                } else if(perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName) {
                    result.put('isNotFEMAUser','false');
            result.put('isNotHomeOwner', 'true' );
                }  else if(perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName) {
                    result.put('isNotFEMAUser','true');
                    result.put('isNotHomeOwner', 'true' ); 
                }
            }
        }
        result.put('userName', userRecord[0].Name);
        return result;
    }
}