/**
 * Created by hp on 2020-04-06.
 */

({
    doInit: function(component, event, helper){

    },
    submitForApproval: function(component, event, helper){

        let recordId = component.get("v.recordId");
        if(!$A.util.isEmpty(recordId)) {
            let action = component.get("c.submitForRDMSHApprovalRequest");
            action.setParams({
                "orderId" : recordId,
                "comment" : component.get("v.comments")
            });
            action.setCallback(this, function(response) {
               let state = response.getState();
                if(state == 'SUCCESS') {
                    var navLink = component.find("navLink");
                   var pageRef = {
                       type: 'standard__recordPage',
                       attributes: {
                           actionName: 'view',
                           objectApiName: 'Order__c',
                           recordId : recordId // change record id.
                       },
                   };
                   navLink.navigate(pageRef, true);
                   
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Success!",
                       "mode": 'sticky',
                       "type": 'success',
                       "message": "Order Submitted Successfully for Approval Process."
                   });
                   toastEvent.fire();
                } else {
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                        if(message == undefined) {
                            message = errors[0].message;
                        }
                    }

                    // Display the message
                    helper.showErrorToast(message);
                }
            });
            $A.enqueueAction(action);
        }
    }
});