/**
 * Created by PREM on 30-04-2020.
 */

({
    doInit : function(component, event, helper){
        debugger;
        var pageRef = component.get("v.pageReference");
        if(pageRef == null) {
            component.set("v.orderId", helper.getUrlParameter('c__orderId'));
            component.set('v.IsCommunity',helper.getUrlParameter('c__isCommunity'));
            component.set('v.appName',helper.getUrlParameter('c__appName'));
            console.log('in if community',component.get('v.IsCommunity'));

        } else {
            component.set("v.orderId", pageRef.state.c__orderId);
            component.set("v.IsCommunity", pageRef.state.c__isCommunity);
            component.set('v.appName', pageRef.state.c__appName);
            console.log('in else community',component.get('v.IsCommunity'));
        }
        if(component.get('v.appName') == 'Cal OES - Public Health Ordering System'){
            component.set('v.detailColumnsJSON',component.get('v.phosDetailColumnsJSON'));
        }
        let detailJSON = component.get('v.detailColumnsJSON');
        let configArray = JSON.parse(detailJSON);
        let apiList = [];
        for(let i=0;i<configArray.length;i++){
            apiList.push(configArray[i].APIName);
        }
        helper.retrieveOrderItems(component, event, helper,apiList);
        component.set('v.configList',configArray);
    },
    redirectToOrderDetail : function(component, event, helper){
        debugger;
        let orderId = component.get('v.orderId');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        var navService = component.find("navService");
        var pageRef = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": orderId,
                "objectApiName": "Order__c",
                "actionName": "view"
            }
        };
        navService.navigate(pageRef);
    },
    redirectToEditRecord : function(component, event, helper){
        if(component.get('v.IsCommunity') == 'Yes' ) {
            let urlEvent = $A.get("e.force:navigateToURL");
            let url = '/edit-order-products?c__orderId=' + component.get('v.orderId') + '&c__appName=' + component.get('v.appName');
            urlEvent.setParams({
              "url": url
            });
            urlEvent.fire();
            return;
        }
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__Order_ProductsEdit"
                    },
                    "state": {
                        "uid": "1",
                        "c__orderId":  component.get("v.orderId"),
                        "c__isQuantityEditable": true,
                        "c__appName": component.get('v.appName')
                    }
                }
            }).then(function(subtabId) {
                console.log("The new subtab ID is:" + subtabId);
                workspaceAPI.setTabLabel({
                  tabId: subtabId,
                  label: "Edit Products"
                });
            }).catch(function(error) {
                console.log("error");
            });
        });
    }
});