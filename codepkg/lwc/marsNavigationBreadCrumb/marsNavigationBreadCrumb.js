import { LightningElement } from 'lwc';
import Utility from 'c/utility';
import getData from '@salesforce/apex/MARS_AgencyPageTabCtrl.getData';
export default class MarsNavigationBreadCrumb extends Utility {
    recordId;
    accountRecord;
    initData() {
        let urlId = this.getURLParameter("id");
        this.recordId = urlId;
        if(this.recordId){
            this.executeAction(getData, {'recordId' : this.recordId}, (response) => {
                this.accountRecord = response.accountInfo;
            });
        }
    }
}