/**
 * Created by StackNexus Admin on 20-01-2021.
 */

import {LightningElement , wire , track , api} from 'lwc';
import getAccountContactsList from '@salesforce/apex/ALS_AccountContacts_Ctrl.getAccountContactsInfo';
import {loadStyle} from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import deleteRecords from '@salesforce/apex/ALS_AccountContacts_Ctrl.deleteRecords';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class AlsAccountContactTabularPreview extends NavigationMixin(LightningElement){

    @track accountContacts;
    @api recordId;
    @track isModalOpen=false;
    @track accountContactId;
    @track listLength;
    @track recordToDelete;
    @track refreshTime = '';

    connectedCallback(){
        loadStyle(this, `${this.alsStyle}`);
        this.refreshTime = Date.now();
    }

    //Fetch Data Value from Controller into wired List
    @wire(getAccountContactsList , {'masterRecordId':'$recordId' ,'refreshDate' :'$refreshTime'})
    wiredContactsList({error,data}){
        // console.log('Record Id ', this.recordId);
        // console.log('Record  data', data);
        if(data){
            this.dataMap = data;
            //console.log('wiredContactsList -In side wiredContactsList ', JSON.stringify(data));
            this.accountContacts = data.accountContacts;
            //console.log('getAccountContactsList',this.accountContacts);
            //this.refreshTime = Date.now();
           // console.log(' length is----', this.accountContacts.length);
            this.listLength =  this.accountContacts.length;
            //this.refreshTime = Date.now();
            this.error = undefined;
        }
        else if (error) {
            this.error = error;
            this.accountContacts = undefined;
            console.log('AlsDocumentUpload - There is an error here'+error);
        }

    }
    //Dropdown menu for Edit and Delete
    handleDropdownClick(event) {
        let index = event.currentTarget.dataset.dropdownId;
        let dropdownClass = this.template.querySelector('[data-dropdown-id="'+index+'"]').className;
        if(this.template.querySelector('[data-dropdown-id="'+index+'"]').className.includes('slds-is-open')) {
            console.log('open');
            this.template.querySelector('[data-dropdown-id="'+index+'"]').className = 'slds-dropdown-trigger slds-dropdown-trigger_click';
        }
        else {
            this.template.querySelector('[data-dropdown-id="'+index+'"]').className = 'slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        }
    }
    // Modal Actions
    openModal(event) {

        let id = event.currentTarget.dataset.editId;
        console.log('open modal ',event.currentTarget.dataset.editId);
        this.accountContactId= id;
        this.isModalOpen = true;
     }

    closeModal(event) {
        this.isModalOpen = false;
     }
     hanldeCloseModal() {
        console.log('***** Call from child');
        this.isModalOpen = false;
        this.refreshTime = Date.now();
        console.log('refreshed time', this.refreshTime);
     }

     //Account Contacts (Card Header) to Contact Roles Navigation
    navigateToContactsList(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'AccountContactRole__c',
                relationshipApiName: 'AccountContactJunctions__r',
                actionName: 'view'
            },
        });

    }

     //Data Value: Contact Name to Contact Record Navigation
     navigateToContact(event){
        //alert(event.target.getAttribute("data-value"));
        //console.log('I am here',event.target.getAttribute("data-value"));
        this[NavigationMixin.Navigate]({
               type: 'standard__recordPage',
               attributes: {
                   recordId: event.target.getAttribute("data-value"),
                   objectApiName: 'Contact',
                   actionName: 'view'
               },
           });

    }

    //View All to Contact Roles list Navigation
    navigateToJunctionList(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'AccountContactRole__c',
                relationshipApiName: 'AccountContactJunctions__r',
                actionName: 'view'
            },
        });
     }


    //Fetch data value from Controller and Delete Id
    handleDelete(event){
        //event.target.getAttribute('data-value');
        this.recordToDelete = event.currentTarget.dataset.deleteId;
        console.log('Inside delete..++',this.recordToDelete );

        deleteRecords({
           recordToDelete: this.recordToDelete
          })
           .then(result => {
               console.log('result++++++++++ ',result);
               window.scrollTo(0,0);
               this.refreshTime = Date.now();
           })
           .catch(error => {
               this.errorToast(error.body.pageErrors[0].message);
               console.log('Error', error);
               window.scrollTo(0,0);
           });
    }
    errorToast(msg) {
        		const event = new ShowToastEvent({
        			title: 'Error',
        			message: msg,
        			variant: 'error',
        			mode: 'dismissable' //pester
        		});
        		this.dispatchEvent(event);
            }

}