import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import ORDER_OBJECT from '@salesforce/schema/Contact_Role__c';
import ROLE_FIELD from '@salesforce/schema/Contact_Role__c.Role__c';
import TYPE_FIELD from '@salesforce/schema/Contact_Role__c.Type__c';
import apexSearch from '@salesforce/apex/HMA_SearchLookupCtrl.searchContact';
import apexSearchAgency from '@salesforce/apex/HMA_SearchLookupCtrl.searchAgency';
import getContact from '@salesforce/apex/HMANOIRequest_Ctrl.getCommunityContact';
import getUserAccount from '@salesforce/apex/HMANOIRequest_Ctrl.getUserAccount';


export default class HmaNOIAdditionalInfo extends Utility {
@track account;
    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT }) objectInfo;
    //@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ROLE_FIELD}) rolePicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD}) typePicklistValues;

    @api isCommContactAdded;
    loadLookupDataOnLoad = false;
    contactRec = {
        Account : {}
    };
    rolePicklistValues = [
        {value : 'Primary Contact', label : 'Primary Contact'},
        {value : 'Responsible Representative', label : 'Responsible Representative'}
    ];
    
    contactSelection = [];
    agencySelection;
    contactRoleList = [];
    contactRole = '';
    type = '';
    selectedItem;
    recordIndex;
    isUpdate = false;
    errorsAgency = [];
    showModal = false;
    
    isMultiEntry = false;
    maxSelectionSize = 20;
    errors = [];

    handleMultiSelectChange(event) {
        this.contactRole = '';
        for(let key in event.detail.value) {
            this.contactRole += event.detail.value[key]+";";
        }
    }

    handleChange(event){
        //if(event.target.name == 'Role') this.contactRole = event.target.value;
        if(event.target.name == 'Type') this.type = event.target.value;
    }

    fieldChangedContact(event){
        this.contactRec[event.target.getAttribute('data-field')] = event.target.value;
    }

    accDetails(event){
        this.contactRec.Account[event.target.getAttribute('data-field')] = event.target.value;
    }
    addContactToList(event) {

        let allValid = this.validateInputs();
        let allValidEmail = this.handleEmailValidation();
        let allValidPhone = this.formatPhone();
        let allValidLookup = this.validateAgencyLookup();
        if(allValid == false || allValidEmail == false || allValidLookup == false || allValidPhone == false) return;
        if(this.contactRec && this.contactRole){
            this.contactRole = this.contactRole.replace(/\;$/,'');
            this.contactRole = this.contactRole.replace(/\;/g, ', ');
            let contactRole = { Contact__r: this.contactRec, Role__c : this.contactRole, Type__c : this.type};
            console.log('contactRole-----',contactRole);
            if(this.recordIndex == -1){
                this.recordLocal.Contact_Roles__r.push(contactRole);
            }else{
                this.recordLocal.Contact_Roles__r[this.recordIndex] = contactRole;
            }
            
            console.log('this.recordLocal.Contact_Roles__r-----',JSON.stringify(this.recordLocal.Contact_Roles__r));
        }
        this.contactRec = {
            Account:{}
        };
        this.contactRole = '';
        this.type = '';
        this.contactSelection =  [];
        this.agencySelection =  [];
        this.showModal = false;
    }

    handleClear(){
        this.contactRec = {
            Account:{}
        };
        
        this.contactRole = '';
        this.type = '';
        this.contactSelection =  [];
        this.agencySelection =  [];
    }

    editContactRole(event){
        //let id = event.currentTarget.id.split('-')[0];
        let id = event.currentTarget.dataset.editId;
        this.recordIndex = id;
        let recordVar =  this.recordLocal.Contact_Roles__r[id];
        this.contactRec = recordVar.Contact__r;
        this.contactRole = recordVar.Role__c;
        this.type = recordVar.Type__c;
        console.log('this.recordIndex',this.recordIndex);
        this.showModal = true;
        this.contactRoleList = [];
        if(recordVar.Role__c){
            recordVar.Role__c = recordVar.Role__c.replace(/\;$/,'');
            recordVar.Role__c = recordVar.Role__c.replace(/\;/g, ', ');
            this.contactRoleList = recordVar.Role__c.split(', ');
        }
    }

    deleteContactRole(event){
        //let id = event.currentTarget.id.split('-')[0];
        let id = event.currentTarget.dataset.deleteId;
        this.recordLocal.Contact_Roles__r.splice(id,1);        
    }

    initData() {
        window.scrollTo(0,0);
        if(this.recordLocal != undefined) {
            if(this.recordLocal.Contact_Roles__r == undefined) {
                this.recordLocal.Contact_Roles__r = [];
            }
        }
        console.log('size----',this.recordLocal);
        this.getCommunityUserAccount();
        if(this.recordLocal.Contact_Roles__r.length == 0) {
            console.log('in if---');
            this.getCommunityContact();
        }
        if(this.recordLocal.Contact_Roles__r.length > 0) {
            console.log('in recordLocal contact Role list--', JSON.parse(JSON.stringify(this.recordLocal.Contact_Roles__r)));
            let roleList = this.recordLocal.Contact_Roles__r;
            console.log('new ContactRoleList---', roleList)
            this.contactRoleList = [];
            for(let i=0; i<roleList.length; i++) {
                roleList[i].Role__c = roleList[i].Role__c.replace(/\;$/,'');
                roleList[i].Role__c = roleList[i].Role__c.replace(/\;/g, ', ');
                let roleArray = roleList[i].Role__c.split(', ');
                if(roleArray.length > 0) {
                    for(let key in roleArray) {
                        this.contactRoleList.push({label : roleArray[key], value: roleArray[key]});
                    }
                } else {
                    this.contactRoleList.push({label : roleList[i].Role__c, value : roleList[i].Role__c});
                }
                
            }
            console.log('original ContactRoleList---', this.contactRoleList);
        }
        // setTimeout(() => {
        //    this.template.querySelectorAll('.action')[0].classList.add('display-none');
        // }, 1000);
    }
    
    getCommunityContact(){
        this.executeAction(getContact, {}, (response) => {
            if(response){
                console.log('response---',response);
                let contactRole = { Contact__r: response, Role__c :'Primary Contact', Type__c:'Primary'};
                console.log('contactRole---',contactRole);
                this.recordLocal.Contact_Roles__r.push(contactRole);
            }
        });
    }
    getCommunityUserAccount(){
        this.executeAction(getUserAccount, {}, (response) => {
            if(response){
                console.log('response-getUserAccount-----',response);
                if(response.account.Name != null && response.account.Name != undefined) {
                    this.account = response.account;
                }              
            }
        });
    }
    handleContactSearch(event) {
        apexSearch(event.detail)
            .then((results) => {
                console.log('results----', results);
                this.template.querySelector('[data-lookup="Contact"]').setSearchResults(results);
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleContactSelectionChange(response) {
        console.log('response--', response);
        if(response.detail.selectedItem.id != undefined) {
            //this.recordLocal.Contact = response.detail.selectedItem.sObject;
            this.contactRec = response.detail.selectedItem.sObject;
            this.agencySelection = [
                {
                    id: this.contactRec.AccountId,
                    sObjectType: 'Account',
                    icon: 'standard:account',
                    title: this.contactRec.Account.Name,
                    subtitle: ''
                }
            ];
            //this.contactRole = 'Delivery Point of Contact';
            this.contactSelection =  [];
        }
        //this.checkForErrors();
    }


    handleAgencySearch(event) {
        apexSearchAgency(event.detail)
            .then((results) => {
                console.log('results----', results);
                this.template.querySelector('[data-lookup="Agency__c"]').setSearchResults(results);
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleAgencySelectionChange(response) {
        console.log('response--', response);
        if(response.detail.selectedItem.id != undefined) {
            this.contactRec.AccountId = response.detail.selectedItem.id;
            this.contactRec.Account = response.detail.selectedItem.sObject;
        }
    }

    validateAgencyLookup() {
        let isSuccess = true;
        this.errorsAgency = [];
        if (this.contactRec.Account == undefined) {
            this.errorsAgency.push({ message: 'Complete this field.' });
            isSuccess = false;
        }
        return isSuccess;
    }
    validateCustomInput() {
        debugger;
        try{
        let isSuccess = true;
            let resRep = false;
            let primaryContact = false;
        if(this.recordLocal.Contact_Roles__r == undefined ||
            this.recordLocal.Contact_Roles__r.length < 2) {
            isSuccess = false;
            this.showErrorNotification('Error', 'Please enter at least two Contacts')
            } else {
                this.recordLocal.Contact_Roles__r.forEach(item => {
                    if(String(item.Role__c).includes('Responsible Representative')) {
                        resRep = true;
                    }
                    if(String(item.Role__c).includes('Primary Contact')) {
                        primaryContact = true;
                    }
                });
                if(resRep === false || primaryContact === false) {
                    isSuccess = false;
                    this.showErrorNotification('Error', 'Atleast one contact role should be Responsible Representative and one should be Primary Contact');
                }
        }
        return isSuccess;
        } catch(e) {
            console.log(e);
        }
    }

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

    formatMobilePhone(){
        let number = this.contactRec.MobilePhone;
        let cleanedNumber = ('' + number).replace(/\D/g, '');
        let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
        let newNumber = '';
        let allValidPhone = true;
        if (phoneNumber) {
            newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
            console.log('newNumber',newNumber);
            this.contactRec.MobilePhone = newNumber;
        }
       
        let inputCmp = this.template.querySelector('.mobilePhoneInput');
        var value = this.contactRec.MobilePhone;
        console.log('value---',value);
        if (this.contactRec.MobilePhone && value != newNumber) {
            allValidPhone =false;
            inputCmp.setCustomValidity("Enter a valid phone number ex:(555) 555-5555");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        //return allValidPhone;
    }

    
    closeModal(){
        this.showModal = false;
        this.handleClear();
    }
    addContact(){
        if(this.account) {
            this.contactRec.Account = this.account; 
        }  
        this.showModal = true;
        this.recordIndex = -1;
    }
}