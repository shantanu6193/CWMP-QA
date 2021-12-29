({
    doInit : function(component, event, helper) {
        var recordTypeId = component.get( "v.pageReference").state.recordTypeId;

        /*var navService = component.find("navService");
        var pageRef = {
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Pre_Application__c",
                actionName: "new"
            },
            state: {
                nooverride: "1"
            }
        }
        navService.navigate(pageRef, true);*/

        let pageRef = component.get("v.pageReference");
        console.log('--pageRef--',JSON.stringify(pageRef));
        let pageRefObj = JSON.parse(JSON.stringify(pageRef));
        console.log('--pageRefObj--',JSON.stringify(pageRefObj));
        var navService = component.find("nav");
        var pageReference;

        if(pageRefObj.attributes.actionName == 'new'){
            pageReference = {
                type: "standard__objectPage",
                    attributes: {
                        objectApiName: "Pre_Application__c",
                        actionName: "new"
                    },
                state: {
                    nooverride: "1"
                }
            };
            var defaultFieldValues = {
                RecordTypeId : recordTypeId,
            };
            pageReference.state.defaultFieldValues = component.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
        }
        navService.navigate(pageRef, true);
    },
})