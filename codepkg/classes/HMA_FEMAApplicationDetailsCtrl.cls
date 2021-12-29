/**
 * Created by harsh on 05-08-2021.
 */

public without sharing class HMA_FEMAApplicationDetailsCtrl {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentUserContactRole(String applicationId){
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('isSuccess', false);
            User[] user = [Select Id, ContactId from User where Id=: UserInfo.getUserId()];
            System.debug('user :'+ user);
            if(user.size() > 0){
                Contact_Role__c[] contactRoles = [SELECT Id,
                                                            Role__c, 
                                                            Application__c, 
                                                            Application__r.Status__c, 
                                                            Application__r.Status_Reason__c, 
                                                            Application__r.Is_Any_Open_RFI__c,
                                                            Application__r.Is_this_project_phased__c, 
                                                            Application__r.Project__c,
                                                            Application__r.Child_Application__c, 
                                                            Application__r.Parent_Application__c
                                                            FROM Contact_Role__c WHERE Application__c =:applicationId AND AccountContactJunction__r.Contact_Name__c=:user[0].ContactId];
                System.debug('contactRoles :'+ contactRoles);
                if(contactRoles.size() > 0){
                    returnMap.put('contactRole', contactRoles[0]);
                    returnMap.put('isSuccess', true);
                }
            }
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveApplication(String applicationRecord){
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('isSuccess', false);
            Application__c application = (Application__c) JSON.deserialize(applicationRecord, Application__c.class);
            update application;
            returnMap.put('isSuccess', true);
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}