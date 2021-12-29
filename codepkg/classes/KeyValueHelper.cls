/***********************************************************************************************************************************
* Class Name   : KeyValueHelper
* Description  : This class for HMA NOI Request
* Author       : Pankaj
* Created On   : 05/18/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               05/18/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class KeyValueHelper {

    /***********************************************
    * Method Name : getTextValue
    * Author : Pankaj
    * Inputs : String key
    * Description: This method return string from metadata
    *********************************************/
    public static String getTextValue(String key) {
        return [SELECT Id,Text_Value__c FROM Key_Value_Store__mdt WHERE DeveloperName = :key].Text_Value__c;
    }
}