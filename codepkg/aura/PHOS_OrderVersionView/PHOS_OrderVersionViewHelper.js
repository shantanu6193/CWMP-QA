/**
 * Created by hp on 2020-04-03.
 */

({
    retrieveProducts: function(component, event, helper){
        var action = component.get('c.getProducts');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
               // console.log('response----',response.getReturnValue());
                let products = response.getReturnValue().Products;
                component.set('v.products', products);
                let productsMap = component.get('v.productsMap');
                productsMap={};
               // console.log('productsMap---', productsMap);
                for(let i = 0 ; i < products.length ; i++){
                    //console.log('products[i].Id---', products[i].Id);
                    //console.log('products[i].Name---', products[i]);
                    productsMap[products[i].Id] = products[i];
                    if(products[i].Name == 'Other'){
                        //component.set('v.otherproductId', products[i].Id);
                    }
                }
                //console.log('productsMap---', productsMap);
                component.set('v.productsMap', productsMap);
            } else {
                console.log('Error---', response.getError());
            }

            helper.getOrderVersion(component, event, helper);
        })
        $A.enqueueAction(action);
        let orderItems = component.get('v.orderItems');
        if(orderItems.length == 0) {
            let item = {};
            orderItems.push(item);
            component.set('v.orderItems', orderItems);
        }
    },
    getOrderVersion:function(component, event, helper){

        let recordId = component.get("v.recordId");
         if(!$A.util.isEmpty(recordId)) {
            let action = component.get("c.getVersion");
            action.setParams({
                "orderVersionId" : recordId
            });
            action.setCallback(this, function(response) {
               let state = response.getState();
                if(state == 'SUCCESS') {
                    let returnMap = response.getReturnValue();
                    component.set('v.orderRec', returnMap['orderRec']);
                    component.set('v.orderItems', returnMap['orderItems']);
                    component.set('v.orderVersion', returnMap['orderVersion']);
                    component.set('v.createdByName', returnMap['orderVersion'].CreatedBy.Name);
                    //component.set('v.createdDate',returnMap['orderVersion'].CreatedDate);
                    component.set('v.createdDate',$A.localizationService.formatDate(returnMap['orderVersion'].CreatedDate, "yyyy/MM/dd"));
                    helper.getDeliveryAddress(component, event, helper);
                    helper.createOrderVersionCmp(component, event, helper);
                } else {
                    alert('ERROR');
                }

            });
            $A.enqueueAction(action);
         }
    },
    createOrderVersionCmp: function(component, event, helper){
        $A.createComponent("c:phosEditOrderPreview", {
                            "orderVersion":component.get("v.orderRec"),
                            "createdDate":component.get("v.createdDate"),
                            "createdByName":component.get("v.createdByName"),
                            },
          function(newCmp,status,errorMessage) {
            if (component.isValid()) {
                if(status == "ERROR") {
                    console.log("Error Message–",errorMessage);
                }
             component.set("v.orderVersion", newCmp);
            }
        });
    },
    getDeliveryAddress: function(component, event, helper){
        debugger;
         var address = [];
        if(!$A.util.isEmpty(component.get('v.orderRec.Shipping_Street__c'))) {
         address = component.get('v.orderRec.Shipping_Street__c').split('\n');
         component.set("v.orderRec.Shipping_Street__c",address[0]);
         if(address.length > 1){
             component.set('v.address',address[1]);
         }
        }
         
    }
});