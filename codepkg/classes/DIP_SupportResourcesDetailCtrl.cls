/***********************************************************************************************************************************
* Class Name   : DIP_SupportResourcesDetailCtrl
* Description  : This class for get DIP support resources detail
* Author       : Pankaj
* Created On   : 05/13/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             05/13/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class DIP_SupportResourcesDetailCtrl {
    
    /***********************************************
    * Method Name : getSupportResources
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of SupportResources and sessionId
    *********************************************/
    @AuraEnabled
    public static  Map<String,Object> getSupportResources(){

        Map<String,Object> resultMap = new Map<String,Object>();

        List<Support_Resource__c> SupportResources = [SELECT Id , Description__c FROM Support_Resource__c Where Is_Active__c=true
        ORDER BY CreatedDate DESC LIMIT 1];

        if(SupportResources.size()>0) {
            resultMap.put('SupportResources', SupportResources[0]);
        }else{
            resultMap.put('Error','No Support Resources Found');
        }
        resultMap.put('sessionId',UserInfo.getSessionId());

        return resultMap;
    }

}