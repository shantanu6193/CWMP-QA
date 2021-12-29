({
    doInit : function(component, event, helper) {
       console.log("Record Id", component.get("v.recordId") );
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: "c__ALS_TransmittalParent",
            },
            state: {
                c__refRecordId: component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        navService.navigate(pageReference);

    },
})