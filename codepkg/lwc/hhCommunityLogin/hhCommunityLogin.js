/**
 * Created by Sushant P on 10-08-2021.
 */
import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import Translation_Language from '@salesforce/schema/User_Registration__c.Translation_Language__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import HHLoginLogo from '@salesforce/resourceUrl/HHLoginLogo';
import HHFireDept from '@salesforce/resourceUrl/HHFireDept';
import login from '@salesforce/apex/LightningLoginFormController.loginLWC';
import style from '@salesforce/resourceUrl/Style';
//import { parseQueryString } from 'c/utility';
import Language_field from '@salesforce/schema/Contact.Preferred_Language__c';
import UserId from '@salesforce/user/Id';
import HH_EN_Sign_In from '@salesforce/label/c.HH_EN_Sign_In';
import HH_EN_Select_Language from '@salesforce/label/c.HH_EN_Select_Language';
import HH_EN_Email_Address from '@salesforce/label/c.HH_EN_Email_Address';
import HH_EN_Password from '@salesforce/label/c.HH_EN_Password';
import HH_EN_Log_In from '@salesforce/label/c.HH_EN_Log_In';
import HH_EN_Forgot_Password from '@salesforce/label/c.HH_EN_Forgot_Password';
import HH_EN_Do_not_have_an_Account from '@salesforce/label/c.HH_EN_Do_not_have_an_Account';
import HH_EN_Register from '@salesforce/label/c.HH_EN_Register';
import HH_EN_contact_local_jurisdiction from '@salesforce/label/c.HH_EN_contact_local_jurisdiction';
import HH_EN_Unsupported_Browser from '@salesforce/label/c.HH_EN_Unsupported_Browser';
import HH_EN_Internet_Explorer_not_supported_Error from '@salesforce/label/c.HH_EN_Internet_Explorer_not_supported_Error';
import HH_url_forgot_password_page from '@salesforce/label/c.HH_url_forgot_password_page';
import HH_url_sign_up from '@salesforce/label/c.HH_url_sign_up';
import HH_url_LoginURL from '@salesforce/label/c.HH_url_LoginURL';

import { CurrentPageReference } from 'lightning/navigation';
import HH_EN_Enter_Email_Error from '@salesforce/label/c.HH_EN_Enter_Email_Error';
import HH_EN_Enter_Password_Error from '@salesforce/label/c.HH_EN_Enter_Password_Error';
import HH_Community_Relative_Url from '@salesforce/label/c.HH_Community_Relative_Url';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HH_EN_Invalid_Username_or_Password from '@salesforce/label/c.HH_EN_Invalid_Username_or_Password';


export default class hhCommunityLogin extends LightningElement {
    @track label ={
                 HH_EN_Sign_In,
                 HH_EN_Select_Language,
                 HH_EN_Email_Address,
                 HH_EN_Password,
                 HH_EN_Log_In,
                 HH_EN_Forgot_Password,
                 HH_EN_Do_not_have_an_Account,
                 HH_EN_Register,
                 HH_EN_contact_local_jurisdiction,
                 HH_EN_Unsupported_Browser,
                 HH_EN_Internet_Explorer_not_supported_Error,
                 HH_url_forgot_password_page,
                 HH_url_sign_up,
                 HH_EN_Enter_Email_Error,
                 HH_EN_Enter_Password_Error,
                 HH_Community_Relative_Url,
                 HH_EN_Invalid_Username_or_Password,
                 HH_url_LoginURL
    }
    @track username;
    @track password;
    @track startUrl;
    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    hhLogo = HHLoginLogo;
    hhFire = HHFireDept;
    isIE = false;

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
        * Loaded style from static resource and checked whether browser is Internet Explorer or not
    */
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
         this.extractStartURL();


    }

    extractStartURL() {
        let urlString = window.location.href;
        let paramString = urlString.split('?')[1];
        let params_arr = paramString.split('&');
        for(let i = 0; i < params_arr.length; i++) {
            let pair = params_arr[i].split('=');
            console.log("Key:" + pair[0]);
            console.log("Value: " + pair[1]);
            if(pair[0] == 'startURL') {
                this.startUrl = decodeURIComponent(pair[1]);
                return;
            }
        }
    }

    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Translation_Language}) TranslationLanguage;

    /*
        * Set username and password
    */
    handleFieldChange(event){
        const fieldName = event.target.name;
        if(fieldName == this.label.HH_EN_Email_Address){
            this.username = event.target.value;
        }else if(fieldName == this.label.HH_EN_Password){
            this.password = event.target.value;
        }
    }

    /*
        * Redirection to forgot password page
    */
    navigateToForgotPassword(){
        window.location.href = this.label.HH_url_forgot_password_page+'/?language='+this.language;
    }

    /*
        * Redirection to sign up page
    */
    navigateSignUp(){
        //this.showErrorNotification('Error',this.label.HH_EN_Enter_Email_Error);
        window.location.href = this.label.HH_url_sign_up+'/?language='+this.language;
    }

    /*
        * Validated fields and log in to the community
    */
    handleLogin(){
        if(this.username == undefined || this.username == null || this.username ==''){
            alert(this.label.HH_EN_Enter_Email_Error);
            return;
        }
        if(this.password == undefined || this.password == null || this.password ==''){
            alert(this.label.HH_EN_Enter_Password_Error);
            return;
        }
        if(this.startUrl ==  undefined || this.startUrl == '') {
        this.startUrl = this.label.HH_Community_Relative_Url+'/s';
        }
        login({ 'username' : this.username, 'password': this.password, 'startUrl': this.startUrl })
        .then((result) => {
            console.log('result----',JSON.stringify(result));
            if(result['success']){
                console.log('success');
                let url = result['url']+'/?language='+this.language;
                console.log('url -- '+url);
                window.location.href = url;
            }else{
                alert(result['errorMsg']);
            }
        })
        .catch((err) => {
          console.error(JSON.stringify(err));
          let str =  err.body.message;
          console.log('str+-- '+str);
          if(str == 'Your login attempt has failed. Make sure the username and password are correct.'){
            alert(this.label.HH_EN_Invalid_Username_or_Password);
          }else{
            alert(str);
          }
        });
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
            this.handleLogin();
         }
    }

    /* Navigate to Login Page */
    get navigateSignIn(){
        return this.label.HH_url_LoginURL+'?language='+this.language;
    }

}