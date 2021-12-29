import { LightningElement,wire,track,api } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import HH_EN_ApplicantFirstName from '@salesforce/label/c.HH_EN_ApplicantFirstName';
import HH_EN_ApplicantLastName from '@salesforce/label/c.HH_EN_ApplicantLastName';	
import HH_EN_IsPhysicalAddressForeignAddress from '@salesforce/label/c.HH_EN_IsPhysicalAddressForeignAddress';
import HH_EN_PhysicalAddressStreet from '@salesforce/label/c.HH_EN_PhysicalAddressStreet';
import HH_EN_PhysicalAddressCity from '@salesforce/label/c.HH_EN_PhysicalAddressCity';
import HH_EN_PhysicalAddressState from '@salesforce/label/c.HH_EN_PhysicalAddressState';
import HH_EN_PhysicalAddressCountry from '@salesforce/label/c.HH_EN_PhysicalAddressCountry';
import HH_EN_PhysicalAddressZip_PostalCode from '@salesforce/label/c.HH_EN_PhysicalAddressZip_PostalCode';
import HH_EN_IsMailingAddressDifferentFromPhysical from '@salesforce/label/c.HH_EN_IsMailingAddressDifferentFromPhysical';
import HH_EN_IsMailingAddressForeignAddress from '@salesforce/label/c.HH_EN_IsMailingAddressForeignAddress';
import HH_EN_MailingAddressStreet from '@salesforce/label/c.HH_EN_MailingAddressStreet';
import HH_EN_MailingAddressCity from '@salesforce/label/c.HH_EN_MailingAddressCity';
import HH_EN_MailingAddressState from '@salesforce/label/c.HH_EN_MailingAddressState';
import HH_EN_MailingAddressMailingZip_PostalCode from '@salesforce/label/c.HH_EN_MailingAddressMailingZip_PostalCode';
import HH_EN_MailingAddressCountry from '@salesforce/label/c.HH_EN_MailingAddressCountry';
import HH_EN_EmailAddress from '@salesforce/label/c.HH_EN_EmailAddress';
import HH_EN_PrimaryPhone from '@salesforce/label/c.HH_EN_PrimaryPhone';
import HH_EN_Primary_Phone_HelpText from '@salesforce/label/c.HH_EN_Primary_Phone_HelpText';
import HH_EN_SecondaryPhone from '@salesforce/label/c.HH_EN_SecondaryPhone';
import HH_EN_EnglishLanguageProficiency from '@salesforce/label/c.HH_EN_EnglishLanguageProficiency';
import HH_EN_PreferredLanguage from '@salesforce/label/c.HH_EN_PreferredLanguage';
import HH_EN_PhysicalAddressInfoLabel from '@salesforce/label/c.HH_EN_PhysicalAddressInfoLabel';
import HH_EN_Applicant_Information_Page_Title from '@salesforce/label/c.HH_EN_Applicant_Information_Page_Title';
import HH_EN_UniqueHouseholdNumberMessageLabel from '@salesforce/label/c.HH_EN_UniqueHouseholdNumberMessageLabel';
import HH_EN_UniqueHouseholdNumber from '@salesforce/label/c.HH_EN_UniqueHouseholdNumber';
import HH_EN_Email_Address from '@salesforce/label/c.HH_EN_Email_Address';
import HH_EN_MissingFieldValueError from '@salesforce/label/c.HH_EN_MissingFieldValueError';
import HH_EN_PatternMismatchError from '@salesforce/label/c.HH_EN_PatternMismatchError';
import HH_UserRegistrationRecordTypeId from '@salesforce/label/c.HH_UserRegistrationRecordTypeId';
import HH_EN_USACountryNamePickListValue from '@salesforce/label/c.HH_EN_USACountryNamePickListValue';
import HH_Email_Validation_Message from '@salesforce/label/c.HH_Email_Validation_Message';
import HH_EN_City_pattern_validation from '@salesforce/label/c.HH_EN_City_pattern_validation';
import HH_EN_State_pattern_validation from '@salesforce/label/c.HH_EN_State_pattern_validation';
import HH_EN_Zip_pattern_validation	 from '@salesforce/label/c.HH_EN_Zip_pattern_validation';
import HH_EN_Phone_pattern_validation	 from '@salesforce/label/c.HH_EN_Phone_pattern_validation';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import HHApp_OBJECT from '@salesforce/schema/HH_Application__c';
import Is_Physical_Address_a_Foreign_Address__c from '@salesforce/schema/Contact.Is_Physical_Address_a_Foreign_Address__c';
import Country_Region__c from '@salesforce/schema/User_Registration__c.Country_Region__c';
import Mailing_Country_Region__c from '@salesforce/schema/User_Registration__c.Mailing_Country_Region__c';
import Is_Mailing_Address_Different__c from '@salesforce/schema/Contact.Is_Mailing_Address_Different__c';
import English_Language_Proficiency__c from '@salesforce/schema/Contact.English_Language_Proficiency__c';
import Preferred_Language__c from '@salesforce/schema/Contact.Preferred_Language__c';
import Is_Mailing_Address_a_Foreign_Address__c from '@salesforce/schema/Contact.Is_Mailing_Address_a_Foreign_Address__c';
import US_State_Codes__c from '@salesforce/schema/HH_Application__c.US_State_Codes__c';

