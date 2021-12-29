/***********************************************************************************************************************************
* Class Name   : PHOS_DistributionPlanVersionCtrl
* Description  : This class for PHOS distribution version
* Author       : Pankaj
* Created On   : 09/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              09/09/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class PHOS_DistributionPlanVersionCtrl {
    
    /***********************************************
    * Method Name : getVersion
    * Author : Pankaj
    * Inputs : String versionId
    * Description: This method return map of order products and distribution version
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getVersion(String versionId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Distribution_Plan_Version__c distributionVersion = [SELECT CreatedBy.Name,CreatedDate,Id,Name,Old_Version_Data__c,Order__c,Version_Data__c,Version_Data_2__c,Version_Data_3__c,Version_Data_4__c,Version_Data_5__c,Version_Data_6__c,Version__c FROM Distribution_Plan_Version__c  where Id=:versionId];
        //String allVersionData = distributionVersion.Version_Data__c + distributionVersion.Version_Data_2__c + distributionVersion.Version_Data_3__c + distributionVersion.Version_Data_4__c + distributionVersion.Version_Data_5__c;
        String allVersionData = (String.isNotEmpty(distributionVersion.Version_Data__c) ? distributionVersion.Version_Data__c : '') + (String.isNotEmpty(distributionVersion.Version_Data_2__c) ? distributionVersion.Version_Data_2__c : '') + (String.isNotEmpty(distributionVersion.Version_Data_3__c) ? distributionVersion.Version_Data_3__c : '') + (String.isNotEmpty(distributionVersion.Version_Data_4__c) ? distributionVersion.Version_Data_4__c : '') + (String.isNotEmpty(distributionVersion.Version_Data_5__c) ? distributionVersion.Version_Data_5__c : '') + (String.isNotEmpty(distributionVersion.Version_Data_6__c) ? distributionVersion.Version_Data_6__c : '');
        System.debug('allVersionData-----'+allVersionData);
        List<Order_Product__c> orderItemRec = (List<Order_Product__c>)JSON.deserialize(allVersionData, List<Order_Product__c>.class);
        System.debug('allVersionData-----'+allVersionData);
        returnMap.put('orderItems', orderItemRec);
        returnMap.put('distributionVersion', distributionVersion);
        return returnMap;
    }
}