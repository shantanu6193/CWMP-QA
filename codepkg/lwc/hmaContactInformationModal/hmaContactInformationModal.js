import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import processOnContactInformation from '@salesforce/apex/HMA_ApplicationCtrl.processOnContactInformation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import ENTITY_TYPE_FIELD from '@salesforce/schema/User_Registration__c.Entity_Type__c';
import COUNTY_FIELD from '@salesforce/schema/User_Registration__c.County__c';
import NON_GOVERNMENT_TYPE_FIELD from '@salesforce/schema/User_Registration__c.Non_Government_Entity_Type__c';
import apexSearchStateAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchStateAgency';
import apexSearchCity from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchCity';
import apexSearchTribal from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchTribal';
import apexSearchSpecialDistrict from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchSpecialDistrict';
import apexSearchCourts from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchCourts';
import apexSearchFireAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFireAgency';
import apexSearchFacility from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFacility';
import apexGetFacilityDetails from '@salesforce/apex/CommunityRegistrationCtrl.getHealthCareFacilityDetails';
import getAccountInformation from '@salesforce/apex/HMA_ApplicationCtrl.getAccountDetails';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class HmaContactInformationModal extends Utility {
    @track contactRec = {};
    @track contactRoles = {};
    //@track conRole = 'Maintenance Commitment';
    @track type = 'Alternate';
    @api showModal;
    @api conRole;
    @api applicationId;
    @api editContactRoleRecord;
    @api tableConfig;
    stateRequired = [];
    cityRequired = [];
    tribalRequired = [];
    spclDistRequired = [];
    courtsRequired = [];
    fireagencyRequired = [];
    healthCareRequired = [];
    accountRec;
    @track UserRegistrationRec={};
    error;
    @track entityPicklist;
    @track entityType;
    @track stateAgency;
    @track city;
    @track tribal;
    @track spclDistrict;
    @track court;
    @track fireAgency;
    @track nonGovtEntityType;
    @track selectedFacility;
    @track nonGovtEntityRecord = {
        FacilityName : ''
    };
    @track editMode = false;
    @track accountName = '';

    entityWithAccountId;
    entityWithoutAccountId;
    accountId;
    contactRoleList = [];
    rolePicklistValues = [
        {value : 'Primary Contact', label : 'Primary Contact'},
        {value : 'Responsible Representative', label : 'Responsible Representative'},
        {value : 'Contributor', label : 'Contributor'},
        {value : 'Viewer', label : 'Viewer'}
    ]
    value = 'inProgress';
    loadLookupDataOnLoad = true;
    loadSpecialDistrictLookupDataOnLoad = false;


    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    @wire(getObjectInfo, {objectApiName : ACCOUNT_OBJECT}) accountObjectInfo;
    @wire(getObjectInfo, {objectApiName : UR_OBJECT}) urObjectInfo;

    @wire(getPicklistValues, {recordTypeId: '$accountObjectInfo.data.defaultRecordTypeId', fieldApiName: ENTITY_TYPE_FIELD}) entityPicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$urObjectInfo.data.defaultRecordTypeId', fieldApiName: COUNTY_FIELD}) countyPicklistValues;  
    @wire(getPicklistValues, {recordTypeId: '$urObjectInfo.data.defaultRecordTypeId', fieldApiName: NON_GOVERNMENT_TYPE_FIELD}) nonGovTypePicklistValues;
    

    initData(){
        if(this.editContactRoleRecord) {
            this.contactRoles = JSON.parse(JSON.stringify(this.editContactRoleRecord));
            this.contactRec = this.editContactRoleRecord.Contact__r;
            this.conRole = this.editContactRoleRecord.Role__c;
            console.log('contactRoles_Init : ', JSON.parse(JSON.stringify(this.contactRoles)));
            console.log('contactRec_Init : ', JSON.parse(JSON.stringify(this.contactRec)));
            if(this.editContactRoleRecord.Role__c) {
                this.contactRoleList = this.editContactRoleRecord.Role__c.split(';');
             }
            if(this.contactRec?.Id) {
                this.editMode = true;
                this.executeAction(getAccountInformation, {contactId : this.contactRec.Id}, res => {
                    if(res != undefined && res != '') {
                        this.accountName = res;
                    }
                });
            }
        }
    }
    get getButtonLabel() {
        console.log('contactRoles ', this.contactRoles);
        console.log('contactRec ', this.contactRec);
        if(this.contactRoles.Id) {
            return "Update Contact";
        } else {
            return "Add Contact";
        }
    }

    get renderContactRoles() {
        return (this.tableConfig && this.tableConfig['ModalName'] == 'SubApplication User Roles');
    }

    get showEntityTypePicklist() {
        return ((this.conRole.includes('Contributor') || this.conRole.includes('Viewer')) && (this.conRole.indexOf('Responsible Representative') === -1 && this.conRole.indexOf('Primary Contact') === -1) && this.editMode == false);
    }

    get isCounty() {
        return ((this.entityType == 'County') || this.nonGovtEntityType == 'Health Care Facility' || this.nonGovtEntityType == 'Other');
    }

    get isState() {
        return (this.entityType == 'State Agency');
    }

    get isCity() {
        return (this.entityType == 'City');
    }

    get isTribal() {
        return (this.entityType == 'Tribal');
    }

    get isSpecialDistrict() {
        return (this.entityType == 'Special District');
    }

    get isCourts() {
        return (this.entityType == 'Courts');
    }

    get isFireAgency() {
        return (this.entityType == 'Fire Agency');
    }

    get isNonGov() {
        console.log('non-gov---',(this.entityType == 'Non-Governmental Entity'));
        return (this.entityType == 'Non-Governmental Entity');
    }

    get isOther() {
        return (this.nonGovtEntityType == 'Other');
    }

    get isHealthCareFacility() {
        return (this.nonGovtEntityType == 'Health Care Facility');
    }

    get isNonGovEntityType() {
        return (this.isOther || this.isHealthCareFacility);
    }

    get showEntityName() {
        return (this.tableConfig && this.tableConfig['ModalName'] == 'SubApplication User Roles' && this.editMode && this.accountName != null && this.accountName != '');
    }

    handleMultiSelectChange(event) {
        this.conRole = '';
        for(let key in event.detail.value) {
            this.conRole += event.detail.value[key]+";";
        }
    }

    handleRoleChange(event) {
        this.conRole = event.detail.value;
    }

    handleEntityTypeChange(event) {
        this.entityType = event.target.value;
        this.nonGovtEntityType = '';
        this.nonGovtEntityRecord = {};
    }

    fieldChangedContact(event){
        let tempCon = JSON.parse(JSON.stringify(this.contactRec));
        tempCon[event.target.getAttribute('data-field')] = event.target.value;
        this.contactRec = tempCon;
        console.log('contactRec : ', JSON.parse(JSON.stringify(this.contactRec)));
    }
    addContactToList(event) {
        
        console.log('this.applicationId ----', this.applicationId);
        console.log('this.conRole ----', this.conRole);
        let allValid = this.validateInputs();
        let allValidEmail = this.handleEmailValidation();
        let allValidPhone = this.formatPhone();
        if(allValid == false || allValidEmail == false || allValidPhone == false) return;
        console.log('this.contactRoles.Id : ', this.contactRoles.Id);
        console.log('this.contactRoles.Id 2 : ', this.contactRoles['Id']);
        let paramMap = this.prepareParamMap();
        if(this.contactRoles && this.contactRoles.Id) {
            let contactRole = { Contact__r: JSON.parse(JSON.stringify(this.contactRec)), Role__c : this.conRole, Type__c : this.type, Application__c : this.applicationId, Id : this.contactRoles.Id};
            this.contactRoles = contactRole;
        }else {
            let contactRole = { Contact__r: JSON.parse(JSON.stringify(this.contactRec)), Role__c : this.conRole, Type__c : this.type, Application__c : this.applicationId};
            this.contactRoles = contactRole;
        }
        console.log('----Server call params----',JSON.parse(JSON.stringify(this.contactRoles)));
        this.handleContactInformation(paramMap);
        this.contactRec = {};
        this.contactRoles = {};
        this.type = '';
        this.showModal = false;
        this.fireCloseModalEvent();
    }
    handleContactInformation(recordDetailsMap) {
        let paramMap = {};
        // paramMap['recordDetails'] = JSON.stringify(contactRoleDetail);
        recordDetailsMap.recordDetails = JSON.stringify(this.contactRoles)
        paramMap['recordDetailsMap'] = recordDetailsMap;
        console.log('params----',recordDetailsMap);
        this.showLoader = true;
        this.executeAction(processOnContactInformation, paramMap, (response) => {
            this.showLoader = false;
            console.log('response --',response);     
            if(response) {
                this.fireContactInformationEvent(response);
                this.fireCloseModalEvent();
            }
        });
    }

    prepareParamMap() {
        let paramMap = {};
        if(this.accountId != '' && this.accountId != null && this.accountId != undefined) {
            paramMap.createAccount = false;
            paramMap.accountId = this.accountId;
        } else {
            paramMap.createAccount = true;
            paramMap.accountRecord = this.nonGovtEntityRecord;
        }
        return paramMap;
    }

    /* 
    This method sets the search result for state agency. Gives call to apex method and then set the result
    */
    handleStateAgencySearch(event) {
        this.executeAction(apexSearchStateAgency, event.detail, (res) => {
            console.log('response for state agency search', res);
            this.template.querySelector('[data-lookup="State_Agency__c"]').setSearchResults(res);
        });
    }

    handleStateAgencyChange(response) {
        if(!response.detail) {
            this.stateAgency = '';
        } else if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.accountId = response.detail.selectedItem.id;
            this.entityWithAccountId = true;
        }
    }

    /*
    This method sets the search result for city.
    */
    handleCitySearch(event) {
        this.executeAction(apexSearchCity, event.detail, (res) => {
            console.log('response for city---', res);
            this.template.querySelector('[data-lookup="City__c"]').setSearchResults(res);
        });
    }

    handleCityChange(response) {
        if(!response.detail) {
            this.city = '';
        } else if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.accountId = response.detail.selectedItem.id;
            this.entityWithAccountId = true;
        }
    }

    /* 
    This method sets the search result for tribal
    */
    handleTribalSearch(event) {
        this.executeAction(apexSearchTribal, event.detail, res => {
            this.template.querySelector('[data-lookup="Tribal__c"]').setSearchResults(res);
        });
    }

    handleTribalChange(response) {
        if(!response.detail) {
            this.tribal = '';
        } else if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.accountId = response.detail.selectedItem.id;
            this.entityWithAccountId = true;
        }
    }

    /* 
    This method sets the search result for special district
    */
    handleSpecialDistrictSearch(event) {
        this.executeAction(apexSearchSpecialDistrict, event.detail, res => {
            this.template.querySelector('[data-lookup="Special_District__c"]').setSearchResults(res);
        });
    }

    handleSpecialDistrictChange(response) {
        if(!response.detail) {
            this.spclDistrict = '';
        } else if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.accountId = response.detail.selectedItem.id;
            this.entityWithAccountId = true;
        }
    }

    /*
    This method sets the search result for courts
    */
    handleCourtSearch(event) {
        this.executeAction(apexSearchCourts, event.detail, res => {
            this.template.querySelector('[data-lookup="Courts__c"]').setSearchResults(res);
        });
    }

    handleCourtChange(response) {
        if(!response.detail) this.court = '';
        else if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.accountId = response.detail.selectedItem.id;
            this.entityWithAccountId = true;
        }
    }

     /*
    * Searches account with Entity_Type__c equals Fire_Agency__c
    */
     handleFireAgencySearch(event) {
        this.executeAction(apexSearchFireAgency, event.detail, res => {
            this.template.querySelector('[data-lookup="Fire_Agency__c"]').setSearchResults(res);
        });
    }

    /*
    * Lookup selection for Fire_Agency__c
    */
    handleFireAgencyChange(response) {
        if(!response.detail) this.fireAgency = '';
        else if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.accountId = response.detail.selectedItem.id;
            this.entityWithAccountId = true;
        }
    }

    /*
    * Set value to Entity_Type__c or Non_Government_Entity_Type__c
    * Set value to Null
    */
    entityChanged(event) {
        this.selectedFacility = false;
        this.accountId = '';
        this.entityWithAccountId = false;
        this.entityWithoutAccountId = true;
        this.nonGovtEntityRecord = {};
        this.nonGovtEntityType = event.target.value;
        console.log('entityChanged---',this.nonGovtEntityType);
    }


    nonGovtEntityRecordFieldChanged(event) {
        this.nonGovtEntityRecord[event.target.getAttribute('data-field')] = event.target.value;
        console.log(event.target.getAttribute('data-field')+'---'+this.nonGovtEntityRecord[event.target.getAttribute('data-field')]);
    }

    /*
    * Set searchTerm to Facility_Name__c for creation of new account
    */
    handleSearchChange(response) {
        this.nonGovtEntityRecord.FacilityName = response.detail.searchTerm;
    }

    /* 
    This method sets the search result for facility search
    */
    handleFacilitySearch(event) {
        this.executeAction(apexSearchFacility, event.detail, res => {
            this.template.querySelector('[data-lookup="Facility__c"]').setSearchResults(res);
        });
    }

    handleFacilityChange(response) {
        if(!response.detail) {
            this.nonGovtEntityRecord.Facility = '';
            this.nonGovtEntityRecord.FacilityName = '';
            this.nonGovtEntityRecord.FacilityID = '';
            this.nonGovtEntityRecord.StreetAddress = '';
            this.nonGovtEntityRecord.CityName = '';
            this.nonGovtEntityRecord.State = '';
            this.nonGovtEntityRecord.County = '';
            this.nonGovtEntityRecord.ZipPostalCode = '';
            this.selectedFacility = false;
        }
        if(response.detail.selectedItem.id != undefined) {
            this.nonGovtEntityRecord.Facility = response.detail.selectedItem.id;
            this.executeAction(apexGetFacilityDetails, {facilityId : this.nonGovtEntityRecord.Facility}, results => {
                console.log('results from apex----', results);
                this.nonGovtEntityRecord.FacilityName = results[0].Name;
                this.nonGovtEntityRecord.FacilityID = results[0].Entity_Id__c;
                this.nonGovtEntityRecord.StreetAddress = results[0].ShippingStreet;
                this.nonGovtEntityRecord.CityName = results[0].ShippingCity;
                this.nonGovtEntityRecord.ZipPostalCode = results[0].ShippingPostalCode;
                this.nonGovtEntityRecord.State = results[0].ShippingState;
                if(results[0].Parent != undefined) {
                    this.nonGovtEntityRecord.County = results[0].Parent.Name;
                }
                this.selectedFacility = true;
            });
        }
    }

    fireContactInformationEvent(conDetail) {
        const contactInformationEvent = new CustomEvent('contactinformation', {
            detail: conDetail
        });
        this.dispatchEvent(contactInformationEvent);
    }
    fireCloseModalEvent() {
        const closeModalEvent = new CustomEvent('closemodal', {
            detail: false
        });
        this.dispatchEvent(closeModalEvent);
    }

    handleClearClick(){
        this.showModal = false;
        this.contactRec = {};        
        this.contactRoles = {};
        this.type = '';
        this.fireCloseModalEvent();
    }
    closeModal(){
        this.showModal = false;
        this.handleClearClick();
    }

    // **** Validation
    handleEmailValidation(){
        let emailFieldCmp = this.template.querySelector('.emailField');
        let mailRegex =  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        let emailAddress =  this.contactRec.Email;
        let mailMatcher = mailRegex.test(emailAddress);
        let allValidEmail = true;
        if(mailMatcher == false ){
            allValidEmail = false;
            emailFieldCmp.setCustomValidity('Email address not in proper format');
        } else {
        emailFieldCmp.setCustomValidity('');
        
        }
        emailFieldCmp.reportValidity();
        return allValidEmail;
    }
    formatPhone(){
        let number = this.contactRec.Phone;
        let cleanedNumber = ('' + number).replace(/\D/g, '');
        let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
        let newNumber = '';
        let allValidPhone = true;
        if (phoneNumber) {
            newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
            console.log('newNumber',newNumber);
            this.contactRec.Phone = newNumber;
        }
       
        let inputCmp = this.template.querySelector('.phoneInput');
        var value = this.contactRec.Phone;
        console.log('value---',value);
        if (value != newNumber) {
            allValidPhone =false;
            inputCmp.setCustomValidity("Enter a valid phone number ex:(555) 555-5555");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        return allValidPhone;
    }
}