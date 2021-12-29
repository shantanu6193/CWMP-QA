({
    doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.getInitData");
        action.setParams({
            "preAppId" : recordId
        });
        action.setCallback(this, function(response) {
           let state = response.getState();
            if(state == 'SUCCESS') {
                let isEdit = response.getReturnValue().isEdit;
                console.log('isEdit----',isEdit);
                if(isEdit) {
                    let currentStage = response.getReturnValue().currentStage;
                    console.log('currentStage----',currentStage);
                    component.set('v.currentStage', currentStage);
                    console.log('--currentStage--',component.get("v.currentStage"));
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                        }), 1000
                    );
                    let urlEvent = $A.get("e.force:navigateToURL");
                    let url = '/hma-noi-request?id=' + component.get('v.recordId') + '&currentStage='+  component.get("v.currentStage");
                    console.log(url);
                    urlEvent.setParams({
                    "url": url
                    });
                    urlEvent.fire();
                }else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "mode": 'sticky',
                        "type": 'error',
                        "message": 'You are not able to edit your NOI Submission once it has been assigned to an Analyst.'
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
					"message": message
				});
				toastEvent.fire();
            }
        });
        $A.enqueueAction(action);

    }
});