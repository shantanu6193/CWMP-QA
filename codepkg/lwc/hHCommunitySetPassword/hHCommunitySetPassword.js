import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import Translation_Language from '@salesforce/schema/User_Registration__c.Translation_Language__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import setPassword from '@salesforce/apex/CommunitySetPasswordCtrl.setPassword';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import HHLoginLogo from '@salesforce/resourceUrl/HHLoginLogo';
import Utility from 'c/utility';
import HHFireDept from '@salesforce/resourceUrl/HHFireDept';
import HH_EN_Select_Language from '@salesforce/label/c.HH_EN_Select_Language';
import HH_EN_Enter_Password from '@salesforce/label/c.HH_EN_Enter_Password';
import HH_EN_Confirm_Password from '@salesforce/label/c.HH_EN_Confirm_Password';
import HH_EN_Submit from '@salesforce/label/c.HH_EN_Submit';
import HH_EN_Unsupported_Browser from '@salesforce/label/c.HH_EN_Unsupported_Browser';
import HH_EN_Internet_Explorer_not_supported_Error from '@salesforce/label/c.HH_EN_Internet_Explorer_not_supported_Error';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import HH_EN_Password_Validation_Must_contain_letter_and_number from '@salesforce/label/c.HH_EN_Password_Validation_Must_contain_letter_and_number';
import HH_EN_Password_Validation_Must_8_character_long from '@salesforce/label/c.HH_EN_Password_Validation_Must_8_character_long';
import HH_EN_Password_Validation_Password_Mismatch from '@salesforce/label/c.HH_EN_Password_Validation_Password_Mismatch';
import HH_EN_Password_Validation_Success from '@salesforce/label/c.HH_EN_Password_Validation_Success';
import HH_EN_Password_Validation_Please_Check_Password from '@salesforce/label/c.HH_EN_Password_Validation_Please_Check_Password';
import HH_EN_ExistingUserWithEmailErrorMessage from '@salesforce/label/c.HH_EN_ExistingUserWithEmailErrorMessage';

export default class hhCommunitySetPassword extends Utility {
    userValidated;
    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    hhLogo = HHLoginLogo;
    hhFire = HHFireDept;

    @track initialPassword;
    passwordCheck = false;
    isIE = false;
    showLoader = false;
    @track label ={
                 HH_EN_Select_Language,
                 HH_EN_Enter_Password,
                 HH_EN_Confirm_Password,
                 HH_EN_Submit,
                 HH_EN_Unsupported_Browser,
                 HH_EN_Internet_Explorer_not_supported_Error,
                 HH_EN_Password_Validation_Must_contain_letter_and_number,
                 HH_EN_Password_Validation_Must_8_character_long,
                 HH_EN_Password_Validation_Password_Mismatch,
                 HH_EN_Password_Validation_Success,
                 HH_EN_Password_Validation_Please_Check_Password,
                 HH_EN_ExistingUserWithEmailErrorMessage
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

    /* Populate language field as per current language in URL */
    setParametersBasedOnUrl() {
           this.language = this.urlStateParameters.language || 'en_US';
    }
    /*
    * Check whether current browser is Internet explorer or not
    */
    initData() {
        //this.languageChangeHandler();
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");

        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
            this.isIE = true;
        }
        else {
            this.isIE = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Translation_Language}) TranslationLanguage;

    /*
    * Validate password field
    */
    passwordPattern(event) {
        var validPattern = new RegExp(/^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9~`!@#$%^&*()-_+={[}\]\\|;:'",<.>\/?]+)$/);
        if(event.target.value.length > 0) {
            if(!validPattern.test(event.target.value)) {
                event.target.setCustomValidity(this.label.HH_EN_Password_Validation_Must_contain_letter_and_number);
            }
            else if(event.target.value.length < 8) {
                event.target.setCustomValidity(this.label.HH_EN_Password_Validation_Must_8_character_long);
            }
            else{
                event.target.setCustomValidity('');
                this.initialPassword = event.target.value;
            }
        }
        event.target.reportValidity();
    }

    /*
    * Check whether two password fields match or not
    */
    passwordMatch(event) {
        let confirmPassword = this.template.querySelector('.confirmpassword');
        if(this.initialPassword != this.recordLocal.Password__c) {
            confirmPassword.setCustomValidity(this.label.HH_EN_Password_Validation_Password_Mismatch);
            this.passwordCheck = false;
        }
        else{
            confirmPassword.setCustomValidity('');
            this.passwordCheck = true;
        }
        confirmPassword.reportValidity();
    }

    /*
    * Process set password
    */
    submit() {
        this.showLoader = true;
        this.recordLocal.urlToken = this.getURLParameter('token');
        if(this.passwordCheck) {
            setPassword({'token' : this.recordLocal.urlToken, 'password' : this.recordLocal.Password__c})
            .then(result => {
                this.showSuccessNotification('Success', this.label.HH_EN_Password_Validation_Success);
                setTimeout(() => {
                    window.location.href = result;
                    this.showLoader = false;
                }, 3000);
            })
            .catch(error => {
                if (error != undefined && error.body != undefined && error.body.message != undefined) {
                    if(error.body.message.includes('DUPLICATE_USERNAME')) {
                        this.showNotification('Error', this.label.HH_EN_ExistingUserWithEmailErrorMessage, 'error', 'dismissible');
                    } else {
                        this.showNotification('Error', error.body.message, 'error', 'dismissible');
                    }
                    this.showLoader = false;
                    return;
                }
                this.showNotification('Error', error, 'error', 'dismissible');
                this.showLoader = false;
            });
        }else{
            this.showNotification('Error', this.label.HH_EN_Password_Validation_Please_Check_Password, 'error', 'dismissible');
            this.showLoader = false;
        }

    }

    /* Change language of Page once user select Language */
    languageFieldChanged(event){
                this.language = event.target.value;
                var queryParams = new URLSearchParams(window.location.search);
                queryParams.set("language", this.language);
                history.replaceState(null, null, "?" + queryParams.toString());
                location.reload();

    }

    /* Navigate to handleLogin() when user clicks Enter Key */
    handleEnterKey(event){
             if (event.which == 13){
                console.log('Enter Key Preseed');
                this.submit();
             }
    }
}