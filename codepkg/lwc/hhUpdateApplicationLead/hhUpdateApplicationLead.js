import { LightningElement, wire, track, api } from 'lwc';
import Utility from 'c/utility';
import HH_EN_Update_Application_Lead from '@salesforce/label/c.HH_EN_Update_Application_Lead';
import HH_StageAndStatusUpdate_Component_SaveButton from '@salesforce/label/c.HH_StageAndStatusUpdate_Component_SaveButton';
import HH_DetailsUpdatedSuccessfullMessage from '@salesforce/label/c.HH_DetailsUpdatedSuccessfullMessage';
import HH_EN_FillAllRequiredFieldErrorMessage from '@salesforce/label/c.HH_EN_FillAllRequiredFieldErrorMessage';

import getQueueName from '@salesforce/apex/HH_UpdateApplicationLeadCtrl.getQueueName';
import searchUsers from '@salesforce/apex/HH_UpdateApplicationLeadCtrl.apexSearchFacility';
import saveApplicationLead from '@salesforce/apex/HH_UpdateApplicationLeadCtrl.saveApplicationLead';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class HhUpdateApplicationLead extends Utility {

    showLoader = false;
    loadLookupDataOnLoad =true;
    isMultiEntry=false;
    leadRequired = [];

    @track showRequiredError = false;
    @track showComponent = false;
    @track label = {
        HH_EN_Update_Application_Lead,
        HH_StageAndStatusUpdate_Component_SaveButton,
        HH_DetailsUpdatedSuccessfullMessage,
        HH_EN_FillAllRequiredFieldErrorMessage
    }
    @api recordId;

    queueName;

    initData() {
        this.executeAction(getQueueName , {'applicationId':this.recordId},
        (response) => {
            console.log('queueName: ',response);
            this.showComponent = response.showComponent;
            if(this.showComponent && response.queueName != undefined) {
                this.queueName = response.queueName;
                this.recordLocal.Application_Lead__c = response.applicationLeadId;
            }    
            this.showLoader = false;
        },(error)=>{
            if(error.body != undefined && error.body.message != undefined && error.body.message.includes('Application not editable')) {
                this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'sticky', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
            }
            else if(error.body != undefined && error.body.message != undefined) {
                this.showErrorNotification('',error.body.message);
            } else {
                this.showErrorNotification('',error);
            }
            this.showLoader = false;
        });        
    }

    handleUserSearch(event) {
        let initailSelection;
        this.executeAction(searchUsers , {'searchTerm':event.detail.searchTerm,'queueName':this.queueName},
        (response) => {
            console.log('results----', response);
            response.forEach(user => {
                if(this.recordLocal.Application_Lead__c != undefined &&
                    user.id == this.recordLocal.Application_Lead__c) {
                        initailSelection = user;
                }
            });
            this.template.querySelector('[data-lookup="Application_Lead__c"]').setSearchResults(response);
            if(initailSelection != undefined) {
                this.template.querySelector('[data-lookup="Application_Lead__c"]').setSelection(initailSelection);
            }
        },(error)=>{
            if(error.body != undefined && error.body.message != undefined) {
                this.showErrorNotification('',error.body.message);
            } else {
                this.showErrorNotification('',error);
            }
            this.showLoader = false;
        });       
    }

    handleUserChange(response) {
        if(!response.detail){
           this.recordLocal.Application_Lead__c = '';
           this.showRequiredError =true;
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Application_Lead__c = response.detail.selectedItem.id;
            this.showRequiredError =false;
        }
    }

    handleSubmit() {       
        if(this.recordLocal.Application_Lead__c  == undefined || this.recordLocal.Application_Lead__c == '') {
            this.showNotification('', this.label.HH_EN_FillAllRequiredFieldErrorMessage,'error','dismissible');
            this.showRequiredError =true;
            return;
        }
        this.executeAction(saveApplicationLead , {'userId':this.recordLocal.Application_Lead__c,'applicationId':this.recordId},
        (response) => {
            getRecordNotifyChange([{recordId: this.recordId}]);
            console.log('Saved...!');
            this.showNotification('Success', this.label.HH_DetailsUpdatedSuccessfullMessage, 'success','dismissible');            
        },(error)=>{
            if(error.body != undefined && error.body.message != undefined) {
                this.showErrorNotification('',error.body.message);
            } else {
                this.showErrorNotification('',error);
            }
            this.showLoader = false;
        });       
    }
}