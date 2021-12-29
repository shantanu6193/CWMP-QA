({
    doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.getInitData");
        action.setParams({
            "appId" : recordId
        });
        action.setCallback(this, function(response) {
           let state = response.getState();
            if(state == 'SUCCESS') {
                let isEdit = response.getReturnValue().isEdit;
                if(isEdit) {
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1000
        );
        let urlEvent = $A.get("e.force:navigateToURL");
        let url = '/application-edit?id=' + component.get('v.recordId');
        console.log(url);
        urlEvent.setParams({
        "url": url
        });
        urlEvent.fire();
                }else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "mode": 'dismissible',
                        "type": 'error',
                        "message": 'You are not able to edit your Subapplication after it has been submitted.'
                    });
                    toastEvent.fire();
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                        }), 10
                    );
                }                
            } else {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "mode": 'sticky',
                    "type": 'error',
                    "message": state
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})