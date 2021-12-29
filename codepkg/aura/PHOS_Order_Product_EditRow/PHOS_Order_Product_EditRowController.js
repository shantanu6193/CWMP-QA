/**
 * Created by hp on 2020-04-06.
 */

({
    doInit: function(component, event, helper){
        //component.set("v.family", component.get("v.orderItem.Product2.Family"));
        /* let products = component.get("v.products");
        let orderItem = component.get("v.orderItem");
        for(let i = 0 ; i < products.length ; i++){
        if(orderItem.Product__c != undefined && orderItem.Product__c != '' && orderItem.Product__c == products[i].Id ){
            console.log('----product---'+products[i]);
            component.set("v.productObj", products[i]);
        }
        }
        helper.setItemType(component, event, helper);*/
    },
    addNewRow : function(component, event, helper){
        let items = component.get('v.orderItems');
        let item = {};
        items.push(item);
        component.set('v.orderItems', items);
        console.log('------',items);
    },
    deleteRow :  function(component, event, helper){
        let index = event.currentTarget.dataset.id;
        console.log('-index-----',index);
        if(index != undefined){
            let items = component.get('v.orderItems');
            items.splice(index,1);
            if(items.length == 0) {
                let item = {};
                items.push(item);
            }
            component.set('v.orderItems', items);
            console.log('------',items);
        }
    },
     onChangeFamily: function(component, event, helper){
         helper.setItemType(component, event, helper);
     },
     setQuantityBackOrder: function(component, event, helper){
         //feedback from eric. Qty can be zero and filled qty can be more than zero
         if(component.get("v.orderItem.Quantity__c") > 0){
             let val = component.get("v.orderItem.Quantity__c") - component.get("v.orderItem.Quantity_Filled__c");
              val = (val <= 0 ? 0 : val);
              component.set("v.orderItem.Quantity_Back_Ordered__c", val);
         }

     },
     orderRowValidation : function(component, event, helper) {
         //debugger;
            let allValid = false;
            let reqFieldsValid = [].concat(component.find('formFields')).reduce(function (validSoFar, inputCmp) {
              inputCmp.showHelpMessageIfInvalid();
              return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            /* let familyValid = [].concat(component.find('family')).reduce(function (validSoFar, inputCmp) {
               inputCmp.showHelpMessageIfInvalid();
               return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            if(reqFieldsValid && familyValid) {*/
            var productRequired = component.find('productSearchCmp').validateCustomInput();
            if(reqFieldsValid && productRequired){
            allValid = true;
            }
            return allValid;

     },

    getProductValue: function(component, event, helper) {
        let productRec = event.getParam('productData');
        component.set("v.orderItem.Product__c", productRec.Id);
        component.set("v.orderItem.Product_Name__c", productRec.Name);
        component.set("v.orderItem.Product_Family__c", productRec.Family);
    },
});