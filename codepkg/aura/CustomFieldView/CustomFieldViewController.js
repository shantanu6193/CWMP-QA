({
    doInit : function(component, event, helper){
        //debugger;Commented by Prem, please use console.log instead
        /*console.log('fieldLabel-----',component.get('v.fieldLabel'));
        let orderItem = JSON.stringify(component.get('v.orderItem'));
        component.set('v.orderItem',parse);*/
        let orderItem = JSON.parse(JSON.stringify(component.get('v.orderItem')));
        let apiName = component.get('v.apiName');
        let value = orderItem[apiName];
        console.log('value---',value);
        component.set('v.value',value);
    }
});