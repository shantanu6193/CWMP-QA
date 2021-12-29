/**
 * Created by Pankaj on 08-07-2020.
 */

import { LightningElement,api,wire,track } from 'lwc';
import Utility from 'c/utility';
import submitRequest from '@salesforce/apex/CommunityAppHmaRegistrationCtrl.processHMARequest';
import getUserDetails from '@salesforce/apex/CommunityAppHmaRegistrationCtrl.getUserDetails';
export default class CommunityAppHmaRegistration extends Utility {
        @api appId;
        contactRecord;
        /*@wire(getUserDetails)
        wiredApplications({ error, data }) {
            if (data) {
                this.contactRecord = data.ContactDetails;
                console.log('this.contactRecord--------',this.contactRecord);
            }
        }*/
        initData(){
            this.executeAction(getUserDetails, {}, (response) => {
                console.log('-----resp------',response);
                this.contactRecord = response.ContactDetails;
                console.log('this.contactRecord------',this.contactRecord);
            });
        }
        get IsContactRecord(){
            if(this.contactRecord != null) return true;
                return false;
        }
        submitDetails() {
            //this.recordLocal.Community_Application__c = this.appId;
            this.executeAction(submitRequest, {}, (response) => {
                this.showLoader = true;
                this.buttonDisabled = true;
                this.showSuccessNotification('Success', 'Please login to App.');
                setTimeout(function(){
                    location. reload();
                    },2000);
            
            });


        }

}