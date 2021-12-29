import { LightningElement, api, track,wire } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import showcontactDetails from '@salesforce/apex/HH_UpdateContactDetailsCtrl.showContactDetails';
import getContactDetails from '@salesforce/apex/HH_UpdateContactDetailsCtrl.getContactDetails';
import updateContactDetails from '@salesforce/apex/HH_UpdateContactDetailsCtrl.updateContactDetails';

import Mailing_Country_Region__c from '@salesforce/schema/User_Registration__c.Mailing_Country_Region__c';
import Country_Region__c from '@salesforce/schema/User_Registration__c.Country_Region__c';

import HH_EN_PrimaryPhone from '@salesforce/label/c.HH_EN_PrimaryPhone';
import HH_EN_SecondaryPhone from '@salesforce/label/c.HH_EN_SecondaryPhone';
import HH_EN_MailingAddressStreet from '@salesforce/label/c.HH_EN_MailingAddressStreet';
import HH_EN_MailingAddressCity from '@salesforce/label/c.HH_EN_MailingAddressCity';
import HH_EN_MailingAddressState from '@salesforce/label/c.HH_EN_MailingAddressState';
import HH_EN_MailingAddressMailingZip_PostalCode from '@salesforce/label/c.HH_EN_MailingAddressMailingZip_PostalCode';
import HH_EN_MailingAddressCountry from '@salesforce/label/c.HH_EN_MailingAddressCountry';
import HH_UserRegistrationRecordTypeId from '@salesforce/label/c.HH_UserRegistrationRecordTypeId';
import HH_EN_PhysicalAddressStreet from '@salesforce/label/c.HH_EN_PhysicalAddressStreet';
import HH_EN_PhysicalAddressCity from '@salesforce/label/c.HH_EN_PhysicalAddressCity';
import HH_EN_PhysicalAddressState from '@salesforce/label/c.HH_EN_PhysicalAddressState';
import HH_EN_PhysicalAddressCountry from '@salesforce/label/c.HH_EN_PhysicalAddressCountry';
import HH_EN_PhysicalAddressZip_PostalCode from '@salesforce/label/c.HH_EN_PhysicalAddressZip_PostalCode';
import HH_EN_Zip_pattern_validation from '@salesforce/label/c.HH_EN_Zip_pattern_validation';
import HH_EN_City_pattern_validation from '@salesforce/label/c.HH_EN_City_pattern_validation';
import HH_EN_State_pattern_validation from '@salesforce/label/c.HH_EN_State_pattern_validation';
import HH_EN_Update_Contact_Details from  '@salesforce/label/c.HH_EN_Update_Contact_Details';
import HH_EN_Save from '@salesforce/label/c.HH_EN_Save';

export default class HhUpdateContactDetails extends Utility {

	@api recordId;
	objectApiName = 'Contact';
	@track showContactDetails = true;
	@track loadcontact = false;

	@track label = {
		HH_EN_PrimaryPhone,
		HH_EN_SecondaryPhone,
		HH_EN_MailingAddressStreet,
		HH_EN_MailingAddressCity,
		HH_EN_MailingAddressState,
		HH_EN_MailingAddressMailingZip_PostalCode,
		HH_EN_MailingAddressCountry,
		HH_EN_PhysicalAddressStreet,
		HH_EN_PhysicalAddressCity,
		HH_EN_PhysicalAddressState,
		HH_EN_PhysicalAddressCountry,
		HH_EN_PhysicalAddressZip_PostalCode,
		HH_UserRegistrationRecordTypeId,
		HH_EN_State_pattern_validation,
		HH_EN_Zip_pattern_validation,
		HH_EN_City_pattern_validation,
		HH_EN_Update_Contact_Details,
		HH_EN_Save
	}

	@wire(getPicklistValues, {
		recordTypeId: '$label.HH_UserRegistrationRecordTypeId',
		fieldApiName: Mailing_Country_Region__c
	})
	mailingAddressOption;

	@wire(getPicklistValues, {
		recordTypeId: '$label.HH_UserRegistrationRecordTypeId',
		fieldApiName: Country_Region__c
	})
	countryRegionOption;

	initData() {
			this.executeAction(showcontactDetails , {},
			(response) => {
					this.showContactDetails = response.showContactDetails;
					console.log('showContactDetails: '+this.showContactDetails);
					this.showContactDetails = true;
					if(this.showContactDetails) {
						this.fetchContactDetails();
						
					}
			},(error)=>{
					console.log('error----',error);
					if(error.body != undefined && error.body.message != undefined) {
							this.showErrorNotification('',error.body.message);
					} else {
							this.showErrorNotification('',error);
					}
					this.showLoader = false;
			}); 
	}

	fetchContactDetails() {
		this.executeAction(getContactDetails , {'contactId':this.recordId},
			(response) => {
					console.log('contact: ',response.contact);
					this.recordLocal = response.contact;
					this.loadcontact = true;
			},(error)=>{
					console.log('error----',error);
					if(error.body != undefined && error.body.message != undefined) {
							this.showErrorNotification('',error.body.message);
					} else {
							this.showErrorNotification('',error);
					}
					this.showLoader = false;
			}); 
	}


	handleSubmit() {
			let allValid = this.validateInputs();
			console.log('allValid----',allValid);
			console.log('recordLocal----',this.recordLocal);
			if(allValid) {
					this.showLoader = true;
					this.executeAction(updateContactDetails , {'record': JSON.stringify(this.recordLocal)},
					(response) => {
							this.recordLocal = response.contact;
							eval("$A.get('e.force:refreshView').fire();");
							this.showNotification('Success', this.label.HH_DetailsUpdatedSuccessfullMessage, 'success','dismissible');
					},(error)=>{
							console.log('error----',error);
							if(error.body != undefined && error.body.message != undefined) {
									this.showErrorNotification('',error.body.message);
							} else {
									this.showErrorNotification('',error);
							}
							this.showLoader = false;
					}); 
			}
	}

}