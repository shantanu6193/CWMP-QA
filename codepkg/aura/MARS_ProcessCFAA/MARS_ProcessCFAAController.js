({
    initialize : function(component) {
        component.set("v.errorMessage", '');
        component.set("v.infoMessage", '');
        var recId = component.get("v.recordId");
        var action = component.get("c.validateCFAAForSalarySurveys");
        action.setParams({
                         currentCFAAId: recId
                        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var result = response.getReturnValue();
              if(result === ''){
                component.set("v.showProceed", true);
              }else{
                component.set("v.errorMessage", result);
                component.set("v.showProceed", false);
              }
          } else if (state === "ERROR") {
            let errors = response.getError();
            let message = "Unknown error";
            if (errors && Array.isArray(errors) && errors.length > 0) {
              message = errors[0].message;
            }
            component.set("v.errorMessage", message);
          }
        });
        $A.enqueueAction(action);
    },

    proceed : function(component) {
        component.set("v.errorMessage", '');
        component.set("v.infoMessage", '');
        var recId = component.get("v.recordId");
        var action = component.get("c.ProceedCloneSalarySurvey");
        action.setParams({
                         currentCFAAId: recId
                        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var result = response.getReturnValue();
              component.set("v.infoMessage", result);
              component.set("v.showProceed", false);
          } else if (state === "ERROR") {
            let errors = response.getError();
            let message = "Unknown error";
            if (errors && Array.isArray(errors) && errors.length > 0) {
              message = errors[0].message;
            }
            component.set("v.errorMessage", message);
          }
        });
        $A.enqueueAction(action);
    },

})