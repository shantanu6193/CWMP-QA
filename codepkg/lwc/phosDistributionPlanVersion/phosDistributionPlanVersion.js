/**
 * Created by PREM on 09-09-2020.
 */

import { LightningElement, api } from 'lwc';
import Utility from 'c/utility';
import getData from '@salesforce/apex/PHOS_DistributionPlanVersionCtrl.getVersion';

export default class PhosDistributionPlanVersion extends Utility {
    @api recordId;
    recordLocal = [];

    /*
    * Get plan distribution record on tha basis of version
    */
    initData(){
        this.executeAction(getData, {'versionId' : this.recordId}, (response) => {
            this.recordLocal = response;
            console.log('response----',response);
        });
    }
}