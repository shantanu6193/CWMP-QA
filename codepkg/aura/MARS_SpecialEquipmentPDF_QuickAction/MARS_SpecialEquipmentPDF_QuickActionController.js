({
    doInit : function(component,helper) {
         var specialEquipId = component.get("v.recordId");
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
             "url":"/apex/MARS_SpecialEquipment_PDF?id="+specialEquipId
         });
         urlEvent.fire();
    }
});