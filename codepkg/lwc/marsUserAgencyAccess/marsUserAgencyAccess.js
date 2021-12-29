import {
    LightningElement,
    wire,
    api,
    track
  } from 'lwc';
import Utility from 'c/utility';
import {
    NavigationMixin
} from 'lightning/navigation';
import getAgenciesList from '@salesforce/apex/MARS_UserAgencyAccess_Ctrl.getAgenciesList';
import apexSearchFireAgency from '@salesforce/apex/MARS_UserAgencyAccess_Ctrl.apexSearchFireAgency';
import submitRequest from '@salesforce/apex/MARS_UserAgencyAccess_Ctrl.submitNewAgencyAccessRequest';
import submitChangeRequest from '@salesforce/apex/MARS_UserAgencyAccess_Ctrl.submitChangeAgencyAccessRequest';


export default class userAgencyAccessMARS extends Utility {
    @track isModalOpen = false;
    @track isUpdateAccessModalOpen = false;
    @track isUpdateAccessToLevel1ModalOpen = false;
    @track isUpdateAccessToLevel2ModalOpen = false;
    @track approvedAgencies;
    @track pendingAgencies;
    @track error;
    @track selectedAgencyId;
    @api
    fireagencyRequired = [];
    validLookups = true;
    buttonDisabled = false;

    @api isCalledFromAura = false;

    connectedCallback() {
        console.log('###: isCalledFromAura: ' + JSON.stringify(this.isCalledFromAura))
    }

    @wire(getAgenciesList)
    wiredAgencies({
        error,
        data
    }) {
        if (data) {
            this.approvedAgencies = data['ApprovedAgencies'];
            this.pendingAgencies = data['PendingAgencies'];
        } else if (error) {
            this.error = error;
        }
    }
    @api handleCallFromAura() {
        console.log('###: in handleAgencyRequest')
        this.isCalledFromAura = true;
        console.log('###: Modal Open: ' + JSON.stringify(this.isCalledFromAura))
    }

    @api handleAgencyRequest() {
        console.log('###: in handleAgencyRequest')
        this.isModalOpen = true;
        console.log('###: Modal Open: ' + JSON.stringify(this.isModalOpen))
    }
    handleUpdateAgencyRequest(event){
        this.selectedAgencyId = event.currentTarget.dataset.myvalue;
        var currentlevel = event.currentTarget.dataset.agenvalue;
        if(currentlevel === 'Primary'){
            this.isUpdateAccessToLevel2ModalOpen = true;
        }
        if(currentlevel === 'Secondary'){
            this.isUpdateAccessToLevel1ModalOpen = true;
        }
    }
    logConsole(event) {
        console.log("this is a test");
    }
    closeModal(event) {
        this.isModalOpen = false;
    }
    closeUpdateAccessModal(event) {
        this.isUpdateAccessModalOpen = false;
    }
    closeUpdateAccessToLevel1Modal(event) {
        this.isUpdateAccessToLevel1ModalOpen = false;
    }
    closeUpdateAccessToLevel2Modal(event) {
        this.isUpdateAccessToLevel2ModalOpen = false;
    }
    handleAgencyOnClick(event) {
        var clickedAgencyId = event.currentTarget.dataset.id;
        var approvalStatus = event.currentTarget.dataset.status;
        if(approvalStatus === 'Approved'){
            this.redirectToCommunityCustomPage('AgencyInfoPage__c', {
                'id': clickedAgencyId
            });
        }else{
            this.showErrorNotification('Stop', 'You do not have access to this agency until the status is changed to approved');
        }
    }
    loadLookupDataOnLoad = false;
     /*
    * Searches account with Entity_Type__c equals Fire_Agency__c
    */
     handleFireAgencySearch(event) {
        apexSearchFireAgency(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Fire_Agency__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Fire_Agency__c
    */
    handleFireAgencyChange(response) {
        if(!response.detail){
           this.selectedAgencyId = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.selectedAgencyId = response.detail.selectedItem.id;
        }
    }

    submitDetails(event) {
        let level = event.target.name;
        let accId = this.selectedAgencyId;
        this.fireagencyRequired = [];
        if(accId === null || accId === '' || accId === undefined){
            this.fireagencyRequired.push({
                message: 'Please select an agency before proceeding. You can type in the name of the agency or MACS Id to find it'
            });
        }else{
            this.executeAction(submitRequest, {
                accessLevel: level,
                accountId: accId
            },(response) => {
                this.showLoader = true;
                this.buttonDisabled = true;
                this.showSuccessNotification('Success', 'Your request is submitted for Approval. once Approved you will be notified and you can access the new agency from here.');
                setTimeout(function(){
                    location. reload();
                    },1500);
            
            });
        }
    }

    submitChangeDetails(event) {
        let level = event.target.name;
        let accId = this.selectedAgencyId;
        this.executeAction(submitChangeRequest, {
            accessLevel: level,
            accountId: accId
        },(response) => {
            this.showLoader = true;
            this.buttonDisabled = true;
            this.showSuccessNotification('Success', 'Your request is submitted for Approval. once Approved you will be notified and you can access the agency from here.');
            setTimeout(function(){
                location. reload();
                },1500);
        
        });
    }

    redirectToCommunityCustomPage = (namedPage, stateJSON) => {
        if(stateJSON == undefined) {
            stateJSON = {};
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: namedPage,
            },
            state: stateJSON
        });
    }
}