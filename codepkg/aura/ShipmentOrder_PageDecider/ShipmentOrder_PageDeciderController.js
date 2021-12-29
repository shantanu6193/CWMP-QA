({
    doInit : function(component, event, helper) {
        debugger;
        let pageRef = component.get("v.pageReference");
        let pageRefObj = JSON.parse(JSON.stringify(pageRef));
        let url = window.location.href;
        let orderId;
        if(url != undefined){
            let index = url.indexOf("a09");
            orderId = url.substr(index,18);
        }
        console.log('--orderId--',orderId);
        if(orderId.length != 18){
            orderId = null;
        }
        let action = component.get("c.getInitData");
        action.setParams({
            "orderId" : orderId
        });
        action.setCallback(this, function(response) {
           let state = response.getState();
            if(state == 'SUCCESS') {
                let returnMap = response.getReturnValue();
                var navService = component.find("navService");
                var pageReference;
                if(pageRefObj.attributes.actionName == 'new'){
                    pageReference = {
                        type: "standard__objectPage",
                        attributes: pageRefObj.attributes,
                        state: {
                            nooverride: "1"
                        }
                    };
                    var defaultFieldValues = {
                        RecordTypeId : returnMap.Bulk_Procurement_RecordTypeId,
                    };
                    if(orderId != null) {
                        defaultFieldValues.Order_Custom__c = orderId;
                        defaultFieldValues.Name = returnMap.OrderNumber
                    }
                    pageReference.state.defaultFieldValues = component.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
                }
                navService.navigate(pageReference, true);
            }
        });
        $A.enqueueAction(action);
    },
});