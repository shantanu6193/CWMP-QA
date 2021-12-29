import {
    LightningElement,
    wire,
    api,
    track
  } from 'lwc';
import Utility from 'c/utility';

import apexSearchFireAgency from '@salesforce/apex/CommunityRegistrationCtrl.apexSearchFireAgency';
import apexgetSalarySurvey from '@salesforce/apex/MARS_FireAgency_Research_Ctrl.getSalarySurveyItems';
import apexgetNonSuppressionList from '@salesforce/apex/MARS_FireAgency_Research_Ctrl.getNonsupressionItems';
import apexgetSpecialEquipmentList from '@salesforce/apex/MARS_FireAgency_Research_Ctrl.getSpecialEquipmentItems';
import apexgetAgreements from '@salesforce/apex/MARS_FireAgency_Research_Ctrl.getAgreementLineItems';
import apexgetAdminRates from '@salesforce/apex/MARS_FireAgency_Research_Ctrl.getAdminLineItems';



export default class MarsFireAgencyResearch extends Utility {

    @track agencyId;
    dateInputValue;
    selectedOption;
    showLoader = false;
    showSalarySurvey = false;
    showNonSuppression = false;
    showSpecialEquipment = false;
    showAgreements = false;
    showAdminRates = false;
    signatureURL = '';

    salarySurveyRecord      = {};    
    adminRateRecord         = {};
    nonSuppPersonnelRecord  = {};
    specialEquipmentRecord  = {};
   
    contentversions         = [];
    salarysurveylineItems   = [];
    nonSuppLineItemRecords  = [];
    splEquipLineItemRecords = [];
    agreements = [];
    adminRates = [];

    showInfoMessage = false;
    infoMessage = '';
    fireagencyRequired = [];
    validLookups = true;
    loadLookupDataOnLoad = false;
    recordId;
    showPrint = false;
    visualForcePage;
    handleDateChange(event){
        this.dateInputValue = event.detail.value;
        this.clearSearchData();
    }

    handleOptionChange(event){
        this.selectedOption = event.detail.value;
        this.clearSearchData(); 
    }

