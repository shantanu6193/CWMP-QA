import { LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import COUNTY_FIELD from '@salesforce/schema/User_Registration__c.County__c'
//import STATE_FIELD from '@salesforce/schema/User_Registration__c.State_Agency__c';
import ENTITY_FIELD from '@salesforce/schema/User_Registration__c.Entity_Type__c';
import getStateAgencies from '@salesforce/apex/CountyUserReigstrationCtrl.getStateAgencies';
import saveRecord from '@salesforce/apex/CountyUserReigstrationCtrl.createUserRegistrationRequest';
import { NavigationMixin } from 'lightning/navigation';
import apexSearchStateAgency from '@salesforce/apex/CountyUserReigstrationCtrl.apexSearchStateAgency';

export default class CountyUserRegistration extends NavigationMixin(LightningElement) {
    @api buttonlabel;

    @track value;
    @track entityValue;
    @track nonGovEntity;
    @track federalTaxId;
    @track stateValue;
    @track emailValid;
    @track firstname;
    @track lastname;
    @track email;
    @track phone;
    @track result;
    @track error;
    @track isModalOpen = false;
    @track disabledSignUpButton = true;
    @track isCounty = false;
    @track isState = false;
    @track isNonGov = false;
    

    // Custom Toast
    @api message = 'Sample Message';
    @api variant = 'error';
    @api autoCloseTime = 5000;
    @api showToast = false;
    @api autoCloseErrorWarning = false;

    /*
    * Get picklist values
    */
    @wire(getObjectInfo, { objectApiName: UR_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTY_FIELD
    })
    picklistValues;

    /*@wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STATE_FIELD
    })
    statePicklistValues;*/

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ENTITY_FIELD
    })
    entityPicklistValues;

    @wire(getStateAgencies)
        statePicklistValues;

    /*
    * Get State_Agency__c values values
    */
    get stateOptions() {
        // eslint-disable-next-line no-console
        console.log('>>>>'+JSON.stringify(this.statePicklistValues.data));
        return this.statePicklistValues.data;
    }
    
    /*
    * Set input field values
    */
    handleChange(event) {
        if (event.target.name === 'First Name') {
            this.firstname = event.target.value;
        }
        if (event.target.name === 'Last Name') {
            this.lastname = event.target.value;
            this.validateEmailAddress();
        }
        if (event.target.name === 'Email') {
            this.email = event.target.value;
        }
        if (event.target.name === 'Phone') {
            this.phone = event.target.value;
        }
        if (event.target.name === 'County') {
            this.value = event.detail.value;
            console.log('State---',this.stateValue);
            this.validateEmailAddress();
        }   
        if (event.target.name === 'EntityType') {
            this.entityValue = event.detail.value;
            if(this.entityValue === 'County'){
                this.isCounty = true;
                this.isState = false;
                this.isNonGov = false;
            }else if(this.entityValue === 'State Agency'){
                this.isState = true;
                this.isCounty = false;
                this.isNonGov = false;
            }else if(this.entityValue === 'Non-Governmental Entity'){
                this.isNonGov = true;
                this.isCounty = false;
                this.isState = false;
            }
            this.value ='';
            this.stateValue = '';
            this.nonGovEntity = '';
            this.federalTaxId = '';
            this.validateEmailAddress();
        } 
        /*if (event.target.name === 'StateAgency') {
            this.stateValue = event.detail.value;
            this.validateEmailAddress();
        }*/
        if (event.target.name === 'NonGovernmentalEntity') {
            this.nonGovEntity = event.target.value;
            this.validateEmailAddress();
        }
        if (event.target.name === 'FederalTaxID') {
            this.federalTaxId = event.target.value;
            this.validateEmailAddress();
        }
    }

    /*
    * Set email field value
    * Validate custom email field
    */
    handleEmailFieldChange(event) {
        this.email = event.target.value;
        this.validateEmailAddress();
    }

    /*
    * Disable sign up button when fields are empty
    */
    validateEmailAddress(){
        if(this.lastname == null || this.lastname == '' || this.email == null || this.email == '' || this.emailValid == false || this.entityValue === null || this.entityValue == '' || 
        ((this.value == null || this.value == '' || this.value === 'undefined') && (this.stateValue == null || this.stateValue == '' || this.stateValue === 'undefined') && ((this.nonGovEntity == null || this.nonGovEntity == '' || this.nonGovEntity === 'undefined') || (this.federalTaxId == null || this.federalTaxId == '' || this.federalTaxId === 'undefined')))){
            this.disabledSignUpButton = true;
        }else{
            this.disabledSignUpButton = false;
        }
    }

    /*
    * Validate email address
    */
    handleEmailBlur() {
        let emailFieldCmp = this.template.querySelector('.emailField');
        let mailRegex =  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        let emailAddress =  this.email;
        let mailMatcher = mailRegex.test(emailAddress);
        let allValid = true;
        if(mailMatcher == false ){
            allValid = false;
            emailFieldCmp.setCustomValidity('Email address not in proper format');
        } else {
        emailFieldCmp.setCustomValidity('');
        
        }
        emailFieldCmp.reportValidity();
        this.emailValid = allValid;
        this.validateEmailAddress();
        return allValid;
    }

    /*
    * Open modal
    */
    showModalPopUp(){
        this.isModalOpen = true;
    }
    
    /*
    * Process sign up request
    */
    signup(){
        saveRecord({fname : this.firstname, lname : this.lastname, email : this.email, phone : this.phone, entity: this.entityValue, county : this.value, state : this.stateValue, nongov : this.nonGovEntity, federalTaxId : this.federalTaxId})
        .then(result => {  
            //this.isModalOpen = true; 
            this.showNotification('Success', 'Your request has been recieved. You will recieve email once your request is approved', 'success');
            setTimeout(() => {
                this.navigateSignUpPage();
            }, 8000);                                     
        })
        .catch(error => {
            console.log('error>>',error.body.message);
            this.isModalOpen = false;
            //this.error = error.body.message;
            
            //this.showCustomNotice();
            let errorMessage = error.body && error.body.message ? error.body.message : 'Something went wrong, please contact your administrator.';
            console.error('Method ' + errorMessage);
            this.showNotification('Error', errorMessage, 'error');
        });   
    }

    /*
    * Show custom toast
    */
    showNotification = (_title, _message, _variant) => {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
            mode: 'sticky',
        });
        this.dispatchEvent(evt);
    };
    /*
    @api
    showCustomNotice() {
        //Custom Toast
        this.message = this.error;
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-show';
        if( (this.autoCloseErrorWarning && this.variant !== 'error') || this.variant === 'error') {
            this.delayTimeout = setTimeout(() => {
                const toastModel = this.template.querySelector('[data-id="toastModel"]');
                toastModel.className = 'slds-hide';
            }, this.autoCloseTime);
            
        }
    }
    */          

    /*
    * Redirect to login page
    */
    navigateSignUpPage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            }
            });
    }

    loadLookupDataOnLoad = true;

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
            this.stateValue = '';
            this.validateEmailAddress();
        }
        if(response.detail.selectedItem.id != undefined) {
            this.stateValue = response.detail.selectedItem.id;
            this.validateEmailAddress();
        }
        
        
    }
}