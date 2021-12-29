/***********************************************************************************************************************************
* Class Name   : UtilityCtrl
* Description  : UtilityCtrl Class contains method related to utility Lwc 
* Author       : Shantanu
* Created On   : 06/12/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu            06/12/2021      Initial Implementation
**************************************************************************************************************************************/

public without sharing class UtilityCtrl {
    

    /***********************************************
    * Method Name : isGuestUser
    * Author : Shantanu
    * Inputs : -
    * Description: This method return true if logged in user is Guest User
    *********************************************/
    @AuraEnabled
    public static Boolean isGuestUser() {
        return UserInfo.getUserType() == 'Guest' ? true : false;
    }
}