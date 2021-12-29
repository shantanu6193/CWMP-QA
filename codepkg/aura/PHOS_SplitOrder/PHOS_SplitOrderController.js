/**
 * Created by hp on 2020-04-09.
 */

({
    doInit: function(component, event, helper){
        var pageRef = component.get("v.pageReference");
        component.set("v.orderId", pageRef.state.c__orderId);
        helper.retrieveProducts(component, event, helper);
    },

    onChangeFulfilment: function(component, event, helper){
        helper.filterOrderItems(component, event, helper);
    },
    /*sendEmailCheckboxSelect:function(component, event, helper){
         var selectedRec = event.getSource().get("v.checked");
      
        if (selectedRec == true) {
            component.find("sendEmail").set("v.value", true);
             component.set("v.sendEmailCheckBox", true);
        }
        else
        {
             component.find("sendEmail").set("v.value", false);
             component.set("v.sendEmailCheckBox", false);
        }
        
    },*/
  createShipmentRec: function(component, event, helper){
        component.set("v.isLoadSpinner",true);
        let orderId = component.get("v.orderId");
        let order = component.get("v.orderRec");
        order = Object.assign({}, order);
        let orderItems = component.get("v.filteredOrderItems");

        let paramMap = {};
        //paramMap.orderId = order.Id;
        paramMap.fulfilment = component.get("v.fulfilment");
        paramMap.Order = JSON.stringify(order);
        paramMap.OrderItems = JSON.stringify(orderItems);

        let action = component.get("c.processSplitOrder");
        action.setParams({
            "paramMap" : paramMap
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "mode": 'sticky',
                    "type": 'success',
                    "message": response.getReturnValue().message
                });
                toastEvent.fire();
                //let returnMap = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
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
            else {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Information!",
                            "mode": 'sticky',
                            "type": 'info',
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }
            component.set("v.isLoadSpinner",false);
        });
        $A.enqueueAction(action);
    },
   /*sendSplitOrderEmail: function(component, event, helper){

      let orderId = component.get("v.orderId");
      let order = component.get("v.orderRec");
      order = Object.assign({}, order);
      let orderItems = component.get("v.filteredOrderItems");

      let paramMap = {};
      //paramMap.orderId = order.Id;
      paramMap.fulfilment = component.get("v.fulfilment");
      paramMap.Order = JSON.stringify(order);
      paramMap.OrderItems = JSON.stringify(orderItems);

      let action = component.get("c.sendEmail");
      action.setParams({
          "paramMap" : paramMap
      });
      action.setCallback(this, function(response) {
         let state = response.getState();
          if(state == 'SUCCESS') {
              //let returnMap = response.getReturnValue();
                if(response.getReturnValue().success){
                    var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Success!",
                       "mode": 'sticky',
                       "type": 'success',
                       "message": "Split Order email sent successfully."
                   });
                   toastEvent.fire();
                }else{
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Information!",
                       "mode": 'sticky',
                       "type": 'info',
                       "message": response.getReturnValue().message
                   });
                   toastEvent.fire();
                }
          } else {
              alert('ERROR');
          }
      });
      $A.enqueueAction(action);

    }*/

});