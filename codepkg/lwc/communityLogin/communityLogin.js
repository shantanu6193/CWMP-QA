import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import headerLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import login from '@salesforce/apex/LightningLoginFormController.loginLWC';
import style from '@salesforce/resourceUrl/Style';
import { parseQueryString } from 'c/utility';
import Utility from 'c/utility';
import UserId from '@salesforce/user/Id';
export default class CommunityLogin extends Utility {

    @track username;
    @track password;
    @track startUrl;
    loginLogo = headerLogo + '/headerLogo/HMA_Login_Logo_White.png';
    cdphLogo =  headerLogo + '/headerLogo/CDPH_Logo.jfif';
    emsaLogo = headerLogo + '/headerLogo/EMSA_Logo.jfif';
    isIE = false;

    /*
        * Loaded style from static resource and checked whether browser is Internet Explorer or not
    */
    connectedCallback() {
        loadStyle(this, style);
        this.password = '';
        this.startUrl = '';

        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");

        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
            this.isIE = true;
        }
        else {
            this.isIE = false;
        }
        if(UserId) {
            window.location.href = '/s';
        }
    }

    /*
        * Set username and password
    */
    handleFieldChange(event){
        const fieldName = event.target.name;
        if(fieldName == 'username'){
            this.username = event.target.value;
        }else if(fieldName == 'password'){
            this.password = event.target.value;
        }
    }
    /*
        * After Username blur handle field values
    */
    handleFieldBlur(event){
        const fieldName = event.target.name;
        if(fieldName == 'username' && event.target.value){
            this.username = event.target.value.trim();
        }else if(fieldName == 'password' && event.target.value){
            this.password = event.target.value.trim();
        }
    }

    /*
        * Redirection to forgot password page
    */
    navigateToForgotPassword(){
        window.location.href = '/s/reset-password';
    }

    /*
        * Redirection to sign up page
    */
    navigateSignUp(){
        window.location.href = '/s/cal-sign-up';
    }

    /*
        * Validated fields and log in to the community
    */
    handleLogin(){
        if(this.username == null || this.username == undefined || this.username ==''){
            alert('Enter Email');
            return;
        }
        if(this.password == null || this.password == undefined || this.password ==''){
            alert('Enter Password');
            return;
        }

        login({ 'username' : this.username, 'password': this.password, 'startUrl': this.startUrl })
        .then((result) => {
            console.log('result----',JSON.stringify(result));
            if(result['success']){
                console.log('success');
                window.location.href = result['url'];
            }else{
                alert(result['errorMsg']);
            }
        })
        .catch((err) => {
          console.error(JSON.stringify(err));
          alert(err.body.message);
        });
    }

}