export default class hhApplicantInfo extends Utility {
	isLoading = true;
	@track showMailingAddress = false;
	disableHouseHoldField = false;
	disableEmailField = false;
	isPhysicalAddressReadOnly = false;
	isMailingAddressReadOnly = false;
	@api houseHoldNumber;
	@api isHomeowner;
	@track countryValues;
	@track recordTypeId;
    storeValueMap = new Map();
	@track label = {
			HH_EN_ApplicantFirstName,
			HH_EN_ApplicantLastName,
			HH_EN_PhysicalAddressStreet,
			HH_EN_PhysicalAddressCity,
			HH_EN_PhysicalAddressState,
			HH_EN_PhysicalAddressCountry,
			HH_EN_PhysicalAddressZip_PostalCode,
			HH_EN_IsMailingAddressDifferentFromPhysical,
			HH_EN_IsPhysicalAddressForeignAddress,
			HH_EN_IsMailingAddressForeignAddress,
			HH_EN_MailingAddressStreet,
			HH_EN_MailingAddressCity,
			HH_EN_MailingAddressState,
			HH_EN_MailingAddressMailingZip_PostalCode,
			HH_EN_MailingAddressCountry,
			HH_EN_EmailAddress,
			HH_EN_PrimaryPhone,
			HH_EN_Primary_Phone_HelpText,
			HH_EN_SecondaryPhone,
			HH_EN_EnglishLanguageProficiency,
			HH_EN_PreferredLanguage,
			HH_EN_PhysicalAddressInfoLabel,
			HH_EN_Applicant_Information_Page_Title,
			HH_EN_UniqueHouseholdNumberMessageLabel,
			HH_EN_UniqueHouseholdNumber,
			HH_EN_Email_Address,
			HH_EN_PatternMismatchError,
			HH_EN_MissingFieldValueError,
			HH_UserRegistrationRecordTypeId,
			HH_EN_USACountryNamePickListValue,
			HH_Email_Validation_Message,
			HH_EN_City_pattern_validation,
			HH_EN_State_pattern_validation,
			HH_EN_Zip_pattern_validation,
			HH_EN_Phone_pattern_validation
	}

    get isEmailRequired() {
        if(this.isHomeowner) {
            return true;
        }
        return false;
    }

	@wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
	objectInfo;
	@wire(getObjectInfo, { objectApiName: HHApp_OBJECT })
	hhAppInfo;

	@wire(getPicklistValues, {
        recordTypeId: '$label.HH_UserRegistrationRecordTypeId',
        fieldApiName: Country_Region__c
	})
    countryRegionOption;

