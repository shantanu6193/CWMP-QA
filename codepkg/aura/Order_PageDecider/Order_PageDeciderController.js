/**
 * Created by Prem Pal on 17-04-2020.
 */

({
    doInit : function(component, event, helper) {
        debugger;
        let pageRef = component.get("v.pageReference");
        console.log('--pageRef--',JSON.stringify(pageRef));
        let pageRefObj = JSON.parse(JSON.stringify(pageRef));
        console.log('--pageRefObj--',JSON.stringify(pageRefObj));
        let url = window.location.href;
        console.log('--url--',url);
        let oppId;
        if(url != undefined){

            let index = url.indexOf("006");
            oppId = url.substr(index,18);
        }
        console.log('--oppId--',oppId);
		if(oppId.length != 18){
		    oppId = null;
        }
		console.log('--oppId--',oppId);
        component.set("v.isOverride",false);
        let action = component.get("c.getInitData");
        action.setParams({
            "oppId" : oppId
        });
        action.setCallback(this, function(response) {
           let state = response.getState();
            if(state == 'SUCCESS') {
                let returnMap = response.getReturnValue();
                console.log('--returnMap--',returnMap);
                if(returnMap.CurrentAppName == 'Cal_OES_Donation_Intake_Portal' || returnMap.CurrentAppName == 'Cal_OES_Bulk_Procurement_Process'){
					var navService = component.find("nav");
					var pageReference;

					if(pageRefObj.attributes.actionName == 'new'){
				        pageReference = {
                            type: "standard__objectPage",
                            attributes: pageRefObj.attributes,
                            state: {
                                nooverride: "1"
                            }
                        };
					    var defaultFieldValues = {
                            RecordTypeId : returnMap.Bulk_Procurement_RecordTypeId,
                        };
                        if(oppId != null){
                            defaultFieldValues.Opportunity__c = oppId;
                            defaultFieldValues.Account__c = returnMap.AccountId
                        }
                        pageReference.state.defaultFieldValues = component.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
                    }else if(pageRefObj.attributes.actionName == 'edit'){
                        pageReference = {
                            type: "standard__recordPage",
                            attributes: pageRefObj.attributes,
                            state: {
                                nooverride: "1"
                            }
                        };
                    }

                    component.set("v.pageReference", pageReference);
					console.log('--pageReference--',pageReference);
					navService.navigate(pageReference, true);

                }else{
                    $A.createComponent(
                        "c:PHOS_Order_Edit",
                        {
                            "aura:id": "findableAuraId",
                            "editRecordId": component.get("v.recordId")
                        },
                        function(componentObj, status, errorMessage){
                            //Add the new button to the body array
                            if (status === "SUCCESS") {
                                var body = component.get("v.body");
                                body.push(componentObj);
                                component.set("v.body", body);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                                // Show offline error
                            }
                            else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                                // Show error message
                            }
                        }
                    );
					//component.set("v.isOverride",true);
                }
            } else {
                let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error!",
					"mode": 'sticky',
					"type": 'error',
					"message": message
				});
				toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
});