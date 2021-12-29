import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import applicationUrlInvoke from '@salesforce/apex/HH_EditRequestCtrl.getInitData';

export default class HhApplicationEditButton extends Utility {
	
	@api recordId;

	initData() {
			this.redirect();
	}

	redirect() {
		console.log('Edit Form invoked.')
		this.executeAction(applicationUrlInvoke, {'appId': this.recordId},(response) => { 
			if(response.isEdit) {
					let state = {};
					state['id'] = this.recordId;
					state['currentStage'] = 'ApplicantInfo';
					this.redirectToCommunityCustomPage('hh-application',state);		
			} else {
				this.showNotification('', 'You cannot Edit the Application', 'warning', 'dismissible');
			}	
		});
	}
}