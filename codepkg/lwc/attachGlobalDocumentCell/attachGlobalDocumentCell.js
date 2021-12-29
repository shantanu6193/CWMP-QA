/**
 * Created by Sushant Patil on 31-05-2021.
 */

import { LightningElement,api,track } from 'lwc';

export default class AttachGlobalDocumentCell extends LightningElement {
 @api columns;
 @api recordValues;

 get fieldValue() {
         //console.log('documentRecord.Id--11111111 = ', this.recordValues.documentRecord.Id);
         //console.log('value--', this.recordValues.documentRecord[this.columns.fieldName]);
         if(this.recordValues && this.columns) {
             return this.recordValues.documentRecord[this.columns.fieldName];
         }
         return '';
     }
get isNotSelectDocumentANDDocumentNameCell() {
        return (this.columns.label != 'Select Document' && this.columns.label != 'Document Name' ) ? true : false;
    }
get isSelectDocumentCell() {
        return (this.columns.label == 'Select Document') ? true : false;
    }
get isDocumentNameCell() {
        return (this.columns.label == 'Document Name') ? true : false;
    }
handleRadioButtonChange(event) {
        console.log('event.target.getAttribute("data-id") 1--', event.target.getAttribute("data-id"));
         let jsonObject = {selectedSourceDocumentValue : event.target.getAttribute("data-id")};
                             const selectedSourceDocumentValue = new CustomEvent('selectedsourcedocumentrecord', {
                                     detail : jsonObject,
                             });
                             this.dispatchEvent(selectedSourceDocumentValue);
    }

}