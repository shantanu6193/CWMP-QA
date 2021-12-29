/**
 * Created by PREM on 31-08-2020.
 */

({
    doInit: function(component, event, helper){
        let recordId = component.get("v.recordId");
        let action = component.get("c.checkCommunityUser");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
           let state = response.getState();
            if(state == 'SUCCESS') {
                let returnData = response.getReturnValue();
                console.log('returnData------',returnData);
                if(returnData.IsCommunityUser == true) {
                    var navService = component.find("navService");
                    let baseURL = window.location.origin;
                    console.log(baseURL);
                    let url = baseURL + '/phos/s/plan-distribution?c__orderId='+recordId;
                    var pageReference = {
                        type: "standard__webPage",
                        attributes: {
                            url: url
                        }
                    };
                    navService.navigate(pageReference);
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else {
                    var baseURL = window.location.hostname;
                    let url = 'https://' + baseURL + '/lightning/n/Distribution_Plan?c__orderId='+recordId + '&c__isCommunity=' + returnData.IsCommunityUser;
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.openSubtab({
                           parentTabId: focusedTabId,
                           url: url,
                           focus: true
                       });
                   })
                    .catch(function(error) {
                        console.log(error);
                    });
                    /*try{
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            workspaceAPI.openSubtab({
                                parentTabId: response.tabId,
                                pageReference: {
                                    "type": "standard__component",
                                    "attributes": {
                                        "componentName": "c__productDistributionPlan" //Name of custom LWC followed by c__
                                    },
                                     "state": {
                                        "c__orderId": component.get("v.recordId") //record id of project, need it inside custom lwc
                                        }
                                },
                                 focus: true
                            }).then(function(subtabId) {
                                console.log("The new subtab ID is:" + subtabId);
                            }).catch(function(error) {
                                console.log("error");
                            });
                        });
                    }catch(e) {
                        console.log(e);
                    }*/

                }
            }
        });
        $A.enqueueAction(action);
    },
});