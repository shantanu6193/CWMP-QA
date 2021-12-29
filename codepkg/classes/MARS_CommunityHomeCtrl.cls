public without sharing class MARS_CommunityHomeCtrl {
    @AuraEnabled
    public static Map<String, Object> checkPermission() {
        Map<String, Object> permissionMap = new Map<String, Object>();
        List<PermissionSetAssignment> userRegPermission = [Select Id from PermissionSetAssignment where PermissionSet.Name = 'User_Registration_Permission' AND AssigneeId =: UserInfo.getUserId()];
        if(userRegPermission.size() == 0) {
            permissionMap.put('UserRegPermission',false);
        }
        else {
            permissionMap.put('UserRegPermission',true);
        }
        return permissionMap;
    }
}