/**
 * Created by PREM on 02-09-2020.
 */

({
    handleFilterChange: function(component, event, helper) {
        let communityUser = helper.getUrlParameter('c__isCommunity');
        if(communityUser == 'false') {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                console.log('response--', JSON.stringify(response) );
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
                var focusedTabId = response.parentTabId;
                workspaceAPI.refreshId({
                    tabId: parentTabId,
                    includeAllSubtabs: true
                });
            })
            .catch(function(error) {
                console.log('error--', error);
                $A.get('e.force:refreshView').fire();
            });
        }
    },
});