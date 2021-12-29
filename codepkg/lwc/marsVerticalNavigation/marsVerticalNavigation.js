import {
    LightningElement,
    track,
    api
} from 'lwc';
import getRelatioshipStrength from "@salesforce/apex/MARS_Agency_Personnel_Ctrl.getRelationshipStrength";

import getPendingAgenciesUsersCount from '@salesforce/apex/MARS_Agency_Personnel_Ctrl.getPendingAgenciesUsersCount';


export default class VerticalNavigation extends LightningElement {
    @track selectedItem = 'agency_information';
    @track currentContent = 'agency_information';
    @track updatedCount = 12;
    @api accountId;
    userAllowed;
    @track error;

    @track agenyPendingLabel = 'Agency Personnel';


    connectedCallback() {
        this.accountId = window.location.href.split('id=')[1].substring(0, 18);
        console.log('url: ' + window.location.href.split('id=')[1]);
        this.fnGetAgencyUserPendingCounts(this.accountId);

    }

    fnGetAgencyUserPendingCounts(accountid) {


        console.log('GET ALLPending ORG USERS');


        getPendingAgenciesUsersCount({
                accountId: accountid
            })
            .then(result => {

                var count = result[0].expr0;

                if (count > 0) {
                    this.agenyPendingLabel = 'Agency Personnel - ' + count + ' Pending Approval'
                }

            })
            .catch(error => {
                this.error = error;
            });




    }

    get isAgencyScreen() {
        if (this.currentContent == 'agency_information') {
            return true;
        }
        return false;
    }

    get isSalarySurvey() {
        if (this.currentContent == 'salary_survey') {
            return true;
        }
        return false;
    }

    get isAdminRate() {
        if (this.currentContent == 'admin_rate') {
            return true;
        }
        return false;
    }

    get isNonSupp() {
        if (this.currentContent == 'non_suppression_personnel') {
            return true;
        }
        return false;
    }

    get isCustomNonSup() {
        if (this.currentContent == 'non_suppression_personnel_custom') {
            return true;
        }
        return false;
    }

    get isCustomSpecialEquip() {
        if (this.currentContent == 'special_equipment_custom') {
            return true;
        }
        return false;
    }

    get isSpcialEquip() {
        if (this.currentContent == 'special_equipment') {
            return true;
        }
        return false;
    }
    get isAgreement() {
        if (this.currentContent == 'resource_agreement_mou') {
            return true;
        }
        return false;
    }

    get isAgencyPersonnel() {
        if (this.currentContent == 'agency_personnel_info') {
            return true;
        }
        return false;
    }
    get isAgencySummary() {
        if (this.currentContent == 'agency_summary') {
            return true;
        }
        return false;
    }

    get userAccess() {
        //var userAllowed = false;
        getRelatioshipStrength({
            accountId: this.accountId
        }).then((result) => {
            console.log('result: ' + result)
            this.userAllowed = result;
        })
        return this.userAllowed;
    }


    handleSelect(event) {
        const selected = event.detail.name;
        this.currentContent = selected;
        console.log('current content: ' + this.currentContent);
    }

    handleNavigatePageEvent(event) {
        if (event.detail == 'non_suppression_personnel') {
            this.currentContent = 'non_suppression_personnel';
            isNonSupp();
        }

    }
}