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
        let url = '';
        if(response.getReturnValue().isExternalUser) {
            url = '/hh-application?id=' + component.get('v.recordId')+'&currentStage=ApplicantInfo';    
        } else {
            url = '/lightning/cmp/c__HH_Application?c__id=' + component.get('v.recordId')+'&c__currentStage=ApplicantInfo'; 
        }
        console.log(url);
        urlEvent.setParams({
        "url": url
        });
        urlEvent.fire();
                }else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    mode: 'dismissible',
                    message: 'Error',
                    messageTemplate: $A.get("$Label.c.HH_EN_Application_Already_Submitted"),
                    messageTemplateData: ['', {
                        url: $A.get("$Label.c.HH_Information_PDF"),
                        label: $A.get("$Label.c.HH_EN_HERE"),
                    }
                    ]
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
                    "mode": 'dismissible',
                    "type": 'error',
                    "message": state
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})