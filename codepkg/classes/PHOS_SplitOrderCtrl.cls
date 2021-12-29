/***********************************************************************************************************************************
* Class Name   : PHOS_SplitOrderCtrl
* Description  : This class for PHOS split order
* Author       : Pankaj
* Created On   : 04/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/09/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_SplitOrderCtrl {

    /***********************************************
    * Method Name : getOrderDetails
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return map of order and order products records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrderDetails(String orderId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Order__c orderRec = [
                SELECT
                        Account_Name_Text__c,
                        Account__c,
                        Actions_Taken_On_This_Request__c,
                        Actual_Payment_Amount__c,
                        Actual_Payment_Date__c,
                        Analyst__c,
                        Approved_by_CPO__c ,
                        ASN_Delivery_Quantity__c,
                        Check_or_Wire_X_Number__c,
                        County__c,
                        CreatedById,
                        CreatedDate,
                        Delivery_Notes__c,
                        Delivery_Recipient_Email_Text__c,
                        Delivery_Recipient_First_Name_Text__c,
                        Delivery_Recipient_Last_Name_Text__c,
                        Delivery_Recipient_Phone_Text__c,
                        Delivery_Recipient_Title_Text__c,
                        Delivery_Recipient__c,
                        Delivery_Schedule_Delivery_Date__c,
                        Description__c,
                        Does_Not_Have_Resources__c,
                        Donation__c,
                        EffectiveDate__c,EndDate__c,
                        Estimated_Donation_Order_Value__c,
                        Expected_Payment_Amount__c,
                        Expected_Payment_Date__c,
                        FISCAL_PO__c,
                        Id,
                        Incident_Name__c,
                        Industry__c,
                        IsDeleted,
                        LastActivityDate,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Mission_ID__c,Mission_Request_Number_If_Applicable__c,Mission__c,Multiple_Shipments__c,Name,
                        Opportunity__c,OrderAmount__c,Order_Completed_Date__c,Order_Create_Date_Time__c,
                        Other_Request_Number_If_Applicable__c,
                        OwnerId,Payment_Method_Other__c,Payment_Method__c,Payment_Terms_Other__c,Payment_Terms__c,Payment_Tracking_Number__c,
                        Personnel__c,PHM_EOM_Confirmed__c,Planned_GI__c,Priority_for_Requests__c,Product_Received_Final_Purchase_Order__c,
                        Purchase_Order_Amendment__c,Purchase_Order_Number__c,Quality_Release__c,RDMHS_Program_Confirmed__c,
                        RecordTypeId,Region__c,Requestor_Agency_Text__c,Requestor_Agency__c,Requestor_Email_Text__c,
                        Requestor_First_Name_Text__c,Requestor_Last_Name_Text__c,Requestor_Phone_Text__c,Requestor_Title_Text__c,
                        Requestor__c,Resource_Request_Number__c,Shipping_City__c,Shipping_Country__c,Shipping_State__c,
                        Shipping_Street_2__c,Shipping_Street__c,Shipping_ZipPostal_Code__c,Status__c,Sub_Industry__c,SuppliesEquipment__c,
                        SystemModstamp,Task__c,Total_ASN_Units__c,Type_Of_Resource_Other__c
                FROM Order__c WHERE Id=:orderId];

        List<Order_Product__c> orderItems = [
                SELECT
                        Carrier_Tracking__c,Cost__c,CreatedById,CreatedDate,Date_Ordered__c,Delivered_On_Date__c,
                        Description__c,Equivalent_Substitutes_Acceptable__c,Equivalent_Substitutes__c,
                        Estimated_Donation_Value__c,Estimated_time_of_Arrival__c,Fulfilment_Entity_Warehouse__c,
                        Id,IsDeleted,Is_Donation__c,Item_Code__c,LastActivityDate,LastModifiedById,LastModifiedDate,Mission__c,
                        Name,Order__c,Priority__c,ProductCode__c,Product_Code__c,
                        Product_Description_Other__c,Product_Family__c,Product_Name__c,Product_Ordered_Part_or_Model_Number__c,
                        Product_Ordered_Size__c,Product_Ordered_Total_Cost__c,Product_Ordered_Total_Quantity__c,
                        Product_Ordered_Unit_Cost__c,Product_Received_Part_or_Model_Number__c,Product_Received_Size__c,
                        Product_Received_Total_Cost__c,Product_Received_Total_Quantity__c,Product_Received_Unit_Cost__c,
                        Product_Received_UOM_Other__c,Product_Received_UOM__c,Product__c,Product__r.Family,
                        Product__r.Name,Quantity_Approved__c,
                        Quantity_Back_Ordered__c,Quantity_Filled__c,Quantity__c,SystemModstamp,Total_Amount__c,Total_Price__c,
                        Tracking__c,Unit_Price__c,UOM_Other__c,UOM__c,Warehouse_Info__c
                FROM Order_Product__c WHERE Order__c =:orderId AND Status__c !=: PHOS_Constants.ORDER_PRODUCT_STATUS_SENT];

        returnMap.put('orderRec', orderRec);
        returnMap.put('orderItems', orderItems);
        return returnMap;

    }

    /***********************************************
    * Method Name : getProducts
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of all active products
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getProducts(){
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Product2> product2s = [Select Id, Name, ProductCode, Family from Product2 where IsActive = true ORDER BY Name];
        List<Product2> product2sList = new List<Product2>();
        List<Product2> product2sOtherList = new List<Product2>();


        for(Product2 product2 : product2s){
            if(product2.Name != 'Other'){
                product2sList.add(product2);
            }else if(product2.Name == 'Other'){
                product2sOtherList.add(product2);
            }
        }
        product2sList.addAll(product2sOtherList);
        returnMap.put('Products', product2sList);
        return returnMap;
    }

    /***********************************************
    * Method Name : processSplitOrder
    * Author : Pankaj
    * Inputs : Map<String, Object> paramMap
    * Description: This method split order, create shipments and return map of message
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> processSplitOrder(Map<String, Object> paramMap){
        Map<String, Object> returnMap = new Map<String, Object>();
        String fulfilment = String.valueOf(paramMap.get('fulfilment'));
        system.debug('fulfilment---'+fulfilment);
        List<Warehouse_Config__mdt> fulfilmentName = [Select Id,Account_Id__c,isActive__c,Send_Email__c,DeveloperName,MasterLabel,Create_Shipment_Order__c
                                                        from Warehouse_Config__mdt where MasterLabel =: fulfilment LIMIT  1];
        if(fulfilmentName.isEmpty() || !fulfilmentName[0].isActive__c) {
            throw new AuraHandledException('Warehouse not found or is inactive');
        }


        Order__c orderRec = (Order__c) JSON.deserialize(String.valueOf(paramMap.get('Order')), Order__c.class);
        System.debug('orderRec-------'+orderRec);
        List<Order_Product__c> orderItems = (List<Order_Product__c>) JSON.deserialize(String.valueOf(paramMap.get('OrderItems')), List<Order_Product__c>.class);
        String orderId = orderRec.Id; //String.valueOf(paramMap.get('orderId'));

        //Calling  create shipment method to create shipment order and shipment order lineitem
        if(fulfilmentName[0].Create_Shipment_Order__c) {
            try {
                createShipment(orderId,fulfilment,orderItems);
            } catch(Exception ex) {
                throw new CustomException('Error: ' + ex.getMessage());
            }
        }

        if(fulfilmentName[0].Send_Email__c) {
            try {
                sendEmail(fulfilmentName,orderId,orderItems);
            } catch(Exception ex) {
                throw new AuraHandledException('Error while sending email: ' + ex.getMessage());
            }
            returnMap.put('message', System.Label.SplitOrderEmailMessage);
            return returnMap;
        }else if(fulfilmentName[0].Create_Shipment_Order__c) {
            returnMap.put('message', System.Label.SplitOrderWarehouseMessage);
            return returnMap;
        } else {
            throw new AuraHandledException('Error while creating Shipment Order');
        }

    }

    /***********************************************
    * Method Name : createShipment
    * Author : Pankaj
    * Inputs : String orderId,String fulfilment,List<Order_Product__c> filteredOrderItems
    * Description: This method create shipment and shipment line Items
    *********************************************/
    private static void createShipment(String orderId,String fulfilment,List<Order_Product__c> filteredOrderItems) {
        Map<String,String> warehouseMap = new  Map<String,String>();
        List<Id> accountIds = new List<Id>();
        List<Warehouse_Config__mdt> wareHouseAccountConfig = [SELECT Id,Account_Id__c,isActive__c,Send_Email__c,Creation_Status__c,MasterLabel,Check_For_Warehouse_Validations__c
                                                                FROM Warehouse_Config__mdt WHERE MasterLabel =: fulfilment LIMIT 1];
        for(Warehouse_Config__mdt tempWarehouse : wareHouseAccountConfig) {
            accountIds.add(tempWarehouse.Account_Id__c);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Entity_Id__c FROM Account WHERE Id IN :accountIds]);
        for(Warehouse_Config__mdt tempWarehouse : wareHouseAccountConfig) {
            if(accountMap.get(tempWarehouse.Account_Id__c) == null) throw new CustomException('Warehouse account not found. '
                    + tempWarehouse.MasterLabel);
            warehouseMap.put(tempWarehouse.MasterLabel, accountMap.get(tempWarehouse.Account_Id__c).Entity_Id__c);
        }
        Order__c orderRec =[Select Id,Order__c,Account__c,Shipping_State__c,Delivery_Schedule_Delivery_Date__c from Order__c where Id=:orderId];

        Shipment_Order__c shipOrderRec= new Shipment_Order__c();
        shipOrderRec.Name='Shipment Name';
        shipOrderRec.Order_Custom__c=orderRec.Id;

        // if order send to West Sac Pharma then status is send to Warehouse otherwise Ready
        if(wareHouseAccountConfig[0].Creation_Status__c != null){
            shipOrderRec.Status__c = wareHouseAccountConfig[0].Creation_Status__c;
        }else{
            shipOrderRec.Status__c = PHOS_Constants.SHIPMENT_ORDER_STATUS_READY;
        }

        /*if(orderRec.Order__c!=null)
            shipOrderRec.Order__c=orderRec.Order__c;*/
        if(orderRec.Delivery_Schedule_Delivery_Date__c!=null)
            shipOrderRec.Delivery_Schedule_Delivery_Date__c=orderRec.Delivery_Schedule_Delivery_Date__c;
        if(wareHouseAccountConfig[0].Account_Id__c!=null)
            shipOrderRec.Warehouse__c = wareHouseAccountConfig[0].Account_Id__c;

        Id phosShipOrderRecordTypeId = Schema.SObjectType.Shipment_Order__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
        shipOrderRec.RecordTypeId = phosShipOrderRecordTypeId;
        insert shipOrderRec;

        // Check Inventory for the Warehouse
        Map<String, Inventory__c> mapProductToRemaining;
        if(wareHouseAccountConfig[0].Check_For_Warehouse_Validations__c == true) {
            mapProductToRemaining = checkWarehouseInventory(orderId, wareHouseAccountConfig, filteredOrderItems);
        }
        Map<Id,Inventory__c> updateInventoryQty = new Map<Id,Inventory__c>(); 
        List<String> orderProductsList = new List<String>();
        List<Inventory__c> inventoriesUpdateList = new List<Inventory__c>();
        List<Shipment_Order_Line_Item__c> lstShipmln = new List<Shipment_Order_Line_Item__c>();
        for(Order_Product__c orderProRec:[Select Id,Quantity__c,Product_Name__c,Product__c,Order__c,Case_Count__c,Original_Order_Product__c,Quantity_Filled__c,Warehouse_Info__c,Fulfilment_Entity_Warehouse__c, Product__r.Skip_PHOS_Warehouse_Validation__c
        from Order_Product__c where Order__c=: orderId and Id IN: filteredOrderItems]){
            if(orderProRec.Quantity_Filled__c == null) throw new CustomException('Filled Quantity is missing of product ' +orderProRec.Product_Name__c);
            if(wareHouseAccountConfig[0].Check_For_Warehouse_Validations__c == true && orderProRec.Product__r.Skip_PHOS_Warehouse_Validation__c == false && mapProductToRemaining != null  &&
                    orderProRec.Quantity_Filled__c > mapProductToRemaining.get(warehouseMap.get(orderProRec.Fulfilment_Entity_Warehouse__c) + orderProRec.Warehouse_Info__c).Remaining_Inventory__c) {
                orderProductsList.add(orderProRec.Product_Name__c);
            } else {
                Shipment_Order_Line_Item__c shipmlnRec = new Shipment_Order_Line_Item__c ();
                shipmlnRec.Order_Product_Shipped__c = orderProRec.Id;
                /* if(orderProRec.Original_Order_Product__c!=null)
                     shipmlnRec.Product_Shipped__c=orderProRec.Original_Order_Product__c;*/
                shipmlnRec.Quantity__c = orderProRec.Quantity_Filled__c;
                shipmlnRec.Case_Count__c = orderProRec.Case_Count__c;
                shipmlnRec.Shipment__c = shipOrderRec.Id;
                shipmlnRec.Status__c = PHOS_Constants.SHIPMENT_LINE_ORDER_STATUS_READY;
                lstShipmln.add(shipmlnRec);
                if(mapProductToRemaining != null && orderProRec.Product__r.Skip_PHOS_Warehouse_Validation__c == false) {
                    Inventory__c inventoryRecord = mapProductToRemaining.get(warehouseMap.get(orderProRec.Fulfilment_Entity_Warehouse__c) + orderProRec.Warehouse_Info__c);
                    inventoryRecord.Remaining_Inventory__c = inventoryRecord.Remaining_Inventory__c - orderProRec.Quantity_Filled__c;
                    inventoriesUpdateList.add(inventoryRecord);
                }
            }
        }
        if(orderProductsList != null && !orderProductsList.isEmpty()) {
            throw new CustomException('Inventory is not available for ' + orderProductsList);
        } else {
            insert lstShipmln;
            if(inventoriesUpdateList != null && !inventoriesUpdateList.isEmpty()) {
                for(Inventory__c inventory : inventoriesUpdateList){
                    updateInventoryQty.put(inventory.Id,inventory);
                }
                if(updateInventoryQty.size() > 0){
                    update updateInventoryQty.values();
                }
               // update inventoriesUpdateList;
            }
        }
    }

    /***********************************************************************************************************************************
    * Class Name   : CustomException
    * Description  : This class for throwing custom exception
    * Author       : Pankaj
    * Created On   : 04/09/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj              04/09/2020      Initial Implementation
    **************************************************************************************************************************************/

    public class CustomException extends Exception{}

    /***********************************************
    * Method Name : checkWarehouseInventory
    * Author : Pankaj
    * Inputs : String orderId, List<Warehouse_Config__mdt> wareHouseAccountConfig, List<Order_Product__c> filteredOrderItems
    * Description: This method check Inventory for the Warehouse 
    *********************************************/
    private static Map<String, Inventory__c> checkWarehouseInventory(String orderId, List<Warehouse_Config__mdt> wareHouseAccountConfig, List<Order_Product__c> filteredOrderItems) {
        Set<String> skuIDs = new Set<String>();
        for(Order_Product__c orderProduct : [SELECT Id, Warehouse_Info__c FROM Order_Product__c WHERE Order__c=: orderId AND Id IN: filteredOrderItems]) {
            skuIDs.add(orderProduct.Warehouse_Info__c);
        }

        List<Inventory__c> inventoryList = [SELECT Id,Name,SKU_Id__c,Warehouse_Code__c,Remaining_Inventory__c,Warehouse_Product__r.Product__c,Warehouse_Product__r.Warehouse__c FROM Inventory__c
        WHERE Warehouse_Product__r.Warehouse__c =: wareHouseAccountConfig[0].Account_Id__c AND SKU_Id__c IN: skuIDs];
        System.debug('inventoryList-------'+inventoryList);
        Map<String,Decimal> invToOrderProdMap = new Map<String, Decimal>();
        for(Inventory__c inv : inventoryList) {
            if(inv.SKU_Id__c != null) {
            invToOrderProdMap.put(inv.SKU_Id__c,inv.Remaining_Inventory__c);
        }
        }
        List<Order_Product__c> orderProductToUpdate = new List<Order_Product__c>();
        for(Order_Product__c orderProduct : [SELECT Id, Warehouse_Info__c,Inventory_Available_Quantity__c FROM Order_Product__c WHERE Order__c=: orderId AND Id IN: filteredOrderItems]) {
            if(orderProduct.Warehouse_Info__c != null && invToOrderProdMap.containsKey(orderProduct.Warehouse_Info__c)) {
                orderProduct.Inventory_Available_Quantity__c = invToOrderProdMap.get(orderProduct.Warehouse_Info__c);
                orderProductToUpdate.add(orderProduct);
            }
        }
        System.debug('orderProductToUpdate----'+orderProductToUpdate);
        update orderProductToUpdate;
        Map<String, Inventory__c> mapProductToRemaining = new Map<String, Inventory__c>();
        for(Inventory__c inv : inventoryList) {
            mapProductToRemaining.put(inv.Warehouse_Code__c + inv.SKU_Id__c, inv);
        }
        return mapProductToRemaining;
    }

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Warehouse_Config__mdt> fulfilmentName, String orderId, List<Order_Product__c> orderItems
    * Description: This method send an email of order details
    *********************************************/
    private static void sendEmail(List<Warehouse_Config__mdt> fulfilmentName, String orderId, List<Order_Product__c> orderItems) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();


        List<Warehouse_Config__mdt> toAddressList = [Select Id,To_Addresses__c,CC_Addresses__c from Warehouse_Config__mdt where MasterLabel =:fulfilmentName[0].MasterLabel LIMIT 1];

        List<String> sendTo = new List<String>();
        Set<String> sendCC = new Set<String>();
        sendCC.add(UserInfo.getUserEmail());
        for (Warehouse_Config__mdt toAddress : toAddressList) {
            if (String.isNotBlank(toAddress.To_Addresses__c)) {
                sendTo.addAll(AppUtils.fetchAllEmailAddresses(toAddress.To_Addresses__c));
            }
            if (String.isNotBlank(toAddress.CC_Addresses__c)) {
                sendCC.addAll(AppUtils.fetchAllEmailAddresses(toAddress.CC_Addresses__c));
            }
        }

        List<Key_Value_Store__mdt> fromAddressList=[Select Id,Text_Value__c from Key_Value_Store__mdt where DeveloperName='PHOS_From_Email_Addresses' LIMIT 1];
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(fromAddressList.size()>0){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=:fromAddressList[0].Text_Value__c];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }

        System.debug('**************OrgWideEmailAddressId*************  '+OrgWideEmailAddressId);
        System.debug('**************listofOrderIds*************  '+orderId);

        String tableRows = '';
        String style = 'border: 1px solid black;border-collapse: collapse;text-align:center;padding: 4px 0px;';
        for(Order_Product__c ot: orderItems){
            String description = ot.Description__c !=null ? ot.Description__c : '';
            Double quantityFilled = ot.Quantity_Filled__c !=null ? ot.Quantity_Filled__c : 0;
            String tableRow = '<tr>';
            tableRow += '<td style="'+style+'">'+ ot.Product__r.Family +'</td>';
            tableRow += '<td style="'+style+'">'+ ot.Product__r.Name +'</td>';
            tableRow += '<td style="'+style+'">'+ ot.Quantity__c +'</td>';
            tableRow += '<td style="'+style+'">'+ quantityFilled +'</td>';
            tableRow += '<td style="'+style+'">'+ (ot.Warehouse_Info__c != null ? ot.Warehouse_Info__c : '') +'</td>';
            tableRow += '<td style="'+style+'">'+ description  +'</td>';
            tableRow += '<td style="'+style+'">'+ ot.Equivalent_Substitutes__c +'</td>';
            tableRow += '<td style="'+style+'">'+ ot.Fulfilment_Entity_Warehouse__c +'</td>';
            tableRow += '<td style="'+style+'">'+ (ot.Mission__c != null ? ot.Mission__c : '') +'</td>';
            tableRow += '</tr>';

            tableRows += tableRow;
        }

        system.debug('---tableRows---'+tableRows);

        //List<String> county = orderRec.County__c.split('-');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);
        List<String> ccEmalils = new List<String>();
        ccEmalils.addAll(sendCC);
        mail.setCcAddresses(ccEmalils);
        mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);

        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'PHOS_Splite_Order'];
        system.debug('et..' + et);
        Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null, (String.isNotEmpty(orderId) ? orderId : null));

        singleEmail.htmlBody = singleEmail.htmlBody.replace('tableRow', tableRows);

        mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
        mail.subject = singleEmail.subject;
        mail.setWhatId(orderId);
        mail.setSaveAsActivity(true);
        mails.add(mail);
        System.debug('**************mail*************  '+mail);

        Messaging.sendEmail(mails);
    }

    /***********************************************
    * Method Name : getEmailAddresses
    * Author : Pankaj
    * Inputs : Map<String, Object> paramMap
    * Description: This method return map of email addresses 
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getEmailAddresses(Map<String, Object> paramMap){
        Map<String, Object> returnMap = new Map<String, Object>();
        String fulfilment = String.valueOf(paramMap.get('fulfilment'));

        if(String.isNotBlank(fulfilment)) {
            List<String> sendTo = new List<String>();
            Set<String> sendCC = new Set<String>();
            sendCC.add(UserInfo.getUserEmail());
            List<Warehouse_Config__mdt> warehouseConfigs = [Select Id,To_Addresses__c,Send_Email__c,CC_Addresses__c
            from Warehouse_Config__mdt
            where MasterLabel =: fulfilment LIMIT 1];

            if(warehouseConfigs.isEmpty()) return returnMap;
            for (Warehouse_Config__mdt toAddress : warehouseConfigs) {
                if (String.isNotBlank(toAddress.To_Addresses__c)) {
                    sendTo.addAll(AppUtils.fetchAllEmailAddresses(toAddress.To_Addresses__c));
                }
                if (String.isNotBlank(toAddress.CC_Addresses__c)) {
                    sendCC.addAll(AppUtils.fetchAllEmailAddresses(toAddress.CC_Addresses__c));
                }
            }

            List<String> sendCCList = new List<String>();
            sendCCList.addAll(sendCC);

            returnMap.put('sendEmail', warehouseConfigs[0].Send_Email__c);
            returnMap.put('sendTo', sendTo);
            returnMap.put('ccAddress',sendCCList);
        }
        return returnMap;
    }

    /***********************************************
    * Method Name : formatPlainBody
    * Author : Pankaj
    * Inputs : String plainBody
    * Description: This method return string with relpace \n with <br/>
    *********************************************/
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

}