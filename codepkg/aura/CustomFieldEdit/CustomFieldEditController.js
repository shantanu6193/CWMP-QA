({
	doInit : function(component, event, helper) {
	    helper.addField(component, event, helper);
		var record = component.get("v.record");
        if(record[component.get("v.APIName")]) {
            var fieldValueRef = component.getReference("v.record." + component.get("v.APIName"));
            component.set("v.fieldValue", fieldValueRef);
        }
	},
    fieldValueChange : function(component, event, helper) {
       component.get("v.record")[component.get("v.APIName")]= component.get("v.fieldValue");
    },
    numberValueChange : function(component, event, helper) {
        var onChangeFormula = component.get("v.onChangeFormula");
       helper.calculateFormula(component, onChangeFormula, component.get("v.record"));
    }
})