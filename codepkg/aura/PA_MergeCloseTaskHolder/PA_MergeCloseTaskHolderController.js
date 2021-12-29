({
    doInit: function(component, event, helper) {
        var action = component.get("c.getSalesforceCustomBaseURL");
        action.setCallback(this, function(response) {
            console.log(response.getState());
            console.log(response.getReturnValue());
            component.set("v.sbaseUrl", response.getReturnValue());
        });
        $A.enqueueAction(action);
        var id = component.get("v.pageReference").state.c__recordId;
        component.set("v.isLoaded", true);
        component.set("v.recId", id);
       // $A.get('e.force:refreshView').fire();
    },

    onTabClosed : function(component, event, helper) {
        var tabTitleToDelete = event.getParam('value'); // Change this to the title string you want to delete...NOTE: this seems bad, it might be better to work on a dynamic way to do this, but this was your ask... 
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
           
        })
        .catch(function(error) {
            console.log(error);
        });
        
        // Close Delete Record Tab...
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log(JSON.parse(JSON.stringify(response))); // this will give you a better debug log.
            
            for(var i = 0; i < response.length; i++) {
                var tabTitle = response[i].title; // title of the tab - usually the record "Name" field, if this is a "customTitle..."
                var customTitle = response[i].customTitle; // use this title if you have given a title to the tabs that you are wanting to close
                var tabId = response[i].tabId; // this is the id you'll need to call the closeTab function

                // You can add more customizations to this, like checking if this is a parent tab, or a subtab, or if it's focused, then not to close it
                // just use response[i].attributeName in your 'response' to figure this out.
                if(tabTitle === tabTitleToDelete) {
                    workspaceAPI.closeTab({tabId: tabId});
                    workspaceAPI.openTab({
                        url: component.get("v.sbaseUrl")+''+component.get("v.recId") +"/view" ,
                       
                    }).then(function(response) {
                        workspaceAPI.focusTab({tabId : response});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                   
                    break;
                }
            }

        })
        .catch(function(error) {
            console.log(error);
        });
    },
})