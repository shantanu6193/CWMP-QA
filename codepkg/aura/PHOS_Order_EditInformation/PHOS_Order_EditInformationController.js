/**
 * Created by Prem Pal on 30-03-2020.
 */

({
    getIndustryValue: function(component, event, helper) {
        component.set("v.orderRec.Industry__c",event.getParam('industry'));
    },
    getSubIndustryValue: function(component, event, helper) {
        component.set("v.orderRec.Sub_Industry__c",event.getParam('subIndustry'));
    },

    doInit : function(component, event, helper) {
		component.set('v.isLoading',true);
        console.log('order-----',JSON.stringify(component.get('v.orderRec')));
        //if(component.get('v.orderRec.Incident_Name__c') == undefined || component.get('v.orderRec.Incident_Name__c') == null) {
        //    component.set('v.orderRec.Incident_Name__c', "COVID-19");
        //}
        /*if(component.get('v.orderRec.Shipping_State__c') == undefined) {
            component.set('v.orderRec.Shipping_State__c', "CA");
        }*/
        let orderRec = component.get('v.orderRec');
        let address = [orderRec.Shipping_Street__c, orderRec.Shipping_Street_2__c, orderRec.Shipping_City__c, orderRec.Shipping_State__c, orderRec.Shipping_Country__c, orderRec.Shipping_ZipPostal_Code__c].filter(Boolean).join(", ");
        component.set('v.address',address);
        helper.getPriorityOfRequestOptions(component, event, helper);
        helper.getStatecodeOptions(component, event, helper);
        helper.getCountyOptions(component, event, helper);
        helper.getIncidentOptions(component, event, helper);
        helper.getEntityTypeOptions(component, event, helper);
        if(orderRec.Account__r != undefined) {
            component.set('v.entityType',orderRec.Account__r.Entity_Type__c);
        }
        let action = component.get("c.getRecipientContact");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state == 'SUCCESS') {
                let contact = response.getReturnValue().contact;
                let user = response.getReturnValue().user;
                let communityUser = response.getReturnValue().IsCommunityUser;
                component.set('v.isCommunityUser',communityUser);
                //component.set('v.orderRec.Requestor__r', contact);
                if(contact != undefined) {
                    if(contact.Account.Entity_Type__c == 'Health Care Facility') {
                        component.set('v.isHealthCareUser',true);
                    }
                    //Call below code only if new order is creating
                    if(orderRec.Requestor_Last_Name_Text__c == undefined){
                        component.set("v.orderRec.Requestor_First_Name_Text__c", contact.FirstName);
                        component.set("v.orderRec.Requestor_Last_Name_Text__c", contact.LastName);
                        component.set("v.orderRec.Requestor_Agency_Text__c", contact.Account.Name);
                        component.set("v.orderRec.Requestor_Email_Text__c", contact.Email);
                        component.set("v.orderRec.Requestor_Phone_Text__c", contact.Phone);
                        component.set("v.orderRec.Requestor_Title_Text__c", contact.Title);
                        if(contact.Account != undefined && contact.Account.Entity_Type__c != undefined) {
                            component.set('v.entityType',contact.Account.Entity_Type__c);
                        }
                        if(contact.Account != undefined && contact.Account.Entity_Type__c == 'County'){
                            component.set("v.orderRec.County__c", contact.Account.Name);
                        }
                        if(contact.Account != undefined && contact.Account.Parent != undefined && contact.Account.Parent.Entity_Type__c == 'County'){  
                            component.set("v.orderRec.County__c", contact.Account.Parent.Name);
                        }
                        if(contact.Account != undefined && contact.Account.Parent != undefined && contact.Account.Parent.Entity_Type__c == 'County'){  
                            component.set("v.orderRec.County__c", contact.Account.Parent.Name);
                        }
                        if(contact.Account != undefined && contact.Account.Entity_Type__c == 'State Agency'){
                            component.set("v.orderRec.County__c", contact.Account.Entity_Type__c);
                        }
                        if(contact.Account != undefined && contact.Account.Entity_Type__c == 'Non-Governmental Entity'){
                            component.set("v.orderRec.County__c", contact.Account.Entity_Type__c);
                        }
                       
                    }
                    // Comment on 26-08-2020 by Chandrabhan
                    if(contact.Account != undefined && contact.Account.Entity_Type__c == 'County'){
                        component.set("v.isOperationalArea", true); 
                        //component.find('county').set('v.disabled',true);
                    }
                     //Added  on 26-08-2020 by Chandrabhan for disable county & Requested Agency in case Hospital
                    if(contact.Account != undefined && contact.Account.Parent != undefined && contact.Account.Parent.Entity_Type__c == 'County'){ 
                        component.set("v.isRequesterAgency", true); 
                        component.set("v.isOperationalArea", true); 
                    }
                    if(contact.Account != undefined && contact.Account.Entity_Type__c == 'State Agency'){
                        component.set("v.isOperationalArea", true);
                    }
                    if(contact.Account != undefined && contact.Account.Entity_Type__c == 'Non-Governmental Entity'){
                        component.set("v.isOperationalArea", true);
                    }
                    if(contact.Account != undefined && (contact.Account.Entity_Type__c == 'County' || contact.Account.Entity_Type__c == 'Region')){
                        component.set("v.isRequestorAgencyDisabled", false);
                    }
                    console.log('orderRec-----',component.get('v.orderRec'));
                   
                }
                else {
                    component.set("v.isRequestorAgencyDisabled", false);
                }

                } else {
                    //alert('ERROR while getting contact');
                }
                component.set('v.isLoading',false);
            });
            $A.enqueueAction(action);
        }, 
     updateDeliveryInfo : function(component, event, helper) {
            let checked = component.get("v.asAsAbove");
            if(checked == false) return;
            let orderRec = component.get('v.orderRec');
            orderRec.Delivery_Recipient_First_Name_Text__c = orderRec.Requestor_First_Name_Text__c;
            orderRec.Delivery_Recipient_Last_Name_Text__c = orderRec.Requestor_Last_Name_Text__c;
            orderRec.Delivery_Recipient_Title_Text__c = orderRec.Requestor_Title_Text__c;
            orderRec.Delivery_Recipient_Email_Text__c = orderRec.Requestor_Email_Text__c;
            orderRec.Delivery_Recipient_Phone_Text__c = orderRec.Requestor_Phone_Text__c;
            component.set("v.orderRec", orderRec);
     },
     requesterPhoneValidation : function(component, event, helper){
         let number = component.find("requesterPhone").get("v.value");
         var inputCmp = component.find("requesterPhone");
         helper.phoneValidation(component, event, helper, number, 'Requester Phone', inputCmp);
     },
     deliveryPhoneValidation : function(component, event, helper){
         let number = component.find("deliveryPhone").get("v.value");
         var inputCmp = component.find("deliveryPhone");
         helper.phoneValidation(component, event, helper, number, 'Delivery Recipient Phone', inputCmp);
     },
     updateIncident: function(component, event, helper) {
        var incidentValues = component.get("v.incidentOptions");
        var  value = event.getSource().get("v.value");
        for(var i=0;i<incidentValues.length;i++){
            if(value == incidentValues[i].value){
                component.set("v.orderRec.Incident_Name__c",incidentValues[i].label);
            }
        }
    },
    entityTypeChange : function(component, event, helper) {
        let value = event.getSource().get("v.value");
        component.set('v.entityType',value);
    },
    getRequestorAgency: function(component, event, helper) {
        let agencyRec = event.getParam('agencyData');
        console.log('agencyRec',agencyRec);
        component.set("v.orderRec.Requestor_Agency_Text__c", agencyRec.Name);
        component.set("v.orderRec.Account__c", agencyRec.Id);
        console.log('values--------->',agencyRec.Name + '-----' + agencyRec.Id);
    },
	handleAddressSelection: function(component, event, helper){
        debugger;
        try{
            console.log('address-selected');
            let address = event.getParam('address');
            console.log('address----',JSON.stringify(address));
            let streetAddress = address[0].properties.StAddr;
            let streetAddress2 = address[0].properties.District;
            let state = address[0].properties.RegionAbbr;
            console.log('address[0].properties.District----',address[0].properties.District);
            let city = address[0].properties.City;
            let zipCode = address[0].properties.Postal;
            let country = address[0].properties.Country;
            component.set('v.address',address[0].properties.LongLabel);
            component.set('v.orderRec.Shipping_Street__c',streetAddress);
            component.set('v.orderRec.Shipping_Street2__c',streetAddress2);
            component.set('v.orderRec.Shipping_State__c',state);
            component.set('v.orderRec.Shipping_ZipPostal_Code__c',zipCode);
            component.set('v.orderRec.Shipping_Country__c',country);
            component.set('v.orderRec.Shipping_City__c',city);
            component.set('v.orderRec.Address_Geolocation__Latitude__s',address[0].latlng.lat);
            component.set('v.orderRec.Address_Geolocation__Longitude__s',address[0].latlng.lng);
            console.log('add------',component.get('v.address'));
        }
        catch(e){
            console.log(e);
        }
    }
});