/**
 * Created by PREM on 10-09-2020.
 */

import { LightningElement,api,track, wire } from 'lwc';
import apexSearchProduct from '@salesforce/apex/PHOS_RequestorAgecyLookupCtrl.apexSearchAgency';
import getStatePicklistValues from '@salesforce/apex/PHOS_RequestorAgecyLookupCtrl.getPicklistData';
import getCounty from '@salesforce/apex/PHOS_RequestorAgecyLookupCtrl.getCounty';
import Utility from 'c/utility';


export default class PhosRequestorAgencyLookup extends Utility {

    @api selectProductName;
    @api isDisabled = false;
    loadDataOnLookup = false;
    agencyRequired = [];
    agencySelection = [];
    isMultiEntry = false;
    createNewAccount = true;
    newRecordLabels = [];
    newRecordApis = [];
	@api entityTypeFilter = '';

    /*
    * Get Shipping_State__c values
    */
    getStateValues() {
        console.log('state values----',this.statePicklistValues);
        let statePicklist = [];
        this.executeAction(getStatePicklistValues, {objectName : 'Order__c', fieldName : 'Shipping_State__c'}, (response) => {
            console.log('res------>',response);
                for(let i=0; i < response.length; i++) {
                    statePicklist.push({label:response[i], value:response[i]});
                }
           });
           return statePicklist;
    }

    /*
    * Get County values
    */
    getCountyValues() {
            //console.log('state values----',this.statePicklistValues);
            let countyPicklist = [];
            this.executeAction(getCounty, {}, (response) => {
                console.log('res------>',response);
                    for(let i=0; i < response.length; i++) {
                        countyPicklist.push({label:response[i].Name, value:response[i].Id});
                    }
               });
               return countyPicklist;
        }

    /*
    * Created array of fields for creation of new account
    */
    initData() {
        let countyPicklist = this.getCountyValues();
        let newStatePicklist = this.getStateValues();
        console.log('newStatePicklist',newStatePicklist)
        this.newRecordLabels = [
            {
                'label' : 'Requester Agency Name',
                'api' : 'Name',
                'req' : true,
                'isText' : true
            },
            {
                'label' : 'Entity Id',
                'api' : 'Entity_Id__c',
                'req' : true,
                'isText' : true,
                'fieldLevelHelp' : 'Please enter the Unique Entity ID for your organization. The Unique Entity ID may be the Facility ID for Health Care Facilities, or the Employer Identification Number (EIN) for non-Health Care Facility Entity types.'
            },
            {
                'label' : 'Phone',
                'api' : 'Phone',
                'req' : true,
                'isPhone' : true
            },
            {
                'label' : 'Entity Type',
                'api' : 'Entity_Type__c',
                'req' : true,
                'isPicklist' : true,
                'values' : [{ label: 'Non-Governmental Entity', value: 'Non-Governmental Entity' },{ label: 'Health Care Facility', value: 'Health Care Facility' }]
            },
            {
                'label' : 'Street',
                'api' : 'ShippingStreet',
                'req' : false,
                'isText' : true
            },
            {
                'label' : 'City',
                'api' : 'ShippingCity',
                'req' : false,
                'isText' : true,
            },
            {
                'label' : 'State',
                'api' : 'ShippingState',
                'req' : false,
                'isPicklist' : true,
                'values' : newStatePicklist
            },
            {
                'label' : 'County',
                'api' : 'ParentId',
                'req' : true,
                'isPicklist' : true,
                'values' : countyPicklist
            },
            {
                'label' : 'Zip',
                'api' : 'ShippingPostalCode',
                'req' : false,
                'isNumber' : true,
                'pattern' : '[0-9]{5}'
            }
        ];

        console.log('this.newRecordLabels--------',this.newRecordLabels);

        console.log('selectProductName---',this.selectProductName);
        if(this.selectProductName) {
             this.agencySelection = [
            {
                id: '',
                sObjectType: 'Account',
                icon: 'standard:account',
                title: this.selectProductName,
                subtitle: ''
            }
            ];
        }

    }

    /*
    * Searches account with Entity_Type__c selected from Entity_Type__c filed
    */
    handleRequestorAgencySearch(event) {
        console.log('event------------',this.entityTypeFilter);
        console.log('event------------',event.detail.searchTerm);
        apexSearchProduct({ searchTerm: event.detail.searchTerm, entityTypeFilter: this.entityTypeFilter })
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup="Agency__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Agency__c
    */
    handleRequestorAgencyChange(response) {
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            const agency = response.detail.selectedItem;
            const agencyData = { Id : agency.id, Name : agency.sObject.Name };
            const agencyChangeEvent = new CustomEvent("agencychange", {detail: { agencyData }});
            this.dispatchEvent(agencyChangeEvent);
        }else{
            const agencyData = { Id : '', Name : '' };
            const agencyChangeEvent = new CustomEvent("agencychange", {detail: { agencyData }});
            this.dispatchEvent(agencyChangeEvent);
        }
    }

    /*
    * validate lookup field
    */
    @api
    validateCustomInput() {
        this.agencyRequired = [];
        console.log('test--------',this.recordLocal.Requestor_Agency_Text__c);
        let isSuccess = true;
        if ((this.selectProductName == undefined || this.selectProductName == '')
                && (this.recordLocal.Requestor_Agency_Text__c == undefined || this.recordLocal.Requestor_Agency_Text__c == '')) {
            this.agencyRequired.push({ message: 'Complete this field.' });
            isSuccess = false;
        }
        return isSuccess;
    }
}