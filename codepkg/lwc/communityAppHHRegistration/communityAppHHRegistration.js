import { LightningElement,api,wire,track } from 'lwc';
import Utility from 'c/utility';
import getUserDetails from '@salesforce/apex/CommunityAppHHRegistrationCtrl.getUserDetails';
import processHHRequest from '@salesforce/apex/CommunityAppHHRegistrationCtrl.processHHRequest';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';


import USER_REG_OBJECT from '@salesforce/schema/User_Registration__c';
import User_Type__c from '@salesforce/schema/User_Registration__c.User_Type__c';
import County__c from '@salesforce/schema/User_Registration__c.County__c';

import HH_UserRegistrationRecordTypeId from '@salesforce/label/c.HH_UserRegistrationRecordTypeId';

export default class CommunityAppHHRegistration extends Utility {
	@api contactRecord;
	buttonDisabled = false;
	userType;
	countyName;

	@wire(getObjectInfo, { objectApiName: USER_REG_OBJECT })
	objectInfo;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: User_Type__c
	})
	userTypePicklistValues;
	
	@wire(getPicklistValues, {
		recordTypeId: HH_UserRegistrationRecordTypeId,
		fieldApiName: County__c
	})
	countyPicklistValues;

	initData(){
		this.executeAction(getUserDetails, {}, (response) => {
				this.contactRecord = response.ContactDetails;
		});
	}

	get IsContactRecord(){
		if(this.contactRecord != null) return true;
				return false;
	}

	requestHHAccess(event) {
		let accId = this.contactRecord.AccountId;
		let conId = this.contactRecord.Id;
		let allValid = this.validateInputs();
	  if(!allValid) {
			this.showErrorNotification('', 'Please fill all required fields.');
			return;
		}
		this.executeAction(processHHRequest, {
				accountId: accId,
				contactId: conId,
				userType: this.userType,
				countyName: this.countyName
		},(response) => {
				this.showLoader = true;
				this.buttonDisabled = true;
				this.showSuccessNotification('Success', 'Your request is submitted for Approval. once Approved you will be notified and you can login to the app from here.');
				setTimeout(function(){
						location. reload();
						},2000);
		},(error) => {
			this.showLoader = false;
			this.buttonDisabled = false;
			this.showErrorNotification('Error', error);
		});
	}

	userTypeChanged(event) {
		this.userType = event.target.value;
		if(this.userType == 'Community') {
			this.showCountyPicklist = true;
		} else {
			this.showCountyPicklist = false;
		}
	}

	countyChanged(event) {
		this.countyName = event.target.value;
	}
}