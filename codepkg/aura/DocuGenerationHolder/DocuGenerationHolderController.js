({
    doInit:function(component, event, helper) {
        component.set("v.recId",component.get("v.recordId"));
    },

    generatePDF : function(component, event, helper) {
       var pdfUrl =  event.getParam('iframeVal');
       var workspaceAPI = component.find("workspace");
       workspaceAPI.openTab({
          url :   pdfUrl ,
       }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});  
       }) 
       .catch(function(error) {
            console.log(error);
       });  
    }
})