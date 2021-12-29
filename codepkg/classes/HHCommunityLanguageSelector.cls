/**
 * Created by StackNexus Admin on 25-08-2021.
 */

public without sharing class HHCommunityLanguageSelector {
    /***********************************************
    * Method Name : updateLanguage
    * Author : Sushant
    * Inputs : language
    * Description: This method will Update local language of user when used changes language on portal.
    ************************************************/
    @AuraEnabled
    public static void updateLanguage(String language){
        String UserId = UserInfo.getUserId();
        User user =[SELECT Id FROM User WHERE Id =:UserId];
        user.LanguageLocaleKey = language;
        update user;
    }

    /***********************************************
* Method Name : getLanguage
* Author : Sushant
* Inputs :
* Description: This method will get local language of current user and display it on portal.
************************************************/
    @AuraEnabled
    public static string getLanguage(){
        String UserId = UserInfo.getUserId();
        User user =[SELECT Id,LanguageLocaleKey FROM User WHERE Id =:UserId];
        if(user.LanguageLocaleKey == 'es'){
            return user.LanguageLocaleKey;
        }else{
            return 'en_US';
        }
    }
}