/**
 * Created by Sushant Patil on 13-08-2021.
 */

import { LightningElement, wire, api, track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import HHLoginLogo from '@salesforce/resourceUrl/HHLoginLogo';
import HHFireDept from '@salesforce/resourceUrl/HHFireDept';
import Translation_Language from '@salesforce/schema/User_Registration__c.Translation_Language__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import HH_EN_Select_Language from '@salesforce/label/c.HH_EN_Select_Language';
import { CurrentPageReference } from 'lightning/navigation';
import HH_EN_Already_have_an_Account from '@salesforce/label/c.HH_EN_Already_have_an_Account';
import HH_EN_Sign_In from '@salesforce/label/c.HH_EN_Sign_In';
import HH_url_LoginURL from '@salesforce/label/c.HH_url_LoginURL';
import HH_url_sign_up from '@salesforce/label/c.HH_url_sign_up';
import HH_Community_Relative_Url from '@salesforce/label/c.HH_Community_Relative_Url';
import HH_EN_Landing_Page_Para_1 from '@salesforce/label/c.HH_EN_Landing_Page_Para_1';
import HH_EN_Landing_Page_Para_2 from '@salesforce/label/c.HH_EN_Landing_Page_Para_2';
import HH_EN_Landing_Page_Para_3 from '@salesforce/label/c.HH_EN_Landing_Page_Para_3';
import HH_EN_Do_not_have_an_Account from '@salesforce/label/c.HH_EN_Do_not_have_an_Account';
import HH_EN_contact_local_jurisdiction from '@salesforce/label/c.HH_EN_contact_local_jurisdiction';
import HH_EN_Unsupported_Browser from '@salesforce/label/c.HH_EN_Unsupported_Browser';
import HH_EN_Internet_Explorer_not_supported_Error from '@salesforce/label/c.HH_EN_Internet_Explorer_not_supported_Error';
import HH_EN_Landing_Page_Title from '@salesforce/label/c.HH_EN_Landing_Page_Title';
import HH_EN_Register from '@salesforce/label/c.HH_EN_Register';
import HH_EN_Copyright_2021_State_of_California from '@salesforce/label/c.HH_EN_Copyright_2021_State_of_California';

export default class HhCommunityLandingPage extends LightningElement {
     @track label ={
                     HH_EN_Select_Language,
                     HH_EN_Already_have_an_Account,
                     HH_EN_Sign_In,
                     HH_url_LoginURL,
                     HH_url_sign_up,
                     HH_EN_Landing_Page_Para_1,
                     HH_EN_Landing_Page_Para_2,
                     HH_EN_Landing_Page_Para_3,
                     HH_EN_Do_not_have_an_Account,
                     HH_EN_Unsupported_Browser,
                     HH_EN_Internet_Explorer_not_supported_Error,
                     HH_EN_contact_local_jurisdiction,
                     HH_EN_Landing_Page_Title,
                     HH_EN_Register,
                     HH_EN_Copyright_2021_State_of_California,
                     HH_Community_Relative_Url
                   }
     @track language = 'en_US';
     loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
     hhLogo = HHLoginLogo;
     hhFire = HHFireDept;
     isIE = false;
     /* To hold the current selected language after page reload.*/
     @wire(CurrentPageReference)
                     getStateParameters(currentPageReference) {
                        if (currentPageReference) {
                           this.urlStateParameters = currentPageReference.state;
                           this.setParametersBasedOnUrl();
                        }
     }

     /* Populate language field as per current language in URL */
     setParametersBasedOnUrl() {
                    this.language = this.urlStateParameters.language ||'en_US';
     }

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

     /* Change language of Page once user select Language */
     languageFieldChanged(event){
                     this.language = event.target.value;
                     var queryParams = new URLSearchParams(window.location.search);
                     queryParams.set("language", this.language);
                     history.replaceState(null, null, "?" + queryParams.toString());
                     location.reload();
    }
    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Translation_Language}) TranslationLanguage;

    /* Navigate to Login Page */
    get navigateSignIn(){
              return this.label.HH_url_LoginURL+'?language='+this.language;
    }

    navigateButtonSignIn(){
               window.location.href = this.label.HH_url_LoginURL+'?language='+this.language;;
    }

    /* Navigate to Registration Page */
    get navigateSignUp(){
               return this.label.HH_url_sign_up+'?language='+this.language;
    }

    get landingPageUrl() {
      return this.label.HH_Community_Relative_Url+'/s';
  }
}