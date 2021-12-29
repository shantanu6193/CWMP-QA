({
    doInit : function(component, event, helper) {

        let wireExecutor = new Date().getTime();
        var action = component.get("c.getCloseoutRequestStatus");
        action.setParams({ "closeoutRequestId" :  component.get("v.recordId")});
        action.setCallback(this, function(response) {              
            let getCloseoutRequestStatus = response.getReturnValue();
            
            if(getCloseoutRequestStatus != 'Pending SR Claim') {

                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",  
                    "message": "Closeout Reauest allready finalized"
                });
                toastEvent.fire();
                return;
            } else {
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }), 10
                );
                let urlEvent = $A.get("e.force:navigateToURL");
                let url = '/pa/s/new-closeout-request?id=' + component.get('v.recordId');
                urlEvent.setParams({
                                    "url": url
                    });
        
               //urlEvent.fire();
                
               window.open(url); 
            }
       
        })
            
        $A.enqueueAction(action);
     
    }
})