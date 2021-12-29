public without sharing class HH_EditRequestCtrl {
    
    /***********************************************
    * Method Name : getInitData
    * Author : Shantanu
    * Inputs : 1. String appId(HH_Application__c) 
    * Description: This method will determine the when to enable edit button depending 
                    user permission set,
                    Application record stage and status
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getInitData(String appId) {
        Map<String, Object> returnMap  = new Map<String, Object>();
        try {
            List<User> userRecord = [SELECT Id, Name, Profile.Name, AccountId, ContactId,
            (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
            FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            set<String> prSet = new Set<String>();
            if(userRecord?.size()==1){
                for(PermissionSetAssignment perSet:userRecord[0].PermissionSetAssignments){
                    prSet.add(perSet.PermissionSet.Name);
                }
                if(userRecord[0]?.profile.Name == HH_CONSTANTS.HH_System_Admin_Profile_Name) {
                    returnMap.put('isEdit', true);
                } else {
                    Boolean isEdit;
                    //if (userRecord[0].AccountId != null) {
                        HH_Application__c app = [SELECT Id,Stage__c,Status__c From HH_Application__c WHERE Id=:appId];
                        if(app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                            && app.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn) {
                            isEdit = true;
                        } else if (prSet.contains(HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName)
                                && app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo) {
                            isEdit = true;
                        } else if(prSet.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                                &&((app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                        &&(app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                            ||app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress
                                            ||app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))
                                    ||(app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment)
                                    ||(app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))) {
                            isEdit = true;
                        }
                    else if(prSet.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)
                                &&((app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                        &&(app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                            ||app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress
                                            ||app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))
                                    ||(app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                        && app.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment)
                                    ||(app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                        && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                    || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                        && app.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))) {
 
                            isEdit = true;
                    }
                    else {
                        isEdit = false;
                    }

                    /** Post MVP - Sprint 6 - To remove the above and uncomment the below. */
                    /*if (prSet.contains(HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName)
                            && ((app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft 
                                    && app.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                        && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))) {
                        isEdit = true;
                    }
                    else if(prSet.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                            && ((app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                    && app.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                    && (app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                        || app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress
                                        || app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI))) {
                        isEdit = true;
                    }
                    else if(prSet.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)
                            && ((app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft
                                    && app.Status__c != HH_CONSTANTS.HHApplication_Status_Withdrawn)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                    && (app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewPending
                                        ||app.Status__c == HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress
                                        ||app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo))
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityDecision
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI)
                                || (app.Stage__c == HH_CONSTANTS.HHApplication_Stage_FEMAReview
                                    && app.Status__c == HH_CONSTANTS.HHApplication_Status_FEMAReviewOpenRFI))) {
                        isEdit = true;
                    }
                    else {
                        isEdit = false;
                    }*/

                        returnMap.put('isEdit', isEdit);
                        returnMap.put('recordId',appId);
                        returnMap.put('isExternalUser',userRecord[0].AccountId != null);
                    /*} else {
                        isEdit = false;
                        returnMap.put('isEdit', isEdit);
                        returnMap.put('recordId',appId);
                    }   */
                }
            }
        } catch (Exception e) {
            System.debug('Error : '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }

    public static Boolean isApplicationEditable(String applicationId) {
        
        return (Boolean)getInitData(applicationId).get('isEdit');
    }
}