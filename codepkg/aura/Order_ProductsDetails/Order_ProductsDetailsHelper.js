/**
 * Created by PREM on 30-04-2020.
 */

({
    retrieveOrderItems: function(component, event, helper,apiList,orderId){
        let recordId = component.get("v.orderId");
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
                    let orderItem = returnMap.orderItems;
                    console.log('returnMap',returnMap);
                    component.set('v.orderItems', returnMap['orderItems']);
                    component.set('v.isEditable', returnMap['hasEditAccess']);
                    let showRecordLockedError = returnMap.ShowRecordLockedError;
                    let orderStatus = returnMap.orderStatus;
                    let isCountyChild = returnMap.CountyChild;
                    let isCommunityUser = returnMap.isCommunityUser;
                    let orderApproved = returnMap.OrderApproved;
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
                    let errorMsg = response.getError()[0];
                    console.log('error----',errorMsg);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error while loading the component."
                    });
                    toastEvent.fire();

                }
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
});