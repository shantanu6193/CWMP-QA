import {
    LightningElement,
    track
} from 'lwc';
import Utility from 'c/utility';
import apexSearchFireAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFireAgency';
import apexSearchIncident from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchIncident';
import apexgetResults from '@salesforce/apex/MARS_PayingEntity_InvoiceResearch_Ctrl.getInvoicePayments';
import getInvoiceDownloadURL from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getInvoiceDownloadURL';
import getContentVersionPreview from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getContentVersionPreview';

export default class MarsPayingEntityInvoiceResearch extends Utility{
    agencyId;
    incidentId;
    startDate;
    endDate;
    showLoader = false;
    showResults = false;
    showInfoMessage = false;
    infoMessage = '';
    invoicePayments = [];
    fireagencyRequired = [];
    incidentRequired = [];
    validLookups = true;
    loadLookupDataOnLoad = false;

    contentVersions;
    invoiceRecord;
    downloadUrl;
    invoiceId;
    itemIndex;

    handleStartDateChange(event){
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event){
        this.endDate = event.detail.value;
    }

    handleSearch(){
        this.showResults = false;
        this.infoMessage = '';
        this.showInfoMessage = false;
        this.invoicePayments = [];

        if(!this.startDate && !this.endDate && !this.agencyId && !this.incidentId){
            this.infoMessage = 'Please choose either Incident or Agency or start and end dates';
            this.showInfoMessage = true;
            return;
        }

        if((!this.startDate && this.endDate) || (this.startDate && !this.endDate)){
            this.infoMessage = 'Please choose both start and end dates';
            this.showInfoMessage = true;
            return;
        }

        this.showLoader = true;
        this.executeAction(apexgetResults, {
            agencyId: this.agencyId ? this.agencyId : '',
            incidentId: this.incidentId ? this.incidentId : '',
            startDate: this.startDate ? this.startDate : null,
            endDate : this.endDate ? this.endDate : null
        }, 
        (response) => {
            this.showResults = true;
            this.invoicePayments = response;
            if(this.invoicePayments.length === 0){
                this.showInfoMessage = true;
                this.infoMessage = 'No Line Items found for the search criteria. Please choose a different Date';
            }
            this.showLoader = false;
        });
        

    }

    getInvoiceURL(event) {
        this.downloadUrl = '';
        const itemIndex = event.currentTarget.dataset.index;
        this.invoiceId = itemIndex;
        console.log(JSON.stringify(event.currentTarget.dataset));
        this.executeAction(getInvoiceDownloadURL, {
            invoiceId: this.invoiceId
        }, (result) => {
            this.contentVersions = result.contentVersions;
            if (this.contentVersions) {
                this.downloadUrl = '/sfc/servlet.shepherd/version/download/' + this.contentVersions[0].Id;
                window.open(this.downloadUrl);
            }
        });
    }
    /*get fileURL(){
        return this.downloadUrl;
    }*/
    viewPdf(event) {
        console.log('###: In viewPdf')
        const itemIndex = event.currentTarget.dataset.index;
        console.log('###: itemIndex: ' + JSON.stringify(itemIndex))
        this.invoiceId = itemIndex;
        this.executeAction(getContentVersionPreview, {
            previewId: this.invoiceId
        }, (result) => {
            console.log('###: result: ' + JSON.stringify(result));
            this.navigateToFilePreview(result);
        });
    }


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
           this.agencyId = '';
        }
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.agencyId = response.detail.selectedItem.id;
        }
    }


      /*
    * Searches Incidents for MARS on Agency Incident Section
    */
      handleIncidentSearch(event) {
        apexSearchIncident(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Incident field on Agency Incidentsection
    */
    handleIncidentChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.incidentId = response.detail.selectedItem.id;
        }
    }




}