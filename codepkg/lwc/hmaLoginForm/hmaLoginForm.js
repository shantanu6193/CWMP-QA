/**
 * Created by PREM on 18-06-2020.
 */

/*import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import loginFormLogo from '@salesforce/resourceUrl/HMA_Login_Logo';
import login from '@salesforce/apex/LightningLoginFormController.loginLWC';
import style from '@salesforce/resourceUrl/Style';
import { parseQueryString } from 'c/utility';*/
import Utility from 'c/utility';
export default class HmaLoginForm extends Utility {
    initData() {
        window.location.href = '/s/login/'; 
    }
/*
    @track username;
    @track password;
    @track startUrl;
    loginLogo = loginFormLogo;

    connectedCallback() {
        loadStyle(this, style);
        this.password = '';
        this.startUrl = '';
    }

    handleFieldChange(event){
        const fieldName = event.target.name;
        if(fieldName == 'username'){
            this.username = event.target.value;
        }else if(fieldName == 'password'){
            this.password = event.target.value;
        }
    }
    navigateToForgotPassword(){
        window.location.href = '/hma/s/login/ForgotPassword';
    }
    navigateSignUp(){
        window.location.href = '/hma/s/login/SelfRegister';
    }
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
*/
}