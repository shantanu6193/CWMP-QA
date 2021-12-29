/**
 * Created by Pankaj on 06-04-2020.
 */

({
    doInit : function(component, event, helper) {
        // if hasrecord is present means it is override action then just redirect to detail page else show edit component
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1000
        );
        let urlEvent = $A.get("e.force:navigateToURL");
        let url = '/edit-order?id=' + component.get('v.recordId');
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    }
});