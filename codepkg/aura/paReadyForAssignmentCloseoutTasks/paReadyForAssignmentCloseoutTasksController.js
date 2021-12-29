/**
 * Created by hp on 23-06-2021.
 */

({
    doInit : function(component, event, helper) {
        var action = component.get("c.getCloseOutTaskDetails");
        action.setParams({ "closeOutTaskId" :  component.get("v.recordId")});
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                $A.get('e.force:refreshView').fire();
                toastEvent.setParams({
                "title": "Success!",
                "type" : "success",
                "message": "Record Updated Successfully"
            });
            toastEvent.fire();
            return;
        });
        $A.enqueueAction(action);
    }
});