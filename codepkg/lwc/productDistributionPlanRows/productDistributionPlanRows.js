/**
 * Created by Shivraj on 27-08-2020.
 */

import { LightningElement, api, track } from 'lwc';
import Utility from 'c/utility';

export default class ProductDistributionPlanRow extends Utility {

    initData() {
        //this.skipCustomLogicValidation = false;
    }

    /*
    * Get records of distribution plan from child component
    */
    updateRecordLocal() {
        this.allInputsValidated = true;
        let recordLocal = this.template.querySelector('[data-custom="innerComponent"]').getRecordDetails();
        if(recordLocal == undefined) {
            this.allInputsValidated = false;
        } else {
            this.recordLocal = recordLocal;
            if(this.hasQuantityError || this.hasQuantityFilledError) {
                this.allInputsValidated = false;
            }
            /*else{
                this.recordLocal = recordLocal;
            }*/
        }
        //console.log('Plan Rows--', JSON.stringify(this.recordLocal));
    }

    /*
    * Validation of inputs
    */
    validateCustomInput() {
        if(this.hasQuantityError || this.hasQuantityFilledError) {
            return false;
        }
        return true;
    }

    /*
    * Validation for Quantity field
    */
    get hasQuantityError() {
        try{
            if(this.recordLocal != undefined && this.recordLocal.Product_Distribution_Plans__r != undefined) {
                let totalProposedQty = 0;
                for(let index=0; index < this.recordLocal.Product_Distribution_Plans__r.length; index++) {
                    if(this.recordLocal.Product_Distribution_Plans__r[index].Proposed_Quantity_Distribution__c != undefined) {
                        totalProposedQty = totalProposedQty + parseFloat(this.recordLocal.Product_Distribution_Plans__r[index].Proposed_Quantity_Distribution__c);
                    }
                }
                if(this.recordLocal.Quantity__c != undefined && this.recordLocal.Quantity__c < totalProposedQty) {
                    //console.log('rec------>',this.recordLocal);
                    return true;
                }
            }
            return false;
        }
        catch(e) {
            console.log(e);
        }
    }

    /*
    * Validation for Quantity filled field
    */
    get hasQuantityFilledError() {
        try{
            if(this.recordLocal != undefined && this.recordLocal.Product_Distribution_Plans__r != undefined) {
                let totalActualQty = 0;
                for(let index=0; index < this.recordLocal.Product_Distribution_Plans__r.length; index++) {
                    if(this.recordLocal.Product_Distribution_Plans__r[index].Actual_Quantity_Distribution__c != undefined) {
                        totalActualQty = totalActualQty + parseFloat(this.recordLocal.Product_Distribution_Plans__r[index].Actual_Quantity_Distribution__c);
                    }
                }
                if(this.recordLocal.Quantity_Filled__c == undefined) {
                    this.recordLocal.Quantity_Filled__c = 0;
                }
                if(this.recordLocal.Quantity_Filled__c < totalActualQty) {
                    //console.log('rec------>',this.recordLocal);
                    return true;
                }
            }
            return false;
        }
        catch(e) {
            console.log(e);
        }
    }

}