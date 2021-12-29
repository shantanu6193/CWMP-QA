({
    checkForRequired: function (component, event, helper) {
        debugger;
        console.log('req---',component.find('reqField'));
        let allChildValid = true;
        if (component.find("reqField") != undefined) {
            var childComponents = component.find("reqField");
            // it can be single component or it can be list
            if (Array.isArray(childComponents)) {
                for (let cmp in childComponents) {
                    if (childComponents[cmp].checkForRequired() == false) {
                        allChildValid = false;
                    }
                }
            } else {
                console.log("Check--",childComponents.length);
                allChildValid = childComponents.checkForRequired();
            }
        }
        return allChildValid;
    },
    getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    handleSteps: function(component, event, helper,currentStepCounter,increment) {
        var currentStep;
        if(currentStepCounter != undefined){
            currentStep = 'step'+currentStepCounter;
        }else{
            currentStep = component.get('v.currentStep');
            var tmp = currentStep.replace('step','');
            currentStepCounter =parseInt(tmp);
        }
		console.log('currentStep--',currentStep);
		console.log('currentStepCounter--',currentStepCounter);
        var progStyle = component.find("progressStyle");
 
        var nextStepCounter = currentStepCounter+increment;
        console.log('nextStepCounter--',nextStepCounter);

        var nextStep = 'step'+ nextStepCounter;
        console.log('nextStep--',nextStep);
        component.set('v.currentStep', nextStep);
        var currentAuraStep = component.find(currentStep);
		var nextAuraStep = component.find(nextStep);

		if(nextStepCounter >= 0 || nextStepCounter <= 3){
		    $A.util.removeClass(progStyle, 'widthFirstClass');
            $A.util.removeClass(progStyle, 'widthSecondClass');
            $A.util.removeClass(progStyle, 'widthThirdClass');

			if(nextStep=='step1'){
	            $A.util.addClass(progStyle, 'widthFirstClass');
	            $A.util.addClass(nextAuraStep, 'slds-is-active');
	        }
	        else if(nextStep=='step2'){
	            $A.util.addClass(progStyle, 'widthSecondClass');
	            $A.util.addClass(nextAuraStep, 'slds-is-active');
	        }
	        else if(nextStep=='step3'){
	            $A.util.addClass(progStyle, 'widthThirdClass');
	            $A.util.addClass(nextAuraStep, 'slds-is-active');
	        }
        }
    },
    setDeliveryAddress: function(component, event, helper){
        debugger;
        let addressLine = component.get('v.addressLine2');
        console.log("addressLine------",component.get('v.addressLine2'));
        if(addressLine == undefined){
            addressLine = '';
        }
        console.log('orderRecord-----',JSON.stringify(component.get('v.orderRec')));
        component.set('v.orderRec.Shipping_Street__c', component.get('v.orderRec.Shipping_Street__c') + "\n " + addressLine);
        console.log("address------",component.get('v.orderRec.Shipping_Street__c'));
    },
    getDeliveryAddress: function(component, event, helper){
         var address = [];
         if(component.get('v.orderRec.Shipping_Street__c') != undefined) {
         address = component.get('v.orderRec.Shipping_Street__c').split('\n');
         component.set("v.orderRec.Shipping_Street__c",address[0]);
         if(address.length > 1){
             component.set('v.addressLine2',address[1]);
         }
         }

    },
    saveOrder:function(component, event, helper, quickSave){
        debugger;
        try{
            component.set('v.isLoading',true);
            helper.setDeliveryAddress(component, event, helper);
            let order = component.get("v.orderRec");
            order = Object.assign({}, order);
            let orderItems = component.get("v.orderItems");

            let paramMap = {};
            paramMap.Order = JSON.stringify(order);
            paramMap.OrderItems = JSON.stringify(orderItems);
            paramMap.QuickSave = quickSave;

            let action = component.get('c.saveOrder');
            action.setParams({
                'paramMap' : paramMap
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                debugger;
                try {
                    if(state == 'SUCCESS') {
                        helper.processSaveOrderCallbackSuccess(component, helper, event, response, quickSave);
                    } else {
                        let errors = response.getError();
                        let message = 'Unknown error'; // Default error message
                        // Retrieve the error message sent by the server
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            message = errors[0].message;
                        }
                        // Display the message
                        console.error(message);
                        helper.showErrorToast(message, 'sticky');
                    }
                    component.set('v.isLoading',false);
                } catch(e) {
                    console.log('error--', e);
                }
            });
            $A.enqueueAction(action);
        } catch(e) {
            helper.showErrorToast('Something went wrong. Please contact administrator.', 'sticky');
        }
    },

    processSaveOrderCallbackSuccess : function(component, helper, event, response, quickSave) {

        //show toast message
        if(quickSave) {
            debugger;
            helper.showSuccessToast( "Order saved successfully. Order Number is" + response.getReturnValue().OrderNumber);
            // update order and product to UI only in case of quick save. In other cases it will be page redirection
            component.set("v.orderRec", response.getReturnValue().OrderRec);
            component.set("v.orderItems", response.getReturnValue().OrderItems);
            helper.getDeliveryAddress(component, event, helper);
            // in case of quick save we don't need to redirect. just break method
            return;
        }

        helper.showSuccessToast( "Order Submitted Successfully. Order Number is " + response.getReturnValue().OrderNumber);

        // redirection is different for community user vs internal user. For internal users record id is present
        if($A.util.isEmpty(component.get('v.recordId'))) {
            var navLink = component.find("navLink");
           var pageRef = {
               type: 'standard__recordPage',
               attributes: {
                   actionName: 'view',
                   objectApiName: 'Order',
                   recordId : response.getReturnValue().OrderRec.Id // change record id.
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
    },

    showSuccessToast : function(message){
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": "Success!",
           "mode": 'dismissible',
           "type": 'success',
           "message": message
       });
       toastEvent.fire();
    },
    showErrorToast : function(message, mode){
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": "Error!",
           "mode": mode,
           "type": 'error',
           "message": message
       });
       toastEvent.fire();
    },
    delayedRefresh : function(milliseconds){
        let ms = milliseconds || 500;
        window.setTimeout($A.getCallback(function(){
            $A.get('e.force:refreshView').fire();
        }),ms);
    },
    informationPageValidation : function(component, event, helper){
        console.log('---',component.find('new_info').find('formFields'));
        var allValid = component.find('new_info').find('formFields').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var requesterPhoneValid = [].concat(component.find('new_info').find('requesterPhone')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var deliveryPhoneValid = [].concat(component.find('new_info').find('deliveryPhone')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var industryRequired = component.find('new_info').find('picklistcmp').validateInputs();
        var agencyRequired = component.find('new_info').find('requestorSearch').validateCustomInput();
        var latCmp = component.find("new_info").find('mapLatitude').get("v.value");
        var longCmp = component.find("new_info").find('mapLongitude').get("v.value");
        /*var value = addressCmp.get("v.value");*/
        console.log('latCmp----',latCmp);
        console.log('longCmp----',longCmp);
        var addressValid = true;
        if ((latCmp == undefined || latCmp == '') && (longCmp == undefined || longCmp == '')) {
            addressValid = false;
        } else {
            addressValid = true;
        }

        if (addressValid && allValid && industryRequired && requesterPhoneValid && deliveryPhoneValid && agencyRequired) {
            return true;
        }
        else if(addressValid == false){
            helper.showErrorToast('Please select address from map','dismissible');
        }
        else {
            window.scrollTo(0,0);
            helper.showErrorToast('Please fill all required fields', 'dismissible');
        }
    },
    orderPageValidation : function(component, event, helper){
        var childComp = component.find('order_sheet');
        let isOrderValid = childComp.checkValidation();
        var allValid = childComp.find('formFields').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (isOrderValid && allValid) {
            return true;
        }else{
            window.scrollTo(0,0);
            helper.showErrorToast('Please fill all required fields', 'dismissible');
        }
    }
})