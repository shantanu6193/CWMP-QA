import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';


export default class PhosIndustryPickList extends LightningElement {

    @api
    get parentIndustry() {
        return this.selectedIndustry;
    }

    set parentIndustry(value) {
        this.selectedIndustry = value;
        this.updateSubIndustryValues();
    }
    // Reactive variables
    @api selectedIndustry;
    @api selectedSubIndustry;

    @track controllingValues = [];
    @track dependentValues = [];

    get isDepValueBlank() {
        if(this.dependentValues == undefined || this.dependentValues.length == 0) {
            return true;
        }
        return false;
    }
   
    @track error;
    @track controlValues;
    @track totalDependentValues = [];

    

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    objectInfo;

    /*
    * Picklist values based on record type
    */
    @wire(getPicklistValuesByRecordType, { objectApiName: ORDER_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
    industryPicklistValues({error, data}) {
        if(data) {
            this.error = null;

            let industryOptions = [{label:'--Select--', value:''}];
            
            data.picklistFieldValues.Industry__c.values.forEach(key => {
                industryOptions.push({
                    label : key.label,
                    value: key.value
                })
            });

            this.controllingValues = industryOptions;
            this.controlValues = data.picklistFieldValues.Sub_Industry__c.controllerValues;
            this.totalDependentValues = data.picklistFieldValues.Sub_Industry__c.values;

            console.log('this.selectedIndustry--in wire-',this.selectedIndustry);
            if(this.selectedIndustry){
                this.updateSubIndustryValues();
            }
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
    }

    /*
    * Update sub industry values on the basis of selected industry
    */
    updateSubIndustryValues() {
        let dependValues = [];
        if(this.totalDependentValues.length > 0) {
            //dependValues.push({label:'--Select--', value:''});
            this.totalDependentValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlValues[this.selectedIndustry]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })
        }
        this.dependentValues = dependValues;
    }

    /*
    * Set industry value
    * Null sub industry
    * Pass values to parent component through event
    */
    handleIndustryChange(event) {
        this.selectedIndustry = event.target.value;
        if(this.selectedIndustry) {

            this.updateSubIndustryValues();

            this.selectedSubIndustry = '';
            this.fireEventToUpdateDependantIndustry();

        }

        const industry =  this.selectedIndustry;
        const industryChangeEvent = new CustomEvent("industrychange", {detail: { industry }});
        // Fire the custom event
        this.dispatchEvent(industryChangeEvent);
    }

    /*
    * Set sub industry value
    */
    handleSubIndustryChange(event) {
        this.selectedSubIndustry = event.target.value;
        this.fireEventToUpdateDependantIndustry();
    }

    /*
    * Pass sub industry values to parent component through event
    */
    fireEventToUpdateDependantIndustry() {
        const subIndustry =  this.selectedSubIndustry;
        const subIndustryChangeEvent = new CustomEvent("subindustrychange", {detail: { subIndustry }});
        this.dispatchEvent(subIndustryChangeEvent);
    }

    /*
    * Validate input fields
    */
    @api
     validateInputs() {
        const allValid = [...this.template.querySelectorAll('[data-id="input"]')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

}