import { LightningElement,api,track } from 'lwc';
import Utility from 'c/utility';

import HH_EN_Prior_Date_Validaton from '@salesforce/label/c.HH_EN_Prior_Date_Validaton';

export default class HhAccountRoleDrawRow extends Utility {

	@api index;

	@track label = {
		HH_EN_Prior_Date_Validaton
	}
	

	get todaysDate() {
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();
		today = yyyy+'-'+mm+'-'+dd;
		return today
	}

	get minDate() {
		return '1700-01-01';
	}

	setTitle(event){
		if(this.recordLocal[event.target.getAttribute('data-field')]){
			this.title = this.recordLocal[event.target.getAttribute('data-field')];
			}else{
				this.title = '';
			}
	}

	deleteRow(event){
		event.preventDefault();
		const deleteEvent = new CustomEvent('delete', { detail: {index: this.index }});
		this.dispatchEvent(deleteEvent);
	}
	
	@api
	getRecord() {
		if(this.recordLocal.Date__c == undefined && this.recordLocal.Amount__c == undefined) {
			return {};
		} else if (this.validateInputs()) {
			return this.recordLocal;
		} else {
			return undefined;
		}
	}

}