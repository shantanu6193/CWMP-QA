/**
 * Created by Prem Pal on 21-04-2020.
 */

({
     doInit : function(component, event, helper) {
        let fieldName = component.get('v.fieldName');
        let sObjectName = component.get('v.sObjectName');
        let recordId = component.get("v.recordId");
        let pathId =recordId+'-path';
        component.set('v.pathId',pathId);
        let pathContainer= recordId+'-path-container';
        component.set('v.pathContainer',pathContainer);
        let subStepsId= recordId+'-subSteps';
        component.set('v.subStepsId',subStepsId);
        let ul_oId = recordId+'-ul_o';
        component.set('v.ul_oId',ul_oId);
        let tooltipId = recordId+'-tooltip';
        component.set('v.tooltipId',tooltipId);
		let action = component.get("c.getInitData");
		action.setParams({
		    "sObjectName":sObjectName,
		    "fieldName" : fieldName,
		    "recordId" : recordId
		});
		action.setCallback(this, function(response) {
		   let state = response.getState();
		    if(state == 'SUCCESS') {
		        let returnMap = response.getReturnValue();
		        let fieldName = component.get('v.fieldName');
                let currentValue = returnMap.Record[fieldName];
                helper.getStepJSON(component, event, helper,currentValue);
		        let currentSubStep = component.get('v.currentSubStep');
		        component.set('v.updatedSubStep',currentSubStep);
		        let currentStep = component.get('v.currentStep');
                component.set('v.updatedStep',currentStep);
                if(returnMap.CommunityUser == true)
                component.set('v.hideFromCommunityUser',false);
		    } else {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Information!",
                            "mode": 'sticky',
                            "type": 'info',
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
		    }
		    window.addEventListener('resize', $A.getCallback(function(){
                if(component.isValid()) {
                    let items = document.getElementById("ul_o").getElementsByTagName("li");
                    for(let i=0; i<items.length; i++) {
                        if(items[i].className.includes('slds-is-active')) {
                            helper.setPopoverPointer(component, event, helper, i);
                        }
                    }
                }
            }));
		});
		$A.enqueueAction(action);
     },
     
     doneRendering: function(component, event, helper) {
         try{
             if(!component.get("v.isDoneRendering")){
                if(document.getElementById("ul_o") != null){
                    let items = document.getElementById("ul_o").getElementsByTagName("li");
                    for(let i=0; i<items.length; i++) {
                        if(items[i].className.includes('slds-is-active')) {
                            helper.setPopoverPointer(component, event, helper, i);
                            let steps = component.get('v.steps');
                            let currentStep = steps[i];
                            if(currentStep != undefined ){
                                if(currentStep.SubStepList != undefined){
                                    let subSteps = currentStep.SubStepList;
                                    component.set('v.subSteps',subSteps);
                                } else {
                                    component.set('v.subSteps',[]);
                                }
                            }   
                            component.set("v.isDoneRendering", true);
                        }
                    }
                }
            }
         }
         catch(e) {
             console.log(e);
         }
     },

     getCurrentStepSubSteps : function(component, event, helper) {
        let index = event.currentTarget.id;
        let steps = component.get('v.steps');
        let currentStep = steps[index];
        let subSteps = currentStep.SubStepList;
        component.set('v.subSteps',subSteps);
        if(subSteps.length == 0){
            component.set('v.showSubSteps',false);
            helper.getStepJSON(component, event, helper,currentStep.Name);
        }else{
            component.set('v.showSubSteps',true);
            helper.setPopoverPointer(component, event, helper, index);
        }
     },

     setCurrentStep : function(component, event, helper) {
        try{
		let index = event.currentTarget.id;
		let subSteps = component.get('v.subSteps');
		let updatedSubStep = subSteps[index];
		component.set('v.updatedSubStep',updatedSubStep);
		let parentIndex = updatedSubStep.ParentIndex;
		helper.getStepJSON(component, event, helper,updatedSubStep.Name);
		let steps = component.get('v.steps');
        let currentStep = steps[parentIndex];
        let currenStepSubSteps = currentStep.SubStepList;
        component.set('v.subSteps',currenStepSubSteps);
        setTimeout(function(){
            helper.setPopoverPointer(component, event, helper, parentIndex);
        },200);
        }
        catch(e) {
            console.log(e);
        }
     }, 

     updateRecordWithNewStep : function(component, event, helper) {
        component.set('v.showLoader',true);
        let fieldName = component.get('v.fieldName');
        let sObjectName = component.get('v.sObjectName');
        let recordId = component.get("v.recordId");
        let updatedSubStep = component.get("v.updatedSubStep");
        let action = component.get("c.updateRecord");
        action.setParams({
            "sObjectName":sObjectName,
            "fieldName" : fieldName,
            "recordId" : recordId,
            "updatedValue" :updatedSubStep.Name
        });
        action.setCallback(this, function(response) {
           let state = response.getState();
            if(state == 'SUCCESS') {
                let returnMap = response.getReturnValue();
                let fieldName = component.get('v.fieldName');
                let currentValue = returnMap.Record[fieldName];
                helper.getStepJSON(component, event, helper,currentValue);
                let currentSubStep = component.get('v.currentSubStep');
                component.set('v.updatedSubStep',currentSubStep);
                let currentStep = component.get('v.currentStep');
                component.set('v.updatedStep',currentStep);
				$A.get('e.force:refreshView').fire();
				component.set('v.showLoader',false);
            } else {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Information!",
                            "mode": 'sticky',
                            "type": 'info',
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
     }
});