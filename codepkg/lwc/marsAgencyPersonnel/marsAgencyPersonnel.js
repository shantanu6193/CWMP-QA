import { LightningElement, track, api, wire } from 'lwc';
import getAgenciesUsersList from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.getAgenciesUsersList';
import getPendingAgenciesUsersList from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.getPendingAgenciesUsersList';

import submitUserAccessChangeRequest from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.submitUserAccessChangeRequest';
import submitRemoveUserAccessRequest from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.submitRemoveUserAccessRequest';
import submitAddUserAccessRequest from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.submitAddUserAccessRequest';

import submitUserAccessApproveRequest from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.submitUserAccessApproveRequest';
import submitUserAccessRejectRequest from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.submitUserAccessRejectRequest';

import { NavigationMixin } from 'lightning/navigation';

import Utility from 'c/utility';


const columns = [  
    { label: 'First Name', fieldName: 'FirstName' },  
    { label: 'Last Name', fieldName: 'LastName' },  
    { label: 'Email', fieldName: 'Email' },  
    { label: 'Phone', fieldName: 'Phone' },  
    { label: 'Access Level', fieldName: 'Relationship_Strength__c' },  
    { label: 'IsActive', fieldName: 'IsActive' },  

    {type: "button", label: 'Action', fixedWidth: 180, typeAttributes: {  
        label: 'Update Access Level',  
        name: 'Update Access Level',  
        title: 'Update Access Level',  
        disabled: false,  
        value: 'update',  
        iconPosition: 'left'  
    }},  
    {type: "button",  label: 'Action', fixedWidth: 120, typeAttributes: {  
        label: { fieldName: 'AccessLevelButton'},  
        name: { fieldName: 'AccessLevelButton'},  
        title: { fieldName: 'AccessLevelButton'},  
        disabled: false,  
        value: 'access',  
        iconPosition: 'left'  
    }}  
];  

const pendcolumns = [  
    { label: 'First Name', fieldName: 'FirstName' },  
    { label: 'Last Name', fieldName: 'LastName' },  
    { label: 'Email', fieldName: 'Email' },  
    { label: 'Phone', fieldName: 'Phone' },  
    { label: 'Access Level Requested', fieldName: 'AccessLevel' },  
    {type: "button", label: 'Action', fixedWidth: 120, typeAttributes: {  
        label: 'Approve',  
        name: 'Approve',  
        title: 'Approve',  
        disabled: false,  
        value: 'Approve',  
        iconPosition: 'left'  
    }},  
    {type: "button", label: 'Action', fixedWidth: 120, typeAttributes: {  
        label: 'Reject',  
        name: 'Reject',  
        title: 'Reject',  
        disabled: false,  
        value: 'Reject',  
        iconPosition: 'left'  
    }},  
];  


export default class MarsAgencyPersonnel  extends Utility  {

    @api  recordId;
    @track usersNew =[];
    @track usersReq =[];

    @track error;
    @track isUpdateAccessToLevel1ModalOpen = false;
    @track isUpdateAccessToLevel2ModalOpen = false;
    @track isRemoveAccessModalOpen = false;
    @track isAddAccessModalOpen = false;

    @track isApprovePendingAccessModalOpen = false;
    @track isRejectPendingAccessModalOpen = false;

    @track contactid ="";
    @track accountid="";
    @track accesslevel="";
    @track id="";
    @track pendingid="";


    buttonDisabled = false;

    @track columns = columns;  
    @track pendcolumns = pendcolumns;  
    
    connectedCallback() {
        this.fnGetAllOrgsUsers(this.recordId);
        this.fnGetAllPendingOrgsUsers(this.recordId);

      }

      fnGetAllOrgsUsers(recordId) {

        console.log('GET ALL ORG USERS');
            


		getAgenciesUsersList({
            accountId: recordId
          })
			.then(result => {


                
                    var newResults = [];


                    result.forEach(function(temp,Index){

                        var accessLevelButton ='';
                        //This set the Action Button to display Either Remove or Add Access
                        if (temp.IsActive === true)
                        {
                            accessLevelButton = 'Deactivate'

                        }else
                        {
                            accessLevelButton = 'Activate'
                        }
                        newResults.push({
                            "Id": temp.Id,
                            "FirstName": temp.Contact.FirstName,
                         "LastName": temp.Contact.LastName,
                         "Email": temp.Contact.Email,
                         "Phone": temp.Contact.Phone,
                         "ContactId": temp.ContactId,
                         "AccountId": temp.AccountId,
                         "IsActive": temp.IsActive,
                         "AccessLevelButton": accessLevelButton,
                         "Relationship_Strength__c": temp.Relationship_Strength__c
                        });


                    });

                this.usersNew = null;
                 this.usersNew = newResults;

			})
			.catch(error => {
				this.error = error;
			});
    }
    
    fnGetAllPendingOrgsUsers(recordId) {

        console.log('GET ALLPending ORG USERS');
            
        console.log(recordId);


		getPendingAgenciesUsersList({
            accountId: recordId
          })
			.then(result => {


                
                    var newResults = [];


                    result.forEach(function(temp,Index){

                        newResults.push({
                            "Id": temp.Id,
                            "FirstName": temp.First_Name__c,
                         "LastName": temp.Last_Name__c,
                         "Email": temp.Email__c,
                         "Phone":  (temp.Contact_Name__r != null) ? temp.Contact_Name__r.Phone : '',
                         "AccessLevel": temp.Access_Level__c
                        });


                    });

                this.usersReq = null;
                 this.usersReq = newResults;

			})
			.catch(error => {
				this.error = error;
			});
    }
    


