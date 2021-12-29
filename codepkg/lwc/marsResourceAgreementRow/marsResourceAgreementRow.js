import {LightningElement,api} from 'lwc';
import Utility from 'c/utility';
import apexSearchCFAA_Line_Items from "@salesforce/apex/MARS_ResourceAgreementCtrl.apexSearchCFAA_Line_Items";
export default class MarsResourceAgreementRow extends Utility {

    @api index;
    loadDataOnLookup = true;
    classificationTitleRequired = [];
    classificationTitleSelection = [];
    isMultiEntry = false;
    showField = true;
    overtimeAllow = true;
    @api isEditable;
    @api fulfilmentOptions;
    @api allRecords;
    errors;
    error;
    recordId;
    //isP2PRequired = false;
    agreementRestrictOTOptionsImp = ["Chief", "Deputy Chief", "Division Chief", "Assistant Chief"];
    agreementRestrictOTOptions = ["Battalion Chief", "Co. Officer/Capt./Lt.", "App. Officer/Eng", "Firefighter/FF-PMedic"];
    /*
     * Set value to the component if product is present
     */
    initData() {
        let urlId = this.getURLParameter("id");
        this.recordId = urlId;
        console.log('inside Resource Agreement row');
        if (this.recordLocal != undefined && this.recordLocal.Personnel_Role__c != undefined) {
            this.classificationTitleSelection = [{
                id: this.recordLocal.Personnel_Role__c,
                // sObjectType: 'CFAA_Line_Items__c',
                icon: 'standard:user_role',
                title: this.recordLocal.Personnel_Role__c,
                subtitle: ''
            }];
        }
    }

    /*
     * Add empty row
     */
    addNewRow(event) {
        //this.recordLocal.Product_Distribution_Plans__r.push(this.recordLocal);
        event.preventDefault();
        let item = {};
        const addEvent = new CustomEvent('added', {
            detail: {
                recordData: item
            }
        });
        this.dispatchEvent(addEvent);
    }

    /*
     * Delete selected row
     */
    deleteRow(event) {
        event.preventDefault();
        const deleteEvent = new CustomEvent('deleted', {
            detail: {
                index: this.index
            }
        });
        this.dispatchEvent(deleteEvent);
    }

    @api
    validateCustomInput() {
        let isSuccess = true;
        this.classificationTitleRequired = [];
        if (this.recordLocal.Name == undefined || this.recordLocal.Name == '') {
            this.classificationTitleRequired.push({
                message: 'Complete this field.'
            });
            isSuccess = false;
        } else {
            this.classificationTitleRequired = [];
            isSuccess = true;
        }
        return isSuccess;
    }

    /*
     * Searches CFAA
     */
    handleItemSearch(event) {
        apexSearchCFAA_Line_Items({
                "searchTerm": event.detail.searchTerm,
                "agencyId": this.recordId
            })
            .then((results) => {
                console.log('results==>', JSON.stringify(results));
                this.template.querySelector('[data-lookup="Personnel_Role__c"]').setSearchResults(results);
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    /*
     * Lookup selection for CFAA
     */
    handleItemChange(response) {
        if (response.detail != null && response.detail.selectedItem.id != undefined) {
            if (response.detail.selectedItem.sObject.Personnel_Role__c)
                this.recordLocal.Name = response.detail.selectedItem.sObject.Personnel_Role__c;
            else if (response.detail.selectedItem.sObject.Classification_Title__c)
                this.recordLocal.Name = response.detail.selectedItem.sObject.Classification_Title__c;
            let searchName = this.recordLocal.Name;
            let containsNonOTVal = this.agreementRestrictOTOptionsImp.some(function (arrVal) {
                return searchName === arrVal;
            });
            this.overtimeAllow = !containsNonOTVal;
        } else {
            this.recordLocal.Name = '';
            this.overtimeAllow = true;
        }
        this.recordLocal.OT__c = this.overtimeAllow;
        this.recordLocal.PTP__c = false;
        /*if(containsNonOTVal) {
            this.isP2PRequired = false;
        } else {
            this.isP2PRequired = true;
        }*/
    }
    handleClicked(event) {
        this.fieldChecked(event);
        let searchName = this.recordLocal.Name;
        let containsNonOTVal = this.agreementRestrictOTOptions.some(function (arrVal) {
            return searchName === arrVal;
        });
        if (containsNonOTVal && this.recordLocal.OT__c == true) {
            this.recordLocal.OT__c = false;
            this.showErrorNotification('You cannot select OT for this resource type combination');
            return;
        }
    }
    get disableOTCheck() {
        if (this.overtimeAllow) return true;
        else return false;
    }

}