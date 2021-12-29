({
    doInit : function(component,helper) {
         var adminRateId = component.get("v.recordId");
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
             "url":"/apex/MARS_AdministrativeRate_PDF?id="+adminRateId
         });
         urlEvent.fire();
    }
});