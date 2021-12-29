({

    doInit : function(component, event, helper) {

        var action = component.get("c.getCloseOutTaskDetails");
        action.setParams({ "closeOutTaskId" :  component.get("v.recordId")});
        action.setCallback(this, function(response) {
            console.log('#response.getState() :',response.getState());
            console.log('#response.getReturnValue()', response.getReturnValue());
            let returnObj = response.getReturnValue().masterCloseoutTask; 
            let isMergecloseoutAccessiable = response.getReturnValue().mergeCloseOutCheck; 
            let isCloseoutTaskStatusValidationPassed = response.getReturnValue().isCloseoutTaskStatusValidationPassed;
            if(isMergecloseoutAccessiable == false){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",  
                    "message": "You do not have necessary access to merge this Closeout Task"
                });
                toastEvent.fire();
                return;
            }

           /* if(isCloseoutTaskStatusValidationPassed == false){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",  
                    "message": "You are not allowed to merge Closeout Task at this stage"
                });
                toastEvent.fire();
                return;
            }else{*/
                component.set("v.isLoaded", true);
                var workspaceAPI = component.find("workspace");
                workspaceAPI.openTab({
                    pageReference: {
                        "type": "standard__component",
                        "attributes": {
                            "componentName": "c__PA_MergeCloseTaskHolder"  // c__<comp Name>
                        },
                        "state": {
                            c__recordId : component.get('v.recordId')// c__<comp attribute Name>
                        }
                    },
                    focus: true
                }).then((response) => {
                       workspaceAPI.setTabLabel({
                          tabId: response,
                          label: "Merge Closeout"
                       });
                       workspaceAPI.setTabIcon({
                                tabId: response,
                                icon: "action:new_case",
                                iconAlt: "Merge Closeout"
                        }); 
                }).catch(function(error) {
                    console.log(error);
                });
                
           // }
        })
        $A.enqueueAction(action);
    },
    
    closeQA: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})