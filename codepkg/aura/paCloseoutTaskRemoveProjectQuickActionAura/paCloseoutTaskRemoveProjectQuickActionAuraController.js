({
    doInit : function(component, event, helper) {
        let wireExecutor = new Date().getTime();
        var action = component.get("c.isFullAccessCloseoutTaskUserWire");
        action.setParams({ "closeoutTaskId" :  component.get("v.recordId"), "status" : wireExecutor});
        action.setCallback(this, function(response) {    
            let isFullAccessCloseoutTaskUser = response.getReturnValue().isFullAccessCloseoutTaskUserWire;
          
            if(isFullAccessCloseoutTaskUser == 'false'){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",  
                    "message": "You do not have permission to access Closeout Task Remove Projects"
                });
                toastEvent.fire();
                return;
            }
           
            else{
            
                var workspaceAPI = component.find("workspace");
                var focusedTabId;
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    this.focusedTabId = response.tabId;
                    workspaceAPI.openTab({
                                        pageReference: {
                                            "type": "standard__component",
                                            "attributes": {
                                                "componentName": "c__paCloseoutTaskRemoveProjectHolderAura" 
                                            },
                                            "state": {
                                                c__recordId : component.get('v.recordId'),
                                                c__focusedTabId : this.focusedTabId
                                            }
                                        },
                                        
                                        focus: true
                                    }).then((response) => {
                                            workspaceAPI.setTabLabel({
                                            tabId: response,
                                            label: "Remove Projects"
                                        });
                                            workspaceAPI.setTabIcon({
                                            tabId: response,
                                            icon: "action:new_case",
                                            iconAlt: "Remove Projects"
                                            }); 
                                    }).catch(function(error) {
                                        
                                    });
                });
            }    
        })
            
        $A.enqueueAction(action);
    }
})