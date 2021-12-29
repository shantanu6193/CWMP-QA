/***********************************************************************************************************************************
* Class Name   : CommunityResetPasswordCtrl
* Description  : This class for community user reset password
* Author       : Pankaj
* Created On   : 07/25/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             07/25/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunityResetPasswordCtrl {
    
    /***********************************************
    * Method Name : resetPassword
    * Author : Pankaj
    * Inputs : String username
    * Description: This method create new registration when user request for reset password
    *********************************************/
    @AuraEnabled
    public static void resetPassword(String username, String language, String recordTypeName){
        /** Updated Cde Added 2 (language, recordTypeName) parameters for HH Community **/
        String recordType = recordTypeName;
        String translationLanguage = language;
        /** If recordType is null set default Record type name as Registration  **/
        if(recordType == null || recordType == '' || recordType == 'undefined'){
            recordType = HH_CONSTANTS.RecordType_Registration;
        }
        /** If translationLanguage is null set default language as English  **/
        if(translationLanguage == null || translationLanguage == '' || translationLanguage == 'undefined'){
            translationLanguage = HH_CONSTANTS.Language_English;
        }
        /** added Contact.Account.Name to get houseHoldUniqueNumber of current user **/
        List<User> user = [SELECT Id, Contact.Account.Name, FirstName, LastName, Email FROM User where Username =:username];
        if(user.size() == 0){
            throw new CustomException(System.Label.HH_EN_UserNotFoundError);
        } else {
            /* check the permission set assignments*/
            List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment 
                                                                    WHERE Assignee.Id =:user[0].Id];
            /* Check if its homeowner */
            Boolean isHomeowner = false;
            for(PermissionSetAssignment pr:permissionSetAssignments) {
                if(pr.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName ){
                    isHomeowner = true;
                    break;
                }
            }
            /** If users record type is Home Hardening then update HouseHold Unique Number in UR record **/
            String houseHoldUniqueNumber ='';
            if(user[0].Contact.Account.Name != null && recordType == System.Label.HH_RecordType_API_Name_HH_Registration){
                String str = user[0].Contact.Account.Name;
                List<String> res = str.split('-', 2);
                houseHoldUniqueNumber = res[0];
            }
            User_Registration__c userRegistration = new User_Registration__c();
            userRegistration.User__c = user[0].Id;
            userRegistration.Status__c = HH_CONSTANTS.UserRegistration_Status_PasswordReset;
            userRegistration.Email__c = user[0].Email;
            userRegistration.First_Name__c = user[0].FirstName;
            userRegistration.Last_Name__c = user[0].LastName;
            String token = SkyWalkerUtility.generateToken(40);
            userRegistration.Token__c = token;
            /** Updated ".get(recordType)." with dynamic variable to get HH record type as well  **/
            Id registrationRecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            userRegistration.RecordTypeId = registrationRecordTypeId;
            /** Added two fields which are required for HH Community **/
            userRegistration.Translation_Language__c = translationLanguage;
            System.debug('Is Homeowner: '+isHomeowner);
            if(isHomeowner) {
            userRegistration.Unique_Household_Number__c = houseHoldUniqueNumber;
            }
            insert userRegistration;
        }
    }

    /***********************************************************************************************************************************
    * Class Name   : CustomException
    * Description  : This class for throwing custom exception
    * Author       : Pankaj
    * Created On   : 07/25/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj             07/25/2020       Initial Implementation
    **************************************************************************************************************************************/

    public class CustomException extends Exception {
   
    }
}