import {  track, api, wire} from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import RFI_OBJECT from '@salesforce/schema/Request_For_Information__c';
import getRFIRecords from '@salesforce/apex/HH_CustomRelatedListRFICtrl.getRFIRecords';

import HH_EN_Refresh from '@salesforce/label/c.HH_EN_Refresh';
import HH_EN_Action from '@salesforce/label/c.HH_EN_Action';
import HH_EN_Edit from '@salesforce/label/c.HH_EN_Edit';
import HH_EN_View from '@salesforce/label/c.HH_EN_View';
import HH_EN_New from '@salesforce/label/c.HH_EN_New';
import HH_EN_Request_For_Information from '@salesforce/label/c.HH_EN_Request_For_Information';
import HH_EN_County from '@salesforce/label/c.HH_EN_County';
export default class HhCustomRelatedListRFI extends Utility {

@track fields;
@track showTable = false;
@track label = {
	HH_EN_Refresh,
	HH_EN_Action,
	HH_EN_Edit,
	HH_EN_View,
	HH_EN_New,
	HH_EN_Request_For_Information,
	HH_EN_County
}
@track showRFIModal = false;
@track showNewButton = false;
@track isAsc = false;
@track isDsc = false;
@api recordId;
@api header
@api selectRecordId;

statusSortDirection;

mode;



	@wire(getObjectInfo, { objectApiName: RFI_OBJECT })
	rfiInfo({ data, error }) {
			if (data) {
				this.label.Name = data.fields.Name.label;
				this.label.Status__c = data.fields.Status__c.label;
				this.label.RFI_Deadline__c = data.fields.RFI_Deadline__c.label;
				this.label.Description__c = data.fields.Description__c.label;
				this.label.CreatedDate = data.fields.CreatedDate.label;
				this.label.County = HH_EN_County;
			}
	}


	initData() {
		this.executeAction(getRFIRecords, {'applicationId' : this.recordId}, 
		(response) => {
						this.recordLocal=  response;
						this.showNewButton = this.recordLocal.isRFICreatable;
						if(this.recordLocal.rfiListCount >0){
						this.showTable = true;
                        }
						this.isAsc = false;
						this.isDsc = false;
		},(error)=>{
				if(error.body != undefined && error.body.message != undefined) {
						this.showNotification('Error', error.body.message, 'error', 'dismissible');
				} else {
						this.showNotification('Error', error, 'error', 'dismissible');
				}
		});
	}

	viewRFI(event) {
			this.selectRecordId = event.target.getAttribute('data-id');
			this.showRFIModal = true;
			this.mode = 'View';
	}

	editRFI(event) {
			this.selectRecordId = event.target.getAttribute('data-id');
			this.showRFIModal = true;
			this.mode = 'Edit';
	}

	navigateToDetailPage(event) {
		this.selectRecordId = event.target.getAttribute('data-id');
		this.navigateRecordViewPage(this.selectRecordId);
	}

	createRFI(){
		this.selectRecordId = undefined;
		this.mode = 'Edit';
		let modalTemp = this.template.querySelector('c-hh-r-f-i-custom-record-form-modal');
		if(modalTemp != undefined && modalTemp != null){
			modalTemp.openModal();
		}
		this.showRFIModal = true;	
	}


	closeModal() {
			this.showRFIModal = false;
			this.initData();
	}

   get isFirefox(){
       if(navigator.userAgent.indexOf("Firefox") != -1){
          return true;
       }else{
           return false;
       }
   }

	sortColumn(event) {
			this.statusSortDirection = this.statusSortDirection === 'asc' ? 'desc' : 'asc';
			if(this.statusSortDirection =='asc'){
					this.isAsc = true;
					this.isDsc = false;
			}
			else{
					this.isDsc = true
					this.isAsc = false;
			}
			var reverse = this.statusSortDirection === 'asc' ? 1 : -1;
			this.recordLocal.rfiList = this.recordLocal.rfiList.sort((a,b) => {return a[event.currentTarget.dataset.id] > b[event.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
	}

}