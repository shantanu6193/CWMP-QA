/***********************************************************************************************************************************
* Class Name   : ShipmentOrderTriggerHelper
* Description  : This is helper class for shipment order trigger
* Author       : Pankaj
* Created On   : 08/17/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                08/17/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class ShipmentOrderTriggerHelper extends TriggerHelper {

    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are inserted
    *********************************************/
    public override void processAfterInsert() {
        updateOrderRecords();
        shrareShipmentOrder();
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated
    *********************************************/
    public override void processAfterUpdate() {
        updateOrderRecords();
        updateSOLI();
        updateOrderInvetoryRecords();
        shrareShipmentOrder();
    }

    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void processBeforeInsert()  {
        insertUpdateShipmentOrder();
    }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void processBeforeUpdate() {
        insertUpdateShipmentOrder();
     }
 
    /***********************************************
    * Method Name : updateOrderRecords
    * Author : Pankaj
    * Inputs : -
    * Description: if status changed to ready then update order record. This is required for mulesoft integration
    *********************************************/
    private void updateOrderRecords() {
        List<Order__c> lstOrderToUpdate= new  List<Order__c>();

        Map<Id, Shipment_Order__c> oldShipmentOrders = (Map<Id, Shipment_Order__c>)Trigger.oldMap;
        for(Shipment_Order__c shipRec : (List<Shipment_Order__c>)Trigger.new ) {
            if((oldShipmentOrders == null || oldShipmentOrders.get(shipRec.Id) == null) ||
                    (oldShipmentOrders.get(shipRec.Id).Status__c != shipRec.Status__c &&  shipRec.Status__c == PHOS_Constants.SHIPMENT_ORDER_STATUS_READY)) {
        	    Order__c ordRec =new Order__c(Id=shipRec.Order_Custom__c);
                lstOrderToUpdate.add(ordRec);
            }
        }
        update lstOrderToUpdate;
    }

    /***********************************************
    * Method Name : updateSOLI
    * Author : Pankaj
    * Inputs : -
    * Description: This method update status from Shipment order to shipment order line items. Shipment order line item will update order products
    *********************************************/
    private void updateSOLI() {
        List<String> shipOrderIdList = new List<String>();
        Map<Id, Shipment_Order__c> oldShipmentOrders = (Map<Id, Shipment_Order__c>)Trigger.oldMap;
        for(Shipment_Order__c shipRec : (List<Shipment_Order__c>)Trigger.new ) {
            if (oldShipmentOrders.get(shipRec.Id).Status__c != shipRec.Status__c) {
                shipOrderIdList.add(shipRec.Id);
            }
        }

        if(shipOrderIdList.isEmpty()) return;

        List<Shipment_Order_Line_Item__c> updateSOLIList= new  List<Shipment_Order_Line_Item__c>();
        List<Shipment_Order__c> listShipOrder = [Select Id, Status__c,
                                                        (Select Id, Status__c from Shipment_Order_Line_Items__r)
                                                        from Shipment_Order__c where ID IN : shipOrderIdList];
        for(Shipment_Order__c shipRec : listShipOrder) {
            for (Shipment_Order_Line_Item__c shipOrderLI : shipRec.Shipment_Order_Line_Items__r) {
                shipOrderLI.Status__c = shipRec.Status__c;
                updateSOLIList.add(shipOrderLI);
            }
        }
        update updateSOLIList;
    }

    /***********************************************
    * Method Name : insertUpdateShipmentOrder
    * Author : Pankaj
    * Inputs : -
    * Description: This method populate creator contact and Requestor Parent Agency on shipment order on  Insert and Update
    *********************************************/
    private  void insertUpdateShipmentOrder(){
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Shipment_Order__c> oldshipmentOrderMap = (Map<Id, Shipment_Order__c>)Trigger.oldMap;
        for(Shipment_Order__c newShipmentOrder :  (List<Shipment_Order__c>)Trigger.new){
            if(newShipmentOrder.Order_Custom__c != null && Trigger.isInsert){
                orderIds.add(newShipmentOrder.Order_Custom__c);
            }
            if(oldshipmentOrderMap != null && newShipmentOrder.Order_Custom__c != null && (newShipmentOrder.Order_Custom__c != oldshipmentOrderMap.get(newShipmentOrder.Id).Order_Custom__c)  && Trigger.isUpdate){
                orderIds.add(newShipmentOrder.Order_Custom__c);
            }
        }
        Map<Id,Order__c> orderMap = new Map<Id, Order__c>([SELECT Id,Creator_Contact__c,Requestor_Parent_Agency__c from Order__c WHERE Id IN:orderIds]);
          if(!orderMap.isEmpty()){
            for(Shipment_Order__c shipmentOrder :  (List<Shipment_Order__c>)Trigger.new){
                if(orderMap.get(shipmentOrder.Order_Custom__c).Requestor_Parent_Agency__c != null)
                    shipmentOrder.Requestor_Parent_Agency__c = orderMap.get(shipmentOrder.Order_Custom__c).Requestor_Parent_Agency__c;
                if(orderMap.get(shipmentOrder.Order_Custom__c).Creator_Contact__c != null)
                    shipmentOrder.Creator_Contact__c = orderMap.get(shipmentOrder.Order_Custom__c).Creator_Contact__c;
             }
          }
    }

    /***********************************************
    * Method Name : updateOrderInvetoryRecords
    * Author : Pankaj
    * Inputs : -
    * Description: This method used for update Inventory Qty record when status changed to Rejected
    *********************************************/
     private void updateOrderInvetoryRecords() {
        Set<Id> orderSet= new  Set<Id>();
        Set<Id> warehouseSet= new  Set<Id>();
        Map<Id, Shipment_Order__c> oldShipmentOrders = (Map<Id, Shipment_Order__c>)Trigger.oldMap;
        for(Shipment_Order__c shipRec : (List<Shipment_Order__c>)Trigger.new ) {
            if(shipRec.Status__c!= null && (oldShipmentOrders.get(shipRec.Id).Status__c != shipRec.Status__c) &&  
                shipRec.Status__c == PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_Rejected && shipRec.LastModifiedDate.Date() == System.today() && 
                shipRec.CreatedDate.Date() == System.today()) {
                        orderSet.add(shipRec.Id);
                        warehouseSet.add(shipRec.Warehouse__c);
            }
        }
        
        if(orderSet.size() > 0 && warehouseSet.size() > 0 ){
            Set<String> warehouseLabelSet = new  Set<String>();

            Map<String,List<Shipment_Order_Line_Item__c>> orderProductsMap = new Map<String,List<Shipment_Order_Line_Item__c>>();
            Map<Id,Inventory__c> productInventory = new Map<Id,Inventory__c>(); 
            for(Shipment_Order_Line_Item__c orderProduct : [SELECT Id,Name,Quantity__c,Order_Product_Shipped__r.Product__c,Order_Product_Shipped__r.Warehouse_Info__c
                                                            FROM Shipment_Order_Line_Item__c WHERE Shipment__c IN:orderSet]){
                    if(orderProductsMap.get(orderProduct.Order_Product_Shipped__r.Warehouse_Info__c) == null) {
                        orderProductsMap.put(orderProduct.Order_Product_Shipped__r.Warehouse_Info__c, new List<Shipment_Order_Line_Item__c>());
                    }
                    orderProductsMap.get(orderProduct.Order_Product_Shipped__r.Warehouse_Info__c).add(orderProduct);
            }    
            List<Inventory__c> updateInventoryList = new List<Inventory__c>();
            List<Inventory__c> inventoryList =[SELECT Id,Name,Remaining_Inventory__c,Warehouse_Product__r.Product__c,SKU_Id__c,
                                                Warehouse_Product__r.Warehouse__c FROM Inventory__c 
                                                WHERE Warehouse_Product__r.Warehouse__c  IN: warehouseSet 
                                                AND SKU_Id__c IN:orderProductsMap.keySet()];
            for(Inventory__c inventory :inventoryList){
                for(Shipment_Order_Line_Item__c orderProd : orderProductsMap.get(inventory.SKU_Id__c)){
                    inventory.Remaining_Inventory__c = inventory.Remaining_Inventory__c + orderProd.Quantity__c;
                    updateInventoryList.add(inventory);
                }
            }
            for(Inventory__c inventory : updateInventoryList){
                productInventory.put(inventory.Id,inventory);
            }
            if(productInventory.size() > 0){
                update productInventory.values();
            }
        }    
    }

    public static void shrareShipmentOrder(){

        Set<Id> shipmentOrderIdSet = new Set<Id>();
        if(Trigger.isUpdate) {
            for(Shipment_Order__c newOrder : (List<Shipment_Order__c>)Trigger.new){
                Shipment_Order__c oldOrder = (Shipment_Order__c)Trigger.oldMap.get(newOrder.Id);
                if(String.isNotBlank(newOrder.Creator_Contact__c)) {
                    if(oldOrder.Status__c != newOrder.Status__c  && String.isNotBlank(newOrder.Creator_Contact__c) ) {
                        shipmentOrderIdSet.add(newOrder.Id);
                    }
                }
            }
        } else if(Trigger.isInsert) {
            for(Shipment_Order__c newOrder : (List<Shipment_Order__c>)Trigger.new){
                if(String.isNotBlank(newOrder.Creator_Contact__c)) {
                    shipmentOrderIdSet.add(newOrder.Id);
                }
            }
        }
        if(shipmentOrderIdSet.size() == 0) return;

        List<Shipment_Order__c> shipmentOrderList = [SELECT Id,Creator_Contact__c,Order_Custom__c,Order_Custom__r.Account__c,Order_Custom__r.Account__r.Account_PHOS_Order_Public_Group__c,
                                                     Order_Custom__r.Account__r.ParentId,Order_Custom__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c,Order_Custom__r.Account__r.Parent.ParentId,
                                                     Order_Custom__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c FROM Shipment_Order__c 
                                                     WHERE Id IN : shipmentOrderIdSet]; 

        if(shipmentOrderList.size() == 0) return;

        Set<String> publicGroupdevloperNames = new Set<String>();

        for(Shipment_Order__c shipmentOrder : shipmentOrderList){
            //For region Account
           if(shipmentOrder.Order_Custom__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c != null) {
            publicGroupdevloperNames.add(shipmentOrder.Order_Custom__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c);
           }
           //For County Account
           if(shipmentOrder.Order_Custom__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c != null) {
               publicGroupdevloperNames.add(shipmentOrder.Order_Custom__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c);
           }
        }

       List<Group> GroupListById = [SELECT Id,Name,DeveloperName from Group where DeveloperName =: publicGroupdevloperNames and Type = 'Regular'];
        if(GroupListById.size() == 0) return;
       
        Map<String,Id> publicGroupMapById = new Map<String,Id>();

        for(Group grp : GroupListById ){

            publicGroupMapById.put(grp.DeveloperName, grp.Id);
        }

        List<Shipment_Order__Share> shipmentOrderShareList = new List<Shipment_Order__Share>();
       
            for(Shipment_Order__c newShipmentOrder : shipmentOrderList){

                if(newShipmentOrder.Creator_Contact__c == null) continue;
                if(newShipmentOrder.Order_Custom__r.Account__r.ParentId != null && newShipmentOrder.Order_Custom__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c != null) {
                    Shipment_Order__Share cs = new Shipment_Order__Share();
                    cs.ParentId = newShipmentOrder.Id;
                    cs.UserOrGroupId = publicGroupMapById.get(newShipmentOrder.Order_Custom__r.Account__r.Parent.Account_PHOS_Order_Public_Group__c);
                    cs.AccessLevel  = 'Read';
                    cs.RowCause = Schema.Shipment_Order__Share.RowCause.Manual;
                    shipmentOrderShareList.add(cs);
                } 
                //For Region Account
               if(newShipmentOrder.Order_Custom__r.Account__r.Parent.ParentId != null && newShipmentOrder.Order_Custom__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c != null) { 
                    Shipment_Order__Share cs = new Shipment_Order__Share();
                    cs.ParentId = newShipmentOrder.Id;
                    cs.UserOrGroupId = publicGroupMapById.get(newShipmentOrder.Order_Custom__r.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c);
                    cs.AccessLevel  = 'Read';
                    cs.RowCause = Schema.Shipment_Order__Share.RowCause.Manual;
                    shipmentOrderShareList.add(cs);
                } 
            }
       

        if(shipmentOrderShareList != null && !shipmentOrderShareList.isEmpty()) {
            insert shipmentOrderShareList;
        }
    }
}