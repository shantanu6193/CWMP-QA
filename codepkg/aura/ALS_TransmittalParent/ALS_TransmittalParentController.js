({
doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        //component.set('v.transmittalId',component.get("v.recordId"));
        component.set("v.transmittalId", pageReference.state.c__refRecordId);
        var action = component.get("c.getDetails");
        
        action.setParams({ transmittalId : pageReference.state.c__refRecordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var acc = response.getReturnValue();
                  var workspaceAPI = component.find("workspace");
                             workspaceAPI.getFocusedTabInfo().then(function(response) {
                             var focusedTabId = response.tabId;
                             workspaceAPI.setTabLabel({
                             tabId: focusedTabId,
                             label: acc.TransmittalObj.Name+"_"+acc.TransmittalObj.ProgramName__r.Name+"_"+acc.TransmittalObj.ApplicantNumber__c
                             });
                             })
                             .catch(function(error) {
                             console.log(error);
                             });
            }
            else if (state === "INCOMPLETE") {
                  console.log("From server"+state);
            }
            else if (state === "ERROR") {
                  console.log("From server"+state);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        },
})