/**
 * Created by hp on 2020-04-04.
 */

({
    doInit: function(component, event, helper){
        let previewJSON = component.get('v.previewColumnsJSON');
        let configArray = JSON.parse(previewJSON);
        let apiList = [];
        for(let i=0;i<configArray.length;i++){
            apiList.push(configArray[i].APIName);
        }
        helper.retrieveOrderItems(component, event, helper,apiList);
        component.set('v.configList',configArray);

    },
    openEditProductTab: function(component, event, helper) {
        try {
            //TODO get page name from design attribute
            if(component.get('v.IsCommunity') == 'Yes' ) {
                let urlEvent = $A.get("e.force:navigateToURL");
                let url = '/edit-order-products?c__orderId=' + component.get('v.recordId') + '&c__appName=' + component.get('v.appName');
                urlEvent.setParams({
                  "url": url
                });
                urlEvent.fire();
                return;
            }
        } catch(e) {
            console.log('e---', e);
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
                        //"c__orderItems": component.get("v.orderItems"),
                        "c__orderId":  component.get("v.orderId"),
                        "c__isQuantityEditable": true,
                        "c__appName" : component.get('v.appName')
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

    },
    openProductTab: function(component, event, helper){
        if(component.get('v.IsCommunity') == 'Yes' ) {
            let urlEvent = $A.get("e.force:navigateToURL");
            let url = '/detail/' + event.target.id;
            urlEvent.setParams({
              "url": url
            });
            urlEvent.fire();
            return;
        }
        else{
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                workspaceAPI.openSubtab({
                    parentTabId: enclosingTabId,
                    url: '#/sObject/'+event.target.id+'/view',
                    focus: true
                });
            });
        }
    },
    openViewProductTab: function(component, event, helper) {
        let orderId = component.get('v.recordId');
        if(component.get('v.IsCommunity') == 'Yes' ) {
            let urlEvent = $A.get("e.force:navigateToURL");
            let url = '/view-order-products?c__orderId=' + orderId + '&c__isCommunity=' + component.get('v.IsCommunity');
            urlEvent.setParams({
              "url": url
            });
            urlEvent.fire();
            return;
        }
        var baseURL = window.location.hostname;
        let url = 'https://' + baseURL + '/lightning/n/BPP_OrdersProducts_DetailList?c__orderId='+component.get("v.orderId") + '&c__isCommunity=' + component.get('v.IsCommunity') + '&c__appName=' + component.get('v.appName');
        console.log('====',url);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
});