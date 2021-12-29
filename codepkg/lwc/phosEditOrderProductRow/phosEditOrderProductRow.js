import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import apexSearchProduct from '@salesforce/apex/PHOS_ProductSearchCtrl.apexSearchProduct';
export default class PhosEditOrderProductRow extends Utility {
    @api index;
    loadDataOnLookup = true; 
    productRequired = [];
    productSelection = [];
    isMultiEntry = false;
    showField = true;
    @api isQuantityEditable;
    @api fulfilmentOptions;
    /*
    * Set value to the component if product is present
    */
    initData() {
        if(this.recordLocal != undefined && this.recordLocal.Product__c != undefined) {
            this.productSelection = [
                {
                    id: this.recordLocal.Product__c,
                    sObjectType: 'Product2',
                    icon: 'standard:product',
                    title: this.recordLocal.Product_Name__c,
                    subtitle: ''
                }
            ];
        } 
    }

    /*
    * Add empty row
    */
   addNewRow(event){
        //this.recordLocal.Product_Distribution_Plans__r.push(this.recordLocal);
        event.preventDefault();
        let item = {};
        const addEvent = new CustomEvent('added', { detail: {recordData:item}});
        this.dispatchEvent(addEvent);
    }

    /*
    * Delete selected row
    */
   deleteRow(event){
        event.preventDefault();
        const deleteEvent = new CustomEvent('deleted', { detail: {index:this.index }});
        this.dispatchEvent(deleteEvent);
   }

    /*setQuantityBackOrder(event){
        console.log('order Qty----->',event.target.value );
        this.recordLocal.Quantity__c = event.target.value;
        //feedback from eric. Qty can be zero and filled qty can be more than zero
        if(this.recordLocal.Quantity__c > 0){
            let val = this.recordLocal.Quantity__c - this.recordLocal.Quantity_Filled__c;
            val = (val <= 0 ? 0 : val);
            this.recordLocal.Quantity_Back_Ordered__c = val;
            console.log('back order Qty----->',this.recordLocal.Quantity_Back_Ordered__c);
        }
    }*/
    @api
    validateCustomInput() {
        let isSuccess = true;
        this.productRequired = [];
        console.log('this.recordLocal.Product__c**',this.recordLocal.Product__c);
        if(this.recordLocal.Product__c == undefined || this.recordLocal.Product__c == '') {
            this.productRequired.push({ message: 'Complete this field.' });
            isSuccess = false;
        } else {
            this.productRequired =[];
            isSuccess = true;
        }
        console.log('isSuccess**',isSuccess);
        return isSuccess;
   }

    /*
    * Searches product
    */
    handleProductSearch(event) {
        apexSearchProduct(event.detail)
        .then((results) => {
           console.log('results----', results);
           this.template.querySelector('[data-lookup="Product__c"]').setSearchResults(results);
        })
        .catch((error) => {
           this.error('Lookup Error', 'An error occured while searching with the lookup field.');
           console.error('Lookup error', JSON.stringify(error));
           this.errors = [error];
        });
    }

    /*
    * Lookup selection for product
    */
    handleProductChange(response) {
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
           this.recordLocal.Product__c = response.detail.selectedItem.id;
           this.recordLocal.Product_Name__c = response.detail.selectedItem.sObject.Name;
           this.recordLocal.Product_Family__c = response.detail.selectedItem.sObject.Family;
           this.recordLocal.Minimum_Order_Quantity__c = response.detail.selectedItem.sObject.Minimum_Order_Quantity__c;
           this.recordLocal.Product__r = response.detail.selectedItem.sObject;
           console.log('Selected prod--->',JSON.stringify(response.detail));
        }else{
           this.recordLocal.Product__c = '';
           this.recordLocal.Product_Name__c = '';
           this.recordLocal.Product_Family__c = '';
           this.recordLocal.Minimum_Order_Quantity__c = '';
        }
    }
}