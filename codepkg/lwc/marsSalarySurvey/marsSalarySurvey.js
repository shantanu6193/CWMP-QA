/**
 * Created by Pankaj on 03-04-2021.
 */

import { LightningElement, wire, api, track } from 'lwc';
import upsertSurveyLineItem from "@salesforce/apex/MARS_SalarySurveyCrl.submitSalarySurveyLines";
import getData from "@salesforce/apex/MARS_SalarySurveyCrl.getData";
import Utility from 'c/utility';
 
export default class MarsSalarySurvey extends Utility {
    @api objectName;
    @api fieldSetName;
    @api recordId;
    @track salarySurveyRecords = [];
    @track isSubmitModalOpen = false;
    futureDate;
    minDate;
    disableSubmit = false;
    salarySurvey;
    oldRequestedEffectiveDate;

    initData() {
        try{
        this.executeAction(getData, {
            accountId: this.recordId
        }, (result) => {
            this.salarySurveyRecords = result.salarySurveyLines;
            this.salarySurvey = result.salarySurvey;
            if(this.salarySurvey.Status__c === 'Pending Review')
                this.disableSubmit = true;
                let todayDate = this.todayDateInYYYYMMDD();
            if(this.salarySurvey != undefined && this.salarySurvey.Requested_Effective_Date__c != undefined && this.salarySurvey.Requested_Effective_Date__c != '' && new Date(this.salarySurvey.Requested_Effective_Date__c) >= new Date(todayDate)){
                this.oldRequestedEffectiveDate = this.salarySurvey.Requested_Effective_Date__c;
                var effectiveDate = new Date(this.oldRequestedEffectiveDate);
                effectiveDate.setDate(effectiveDate.getDate() + 1);
                this.minDate = new Date(this.oldRequestedEffectiveDate).toISOString();
                this.futureDate = effectiveDate.toISOString();
            } else {
                this.minDate = todayDate;
                this.futureDate = todayDate; 
            }  
        });
    }catch(e){
        console.log(e);
    }

    }

    hasError;
    getSurveyLines() {
        let recordsToSave = [];
        let hasCorrectData = true;

        for (let i = 0; i < this.salarySurveyRecords.length; i++) {
            let salarySurvey = this.template.querySelector('[data-id="' + i + '"]').getRecordDetails();
            if (salarySurvey == undefined) {
                this.hasError = true;
            }
            recordsToSave.push(salarySurvey);
        }
        return recordsToSave;
    }

    saveData() {
        if (this.validateInputs() == false) return;
        this.hasError = false;
        let recordsToSave = this.getSurveyLines();

        if (this.hasError == true) return;
        let signatureBlob = this.template.querySelector('[data-id="signature"]').getSignatureBlob();
        if (signatureBlob == undefined) {
            this.showErrorNotification('Please sign form.');
            this.template.querySelector('[data-id="signature"]').refreshCanvas();
            return;
        }
        this.executeAction(upsertSurveyLineItem, {
            data: JSON.stringify(recordsToSave),
            accountId: this.recordId,
            effectiveDate: this.futureDate,
            signatureBlob: signatureBlob
        }, (response) => {
            this.disableSubmit = true;
            this.showSuccessNotification('Records Submitted Successfully.');
            this.template.querySelector("c-mars-salary-survey-history").initData();
        });
    }

    handleFutureDateChange(event) {
        this.futureDate = event.target.value;
        const futureDate = new Date(this.futureDate);
        var effectiveDate = new Date(this.oldRequestedEffectiveDate);
        effectiveDate.setDate(effectiveDate.getDate() + 1);
        let startDateCmp = this.template.querySelector(".futuredate");
        if(futureDate < effectiveDate){
            startDateCmp.setCustomValidity("Please select a future date");
            startDateCmp.reportValidity();
            return false;
         }else {
             startDateCmp.setCustomValidity("");
             startDateCmp.reportValidity();
             return true;
         }       
    }
    get checkSubmitDisable() {
        if(this.disableSubmit) {
            return true;
        } else {
            return false;
        } 
    }
}