/**
 * Created by hp on 2020-04-06.
 */

({
     setItemType: function(component, event, helper){
       var family = component.find('family').get('v.value');
       if(family == undefined){
           family = component.get("v.orderItem.Product__r.Family");
       }
       if(family == undefined){
           family = component.get("v.productObj.Family");//IF record not saved
       }
       let products = component.get("v.products");
       let itemTypeList = [];
       for(let i = 0 ; i < products.length ; i++){
         if(products[i].Family == family){
           itemTypeList.push(products[i]);
         }
       }
       console.log('itemTypeList= '+itemTypeList);
       component.set("v.itemTypeProducts", itemTypeList);
     }
});