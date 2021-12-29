/***********************************************************************************************************************************
* Class Name   : CommunitySetPasswordCtrl
* Description  : This class for community new user to set password
* Author       : Pankaj
* Created On   : 07/13/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             07/13/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunitySetPasswordCtrl {
   
    /***********************************************
    * Method Name : setPassword
    * Author : Pankaj
    * Inputs : String token, String password
    * Description: This method verify the new user using token and set password for new registered user.
    *********************************************/
    @AuraEnabled
    public static String setPassword(String token, String password) {
        try {
			if(String.isEmpty(password)) {
            	throw new CustomException('Password empty');
        	}
            If(String.isEmpty(token)) {
                throw new CustomException(System.Label.Token_empty);
            }
            /** Added recordtypeid in Query **/
            List<User_Registration__c> recToValidate = [Select Id, recordtypeid, Name, Email__c, Token__c, Status__c, Password__c, User__r.Id From User_Registration__c where Token__c =: token];
    
            if(recToValidate.size() == 0) {
                throw new CustomException(System.Label.HH_EN_Invalid_token);
            } 
            if(recToValidate.size() == 1 && recToValidate[0].Status__c == HH_CONSTANTS.UserRegistration_Status_Verified) {
                throw new CustomException(System.Label.HH_EN_ExistingUserWithEmailErrorMessage);
            } 
            if(recToValidate.size() == 1 && recToValidate[0].Status__c == HH_CONSTANTS.UserRegistration_Status_VerificationPending) {
                recToValidate[0].Status__c = HH_CONSTANTS.UserRegistration_Status_Verified;
                recToValidate[0].Password__c = password;
                update recToValidate;
            } 
            if(recToValidate.size() == 1 && recToValidate[0].Status__c == HH_CONSTANTS.UserRegistration_Status_PasswordReset) {
                System.setPassword(recToValidate[0].User__r.Id, password);
                recToValidate[0].Status__c = 'Password Set';
                update recToValidate;
            } 
            String userName =  String.valueOf(recToValidate[0].Email__c);
            
    
            if(String.isNotEmpty(userName) && (String.isNotEmpty(password))) {
                /** to get record Type Name **/
                string recordTypeName = Schema.SObjectType.User_Registration__c.getRecordTypeInfosById().get(recToValidate[0].recordtypeid).getDeveloperName();
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/s';
                ApexPages.PageReference pageRef = new PageReference(baseUrl);
                /** if users RecordType is Home Hardening redirect to Home-Hardening Home page **/
                if(recordTypeName == HH_CONSTANTS.RecordType_HH_RegistrationAPIName){
                     baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + System.Label.HH_url_LoginURL;
                    pageRef = new PageReference(baseUrl);
                } else {
                    pageRef = Site.login(userName, password, baseUrl);
                }
                System.debug('baseURL---->'+baseUrl);
                return pageRef.getUrl();
                //Site.login(userName,password,'hmadev-caloes.cs32.force.com/s');
            }    
            else{
                return null;
            } 
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    /***********************************************
    * Method Name : checkPasswordExpired
    * Author : Chandrabhan
    * Inputs : String token
    * Description: This method verify the new user using token is used or not.
    *********************************************/
    @AuraEnabled
    public static Boolean checkPasswordExpired(String token) {
        List<User_Registration__c> recToValidate = [SELECT Id, Name, Status__c FROM User_Registration__c WHERE Token__c =: token];
        if(recToValidate.size() == 1 && (recToValidate[0].Status__c == 'Verification Pending' || recToValidate[0].Status__c == 'Password Reset')) {
            return true;
        } 
        return false;
    }

    /***********************************************************************************************************************************
    * Class Name   : CustomException
    * Description  : This class for throwing custom exception
    * Author       : Pankaj
    * Created On   : 07/13/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj             07/13/2020       Initial Implementation
    **************************************************************************************************************************************/

    public class CustomException extends Exception {
   
    }
  

}