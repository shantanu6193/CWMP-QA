import { LightningElement, api } from 'lwc';
import apexSearchWarehouse from '@salesforce/apex/PHOS_WarehouseSearchCtrl.apexSearchWarehouse';
import Utility from 'c/utility';
export default class PhosWarehouseSKUSearch extends Utility {

    @api selectedWarehouse;
    @api selectedWarehouseSKU;
    @api selectedProductId;

    loadDataOnLookup = false;
    warehouseRequired = [];
    warehouseSelection = [];
    isMultiEntry = false;

    /*
    * Initially selects a warehouse if present
    */
    initData() {
        console.log('selectedWarehouse---',this.selectedWarehouse);
        if(this.recordLocal.Warehouse__c == undefined) {
            this.recordLocal.Warehouse__c = '';
        }
        if(this.selectedWarehouseSKU) {
             this.warehouseSelection = [
            {
                id: this.selectedWarehouseSKU,
                sObjectType: 'Inventory__c',
                icon: 'standard:product',
                title: this.selectedWarehouseSKU,
                subtitle: ''
            }
            ];
        }
    }

    /*
    * Null WarehouseSKU field when Warehouse__c field is empty
    * Null Warehouse__c field when Warehouse__c is empty
    * Searches warehouses
    */
    @api
    handleWarehouseSearch(event) {
        if(event == undefined) {
            this.warehouseSelection = [];
            this.recordLocal.Warehouse__c = '';
            const warehouseData = { Id : '', WarehouseSKU :'',RemainingQuantity :'' };
            const warehouseChangeEvent = new CustomEvent("warehouseChange", {detail: { warehouseData }});
            this.template.querySelector('[data-lookup="Warehouse__c"]').setSearchResults([]);
            // Fire the custom event
            this.dispatchEvent(warehouseChangeEvent);
        }
        else {
        this.recordLocal.Warehouse__c = event.detail.searchTerm;
        let warehouseTerm = event.detail.searchTerm;
        console.log('warehouseTerm---',event.detail.searchTerm);
        const warehouseData = { Id : '', WarehouseSKU : warehouseTerm, RemainingQuantity :'' };
        const warehouseChangeEvent = new CustomEvent("warehouseChange", {detail: { warehouseData }});
        // Fire the custom event
        this.dispatchEvent(warehouseChangeEvent);
         console.log('searchTerm---',JSON.stringify(event.detail));
         console.log('searchTerm---',this.selectedWarehouse);
        apexSearchWarehouse({ 'selectedWarehouse' : this.selectedWarehouse, 'searchTerm' : event.detail.searchTerm })
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="Warehouse__c"]').setSearchResults(results);
            
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }
    }

    /*
    * Lookup selection for Warehouse__c
    * Passes selected warehouse data to parent component through event
    */
    handleWarehouseChange(response) {
    console.log('response----',response);
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.recordLocal.Warehouse__c = response.detail.selectedItem.id;
            const warehouse = response.detail.selectedItem;
            const warehouseData = { Id : warehouse.id, WarehouseSKU : warehouse.sObject.SKU_Id__c, RemainingQuantity : warehouse.sObject.Remaining_Inventory__c };
            const warehouseChangeEvent = new CustomEvent("warehouseChange", {detail: { warehouseData }});
            // Fire the custom event
            this.dispatchEvent(warehouseChangeEvent);
        } else{
            this.recordLocal.Warehouse__c = '';
            const warehouseData = { Id : '', WarehouseSKU :'',RemainingQuantity :'' };
            const warehouseChangeEvent = new CustomEvent("warehouseChange", {detail: { warehouseData }});
            // Fire the custom event
            this.dispatchEvent(warehouseChangeEvent);
        }
    }
}