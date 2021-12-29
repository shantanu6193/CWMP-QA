/**
 * Created by Pankaj on 08-07-2020.
 */
import { LightningElement, wire, api, track} from 'lwc';

import submitRequest from '@salesforce/apex/CommunityAppPHOSRegistrationCtrl.processPHOSRequest';
import submitRejectedRequest from '@salesforce/apex/CommunityAppPHOSRegistrationCtrl.processPHOSRequestForRejection';
import getUserDetails from '@salesforce/apex/CommunityAppPHOSRegistrationCtrl.getUserDetails';


import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import COUNTY_FIELD from '@salesforce/schema/User_Registration__c.County__c';
import ENTITY_FIELD from '@salesforce/schema/User_Registration__c.Entity_Type__c';
import NON_GOVERNMENT_TYPE_FIELD from '@salesforce/schema/User_Registration__c.Non_Government_Entity_Type__c';
import { NavigationMixin } from 'lightning/navigation';
import apexSearchStateAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchStateAgency';
import apexSearchCity from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchCity';
import apexSearchTribal from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchTribal';
import apexSearchSpecialDistrict from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchSpecialDistrict';
import apexSearchCourts from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchCourts';
import apexSearchFacility from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFacility';
import apexGetFacilityDetails from '@salesforce/apex/CommunityRegistrationCtrl.getHealthCareFacilityDetails';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import Utility from 'c/utility';

export default class CommunityAppPhosRegistration extends Utility {

    @api appId;
    contactRecord;
    entityChangeRequired = false;

    stateRequired = [];
    courtsRequired = [];
    spclDistRequired = [];
    tribalRequired = [];
    cityRequired = [];
    healthCareRequired = [];
    facilityId;
    facilityAddress;
    selectedFacility = false;
    validLookups = true;
    loadLookupDataOnLoad = true;
    loadSpecialDistrictLookupDataOnLoad = false;
    buttonDisabled = false;

    /*
        * Check on users contact whether Entity_Change_Requested__c is true or false
    */
    initData() {
        this.executeAction(getUserDetails, {}, (response) => {
            console.log('-----resp------',response);
            this.contactRecord = response.ContactDetails;
            if(this.contactRecord.Entity_Change_Requested__c == true) {
                this.entityChangeRequired = true;
            }else {
                this.entityChangeRequired = false;
            }
            console.log('this.entityChangeRequired------',this.entityChangeRequired);
            console.log('this.contactRecord------',this.contactRecord);
        });
    }

    /*
        * Submit record to create user registration record for PHOS app
    */
    submitDetails() {
        this.recordLocal.Community_Application__c = this.appId;
        console.log('this.recordLocal',this.recordLocal);
        let allValid = false;
        if(this.entityChangeRequired == false) {
            allValid = true;
        }
        else {
            console.log('in else',this.validateFields());
            allValid = this.validateFields();
        }
        //console.log('allValid----',allValid);
        if(allValid) {
            //console.log('*******VALID*********');
            if(this.entityChangeRequired == false) {
                this.executeAction(submitRequest, {'userRegistrationStr' : JSON.stringify(this.recordLocal)}, (response) => {
                    this.showLoader = true;
                    this.buttonDisabled = true;
                    this.showSuccessNotification('Success', 'Your request sent for approval. You will be notified after access is granted.');
                    setTimeout(function(){
                        location. reload();
                    },2000);
                });
            }
            else {
                this.executeAction(submitRejectedRequest, {'userRegistrationStr' : JSON.stringify(this.recordLocal)}, (response) => {
                    this.showLoader = true;
                    this.buttonDisabled = true;
                    this.showSuccessNotification('Success', 'Your entity change request is sent for approval. You will be notified after access is granted.');
                    setTimeout(function(){
                        location. reload();
                    },2000);
                });
            }
        }
    }

