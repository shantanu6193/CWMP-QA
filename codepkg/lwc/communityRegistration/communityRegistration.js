import { LightningElement, wire, api, track} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
//import COUNTY_FIELD from '@salesforce/schema/User_Registration__c.County__c';
import ENTITY_FIELD from '@salesforce/schema/User_Registration__c.Entity_Type__c';
import NON_GOVERNMENT_TYPE_FIELD from '@salesforce/schema/User_Registration__c.Non_Government_Entity_Type__c';
//import getStateAgencies from '@salesforce/apex/CommunityRegistrationCtrl.getStateAgencies';
import saveRecord from '@salesforce/apex/CommunityRegistrationCtrl.createUserRegistration';
import { NavigationMixin } from 'lightning/navigation';
import apexSearchStateAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchStateAgency';
import apexSearchFireAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFireAgency';
import apexSearchFederalAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFederalAgency';
import apexSearchMARSpayingEntity from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchMARSpayingEntity';
import apexSearchCity from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchCity';
import apexSearchTribal from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchTribal';
import apexSearchSpecialDistrict from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchSpecialDistrict';
import apexSearchCourts from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchCourts';
import apexSearchFacility from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFacility';
import apexGetFacilityDetails from '@salesforce/apex/CommunityRegistrationCtrl.getHealthCareFacilityDetails';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import registrationSuccessLabel from '@salesforce/label/c.Common_Registration_Success_Message';
import getCountyAccountList from '@salesforce/apex/CommunityRegistrationCtrl.getCountyAccountList';
import getContactRecords from '@salesforce/apex/CommunityRegistrationCtrl.getContactRecords';
import Utility from 'c/utility';
import UserId from '@salesforce/user/Id';

export default class CommunityRegistration extends Utility {

    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    cdphLogo =  headerLogo + '/headerLogo/CDPH_Logo.jfif';
    emsaLogo = headerLogo + '/headerLogo/EMSA_Logo.jfif';
    isIE = false;

    @api buttonlabel;
    stateRequired = [];
    fireagencyRequired = [];
    federalAgencyRequired = [];
    marspayingentityrequired = [];
    courtsRequired = [];
    spclDistRequired = [];
    tribalRequired = [];
    cityRequired = [];
    healthCareRequired = [];
    facilityId;
    facilityAddress;
    selectedFacility = false;
    validLookups = true;
    buttonDisabled = false;

    buttonDisabled = false;

    hideEntityDropDown = false;
    hideFireDropDown = false;
    hideEmailField = false;

    paramTypeValue='';
    paramAgencyValue='';
    paramAccountIdValue='';
    paramEmailValue='';
    countyOptions;
    urlParameters;
    @track contactRecord;
    isContactIdProvided = false;
    contactId;

    /*
    * Check whether current browser is Internet explorer or not
    */
    initData() {
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");

        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
            this.isIE = true;
        }
        else {
            this.isIE = false;
        }
        if(UserId) {
            window.location.href = '/s';
        }

        //load url parameter for HMA FEMA User
        this.getURLParams();


        ///Prefill Entity Type and Fire Agency on Passed URL Paramaters

        const paramType = 'type';
        const paramAgency = 'agency';
        const paramAccountId = 'accountid';
        const pramEmail = 'email';

        this.paramTypeValue = this.getUrlParamValue(window.location.href, paramType);
        this.paramAgencyValue = this.getUrlParamValue(window.location.href, paramAgency);
        this.paramAccountIdValue = this.getUrlParamValue(window.location.href, paramAccountId);
        this.paramEmailValue = this.getUrlParamValue(window.location.href, pramEmail);

