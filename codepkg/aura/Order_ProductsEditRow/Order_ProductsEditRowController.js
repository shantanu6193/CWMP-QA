/**
 * Created by hp on 2020-04-06.
 */

({
    doInit: function(component, event, helper){


        let products = component.get("v.products");
        let orderItem = component.get("v.orderItem");
/*
        for(let i = 0 ; i < products.length ; i++){
            if(orderItem.Product__c != undefined && orderItem.Product__c != '' && orderItem.Product__c == products[i].Id ){
                component.set("v.productObj", products[i]);
            }
        }
        helper.setItemType(component, event, helper);*/
        if(orderItem.Id){
            component.set("v.isReadOnly",true);
        }else{
            component.set("v.isReadOnly", false);
        }
    },
    addNewRow : function(component, event, helper){
        let items = component.get('v.orderItems');
        let item = {};
        items.push(item);
        component.set('v.orderItems', items);
    },
    deleteRow :  function(component, event, helper){
        let index = event.currentTarget.id;
        if(index != undefined){
            let items = component.get('v.orderItems');
            items.splice(index,1);
            if(items.length == 0) {
                let item = {};
                items.push(item);
            }
            component.set('v.orderItems', items);
        }
    },
    onChangeFamily: function(component, event, helper){
        helper.setItemType(component, event, helper);
    },
    getWarehouseValue: function(component, event, helper) {
        let warehouseRec = event.getParam('warehouseData');
        console.log('SKU Id='+warehouseRec.WarehouseSKU);
        component.set("v.orderItem.Warehouse_Info__c", warehouseRec.WarehouseSKU);
        component.set("v.orderItem.RemainingQuantity", warehouseRec.RemainingQuantity);
        console.log('-----Remaining Quantity',warehouseRec.RemainingQuantity);
    },
    onChangeWarehouse: function(component, event, helper){
        component.find('warehouseSearchCmp').handleWarehouseSearch();
    },
    getProductValue: function(component, event, helper) {
        let productRec = event.getParam('productData');
        component.set("v.orderItem.Product__c", productRec.Id);
        component.set("v.orderItem.Product_Name__c", productRec.Name);
        component.set("v.orderItem.Product_Family__c", productRec.Family);
    }
});