import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import apexSearchFemaCode from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchFemaCode';

export default class MarsSpecialEquipLine extends Utility {
@api index;
loadLookupDataOnLoad = false;
loadagencyLookupDataOnLoad = false;
femacodeRequired = [];//errors={femacodeRequired}
FEMACodeSelection = [];
enterRevisedRate = false;
    /*
    * Set value to the component if FEMA is present
    */
    initData() {
        if(this.recordLocal != undefined && this.recordLocal.FEMA_CODE__c != undefined) {
            this.FEMACodeSelection = [
                {
                    sObjectType: 'FEMA_Code_LineItem__c',
                    icon: 'utility:lightning_extension',
                    title: this.recordLocal.FEMA_CODE__c,
                    subtitle: ''
                }
            ];
            this.enterRevisedRate = true;
        } 
    }

    /*
    * Searches for FEMA Codes
    */
   handleFemaCodeSearch(event) {
        apexSearchFemaCode(event.detail)
            .then((results) => {
                this.template.querySelector('[data-lookup="FEMA_CODE__c"]').setSearchResults(results);
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                this.errors = [error];
            });
    }

    /* 
    * Lookup selection for agency FEMA CODE
    */
   handleFemaCodeChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Special_Equipment_Type__c = response.detail.selectedItem.sObject.Equipment__c;
            this.recordLocal.FEMA_CODE__c = response.detail.selectedItem.title;
            this.recordLocal.Revised_Rate__c=response.detail.selectedItem.sObject.Current_Rate__c;
            this.enterRevisedRate = true;
        }else {
            this.recordLocal.Special_Equipment_Type__c = '';
            this.recordLocal.FEMA_CODE__c = '';
            this.recordLocal.Revised_Rate__c = '';
            this.enterRevisedRate = false;
        }
    }
    /*
    * Add empty row
    */
   addNewRow(event){
        event.preventDefault();
        let item = {};
        const addEvent = new CustomEvent('added', { detail: {recordData:item}});
        this.dispatchEvent(addEvent);
    }

    /*
    * Delete selected row
    */
    removeRow(event){
        event.preventDefault();
        const deleteEvent = new CustomEvent('deleted', { detail: {index:this.index }});
        this.dispatchEvent(deleteEvent);
    }

    /*@api
    validateCustomInput() {
        let isSuccess = true;
        this.femacodeRequired = [];
        if(this.recordLocal.FEMA_CODE__c == undefined || this.recordLocal.FEMA_CODE__c == '') {
            this.femacodeRequired.push({ message: 'Complete this field.' });
            isSuccess = false;
        } else {
            this.femacodeRequired =[];
            isSuccess = true;
        }
        return isSuccess;
   }*/
   get disableRevisedRate(){
    if(this.enterRevisedRate) return true;
    else return false;
   }
}