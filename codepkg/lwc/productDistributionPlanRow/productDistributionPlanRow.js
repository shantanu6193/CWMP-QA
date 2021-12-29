/**
 * Created by Shivraj on 27-08-2020.
 */

import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import apexSearchFacility from '@salesforce/apex/PHOS_DistributionCtrl.apexSearchFacility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
//import FACILITY_TYPE_FIELD from '@salesforce/schema/Account.Facility_Type__c';
import FACILITY_CATEGORY_FIELD from '@salesforce/schema/Account.Facility_Category__c';

export default class ProductDistributionPlanRow extends Utility {
    @api index;
    currentIndex = 1;
    loadFacilityLookupData = false;
    isMultiEntry = false;
    healthCareRequired = [];
    selectedFacility = false;
    facilityInitialSelection;
    showField = true;
    @api facilityCategoryPicklistValues;
    @api countyOptions;

    /*
    * Get picklist values
    */
    //@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT }) objectInfo;

    //@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FACILITY_TYPE_FIELD}) facilityTypePicklistValues;
    //@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FACILITY_CATEGORY_FIELD}) facilityCategoryPicklistValues;

    /*
    * Initially selects a Facility__c if present
    * Set County picklist values
    */
    initData() {
        if(this.recordLocal != undefined && this.recordLocal.Facility__r != undefined) {
            this.facilityInitialSelection = [
                {
                    id: this.recordLocal.Facility__c,
                    sObjectType: 'Facility__c',
                    icon: 'standard:account',
                    title: this.recordLocal.Facility__r.Name,
                    subtitle: ''
                }
            ];
            this.selectedFacility = true;
        } else if (this.recordLocal != undefined && this.recordLocal.Facility__r == undefined
                    && this.recordLocal.Facility_Name__c != undefined) {
            this.facilityInitialSelection = [
                {
                    id: this.recordLocal.Facility__c,
                    sObjectType: 'Facility__c',
                    icon: 'standard:account',
                    title: this.recordLocal.Facility_Name__c,
                    subtitle: ''
                }
            ];
            this.selectedFacility = true;
        }
    }

    /*
    * Searches account with Entity_Type__c equals Health Care Facility
    */
    handleFacilitySearch(event) {
        this.recordLocal.Facility_Name__c = event.detail.searchTerm;
        apexSearchFacility(event.detail)
        .then((results) => {
            try{
            this.template.querySelector('[data-lookup="Facility__c"]').setSearchResults(results);
            }
            catch(e){
                console.log(e);
            }
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Facility__c
    */
    handleFacilityChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined ) {
            this.recordLocal.Facility__c = response.detail.selectedItem.id;
            this.recordLocal.Facility_Name__c = response.detail.selectedItem.sObject.Name;
            if(response.detail.selectedItem.sObject.Parent != undefined) {
                this.recordLocal.County__c = response.detail.selectedItem.sObject.Parent.Id;
            }
            this.recordLocal.Facility_Code__c = response.detail.selectedItem.sObject.Entity_Id__c;
            //this.recordLocal.Facility_Type__c = response.detail.selectedItem.sObject.Facility_Type__c;
            this.recordLocal.Facility_Category__c = response.detail.selectedItem.sObject.Facility_Category__c;
            this.selectedFacility = true;
            this.showField = false;
            setTimeout(() => {
                this.showField = true;
            }, 50);
        }
        else {
            this.recordLocal.Facility__c = '';
            this.recordLocal.Facility_Name__c = '';
            this.recordLocal.County__c = '';
            this.recordLocal.Facility_Code__c = '';
            //this.recordLocal.Facility_Type__c = '';
            this.recordLocal.Facility_Category__c = '';
            this.selectedFacility = false;
            this.showField = false;
            setTimeout(() => {
                this.showField = true;
            }, 50);
        }
    }

    /*
    * Add empty row
    */
    addPlan(event){
        //this.recordLocal.Product_Distribution_Plans__r.push(this.recordLocal);
        event.preventDefault();
        let item = {};
        const addEvent = new CustomEvent('added', { detail: {recordData:item}});
        this.dispatchEvent(addEvent);
    }

    /*
    * Delete selected row
    */
    deletePlan(event){
        event.preventDefault();
        const deleteEvent = new CustomEvent('deleted', { detail: {index:this.index }});
        this.dispatchEvent(deleteEvent);
    }
    /*
    * Validate lookup field
    */
    validateCustomInput() {
        let isSuccess = true;
        this.healthCareRequired = [];
        if(this.recordLocal.Facility_Name__c == undefined || this.recordLocal.Facility_Name__c == '') {
            this.healthCareRequired.push({ message: 'Complete this field.' });
            isSuccess = false;
        }
        return isSuccess;
    }

    updateProposedQuantity(event) {
        event.preventDefault();
        let proposedQuantity = 0;
        if(event.target.value) {
            proposedQuantity = event.target.value;
        }
        const addEvent = new CustomEvent('proposedquantityupdated', { detail: {recordData:proposedQuantity}});
        this.dispatchEvent(addEvent);
    }

    updateActualQuantity(event) {
        event.preventDefault();
        let actualQuantity = 0;
        if(event.target.value) {
          actualQuantity = event.target.value;
        }
        const addEvent = new CustomEvent('actualquantityupdated', { detail: {recordData:actualQuantity}});
        this.dispatchEvent(addEvent);
    }

    @api
    getRecordLocal() {
        return this.recordLocal;
    }
}