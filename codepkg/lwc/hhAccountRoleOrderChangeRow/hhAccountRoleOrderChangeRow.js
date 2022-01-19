import { LightningElement,api,wire,track } from 'lwc';
import { getObjectInfo ,getPicklistValues } from 'lightning/uiObjectInfoApi';

import ORDER_CHANGE from '@salesforce/schema/Order_Change__c';
import HH_EN_Select_an_Option from '@salesforce/label/c.HH_EN_Select_an_Option';
import Has_Homeowner_provided_check_payment__c from '@salesforce/schema/Order_Change__c.Has_Homeowner_provided_check_payment__c';
import Utility from 'c/utility';

export default class HhAccountRoleOrderChangeRow extends Utility {

	@api index;

	@track hasHomeownerProvidedPaymentValues;
	@track title='';
	@track label= {
		HH_EN_Select_an_Option
	}

	@wire(getObjectInfo, { objectApiName: ORDER_CHANGE })
	orderChanegObjectInfo;

	@wire(getPicklistValues, {
		recordTypeId: '$orderChanegObjectInfo.data.defaultRecordTypeId',
		fieldApiName: Has_Homeowner_provided_check_payment__c
	})
	hasHomeownerProvidedPayment({error, data}){
		if(data){
				this.hasHomeownerProvidedPaymentValues = data;
				console.log('picklistvalues: '+JSON.stringify(this.hasHomeownerProvidedPaymentValues)); 
		} else {
			console.log('error: ',error);
		}
	}

	deleteRow(event){
		event.preventDefault();
		const deleteEvent = new CustomEvent('delete', { detail: {index:this.index }});
		this.dispatchEvent(deleteEvent);
	}

	@api
	getRecord() {
		if(this.recordLocal.Has_Homeowner_provided_check_payment__c == undefined && this.recordLocal.Homeowner_check_payment_amount__c == undefined) {
			return {};
		} else if (this.validateInputs()) {
			return this.recordLocal;
		} else {
			return undefined;
		}
	}

}