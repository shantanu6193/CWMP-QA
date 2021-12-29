/**
 * Created by hp on 2020-04-09.
 */

({
    retrieveOrderDetails: function(component, event, helper){
        let orderId = component.get("v.orderId");
        let action = component.get("c.getOrderDetails");
        action.setParams({
            "orderId" : orderId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state == 'SUCCESS') {
                let returnMap = response.getReturnValue();

                component.set('v.orderRec', returnMap['orderRec']);
                var orderRecord=component.get('v.orderRec');
                console.log('orderRecord-----',orderRecord);
                if(orderRecord.Status__c=='Fulfilled - Closed'){
                    helper.showErrorToast('Cannot modify Fulfilled - Closed Order', 'sticky');
                    if($A.util.isEmpty(component.get('v.orderId'))) {
                        var navLink = component.find("navLink");
                        var pageRef = {
                            type: 'standard__recordPage',
                            attributes: {
                                actionName: 'view',
                                objectApiName: 'Order',
                                recordId :orderId // change record id.
                            },
                        };
                        navLink.navigate(pageRef, true);
                        helper.delayedRefresh();
                    }  else {
                    // close subtab if has and refresh parent tab.
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            console.log('response--', JSON.stringify(response));
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
                }
                component.set('v.orderItems', returnMap['orderItems']);
                helper.getFulfilmentEntityWarehouse(component, event, helper);
            } else {
                helper.showErrorToast('Error','sticky');
            }
        });
        $A.enqueueAction(action);
  },
   delayedRefresh : function(milliseconds){
        let ms = milliseconds || 500;
        window.setTimeout($A.getCallback(function(){
            $A.get('e.force:refreshView').fire();
        }),ms);
    },
     showErrorToast : function(message, mode){
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": "Error!",
           "mode": mode,
           "type": 'error',
           "message": message
       });
       toastEvent.fire();
    },
  getFulfilmentEntityWarehouse: function(component, event, helper){
      let orderItems = component.get("v.orderItems");
      let fulfilmentOptions = [];
      for(let i = 0 ; i < orderItems.length ; i++){
          let optionToPush = orderItems[i].Fulfilment_Entity_Warehouse__c;
          if($A.util.isEmpty(optionToPush)) {
                optionToPush = 'N/A';
          }
          if(!fulfilmentOptions.includes(optionToPush) && optionToPush != 'Filled Locally/Regionally'){
              fulfilmentOptions.push(optionToPush);
          }
          if($A.util.isEmpty(fulfilmentOptions)){
              optionToPush = 'N/A';
              fulfilmentOptions.push(optionToPush);
          }
      }
      component.set("v.fulfilmentOptions", fulfilmentOptions);
      component.set('v.fulfilment', fulfilmentOptions[0]);
      helper.filterOrderItems(component, event, helper);//onload
  },
  getToAddressCCAddress: function(component, event, helper){
    debugger;
    let order = component.get("v.orderRec");
    order = Object.assign({}, order);
    let orderItems = component.get("v.filteredOrderItems");
    let paramMap = {};
    //paramMap.orderId = order.Id;
    paramMap.fulfilment = component.get("v.fulfilment");
    paramMap.Order = JSON.stringify(order);
    paramMap.OrderItems = JSON.stringify(orderItems);
    let action = component.get("c.getEmailAddresses");
      action.setParams({
          "paramMap" : paramMap
    });
    action.setCallback(this, function(response) {
        let state = response.getState();
         if(state === 'SUCCESS') {
            let sendTo = '';
            let ccAddress = '';
            let sendEmail = false;
            let returnMap = response.getReturnValue();
            if($A.util.isEmpty(returnMap)){
                component.set('v.sendEmail', sendEmail);
                component.set('v.sendTo', sendTo);
                component.set('v.ccAddress', ccAddress);
            }else{
                sendTo = returnMap['sendTo'].toString();
                component.set('v.sendTo', sendTo);
                ccAddress = returnMap['ccAddress'].toString();
                component.set('v.ccAddress', ccAddress);
                sendEmail = returnMap['sendEmail'];
                component.set('v.sendEmail', sendEmail);
            }    
        
        } else {
             helper.showErrorToast('Error','sticky');
         }
     });
     $A.enqueueAction(action);
  },
  retrieveProducts: function(component, event, helper){
      debugger;
      var action = component.get('c.getProducts');
      action.setCallback(this, function(response) {
          var state = response.getState();
          var productFamily = [];
          if (state === 'SUCCESS') {

              let products = response.getReturnValue().Products;
              component.set('v.products', products);
              let productsMap = component.get('v.productsMap');
              productsMap={};
              console.log('productsMap---', productsMap);
              for(let i = 0 ; i < products.length ; i++){
                  console.log('products[i].Id---', products[i].Id);
                  console.log('products[i].Name---', products[i]);
                  productsMap[products[i].Id] = products[i];
                  if(products[i].Name == 'Other'){
                      component.set('v.otherproductId', products[i].Id);
                  }

                  if(!productFamily.includes(products[i].Family)){
                      productFamily.push(products[i].Family);
                  }
              }
              //component.set("v.productFamily",productFamily);
              console.log('productFamily---', productFamily);
              console.log('productsMap---', productsMap);
              component.set('v.productsMap', productsMap);
              //component.set('v.loaded', true);
              //console.log('loaded---', component.get('v.loaded'));
               helper.retrieveOrderDetails(component, event, helper);
          } else {
              console.log('Error---', response.getError());
          }
      })
      $A.enqueueAction(action);
  },
  filterOrderItems: function(component, event, helper){
      debugger;
      let fulfilment = component.get('v.fulfilment');
      if(fulfilment == 'N/A') {
            fulfilment = '';
        }
      let orderItems = component.get("v.orderItems");
      let filteredOrderItems = [];
      for(let i = 0 ; i < orderItems.length ; i++){
          let wareHouse = orderItems[i].Fulfilment_Entity_Warehouse__c;
          if($A.util.isEmpty(wareHouse)) {
              wareHouse = '';
          }
          if(fulfilment == wareHouse){
              filteredOrderItems.push(orderItems[i]);
          }
      }
      component.set("v.filteredOrderItems", filteredOrderItems);
      helper.getToAddressCCAddress(component, event, helper);
  }
});