        if(this.paramTypeValue !== null )
        {        
            this.recordLocal.Entity_Type__c = this.paramTypeValue;
  


            if(this.paramTypeValue == 'Fire Agency')
            {
                this.recordLocal.Fire_Agency__c = this.paramAccountIdValue;

                this.hideFireDropDown = true;
                this.hideEntityDropDown = true;
    
            }

            console.log(this.paramEmailValue);

            if(this.paramEmailValue != null)
            {

                this.hideEmailField = true;
                this.recordLocal.Email__c = this.paramEmailValue;
                console.log(this.recordLocal.Email__c);

    
            }


        }


    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    getCountyAccountList() {
        getCountyAccountList()
        .then((result) => {
            console.log('county='+JSON.stringify(result));
            if(result){
                let countyList = result;
                let countyValues = [];
                for(let i = 0; i < countyList.length; i++) {
                    countyValues.push({
                    label: countyList[i].Name,
                    value: countyList[i].Name
                    })
                }
                this.countyOptions = countyValues;
            }
        })
        .catch((error) => {
            console.log('County account error--',error); 
        });
    }
  
    /*
    * Get picklist values
    */
    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;

    //@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTY_FIELD}) picklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ENTITY_FIELD}) entityPicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: NON_GOVERNMENT_TYPE_FIELD}) nonGovTypePicklistValues;

    //@wire(getStateAgencies) statePicklistValues;

    /*
    * Get State picklist values
    */
    get stateOptions() {
        console.log('>>>>'+JSON.stringify(this.statePicklistValues.data));
        return this.statePicklistValues.data;
    }

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
    * Check whether contact Entity_Type__c equals Fire Agency
    */

