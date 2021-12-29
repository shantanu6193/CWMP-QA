({
    doInit: function (component,event,helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            if(response.subtabs != undefined) {
                response.subtabs.forEach(subtab => {
                    if(subtab.url.includes('/c__HH_Application?')) {
            workspaceAPI.setTabLabel({
                            tabId: subtab.tabId,
                icon: "action:edit_relationship",
                label: "CWMP Application"
            });
            workspaceAPI.setTabIcon({
                            tabId: subtab.tabId,
                icon: "action:edit_relationship",
            });
                    } else {
                        workspaceAPI.closeTab({tabId: subtab.tabId});      
                    }
                });
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    handleClose: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response--', JSON.stringify(response) );
            workspaceAPI.getTabInfo({
                tabId: response.parentTabId
            }).then(function(r) {
                if(r.subtabs != undefined) {
                    r.subtabs.forEach(subtab => {
                            workspaceAPI.closeTab({tabId: subtab.tabId});    
                    });
                }
            workspaceAPI.refreshTab({
                tabId: response.parentTabId,
                    includeAllSubtabs: false
                });
            });
        })
        .catch(function(error) {
            console.log('error--', error);
            $A.get('e.force:refreshView').fire();
        });
    }
});