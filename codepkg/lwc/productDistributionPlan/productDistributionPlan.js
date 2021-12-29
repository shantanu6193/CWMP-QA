/**
 * Created by Shivraj on 27-08-2020.
 */

import { LightningElement, api, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getOrderProducts from '@salesforce/apex/PHOS_DistributionCtrl.getOrderProducts';
import submitRequest from '@salesforce/apex/PHOS_DistributionCtrl.submitRequest';

export default class ProductDistributionPlan extends Utility {
    @api recordId;

    /*
    * Get order products by recordId as well as plan rows
    */
    initData() {
        let orderId = this.getURLParameter("c__orderId");
        this.recordId = orderId;
        if(this.recordId) {
            this.executeAction(getOrderProducts, {orderId : this.recordId}, (response) => {
                if(response){
                    this.recordLocal.Order_Products__r = response.OrderItems;
                }
            });
        }
        this.skipCustomLogicValidation = true;
    }

    /*
    * Calls submitData() method when submit button is clicked
    */
    submit() {
        this.submitData(false);
    }

    /*
    * Calls submitData() method when quick save button is clicked
    */
    quickSave() {
        this.submitData(true);
    }

    /*
    * Process submit plan distribution record
    * Submits record and stays on a page when isQuickSave is true
    * Submits record and redirect to record page when isQuickSave is false
    */
    submitData(isQuickSave) {
        try{

            let recordValid = this.updateLisToParentComponentList();
            if(recordValid == undefined) {
                return;
            }
            let localRecord = JSON.parse(JSON.stringify(this.recordLocal.Order_Products__r));
            for(let i=0; i<localRecord.length; i++) {
                if(localRecord[i].Product_Distribution_Plans__r == undefined) {
                    localRecord[i].Product_Distribution_Plans__r = [];
                }
                let orderProductRec = {
                        totalSize: localRecord[i].Product_Distribution_Plans__r.length,
                        done: true,
                        records : localRecord[i].Product_Distribution_Plans__r
                };
                localRecord[i].Product_Distribution_Plans__r = orderProductRec;
                let removeProdDistPlan = false;
                for(let j=0; j < localRecord[i].Product_Distribution_Plans__r.records.length; j++) {
                    let record = localRecord[i].Product_Distribution_Plans__r.records[j];
                    //console.log('record----',record);
                    if(record.Facility__c == undefined && record.Facility__r == undefined && record.County__c == undefined && record.Facility_Code__c == undefined && record.Facility_Name__c == undefined && record.Actual_Quantity_Distribution__c == undefined && record.Distribution_Notes__c == undefined && record.Proposed_Quantity_Distribution__c == undefined) {
                        localRecord[i].Product_Distribution_Plans__r.records.splice(j,1);
                    }
                    if(Object.keys(record).length == 0) {
                       //console.log('i====',i);
                       removeProdDistPlan = true;
                    }
                }
                if(removeProdDistPlan == true) {
                    delete localRecord[i].Product_Distribution_Plans__r;
                }
                //console.log('localRecord test----',localRecord);
            }
            //console.log('====recorddddddToSend',JSON.stringify(localRecord));
            this.executeAction(submitRequest, {'recordData' : JSON.stringify(localRecord), 'isQuickSave' : isQuickSave}, (response) => {
                //console.log('resp--------->',response);
                this.showNotification('Success', 'Record Saved Successfully', 'success', 'dismissible');
                if(!isQuickSave) {
                    this.dispatchCloseEvent();
                    this.navigateRecordViewPage(response.OrderId);
                }
                else {
                     this.recordLocal.Order_Products__r = response.OrderItems;
                }
            });
        }
        catch(e){
            console.log(e);
        }
    }

    /*
    * Calls dispatchCloseEvent() when close button clicked
    * Navigates to record page
    */
    close() {
        this.dispatchCloseEvent();
        this.navigateRecordViewPage(this.recordId);
    }

    /*
    * Notifies parent component when close clicked
    */
    dispatchCloseEvent() {
        //console.log('iiiiii');
        let close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         this.dispatchEvent(closeclickedevt);
    }

    /*
    * Validate input fields
    */
    validateFields(){
        let validateInputs = this.validateInputs();
        if(validateInputs && this.skipCustomLogicValidation) {
            return true;
        }
        return false;
    }

    /*
    * Get order product details from child component
    */
    updateLisToParentComponentList() {
        if(this.recordLocal.Order_Products__r != undefined) {
            for(let i=0; i<this.recordLocal.Order_Products__r.length; i++) {

                let orderProduct = this.template.querySelector('[data-id="'+i+'"]').getRecordDetails();
                if(orderProduct == undefined) {
                    return undefined;
                }
                delete orderProduct.index;
                this.recordLocal.Order_Products__r[i] = orderProduct;
            }
        }
        return this.recordLocal;
    }
}