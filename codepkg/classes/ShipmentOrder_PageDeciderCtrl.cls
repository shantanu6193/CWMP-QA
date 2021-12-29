/***********************************************************************************************************************************
* Class Name   : ShipmentOrder_PageDeciderCtrl
* Description  : This class for shipment order page decider
* Author       : Pankaj
* Created On   : 08/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                08/12/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class ShipmentOrder_PageDeciderCtrl {
    
    /***********************************************
    * Method Name : getInitData
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return map of OrderNumber and Bulk_Procurement_RecordTypeId
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getInitData(String orderId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Order__c> orderRec = [Select Id,Name from Order__c where ID =: orderId];
        returnMap.put('OrderNumber', orderRec[0].Name);
        returnMap.put('Bulk_Procurement_RecordTypeId', Schema.SObjectType.Shipment_Order__c.getRecordTypeInfosByDeveloperName()
                .get('Bulk_Procurement').getRecordTypeId());

        return returnMap;
    }
}