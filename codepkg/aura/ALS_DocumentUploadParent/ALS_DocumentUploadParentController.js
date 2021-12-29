({
    doInit : function(component, event, helper) {
        component.set('v.projectId',component.get("v.recordId"));
    },

    onTabRefreshed : function(component, event, helper) {
        console.log("Tab Refreshed");
       // how to call a child method(LWC) from parent(Aura) ????

       //var callToRefesh = component.find('tabRefreshed');
      // callToRefesh.onTabRefreshed();   
      
      component.find('alsDocumentUpload').onTabRefreshed();
    }

})