    get isFireAgency() {

        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'Fire Agency') {
            return true;
        }
        return false;
    }

      /*
    * Check whether contact Entity_Type__c equals MARS Paying Entity
    */

    get isFederalEntity() {

        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'Federal Agency') {
            return true;
        }
        return false;
    }

      /*
    * Check whether contact Entity_Type__c equals MARS Paying Entity
    */
      get isMARSPayingEntity() {
        if(this.recordLocal != undefined && this.recordLocal.Entity_Type__c == 'MARS Paying Entity') {
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
    * Check whether contact Entity_Type__c equals Special District
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
            fieldsToNull = ['State_Agency__c','Fire_Agency__c', 'MARS_Paying_Entity__c','Non_Government_Entity_Type__c','Non_Governmental_Entity__c','Federal_Tax_ID__c','Facility__c','Facility_Name__c','Facility_ID__c','County__c','City__c','Tribal__c','Special_District__c','Courts__c','Street_Address__c','City_Name__c','State__c','Zip_Postal_Code__c'];
        }
        for(let i=0; i<fieldsToNull.length; i++) {
            this.setFieldsToBlank(fieldsToNull[i]);
        }
        if(this.recordLocal.Entity_Type__c == 'County' || this.recordLocal.Entity_Type__c == 'Non-Governmental Entity') {
            this.getCountyAccountList();
        }
    }

    /*
    * Validate input fields
    */
    validateFields(){
        let lastNameValid = this.handleLastNameValidation();
        let phoneValid = this.handlePhoneValidation();
        let validateInputs = this.validateInputs();
        let emailValid = false;

        if(this.hideEmailField == true){
            console.log('customEmail');
            emailValid = true;
        }
        else{
            console.log('regularEmail');
            emailValid = this.handleEmailBlur();
        }

        this.validateCustomInput();
        let lookupValid = this.validLookups;
        


        console.log(validateInputs);
        console.log(emailValid);
        console.log(lookupValid);
        console.log(phoneValid);

        if(lastNameValid && validateInputs && emailValid && lookupValid && phoneValid) {

        console.log('return true');


            return true;
        }


        console.log('return false');

        return false;
    }

    /*
    * Validate for any custom validation (Ex. lookup)
    */
    validateCustomInput() {
        this.healthCareRequired = [];
        this.stateRequired = [];
        this.fireagencyRequired = [];
        this.federalAgencyRequired = [];
        this.cityRequired = [];
        this.spclDistRequired = [];
        this.tribalRequired = [];
        this.courtsRequired = [];
        if(this.recordLocal.Entity_Type__c == 'State Agency') {
            this.validateLookups('State_Agency__c','State Agency',this.stateRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'Fire Agency') {
            this.validateLookups('Fire_Agency__c','Fire Agency',this.fireagencyRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'Federal Agency') {
            this.validateLookups('Federal_Agency__c','Federal Agency',this.federalAgencyRequired);
        }
        if(this.recordLocal.Entity_Type__c == 'MARS Paying Entity') {
            this.validateLookups('MARS_Paying_Entity__c','MARS Paying Entity',this.marspayingentityrequired);
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

    /*
    * Validate lookup fields
    */
    validateLookups(fieldApiName, entityType, errorField) {
        if(this.recordLocal.Entity_Type__c == entityType && (this.recordLocal[fieldApiName] == undefined || this.recordLocal[fieldApiName] == '')) {
            errorField.push({ message: 'Complete this field.' });
            this.validLookups = false;
        }
        else {
            this.validLookups = true;
        }
    }

    /*
    * Validate last name validation
    */
    handleLastNameValidation(){
        let lastNameCmp = this.template.querySelector('.lastNameField');
        let lastName =  this.recordLocal.Last_Name__c;
        if(lastName){
            lastName = lastName.trim();
            this.recordLocal.Last_Name__c = this.recordLocal.Last_Name__c.trim();
        }
        let allValid = true;
        if(lastName == null || lastName == undefined || lastName == ''){
            lastNameCmp.setCustomValidity('Complete this field.');
            allValid = false;
        }
        else{
            lastNameCmp.setCustomValidity('');
        }
        lastNameCmp.reportValidity();
        return allValid;
    }
    /*
    * Custom email field validation
    */
    handleEmailBlur() {

        let emailFieldCmp = this.template.querySelector('.emailField');
        let mailRegex =  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
		
		this.recordLocal.Email__c = this.recordLocal.Email__c.trim(); 
        let emailAddress =  this.recordLocal.Email__c;
        let allValid = true;
        if(emailAddress == null || emailAddress == undefined || emailAddress == ''){
            emailFieldCmp.setCustomValidity('Complete this field.');
            allValid = false;
        }
        else{
            let mailMatcher = mailRegex.test(emailAddress);
            if(mailMatcher == false ){
                allValid = false;
                emailFieldCmp.setCustomValidity('Email address not in proper format');
            }else {
                emailFieldCmp.setCustomValidity('');
            }  
        }
        emailFieldCmp.reportValidity();
        return allValid;
    }

    /*
    * Custom phone field validation
    */
    handlePhoneValidation(event){
        
        let number = this.recordLocal.Phone__c;
        let inputCmp = this.template.querySelector('.phoneField');
        let allValidPhone = true;
        if(number == null || number == undefined || number == ''){
            inputCmp.setCustomValidity("Complete this field."); 
            allValidPhone = false;
        }
        else{
            let cleanedNumber = ('' + number).replace(/\D/g, '');
            let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
            let newNumber = '';
            if (phoneNumber) {
                newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
                console.log('newNumber',newNumber);
                this.recordLocal.Phone__c = newNumber;
            }
            var value = this.recordLocal.Phone__c;
            console.log('value---',value);
            if (value != newNumber) {
                allValidPhone =false;
                inputCmp.setCustomValidity("Enter a valid phone number ex:(555) 555-5555");
            } else {
                inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
            }
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        return allValidPhone;
    }

    /*
    * Validate fields and process sign up request
    */
    signup(){
        let allValid = false;
        /*If contact id provided in the URL then we are considered the data is valid and for disabled fields setCustomValidity not working*/
        if(this.isContactIdProvided){
            allValid = true;
        } else{
            allValid = this.validateFields();
        }
        //let allValid = this.validateFields();
        console.log('allValid----',allValid);
        console.log('record------>',JSON.stringify(this.recordLocal));
        console.log('record------>',this.recordLocal);
        if(allValid) {
            this.executeAction(saveRecord, {'record' : JSON.stringify(this.recordLocal)}, (response) => {
                    this.showLoader = true;
                    this.buttonDisabled = true;
                    this.showNotification('Success', registrationSuccessLabel, 'success','sticky');
                    setTimeout(() => {
                        this.navigateSignUpPage();
                    }, 3000);
             });
         }
         else {
             this.buttonDisabled = false;
             this.showNotification('Error', 'Please fill all required fields', 'Error','dismissable');
         }
    }

    /*
    * Redirect to sign up page
    */
    navigateSignUpPage(){
        this.redirectToCommunityLoginPage();
    }

    loadLookupDataOnLoad = true;
    loadSpecialDistrictLookupDataOnLoad = false;

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
    * Searches account with Entity_Type__c equals Fire_Agency__c
    */
     handleFireAgencySearch(event) {
        apexSearchFireAgency(event.detail)
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="Fire_Agency__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Fire_Agency__c
    */
    handleFireAgencyChange(response) {
        if(!response.detail){
           this.recordLocal.Fire_Agency__c = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Fire_Agency__c = response.detail.selectedItem.id;
        }
    }


     /*
    * Searches account with Entity_Type__c equals Federal_Agency__c
    */
     handleFederalAgencySearch(event) {
        apexSearchFederalAgency(event.detail)
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="Federal_Agency__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Federal_Agency__c
    */
    handleFederalAgencyChange(response) {
        if(!response.detail){
           this.recordLocal.Federal_Agency__c = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Federal_Agency__c = response.detail.selectedItem.id;
        }
    }

     /*
    * Searches account with Entity_Type__c equals MARS Paying Entity
    */
     handleMarspayingEntitySearch(event) {
        apexSearchMARSpayingEntity(event.detail)
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="MARS_Paying_Entity__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the MARS Paying Entity lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Fire_Agency__c
    */
    handleMarspayingEntityChange(response) {
        if(!response.detail){
           this.recordLocal.MARS_Paying_Entity__c = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.MARS_Paying_Entity__c = response.detail.selectedItem.id;
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
            console.log('results----', results);
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
            console.log('results----', results);
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
            console.log('results----', results);
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
        apexSearchFacility(event.detail)
        .then((results) => {
            console.log('results----', results);
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
                console.log('results from apex----', results);
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

    /*
    * Redirect to login page
    */
    redirectToLogin(){
        window.location.href = '/s/login/';
    }

    /*
    * Check if contact id is there or not in url
    */
    contactIdInURL(contactId) {
        if(contactId === null || contactId === undefined || contactId === '') return false;
        let queryString = window.location.search;
        let urlParams = new URLSearchParams(queryString);
        let contactIdFromUrl = urlParams.get(contactId);
        return (contactIdFromUrl != null && contactIdFromUrl != undefined && contactIdFromUrl != '');
    }

    getURLParams() {
        console.log('in gel url');
        let queryString = window.location.search;
        this.urlParameters = new URLSearchParams(queryString);
        this.contactId = this.urlParameters.get('contactId');
        if(this.contactId) {
            console.log('contactId--', this.contactId);
            this.getContactRecords();
        }
        
    }

    getContactRecords() {
        getContactRecords({contactRecordId : this.contactId}).then(res => {
            console.log('in contactRecords');
            if(res.Success) {
                console.log('res---', res);
                this.recordLocal.First_Name__c = res.ContactRecord.FirstName;
                this.recordLocal.Last_Name__c = res.ContactRecord.LastName;
                this.recordLocal.Email__c = res.ContactRecord.Email;
                this.recordLocal.Phone__c = res.ContactRecord.Phone;
                this.recordLocal.Contact_Name__c = res.ContactRecord.Id;
                this.recordLocal.Entity_Type__c = res.ContactRecord.Account.Entity_Type__c;
                this.recordLocal.AccountName = res.ContactRecord.Account.Name;
                this.isContactIdProvided = true;
            }
        }).catch(err => {
            console.log('error---', err);
        })
    }
}