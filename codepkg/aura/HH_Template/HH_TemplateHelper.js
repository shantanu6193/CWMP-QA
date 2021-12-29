({
    getUserName: function (component, event, helper) {
        var action = component.get("c.getUserName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                console.log('username: ',response);
                let returnValue = response.getReturnValue();
                component.set('v.userName', returnValue['userName']);
                component.set('v.isNotHomeOwner', returnValue['isNotHomeOwner']);
            } else {
                component.set('v.userName','');
            }
        });
        $A.enqueueAction(action);
    }
})