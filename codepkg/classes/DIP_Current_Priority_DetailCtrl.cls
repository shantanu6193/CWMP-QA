/***********************************************************************************************************************************
* Class Name   : DIP_Current_Priority_DetailCtrl
* Description  : This class for get priority Items
* Author       : Pankaj
* Created On   : 04/15/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             04/15/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class DIP_Current_Priority_DetailCtrl {
   
    /***********************************************
    * Method Name : getPriorityItem
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of PriorityItem and sessionId
    *********************************************/
    @AuraEnabled
    public static  Map<String,Object> getPriorityItem(){

        Map<String,Object> resultMap = new Map<String,Object>();

        List<Current_Priorities__c> priorityItem = [SELECT Id , Priority_Description__c FROM Current_Priorities__c Where Is_Active__c=true
                                                    ORDER BY CreatedDate DESC LIMIT 1];


        resultMap.put('PriorityItem', priorityItem[0]);
        resultMap.put('sessionId',UserInfo.getSessionId());

        return resultMap;
    }

}