/***********************************************************************************************************************************
* Class Name   : DIP_DashBoard_ListCtrl
* Description  : This class for get Dashboard
* Author       : Pankaj
* Created On   : 04/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             04/09/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class DIP_DashBoard_ListCtrl {

    /***********************************************
    * Method Name : getImportantBoards
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of dashboard from metadata
    *********************************************/
     @AuraEnabled
    public static  Map<String,List<DashBoard_Config__mdt>> getImportantBoards(){

         Map<String,List<DashBoard_Config__mdt>> resultMap = new Map<String,List<DashBoard_Config__mdt>>();

        List<DashBoard_Config__mdt> dashBoardConfigs = [SELECT Id,Label,Dashboard_Description__c,Dashboard_Id__c,Dashboard_Label__c FROM DashBoard_Config__mdt Where is_Active__c=true ORDER BY Dashboard_Label__c];

        resultMap.put('dashBoardConfigs', dashBoardConfigs);

        return resultMap;
    }

}