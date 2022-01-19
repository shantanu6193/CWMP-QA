import {  track, api, wire} from 'lwc';
import Utility from 'c/utility';

import getCWMPAccountRoles from '@salesforce/apex/HH_CustomRelatedListAccountRolesCtrl.getCWMPAccountRoles';

import HH_EN_Refresh from '@salesforce/label/c.HH_EN_Refresh';
import HH_EN_Action from '@salesforce/label/c.HH_EN_Action';
import HH_EN_Edit from '@salesforce/label/c.HH_EN_Edit';
import HH_EN_View from '@salesforce/label/c.HH_EN_View';
import HH_EN_New from '@salesforce/label/c.HH_EN_New';

export default class HhCustomRelatedListAccountRoles extends Utility {
	@track isModalOpen = false;
	iscreate =false;
	isedit=false;

	@api recordId;
	@api header;

	@track fields;
	@track showTable = false;
	@track label = {
			HH_EN_Refresh,
			HH_EN_Action,
			HH_EN_Edit,
			HH_EN_View,
			HH_EN_New
	}
	@track showContractorModal = false;
	@track showNewButton = true;

	selectedRecordId;


	initData() {
		this.executeAction(getCWMPAccountRoles, {'recordId' : this.recordId}, 
		(response) => {
						console.log('----accountroles----',response);
						this.recordLocal.accountRoles=  response.accountRoles;
						this.recordLocal.totalAccountRoles = response.accountRoles.length;
						if (this.recordLocal.totalAccountRoles > 0) {
							this.showTable = true;
            }
		},(error)=>{
				if(error.body != undefined && error.body.message != undefined) {
						this.showNotification('Error', error.body.message, 'error', 'dismissible');
				} else {
						this.showNotification('Error', error, 'error', 'dismissible');
				}
		});
	}

	editAccountRole(event) {
			this.selectedRecordId = event.target.getAttribute('data-selected-id');
			this.isModalOpen = true;
	}   

	/*Navigate to New Page*/
	createNewContractor(){
	console.log('------------------------');
			this.selectedRecordId = null;
			this.isModalOpen = true;
	
	}
	
	closeModal(){
		this.isModalOpen = false;
		this.initData();
	}

	get openModal() {
		return this.isModalOpen;
	}

}