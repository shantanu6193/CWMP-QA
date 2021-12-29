import { LightningElement ,api} from 'lwc';
import createInvoiceEstimate from '@salesforce/apex/MARS_GenerateEstimateForF42sCtrl.createInvoiceEstimate';
import Utility from 'c/utility';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class MarsGenerateEstimateForF42s extends Utility  {
    estimateInvoiceList;
    @api recordId;
    initData() { 
        console.log(this.recordId);
        if(this.recordId != undefined) {
            let paramMap = {};
            paramMap['f42s'] = this.recordId;
            this.executeAction(createInvoiceEstimate, paramMap, (response) => {
               this.estimateInvoiceList = JSON.parse(response.invoiceRecord);
               //console.log('Data=',response.invoiceRecord);
            });
        }
    }

    renderedCallback() {
        console.log('rendered------------');
        console.log(this.recordId);
        //this.initData();
    }
    
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}