/**
 * Created by hp on 2020-04-09.
 */

({
    doInit : function(component,helper) {
        debugger;
         var orderId = component.get("v.recordId");
         var workspaceAPI = component.find("workspace");
/*         workspaceAPI.getTabInfo({
                         tabId: response
                 }).then(function(tabInfo) {
                     console.log("The recordId for this tab is: " + tabInfo.recordId);
                 });*/

                workspaceAPI.getFocusedTabInfo().then(function(response) {
                     console.log('response--', JSON.stringify(response) );
                     var focusedTabId = response.tabId;
                    console.log('focusedTabId--', focusedTabId );
                        workspaceAPI.openSubtab({
                            parentTabId: response.tabId,
                            pageReference: {
                                "type": "standard__component",
                                "attributes": {
                                    "componentName": "c__PHOS_SplitOrder"
                                },
                                "state": {
                                    "uid": "1",
                                    "c__orderId":  orderId
                                }
                            }
                       }).then(function(subtabId) {
                            console.log("The new subtab ID is:" + subtabId);
                            workspaceAPI.setTabLabel({
                              tabId: subtabId,
                              label: "Split Order"
                            });
                     })

                 })
                 .catch(function(error) {
                     console.log('error--', error);
                     $A.get('e.force:refreshView').fire();
                 });
         /*workspaceAPI.openTab({
             url: '/lightning/r/Order/'+orderId+'/view',
             focus: true
            }).then(function(response) {
                   workspaceAPI.openSubtab({
                    parentTabId: response.tabId,
                    pageReference: {
                        "type": "standard__component",
                        "attributes": {
                            "componentName": "c__PHOS_SplitOrder"
                        },
                        "state": {
                            "uid": "1",
                            "c__orderId":  orderId
                        }
                    }
                   }).then(function(subtabId) {
                    console.log("The new subtab ID is:" + subtabId);
                    workspaceAPI.setTabLabel({
                      tabId: subtabId,
                      label: "Split Order"
                    });
                }).catch(function(error) {
                    console.log("sub tab error= "+error);
                });
           })
           .catch(function(error) {
               console.log('error= '+error);
           });*/

         $A.get("e.force:closeQuickAction").fire();
    }
});