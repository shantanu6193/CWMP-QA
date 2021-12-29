public without sharing class MARS_AgencyPageTabsCtrl {
    @AuraEnabled
    public static String getUserTabAccess(String accountId) {
        String userAccess = '';
        User userRec = [SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()];
        if(userRec.ContactId == null) return userAccess;

        List<AccountContactRelation> accountContactRelations = [SELECT Relationship_Strength__c FROM AccountContactRelation WHERE AccountId=:accountId
                AND ContactId=:userRec.ContactId];
        if(accountContactRelations.size() > 0) { 
            userAccess = accountContactRelations[0].Relationship_Strength__c;
        }
        return userAccess;
    }
}