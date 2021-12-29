/**
 * Created by hp on 2020-04-05.
 */

({
    retrieveOrderItems: function(component, event, helper){
        component.set('v.loaded', false);
        let recordId = component.get("v.orderId");

        let previewJSON = component.get('v.ColumnsToBeDisplay');
        let configArray = JSON.parse(previewJSON);
        let apiList = [];
        for(let i=0;i<configArray.length;i++){
            apiList.push(configArray[i].APIName);
        }

        if(!$A.util.isEmpty(recordId)) {
            let action = component.get("c.getOrderProductDetails");
            action.setParams({
                "orderId" : recordId,
                "fieldAPINames":JSON.stringify(apiList)
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if(state == 'SUCCESS') {
                    let returnMap = response.getReturnValue();
                    let items = returnMap['orderItems'];
                    let warehouseList = returnMap['Warehouse'];
                    console.log('items----',items);
                    if(items.length == 0) {
                        let item = {};
                        items.push(item);
                        component.set('v.orderItems', items);
                    }else{
                        
                        for(let i=0; i<items.length; i++) {
                            items[i].enablePostSent = false;
                            for(let j=0; j<warehouseList.length; j++){
                                console.log('warehouseList[j]------',warehouseList[j]);
                                if(items[i].Fulfilment_Entity_Warehouse__c == warehouseList[j].MasterLabel){
                                    items[i].enablePostSent = true;
                                }
                            }
                        }
                        console.log('items------',JSON.stringify(items));
                        component.set('v.orderItems', items);
                    }
                } else {
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": message
                    });
                    toastEvent.fire();
                }
                component.set('v.loaded',true);
                component.set("v.isLoadSpinner",false);
            });
            $A.enqueueAction(action);
        }
    },
    getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    retrieveProducts: function(component, event, helper){
        var action = component.get('c.getProducts');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var productFamily = [];
            if (state === 'SUCCESS') {
                let products = response.getReturnValue().Products;
                component.set('v.products', products);
                let productsMap = component.get('v.productsMap');
                productsMap={};
                for(let i = 0 ; i < products.length ; i++){
                    productsMap[products[i].Id] = products[i];
                    if(products[i].Name == 'Other'){
                        component.set('v.otherproductId', products[i].Id);
                    }

                    if(!productFamily.includes(products[i].Family)){
                        productFamily.push(products[i].Family);
                    }
                }
                component.set("v.productFamily",productFamily);
                component.set('v.productsMap', productsMap);
                helper.retrieveOrderItems(component, event, helper);
            } else {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": message
                });
                toastEvent.fire();
                component.set("v.isLoadSpinner",false);
            }
        })
        $A.enqueueAction(action);
        let orderItems = component.get('v.orderItems');
        if(orderItems.length == 0) {
            let item = {};
            orderItems.push(item);
            component.set('v.orderItems', orderItems);
        }
    },

    getFieldDetails : function(component, event, helper){
        let action = component.get("c.getFieldDetails");
        action.setParams({
            "fieldsJSON":component.get('v.ColumnsToBeDisplay'),
            "objectName":"Order_Product__c"
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state == 'SUCCESS') {
                component.set('v.fieldDetailList', response.getReturnValue());
                helper.retrieveProducts(component, event, helper);
            } else {
                component.set("v.isLoadSpinner",false);
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    setItemCode: function(component, event, helper){
        let items = JSON.parse(JSON.stringify(component.get('v.orderItems')));
        let productsMap = JSON.parse(JSON.stringify(component.get('v.productsMap')));
        for(let i = 0 ; i < items.length ; i++){
            let productCode2Id = items[i].Product__c;
            let product = productsMap[productCode2Id];
            if(product){
                if(product.Name != 'Other'){
                    items[i].Item_Code__c = product.Product_Code__c;
                }
            }

        }
        component.set('v.orderItems', items);
    },
    saveProducts : function(component, event, helper){
        try{
            component.set("v.isLoadSpinner",true);
            //var requiredFields = 'Product Family, Item Type';
            var requiredFields = ["Product Family", "Item Type"];
            let fieldDetailList = component.get("v.fieldDetailList");
            /*for(var j=0; j<fieldDetailList.length; j++){
                if(fieldDetailList[j].isRequired){
                    //requiredFields = requiredFields + ', ' + fieldDetailList[j].APIName;
                    requiredFields.push(fieldDetailList[j].APIName);
                }
            }*/

            helper.setItemCode(component, event, helper);
            let orderItems = component.get("v.orderItems");

            var isvalid = true;
            var productValid = true;
            debugger;
            for(var i=0; i<orderItems.length; i++){
                if(!orderItems[i].Product__c){
                    isvalid=false;
                    productValid = false;
                    //break;
                }
                delete orderItems[i].error;
                for(var j=0; j<fieldDetailList.length; j++){
                    if(fieldDetailList[j].isRequired){
                        let value = orderItems[i][fieldDetailList[j].APIName];
                        if(value != undefined) {
                            value = value + '';
                        }
                        if(value == undefined || value == ''){
                            isvalid=false;
                            requiredFields.push(fieldDetailList[j].Label);
                            //break;
                        }
                    }
                }
            }
            if(productValid == true) {
                requiredFields.splice(0,2);
             }
            console.log('req-----'.requiredFields);
            if(isvalid){
                let paramMap = {};
                paramMap.OrderItems = JSON.stringify(orderItems);
                paramMap.Order__c = component.get("v.orderId");
                let action = component.get("c.saveOrderItems");
                action.setParams({
                    'paramMap' : paramMap
                });
                action.setCallback(this, function(response) {
                    debugger;
                    let state = response.getState();
                    if(state == 'SUCCESS') {
                        component.set("v.isEditProduct", false);
                        let responseVal = response.getReturnValue();
                        console.log('--responseVal--', responseVal);
                        // in case of inventory error
                        if(responseVal.hasError == true) {
                            component.set("v.isLoadSpinner",false);
                            let errorMap = responseVal.errorMap;
                            let orderItems = component.get("v.orderItems");
                            for(let i=0; i<orderItems.length; i++) {
                                if(errorMap[i] != undefined) {
                                    orderItems[i].error = errorMap[i];
                                }
                            }
                            console.log('orderItems---', orderItems);

                            component.set("v.orderItems", orderItems);

                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "mode": 'sticky',
                                "type": 'error',
                                "message": "Please fix all errors."
                            });
                            toastEvent.fire();

                            return;
                        }

                        // in case of save and close
                        var isQuickSave =  component.get("v.isQuickSave");
                        if(!isQuickSave) {
                            if(component.get('v.IsCommunity') == 'Yes') {
                                let navService = component.find("navLink");
                                let pageRef = {
                                    type: 'standard__recordPage',
                                    attributes: {
                                        actionName: 'view',
                                        objectApiName: 'Order',
                                        recordId : component.get("v.orderId")
                                    },
                                };
                                navService.navigate(pageRef, true);
                            } else {
                                var workspaceAPI = component.find("workspace");

                                workspaceAPI.getFocusedTabInfo().then(function(response) {
                                    console.log('response--', JSON.stringify(response) );
                                    var focusedTabId = response.tabId;
                                    workspaceAPI.closeTab({tabId: focusedTabId});
                                    var focusedTabId = response.parentTabId;
                                    workspaceAPI.refreshId({
                                        tabId: parentTabId,
                                        includeAllSubtabs: true
                                    });
                                })
                                .catch(function(error) {
                                    console.log('error--', error);
                                    $A.get('e.force:refreshView').fire();
                                });
                            }

                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "mode": 'sticky',
                                "type": 'success',
                                "message": "Order Products updated Successfully"
                            });
                            toastEvent.fire();
                        }
                    } else {
                        let errors = response.getError();
                        let message = 'Unknown error'; // Default error message
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            message = errors[0].message;
                        }

                        // Display the message
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": 'error',
                            "message": message
                        });
                        toastEvent.fire();
                    }
                    component.set("v.isLoadSpinner",false);
                });
                $A.enqueueAction(action);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": requiredFields.toString() +  ' are required fields!'
                });
                toastEvent.fire();
                component.set("v.isLoadSpinner",false);
            }

        } catch(err) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": err.message
            });
            toastEvent.fire();
            component.set("v.isLoadSpinner",false);
        }
    }
});