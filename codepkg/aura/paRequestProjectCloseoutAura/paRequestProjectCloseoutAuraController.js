({
    
    /*****************************************************************************
    * Method Name  : handleClose
    * Description  : This function is use to close the current Active Tab 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    handleClose : function(component, event, helper) {
        //close component tab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log('#OnTabClosed Error:',error);
        });
    },

    /*****************************************************************************
    * Method Name  : openCloseoutRequestTab
    * Description  : This function is used to open the current created closeout request 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
   
    openCloseoutRequestTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({           
            url: '/lightning/r/Closeout_Request__c/'+event.getParam('closeOutRequestId')+'/view',
            focus: true
        });
    },
})