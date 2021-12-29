import { LightningElement,api,wire,track } from 'lwc';
import Utility from 'c/utility';
import HH_EN_MissingFieldValueError from '@salesforce/label/c.HH_EN_MissingFieldValueError';

export default class HhApplicationEditDeedContactRow extends Utility {
	@api index;

	@track label = {
		HH_EN_MissingFieldValueError
	}
	/*
	* Delete selected row
	*/

	initData() {
		console.log('===>',JSON.stringify(this.recordLocal));
		this.recordLocal['Contact__r']['FirstName'] = this.recordLocal['Contact__r.FirstName'] ;
		this.recordLocal['Contact__r']['LastName'] = this.recordLocal['Contact__r.LastName'] ;
	}
	deleteRow(event){
			event.preventDefault();
			const deleteEvent = new CustomEvent('deleted', { detail: {index:this.index }});
			this.dispatchEvent(deleteEvent);
	}

	blankCheck(event) {
		this.recordLocal[event.target.getAttribute('data-field')] = this.recordLocal[event.target.getAttribute('data-field')].trim();
		let contactField = this.template.querySelector('[data-field="'+event.target.getAttribute('data-field')+'"]');
		contactField.setCustomValidity('');
		contactField.reportValidity();
		if(this.recordLocal[event.target.getAttribute('data-field')].length == 0) {
			contactField.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
			contactField.reportValidity();
		}
	}

	@api 
	getUnvalidatedRecord() {
				return this.recordLocal;
	}
}