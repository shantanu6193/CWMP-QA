/**
 * Created by Admin on 13-05-2020.
 */

({
        getData : function(component, event, helper) {
            let action = component.get("c.getSupportResources");
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    //debugger;
                    console.log('response----',response.getReturnValue());
                    let SupportResources = response.getReturnValue().SupportResources;
                    component.set('v.SupportResources', SupportResources);
                    component.set("v.sessionId", response.getReturnValue().sessionId);
                    helper.subScribeRefreshComponent(component, event, helper);
                }
                else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "ERROR!",
                        "message": "An Error has occured. Please try again or contact System Administrator."
                    });
                    toastEvent.fire();
                }
                //component.set("v.showSpinner",false);
                if($A.get("e.force:closeQuickAction")!=undefined && $A.get("e.force:closeQuickAction")!=null){
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        },

        subScribeRefreshComponent : function(component, event, helper){

                var sessionId = component.get("v.sessionId");
                    try{
                        var cometd = new window.org.cometd.CometD();
                        cometd.configure({
                                        url: window.location.protocol + '//' + window.location.hostname + '/cometd/41.0/',
                                        requestHeaders: { Authorization: 'OAuth ' + sessionId},
                                        appendMessageTypeToURL : false
                                    });
                        cometd.websocketEnabled = false;
                        // Connect to
                        cometd.handshake($A.getCallback(function(status) {
                            if (status.successful) {
                                var eventName = "/event/Update_Support_Resource__e";
                                var subscription =
                                    cometd.subscribe(eventName, $A.getCallback(function(message) {

                                        helper.getData(component, event, helper);
                                    }
                                ));
                            } else {
                                // TODO: Throw an event / set error property here?
                                console.error('streaming component: ' + status);
                            }
                        }));

                    }catch(err){
                      console.log('---erroor in connection'+err);
                    }

            }
});