import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import Translation_Language from '@salesforce/schema/User_Registration__c.Translation_Language__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import HHFireDept from '@salesforce/resourceUrl/HHFireDept';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HHLoginLogo from '@salesforce/resourceUrl/HHLoginLogo';
import resetUserPassword from '@salesforce/apex/CommunityResetPasswordCtrl.resetPassword';
import Utility from 'c/utility';
import HH_EN_Select_Language from '@salesforce/label/c.HH_EN_Select_Language';
import HH_EN_Need_Email_Address_Paragraph from '@salesforce/label/c.HH_EN_Need_Email_Address_Paragraph';
import HH_EN_Email_Address from '@salesforce/label/c.HH_EN_Email_Address';
import HH_EN_Password_Reset from '@salesforce/label/c.HH_EN_Password_Reset';
import HH_EN_Reset_Password from '@salesforce/label/c.HH_EN_Reset_Password';
import HH_url_forgot_password_page from '@salesforce/label/c.HH_url_forgot_password_page';
import HH_EN_Cancel from '@salesforce/label/c.HH_EN_Cancel';
import HH_EN_Unsupported_Browser from '@salesforce/label/c.HH_EN_Unsupported_Browser';
import HH_EN_Internet_Explorer_not_supported_Error from '@salesforce/label/c.HH_EN_Internet_Explorer_not_supported_Error';
import HH_url_LoginURL from '@salesforce/label/c.HH_url_LoginURL';
import HH_EN_Reset_Email_Send from '@salesforce/label/c.HH_EN_Reset_Email_Send';
import { CurrentPageReference } from 'lightning/navigation';
import HH_RecordType_API_Name_HH_Registration from '@salesforce/label/c.HH_RecordType_API_Name_HH_Registration';
import HH_EN_Enter_Email_Error from '@salesforce/label/c.HH_EN_Enter_Email_Error';

export default class hhCommunityResetPassword extends Utility {
    username='';

    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    hhLogo = HHLoginLogo;
    hhFire = HHFireDept;
    isIE = false;
    showLoader = false;
    disableButton = false;
    @track label ={
             HH_EN_Select_Language,
             HH_EN_Need_Email_Address_Paragraph,
             HH_EN_Email_Address,
             HH_EN_Password_Reset,
             HH_EN_Reset_Password,
             HH_EN_Cancel,
             HH_EN_Unsupported_Browser,
             HH_EN_Internet_Explorer_not_supported_Error,
             HH_url_LoginURL,
             HH_EN_Reset_Email_Send,
             HH_RecordType_API_Name_HH_Registration,
             HH_EN_Enter_Email_Error,
             HH_url_forgot_password_page
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
    * Set value to username field
    */
    handleFieldChange(event){
        this.username = event.target.value;
    }

    /*
    * Validate field and process reset passworkd request
    */
    resetPassword() {
        if(this.username == null || this.username == undefined || this.username ==''){
            this.showNotification('Error', this.label.HH_EN_Enter_Email_Error, 'error','dismissible');
        }else{
            this.showLoader = true;
            console.log('username----------->'+this.username);
            console.log('language----------->'+this.language);
            if(this.username){
                this.disableButton = true;
                /** Updated Cde Added 2 (language, recordTypeName) more parameters for HH Community **/
                resetUserPassword({'username' : this.username,'language' : this.language,'recordTypeName' : this.label.HH_RecordType_API_Name_HH_Registration })
                .then((result)=>{
                    console.log('result----->',result);
                    this.showNotification('Success',this.label.HH_EN_Reset_Email_Send, 'success','dismissible');
                    this.showLoader = false;
                    setTimeout(() => {
                        this.redirectToCommunityLoginPage();
                    }, 5000);
                }).catch(error=>{
                    this.disableButton = false;
                    console.log('error----->',error);
                    this.showNotification('Error', error.body.message, 'error','dismissible');
                    this.showLoader = false;
                });
          }
        }
    }

    /*
    * Redirect to login page
    */
    navigateToLogin(event){
        window.location.href = this.label.HH_url_LoginURL+'/?language='+this.language;
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
        event.target.patter;
                 if (event.which == 13){
                    this.resetPassword();
                 }
    }

    get navigateToForgotPassword(){
        return this.label.HH_url_forgot_password_page+'/?language='+this.language;
    }
}