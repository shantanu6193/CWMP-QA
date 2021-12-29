import { LightningElement, track, api, wire} from 'lwc';
import Utility from 'c/utility';
import HH_EN_Application_Actions_Message from '@salesforce/label/c.HH_EN_Application_Actions_Message';
import HH_EN_Application_Already_Submitted from '@salesforce/label/c.HH_EN_Application_Already_Submitted';
import HH_EN_Application_Delete_Not_Allowed from '@salesforce/label/c.HH_EN_Application_Delete_Not_Allowed';
import HH_EN_Delete_Application_Confirmation_Header from '@salesforce/label/c.HH_EN_Delete_Application_Confirmation_Header';
import HH_EN_Delete_Application_Confirmation_Message from '@salesforce/label/c.HH_EN_Delete_Application_Confirmation_Message';
import HH_EN_Cancel from '@salesforce/label/c.HH_EN_Cancel';
import HH_EN_Delete from '@salesforce/label/c.HH_EN_Delete';
import HH_EN_Edit from  '@salesforce/label/c.HH_EN_Edit';
import HH_EN_Preview_Button from  '@salesforce/label/c.HH_EN_Preview_Button';
import HH_EN_HERE from  '@salesforce/label/c.HH_EN_HERE';
import HH_Information_PDF from  '@salesforce/label/c.HH_Information_PDF';

import editApplication from '@salesforce/apex/HH_ApplicationActionsCtrl.editApplication';
import deleteApplication from '@salesforce/apex/HH_ApplicationActionsCtrl.deleteApplication';
import isExternalUser from '@salesforce/apex/HH_ApplicationActionsCtrl.isExternalUser';
export default class HhApplicationActions extends Utility {

	@api recordId;
	@track isExternal;
	@track showDeleteModal = false;
	@track label = {
			HH_EN_Application_Actions_Message,
			HH_EN_Application_Already_Submitted,
			HH_EN_Application_Delete_Not_Allowed,
			HH_EN_Delete_Application_Confirmation_Header,
			HH_EN_Delete_Application_Confirmation_Message,
			HH_EN_Cancel,
			HH_EN_Delete,
			HH_EN_Edit,
			HH_EN_Preview_Button,
			HH_EN_HERE,
			HH_Information_PDF
	}

	language

	initData() {
		this.executeAction(isExternalUser, {},
		(response) => { 
						this.isExternal = response.isExternal; 
						this.language = response.language;
		});	
	}

	handleEdit() {
		this.executeAction(editApplication, {'applicationId' : this.recordId},
		(response) => { 
					if(response.success && response.isEditable) {
							if(this.isExternal) {
								this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId, 'currentStage' : 'ApplicantInfo'});
							} else {
								let state = {};
								state['c__id'] = this.recordId;
								state['c__currentStage'] = 'ApplicantInfo';
								this.navigateToComponent('c__HH_Application',state);
							//	this.redirectToTabPage('HH_Application_Form',{'c__id' : this.recordId, 'c__currentStage' : 'ApplicantInfo'})
							}
					} else if (response.success && response.isEditable == false) {
							this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'dismissible', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
					} else {
							this.showErrorNotification('Error',response.message);
					}
		});
	}


	handlePreview() {
			if(this.isExternal) {
					this.redirectToCommunityCustomPage('hh-application-preview', {'id' : this.recordId, 'language' : this.language});
			} else {
				let state = {};
				state['c__id'] = this.recordId;
				state['c__language'] = this.language;
				this.navigateToComponent('c__HH_ApplicationPreview',state);
					//this.redirectToTabPage('HH_Application_Preview',{'c__id' : this.recordId, 'c__language' : this.language});
			}
	}


  handleDeleteModal() {
			this.showDeleteModal = true;
	}

	closeDeleteModal(){
			this.showDeleteModal = false;
	}
	
	handleDelete() {
		this.showDeleteModal = false;
		this.executeAction(deleteApplication, {'applicationId' : this.recordId},
		(response) => { 
					if(response.success && response.isDelete) {
							this.navigateToObjectListView('HH_Application__c');
					} else if (response.success && response.isDelete == false) {
							this.showNotification('',this.label.HH_EN_Application_Delete_Not_Allowed,'error','dismissible'); 
					}
		});
	}

}