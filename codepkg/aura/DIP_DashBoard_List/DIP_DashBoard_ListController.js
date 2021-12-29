/**
 * Created by Neha on 09-04-2020.
 */

({

    doInit : function(component, event, helper) {
    let action = component.get("c.getImportantBoards");
           action.setCallback(this, function(response){
           var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response----',response.getReturnValue());
                let dashBoardList = response.getReturnValue().dashBoardConfigs;
                component.set('v.dashBoardsList', dashBoardList);
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "ERROR!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
            if($A.get("e.force:closeQuickAction")!=undefined && $A.get("e.force:closeQuickAction")!=null){
            $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	}
});