import { LightningElement, api } from 'lwc';
import apexSearchProduct from '@salesforce/apex/PHOS_ProductSearchCtrl.apexSearchProduct';
import Utility from 'c/utility';
export default class PhosProductSearch extends Utility {

    @api selectProductId;
    @api selectProductName;

    loadDataOnLookup = true; 
    productRequired = [];
    productSelection = [];
    isMultiEntry = false;

    /*
    * Set value to the component if product is present
    */
    initData() {
        console.log('selectProductId---',this.selectProductId);
        console.log('selectProductName---',this.selectProductName);
        if(this.selectProductId) {
             this.productSelection = [
            {
                id: this.selectProductId,
                sObjectType: 'Product2',
                icon: 'standard:product',
                title: this.selectProductName,
                subtitle: ''
            }
            ];
        }

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
            const prod = response.detail.selectedItem;
            const productData = { Id : prod.id, Name : prod.sObject.Name, Family : prod.sObject.Family, MinimumOrderQuantity : prod.sObject.Minimum_Order_Quantity__c };
            const industryChangeEvent = new CustomEvent("productchange", {detail: { productData }});
            // Fire the custom event
            this.dispatchEvent(industryChangeEvent);
        }else{
            this.recordLocal.Product__c = '';
            const productData = { Id : '', Name :'', Family : '', MinimumOrderQuantity : '' };
            const industryChangeEvent = new CustomEvent("productchange", {detail: { productData }});
            // Fire the custom event
            this.dispatchEvent(industryChangeEvent);
        }
    }

    /*
    * Validate lookup field
    */
    @api
    validateCustomInput() {
        this.productRequired = [];
        console.log('test--------',this.recordLocal);
        let isSuccess = true;
        if (this.selectProductId == undefined || this.selectProductId == '') {
            this.productRequired.push({ message: 'Complete this field.' });
            isSuccess = false;
        }
        return isSuccess;
    }
}