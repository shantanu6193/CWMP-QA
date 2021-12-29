/**
 * Created by hp on 2020-04-06.
 */

({
    retrieveProducts : function(component, event, helper){
        var action = component.get('c.getProducts');
        //todo- - move to helper class
        action.setCallback(this, function(response) {
            var state = response.getState();
            var productFamily = [];
            if (state === 'SUCCESS') {
                //todo - remove all console. there should be one debug in do init. no other debugs required
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
                component.set("v.productFamily", productFamily);
                component.set('v.productsMap', productsMap);
                component.set('v.loaded', true);

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error"
                });
                toastEvent.fire();
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

    getPicklistValues : function(component, event, helper, objectName, fieldName, fieldOptions) {
        var action = component.get('c.getPickListData');
        action.setParams({
                "sObjectName" : objectName,
                "fieldName" : fieldName
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('res-------------->',response.getReturnValue());
                let result = response.getReturnValue();
                var options = [];
                for(var key in result){
                    options.push({label: result[key], value: key});
                }
                component.set('v.'+fieldOptions,options);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error"
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(action);
    }
});