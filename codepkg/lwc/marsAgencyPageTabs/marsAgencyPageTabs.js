import { LightningElement } from 'lwc';
import Utility from 'c/utility';
import getUserTabAccess from '@salesforce/apex/MARS_AgencyPageTabsCtrl.getUserTabAccess';
export default class MarsAgencyPageTabs extends Utility {
    tabAccess;
    accountId;
    initData() {
           let urlId = this.getURLParameter("id");
           this.accountId = urlId;
            this.executeAction(getUserTabAccess,{'accountId' : this.accountId}, (response) => {
                this.tabAccess = response;
            });
    }
    get getTabAccess() {
        if(this.tabAccess == 'Primary') return true;
        return false;
    }
}