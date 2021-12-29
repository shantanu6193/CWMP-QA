/**
 * Created by Pankaj on 21-04-2020.
 */

({

    updateAvailableProductList : function(component, event, helper) {
        console.log('Testing');
        let availableProducts = [];
        let originalProducts = component.get("v.orderItemList");
        let selectedShipLineItems = component.get("v.selectedShipmentItems");
        let currentShipmentLine = component.get("v.shipmentItem");

        for(var i=0; i<originalProducts.length; i++) {
            let addProductToList = true;
            for(var j=0; j<selectedShipLineItems.length; j++) {
                if(currentShipmentLine.Order_Product_Shipped__c == originalProducts[i].Id) {
                    break;
                }
                if(selectedShipLineItems[j].Order_Product_Shipped__c == originalProducts[i].Id) {
                    addProductToList  = false;
                    break;
                }
            }
            if(addProductToList) {
                availableProducts.push(originalProducts[i]);
            }
        }
        component.set("v.orderItemListToShow", availableProducts);
    },
    
    refreshOrderProducts : function(component, event, helper) {
        var component = component.getEvent("refreshOrderProductEvt");       
        component.fire();
    },

    updateDescription : function(component, event, helper) {
        let currentProductItem = component.get('v.shipmentItem.Order_Product_Shipped__c');
        //console.log('----11',currentProductItem);
        let orderItemList = component.get('v.orderItemList');
        //console.log('----22',JSON.stringify(orderItemList));
        component.set("v.shipmentItem.Product_Description__c", '');
        for (var i = 0; i < orderItemList.length; i++) {
            console.log('----33',orderItemList[i].Id);
            if(orderItemList[i].Id == currentProductItem){
                component.set("v.shipmentItem.Product_Description__c",orderItemList[i].Description__c);
                component.set("v.shipmentItem.Quantity_Requested__c",orderItemList[i].Quantity__c);
                component.set("v.shipmentItem.Quantity__c",orderItemList[i].Quantity_Filled__c);
            }
        }
    }

});