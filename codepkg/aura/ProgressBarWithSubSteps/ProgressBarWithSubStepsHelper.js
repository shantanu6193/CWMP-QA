/**
 * Created by Prem Pal on 21-04-2020.
 */

({
    getStepJSON: function(component, event, helper,currentValue){
        let stepsJSONString = component.get('v.groupingJSON');
        let steps = component.get('v.steps');
        steps = [];
        let stepsJSON = JSON.parse(stepsJSONString);
		let valueFound = false;
		for(let i = 0 ; i < stepsJSON.length ; i++){
			let stepItemSet = false;
			let stepItem = stepsJSON[i];
			let groupName = (Object.keys(stepItem))[0];
			let groupValues = stepItem[groupName];

			let subStepItemObjectList = [];
			let stepItemObject = {
		                            "Name":groupName,
		                            "SubStepList":subStepItemObjectList,
		                            "Active":  false,
		                            "Complete":  false,
		                            "Index":i
		                        };
            if(groupValues.length == 0) {
                if(groupName == currentValue){
                    stepItemObject.Active = true;
                    let json = {
                                    "Active" : true,
                                    "Class" : "slds-path__item slds-is-current slds-is-active parent-steps",
                                    "Complete": true,
                                    "Name": groupName,
                                    "ParentIndex": i
                                }
                    component.set('v.updatedSubStep',json);
                    component.set('v.currentSubStep',json);
                    valueFound = true;
                }else {
                    if(valueFound == false){
                        stepItemObject.Active = false;
                        stepItemObject.Complete = true;
                    } else if(valueFound == true){
                        stepItemObject.Active = false;
                        stepItemObject.Complete = false;
                    }
                }
            }
			for(let j = 0 ; j < groupValues.length ; j++){
			    let subStepItemObject = {"Name":groupValues[j],"Active":false,"Complete":false,"Index":j,"ParentIndex":i};

			    if(currentValue == groupValues[j]){
			        valueFound = true;
			        subStepItemObject.Active = true;
                    subStepItemObject.Complete = false;

                    stepItemObject.Active = true;
                    stepItemObject.Complete = false;
                    stepItemSet = true;
			    }else{
			        if(valueFound){
			            subStepItemObject.Active = false;
                        subStepItemObject.Complete = false;

						if(stepItemSet == false){
						    stepItemObject.Active = false;
                            stepItemObject.Complete = false;
                        }

                    }else{
                        subStepItemObject.Active = false;
                        subStepItemObject.Complete = true;

						if(stepItemSet == false){
						    stepItemObject.Active = false;
                            stepItemObject.Complete = true;
                        }

                    }
                }

                if(subStepItemObject.Complete == false){
                    if(subStepItemObject.Active == true){
                        subStepItemObject.Class = 'slds-path__item slds-is-current slds-is-active';
                        component.set('v.currentSubStep',subStepItemObject);
                    }else{
                        subStepItemObject.Class = 'slds-path__item slds-is-incomplete';
                    }
                }else{
                    subStepItemObject.Class = 'slds-path__item slds-is-complete';
                }

				subStepItemObjectList.push(subStepItemObject);
			}
			if(stepItemObject.Complete == false){
			    if(stepItemObject.Active == true){
			        stepItemObject.Class = 'slds-path__item slds-is-current slds-is-active parent-steps';
			        component.set('v.currentStep',stepItemObject);
                }else{
                    stepItemObject.Class = 'slds-path__item slds-is-incomplete parent-steps';
                }
            }else{
                stepItemObject.Class = 'slds-path__item slds-is-complete parent-steps';
            }
            steps.push(stepItemObject);
        }
        component.set('v.steps',steps);
    },
    setPopoverPointer: function(component, event, helper, index) {
        try{
            setTimeout(function(){   
                let recordId = component.get('v.recordId');
                let pathId = recordId+'-path';
                let width = document.getElementById(pathId).clientWidth;
                let subStepsId = recordId+'-subSteps'; 
                if(document.getElementById(subStepsId) != null)
                    document.getElementById(subStepsId).style.width = width + 'px';

                let pathContainer = recordId+'-path-container';
                let parentWidth = document.getElementById(pathContainer).clientWidth;
                let ul_oId= recordId+'-ul_o';
                let numberOfItems = document.getElementById(ul_oId).getElementsByTagName("li").length;
                let widthOfListItem = (parentWidth / numberOfItems);
                let pointerLeft = (widthOfListItem/2) + (widthOfListItem * (index));
                var styleElem = document.head.appendChild(document.createElement("style"));
                let tooltipId = recordId+'-tooltip';
                styleElem.innerHTML = "#"+tooltipId+":after {left:"+ pointerLeft + "px;}";
            },200);

        }
        catch(e) {
            console.log('setPopoverPointer----->'+e);
        }
    }
});