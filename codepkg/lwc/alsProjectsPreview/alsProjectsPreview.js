import { LightningElement, wire , track , api } from 'lwc';
import getProjectsList from '@salesforce/apex/ALS_ProjectsPreviewController_Ctrl.getProjectsInfo';
import {loadStyle} from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import deleteRecords from '@salesforce/apex/ALS_ProjectsPreviewController_Ctrl.deleteRecords';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class AlsProjectsPreview extends NavigationMixin (LightningElement) {
    @track projectJunctions;
    @track projectjunctionId;
    @api recordId;
    @track listLength;
    @track isModalOpen=false;
    @track recordToDelete;
    @track refreshTime = '';
    

    connectedCallback(){
        loadStyle(this, `${this.alsStyle}`);
        this.refreshTime = Date.now();
    }

    //Fetch Data Value from Controller into wired List
    @wire(getProjectsList , {'masterRecordId':'$recordId' ,'refreshDate' :'$refreshTime'})
    wiredProjectsList({error,data}){
        // console.log('wiredProjectsList ---Record Id ', this.recordId);
        // console.log('Record  data', data);
        if(data){
            this.dataMap = data;
        //    console.log('wiredProjectsList -In side wiredProjectsList ', JSON.stringify(data));
            this.projectJunctions = data.projectJunctions;
            // console.log('getProjectsList',this.projectJunctions);
            // this.refreshTime = Date.now();
            //console.log('refreshed time', this.refreshTime);
            this.listLength =  this.projectJunctions.length;
           // console.log('+++this.listLength++ '+this.listLength);
            this.error = undefined;
        }
        else if (error) {
            this.error = error;
            this.projectJunctions = undefined;
        }

    }

    //Dropdown menu for Edit and Delete
    handleDropdownClick(event) {
        let index = event.currentTarget.dataset.dropdownId;
        let dropdownClass = this.template.querySelector('[data-dropdown-id="'+index+'"]').className;
        if(this.template.querySelector('[data-dropdown-id="'+index+'"]').className.includes('slds-is-open')) {
            this.template.querySelector('[data-dropdown-id="'+index+'"]').className = 'slds-dropdown-trigger slds-dropdown-trigger_click';
        }
        else {
            this.template.querySelector('[data-dropdown-id="'+index+'"]').className = 'slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        }
    }

     // Modal Actions
     openModal(event) {
         this.projectjunctionId = event.currentTarget.dataset.editId;
        console.log('InsideopenModal_this.projectjunctionId+++ '+this.projectjunctionId);
         this.isModalOpen = true;
         console.log('+++++++1'+this.isModalOpen);
      }
      closeModal(event) {
        this.isModalOpen = false;
     }
     hanldeCloseModal() {
        this.isModalOpen = false;
        this.refreshTime = Date.now();
     }

    //Project Roles (Card Header) to Project Roles Junction Navigation
    navigateToProjectsList(){ 
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Project_Role__c',
                relationshipApiName: 'Project_Roles__r',
                actionName: 'view'
            },
        });
    }
    
    //View All to Project Roles Junction Navigation
    navigateToProjectRoleList(){ 
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Project_Role__c',
                relationshipApiName: 'Project_Roles__r',
                actionName: 'view'
            },
        });
    }

    //Data Value: Account Name to Account Record Navigation
    navigateToAccountName(event){ 
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.getAttribute("data-value"),
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            });
         }
         
    //Data Value: Contact Name to Contact Record Navigation
    navigateToContactName(event){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.getAttribute("data-value"),
                    objectApiName: 'Contact',
                    actionName: 'view'
                },
            });
         }
    
    //Data Value: Project Role to Contact Record Navigation
    navigateToAcr(event){ 
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.getAttribute("data-value"),
                    objectApiName: 'AccountContactRole__c',
                   // objectApiName: 'Project_Role__c',
                    actionName: 'view'
                },
            })
         }
         
    //Fetch data value from Controller and Delete Id 
    handleDelete(event){
        
        this.recordToDelete = event.currentTarget.dataset.deleteId;
        console.log('Inside delete++++++',this.recordToDelete );
        
        deleteRecords({
               recordToDelete: this.recordToDelete
              })
               .then(result => {

                  // console.log('result++++++++++ ',result);
                   window.scrollTo(0,0);
                   this.refreshTime = Date.now();
                   //console.log('refreshed time', this.refreshTime);
               })
               .catch(error => {

                  console.log('Error+++++++', error);
                  this.errorToast(error);
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