({
    doInit: function (component, event, helper) {
      var f42Id = component.get("v.recordId");
      var action = component.get("c.initialize");
      action.setParams({recId : f42Id});
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if(result !== 'Proceed'){
                component.set("v.infoMessage", result);
            }else{
                component.set("v.showApproval", true);
                component.set("v.errorMessage", '');
                component.set("v.infoMessage", '');
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
    proceed: function (component, event, helper) {
        component.set("v.errorMessage", '');
        component.set("v.infoMessage", '');
        var f42Id = component.get("v.recordId");
        var action = component.get("c.f42Approval");
        action.setParams({recId : f42Id,
                          status: component.get("v.approvalStatus"),
                          comment: component.get("v.comments")
                        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var result = response.getReturnValue();
              component.set("v.infoMessage", "Update Successful");
              $A.get('e.force:refreshView').fire();
              component.set("v.comments", '');
              component.set("v.approvalStatus", '');
              component.set("v.showApproval", false);
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
    
  });