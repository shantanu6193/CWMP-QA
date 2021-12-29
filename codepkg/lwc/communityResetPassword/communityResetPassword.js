import { LightningElement } from 'lwc';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resetUserPassword from '@salesforce/apex/CommunityResetPasswordCtrl.resetPassword';
import Utility from 'c/utility';

export default class CommunityResetPassword extends Utility {
    username='';
    
    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    cdphLogo =  headerLogo + '/headerLogo/CDPH_Logo.jfif';
    emsaLogo = headerLogo + '/headerLogo/EMSA_Logo.jfif';
    isIE = false;
    showLoader = false;

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
    }

    /*
    * Set value to username field
    */
    handleFieldChange(event){
        this.username = event.target.value;
    }
    /*
    * handle field value after blur
    */
    handleFieldBlur(event){
        this.username = event.target.value.trim();
    }
    /*
    * Validate field and process reset passworkd request
    */
    resetPassword() {
        if(this.username == null || this.username == undefined || this.username ==''){
            //#JIRA #https://stacknexus.atlassian.net/browse/CALOESPA-137
            this.showNotification('Error', 'Please fill Email field', 'error');
            navigateToForgotPassword();
        }
        this.showLoader = true;
        console.log('username----------->'+this.username);
        if(this.username){
            resetUserPassword({'username' : this.username})
            .then((result)=>{
                console.log('result----->',result);
                this.showNotification('Success', 'Check the email account associated with your email address for instructions on resetting your password. Remember to look in your spam folder, where automated messages sometimes filter. If you still are unable to log in, contact your administrator.', 'success');
                this.showLoader = false;
                setTimeout(() => {
                    this.redirectToCommunityLoginPage();
                }, 5000);
            }).catch(error=>{
                console.log('error----->',error);
                this.showNotification('Error', error.body.message, 'error');
                this.showLoader = false;
            });
      }
    }

    /*
    * Redirect to login page
    */
    navigateToLogin(event){
        window.location.href = '/s/';
    }
}