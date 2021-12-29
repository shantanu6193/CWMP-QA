/**
 * Created by ricky on 13-08-2021.
 */
/* Importing the Wire, track and lightning elements on the page. */
import { LightningElement, track, wire } from 'lwc';
import Utility from 'c/utility';

/** Importing Object info and Picklist fields information from object. */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import HHApp_OBJECT from '@salesforce/schema/HH_Application__c';

/** Importing Cal OES logos from Static Resources.. */
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import HHLoginLogo from '@salesforce/resourceUrl/HHLoginLogo'; 

/* Importing the Save record method from Community Registration controller class, in order to save the User registration record. */
import saveRecord from '@salesforce/apex/CommunityRegistrationCtrl.createUserRegistration';

/* Importing the Custom Labels for Field labels, Messages and Error messages on the page. */
import HH_EN_RegistartionLanguageMessageLabel from '@salesforce/label/c.HH_EN_RegistartionLanguageMessageLabel';
import HH_EN_ApplicantFirstName from '@salesforce/label/c.HH_EN_ApplicantFirstName';
import HH_EN_ApplicantLastName from '@salesforce/label/c.HH_EN_ApplicantLastName';
import HH_EN_PhysicalAddressInfoLabel from '@salesforce/label/c.HH_EN_PhysicalAddressInfoLabel';
import HH_EN_IsPhysicalAddressForeignAddress from '@salesforce/label/c.HH_EN_IsPhysicalAddressForeignAddress';
import HH_EN_PhysicalAddressStreet from '@salesforce/label/c.HH_EN_PhysicalAddressStreet';
import HH_EN_PhysicalAddressCity from '@salesforce/label/c.HH_EN_PhysicalAddressCity';
import HH_EN_PhysicalAddressState from '@salesforce/label/c.HH_EN_PhysicalAddressState';
import HH_EN_PhysicalAddressZip_PostalCode from '@salesforce/label/c.HH_EN_PhysicalAddressZip_PostalCode';
import HH_EN_PhysicalAddressCountry from '@salesforce/label/c.HH_EN_PhysicalAddressCountry';
import HH_EN_IsMailingAddressDifferentFromPhysical from '@salesforce/label/c.HH_EN_IsMailingAddressDifferentFromPhysical';
import HH_EN_IsMailingAddressForeignAddress from '@salesforce/label/c.HH_EN_IsMailingAddressForeignAddress';
import HH_EN_MailingAddressStreet from '@salesforce/label/c.HH_EN_MailingAddressStreet';
import HH_EN_MailingAddressCity from '@salesforce/label/c.HH_EN_MailingAddressCity';
import HH_EN_MailingAddressState from '@salesforce/label/c.HH_EN_MailingAddressState';
import HH_EN_MailingAddressMailingZip_PostalCode from '@salesforce/label/c.HH_EN_MailingAddressMailingZip_PostalCode';
import HH_EN_MailingAddressCountry from '@salesforce/label/c.HH_EN_MailingAddressCountry';
import HH_EN_Email_Address from '@salesforce/label/c.HH_EN_Email_Address';
import HH_EN_PrimaryPhone from '@salesforce/label/c.HH_EN_PrimaryPhone';
import HH_EN_Primary_Phone_HelpText from '@salesforce/label/c.HH_EN_Primary_Phone_HelpText';
import HH_EN_SecondaryPhone from '@salesforce/label/c.HH_EN_SecondaryPhone';
import HH_EN_EnglishLanguageProficiency from '@salesforce/label/c.HH_EN_EnglishLanguageProficiency';
import HH_EN_PreferredLanguage from '@salesforce/label/c.HH_EN_PreferredLanguage';
import HH_EN_Sign_Up from '@salesforce/label/c.HH_EN_Sign_Up';
import HH_EN_PhoneNumberMismatchError from '@salesforce/label/c.HH_EN_PhoneNumberMismatchError';
import HH_EN_MissingFieldValueError from '@salesforce/label/c.HH_EN_MissingFieldValueError';
import HH_EN_SelectLanguagePlaceHolder from '@salesforce/label/c.HH_EN_SelectLanguagePlaceHolder';
import HH_EN_Already_have_an_Account from '@salesforce/label/c.HH_EN_Already_have_an_Account';
import HH_EN_Sign_In from '@salesforce/label/c.HH_EN_Sign_In';
import HH_EN_UniqueHouseholdNumber from '@salesforce/label/c.HH_EN_UniqueHouseholdNumber';
import HH_EN_UserReg_LandingPage from '@salesforce/label/c.HH_EN_UserReg_LandingPage';
import HH_EN_RegistrationSuccessfulMessage from '@salesforce/label/c.HH_EN_RegistrationSuccessfulMessage';
import HH_EN_FillAllRequiredFieldErrorMessage from '@salesforce/label/c.HH_EN_FillAllRequiredFieldErrorMessage';
import HH_EN_USACountryNamePickListValue from '@salesforce/label/c.HH_EN_USACountryNamePickListValue';
import HH_url_LoginURL from '@salesforce/label/c.HH_url_LoginURL';
import HH_EN_PatternMismatchError from '@salesforce/label/c.HH_EN_PatternMismatchError';
import HH_EN_UniqueHouseholdNumberMessageLabel from '@salesforce/label/c.HH_EN_UniqueHouseholdNumberMessageLabel';
import HH_UserRegistrationRecordTypeId from '@salesforce/label/c.HH_UserRegistrationRecordTypeId';
import HH_EN_Copyright_2021_State_of_California from '@salesforce/label/c.HH_EN_Copyright_2021_State_of_California';
import HH_Email_Validation_Message from '@salesforce/label/c.HH_Email_Validation_Message';
import HH_EN_Phone_pattern_validation from '@salesforce/label/c.HH_EN_Phone_pattern_validation';
import HH_EN_Unsupported_Browser from '@salesforce/label/c.HH_EN_Unsupported_Browser';
import HH_EN_Internet_Explorer_not_supported_Error from '@salesforce/label/c.HH_EN_Internet_Explorer_not_supported_Error';
import HH_Community_Relative_Url from '@salesforce/label/c.HH_Community_Relative_Url';
/* Importing the Picklist field values used in page. */
import Is_Physical_Address_a_Foreign_Address from '@salesforce/schema/User_Registration__c.Is_Physical_Address_a_Foreign_Address__c';
import Is_Mailing_Address_a_Foreign_Address from '@salesforce/schema/User_Registration__c.Is_Mailing_Address_a_Foreign_Address__c';
import Is_Mailing_Address_Different from '@salesforce/schema/User_Registration__c.Is_Mailing_Address_Different__c';
import English_Language_Proficiency from '@salesforce/schema/User_Registration__c.English_Language_Proficiency__c';
import Preferred_Language from '@salesforce/schema/User_Registration__c.Preferred_Language__c';
import Country_Region from '@salesforce/schema/User_Registration__c.Country_Region__c';
import Mailing_Country_Region from '@salesforce/schema/User_Registration__c.Mailing_Country_Region__c';
import Translation_Language from '@salesforce/schema/User_Registration__c.Translation_Language__c';
import HHFireDept from '@salesforce/resourceUrl/HHFireDept';
import US_State_Codes__c from '@salesforce/schema/HH_Application__c.US_State_Codes__c';


