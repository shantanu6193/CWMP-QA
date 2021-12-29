import { LightningElement ,wire , track , api } from 'lwc';
import {loadStyle} from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import getIncidentSubrecipient from '@salesforce/apex/ALS_IncidentSubrecipientJunPreview_Ctrl.getIncidentSubrecipientInfo';

export default class AlsIncidentSubrecipientJunctionPreview extends NavigationMixin(LightningElement){

    @track incidentSubrecipient;
    @api recordId;

     //Fetch Data Value from Controller into wired List
     @wire(getIncidentSubrecipient , {'masterRecordId':'$recordId' ,'refreshDate' :'$refreshTime'})
     wiredIncidentSubrecipientList({error,data}){
         console.log('Record Id ', this.recordId);
         console.log('Record  data', data);
         if(data){
             this.dataMap = data;
             //console.log('wiredContactsList -In side incidentSubrecipient ', JSON.stringify(data));
             this.incidentSubrecipient = data.incidentSubrecipient;
             //console.log('getIncidentSubrecipient',this.incidentSubrecipient);
            //  this.refreshTime = Date.now();
             this.error = undefined;
         }
         else if (error) {
             this.error = error;
             this.incidentSubrecipient = undefined;
             console.log('AlsincidentSubrecipient - There is an error here'+error);
         }
 
     }


    connectedCallback(){
        loadStyle(this, `${this.alsStyle}`);
        this.refreshTime = Date.now();
    }
    

    navigateToJunctionList(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Incident_Subrecipient_Stage__c',
                relationshipApiName: 'Incident_sub_recipient_stage__r',
                actionName: 'view'
            },
        });
    }

    navigateToIncidentName(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Incident__c',
                actionName: 'view'
            },
        });

    }
    navigateToAccountName(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                // recordId: event.target.getAttribute("data-value"),
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }
    navigateToIncidentSubrecipientRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Incident_Subrecipient_Stage__c',
                actionName: 'view'
            },
        });
    }

}