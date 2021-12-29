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
    * Method Name  : openCloseoutTaskTab
    * Description  : This function is used to open the current created closeout Task 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
   
    openCloseoutTaskTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({           
            url: '/lightning/r/Closeout_Task__c/'+event.getParam('closeoutTaskId')+'/view',
            focus: true
        });
    },
    
})