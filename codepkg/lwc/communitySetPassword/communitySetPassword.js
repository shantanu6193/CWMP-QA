import { LightningElement, track, api, wire } from 'lwc';
import setPassword from '@salesforce/apex/CommunitySetPasswordCtrl.setPassword';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import checkPasswordExpired from '@salesforce/apex/CommunitySetPasswordCtrl.checkPasswordExpired';
import Utility from 'c/utility';

export default class communitySetPassword extends Utility {
    userValidated;
    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    cdphLogo =  headerLogo + '/headerLogo/CDPH_Logo.jfif';
    emsaLogo = headerLogo + '/headerLogo/EMSA_Logo.jfif';
    
    @track initialPassword;
    passwordCheck = false;
    isIE = false;
    showLoader = false;
    tokenNotExpired = true;
    //@track disabledSignUpButton = true;

    /*
    * Check whether current browser is Internet explorer or not
    */
    initData() {
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        this.recordLocal.urlToken = this.getURLParameter('token');
        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
            this.isIE = true;
        }
        else {
            this.isIE = false;
        }
        this.executeAction(checkPasswordExpired, {'token' : this.recordLocal.urlToken}, (response) => {
            this.tokenNotExpired = response;
            if(this.tokenNotExpired == false) {
                this.showErrorNotification('Error', 'Password reset token/link is expired');
            }
        });
    }

    /*
    * Validate password field
    */
    passwordPattern(event) {
        var validPattern = new RegExp(/^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9~`!@#$%^&*()-_+={[}\]\\|;:'",<.>\/?]+)$/);
        if(event.target.value.length > 0) {
            if(!validPattern.test(event.target.value)) {
                event.target.setCustomValidity('Must contain combination of letters and numbers');
            } 
            else if(event.target.value.length < 8) {
                event.target.setCustomValidity('Must be 8 character long');
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
            confirmPassword.setCustomValidity('Password Mismatch');
            this.passwordCheck = false;
            //this.disabledSignUpButton = false;
        }
        else if(this.recordLocal.Password__c == null && this.initialPassword == null){
           this.passwordCheck = false;
           //this.disabledSignUpButton = true;
        }else{
            confirmPassword.setCustomValidity('');
            this.passwordCheck = true;
             //this.disabledSignUpButton = false;
        }
        confirmPassword.reportValidity();
    }

    get disabledSignUpButton(){
        if(this.recordLocal.Password__c == null || this.initialPassword == null){
            return true;
        }else{
            return false;
        }
    }
    /*
    * Process set password
    */
    submit() {
        let confirmPassword = this.template.querySelector('.confirmpassword');
        if(this.initialPassword != this.recordLocal.Password__c) {
            confirmPassword.setCustomValidity('Password Mismatch');
            return;
         }
         confirmPassword.reportValidity();
        /*executeAction(checkUserValidation, {'token' : this.recordLocal.urlToken, 'password' : this.recordLocal.Password__c}, 'Success', 'Error');
        this.showSuccessNotification('Success', 'Password Set Successfully');
        this.redirectToCommunityLoginPage();*/
        this.recordLocal.urlToken = this.getURLParameter('token');
        if(this.passwordCheck) {
            this.showLoader = true;
            setPassword({'token' : this.recordLocal.urlToken, 'password' : this.recordLocal.Password__c})
            .then(result => {
                this.showSuccessNotification('Success', 'Password Set Successfully');
                setTimeout(() => {
                    window.location.href = result;
                    this.showLoader = false;
                }, 3000);

            })
            .catch(error => {
                this.showErrorNotification('Error', error.body.message);
                this.showLoader = false;
            });
        }  //#JIRA #https://stacknexus.atlassian.net/browse/CALOESPA-179
        else{
            this.showNotification('Error', 'Please fill all required fields', 'Error','dismissable');
            //this.showLoader = false;
           // window.location.href = document.location.href;
        }
        
    }
}