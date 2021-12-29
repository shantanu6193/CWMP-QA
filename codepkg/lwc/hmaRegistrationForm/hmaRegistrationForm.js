/**
 * Created by PREM on 19-06-2020.
 */

/*import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import loginFormLogo from '@salesforce/resourceUrl/HMA_Login_Logo';
import style from '@salesforce/resourceUrl/Style';
import registerUser from '@salesforce/apex/RegistrationCtrl.registerUser';*/
import Utility from 'c/utility';
export default class HmaRegistrationForm extends Utility {
    initData() {
        window.location.href = '/s/login/'; 
    }
    /*loginLogo = loginFormLogo;
    handleRegister(event){
        console.log('recordlocal----',JSON.stringify(this.recordLocal));
        registerUser({ 'userDetails' : JSON.stringify(this.recordLocal)})
        .then((result) => {
            console.log('result----',JSON.stringify(result));
            this.showNotification('Success', 'Your registration is successful, Please check your Email to login', 'success','sticky');
            setTimeout(() => {
                this.redirectToCommunityLoginPage();
            },2000);
        })
        .catch(error => {
            console.log('error>>',error.body.message);
            let errorMessage = error.body && error.body.message ? error.body.message : 'Something went wrong, please contact your administrator.';
            this.showNotification('Error', errorMessage, 'error', 'sticky');
        });
    }
    redirectToLogin(){
        window.location.href = '/hma/s/login/';
    }*/
    initData() {
        window.location.href = '/s/login/'; 
    }
}