/* Importing Current Page reference */
import { CurrentPageReference } from 'lightning/navigation';

export default class HhCommunityRegistration extends Utility {

    /* Storing the Custom labels in a variable in order to use in HTML. */
    @track label = {
        HH_EN_RegistartionLanguageMessageLabel,
        HH_EN_ApplicantFirstName,
        HH_EN_ApplicantLastName,
        HH_EN_PhysicalAddressInfoLabel,
        HH_EN_IsPhysicalAddressForeignAddress,
        HH_EN_PhysicalAddressStreet,
        HH_EN_PhysicalAddressCity,
        HH_EN_PhysicalAddressState,
        HH_EN_PhysicalAddressZip_PostalCode,
        HH_EN_PhysicalAddressCountry,
        HH_EN_IsMailingAddressDifferentFromPhysical,
        HH_EN_IsMailingAddressForeignAddress,
        HH_EN_MailingAddressStreet,
        HH_EN_MailingAddressCity,
        HH_EN_MailingAddressState,
        HH_EN_MailingAddressMailingZip_PostalCode,
        HH_EN_MailingAddressCountry,
        HH_EN_Email_Address,
        HH_EN_PrimaryPhone,
        HH_EN_Primary_Phone_HelpText,
        HH_EN_SecondaryPhone,
        HH_EN_EnglishLanguageProficiency,
        HH_EN_PreferredLanguage,
        HH_EN_Sign_Up,
        HH_EN_PhoneNumberMismatchError,
        HH_EN_MissingFieldValueError,
        HH_EN_SelectLanguagePlaceHolder,
        HH_EN_Already_have_an_Account,
        HH_EN_Sign_In,
        HH_EN_UniqueHouseholdNumber,
        HH_EN_UserReg_LandingPage,
        HH_EN_RegistrationSuccessfulMessage,
        HH_EN_FillAllRequiredFieldErrorMessage,
        HH_EN_USACountryNamePickListValue,
        HH_url_LoginURL,
        HH_EN_PatternMismatchError,
        HH_UserRegistrationRecordTypeId,
        HH_EN_UniqueHouseholdNumberMessageLabel,
        HH_EN_Copyright_2021_State_of_California,
        HH_Email_Validation_Message,
        HH_EN_Phone_pattern_validation,
        HH_EN_Unsupported_Browser,
        HH_EN_Internet_Explorer_not_supported_Error,
        HH_Community_Relative_Url
    }