    closeUpdateAccessToLevel1Modal(event) {
        this.isUpdateAccessToLevel1ModalOpen = false;
    }
    closeUpdateAccessToLevel2Modal(event) {
        this.isUpdateAccessToLevel2ModalOpen = false;
    }
    closeRemoveAccessModal(event) {
        this.isRemoveAccessModalOpen = false;
    }
    closeAddAccessModal(event) {
        this.isAddAccessModalOpen = false;
    }

    closeApprovePendingAccessModal(event) {
        this.isApprovePendingAccessModalOpen = false;
    }
    closeRejectPendingAccessModal(event) {
        this.isRejectPendingAccessModalOpen = false;
    }

    callRowAction( event ) {  

        this.contactid =  event.detail.row.ContactId;
        this.accountid =  event.detail.row.AccountId;
        this.accesslevel = event.detail.row.Relationship_Strength__c;

        this.id = event.detail.row.Id;


        switch (event.detail.action.value) {
            case 'update':

                if(event.detail.row.Relationship_Strength__c === 'Primary'){
                    this.isUpdateAccessToLevel2ModalOpen = true;
                }
                if(event.detail.row.Relationship_Strength__c === 'Secondary'){
                    this.isUpdateAccessToLevel1ModalOpen = true;
                }

                break;
            case 'access':

          console.log(event.detail.row.AccessLevelButton);
            
                if(event.detail.row.AccessLevelButton === 'Deactivate'){
                    this.isRemoveAccessModalOpen = true;
                }
                if(event.detail.row.AccessLevelButton === 'Activate'){
                    this.isAddAccessModalOpen = true;
                }

                break;

        }
  
    }  


    callPendRowAction( event ) {  


        this.pendingid = event.detail.row.Id;

        switch (event.detail.action.value) {
            case 'Approve':

                this.isApprovePendingAccessModalOpen = true;


                break;
            case 'Reject':

            
              this.isRejectPendingAccessModalOpen = true;

                break;

        }
  
    }  


    submitChangeDetails(event) {


        console.log(this.contactid);
        console.log(this.accountid);
        console.log(this.accesslevel);

        
        submitUserAccessChangeRequest({
            contactId: this.contactid,
            accountId: this.accountid,
            accessLevel: this.accesslevel

          })
			.then(result => {


                this.isUpdateAccessToLevel1ModalOpen = false;
                this.isUpdateAccessToLevel2ModalOpen = false;




                this.showSuccessNotification('Success', 'User Access Level Changed');

                 //Refresh Page -- Cant get data to update
                 setTimeout(function(){
                    location. reload();
                    },1000);

			})
			.catch(error => {
				this.error = error;
			});
            
 
    }

    submitRemoveChangeDetails(event) {
        console.log(this.contactid);
        console.log(this.accountid);
        console.log(this.accesslevel);
        submitRemoveUserAccessRequest({
            contactId: this.contactid,
            accountId: this.accountid,
            accessLevel: this.accesslevel

          })
			.then(result => {

                this.isRemoveAccessModalOpen = false;
                this.fnGetAllOrgsUsers(this.recordId);
                this.showSuccessNotification('Success', 'User Access Removed');
                //Refresh Page -- Cant get data to update
                setTimeout(function(){
                    location. reload();
                    },1000);
			})
			.catch(error => {
				this.error = error;
			});

    }

    submitAddChangeDetails(event) {
        console.log(this.contactid);
        console.log(this.accountid);
        console.log(this.accesslevel);
        submitAddUserAccessRequest({
            contactId: this.contactid,
            accountId: this.accountid,
            accessLevel: this.accesslevel

          })
			.then(result => {

                this.isAddAccessModalOpen = false;
                this.fnGetAllOrgsUsers(this.recordId);
                this.showSuccessNotification('Success', 'User Access Added');
                //Refresh Page -- Cant get data to update
                setTimeout(function(){
                    location. reload();
                    },1000);
			})
			.catch(error => {
				this.error = error;
			});

    }
    


    submitApprovePendingDetails(event) {

    
        submitUserAccessApproveRequest({
            userregid: this.pendingid

          })
			.then(result => {

                this.isApprovePendingAccessModalOpen = false;
                this.fnGetAllOrgsUsers(this.recordId);
                this.showSuccessNotification('Success', 'User Access Approved');
                //Refresh Page -- Cant get data to update
                setTimeout(function(){
                    location. reload();
                    },1000);
			})
			.catch(error => {
				this.error = error;
			});

    }

    submitRejectPendingDetails(event) {


        submitUserAccessRejectRequest({
            userregid: this.pendingid
          })
			.then(result => {

                this.isRejectPendingAccessModalOpen = false;
                this.fnGetAllOrgsUsers(this.recordId);
                this.showSuccessNotification('Success', 'User Access Rejected');
                //Refresh Page -- Cant get data to update
                setTimeout(function(){
                    location. reload();
                    },1000);
			})
			.catch(error => {
				this.error = error;
			});

    }






}