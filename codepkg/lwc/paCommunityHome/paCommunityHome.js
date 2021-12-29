/*
 *LWC Name      : PaCommunityHome
 * Description  : -
 *               
 * Author       : Pankaj
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Pankaj             28/05/2021       Initial Implementation
**/
import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import logos from '@salesforce/resourceUrl/PA_Community_Resources';
import appLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import getDatatwo from '@salesforce/apex/PA_CommunityHomeCtrl.getDatatwo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//import Utility from 'c/utility';
export default class PaCommunityHome extends NavigationMixin(LightningElement) {
    reportLogo = logos + '/Reports.jpg';
    orderLogo = logos + '/Orders.jpg';
    closeoutLogo = logos + '/closeout.jpg';
    registrationLogo = logos + '/User_Registration.jpg';
    newsMedia = appLogo + '/Popular_Contents/News_Media.png'
    knowledgeList = [];
    docList = [];
    searchTerm = '';
    reportUrl = '';
    connectedCallback() {
        try{
        getDatatwo()
        .then(result => {
                
            this.knowledgeList = result.KnowledgeList;
            this.docList = result.DocumentList;
            this.reportUrl = result.ReportUrl;
        })
        .catch(error => {
            this.error = error;
        });
        } catch(e) {
           
        }
    }
    navigateToAppealListView() {
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Amendment_Request__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }catch(e){
        
    }
    }
    navigateToProjectCloseOutTaskListView() {
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Closeout_Request__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }catch(e){
       
    }
    }
    navigateToProjectListView() {
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }catch(e){
       
    }
    }
    
    navigateToReportListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.reportUrl
            },
        });
    }
    searchHandler() {
        if(this.searchTerm == undefined || this.searchTerm == null || this.searchTerm == '') {
            const event = new ShowToastEvent({
                title: '',
                message: 'Please enter a value in the search field',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        } else {
        let baseUrl = window.location.host;
        window.location = '/pa/s/global-search/' + this.searchTerm;
    }
       
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }
    redirectToKnowledge(event) {
        let url = '/pa/s/article/' + event.target.dataset.name;
        window.location.href = url;
    }
    handleEnterPress(event){
        if(event.keyCode === 13){
            this.searchHandler();
        }
    }
}