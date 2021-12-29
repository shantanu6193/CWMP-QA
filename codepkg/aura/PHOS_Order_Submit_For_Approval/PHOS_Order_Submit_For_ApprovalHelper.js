/**
 * Created by Pankaj on 12-04-2020.
 */

({
    showErrorToast : function(message){
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": "Error!",
           "mode": 'sticky',
           "type": 'error',
           "message": message
       });
       toastEvent.fire();
    }
});