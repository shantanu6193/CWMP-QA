/**
 * Created by StackNexus Admin on 03-09-2021.
 */

({
    doInit : function(component, event, helper) {
        window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }), 1000
                );
        let recordId = component.get("v.recordId");
        let urlEvent = $A.get("e.force:navigateToURL");
                let url = '/hh-application-preview?id=' + component.get('v.recordId');
                console.log(url);
                urlEvent.setParams({
                "url": url
                });
                urlEvent.fire();
    }
});