    /*
        * Check whether contact record is null or not
    */
    get IsContactRecord(){
        if(this.contactRecord != null)
            return true;
            return false;
    }

    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTY_FIELD}) picklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ENTITY_FIELD}) entityPicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: NON_GOVERNMENT_TYPE_FIELD}) nonGovTypePicklistValues;

    /*
        * Check whether contact Non_Government_Entity_Type__c equals Health Care Facility
    */
    get isHealthCareFacility() {
        if(this.recordLocal != undefined && this.recordLocal.Non_Government_Entity_Type__c == 'Health Care Facility') {
            return true;
        }
        else {
            return false;
        }
    }

    /*
        * Check whether contact Non_Government_Entity_Type__c equals Other
    */
     get isOther() {
        if(this.recordLocal != undefined && this.recordLocal.Non_Government_Entity_Type__c == 'Other') {
            this.selectedFacility = false;
            return true;
        }
        else {
            return false;
        }
    }

    /*
        * Check whether contact Entity_Type__c equals Non-Governmental Entity
    */
    get isNonGov(){
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'Non-Governmental Entity') {
            return true;
        }
        return false;
    }

    /*
        * Check whether contact Non_Government_Entity_Type__c equals Other or Health Care Facility
    */
    get isNonGovEntityType() {
        if(this.recordLocal != undefined && (this.recordLocal.Non_Government_Entity_Type__c == 'Other' || this.recordLocal.Non_Government_Entity_Type__c == 'Health Care Facility')) {
            return true;
        }
        return false;
    }

    /*
        * Check whether contact Entity_Type__c equals State Agency
    */
    get isState() {
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'State Agency') {
            return true;
        }
        return false;
    }

    /*
        * Check whether contact Entity_Type__c equals County or Non_Government_Entity_Type__c equals Health Care Facility or Other
    */
    get isCounty() {
        if(this.recordLocal != undefined && (this.recordLocal.Entity_Type__c == 'County' || this.recordLocal.Non_Government_Entity_Type__c == 'Health Care Facility' || this.recordLocal.Non_Government_Entity_Type__c == 'Other')) {
            return true;
        }
        return false;
    }

    /*
        * Check whether contact Non_Government_Entity_Type__c equals City
    */
    get isCity() {
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'City') {
            return true;
        }
        return false;
    }

    /*
        * Check whether contact Entity_Type__c equals Tribal
    */
     get isTribal() {
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'Tribal') {
            return true;
        }
        return false;
    }

     /*
        * Check whether contact Entity_Type__c equals Tribal
    */
    get isSpecialDistrict() {
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'Special District') {
            return true;
        }
        return false;
    }

    /*
        * Check whether contact Entity_Type__c equals Courts
    */
    get isCourts() {
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'Courts') {
            return true;
        }
        return false;
    }

    /*
        * Set value to Entity_Type__c or Non_Government_Entity_Type__c
        * Set value to Null
    */
    entityChanged(event) {
        this.selectedFacility = false;
        this.recordLocal[event.target.getAttribute('data-field')] = event.target.value;
        let field = event.target.getAttribute('data-field');
        let fieldsToNull = [];
        if(field == 'Non_Government_Entity_Type__c') {
            fieldsToNull = ['Non_Governmental_Entity__c','Federal_Tax_ID__c','Facility__c','Facility_Name__c','Facility_ID__c','County__c','Street_Address__c','City_Name__c','State__c','Zip_Postal_Code__c'];
        }
        else {
            fieldsToNull = ['State_Agency__c','Non_Government_Entity_Type__c','Non_Governmental_Entity__c','Federal_Tax_ID__c','Facility__c','Facility_Name__c','Facility_ID__c','County__c','City__c','Tribal__c','Special_District__c','Courts__c','Street_Address__c','City_Name__c','State__c','Zip_Postal_Code__c'];
        }
        for(let i=0; i<fieldsToNull.length; i++) {
            this.setFieldsToBlank(fieldsToNull[i]);
        }
    }

    /*
        * Validate input fields
    */
    validateFields(){
        try{
        let validateInputs = this.validateInputs();
        //console.log('validateInputs',validateInputs);
        this.validateCustomInput();
        let lookupValid = this.validLookups;
        //console.log('lookupValid',lookupValid);
        if(validateInputs && lookupValid) {
            return true;
        }
        return false;
        }
        catch(e) {
            console.log(e);
        }
    }

    /*
        * Validate for any custom validation (Ex. lookup)
    */
    validateCustomInput() {
        try{
        this.healthCareRequired = [];
        this.stateRequired = [];
        this.cityRequired = [];
        this.spclDistRequired = [];
        this.tribalRequired = [];
        this.courtsRequired = [];
        if(this.recordLocal.Entity_Type__c == 'State Agency') {
            this.validateLookups('State_Agency__c','State Agency',this.stateRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'City') {
            this.validateLookups('City__c','City',this.cityRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'Special District') {
            this.validateLookups('Special_District__c','Special District',this.spclDistRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'Tribal') {
            this.validateLookups('Tribal__c','Tribal',this.tribalRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'Courts') {
            this.validateLookups('Courts__c','Courts',this.courtsRequired);
        }

        if(this.recordLocal.Entity_Type__c == 'Non-Governmental Entity' && this.recordLocal.Non_Government_Entity_Type__c == 'Health Care Facility') {
            if(this.recordLocal.Facility_Name__c == null && (this.recordLocal.Facility__c == null || this.recordLocal.Facility__c == '' || this.recordLocal.Facility__c == undefined)) {
                this.healthCareRequired.push({ message: 'Complete this field.' });
                this.validLookups = false;
            }
            else if((this.recordLocal.Facility__c == null || this.recordLocal.Facility__c == '' || this.recordLocal.Facility__c == undefined) && (this.recordLocal.Facility_Name__c != null && this.recordLocal.Facility_Name__c.length <= 2)) {
                this.healthCareRequired.push({ message: 'Facility Name should be more than 2 characters' });
                this.validLookups = false;
            }
            else {
                this.healthCareRequired = [];
                this.validLookups = true;
            }
        }
        }
        catch(e) {
            console.log(e);
        }
    }

    /*
        * Validate lookup fields
    */
    validateLookups(fieldApiName, entityType, errorField) {
        try{
        if(this.recordLocal.Entity_Type__c == entityType && (this.recordLocal[fieldApiName] == undefined || this.recordLocal[fieldApiName] == '')) {
            errorField.push({ message: 'Complete this field.' });
            this.validLookups = false;
        }
        else {
            this.validLookups = true;
        }
        }
        catch(e) {
            console.log(e);
        }
    }

    /*
        * Searches account with Entity_Type__c equals State_Agency__c
    */
    handleStateAgencySearch(event) {
        apexSearchStateAgency(event.detail)
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="State_Agency__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
        * Lookup selection for State_Agency__c
    */
    handleStateAgencyChange(response) {
        if(!response.detail){
           this.recordLocal.State_Agency__c = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.State_Agency__c = response.detail.selectedItem.id;
        }
    }

    /*
        * Searches account with Entity_Type__c equals City__c
    */
    handleCitySearch(event) {
        apexSearchCity(event.detail)
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="City__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
        * Lookup selection for City__c
    */
    handleCityChange(response) {
        if(!response.detail){
            this.recordLocal.City__c = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.City__c = response.detail.selectedItem.id;
        }
    }

    /*
        * Searches account with Entity_Type__c equals Tribal__c
    */
    handleTribalSearch(event) {
        apexSearchTribal(event.detail)
        .then((results) => {
            //console.log('results----', results);
            this.template.querySelector('[data-lookup="Tribal__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
        * Lookup selection for Tribal__c
    */
    handleTribalChange(response) {
        if(!response.detail){
            this.recordLocal.Tribal__c = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Tribal__c = response.detail.selectedItem.id;
        }
    }

    /*
        * Searches account with Entity_Type__c equals Special_District__c
    */
    handleSpecialDistrictSearch(event) {
        apexSearchSpecialDistrict(event.detail)
        .then((results) => {
            //console.log('results----', results);
            this.template.querySelector('[data-lookup="Special_District__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
        * Lookup selection for Special_District__c
    */
    handleSpecialDistrictChange(response) {
        if(!response.detail){
            this.recordLocal.Special_District__c = ''
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Special_District__c = response.detail.selectedItem.id;
        }
    }

    /*
        * Searches account with Entity_Type__c equals Courts__c
    */
    handleCourtSearch(event) {
        apexSearchCourts(event.detail)
        .then((results) => {
            //console.log('results----', results);
            this.template.querySelector('[data-lookup="Courts__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
        * Lookup selection for Courts__c
    */
    handleCourtChange(response) {
        if(!response.detail){
            this.recordLocal.Courts__c = ''
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Courts__c = response.detail.selectedItem.id;
        }
    }

    /*
        * Set searchTerm to Facility_Name__c for creation of new account
    */
    handleSearchChange(response) {
        let searchTerm = response.detail.searchTerm;
        this.recordLocal.Facility_Name__c = searchTerm;
    }

    /*
        * Searches account with Entity_Type__c equals Facility_Name__c
    */
    handleFacilitySearch(event) {
        this.recordLocal.Facility_Name__c = event.detail.searchTerm;
        console.log('----this.recordLocal.Facility_Name__c',this.recordLocal.Facility_Name__c);
        apexSearchFacility(event.detail)
        .then((results) => {
            //console.log('results----', results);
            this.template.querySelector('[data-lookup="Facility__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
        * Lookup selection for Facility_Name__c
    */
    handleFacilityChange(response) {
        if(!response.detail){
            this.recordLocal.Facility__c = '';
            this.recordLocal.Facility_Name__c = '';
            this.recordLocal.Facility_ID__c = '';
            this.recordLocal.Street_Address__c = '';
            this.recordLocal.City_Name__c = '';
            this.recordLocal.State__c = '';
            this.recordLocal.County__c = '';
            this.recordLocal.Zip_Postal_Code__c = '';
            this.selectedFacility = false;
        }
        if(response.detail.selectedItem.id != undefined) {
            this.recordLocal.Facility__c = response.detail.selectedItem.id;
            apexGetFacilityDetails({facilityId : this.recordLocal.Facility__c})
            .then((results) => {
                //console.log('results from apex----', results);
                this.recordLocal.Facility_Name__c = results[0].Name;
                this.recordLocal.Facility_ID__c = results[0].Entity_Id__c;
                this.recordLocal.Street_Address__c = results[0].ShippingStreet;
                this.recordLocal.City_Name__c = results[0].ShippingCity;
                this.recordLocal.Zip_Postal_Code__c = results[0].ShippingPostalCode;
                this.recordLocal.State__c = results[0].ShippingState;
                if(results[0].Parent != undefined) {
                    this.recordLocal.County__c = results[0].Parent.Name;
                }
                this.selectedFacility = true;
            })
            .catch((error) => {
                console.log('error---',error);
            });
        }
    }
}