    handleSearch(){
        this.clearSearchData();
        if(!this.agencyId || !this.dateInputValue  || !this.selectedOption){
            this.showInfoMessage = true;
            this.infoMessage = 'Please select Agency, Date and an option to display the result';
            return;
        }

        //Salary Survey
        if(this.selectedOption === 'Salary Survey'){
            this.showLoader = true;
            this.executeAction(apexgetSalarySurvey, {
                accountId: this.agencyId,
                dayOfRecord: this.dateInputValue
            }, 
            (response) => {
                this.showSalarySurvey = true;
                this.salarysurveylineItems = response;
                if(this.salarysurveylineItems.length === 0){
                    this.showInfoMessage = true;
                    this.infoMessage = 'No Line Items found for the search criteria. Please choose a different Date';
                }else{
                    this.salarySurveyRecord.Start_Date__c = this.salarysurveylineItems[0].Agency_Salary_Survey__r.Start_Date__c;
                    this.salarySurveyRecord.Status__c = this.salarysurveylineItems[0].Agency_Salary_Survey__r.Status__c;
                    this.salarySurveyRecord.Reject_Reason__c = this.salarysurveylineItems[0].Agency_Salary_Survey__r.Reject_Reason__c;
                    this.signatureURL = this.salarysurveylineItems[0].Name;
                    this.salarySurveyRecord.Name = this.salarysurveylineItems[0].Agency_Salary_Survey__r.CreatedBy.FirstName + ' ' +
                    this.salarysurveylineItems[0].Agency_Salary_Survey__r.CreatedBy.LastName;
                    this.recordId = this.salarysurveylineItems[0].Agency_Salary_Survey__c;
                    this.showPrint = true;
                    this.visualForcePage = 'MARS_AgencySalarySurveyPDF';
                }
                this.showLoader = false;
            });
        }

        //Non-Suppression List
        if(this.selectedOption === 'Non-Suppression Personnel'){
            this.showLoader = true;
            this.executeAction(apexgetNonSuppressionList, {
                accountId: this.agencyId,
                dayOfRecord: this.dateInputValue
            }, 
            (response) => {
                this.showNonSuppression = true;
                this.nonSuppLineItemRecords = response;
                if(this.nonSuppLineItemRecords.length === 0){
                    this.showInfoMessage = true;
                    this.infoMessage = 'No Line Items found for the search criteria. Please choose a different Date';
                }else{
                    this.nonSuppPersonnelRecord.Start_Date__c = this.nonSuppLineItemRecords[0].Agency_Non_Suppression_Personnel__r.Start_Date__c;
                    this.nonSuppPersonnelRecord.Approval_Status__c = this.nonSuppLineItemRecords[0].Agency_Non_Suppression_Personnel__r.Approval_Status__c;
                    this.nonSuppPersonnelRecord.Reject_Reason__c = this.nonSuppLineItemRecords[0].Agency_Non_Suppression_Personnel__r.Reject_Reason__c;                 
                    this.signatureURL = this.nonSuppLineItemRecords[0].Name;        
                    this.nonSuppPersonnelRecord.Name = this.nonSuppLineItemRecords[0].Agency_Non_Suppression_Personnel__r.CreatedBy.FirstName + ' ' +
                    this.nonSuppLineItemRecords[0].Agency_Non_Suppression_Personnel__r.CreatedBy.LastName; 
                    this.recordId = this.nonSuppLineItemRecords[0].Agency_Non_Suppression_Personnel__c;
                    this.showPrint = true;     
                    this.visualForcePage =  'MARS_NonSuppressionPDF';    
                }
                this.showLoader = false;
            });
        }

        //Special Equipment
        if(this.selectedOption === 'Special Equipment'){
            this.showLoader = true;
            this.executeAction(apexgetSpecialEquipmentList, {
                accountId: this.agencyId,
                dayOfRecord: this.dateInputValue
            }, 
            (response) => {
                this.showSpecialEquipment = true;
                this.splEquipLineItemRecords = response;
                if(this.splEquipLineItemRecords.length === 0){
                    this.showInfoMessage = true;
                    this.infoMessage = 'No Line Items found for the search criteria. Please choose a different Date';
                }else{
                    this.specialEquipmentRecord.Start_Date__c = this.splEquipLineItemRecords[0].Agency_Special_Equipment__r.Start_Date__c;
                    this.specialEquipmentRecord.Approval_Status__c = this.splEquipLineItemRecords[0].Agency_Special_Equipment__r.Approval_Status__c;
                    this.specialEquipmentRecord.Reject_Reason__c = this.splEquipLineItemRecords[0].Agency_Special_Equipment__r.Reject_Reason__c;
                    this.signatureURL = this.splEquipLineItemRecords[0].Name;        
                    this.specialEquipmentRecord.Name = this.splEquipLineItemRecords[0].Agency_Special_Equipment__r.CreatedBy.FirstName + ' ' +
                    this.splEquipLineItemRecords[0].Agency_Special_Equipment__r.CreatedBy.LastName; 
                    this.recordId = this.splEquipLineItemRecords[0].Agency_Special_Equipment__c;
                    this.showPrint = true; 
                    this.visualForcePage='MARS_SpecialEquipment_PDF';

                }
                this.showLoader = false;
            });
        }

        //Agreements
        if(this.selectedOption === 'Agreements'){
            this.showLoader = true;
            this.executeAction(apexgetAgreements, {
                accountId: this.agencyId,
                dayOfRecord: this.dateInputValue
            }, 
            (response) => {            
                this.showAgreements = true;
                this.agreements = response.agreementLines;
                this.contentversions = response.contentVersions;
                if(this.agreements.length === 0){                    
                    this.showInfoMessage = true;
                    this.infoMessage = 'No Line Items found for the search criteria. Please choose a different Date';
                }else{  
                    /*if(this.agreements[0].Agency_Rate_Agreement__r.Approval_Status__c === 'Rejected') {
                        this.visualForcePage ='MARS_DeniedAgreementPDF'; 
                    } else {
                        this.visualForcePage ='MARS_ApprovedAgreementPDF'; 
                    } */                 
                    this.visualForcePage ='MARS_ApprovedAgreementPDF';                        
                    this.recordId = this.agreements[0].Agency_Rate_Agreement__c;
                    this.showPrint = true;                    
                }
                this.showLoader = false;
            });
        }

        //Admin Rates
        if(this.selectedOption === 'Admin Rates'){
            this.showLoader = true;
            this.executeAction(apexgetAdminRates, {
                accountId: this.agencyId,
                dayOfRecord: this.dateInputValue
            }, 
            (response) => {
                this.showAdminRates = true;
                this.adminRates = response;
                if(this.adminRates.length === 0){
                    this.showInfoMessage = true;
                    this.infoMessage = 'No Line Items found for the search criteria. Please choose a different Date';
                }else{
                    this.adminRateRecord.Total_Indirect_Amount__c =  this.adminRates[0].Agency_Administrative_Rates__r.Total_Indirect_Amount__c;
                    this.adminRateRecord.Total_Direct_Amount__c =  this.adminRates[0].Agency_Administrative_Rates__r.Total_Direct_Amount__c;
                    this.adminRateRecord.Administrative_Total_Indirect_Direct__c =  this.adminRates[0].Agency_Administrative_Rates__r.Administrative_Total_Indirect_Direct__c;
                    this.adminRateRecord.Administrative_Rate_Indirect_Cost_Direct__c =  this.adminRates[0].Agency_Administrative_Rates__r.Administrative_Rate_Indirect_Cost_Direct__c;
                    this.adminRateRecord.Start_Date__c =  this.adminRates[0].Agency_Administrative_Rates__r.Start_Date__c;
                    this.adminRateRecord.Approval_Status__c =  this.adminRates[0].Agency_Administrative_Rates__r.Approval_Status__c;
                    this.adminRateRecord.Reject_Reason__c =  this.adminRates[0].Agency_Administrative_Rates__r.Reject_Reason__c;
                    this.signatureURL = this.adminRates[0].Name;        
                    this.adminRateRecord.Name = this.adminRates[0].Agency_Administrative_Rates__r.CreatedBy.FirstName + ' ' +
                    this.adminRates[0].Agency_Administrative_Rates__r.CreatedBy.LastName; 
                    this.recordId = this.adminRates[0].Agency_Administrative_Rates__c;
                    this.showPrint = true;   
                    this.visualForcePage='MARS_AdministrativeRate_PDF';   

                }
                this.showLoader = false;
            });
        }

    }

