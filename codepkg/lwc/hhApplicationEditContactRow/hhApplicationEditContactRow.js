import { api,wire,track } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo ,getPicklistValues } from 'lightning/uiObjectInfoApi';
import HH_EN_Prior_Date_Validaton from '@salesforce/label/c.HH_EN_Prior_Date_Validaton';
import HH_EN_Select_an_Option from '@salesforce/label/c.HH_EN_Select_an_Option';
import HH_EN_MissingFieldValueError from '@salesforce/label/c.HH_EN_MissingFieldValueError';

import APPLICATION_CONTACT from '@salesforce/schema/Application_Contact__c';
import HEAD_HOUSE_FIELD from '@salesforce/schema/Application_Contact__c.Head_of_Household__c';
import RELATION_TO_HOMEOWNER_FIELD from '@salesforce/schema/Application_Contact__c.Relationship_to_Homeowner__c';

export default class HhApplicationEditContactRow extends Utility {
	@api index;
	@track headHousholdPicklistValues;
	@track relationToHomeOwnerPicklistValues;
	@track picklistRendered = false;
	@track title='';
	@track label= {
		HH_EN_Prior_Date_Validaton,
		HH_EN_Select_an_Option,
		HH_EN_MissingFieldValueError
	}

	@wire(getObjectInfo, { objectApiName: APPLICATION_CONTACT })
	contactObjectInfo;

	@wire(getPicklistValues, {
		recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
		fieldApiName: HEAD_HOUSE_FIELD
	})
	headHousholdPicklistValues({error, data}){
		if(data){
				this.headHousholdPicklistValues = data;
				console.log('picklistvalues: '+JSON.stringify(this.headHousholdPicklistValues)); 
		}
	}

	@wire(getPicklistValues, {
		recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
		fieldApiName: RELATION_TO_HOMEOWNER_FIELD
	})
	relationToHomeOwnerPicklistValues({error, data}){
		if(data){
				this.relationToHomeOwnerPicklistValues = data;
				console.log('picklistvalues: '+JSON.stringify(this.relationToHomeOwnerPicklistValues)); 
		}
	}

	initData() {
		console.log('record: '+this.recordlocal);
		if(this.headHousholdPicklistValues != undefined && this.relationToHomeOwnerPicklistValues != undefined) {
				this.picklistRendered = true;
				console.log('Picklist Rendered');
		}
	}

	/*
	* Delete selected row
	*/
	deleteRow(event){
			event.preventDefault();
			const deleteEvent = new CustomEvent('deleted', { detail: {index:this.index }});
			this.dispatchEvent(deleteEvent);
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
    getHousholdPicklistTitle(event){
        if(this.headHousholdPicklistValues.values) {
            this.headHousholdPicklistValues.values.forEach(selectionList => {
                if(selectionList.value == event.target.getAttribute("data-value")) {
                    this.title = selectionList.label;
                }else if(event.target.getAttribute("data-value") == null){
                    this.title = this.label.HH_EN_Select_an_Option;
                }
            });
        }
    }

    getRelationValuesTitle(event){
        if(this.relationToHomeOwnerPicklistValues.values) {
            this.relationToHomeOwnerPicklistValues.values.forEach(selectionList => {
                if(selectionList.value == event.target.getAttribute("data-value")) {
                    this.title = selectionList.label;
                }else if(event.target.getAttribute("data-value") == null){
                     this.title = this.label.HH_EN_Select_an_Option;
                 }
            });
        }
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
}