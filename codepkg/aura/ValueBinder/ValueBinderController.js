/**
 * Created by Prem Pal on 30-03-2020.
 */

({
    doInit : function(component, event, helper) {
        try{
            let record = component.get('v.record');
            let key = component.get('v.key');
            let field = component.get('v.field');
            console.log('record---', JSON.stringify(record));
            console.log('key---', key);
            console.log('field---', field);
            component.set('v.value',record[key][field]);
        }
        catch(e){
            console.log(e);
        }
    }
});