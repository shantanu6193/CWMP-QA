/***********************************************************************************************************************************
* Class Name   : ShipmentTriggerHelper
* Description  : This is helper class for shipment trigger
* Author       : Pankaj
* Created On   : 08/17/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               08/17/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class ShipmentTriggerHelper extends TriggerHelper {

    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void processBeforeInsert()  {
       insertUpdateShipment();
    }

     /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void processAfterInsert()  {
        shrareShipment();
     }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void processBeforeUpdate() {
        insertUpdateShipment();
    }

    /***********************************************
    * Method Name : insertUpdateShipment
    * Author : Pankaj
    * Inputs : -
    * Description: This method populate creator contact and Requestor Parent Agency on shipment on  Insert and Update
    *********************************************/
    private  void insertUpdateShipment(){
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Shipment__c> oldShipmentMap = (Map<Id, Shipment__c>)Trigger.oldMap;
        for(Shipment__c newShipment :  (List<Shipment__c>)Trigger.new){
            if(newShipment.Order__c != null && Trigger.isInsert){
                orderIds.add(newShipment.Order__c);
            }
            if(oldShipmentMap != null && newShipment.Order__c != null && (newShipment.Order__c != oldShipmentMap.get(newShipment.Id).Order__c) && Trigger.isUpdate){
               orderIds.add(newShipment.Order__c);
            }
        }
        Map<Id,Order__c> orderMap = new Map<Id, Order__c>([SELECT Id,Creator_Contact__c,Requestor_Parent_Agency__c from Order__c WHERE Id IN:orderIds]);
          if(!orderMap.isEmpty()){
            for(Shipment__c shipment :  (List<Shipment__c>)Trigger.new){
                if(orderMap.get(shipment.Order__c).Requestor_Parent_Agency__c != null)
                    shipment.Requestor_Parent_Agency__c = orderMap.get(shipment.Order__c).Requestor_Parent_Agency__c;
                if(orderMap.get(shipment.Order__c).Creator_Contact__c != null)
                    shipment.Creator_Contact__c = orderMap.get(shipment.Order__c).Creator_Contact__c;
             }
          }
    }

    public static void shrareShipment(){

        Set<Id> shipmentIdSet = new Set<Id>();
       
        for(Shipment__c newOrder : (List<Shipment__c>)Trigger.new){
            if(String.isNotBlank(newOrder.Creator_Contact__c)) {
                shipmentIdSet.add(newOrder.Id);
            }
        }
        if(shipmentIdSet.size() == 0) return;

        List<Shipment__c> shipmentList = [SELECT Id,Creator_Contact__c,Order__c,Order__r.Account__c,Order__r.Account__r.Account_PHOS_Order_Public_Group__c,
                                                Order__r.Account__r.ParentId,Order__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c,Order__r.Account__r.Parent.ParentId,
                                                Order__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c FROM Shipment__c 
                                                 WHERE Id IN : shipmentIdSet]; 

        if(shipmentList.size() == 0) return;

        Set<String> publicGroupdevloperNames = new Set<String>();

        for(Shipment__c shipment : shipmentList){
            //For region Account
           if(shipment.Order__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c != null) {
            publicGroupdevloperNames.add(shipment.Order__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c);
           }
           //For County Account
           if(shipment.Order__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c != null) {
               publicGroupdevloperNames.add(shipment.Order__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c);
           }
        }

       List<Group> GroupListById = [SELECT Id,Name,DeveloperName from Group where DeveloperName =: publicGroupdevloperNames and Type = 'Regular'];
        if(GroupListById.size() == 0) return;
       
        Map<String,Id> publicGroupMapById = new Map<String,Id>();

        for(Group grp : GroupListById ){

            publicGroupMapById.put(grp.DeveloperName, grp.Id);
        }

        List<Shipment__Share> shipmentOrderShareList = new List<Shipment__Share>();
       
            for(Shipment__c newShipmentOrder : shipmentList){

                if(newShipmentOrder.Creator_Contact__c == null) continue;
                if(newShipmentOrder.Order__r.Account__r.ParentId != null && newShipmentOrder.Order__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c != null) {
                    Shipment__Share cs = new Shipment__Share();
                    cs.ParentId = newShipmentOrder.Id;
                    cs.UserOrGroupId = publicGroupMapById.get(newShipmentOrder.Order__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c);
                    cs.AccessLevel  = 'Read';
                    cs.RowCause = Schema.Shipment__Share.RowCause.Manual;
                    shipmentOrderShareList.add(cs);
                } 
                //For Region Account
               if(newShipmentOrder.Order__r.Account__r.Parent.ParentId != null && newShipmentOrder.Order__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c != null) { 
                    Shipment__Share cs = new Shipment__Share();
                    cs.ParentId = newShipmentOrder.Id;
                    cs.UserOrGroupId = publicGroupMapById.get(newShipmentOrder.Order__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c);
                    cs.AccessLevel  = 'Read';
                    cs.RowCause = Schema.Shipment__Share.RowCause.Manual;
                    shipmentOrderShareList.add(cs);
                } 
            }
       

        if(shipmentOrderShareList != null && !shipmentOrderShareList.isEmpty()) {
            insert shipmentOrderShareList;
        }
    }
}