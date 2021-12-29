/**
 * Created by Sushant Patil on 07-09-2021.
 */

import { LightningElement, track,api, wire } from 'lwc';
import getRecordInfo from '@salesforce/apex/HHCustomRelatedListCtrl.getRecordInfo';
import {loadStyle} from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import HH_EN_First_Name from '@salesforce/label/c.HH_EN_First_Name';
import HH_EN_Last_Name from '@salesforce/label/c.HH_EN_Last_Name';
import HH_EN_Relationship_to_Homeowner from '@salesforce/label/c.HH_EN_Relationship_to_Homeowner';
import HH_EN_Annual_Income from '@salesforce/label/c.HH_EN_Annual_Income';
import HH_EN_Date_of_Birth from '@salesforce/label/c.HH_EN_Date_of_Birth';
import HH_EN_Refresh from '@salesforce/label/c.HH_EN_Refresh';

export default class HHCustomRelatedListCoOwner extends NavigationMixin(LightningElement) {
    @api recordId;
    @track applicationContacts;
    @track error;
    @track listLength;
    @track showTable = false;
    @api filter ='Role__c=\'Co-owner\'';
    @api heading;
    @track refresh ='';
    @track label = {
    			HH_EN_First_Name,
    			HH_EN_Last_Name,
    			HH_EN_Relationship_to_Homeowner,
    			HH_EN_Annual_Income,
    			HH_EN_Date_of_Birth,
    			HH_EN_Refresh
    	}

    connectedCallback(){}

    handleRefresh(e){
        this.refresh = Date.now();
    }

    //Fetch Data Value from Controller into wired List
    @wire(getRecordInfo , {'masterRecordId':'$recordId', 'filter': '$filter', 'refresh':'$refresh'})
    wiredAccountsList({error,data}){
        if(data){
            this.applicationContacts = data.applicationContacts;

            //console.log('Apex call------1 = '+this.applicationContacts[0].Last_Name__c);
            this.listLength =  this.applicationContacts.length;
            if(this.listLength > 0){
                //eval("$A.get('e.force:refreshView').fire();");
                this.showTable = true;
            }
        }
        else if (error) {
            this.error = error;
            this.contactAccounts = undefined;
        }
    }

    navigateToApplicationContactsList(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'HH_Application__c',
                relationshipApiName: 'Application_Contacts__r',
                actionName: 'view'
            },
        });
    }

     navigateToRecord(event){
        this[NavigationMixin.Navigate]({
               type: 'standard__recordPage',
               attributes: {
                   recordId: event.target.getAttribute("data-value"),
                   objectApiName: 'Application_Contact__c',
                   actionName: 'view'
               },
           });
    }
}