import { LightningElement,api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import formStyle from '@salesforce/resourceUrl/ALS_Styles';
import {
	ShowToastEvent
	} from 'lightning/platformShowToastEvent';

export default class AlsDocumentCreate extends LightningElement {
    @api progressValue;
    @api parentfieldname;
    @api parentfieldvalue;
    @api availabledocuments;

    connectedCallback() {
        loadStyle(this, formStyle + '/ALS_DocEdit_Style.css');
    }

    renderedCallback(){
        const inputFields = this.template.querySelectorAll(
            'lightning-record-form'
        );
        console.log('input: '+JSON.stringify(inputFields));
    }



    // handleformload(event){
    //     //console.log('load function: '+JSON.stringify(event));
    //     const fields = event.detail.record.fields;
    //     console.log('fields on load: '+JSON.stringify(fields));
    //     console.log('project: '+JSON.stringify(fields[this.parentfieldname]));
    //     console.log('project: '+JSON.stringify(fields[this.parentfieldname].value));
    //     fields[this.parentfieldname].value = this.parentfieldvalue
    //     //console.log('record form is ' + this.template.querySelectorAll('lightning-input-field'));
    //     //console.log('record form stringified is ' + Object.keys(this.template.querySelectorAll('lightning-input-field')));
    //     //var elements = this.template.querySelectorAll('lightning-input-field');
    // }

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
         console.log(' I am in submit');
         const fields = event.detail.fields;

   /* var alldocs = JSON.stringify(this.availabledocuments);
    console.log('DDDDDDDDDDDDDD '+alldocs);
     if(alldocs.contains('Supplement')){
       console.log('DDDDDDDDDDDDdssssssssssssssssssssssssssDD ');
     }
    var newDoc = fields.Document_Name__c;
    if(alldocs.contains(newDoc)){
        console.log('DDDDDDDDDDDDDD ');
    }*/

                          /* var Count =0;
                           this.availabledocuments.forEach(function(acc){
                               var dup1 = acc.documentRecord.Document_Name__c;
                               var dup2 = fields.Document_Name__c
                               if(dup1 == dup2){
                                Count++;
                               }
                           });
                            if(Count > 0){
                                 this.errorToast();
                            }else{*/

                            //Submit(event);
                            fields[this.parentfieldname] = this.parentfieldvalue;
                            console.log('++++++++++'+this.parentfieldname+' + + '+this.parentfieldvalue);
                            this.template.querySelector('lightning-record-form').submit(fields);

        // /*fields.LastName = 'My Custom Last Name'; // modify a field
        // console.log('test :',this.template.querySelector('lightning-record-form').submit(fields));
        // this.dispatchEvent(selectEvent);*/
                           // }
    }

    errorToast(msg) {
         	const event = new ShowToastEvent({
         		title: 'Error',
         		message: 'Duplicate Document.',
         		variant: 'Error',
         		mode: 'sticky'
         	});
         	this.dispatchEvent(event);
         	}

    handleSuccess(event){
        //     console.log('handleSuccess event Child - Starts');
          this.progressValue = event.target.value;
        //Success(event);
        //     // Creates the event with the data.
             const selectedEvent = new CustomEvent("progressvaluechange", {
                 detail: this.progressValue
             });
    
        //     // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        //     console.log('handleSuccess event Child - Event Dispatched');
         }
}