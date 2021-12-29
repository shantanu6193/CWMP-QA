import { LightningElement, api } from 'lwc';
import Utility from 'c/utility';
import processOnRFI from '@salesforce/apex/HMA_RequestForInformationCtrl.processOnRFI';

export default class HmaRFISubmitButton extends Utility {
    @api recordId;
    @api invoke() {
        this.callApexAction();
    }

    callApexAction() {
        console.log('recordId  : ', this.recordId);
        this.executeAction(processOnRFI, {applicationId : this.recordId}, (response) => {
            console.log('response_processOnRFI : ',response);
            if(response['isSuccess'] == true) {
                this.showSuccessNotification('The RFI(s) has successfully submitted.');
            } else {
                this.showErrorNotification("You do not have an RFI to submit.");
            }
        });
    }
}