	@wire(getPicklistValues, {
        recordTypeId: '$label.HH_UserRegistrationRecordTypeId',
        fieldApiName: Mailing_Country_Region__c
	})
    mailingAddressOption;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Physical_Address_a_Foreign_Address__c
	})
	isPhyForgeinPickListValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Mailing_Address_Different__c
	})
	mailingAddressDiffPickListValues;

	@wire(getPicklistValues, {
		recordTypeId: '$hhAppInfo.data.defaultRecordTypeId',
		fieldApiName: US_State_Codes__c
	})
	uSStateCodes;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: English_Language_Proficiency__c
	})
	engProficiencyPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Preferred_Language__c
	})
	preferredLangPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Mailing_Address_a_Foreign_Address__c
	})
	mailingAddForegienAddPickListValues;

	initData(){
        let keyString = this.recordLocal['Is_Physical_Address_a_Foreign_Address__c']+'-'+'Physical_State__c';
	    this.storeValueMap.set(keyString, this.recordLocal['Physical_State__c']);
	    this.recordLocal['Physical_State__c'] = this.storeValueMap.get(keyString);

        let keyStringPhysical = this.recordLocal['Is_Physical_Address_a_Foreign_Address__c']+'-'+'Physical_Country__c';
	    this.storeValueMap.set(keyStringPhysical, this.recordLocal['Physical_Country__c']);
        this.recordLocal['Physical_Country__c'] = this.storeValueMap.get(keyStringPhysical);

        let keyString1 = this.recordLocal['Is_Mailing_Address_Different__c']+'-MailingStreet';
        let keyString2 = this.recordLocal['Is_Mailing_Address_Different__c']+'-MailingCity';
        let keyString3 = this.recordLocal['Is_Mailing_Address_Different__c']+'-MailingState-'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'];
        let keyString4 = this.recordLocal['Is_Mailing_Address_Different__c']+'-MailingPostalCode';
        let keyString5 = this.recordLocal['Is_Mailing_Address_Different__c']+'-MailingCountry-'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'];
        let keyString6 = this.recordLocal['Is_Mailing_Address_Different__c']+'-Is_Mailing_Address_a_Foreign_Address__c';
        this.storeValueMap.set(keyString1, this.recordLocal['MailingStreet']);
        this.storeValueMap.set(keyString2, this.recordLocal['MailingCity']);
        this.storeValueMap.set(keyString3, this.recordLocal['MailingState']);
        this.storeValueMap.set(keyString4, this.recordLocal['MailingPostalCode']);
        this.storeValueMap.set(keyString5, this.recordLocal['MailingCountry']);
        this.storeValueMap.set(keyString6, this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c']);
        this.recordLocal['MailingStreet'] = this.storeValueMap.get(keyString1);
        this.recordLocal['MailingCity'] = this.storeValueMap.get(keyString2);
        this.recordLocal['MailingState'] = this.storeValueMap.get(keyString3);
        this.recordLocal['MailingPostalCode'] = this.storeValueMap.get(keyString4);
        this.recordLocal['MailingCountry'] = this.storeValueMap.get(keyString5);
        this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] = this.storeValueMap.get(keyString6);
        console.log(' --Is_Mailing_Address_a_Foreign_Address__c---'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c']);
        console.log(' --MailingStreet---'+this.recordLocal['MailingStreet']);
        console.log(' --MailingCity---'+this.recordLocal['MailingCity']);
        console.log(' --MailingPostalCode---'+this.recordLocal['MailingPostalCode']);
        console.log(' --MailingState---'+this.recordLocal['MailingState']);
        console.log(' --MailingCountry---'+this.recordLocal['MailingCountry']);
	    if(this.houseHoldNumber){
	        this.disableHouseHoldField = true;
     }
     if(this.recordLocal.Email){
         this.disableEmailField = this.isHomeowner;
     }
		 if (this.recordLocal.Is_Mailing_Address_Different__c == 'Yes') {
			 	this.showMailingAddress = true;
		 } else {
			 this.showMailingAddress = false;
		 }
		 if(this.recordLocal['Is_Physical_Address_a_Foreign_Address__c'] == 'No') {
				this.isPhysicalAddressReadOnly = true;
		 } else {
				this.isPhysicalAddressReadOnly  = false;
     }
         if(this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] == 'No') {
                 this.isMailingAddressReadOnly = true;
         } else {
                 this.isMailingAddressReadOnly  = false;
         }
	}

	houseHoldNumberChange(event) {
		this.houseHoldNumber = event.target.value;
	}

	@api
	validateEmail() {
        let emailFieldCmp = this.template.querySelector('.emailField');
		let mailRegex = /^[^<>()[\]\\,;:\%#^\s@\"$&!@]+@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z0-9]+\.)+[a-zA-Z]{2,}))$/;
				let emailAddress =  this.recordLocal.Email != undefined ? this.recordLocal.Email.trim() : '';
        let allValid = true;

        if(this.isHomeowner || (!this.isHomeowner && emailAddress != null && emailAddress != '' && emailAddress.length > 0)) {
        if(emailAddress == null || emailAddress == undefined || emailAddress == '') {
            emailFieldCmp.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
            allValid = false;
        }
        else {
            let mailMatcher = mailRegex.test(emailAddress);
            if(mailMatcher == false ) {
                allValid = false;
                emailFieldCmp.setCustomValidity(this.label.HH_Email_Validation_Message);
            }else {
                emailFieldCmp.setCustomValidity('');
            }
        }
        }
        else {
            emailFieldCmp.setCustomValidity('');
        }
        emailFieldCmp.reportValidity();
        return allValid;
  }

	@api getHouseHoldNumber() {
				return this.houseHoldNumber;
	}
	blankCheck(event) {
	    var withoutSpace = this.recordLocal[event.target.getAttribute('data-field')].replace(/ /g,"");
    		if(withoutSpace.length == 0){
    		    this.recordLocal[event.target.getAttribute('data-field')]=null;
    		}
    }

	handleIsForeignAddressChange(event) {

	    let keyString = event.target.value+'-'+'Physical_State__c';
		this.recordLocal[event.target.getAttribute('data-field')] = event.target.value;
		if(this.recordLocal['Is_Physical_Address_a_Foreign_Address__c'] == 'No') {
				this.recordLocal['Physical_Country__c'] = this.label.HH_EN_USACountryNamePickListValue;
				this.isPhysicalAddressReadOnly = true;
            this.recordLocal['Physical_State__c'] = this.storeValueMap.get(keyString);
           if(this.recordLocal.Is_Mailing_Address_Different__c == 'No'){
              this.mailingAddressChanges('No');
		}
		}else{
				this.isPhysicalAddressReadOnly = false;
            this.recordLocal['Physical_State__c'] = this.storeValueMap.get(keyString);
            this.recordLocal['Physical_Country__c'] = this.storeValueMap.get('Yes-Physical_Country__c');
            if(this.recordLocal.Is_Mailing_Address_Different__c == 'No'){
              this.mailingAddressChanges('No');
            }
		}
	}
	handleIsMailingAddressChange(event){
        let keyString = this.recordLocal['Is_Mailing_Address_Different__c']+'-'+event.target.getAttribute('data-field');
        this.storeValueMap.set(keyString, event.target.value);
        this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString);
	    if(event.target.value == 'No') {
            this.isMailingAddressReadOnly = true;
            let keyString1 = 'Yes-MailingState-No';
            this.recordLocal['MailingCountry'] = this.label.HH_EN_USACountryNamePickListValue;
            if(this.storeValueMap.get(keyString1)){
                this.recordLocal['MailingState'] = this.storeValueMap.get(keyString1);
            }else{
                this.recordLocal['MailingState'] = '';
            }
        }else if(event.target.value == 'Yes'){
            let keyString1 = 'Yes-MailingState-Yes';
            let keyString2 = 'Yes-MailingCountry-Yes';
            this.isMailingAddressReadOnly = false;
            if(this.storeValueMap.get(keyString1)){
                this.recordLocal['MailingState'] = this.storeValueMap.get(keyString1);
            }else{
                this.storeValueMap.set(keyString1, this.storeValueMap.get('Yes-MailingState'));
                this.recordLocal['MailingState'] = this.storeValueMap.get('Yes-MailingState');
            }
            if(this.storeValueMap.get(keyString2)){
                this.recordLocal['MailingCountry'] = this.storeValueMap.get(keyString2);
            }else{
                this.storeValueMap.set(keyString2, this.storeValueMap.get('Yes-MailingCountry'));
                this.recordLocal['MailingCountry'] = this.storeValueMap.get('Yes-MailingCountry');
            }
        }
	}

	fieldChangedMap(event){
	    if(event.target.getAttribute('data-field') == 'Physical_State__c' || event.target.getAttribute('data-field') == 'Physical_Country__c'){
            let keyString = this.recordLocal['Is_Physical_Address_a_Foreign_Address__c']+'-'+event.target.getAttribute('data-field');
            this.storeValueMap.set(keyString, event.target.value);
            this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString);
	    }
        else if(event.target.getAttribute('data-field') == 'MailingState' || event.target.getAttribute('data-field') == 'MailingCountry'){
            if(this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] != undefined){
                let keyString2 = 'Yes-'+event.target.getAttribute('data-field')+'-'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'];
                this.storeValueMap.set(keyString2, event.target.value);
                this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString2);
            }else{
               let keyString1 = 'Yes-'+event.target.getAttribute('data-field');
               this.storeValueMap.set(keyString1, event.target.value);
               this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString1);
            }
        }else{
            let keyString = this.recordLocal['Is_Mailing_Address_Different__c']+'-'+event.target.getAttribute('data-field');
            this.storeValueMap.set(keyString, event.target.value);
            this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString);
        }
        if(this.recordLocal.Is_Mailing_Address_Different__c == 'No'){
           this.mailingAddressChanges('No');
        }
	}

    mailingAddressPicklistChanged(event) {
        this.mailingAddressChanges(event.target.value);
    }

    mailingAddressChanges(picklistValue){
        let value = picklistValue;
        this.recordLocal.Is_Mailing_Address_Different__c = value;
        if(value == 'Yes') {
            this.showMailingAddress = true;
            this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] = this.storeValueMap.get('Yes-Is_Mailing_Address_a_Foreign_Address__c');
            this.recordLocal['MailingStreet'] = this.storeValueMap.get('Yes-MailingStreet');
            this.recordLocal['MailingCity'] =  this.storeValueMap.get('Yes-MailingCity');
            this.recordLocal['MailingPostalCode'] =  this.storeValueMap.get('Yes-MailingPostalCode');
		if(this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] == 'No') {
                this.recordLocal['MailingState'] =  this.storeValueMap.get('Yes-MailingState-No');
			this.recordLocal['MailingCountry'] = this.label.HH_EN_USACountryNamePickListValue;
			this.isMailingAddressReadOnly = true;
            }else if(this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] == 'Yes'){
                this.isMailingAddressReadOnly = false;
                this.recordLocal['MailingState'] =  this.storeValueMap.get('Yes-MailingState-Yes');
                this.recordLocal['MailingCountry'] =  this.storeValueMap.get('Yes-MailingCountry-Yes');
            }else{
                this.isMailingAddressReadOnly = false;
                this.recordLocal['MailingState'] =  this.storeValueMap.get('Yes-MailingState');
                this.recordLocal['MailingCountry'] =  this.storeValueMap.get('Yes-MailingCountry');
		}
            console.log(' --Is_Mailing_Address_a_Foreign_Address__c---'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c']);
            console.log(' --MailingStreet---'+this.recordLocal['MailingStreet']);
            console.log(' --MailingCity---'+this.recordLocal['MailingCity']);
            console.log(' --MailingPostalCode---'+this.recordLocal['MailingPostalCode']);
            console.log(' --MailingState---'+this.recordLocal['MailingState']);
            console.log(' --MailingCountry---'+this.recordLocal['MailingCountry']);
        } else {
            this.showMailingAddress = false;
            this.recordLocal['MailingStreet'] = this.recordLocal['Physical_Street__c'];
            this.recordLocal['MailingCity'] = this.recordLocal['Physical_City__c'];
            this.recordLocal['MailingState'] = this.recordLocal['Physical_State__c'];
            this.recordLocal['MailingPostalCode'] = this.recordLocal['Physical_Zip_Postal_Code__c'];
            this.recordLocal['MailingCountry'] = this.recordLocal['Physical_Country__c'];
            this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] = this.recordLocal['Is_Physical_Address_a_Foreign_Address__c'];
            console.log(' --Is_Mailing_Address_a_Foreign_Address__c---'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c']);
            console.log(' --MailingStreet---'+this.recordLocal['MailingStreet']);
            console.log(' --MailingCity---'+this.recordLocal['MailingCity']);
            console.log(' --MailingPostalCode---'+this.recordLocal['MailingPostalCode']);
            console.log(' --MailingState---'+this.recordLocal['MailingState']);
            console.log(' --MailingCountry---'+this.recordLocal['MailingCountry']);
		}
	}
}