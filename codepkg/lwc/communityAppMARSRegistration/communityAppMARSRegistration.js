import { LightningElement,api,wire,track } from 'lwc';
import Utility from 'c/utility';
import submitRequest from '@salesforce/apex/CommunityAppMARSRegistrationCtrl.processMARSRequest';
import getUserDetails from '@salesforce/apex/CommunityAppMARSRegistrationCtrl.getUserDetails';
import submitRequestforPayingEntity from '@salesforce/apex/CommunityAppMARSRegistrationCtrl.processMARSPayingEntityRequest';

export default class CommunityAppMARSRegistration extends Utility {
    @api contactRecord;


    initData(){
        this.executeAction(getUserDetails, {}, (response) => {
            this.contactRecord = response.ContactDetails;
        });
    }
    get IsContactRecord(){
        if(this.contactRecord != null) return true;
            return false;
    }

    get isPayingEntity(){
        if(this.contactRecord.Account.Entity_Type__c == 'MARS Paying Entity'){
            return true;
        }
        return false;
    }

    get isFireAgency(){
        if(this.contactRecord.Account.Entity_Type__c != 'MARS Paying Entity'){
            return true;
        }
        return false;
    }
    
    submitDetails(event) {
        let level = event.target.name;
        let accId = this.contactRecord.AccountId;
        let conId = this.contactRecord.Id;
        this.executeAction(submitRequest, {
            accessLevel: level,
            accountId: accId,
            contactId: conId
        },(response) => {
            this.showLoader = true;
            this.buttonDisabled = true;
            this.showSuccessNotification('Success', 'Your request is submitted for Approval. once Approved you will be notified and you can login to the app from here.');
            setTimeout(function(){
                location. reload();
                },2000);
        
        });
    }

    submitDetailsforPayingEntity(event) {
        let accId = this.contactRecord.AccountId;
        let conId = this.contactRecord.Id;
        this.executeAction(submitRequestforPayingEntity, {
            accountId: accId,
            contactId: conId
        },(response) => {
            this.showLoader = true;
            this.buttonDisabled = true;
            this.showSuccessNotification('Success', 'Your request is submitted for Approval. once Approved you will be notified and you can login to the app from here.');
            setTimeout(function(){
                location. reload();
                },2000);
        
        });
    }



}