/***********************************************************************************************************************************
* Class Name   : OrderProductTriggerHelper
* Description  : This is helper class for order product trigger
* Author       : Pankaj
* Created On   : 06/21/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                06/21/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class OrderProductTriggerHelper extends TriggerHelper{
    public static Boolean skipOrderProductTrigger = false;
    public static Boolean skipOrderFullFilledValidation = false;
    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void processBeforeInsert()  {
        updateOrderProductPrice();
        updateWarehouseAndOrderProductQuantity();
    }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void processBeforeUpdate()  {
        updateOrderProductPrice();
       
    }
    
    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are inserted
    *********************************************/
    public override void processAfterInsert()  {

        rollUpAmountToOpportunity();
        updateOrder();
        populateProductFields();
        //updateOrderProductPrice();
      
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated
    *********************************************/
    public override void processAfterUpdate() {

        rollUpAmountToOpportunity();
        updateOrder();
        //updateOrderProductPrice();
        orderProductValidation();
       
    }

    /***********************************************
    * Method Name : processAfterDelete
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are deleted
    *********************************************/
    public override void processAfterDelete() {

        rollUpAmountToOpportunity();
       
    }

    /***********************************************
    * Method Name : processAfterUndelete
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are undeleted
    *********************************************/
    public override void processAfterUndelete() {

        rollUpAmountToOpportunity();
    
    }

    /***********************************************
    * Method Name : rollUpAmountToOpportunity
    * Author : Pankaj
    * Inputs : -
    * Description: This method rollup amount on opportunity when the products are inserted\updated\deleted\undeleted
    *********************************************/
    private void rollUpAmountToOpportunity()
    {
        System.debug('***********inside - OrderItemTrigger - rollUpAmountToOpportunity*************');

        // List of Order Items  that are being inserted, updated , deOrderItemleted or undeleted
        List<Order_Product__c> OrderItemList = new List<Order_Product__c>();
        OrderItemList = Trigger.Isinsert || Trigger.isUndelete ? Trigger.New : Trigger.old;
        System.debug('***********OrderItemList*************'+ OrderItemList);

        Map<Id, Opportunity> opportunityToUpdateMap = new Map<Id, Opportunity>();
        Set <Id> updatedOrderRecordsIds = new Set<Id>();

        for(Order_Product__c orderItem : OrderItemList){
            updatedOrderRecordsIds.add(orderItem.Order__c);
        }

        List<Order__c> updatedOrderRecordsList = new List<Order__c>();

        if(updatedOrderRecordsIds.size() > 0 ){
            updatedOrderRecordsList = [Select Id, Opportunity__c  From Order__c Where Id IN :updatedOrderRecordsIds];
        }

        for(Order__c order:updatedOrderRecordsList){
            if(order.Opportunity__c != null){
                opportunityToUpdateMap.put(order.Opportunity__c,new Opportunity(Id = order.Opportunity__c , Amount=0));
            }
        }
        System.debug('***********opportunityToUpdateMap*************'+ opportunityToUpdateMap);

        List<AggregateResult> aggResult = new List<AggregateResult>();
        aggResult = [Select sum(OrderAmount__c) , Opportunity__c From Order__c Where Opportunity__c IN : opportunityToUpdateMap.keySet() Group By Opportunity__c];

        System.debug('***********aggResult*************'+ aggResult);

        FOR(AggregateResult ar : aggResult){
            Id oppId = (ID)ar.get('Opportunity__c');
            if(opportunityToUpdateMap.containsKey(oppId)){
                Opportunity opp = opportunityToUpdateMap.get(oppId);
                Decimal sumAtt = (Decimal)ar.get('expr0');
                opp.Amount = sumAtt;
                opportunityToUpdateMap.put(oppId, opp);
            }
        }
        System.debug('***********opportunityToUpdateMapValues(After Processing)*************'+ opportunityToUpdateMap.values());

        update opportunityToUpdateMap.values();
    }

    /***********************************************
    * Method Name : updateOrder
    * Author : Pankaj
    * Inputs : -
    * Description: This method update the order products
    *********************************************/
    public static void updateOrder(){
        List<Order__c> updateOrderList = new List<Order__c>();
        for(Order_Product__c orderItem : (List<Order_Product__c>)Trigger.New){
            Order__c orderRecord = new Order__c(Id = orderItem.Order__c );
            if(!updateOrderList.contains(orderRecord)){
                updateOrderList.add(orderRecord);
            }
        }
        TriggerHelper.skipTrigger = true;
        if(!updateOrderList.isEmpty()){
            update updateOrderList;
        }
        TriggerHelper.skipTrigger = false;
    }

    /***********************************************
    * Method Name : updateOrderProductPrice
    * Author : Pankaj
    * Inputs : -
    * Description: This method update the order product price
    *********************************************/
    public static void updateOrderProductPrice(){
        List<Order_Product__c> orderProductList = new List<Order_Product__c>();
        orderProductList = Trigger.New;
        System.debug('In Trigger------'+orderProductList);
        for (Order_Product__c orderProduct : orderProductList) {
            System.debug('orderProduct.Quantity__c-----' + orderProduct.Quantity__c);
            System.debug('orderProduct.Unit_Price__c-----' + orderProduct.Unit_Price__c);
            if (orderProduct.Unit_Price__c != null) {
                orderProduct.Total_Price__c = orderProduct.Quantity__c * orderProduct.Unit_Price__c;
                orderProduct.Product_Code__c = orderProduct.Product__r.ProductCode;
            }
        }
    }

    /***********************************************
    * Method Name : updateWarehouseAndOrderProductQuantity
    * Author : Pankaj
    * Inputs : -
    * Description: This method populate Warehouse and Quantity filled for order source is Dynamic
    *********************************************/
    public static void updateWarehouseAndOrderProductQuantity() {
        List<Id> orderIds = new List<Id>();
        for(Order_Product__c orderProduct : (List<Order_Product__c>)Trigger.new) {
            orderIds.add(orderProduct.Order__c);
        }
        Map<Id,Order__c> orderList = new map<Id,Order__c>([SELECT Id, Status__c,Order_Source__c FROM Order__c WHERE Id IN :orderIds]);
        for (Order_Product__c orderProduct :(List<Order_Product__c>)Trigger.new) {
			Order__c orderRecord = orderList.get(orderProduct.Order__c);
            if(orderRecord != null) {
                if(orderRecord.Order_Source__c == PHOS_Constants.ORDER_SOURCE_DYNAMICS ) {
                    skipOrderFullFilledValidation = true;
                }
                if(orderRecord.Order_Source__c == PHOS_Constants.ORDER_SOURCE_DYNAMICS && orderRecord.Status__c == PHOS_Constants.ORDER_PRODUCT_STATUS_FULLFILLEDANDCLOSED) {
                    orderProduct.Fulfilment_Entity_Warehouse__c = PHOS_Constants.FULFILMENT_ENTITY_WAREHOUSE_COLOR;
                    orderProduct.Quantity_Filled__c = orderProduct.Quantity__c;
                }
                
            }
        }
    }

    /***********************************************
    * Method Name : populateProductFields
    * Author : Pankaj
    * Inputs : -
    * Description: This method populate order product fields from product
    *********************************************/
    public static void populateProductFields() {
        List<Order_Product__c> orderProductList = Trigger.New;
        List<Product2> prodList = new List<Product2>();
        List<Order_Product__c> orderProducts = [select Id, Product__r.Name, Product__r.Family,
                Product_Family__c,Product_Name__c from Order_Product__c where Id in : orderProductList];
        System.debug('list---------------'+orderProducts.size());
        for(Order_Product__c orderProduct : orderProducts) {
            if(orderProduct.Product_Family__c == null) {
                orderProduct.Product_Family__c = orderProduct.Product__r.Family;
            }
            if(orderProduct.Product_Name__c == null) {
                orderProduct.Product_Name__c = orderProduct.Product__r.Name;
            }

        }
        update orderProducts;
    }
    /***********************************************
   * Method Name : orderProductValidation
   * Author : Pankaj
   * Inputs : -
   * Description: This method for validation based on Order Status Fulfilled - Closed
   *********************************************/
    public static void orderProductValidation() {
        List<Id> orderIds = new List<Id>();
        for(Order_Product__c orderProduct : (List<Order_Product__c>)Trigger.new) {
            orderIds.add(orderProduct.Order__c);
        }
        if(skipOrderProductTrigger == false) {
            Set<Id> idsForError = new Set<Id>();
            for(Order_Product__c orderProduct : [SELECT Id, Order__r.Status__c FROM Order_Product__c WHERE Order__c IN : orderIds]) {

                if(orderProduct.Order__r.Status__c == 'Fulfilled - Closed') {
                    idsForError.add(orderProduct.Id);
                }
            }
            for(Order_Product__c orderProduct : (List<Order_Product__c>)Trigger.new) {
                if(skipOrderFullFilledValidation == false && idsForError.contains(orderProduct.Id)) {
                    orderProduct.addError('You cannot edit the Fulfilled - Closed Order\'s Products');
                }
            }
        }
    }
}