/**
 * Created by Pankaj on 2021-05-27.
 */

import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getF42Entries from '@salesforce/apex/MarsGenerateInvoiceCtrl.getF42Entries';
import generateInvoice from '@salesforce/apex/MarsGenerateInvoiceCtrl.generateInvoice';
import apexSearchIncident from '@salesforce/apex/MarsGenerateInvoiceCtrl.apexSearchIncident';
import apexSearchAgency from '@salesforce/apex/MarsGenerateInvoiceCtrl.apexSearchAgency';
import Utility from 'c/utility';

export default class MarsGenerateInvoice extends Utility {
    //used to store lookup fields
    selectedSRRecordId;
    selectedIncidentRecordId;
    selectedFundingRuleId;
    //lookup related variables
    isMultiEntry = false;
    loadDataOnLookup = false;
    showEstimate = false;
    @track selectedF42IdLst =[];
    @track selectedF42Details =[];
    @track selectedExpClaimIdList =[];
    @track selectedExpClaimDetails =[];
    invoiceList;
    //Data Table Fields
    f42Data;
    fundingData;
    expenseClaimData;
    @track preSelectedRows=[];

    /*
    * Searches Incidents with Users have project access
    */
    handleAccountSearch(event) {
        console.log('event------------',event.detail.searchTerm);
        apexSearchAgency({ searchTerm: event.detail.searchTerm})
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="Account"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    handleSRChange(response) {
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedSRRecordId = response.detail.selectedItem.id;
        } else {
            this.selectedSRRecordId = undefined;
        }
        this.f42Data = undefined;
        this.fundingData = undefined;
        this.expenseClaimData = undefined;
    }

    /*
    * Searches Incidents with Users have project access
    */
    handleIncidentSearch(event) {
        console.log('event------------',event.detail.searchTerm);
        apexSearchIncident({ searchTerm: event.detail.searchTerm})
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    handleIncidentChange(response) {
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedIncidentRecordId = response.detail.selectedItem.id;
        } else {
            this.selectedIncidentRecordId = undefined;
        }
    }

    handleSearch(event) {
        if(!this.selectedIncidentRecordId) {
            this.showErrorNotification('Error', 'Please select Incident');
            return;
        }

        let paramMap = {};
        paramMap['selectedSRRecordId'] = this.selectedSRRecordId;
        paramMap['selectedIncidentRecordId'] = this.selectedIncidentRecordId;
        this.executeAction(getF42Entries, paramMap, (response) => {
            let f42data = [];
            let fundingData = [];
            response.getF42Entries.forEach(element => {
                let elt = {};
                elt.Id = element.Id;
                elt.Name = element.Name;
                elt.Strike_Team = element.Strike_Team__c ;
                elt.Status =  element.Status__c ;
                elt.CreatedByName =  element.CreatedBy.Name;
                elt.AccountName =  element.Account__r.Name;
                elt.AccountId = element.Account__c;
                f42data.push(elt);
            });
            this.f42Data = f42data;

            let expenseClaimData = [];
            response.getExpenseClaimData.forEach(element => {
                let elt = {};
                elt.Id = element.Id;
                elt.Name = element.Name;
                elt.Strike_Team = element.Strike_Team__c ;
                elt.Status =  element.Status__c ;
                elt.CreatedByName =  element.CreatedBy.Name;
                elt.AccountName =  element.Account__r.Name;
                elt.AccountId =  element.Account__c;
                expenseClaimData.push(elt);
            });
            this.expenseClaimData = expenseClaimData;

            response.fundingRules.forEach(element => {
                let elt = {};
                elt.Id = element.Id;
                elt.Name = element.Name;
                elt.Rule_Type = element.Rule_Type__c ;
                if(element.Funding_Source_1__c != null)
                    elt.Funding_Source_1 =  element.Funding_Source_1__r.Name;
                 else 
                    elt.Funding_Source_1 =  '';
    
                elt.Funding_Source_1_Percent =  element.Funding_Source_1_Percent__c;
                if(element.Funding_Source_2__c != null)
                elt.Funding_Source_2 =  element.Funding_Source_2__r.Name;
                else
                    elt.Funding_Source_2 =  '';
                elt.Funding_Source_2_Percent =  element.Funding_Source_2_Percent__c;
                if(element.Funding_Source_3__c != null)
                    elt.Funding_Source_3 =  element.Funding_Source_3__r.Name;
                else
                    elt.Funding_Source_3 =  '';
                elt.Funding_Source_3_Percent =  element.Funding_Source_3_Percent__c;
                if(element.Funding_Source_4__c != null)
                    elt.Funding_Source_4 =  element.Funding_Source_4__r.Name;
                else
                    elt.Funding_Source_4 =  '';
                elt.Funding_Source_4_Percent =  element.Funding_Source_4_Percent__c;
                if(element.Funding_Source_5__c != null)
                elt.Funding_Source_5 =  element.Funding_Source_5__r.Name;
                else
                    elt.Funding_Source_5 =  '';
                elt.Funding_Source_5_Percent =  element.Funding_Source_5_Percent__c;
                fundingData.push(elt);
                });
            this.fundingData = fundingData;
        });
    }

    handleClear(event) {
        this.refreshScreen();
    }

    get columns() {
        return [
            {
                label: 'F42 Name',
                fieldName: 'Name'
            },
            {
                label: 'Strike Team',
                fieldName: 'Strike_Team'
            },
            {
                label: 'Status',
                fieldName: 'Status'
            },
            {
                label:'Created By',
                fieldName:'CreatedByName'
            } ,
            {
                label:'Agency',
                fieldName:'AccountName'
            }
       ];
    }

