({
    doInit : function(component, event, helper) {
        component.set('v.Spinner', true);
        var action = component.get("c.getOrderItemAndShipmentProducts");
        action.setParams({
            "shipmentId" :  component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            component.set('v.Spinner', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.orderItemList", response.getReturnValue().orderItemList);
                    component.set("v.shipmentLineItems", response.getReturnValue().shipmentLineItems);
                    
                    console.log('>>>'+JSON.stringify(response.getReturnValue()));                
                }
                
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    addNewRow : function(component, event, helper){
        var items = component.get('v.shipmentLineItems');
        var item = {};
        items.push(item);
        component.set('v.shipmentLineItems', items);
        console.log('------',items);
        console.log('>>>'+JSON.stringify(items));           
    },
    
    deleteRow :  function(component, event, helper){
        let index = event.currentTarget.id;
        console.log('-index-----',index);
        if(index != undefined){
            let items = component.get('v.shipmentLineItems');
            items.splice(index,1);
            /*if(items.length == 0) {
                let item = {};
                items.push(item);
            }*/
            component.set('v.shipmentLineItems', items);
            console.log('------',items);
        }
    },
    
    saveShipmentProducts :  function(component, event, helper){
        let products = component.get('v.shipmentLineItems');
        var isValid=true;
        for(let i = 0 ; i < products.length ; i++){
            if(!products[i].Order_Product_Shipped__c || !products[i].Quantity__c){
                isValid = false;
            }
        }
        if(isValid){     
            component.set('v.Spinner', true);
            var action = component.get("c.saveShipmentLineItems");
            action.setParams({
                "shipmentLineItemsStr" : JSON.stringify(products),
                "shipmentId" :  component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue() == 'Success'){                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "success",
                            "title": "Success!",
                            "message": "The records has been submitted successfully."
                        });
                        toastEvent.fire();
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "error",
                            "title": "Error!",
                            "message": response.getReturnValue()
                        });
                        toastEvent.fire();
                    }                    
                    
                }else {
                    var errMessage='Unknown error';
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errMessage= errors[0].message;
                        }
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                        "message": errMessage
                    });
                    toastEvent.fire();
                }
                component.set('v.Spinner', false);
                
            });
            $A.enqueueAction(action);
            try{
            helper.refreshTab(component, event, helper);
            }
            catch(e){
                console.log(e);
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "error",
                "title": "Error!",
                "message": "Product Shipped and Quantity are required!"
            });
            toastEvent.fire();
        }
    },
    
    refreshOrderProductsHandler : function(component, event, helper){
        var childComp = component.find('childRow');
        if(childComp.length == undefined) {
            childComp.callChild();
        } else {
            for(var i=0 ;i<childComp.length; i++) {
                childComp[i].callChild();
            }
        }

    },
})