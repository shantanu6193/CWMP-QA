public with sharing class MARS_F42Approval_Controller {

    @AuraEnabled
    public static string initialize(string recId){
        try {
            F42__c f42 = [SELECT Id, Status__c FROM F42__c WHERE Id=: recId LIMIT 1];
            if(f42.Status__c == 'CALOES REVIEW'){
                return 'Proceed';
            }
            if(f42.Status__c == 'AGENCY REVIEW' ){
                return 'This F42 is pending Agency Review. No Action needed at this point.';
            }
            if(f42.Status__c == 'APPROVED' ){
                return 'This F42 is Approved. No Action needed at this point.';
            }
            if(f42.Status__c == 'DOCUMENTATION ONLY'){
                return 'This F42 is marked as Documentation Only. No Action needed at this point.';
            }
            
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void f42Approval(string recId, string status, string comment){
        try {

            F_42_Review_Comments__c comm = new F_42_Review_Comments__c();
            comm.F_42__c         = recId;
            comm.Comment_By__c   = 'Mutual Aid Staff';
            comm.Comment__c      = comment;
            insert comm;

            F42__c f42 = [SELECT Id, Status__c FROM F42__c WHERE Id=: recId LIMIT 1];
            f42.Status__c = status;
            update f42;
 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}