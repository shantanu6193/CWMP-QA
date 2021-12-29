({
    doInit : function(component,helper) {
         var agreementId = component.get("v.recordId");
         let action = component.get("c.getStatus");
         action.setParams({
             'agreementId' : agreementId
         });
         action.setCallback(this, function(response) {
            let state = response.getState();
             if(state == 'SUCCESS') {
                let statusValue = response.getReturnValue();
                let vfPageName = '';
                if(statusValue == 'Approved' || statusValue == 'Expired') {
                    vfPageName = '/apex/MARS_ApprovedAgreementPDF?id='+agreementId;
                }else if(statusValue == 'Rejected') {
                    vfPageName = '/apex/MARS_DeniedAgreementPDF?id='+agreementId;
                }
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    'url':vfPageName
                });
                urlEvent.fire();
            }
        }),
    $A.enqueueAction(action);   
    } 
});