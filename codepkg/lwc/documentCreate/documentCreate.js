import { LightningElement, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import formStyle from '@salesforce/resourceUrl/DocumentUpload';

export default class DocumentCreate extends LightningElement {
    @api progressValue;
    @api parentfieldname;
    @api parentfieldvalue;

    connectedCallback() {
        loadStyle(this, formStyle + '/DocEdit_Style.css');
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
        //Submit(event);
        fields[this.parentfieldname] = this.parentfieldvalue;
        console.log('++++++++++'+this.parentfieldname+' + + '+this.parentfieldvalue);
         this.template.querySelector('lightning-record-form').submit(fields);
        // /*fields.LastName = 'My Custom Last Name'; // modify a field
        // console.log('test :',this.template.querySelector('lightning-record-form').submit(fields));
        // this.dispatchEvent(selectEvent);*/

    }

    handleSuccess(event){
     this.progressValue = event.target.value;
     const selectedEvent = new CustomEvent("progressvaluechange", {
         detail: this.progressValue
     });
     this.dispatchEvent(selectedEvent);
    }
}