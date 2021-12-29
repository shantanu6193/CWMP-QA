/**
 * Created by Pankaj on 11-03-2021.
 */

 import { LightningElement, track, wire } from 'lwc';
 import { NavigationMixin } from 'lightning/navigation';
 import getUserDetail from '@salesforce/apex/HH_TemplateCtrl.getUserName';
 //import logos from '@salesforce/resourceUrl/PA_Community_Resources';
 import HHlogos from '@salesforce/resourceUrl/HH_Common_Community_Resource';
 //import appLogo from '@salesforce/resourceUrl/Common_Community_Resource';
 import HH_Community_Relative_Url from '@salesforce/label/c.HH_Community_Relative_Url';
 import HH_EN_Submit_Applications from '@salesforce/label/c.HH_EN_Submit_Applications';
 import HH_EN_Applications from '@salesforce/label/c.HH_EN_Applications';
 import HH_EN_Search from '@salesforce/label/c.HH_EN_Search';
 import HH_EN_Landing_Page_Title from '@salesforce/label/c.HH_EN_Landing_Page_Title';
 import HH_EN_View_Reports from '@salesforce/label/c.HH_EN_View_Reports';
 import HH_EN_View_Dashboards from '@salesforce/label/c.HH_EN_View_Dashboards';

 //import Utility from 'c/utility';
 export default class HhCommunityHome extends NavigationMixin(LightningElement) {
    reportLogo = HHlogos + '/Reports.jpg';
    orderLogo = HHlogos + '/Orders.jpg';
    closeoutLogo = HHlogos + '/closeout.jpg';
    viewReportslogo = HHlogos + '/ReportsImage.jpg';
    viewDashboardslogo = HHlogos + '/DashboardImage.jpg';
    //newsMedia = appLogo + '/Popular_Contents/News_Media.png';
    //HHlogos = appLogo
    docList = [];
    searchTerm = '';
@track label = {
        HH_EN_Submit_Applications,
        HH_Community_Relative_Url,
        HH_EN_Applications,
        HH_EN_Search,
        HH_EN_Landing_Page_Title,
        HH_EN_View_Reports,
        HH_EN_View_Dashboards
    }
    @track isNotHomeOwner;
    @track isNotFEMAUser

    navigateToSubmitApplication() {
        window.location.href = this.label.HH_Community_Relative_Url+'/s/check-draft-applications';
    }
    navigateToReports() {
        window.location.href = this.label.HH_Community_Relative_Url+'/s/report/Report/Recent';
    }
    navigateToDashboard() {
        window.location.href = this.label.HH_Community_Relative_Url+'/s/dashboard/Dashboard/Recent';
    }

    navigateToApplicationListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'HH_Application__c',
                actionName: 'list'
            },
            state: {
                'HH_Application__c-filterId': 'All'
            },
        });
    }
    
    searchHandler() {
        console.log('searchTerm-----',this.searchTerm);
        if(this.searchTerm){
             let baseUrl = window.location.host;
             window.location = this.label.HH_Community_Relative_Url+'/s/global-search/' + this.searchTerm;
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleEnterPress(event){
        if(event.keyCode === 13){
            this.searchHandler();
        }
    }

    connectedCallback()	{
        getUserDetail()
            .then(result => {
                this.isNotFEMAUser = result.isNotFEMAUser == 'true' ? true:false;
                this.isNotHomeOwner = result.isNotHomeOwner == 'true'? true: false;
                console.log('result', result);
            })
            .catch(error => {
                console.log('Error---', error);
            });
    }
}