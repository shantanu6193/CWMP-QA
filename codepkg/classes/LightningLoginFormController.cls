/***********************************************************************************************************************************
* Class Name   : LightningLoginFormController
* Description  : standard login class is customized with few custom logic and Added support for login through custom LWC component
* Author       : Pankaj
* Created On   : 4/24/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               4/24/2020       Initial Implementation
**************************************************************************************************************************************/
global without sharing class  LightningLoginFormController {

    /***********************************************
    * Method Name : login
    * Author : Pankaj
    * Inputs : String username, String password, String startUrl
    * Description: This method return string for Redirect URL
    *********************************************/
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
           
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /***********************************************
        * Method Name : checkForHHHomeowner
        * Author : Shantanu
        * Inputs : String username,String startUrl
        * Description: This method restrict homeowner to login main portal.
    *********************************************/
    private Static void checkForHHHomeowner(String username, String startUrl) {
        if(String.isNotEmpty(startUrl)) {
            if(startUrl.contains(Label.HH_Community_Relative_Url)){
                return;
            }
        }
       
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id,PermissionSet.Name,PermissionSet.Profile.Name, 
                                                                    AssigneeId,Assignee.Username, Assignee.Profile.Name 
                                                                    FROM PermissionSetAssignment 
                                                                    WHERE PermissionSet.Name =:HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName  
                                                                    AND Assignee.Username =:username];
        if(permissionSetAssignments.size() > 0) {
            throw new AuraHandledException('You do not have access to login.');
        }
    }

    /***********************************************
    * Method Name : loginLWC
    * Author : Pankaj
    * Inputs : String username, String password, String startUrl
    * Description: This method return map of URL and success
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> loginLWC(String username, String password, String startUrl) {
        Map<String, Object> returnMap = new Map<String, Object>();
        System.debug('starturl: '+startUrl);
        System.debug('username: '+username);
        checkForHHHomeowner(username,startUrl);
        ApexPages.PageReference lgn = Site.login(username, password, startUrl);
        returnMap.put('success', true);
        if(!Test.isRunningTest()){
            returnMap.put('url', lgn.getUrl());  
        } 
        return returnMap;
    }

    /***********************************************
    * Method Name : getIsUsernamePasswordEnabled
    * Author : Pankaj
    * Inputs : -
    * Description: This method return true if user name and password are enabled
    *********************************************/
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    /***********************************************
    * Method Name : getIsSelfRegistrationEnabled
    * Author : Pankaj
    * Inputs : -
    * Description: This method return true if self registration is enabled
    *********************************************/
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    /***********************************************
    * Method Name : getSelfRegistrationUrl
    * Author : Pankaj
    * Inputs : -
    * Description: This method return string of url for self registration
    *********************************************/
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    /***********************************************
    * Method Name : getForgotPasswordUrl
    * Author : Pankaj
    * Inputs : -
    * Description: This method return string of url for forgot password
    *********************************************/
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }

    /***********************************************
    * Method Name : getAuthConfig
    * Author : Pankaj
    * Inputs : -
    * Description: This method return Auth.AuthConfiguration
    *********************************************/
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        if(Test.isRunningTest()) {
        }
        return authConfig;
    }

    /***********************************************
    * Method Name : setExperienceId
    * Author : Pankaj
    * Inputs : String expId
    * Description: This method return null string if there is no error, else it will return the error message 
    *********************************************/
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
 }