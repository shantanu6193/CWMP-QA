/**
 * Created by PREM on 30-04-2020.
 */

({
    doInit : function (component, event, helper){
        let orderItem = JSON.parse(JSON.stringify(component.get('v.orderItem')));
        console.log('orderItem----',orderItem);
        let apiName = component.get('v.apiName');
        //console.log('apiName-----',orderItem['Product2.Family']);
        let value = orderItem[apiName];
        console.log('value---',value);
        component.set('v.value',value);
    }
});