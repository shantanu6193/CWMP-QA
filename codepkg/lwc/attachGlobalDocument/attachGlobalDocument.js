/**
 * Created by Sushant Patil on 28-05-2021.
 */

import { LightningElement, wire, track, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AttachGlobalDocument extends LightningElement {
@api sourceDocumentList;
@api isDocumentFound;
//@api messageToDisplay;
@api cloneDocumentTableColumns;
selectedSourceDocumentValue;
onSelectSecondaryDocument(event){
     console.log('****-destinationDocumentId** = '+this.destinationDocumentId);
     if(!this.selectedSourceDocumentValue){
         this.errorToast('Error','Please select Document To Copy..','error');
     }
     if(this.selectedSourceDocumentValue){
           let jsonObject = {selectedSourceDocumentValue : this.selectedSourceDocumentValue };
                     const selectedSourceDocumentValue = new CustomEvent('selectedsourcedocumentrecord', {
                             detail : jsonObject,
                     });
                     this.dispatchEvent(selectedSourceDocumentValue);
     }
 }
  connectedCallback(){
      console.log('****-cloneDocumentTableColumns** = '+this.cloneDocumentTableColumns);
 }
closeModal() {
       const closemodal = new CustomEvent('closemodal', {
               detail : null,
       });
       this.dispatchEvent(closemodal);
  }
 handleRadioButtonChange(event) {
     console.log('event.target.getAttribute("data-id") 2--',event.detail.selectedSourceDocumentValue);
     this.selectedSourceDocumentValue = event.detail.selectedSourceDocumentValue;
 }
errorToast(title1,message1,variant1) {
          const evt = new ShowToastEvent({
              title: title1,
              message: message1,
              variant: variant1,
          });
          this.dispatchEvent(evt);

  }


}