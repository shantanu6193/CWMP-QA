({
    doInit : function(component,helper) {
         var nonSuppressionId = component.get("v.recordId");
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
             "url":"/apex/MARS_NonSuppressionPDF?id="+nonSuppressionId
         });
         urlEvent.fire();

        //$A.get("e.force:closeQuickAction").fire();
    }
});