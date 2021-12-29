import { LightningElement,track } from 'lwc';
import Utility from 'c/utility';
export default class PhosEditOrderProducts extends Utility {
    isLoading = true;
    currentIndex = 1;
    productsMap;
    productFamily;
    isQuantityEditable;
    fulfilmentOptions;
    initData() {
        if(this.recordLocal != undefined && this.recordLocal.Order_Products__r == undefined) {
            this.recordLocal.Order_Products__r = [];
            this.recordLocal.Order_Products__r.push({index : 0});
        } else if(this.recordLocal != undefined && this.recordLocal.Order_Products__r != undefined) {
            for(let i =0; i<this.recordLocal.Order_Products__r.length; i++) {
                this.recordLocal.Order_Products__r[i].index = this.currentIndex;
                this.currentIndex++;
            }
        }
        this.skipCustomLogicValidation = true;
    }
    get hasData() {
        if(this.recordLocal == undefined || this.recordLocal.Order_Products__r == undefined) {
            return false;
        }
        return true;
    }

    /*
    * Add empty row with index 0
    */
   /*addFirstProduct(event) {
        this.recordLocal.Order_Products__r = [];
        this.recordLocal.Order_Products__r.push({index : 0});
    }*/
    /*
    * Add empty row
    */
   handleAddProduct(response) {
        this.recordLocal.Order_Products__r.push({index : this.currentIndex});
        this.currentIndex++;
    }

    /*
    * Delete selected row
    */
   handleDeleteProduct(response){
        let childIndex = response.detail.index;
        if( this.recordLocal.Order_Products__r.length > 1) {
            this.recordLocal.Order_Products__r.splice(childIndex, 1);
        } else if( this.recordLocal.Order_Products__r.length == 1) {
            this.recordLocal.Order_Products__r = undefined;
            this.recordLocal.Order_Products__r = [];
            this.recordLocal.Order_Products__r.push({index : 0});
        }
   }
   validateCustomInput() {
        let isSuccess = true;
        if(this.recordLocal.Order_Products__r == undefined ||
            this.recordLocal.Order_Products__r.length < 1) {
            isSuccess = false;
            this.showErrorNotification('Error', 'Please add atleast one product')
        }
        return isSuccess;
   }

    /*
    * Get records from child component
    */
    updateListToParentComponentList() {
        if(this.recordLocal.Order_Products__r != undefined) {
            for(let i=0; i<this.recordLocal.Order_Products__r.length; i++) {
               let orderProductRec = this.template.querySelector('[data-id="'+i+'"]').getRecordDetails();
               console.log('planRec------',orderProductRec);
               if(orderProductRec == undefined) {
                   return undefined;
               }
               delete orderProductRec.index;
               this.recordLocal.Order_Products__r[i] = orderProductRec;
            }
        }
        console.log('this.recordLocal---', JSON.stringify(this.recordLocal));
        return this.recordLocal;
    }

    /*
    * Get records from child component
    */
    updateRecordLocal() {
        this.allInputsValidated = true;
        let recordLocal = this.updateListToParentComponentList();
        if(recordLocal == undefined) {
          this.allInputsValidated = false;
        } else {
          this.recordLocal = recordLocal;
          console.log('this.recordLocal---', JSON.stringify(this.recordLocal));
        }
    }
}