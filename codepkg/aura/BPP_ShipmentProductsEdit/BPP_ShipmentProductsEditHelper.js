({
    refreshTab: function(component, event, helper){
            window.setTimeout(
                $A.getCallback(function() {
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.refreshTab({
                              tabId: focusedTabId,
                              includeAllSubtabs: true
                         });
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                }), 500
            );
        }
});