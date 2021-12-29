({
    doInit : function(component, event, helper) {
        //helper.handleSteps(component, event, helper,1,0);
    	let recordId = component.get("v.recordId");
    	component.set('v.isLoaded',true);
    	if($A.util.isEmpty(recordId)) {
            recordId = helper.getUrlParameter('id');
            component.set("v.recordId", recordId);
        }
        if($A.util.isEmpty(recordId)) {
            recordId = component.get("v.editRecordId");
            component.set("v.recordId", recordId);
        }
        //component.set("v.recordId", recordId);
        if(!$A.util.isEmpty(recordId)) {
            component.set('v.isLoaded',false);
            //let action = component.get("c.getOrders");
            let action = component.get("c.getOrderData");
            action.setParams({
                "orderId" : recordId
            });
            action.setCallback(this, function(response) {
               let state = response.getState();
                if(state == 'SUCCESS') {
                    let returnMap = response.getReturnValue();
                   // component.set('v.orderRec', returnMap['Order']);
                    //component.set('v.orderItems', returnMap['OrderItems']);
                    component.set("v.orderRecord", returnMap.Order);
                    component.set("v.isCommunityUser", returnMap.isCommunityUser);
                    let showRecordLockedError = returnMap.ShowRecordLockedError;
                    let orderStatus = returnMap.Order.Status__c;
                    let isCountyChild = returnMap.CountyChild;
                    let isCommunityUser = returnMap.isCommunityUser;
                    let orderApproved = returnMap.OrderApproved;
                    console.log('showRecordLockedError====',orderStatus);
                    //debugger;
                    if(showRecordLockedError == true || orderStatus == 'Fulfilled - Closed' || (orderStatus != 'Draft' && isCountyChild == true)
                        || (showRecordLockedError == true && isCommunityUser == true && orderApproved == true)) {
                        if(isCountyChild == true && orderStatus != 'Draft') {
                            helper.showErrorToast('Order can be modified in Draft status','sticky');
                        }
                        else if(showRecordLockedError == true && isCommunityUser == true && orderApproved == true) {
                            helper.showErrorToast('Order cannot be edited once approved','sticky');
                        }
                        else if(orderStatus == 'Fulfilled - Closed') {
                            helper.showErrorToast('Cannot modify Fulfilled - Closed order','sticky');
                        }
                        else if(showRecordLockedError == true) {
                            helper.showErrorToast('This record is locked. If you need to edit it, contact your admin','sticky');
                        }
                        //debugger;
                        if($A.util.isEmpty(component.get('v.editRecordId'))) {
                           var navLink = component.find("navLink");
                           var pageRef = {
                               type: 'standard__recordPage',
                               attributes: {
                                   actionName: 'view',
                                   objectApiName: 'Order__c',
                                   recordId : returnMap.Order.Id // change record id.
                               },
                           };
                           navLink.navigate(pageRef, true);
                           helper.delayedRefresh();
                        }  else {
                            // close subtab if has and refresh parent tab.
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
                    }
                    //helper.getDeliveryAddress(component, event, helper);
                } else {
                    helper.showErrorToast('Error while getting order details.');
                }
                component.set('v.isLoaded',true);
            });
            $A.enqueueAction(action);
        }

    },
    orderSubmitted: function(component, event, helper) {
        let communityUser = component.get("v.isCommunityUser");
        if(communityUser == false) {
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
    /*
    handleQuickSave : function(component, event, helper) {
        let currentStep = component.get('v.currentStep');
        if(currentStep == 'step1') {
            let allValid = helper.informationPageValidation(component, event, helper);
            if(allValid) {
                helper.saveOrder(component, event, helper, true);
            }
        }
        else if(currentStep == 'step2') {
            let allValid = helper.orderPageValidation(component, event, helper);
            if(allValid) {
                helper.saveOrder(component, event, helper, true);
            }
        }
        else {
            helper.saveOrder(component, event, helper, true);
        }
    },
    handleSubmit : function(component, event, helper) {
        helper.saveOrder(component, event, helper, false);
    },
    
    handleNextClick: function(component, event, helper) {
        console.log('--IN SUBMIT--');
        let currentStep = component.get('v.currentStep');
        if(currentStep == 'step1'){
            let allValid = helper.informationPageValidation(component, event, helper);
            if(allValid) {
                helper.handleSteps(component, event, helper,undefined,1); 
            }
        }
        else if(currentStep == 'step2'){
            let allValid = helper.orderPageValidation(component, event, helper);
            if(allValid) {
                helper.handleSteps(component, event, helper,undefined,1);
            }
        }
        else {
            helper.handleSteps(component, event, helper,undefined,1);
        }
    },
    handlePreviousClick: function(component, event, helper) {
        let currentStep = component.get('v.currentStep');
        if(currentStep == 'step2'){
            let allValid = helper.orderPageValidation(component, event, helper);
            if(allValid) {
                helper.handleSteps(component, event, helper,undefined,-1);
            }
        }
        else{
            helper.handleSteps(component, event, helper,undefined,-1);
        }
    },
    handleWizard: function(component, event, helper) {
        var currentStepCounter = event.currentTarget.dataset.id;
        console.log('currentStepCounter--',currentStepCounter);
        let currentStep = component.get('v.currentStep');
        if(currentStep == 'step1'){
            let allValid = helper.informationPageValidation(component, event, helper);
            if(allValid) {
                helper.handleSteps(component, event, helper,0,parseInt(currentStepCounter));
            }
        }
        else if(currentStep == 'step2'){
            let allValid = helper.orderPageValidation(component, event, helper);
            if(allValid) {
                helper.handleSteps(component, event, helper,0,parseInt(currentStepCounter));
            }
        }
        else{
            helper.handleSteps(component, event, helper,0,parseInt(currentStepCounter));
        }
    },*/
})