/***********************************************************************************************************************************
* Class Name   : BPP_ShipmentProductsEditCtrl
* Description  : This Class for BPP Shipment Products 
* Author       : Pankaj
* Created On   : 09/14/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            09/14/2020       Initial Implementation
**************************************************************************************************************************************/

public class BPP_ShipmentProductsEditCtrl {

    /***********************************************
    * Method Name : getOrderItemAndShipmentProducts
    * Author : Pankaj
    * Inputs : String shipmentId
    * Description: This Method return the ShipmentProducts
    *********************************************/ 
    @AuraEnabled
    public static ShipmentProducts getOrderItemAndShipmentProducts(String shipmentId){
        Shipment_Order__c shipmentOrder = [SELECT Order_Custom__c, Warehouse__r.Name, Order_Custom__r.RecordType.Name FROM Shipment_Order__c WHERE Id=:shipmentId];
        //String orderId = [SELECT Order_Custom__c FROM Shipment_Order__c WHERE Id=:shipmentId].Order_Custom__c ;
        String orderId = shipmentOrder.Order_Custom__c;
        String warehouse = shipmentOrder.Warehouse__c;
        ShipmentProducts shipmentProds = new ShipmentProducts();
        if(orderId !=null){

            /*shipmentProds.orderItemList = [SELECT Id, Product_Name__c,Description__c,Quantity__c
                                        FROM Order_Product__c
                                        WHERE Order__c=:orderId
                                        ORDER BY Product_Name__c];*/
            List<Warehouse_Config__mdt> wareHouseAccount = [Select Id,Account_Id__c,isActive__c,MasterLabel from Warehouse_Config__mdt
            where Account_Id__c =: warehouse LIMIT  1];
            if(!wareHouseAccount.isEmpty())
                warehouse = wareHouseAccount[0].MasterLabel;
            String queryString = 'Select Id, Product_Name__c,Description__c,Quantity__c,Quantity_Filled__c FROM Order_Product__c WHERE Order__c =:orderId';
            if(shipmentOrder.Order_Custom__r.RecordType.Name == 'PHOS' && String.isNotBlank(warehouse)) {
                queryString = queryString + ' AND Fulfilment_Entity_Warehouse__c =: warehouse';
            }
            queryString = queryString + ' ORDER BY Product_Name__c';
            shipmentProds.orderItemList = Database.query(queryString);
            shipmentProds.shipmentLineItems = [SELECT Id, Order_Product_Shipped__c, Shipment__c, Quantity__c,Product_Received_BOL_Total_Quantity__c,Product_Description__c,Quantity_Requested__c
            FROM Shipment_Order_Line_Item__c
            WHERE Shipment__c=:shipmentId];

        }
        return shipmentProds ;
    }

    /***********************************************
    * Method Name : saveShipmentLineItems
    * Author : Pankaj
    * Inputs : string shipmentLineItemsStr, String shipmentId
    * Description: This Method save\update the Shipment Line Items
    *********************************************/ 
    @AuraEnabled
    public static string saveShipmentLineItems(string shipmentLineItemsStr, String shipmentId){
        try{
            List<Shipment_Order_Line_Item__c> shipmentLineItems = (List<Shipment_Order_Line_Item__c>)JSON.deserialize(shipmentLineItemsStr, List<Shipment_Order_Line_Item__c>.class);
            Set<Id> existingShipmentItems = new set<Id>();
            for(Shipment_Order_Line_Item__c shipmentLine :shipmentLineItems){
                if(shipmentLine.Shipment__c == null) {
                    shipmentLine.Shipment__c = shipmentId;
                }

                if(shipmentLine.Id !=null){
                    existingShipmentItems.add(shipmentLine.Id);
                }

            }
            Delete [Select Id From Shipment_Order_Line_Item__c Where Shipment__c=: shipmentId AND ID Not IN:existingShipmentItems];
            upsert shipmentLineItems;
            return 'Success';
        }catch(Exception Ex){
            return Ex.getMessage();
        }
    }

    /***********************************************************************************************************************************
    * Class Name   : ShipmentProducts
    * Description  : This is inner class for ShipmentProducts 
    * Author       : Pankaj
    * Created On   : 09/14/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj            09/14/2020       Initial Implementation
    **************************************************************************************************************************************/

    public class ShipmentProducts {
        @AuraEnabled
        public List<Order_Product__c> orderItemList = New List<Order_Product__c>();

        @AuraEnabled
        public List<Shipment_Order_Line_Item__c> shipmentLineItems = New List<Shipment_Order_Line_Item__c>();
    }

}