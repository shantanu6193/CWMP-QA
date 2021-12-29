import { LightningElement, api, wire, track } from 'lwc';
import Utility from 'c/utility';
import changeRFIStatus from '@salesforce/apex/HMA_RequestForInformationCtrl.changeRFIStatus';
import loadRFIRecord from '@salesforce/apex/HMA_RequestForInformationCtrl.loadRFIRecord';
export default class HmaRFIInternalLayoutButtons extends Utility {
    @api recordId;
    @track rfiRecord;

    timeExtensionButton = false;
    submitRFIButton = false;
    
    initData() {
        this.executeAction(loadRFIRecord, {rfiId : this.recordId}, (response) => {
            if(response.IsSuccess) {
                this.rfiRecord = response.RFIRecord;
                if(response.RFIRecord['Status__c'] == 'FEMA Draft') {
                    this.timeExtensionButton = true;
                    this.submitRFIButton = true;
                } else if(response.RFIRecord['Status__c'] == 'FEMA Time Extension Requested') {
                    this.timeExtensionButton = true;
                    this.submitRFIButton = false;
                } 
                //else if(response.RFIRecord['Status__c'] == 'Submitted to Cal OES Analyst') {
                //     this.submitRFIButton = true;
                //     this.timeExtensionButton = false;
                // }
            }
        });
    }

    get timeExtensionButtonDisable() {
        return this.timeExtensionButton;
    }

    get submitRFIButtonDisabled() {
        return this.submitRFIButton;
    }

    changeStatus(event) {
        let operation = '';
        let message = '';
        if(event.target.dataset.label == 'Time Extension') {
            operation = 'TimeExtensionRequest';
            message = 'Request for Time Extension is submitted successfully';
        } else if(event.target.dataset.label == 'Submit RFI') {
            operation = 'SubmitRFI';
            message = 'Your Request for Information is submitted successfully';
        }
        this.executeAction(changeRFIStatus, {rfiId : this.recordId, operation : operation}, (response) => {
            if(response.IsSuccess) {
                this.showNotification('Success', message, 'success', 'dismissable');
                this.disableButton(operation);
                eval("$A.get('e.force:refreshView').fire();");
            } else {
                this.showNotification('Error', message, 'error', 'dismissable');
            }
        });
    }

    disableButton(operation) {
        if(operation == 'TimeExtensionRequest') {
            this.timeExtensionButton = true;
            this.submitRFIButton = false;
        }
    }
}