    get options() {
        return [
            { label: 'Salary Survey', value: 'Salary Survey' },
            { label: 'Attachment A. Non-Suppression Personnel', value: 'Non-Suppression Personnel' },
            { label: 'Special Equipment', value: 'Special Equipment' },
            { label: 'Agreements (MOU/MOA/GBR)', value: 'Agreements' },
            { label: 'Administrative Rate', value: 'Admin Rates' },
        ];
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
        this.clearSearchData();
    }
    /*
    * Print PDF 
    */
    handlePrint(){
        window.open('/mars/apex/'+this.visualForcePage+'?id=' + this.recordId);
    }
    clearSearchData(){
        this.showSalarySurvey           = false;
        this.showNonSuppression         = false;
        this.showSpecialEquipment       = false;
        this.showAgreements             = false;
        this.showAdminRates             = false;
        this.showPrint                  = false;
                           
        this.salarySurveyRecord         = {};
        this.nonSuppPersonnelRecord     = {};
        this.specialEquipmentRecord     = {};
        this.adminRateRecord            = {};
        this.contentversions            = {};
        this.salarysurveylineItems      = [];
        this.nonSuppLineItemRecords     = [];
        this.splEquipLineItemRecords    = [];
        this.agreements                 = [];
        this.adminRates                 = [];

        this.showInfoMessage            = false;
        this.infoMessage                = '';
        this.signatureURL               = '';
        this.visualForcePage            = '';
    }
}