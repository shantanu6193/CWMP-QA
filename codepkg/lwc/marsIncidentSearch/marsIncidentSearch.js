import { LightningElement,track  } from 'lwc';
import getIncidentList from '@salesforce/apex/MARS_Incident_Search_Ctrl.getIncidentList';
import getIncidentListByNumber from '@salesforce/apex/MARS_Incident_Search_Ctrl.getIncidentListByNumber';


const columns = [
    { label: 'Name', fieldName: 'Link',
    type: 'url', 
    typeAttributes: { 
        label: {
            fieldName: 'Name'
        },
        target: '_self'
    },
},
    { label: 'Incident Order Number', fieldName: 'Order_No__c' },
    { label: 'Incident Start Date', fieldName: 'Incident_Start_Date__c', type: 'date' },
    { label: 'Incident End Date', fieldName: 'Incident_End_Date__c', type: 'date' },
    { label: 'Event Type', fieldName: 'Event_Type__c' },
];


export default class MarsIncidentSearch extends LightningElement {

    @track name = '';
    @track number = '';

    @track incidentsRecord;
    columns = columns;

    nameChange(event) {

        this.name  = event.target.value;

                getIncidentList({
                        searchKey: this.name,
                    })
                    .then(result => {
                        // set @track contacts variable with return contact list from server  
                        this.incidentsRecord = result;

                        var newResults = [];

                        result.forEach(function(temp,Index){
                            newResults.push({
                                "Id": temp.Id,
                                'Name': temp.Name,
                                "Link":'/lightning/r/Incident__c/'+ temp.Id +  '/view',
                                "Order_No__c": temp.Order_No__c,
                                "Event_Type__c": temp.Event_Type__c,
                                "Incident_Start_Date__c": temp.Incident_Start_Date__c,
                                "Incident_End_Date__c": temp.Incident_End_Date__c

                            });
                        });


                        this.incidentsRecord = null;
                        this.incidentsRecord = newResults;

                    })
                    .catch(error => {
                    

                    });


    }


    numberChange(event) {


        this.number  = event.target.value;


        getIncidentListByNumber({
                        searchnum: this.number
                    })
                    .then(result => {
                        // set @track contacts variable with return contact list from server  
                        this.incidentsRecord = result;

                        var newResults = [];

                        result.forEach(function(temp,Index){
                            newResults.push({
                                "Id": temp.Id,
                                'Name': temp.Name,
                                "Link":'/lightning/r/Incident__c/'+ temp.Id +  '/view',
                                "Order_No__c": temp.Order_No__c,
                                "Event_Type__c": temp.Event_Type__c,
                                "Incident_Start_Date__c": temp.Incident_Start_Date__c,
                                "Incident_End_Date__c": temp.Incident_End_Date__c

                            });
                        });


                        this.incidentsRecord = null;
                        this.incidentsRecord = newResults;

                    })
                    .catch(error => {
                    

                    });


    }


}