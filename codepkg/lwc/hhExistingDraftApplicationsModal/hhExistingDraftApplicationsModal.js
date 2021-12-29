import { LightningElement, track, api, wire} from 'lwc';
import Utility from 'c/utility';
import checkDraftAppCount from '@salesforce/apex/HH_CheckExistingDraftApplicationsCtrl.getExistingDraftApplicationsCount';
import HH_EN_Existing_Draft from '@salesforce/label/c.HH_EN_Existing_Draft';
import HH_EN_Yes from '@salesforce/label/c.HH_EN_Yes';
import HH_EN_Cancel from '@salesforce/label/c.HH_EN_Cancel';

export default class HhExistingDraftApplicationsModal extends Utility {

@track showModal = false;

@track label = {
	HH_EN_Existing_Draft,
	HH_EN_Yes,
	HH_EN_Cancel
}

initData() {
	this.executeAction(checkDraftAppCount, {}, 
	(response) => {
				let draftCount = response.totalDraftApplications;
				if(draftCount > 0 ) {
					this.showModal = true;
				} else {
						this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId});
				}
	},(error)=>{
			if(error.body != undefined && error.body.message != undefined) {
					this.showErrorNotification('Error Fetching Data',error.body.message);
			} else {
					this.showErrorNotification('Error Fetching Data',error);
			}
	});

}

handleCancel() {
	let state = {};
	state['HH_Application__c-filterId'] = 'All';
	this.navigateToListView('HH_Application__c',state);
}

handleYes() {

	this.redirectToCommunityCustomPage('hh-application', {'currentStage' : 'ApplicantInfo'});
}

}