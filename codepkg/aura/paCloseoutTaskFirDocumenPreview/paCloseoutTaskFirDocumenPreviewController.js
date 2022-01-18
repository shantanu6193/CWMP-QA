({

     /*****************************************************************************
    * Method Name  : doInit
    * Description  : This function is used to open tab
    * Author       : Dayal
    * Created On   : 27/12/2021
    * Modification Log: 
    *******************************************************************************/ 
    doInit : function(component, event, helper) {       
       
        if(component.get("v.SignFirContentDocumentIdDetails") == null || component.get("v.SignFirContentDocumentIdDetails") == undefined){
            component.set("v.isSignFirDocumentUrl" , false);
        }

        if(component.get("v.FirContentDocumentIdDetails") == null || component.get("v.FirContentDocumentIdDetails") == undefined){
           
            component.set("v.isFirDocumentUrl" , false);
        }          
    },

     /*****************************************************************************
    * Method Name  : handleSignedFirDocument
    * Description  : This function is used to open subtab SignedFIRDocument
    * Author       : Dayal
    * Created On   : 27/12/2021
    * Modification Log: 
    *******************************************************************************/
    handleSignedFirDocument : function(component, event, helper) {

       /* var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({           
            url: component.get("v.SignedFIRDocument"),
            focus: true
        }); */  
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                url: component.get("v.SignedFIRDocument"),
                focus: true
            }); 
        })
     
    },

      /*****************************************************************************
    * Method Name  : handleFirDocument
    * Description  : This function is used to open subtab FIRDocument
    * Author       : Dayal
    * Created On   : 27/12/2021
    * Modification Log: 
    *******************************************************************************/
    handleFirDocument : function(component, event, helper) {
        
        /*var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({           
            url: component.get("v.FIRDocument"),
            focus: true
        });*/

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                url: component.get("v.FIRDocument"),
                focus: true
            }); 
        })
     
    }
})