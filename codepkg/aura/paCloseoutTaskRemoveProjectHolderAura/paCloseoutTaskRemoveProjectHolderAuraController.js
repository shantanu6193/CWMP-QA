({
    doInit: function(component, event, helper) {
        var action = component.get("c.getSalesforceCustomBaseURL");
        action.setCallback(this, function(response) {
            component.set("v.sbaseUrl", response.getReturnValue());
        });
        $A.enqueueAction(action);
        var id = component.get("v.pageReference").state.c__recordId;
        var sourceCloseoutTaskTabId = component.get("v.pageReference").state.c__focusedTabId;
        component.set("v.recId", id);
        component.set("v.sourceCloseoutTaskTabId", sourceCloseoutTaskTabId);
    },

    onTabClosed : function(component, event, helper) {
        //close component tab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                 //Reload source closeout task record tab
                 workspaceAPI.refreshTab({tabId: component.get("v.sourceCloseoutTaskTabId"), includeAllSubtabs: true})
            })
        })
        .catch(function(error) {
            console.log(error);
        });
        
        
    }
})