/**
 * Created by PREM on 29-12-2020.
 */

import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import logos from '@salesforce/resourceUrl/PHOS_Community_Resource';
import appLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import getData from '@salesforce/apex/PHOS_CommunityHomeCtrl.getData';
export default class PhosCommunityHome extends NavigationMixin(LightningElement) {
    reportLogo = logos + '/Reports.jpg';
    orderLogo = logos + '/Orders.jpg';
    registrationLogo = logos + '/User_Registration.jpg';
    newsMedia = appLogo + '/Popular_Contents/News_Media.png'
    knowledgeList = [];
    docList = [];
    userRegPermission = false;
    @track searchTerm = '';
    connectedCallback() {
        try{
        console.log('in init');
        getData()
        .then(result => {
            console.log('result--------',result);
            this.knowledgeList = result.KnowledgeList;
            this.docList = result.DocumentList;
            this.userRegPermission = result.UserRegPermission;
        })
        .catch(error => {
            this.error = error;
        });
        }
        catch(e) {
            console.log(e);
        }
    }

    navigateToOrderListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    navigateToReportListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Report',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    navigateToUserRegistrationListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'User_Registration__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    searchHandler() {
        console.log('searchTerm-----',this.searchTerm);
        let baseUrl = window.location.host;
        window.location = '/phos/s/global-search/' + this.searchTerm;
    }
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }
    redirectToKnowledge(event) {
        let url = '/phos/s/article/' + event.target.dataset.name;
        window.location.href = url;
    }
    handleEnterPress(event){
        if(event.keyCode === 13){
            this.searchHandler();
        }
    }
}