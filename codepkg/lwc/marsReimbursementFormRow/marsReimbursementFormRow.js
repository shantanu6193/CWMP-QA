import { LightningElement, api } from 'lwc';
import Utility from 'c/utility';
export default class MarsReimbursementFormRow extends Utility {
    @api index;
    loadLookupDataOnLoad = false;
    loadagencyLookupDataOnLoad = false;
    femacodeRequired = [];//errors={femacodeRequired}
    FEMACodeSelection = [];
    enterRevisedRate = false;

    initData() {
        this.recordLocal.Meal__c = 0.00;
        this.recordLocal.Lodging__c = 0.00;
        this.recordLocal.MISC__c = 0.00;
    }

    handleDateChange(event) {

    }
    /*
    * Add empty row
    */
    addNewRow(event) {
        event.preventDefault();
        let item = {};
        const addEvent = new CustomEvent('added', { detail: { recordData: item } });
        this.dispatchEvent(addEvent);
    }

    /*
    * Delete selected row
    */
    removeRow(event) {
        event.preventDefault();
        const deleteEvent = new CustomEvent('deleted', { detail: {index: this.index} });
        this.dispatchEvent(deleteEvent);
    }

    onInputFilled(event) {
        this.fieldChanged(event);
        if (this.recordLocal.Meal__c != undefined && this.recordLocal.Lodging__c != undefined && this.recordLocal.MISC__c != undefined )
        this.recordLocal.Amount__c = Number(this.recordLocal.Meal__c) + Number(this.recordLocal.Lodging__c) + Number(this.recordLocal.MISC__c);
        const addEvent = new CustomEvent('calculatetotal');
        this.dispatchEvent(addEvent);
    }
}