/**
 * Created by Chandrabhan on 2021-12-10.
 */

 ({
    doInit : function(component,helper) {
         var salarySurveyId = component.get("v.recordId");
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
             "url":"/apex/MARS_AgencySalarySurveyPDF?id="+salarySurveyId
         });
         urlEvent.fire();

        //$A.get("e.force:closeQuickAction").fire();
    }
});