    getSelectedF42s(event){
        const selectedRows = event.detail.selectedRows;
        this.selectedF42IdLst = [];
        this.selectedF42Details = [];
        console.log('-----seleted project ---------',selectedRows);
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedF42IdLst.push(selectedRows[i].Id);
            this.selectedF42Details.push(selectedRows[i]);
            //if one small project select then all small project also select
            /*if(selectedRows[i].Total_Project_Award__c < 1000){
                this.selectAllSmallProject();
            }*/
        }
        this.selectedF42IdLst = this.getUniqueList(this.selectedF42IdLst);
    }

    getSelectedExpenseClaim(event){
        const selectedRows = event.detail.selectedRows;
        this.selectedExpClaimIdList = [];
        this.selectedExpClaimDetails = [];
        console.log('-----seleted Expense Claim ---------',selectedRows);
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedExpClaimIdList.push(selectedRows[i].Id);
            this.selectedExpClaimDetails.push(selectedRows[i]);

        }
        this.selectedExpClaimIdList = this.getUniqueList(this.selectedExpClaimIdList);
    }
    get isButtonDisabled() {
        if(this.selectedIncidentRecordId && this.selectedFundingRuleId && ((
            this.selectedF42IdLst && this.selectedF42IdLst.length > 0) ||
            (this.selectedExpClaimIdList && this.selectedExpClaimIdList.length > 0))) {
                        return false;
        }
        return true;
    }

    handleSubmit(event) {
        console.log("******************* SUBMIT ACTIONS ***************************")
        if(this.selectedF42Details.length == 0 && this.selectedExpClaimDetails.length == 0) {
            return;
        } else if (this.selectedF42Details.length > 0 && this.selectedExpClaimDetails.length > 0) {
            this.showErrorNotification('Error', 'Please select either F-42s or Expense Claim');
            return;
        }
        let paramsByAccount = {};
        for (let i = 0; i < this.selectedF42Details.length; i++) {
            let selectedF42 = this.selectedF42Details[i];
            if(paramsByAccount[selectedF42.AccountId]) {
                paramsByAccount[selectedF42.AccountId].f42s.push(selectedF42.Id);
                if(paramsByAccount[selectedF42.AccountId].f42s.length >= 13) {
                    this.showErrorNotification('Error', 'Please select up to 12 F-42s per Agency');
                    return;
                }
            } else {
                let paramMap = {};
                console.log("*** generateInvoice()");
                paramMap['f42s'] = [];
                paramMap.f42s.push(selectedF42.Id);
                paramMap['agencyId'] = selectedF42.AccountId;
                paramMap['incidentNumber'] = this.selectedIncidentRecordId;
                paramMap['fundingRuleId'] = this.selectedFundingRuleId;
                paramMap['expenseClaims'] = [];
                paramsByAccount[selectedF42.AccountId] = paramMap;
            }
        }

        for (let i = 0; i < this.selectedExpClaimDetails.length; i++) {
            let selectedExpClaim = this.selectedExpClaimDetails[i];
            if(paramsByAccount[selectedExpClaim.AccountId]) {
                paramsByAccount[selectedExpClaim.AccountId].expenseClaims.push(selectedExpClaim.Id);
                if(paramsByAccount[selectedExpClaim.AccountId].expenseClaims.length >= 13) {
                    this.showErrorNotification('Error', 'Please select up to 12 Expense Claim per Agency');
                    return;
                }
            } else {
                let paramMap = {};
                console.log("*** generateInvoice Exp");
                paramMap['f42s'] = [];
                paramMap['agencyId'] = selectedExpClaim.AccountId;
                paramMap['incidentNumber'] = this.selectedIncidentRecordId;
                paramMap['fundingRuleId'] = this.selectedFundingRuleId;
                paramMap['expenseClaims'] = [];
                paramMap.expenseClaims.push(selectedExpClaim.Id);
                paramsByAccount[selectedExpClaim.AccountId] = paramMap;
            }
        }

        let invoicesMap = Object.keys(paramsByAccount).map(key=> ({ key: key, ...paramsByAccount[key] }));
        this.invoiceList = [];
        this.generateIndividualInvoice(invoicesMap);
    }

    generateIndividualInvoice(paramMapList) {
        let paramMap = paramMapList[0];
        this.executeAction(generateInvoice, paramMap, (response) => {
           this.invoiceList = this.invoiceList.concat(response);
           //after last item show success message and redirect to invoice details screen
           if(paramMapList.length == 1) {
               //navigate to Invoice detail page
               this.showSuccessNotification('Success', this.invoiceList.length +' Invoice(s) are generated successfully!');
               console.log('Ids==',JSON.stringify(this.invoiceList));
               //this.navigateRecordViewPage(response);
               for(let i=0;i<this.invoiceList.length;i++){
                   this.navigateRecordViewPage(this.invoiceList[i]);
               }
               this.refreshScreen();
           } else {
                paramMapList = paramMapList.splice(1, paramMapList.length-1);
                this.generateIndividualInvoice(paramMapList);
           }

        });
    }

    getUniqueList(arrayList) {
        let values = [];
        for(let i = 0; i < arrayList.length; i++){
            if(values.includes(arrayList[i]) == false) {
                values.push(arrayList[i]);
            }
        }
        return values;
    }

    handleFundingRule(event){
        console.log('Fund value=',JSON.stringify(event.target.value));
        this.selectedFundingRuleId = event.target.value;
    }
    //****************************************
    get ExpenseClaimcolumns() {
        return [
            {
                label: 'Expense Claim Name',
                fieldName: 'Name'
            },
            {
                label: 'Strike Team',
                fieldName: 'Strike_Team'
            },
            {
                label: 'Status',
                fieldName: 'Status'
            },
            {
                label:'Created By',
                fieldName:'CreatedByName'
            } ,
            {
                label:'Agency',
                fieldName:'AccountName'
            }
       ];
    }
}