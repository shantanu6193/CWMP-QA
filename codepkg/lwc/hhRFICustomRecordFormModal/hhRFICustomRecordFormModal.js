import { LightningElement,api,track,wire } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import RFI_OBJECT from '@salesforce/schema/Request_For_Information__c';
import Status__c from '@salesforce/schema/Request_For_Information__c.Status__c';
import getInitDetails from '@salesforce/apex/HH_RFICustomRecordFormCtrl.getInitDetails';
import upsertRFI from '@salesforce/apex/HH_RFICustomRecordFormCtrl.upsertRFI';

import HH_EN_Cancel from '@salesforce/label/c.HH_EN_Cancel';
import HH_EN_Save from '@salesforce/label/c.HH_EN_Save';
import HH_EN_Request_For_Information from '@salesforce/label/c.HH_EN_Request_For_Information';
import HH_RFIDeadLinePriorDateErrorMessage from '@salesforce/label/c.HH_RFIDeadLinePriorDateErrorMessage';

export default class HhRFICustomRecordFormModal extends Utility {

	@track isModalOpen = true;
	@api parentRecordId;
	@api recordId;
	@api isHomeowner;
	@api isCaloesUser;
	@api isCommunityUser;
	@api isFemaUser;
	@api mode;
	@track label = {
		HH_EN_Cancel,
		HH_EN_Save,
		HH_EN_Request_For_Information,
		HH_RFIDeadLinePriorDateErrorMessage
	};
	@track disableSave = false;
	@track showForm = false;
	@track readOnlyField = false;
	@track readOnlyCommunityComment = true;
	@track readOnlyCaloesComment = true;
	@track readOnlyHomeownerComment = true;
	@track readOnlyFEMAComment = true;
	@track isEditMode = false;

	isMultiEntry = false;
	loadLookupDataOnLoad = true;
	appRequired = [];

	cwmpRecordTypeId;
	statusList;

  @wire(getPicklistValues, {recordTypeId: '$cwmpRecordTypeId',
														 fieldApiName: Status__c}) 
			wiredValues({ error, data }) {
			if (data) {
					this.statusList = data.values;
			} else {
				console.log('error: ',error);
			}
	}
	
	@wire(getObjectInfo, { objectApiName: RFI_OBJECT })
    rfiInfo({ data, error }) {
        if (data) {
					this.label.Status__c = data.fields.Status__c.label;
					this.label.RFI_Type__c = data.fields.RFI_Type__c.label;
					this.label.CWMP_Application__c = data.fields.CWMP_Application__c.label;
					this.label.RFI_Deadline__c = data.fields.RFI_Deadline__c.label;
					this.label.Description__c = data.fields.Description__c.label;
					this.label.Cal_OES_Comment__c = data.fields.Cal_OES_Comment__c.label;
					this.label.FEMA_Comments__c = data.fields.FEMA_Comments__c.label;
					this.label.Homeowner_Comment__c = data.fields.Homeowner_Comment__c.label;
					this.label.Community_Comment__c = data.fields.Community_Comment__c.label;
					console.log('labels: ',this.label);
				}
    }

	initData() {
		console.log('parentRecordId: ',this.parentRecordId);
		this.executeAction(getInitDetails , {'parentRecordId':this.parentRecordId,'recordId':this.recordId ,'userId':this.userId,'mode':this.mode},
				(response) => {
						this.applicationName = response.applicationName;
						this.recordLocal = response.rfi;
						if(this.parentRecordId == undefined && response.applicationId != undefined) {
							this.parentRecordId = response.applicationId;
						}
						this.isHomeowner = response.isHomeowner;
						this.cwmpRecordTypeId = response.rfi.RecordTypeId;
						this.checkMode();
						this.showForm = true;
				},(error)=>{
						this.closeModal();
						if(error.body != undefined && error.body.message != undefined) {
								this.showErrorNotification('',error.body.message);
						} else {
								this.showErrorNotification('',error);
						}
						this.showLoader = false;
    });
	}


	checkMode(){
			if(this.mode == 'Edit') {
					this.isEditMode = true;
					if(this.isHomeowner) {
					this.readOnlyHomeownerComment = false;
					} else if(this.isCaloesUser) {
							this.readOnlyCaloesComment = false;
					} else if (this.isCommunityUser) {
							this.readOnlyCommunityComment = false;
					}  else if (this.isFemaUser) {
							this.readOnlyFEMAComment = false;
					} else {
					this.readOnlyHomeownerComment = false;
							this.readOnlyCaloesComment = false;	
							this.readOnlyCommunityComment = false;
							this.readOnlyFEMAComment = false;
					} 
			}
	}

	

	closeModal() {
			this.showForm = false;
			let  close = new CustomEvent('close');
			this.dispatchEvent(close);
	}

	@api
	openModal() {
		this.showForm = true;
	}

	handleStatusChanged(event) {
			this.recordLocal.Status__c = event.target.value;
	}

	handleSubmit() {
		let allValid = this.validateInputs();
		if(!allValid) {
			return;
		}
		this.disableSave = true;
		this.executeAction(upsertRFI , {'rfiJSON':JSON.stringify(this.recordLocal), 'parentRecordId':this.parentRecordId},
		(response) => {
				this.disableSave = false;
				this.showSuccessNotification('','Record created successfully.')
				this.closeModal();
				this.navigateRecordViewPage(response.rfi.Id);
		},(error)=>{
				this.disableSave = false;
				if(error.body != undefined && error.body.message != undefined) {
						this.showErrorNotification('',error.body.message);
				} else {
						this.showErrorNotification('',error);
				}
				this.showLoader = false;
	});	
	}

	get todaysDate() {
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();
		today = yyyy+'-'+mm+'-'+dd;
		return today
	}
}