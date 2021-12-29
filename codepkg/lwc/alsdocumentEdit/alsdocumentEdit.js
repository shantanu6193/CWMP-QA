import { LightningElement,api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import formStyle from '@salesforce/resourceUrl/ALS_Styles';

export default class AlsdocumentEdit extends LightningElement {
    @api progressValue;
    @api getidfromparent;

    connectedCallback() {
        loadStyle(this, formStyle + '/ALS_DocEdit_Style.css')
    }

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields)
        /*fields.LastName = 'My Custom Last Name'; // modify a field
        console.log('test :',this.template.querySelector('lightning-record-form').submit(fields));
        this.dispatchEvent(selectEvent);*/
    }

    handleSuccess(event){
        console.log('handleSuccess event Child - Starts');
        this.progressValue = event.target.value;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: this.progressValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        console.log('handleSuccess event Child - Event Dispatched');
    }
}

/*handleSubmit(event){
    event.preventDefault();       // stop the form from submitting
    const fields = event.detail.fields;
    console.log("Inside Handle Submit");

   /* fields.LastName = 'My Custom Last Name'; // modify a field
    console.log('test :',this.template.querySelector('lightning-record-form').submit(fields));
    this.dispatchEvent(selectEvent);
 }*/