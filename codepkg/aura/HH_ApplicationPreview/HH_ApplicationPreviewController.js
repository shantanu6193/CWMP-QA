({
    handleClose: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response--', JSON.stringify(response) );
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            workspaceAPI.refreshTab({
                tabId: response.parentTabId,
                includeAllSubtabs: true
            });
        })
        .catch(function(error) {
            console.log('error--', error);
            $A.get('e.force:refreshView').fire();
        });
    },
    doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            response.subtabs.forEach(subtab => {
                if(subtab.url.includes('/c__HH_ApplicationPreview')) {
            workspaceAPI.setTabLabel({
                        tabId: subtab.tabId,
                        icon: "action:preview",
                label: "CWMP Application Preview"
            });
            workspaceAPI.setTabIcon({
                        tabId: subtab.tabId,
                icon: "action:preview",
                    });
                } else {
                    workspaceAPI.closeTab({tabId: subtab.tabId});      
                }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
});