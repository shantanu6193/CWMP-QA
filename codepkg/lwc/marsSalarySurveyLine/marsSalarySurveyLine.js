/**
 * Created by Pankaj on 04-04-2021.
 */

import { LightningElement } from 'lwc';
import Utility from 'c/utility';

export default class MarsSalarySurveyLine extends Utility {
    agreementRestrictOTOptionsImp = ["Chief", "Deputy Chief", "Division Chief", "Assistant Chief"];
    get getYesNoOptions() {
        return [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        },
        ];
    }

    get isSalaryRateReadOnly() {
        if(this.recordLocal.Are_you_adding_WC_UI__c == 'No' && this.recordLocal.WC_and_or_UI__c == 'Yes') return true;
        return false;
    }

    fieldChangedPicklist(event){
        this.fieldChanged(event);
        this.updateRevisedRate();
        let searchName = this.recordLocal.Classification_Title__c;
        let containsNonOTVal = this.agreementRestrictOTOptionsImp.some(function (arrVal) {
            return searchName === arrVal;
        });
        if(this.recordLocal.WC_and_or_UI__c == 'Yes' && containsNonOTVal) {
            this.recordLocal.MOU_MOA__c = true;
        } else if(this.recordLocal.WC_and_or_UI__c == 'No' && containsNonOTVal) {
            this.recordLocal.MOU_MOA__c = false;
        }
    }

    updateRevisedRate() {
        if(this.isSalaryRateReadOnly == true) {
            this.recordLocal.Revised_Rate__c = this.recordLocal.Base_Rates__c;
        }
        if(this.disableAddingWC == true) {
            this.recordLocal.Are_you_adding_WC_UI__c = 'No';
        }
    }

    get disableAddingWC() {
        if(this.recordLocal.WC_and_or_UI__c == 'No') return true;
        return false;
    }

    get getRevisedSalaryRate() {
        return this.recordLocal.Revised_Rate__c;
    }
}