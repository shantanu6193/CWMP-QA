({
    doInit:function(component, event, helper) {
        console.log('#Aura Init...');
        component.set("v.recId",component.get("v.recordId"));
    },

    sendForDocuSign : function(component, event, helper) {
       var url =  event.getParam('url');
       console.log('#url From Aura :',url);
       var workspaceAPI = component.find("workspace");
       workspaceAPI.openTab({
           url :   url 
       }).then(function(response) {
               workspaceAPI.focusTab({tabId : response});  
       })
       .catch(function(error) {
               console.log('#Aura Error :',error);
       });
       
       /* 
       //Create Document object
        var action = component.get("c.generateDocument");
        action.setParams({ "recordId" :  component.get("v.recordId")});
        action.setCallback(this, function(response) {    
            console.log('#response.getState():',response.getState());
            console.log('#response.getReturnValue()',response.getReturnValue());
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openTab({
                url :   url 
            }).then(function(response) {
                    workspaceAPI.focusTab({tabId : response});  
            })
            .catch(function(error) {
                    console.log('#Aura Error :',error);
            });  
        })
        $A.enqueueAction(action);
        */

    }
})