/**
 * Created by hp on 2020-04-04.
 */

({
    retrieveOrderItems: function(component, event, helper,apiList){
        let recordId = component.get("v.recordId");
        component.set("v.orderId", recordId);
        let fieldAPINames = JSON.stringify(apiList);
        console.log('fieldAPINames',fieldAPINames);


        if(!$A.util.isEmpty(recordId)) {
            let action = component.get("c.getOrderProducts");
            action.setParams({
                "orderId" : recordId,
                "fieldAPINames" : fieldAPINames
            });
            action.setCallback(this, function(response) {
               let state = response.getState();
                if(state == 'SUCCESS') {
                    let returnMap = response.getReturnValue();
                    console.log('returnMap',returnMap);
                    component.set('v.orderItems', returnMap['orderItems']);
                    component.set("v.hasEditAccess", returnMap.hasEditAccess);
                    component.set("v.appName", returnMap.appName);
                    console.log('appName----',component.get('v.appName'));
                    let showRecordLockedError = returnMap.ShowRecordLockedError;
                    let orderStatus = returnMap.orderStatus;
                    let isCountyChild = returnMap.CountyChild;
                    let isCommunityUser = returnMap.isCommunityUser;
                    let orderApproved = returnMap.OrderApproved;
                    //debugger;
                    if(showRecordLockedError == true || orderStatus == 'Fulfilled - Closed') {
                        component.set('v.disableEditBtn',true);
                    }
                    else if(isCountyChild == true && orderStatus != 'Draft'){
                        component.set('v.disableEditBtn',true);
                    }
                    else if(isCommunityUser == true && showRecordLockedError == true && orderApproved == true) {
                        component.set('v.disableEditBtn',true);
                    }
                    else{
                        component.set('v.disableEditBtn',false);
                    }
                } else {
                    //TODO show proper toast message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error while loading the component."
                    });
                    toastEvent.fire();

                }
                component.set('v.loaded',true);
            });
            $A.enqueueAction(action);
        }
    }
});