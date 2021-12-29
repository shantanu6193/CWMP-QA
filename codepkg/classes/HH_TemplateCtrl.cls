public without sharing class HH_TemplateCtrl {
    /***********************************************
   * Method Name : getUserName
   * Author : Shantanu
   * Description: This method return's username
   *********************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUserName() {
        Map<String,String> result = new Map<String,String>();
        User user = [SELECT Id,Name,Contact.Contact_Type__c FROM User WHERE Id =:UserInfo.getUserId()];
        if(user.Contact.Contact_Type__c == HH_CONSTANTS.HH_Contact_Type_Homeowner){
            result.put('isNotHomeOwner', 'false' );
        }else{
            result.put('isNotHomeOwner', 'true' );
        }
        result.put('userName', user.Name);
        return result;
    }
}