    /** Creating variable for disabling the SignUp button and Logo. */
    buttonDisabled = false;
    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    hhLogo = HHLoginLogo;
    hhFire = HHFireDept;
    isIE = false;
    storeValueMap = new Map();
    /* Fetching Picklist field values from user registration object - HH Registration record Type. */
    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
    @wire(getObjectInfo, { objectApiName: HHApp_OBJECT }) hhAppInfo;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Is_Physical_Address_a_Foreign_Address}) IsPhysicalAddressForeignList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Is_Mailing_Address_a_Foreign_Address}) isMailingAddressForeignList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Is_Mailing_Address_Different}) isMailingDifferentList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: English_Language_Proficiency}) englishLanguageProficiencyList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Preferred_Language}) preferredLanguageList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Country_Region}) physicalAddressCountryList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Mailing_Country_Region}) mailingAddressCountryList;
    @wire(getPicklistValues, {recordTypeId: HH_UserRegistrationRecordTypeId, fieldApiName: Translation_Language}) translationLanguageList;

    //@track UserRegistrationDetail = {};
    @track showMailingAddress = false;
    @track isPhysicalAddressReadOnly = false;
    @track isMailingAddressReadOnly = false;
    @track isPatternMatch = true;

    connectedCallback() {


        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
 
        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
            this.isIE = true;
        }
        else {
            this.isIE = false;
        }

         //show correct spanish translated IE warning 
         var browserLanguage = window.navigator.userLanguage || window.navigator.language;

         console.log("Browser Language: " + browserLanguage);
         if( this.isIE === true && this.language == "en_US"  && browserLanguage.includes("es") === true ){

            var oldURL = window.location.href;
            var newURL = oldURL.replace( "en_US" ,"es");
            window.location.href = newURL;
         }
  


    }

    /* To hold the current selected language after page reload.*/
    currentPageReference = null;
    @track language = 'en_US';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    @wire(getPicklistValues, {
		recordTypeId: '$hhAppInfo.data.defaultRecordTypeId',
		fieldApiName: US_State_Codes__c
	})
	uSStateCodes;

    setParametersBasedOnUrl() {
          this.language = this.urlStateParameters.language || null;
    }

    /* This method is created to refresh the URL upon Translation language change. */
    languageFieldChanged(event){
        this.language = event.target.value;
        var queryParams = new URLSearchParams(window.location.search);
        queryParams.set("language", this.language);
        history.replaceState(null, null, "?" + queryParams.toString());
        location.reload();
        this.language = event.target.value;

        this.recordLocal['data-field'] = this.language;
    }

    /*
    * Validate input fields
    */
    validateFields(){
        let validateInputs = this.validateInputs();
        let mailingAddressForeignValid = false;
        let mailingStreetValid = false;
        let mailingCityValid = false;
        let mailingStateValid = false;
        let mailingPostalCodeValid = false;
        let mailingCountryValid = false;

        if(this.showMailingAddress == true) {
            let mailingAddressForeignValid = true;
            let mailingStreetValid = true;
            let mailingCityValid = true;
            let mailingStateValid = true;
            let mailingPostalCodeValid = true;
            let mailingCountryValid = true;
        }

        if(validateInputs) {
            console.log('Validation return true');
            return true;
        }
        else{
            console.log('Validation return false');
            return false;
        }
    }

    /* This method is to send the data to backend for saving User registration record upon click on SIgn-Up Button. */
    handleOnClickSingUp(event) {
        this.buttonDisabled = true;
        this.recordLocal.RecordTypeId = HH_UserRegistrationRecordTypeId;
        this.recordLocal['Translation_Language__c'] = this.language;
        let emailValid = this.validateEmail();

        let allValid = this.validateFields();

        if(allValid && emailValid) {
            this.executeAction(saveRecord, {'record' : JSON.stringify(this.recordLocal)}, (response) => {
                    this.showLoader = true;
                    //registrationSuccessLabel not defined
                    this.showNotification('Success', this.label.HH_EN_RegistrationSuccessfulMessage, 'success','dismissible');
                    setTimeout(() => {
                        window.location.href = HH_url_LoginURL;
                    }, 3000);
             },(error) =>{
                 console.log('Error: ',error);
                 this.buttonDisabled = false;
                 if(error.status != undefined) {
                     this.showNotification('Error',error.body.message, 'Error','dismissible');
                     return;
                 } 
                 this.showNotification('Error',error, 'Error','dismissible');
            });
        }
        else {
            this.buttonDisabled = false;
            this.showNotification('', this.label.HH_EN_FillAllRequiredFieldErrorMessage, 'Error','dismissible');
        }
    }

    navigateSignIn(){
        window.location.href = this.label.HH_url_LoginURL;
    }

    /** This method is for validating the Email field format - Standard was not working properly. */
    validateEmail() {
        let emailFieldCmp = this.template.querySelector('.emailField');

        let mailRegex =  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        let emailAddress =  this.recordLocal.Email__c;
        let allValid = true;

        if(emailAddress == null || emailAddress == undefined || emailAddress == '') {
            emailFieldCmp.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
            allValid = false;
        }
        else {
            let mailMatcher = mailRegex.test(emailAddress);
            console.log('mailMatcher --> 291 --> ', mailMatcher);
            if(mailMatcher == false ) {
                allValid = false;
                emailFieldCmp.setCustomValidity(this.label.HH_EN_PatternMismatchError);
            }else {
                emailFieldCmp.setCustomValidity('');
            }
        }
        emailFieldCmp.reportValidity();
        return allValid;
    }

    get landingPageUrl() {
        return this.label.HH_Community_Relative_Url+'/s';
    }

    /* This method is created seperate in order to store the change of "Is Physical Address a Foreign Address?" field
            - As this field change impact the edit property of of Mailing Physical country field.
             If yes - Then Mailing Country - United State of America. - Field is non editable.
             If No - Then Mailing Country dropdown is enabled. - Field is editable. */
    handleIsForeignAddressChange(event) {
        let keyString = event.target.value+'-'+'State__c';
        this.recordLocal[event.target.getAttribute('data-field')] = event.target.value;
        if(this.recordLocal['Is_Physical_Address_a_Foreign_Address__c'] == 'No') {
            this.recordLocal['Country_Region__c'] = this.label.HH_EN_USACountryNamePickListValue;
            this.isPhysicalAddressReadOnly = true;
            this.recordLocal['State__c'] = this.storeValueMap.get(keyString);
            if(this.recordLocal.Is_Mailing_Address_Different__c == 'No'){
              this.mailingAddressChanges('No');
            }
        }else{
            this.recordLocal['Country_Region__c'] = this.storeValueMap.get('Yes-Country_Region__c');
            this.isPhysicalAddressReadOnly = false;
            this.recordLocal['State__c'] = this.storeValueMap.get(keyString);
            if(this.recordLocal.Is_Mailing_Address_Different__c == 'No'){
              this.mailingAddressChanges('No');
            }
        }
    }

    fieldChangedMap(event){
        if(event.target.getAttribute('data-field') == 'State__c' || event.target.getAttribute('data-field') == 'Country_Region__c'){
            let keyString = this.recordLocal['Is_Physical_Address_a_Foreign_Address__c']+'-'+event.target.getAttribute('data-field');
            this.storeValueMap.set(keyString, event.target.value);
            this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString);
        }else if(event.target.getAttribute('data-field') == 'Mailing_State_Province__c' || event.target.getAttribute('data-field') == 'Mailing_Country_Region__c'){
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
            this.recordLocal['Mailing_Address__c'] = this.storeValueMap.get('Yes-Mailing_Address__c');
            this.recordLocal['Mailing_City__c'] =  this.storeValueMap.get('Yes-Mailing_City__c');
            this.recordLocal['Mailing_Zip_Postal_Code__c'] =  this.storeValueMap.get('Yes-Mailing_Zip_Postal_Code__c');
            if(this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] == 'No'){
                this.recordLocal['Mailing_State_Province__c'] =  this.storeValueMap.get('Yes-Mailing_State_Province__c-No');
                this.recordLocal['Mailing_Country_Region__c'] =  this.label.HH_EN_USACountryNamePickListValue;
                this.isMailingAddressReadOnly = true;
            }else if(this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] == 'Yes'){
                this.isMailingAddressReadOnly = false;
                this.recordLocal['Mailing_State_Province__c'] =  this.storeValueMap.get('Yes-Mailing_State_Province__c-Yes');
                this.recordLocal['Mailing_Country_Region__c'] =  this.storeValueMap.get('Yes-Mailing_Country_Region__c-Yes');
            }else{
                this.isMailingAddressReadOnly = false;
                this.recordLocal['Mailing_State_Province__c'] =  this.storeValueMap.get('Yes-Mailing_State_Province__c');
                this.recordLocal['Mailing_Country_Region__c'] =  this.storeValueMap.get('Yes-Mailing_Country_Region__c');
            }
            console.log(' --Is_Mailing_Address_a_Foreign_Address__c---'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c']);
            console.log(' --Mailing_Address__c---'+this.recordLocal['Mailing_Address__c']);
            console.log(' --Mailing_City__c---'+this.recordLocal['Mailing_City__c']);
            console.log(' --Mailing_Zip_Postal_Code__c---'+this.recordLocal['Mailing_Zip_Postal_Code__c']);
            console.log(' --Mailing_State_Province__c---'+this.recordLocal['Mailing_State_Province__c']);
            console.log(' --Mailing_Country_Region__c---'+this.recordLocal['Mailing_Country_Region__c']);
        } else {
            this.showMailingAddress = false;
            this.recordLocal['Mailing_Address__c'] = this.recordLocal['Street_Address__c'];
            this.recordLocal['Mailing_City__c'] = this.recordLocal['City_Name__c'];
            this.recordLocal['Mailing_State_Province__c'] = this.recordLocal['State__c'];
            this.recordLocal['Mailing_Zip_Postal_Code__c'] = this.recordLocal['Zip_Postal_Code__c'];
            this.recordLocal['Mailing_Country_Region__c'] = this.recordLocal['Country_Region__c'];
            this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c'] = this.recordLocal['Is_Physical_Address_a_Foreign_Address__c'];

            console.log(' --Is_Mailing_Address_a_Foreign_Address__c---'+this.recordLocal['Is_Mailing_Address_a_Foreign_Address__c']);
            console.log(' --Mailing_Address__c---'+this.recordLocal['Mailing_Address__c']);
            console.log(' --Mailing_City__c---'+this.recordLocal['Mailing_City__c']);
            console.log(' --Mailing_Zip_Postal_Code__c---'+this.recordLocal['Mailing_Zip_Postal_Code__c']);
            console.log(' --Mailing_State_Province__c---'+this.recordLocal['Mailing_State_Province__c']);
            console.log(' --Mailing_Country_Region__c---'+this.recordLocal['Mailing_Country_Region__c']);
        }
    }
    handleIsMailingAddressChange(event){
        let keyString = this.recordLocal['Is_Mailing_Address_Different__c']+'-'+event.target.getAttribute('data-field');
        this.storeValueMap.set(keyString, event.target.value);
        this.recordLocal[event.target.getAttribute('data-field')] = this.storeValueMap.get(keyString);
        if(event.target.value == 'No') {
            this.isMailingAddressReadOnly = true;
            let keyString1 = 'Yes-Mailing_State_Province__c-No';
            this.recordLocal['Mailing_Country_Region__c'] = this.label.HH_EN_USACountryNamePickListValue;
            if(this.storeValueMap.get(keyString1)){
                console.log('277-- '+this.storeValueMap.get(keyString1));
                this.recordLocal['Mailing_State_Province__c'] = this.storeValueMap.get(keyString1);
                console.log('279-- '+this.recordLocal['Mailing_State_Province__c']);
            }else{
                console.log('281-- '+this.storeValueMap.get('Yes-Mailing_State_Province__c'));
//                this.storeValueMap.set(keyString1, this.storeValueMap.get('Yes-MailingState'));
//                this.recordLocal['MailingState'] = this.storeValueMap.get('Yes-MailingState');
                this.recordLocal['Mailing_State_Province__c'] = '';
                console.log('284-- '+this.recordLocal['Mailing_State_Province__c']);
            }
        }
        else if(event.target.value == 'Yes'){
            let keyString1 = 'Yes-Mailing_State_Province__c-Yes';
            let keyString2 = 'Yes-Mailing_Country_Region__c-Yes';
            this.isMailingAddressReadOnly = false;
            if(this.storeValueMap.get(keyString1)){
                console.log('288-- '+this.storeValueMap.get(keyString1));
                this.recordLocal['Mailing_State_Province__c'] = this.storeValueMap.get(keyString1);
                console.log('290-- '+this.storeValueMap.get(keyString1));
            }else{
                console.log('291-- '+this.storeValueMap.get('Yes-Mailing_State_Province__c'));
                this.storeValueMap.set(keyString1, this.storeValueMap.get('Yes-Mailing_State_Province__c'));
                this.recordLocal['Mailing_State_Province__c'] = this.storeValueMap.get('Yes-Mailing_State_Province__c');
                console.log('295-- '+this.recordLocal['Mailing_State_Province__c']);
            }
            if(this.storeValueMap.get(keyString2)){
                this.recordLocal['Mailing_Country_Region__c'] = this.storeValueMap.get(keyString2);
            }else{
                this.storeValueMap.set(keyString2, this.storeValueMap.get('Yes-Mailing_Country_Region__c'));
                this.recordLocal['Mailing_Country_Region__c'] = this.storeValueMap.get('Yes-Mailing_Country_Region__c');
            }
        }
    }
}