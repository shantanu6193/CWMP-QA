/**
 * Created by hp on 2020-04-06.
 */

({
     getPriorityOfRequestOptions : function(component, event, helper) {
          let action = component.get("c.getPriorityOfRequests");
          action.setCallback(this, function(response) {
             let state = response.getState();
              if(state == 'SUCCESS') {
                 debugger;
                 component.set("v.priorityOptions", response.getReturnValue());
                 console.log("----",response.getReturnValue())
              } else {
                 //alert('ERROR while getting contact');
              }
          });
          $A.enqueueAction(action);
     },
   getStatecodeOptions : function(component, event, helper) {
          let action = component.get("c.getStateCodes");
          action.setCallback(this, function(response) {
             let state = response.getState();
               //alert(state);
              if(state == 'SUCCESS') { 
                
                 component.set("v.stateCodeOptions", response.getReturnValue());
                 console.log("----",response.getReturnValue())
              } else {
                 //alert('ERROR while getting contact');
              }
          });
          $A.enqueueAction(action);
     },
     phoneValidation : function(component, event, helper, number, field, inputCmp){
          let cleanedNumber = ('' + number).replace(/\D/g, '');
          let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
          let newNumber = '';
          if (phoneNumber) {
             newNumber  = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
             console.log('newNumber',newNumber);
             if(field == 'Requester Phone') {
                 component.set('v.orderRec.Requestor_Phone_Text__c', newNumber);
             }
             else if(field == 'Delivery Recipient Phone') {
                 component.set('v.orderRec.Delivery_Recipient_Phone_Text__c', newNumber);
             }
          }
          var value = inputCmp.get("v.value");
          if (value != newNumber) {
              inputCmp.setCustomValidity("Enter a valid phone number ex:(555) 555-5555");
              console.log('valid',false);
          } else {
              inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
              console.log('valid',true);
          }
          inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
      },
      getCountyOptions : function(component, event, helper) {
         let action = component.get("c.getCountyList");
         action.setCallback(this, function(response) {
            let state = response.getState();
              //alert(state);
             if(state == 'SUCCESS') { 
               
                component.set("v.countyCodeOptions", response.getReturnValue());
                console.log("----",response.getReturnValue())
             } else {
                //alert('ERROR while getting contact');
             }
         });
         $A.enqueueAction(action);
    },
    getEntityTypeOptions : function(component, event, helper) {
        debugger;
        try{
         let action = component.get("c.getEntityTypeList1");
         action.setCallback(this, function(response) {
            let state = response.getState();
              //alert(state);
             if(state == 'SUCCESS') {

                component.set("v.entityTypeOptions", response.getReturnValue());
                console.log("----",response.getReturnValue())
             } else {
                //alert('ERROR while getting contact');
             }
         });
         $A.enqueueAction(action);
         }
         catch(e) {
             console.log(e);
         }
    },
    getIncidentOptions : function(component, event, helper) {
      let action = component.get("c.getIncidentList");
      action.setParams({ available : "PHOS" });
      action.setCallback(this, function(response) {
         let state = response.getState();
           //alert(state);
          if(state == 'SUCCESS') { 
            
             component.set("v.incidentOptions", response.getReturnValue());
             console.log("----",response.getReturnValue())
          } else {
             //alert('ERROR while getting contact');
          }
      });
		  $A.enqueueAction(action);
	 }
});