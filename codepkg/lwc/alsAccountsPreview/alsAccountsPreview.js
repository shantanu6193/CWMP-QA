import { LightningElement, track,api, wire } from 'lwc';
import getContactAccountsList from '@salesforce/apex/ALS_ContactAccounts_Ctrl.getContactAccountsInfo';
import {loadStyle} from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import deleteRecords from '@salesforce/apex/ALS_ContactAccounts_Ctrl.deleteRecords';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class AlsAccountsPreview extends NavigationMixin(LightningElement){
    @track contactAccounts;
    @api recordId;
    @track listLength;
    @track isModalOpen=false;
    @track recordToDelete;
    @track refreshTime = '';
    @track accountContactId;
    
    connectedCallback(){
        loadStyle(this, `${this.alsStyle}`);
        this.refreshTime = Date.now();
    }

    //Fetch Data Value from Controller into wired List
    @wire(getContactAccountsList , {'masterRecordId':'$recordId' ,'refreshDate' :'$refreshTime'})
    wiredAccountsList({error,data}){
        // console.log('Record Id ', this.recordId);
        // console.log('Record  data', data);
        if(data){
            this.dataMap = data;
            //console.log('wiredAccountsList -In side wiredAccountsList ', JSON.stringify(data));
            this.contactAccounts = data.contactAccounts;
            //console.log('getContactAccountsList',this.contactAccounts);
            //this.refreshTime = Date.now();
            // console.log(' length is----', this.contactAccounts.length);
            this.listLength =  this.contactAccounts.length;
            this.error = undefined;
        }
        else if (error) {
            this.error = error;
            this.contactAccounts = undefined;
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
        //console.log('Testing++++++++',event.currentTarget.getAttribute('data-value'));
        //console.log('Try++++++++',event.currentTarget.dataset.value);
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

    // Contact Accounts (Card Header) to Contact Roles Navigation
     navigateToAccountsList(){ 
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
     
     //Data Value: Account Name to Account Record Navigation
     navigateToAccount(event){
         //alert(event.target.getAttribute("data-value"));
         //console.log('I am here',event.target.getAttribute("data-value"));
         this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.getAttribute("data-value"),
                    objectApiName: 'Account',
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
          console.log('Inside delete',this.recordToDelete );
          deleteRecords({
            recordToDelete: this.recordToDelete
           })
            .then(result => {
                console.log('result++++++++++ ',result);
                window.scrollTo(0,0);
                this.refreshTime = Date.now();
            })
            .catch(error => {
                console.log('Error', error);
                this.errorToast(error.body.pageErrors[0].message);
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