/**
 * Created by PREM on 30-12-2020.
 */

public without sharing class PHOS_CommunityHomeCtrl {
    @AuraEnabled
    public static List<KnowledgeArticleVersion> getArticles() {
        List<KnowledgeArticleVersion> knowledgeList = [SELECT Id,KnowledgeArticleId,Language,PublishStatus,Summary,Title,UrlName FROM KnowledgeArticleVersion where PublishStatus = 'Online' AND Language = 'en_US' WITH DATA CATEGORY PHOS__c below PHOS_Portal__c];
        return knowledgeList;
    }
    @AuraEnabled
    public static Map<String, Object> getData() {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<PHOS_Document_Repository__mdt> docList = [SELECT DeveloperName,Id,Is_Active__c,Label,Language,MasterLabel,Sequence__c,URL__c FROM PHOS_Document_Repository__mdt where Is_Active__c = true Order By Sequence__c];
        returnMap.put('DocumentList',docList);
        returnMap.put('KnowledgeList',getArticles());
        returnMap.put('UserRegPermission',checkPermission().get('UserRegPermission'));
        return returnMap;
    }
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