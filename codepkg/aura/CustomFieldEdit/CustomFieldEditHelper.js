({
	helperMethod : function() {
		
	},
	calculateFormula : function(component, formula, record) {
	    // currently added support only for two operators. todo - In future need to add for more
	    debugger;
	    if(formula == undefined || formula == '') return;
	    if(formula.indexOf('-') > -1) {
            let fields = formula.split('=');
            let fieldAPINames = fields[1].split('-');
            let firstFieldValue = record[fieldAPINames[0]];
            if(firstFieldValue == undefined) {
                firstFieldValue = 0;
            }
            let secondFieldValue = record[fieldAPINames[1]];
            if(secondFieldValue == undefined) {
                secondFieldValue = 0;
            }
            let value = firstFieldValue - secondFieldValue;
            if(value < 0) {
                value = 0;
            }
            record[fields[0]] = value
            component.get("v.record")[fields[0]] = value;
            component.set("v.record",  record);
        }

    },

    addField : function(component, event, helper) {
        var fieldAPIName = component.get("v.APIName");
        var fieldType = component.get("v.fieldType");
        var obj = component.get("v.record");
        console.log('fieldType---', fieldType);
        /*if(fieldType == 'STRING') {
            helper.addStringField(component, event, helper);
        } else if(fieldType == 'BOOLEAN') {
            helper.addBooleanField(component, event, helper);
        }  else if(fieldType == 'PICKLIST') {
            helper.addPicklistField(component, event, helper);
        }  else if(fieldType == 'DATETIME') {
            helper.addDateTimeField(component, event, helper);
        }  else */if(fieldType == 'DOUBLE') {
            helper.addDoubleField(component, event, helper);
        }/*  else if(fieldType == 'DATE') {
            helper.addDateField(component, event, helper);
        }else if(fieldType == 'CURRENCY') {
            helper.addCurrencyField(component, event, helper);
        }  else if(fieldType == 'NUMBER') {
             helper.addNumberField(component, event, helper);
         } else if(fieldType == 'TEXTAREA') {
            helper.addTextAreaField(component, event, helper);
        } else if(fieldType == 'FAX') {
             helper.addFaxField(component, event, helper);
         }*/

    },

    addDoubleField : function(component, event, helper) {
            var fieldAPIName = component.get("v.APIName");
            var noFormatting;// = field.noFormatting;
            if(noFormatting == undefined || noFormatting == null || noFormatting == '') {
                noFormatting = '0.01';
            }
            $A.createComponent(
                "lightning:input", {
                    value: component.getReference("v.record." + fieldAPIName),
                    label: '',
                    variant: 'label-hidden',
                    type: 'number',
                    //step: noFormatting,
                    required: component.getReference("v.isRequired"),
                    "onchange" : component.getReference("c.numberValueChange"),
                   autocomplete: 'off',
                   disabled: component.getReference("v.isDisabled"), 
                   "aura:id": "fieldId"
                },
                $A.getCallback(function(newCmp, status, error) {
                    if (status === "SUCCESS") {
                        var edits = component.get("v.body");
                        edits.push(newCmp);
                        component.set("v.body", edits);
                    }else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                    }else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                })
            );
        }

})