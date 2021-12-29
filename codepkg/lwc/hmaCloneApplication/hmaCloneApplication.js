import { LightningElement, api, track } from 'lwc';
import Utility from 'c/utility';
import CloneApplication from '@salesforce/apex/HMA_CloneApplicationCtrl.CloneApplication';

export default class HmaCloneApplication extends Utility {
    @api recordId;
    @api invoke() {
        this.cloneApplicationHandle();
    }
    @track  isLoading = false;
    cloneApplicationHandle() {
        console.log('recordId  : ', this.recordId);
        this.isLoading = true;
        this.executeAction(CloneApplication, {applicationId : this.recordId}, (response) => {
            console.log('response_CloneApplication : ',response);
            this.isLoading = false;
            if(response['isSuccess'] == true) {
                this.showSuccessNotification('The Sub-Application Cloned successfully.');
            } else {
                this.showErrorNotification(response['error']);
            }
        });
    }
}