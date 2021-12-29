/**
 * Created by hp on 2020-04-04.
 */

({
    doInit : function(component, event, helper){
        component.set("v.isLoadSpinner",true);
        var pageRef = component.get("v.pageReference");
        if(pageRef == null) {
            component.set("v.orderId", helper.getUrlParameter('c__orderId'));
            component.set("v.appName", helper.getUrlParameter('c__appName'));
            component.set("v.isQuantityEditable", true);

        } else {
            component.set("v.orderId", pageRef.state.c__orderId);
            component.set("v.appName", pageRef.state.c__appName);
            console.log('appName  in edit---',component.get('v.appName'));
            component.set("v.isQuantityEditable", pageRef.state.c__isQuantityEditable);
        }
        let appName = component.get('v.appName');
        if(appName == 'Cal OES - Public Health Ordering System' || appName == 'Community User') {
            let columnToDisplayJSON = component.get('v.ColumnsToBeDisplayOnPHOS');
            component.set('v.ColumnsToBeDisplay', columnToDisplayJSON);
        }

        helper.getFieldDetails(component, event, helper);

    },
    saveAndCloseProducts : function(component, event, helper) {
        component.set("v.isQuickSave", false);
        helper.saveProducts(component, event, helper);
    },
    quickSaveProducts : function(component, event, helper) {
        component.set("v.isQuickSave", true);
        helper.saveProducts(component, event, helper);
    },
    cancelToClose : function(component, event, helper) {// Cancel Button Code
            let navService = component.find("navLink");
            let pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    objectApiName: 'Order__c',
                    recordId : component.get("v.orderId")
                },
            };
            navService.navigate(pageRef, true);
    },
});