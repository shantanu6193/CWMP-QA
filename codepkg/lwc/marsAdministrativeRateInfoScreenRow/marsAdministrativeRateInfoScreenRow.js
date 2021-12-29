import { LightningElement } from 'lwc';
import Utility from 'c/utility';
export default class MarsAdministrativeRateInfoScreenRow extends Utility {

    onInputFilled(event){
        this.fieldChanged(event);
        if(this.recordLocal.Direct__c != undefined && this.recordLocal.Indirect__c != undefined) {
            this.recordLocal.Total__c = Number(this.recordLocal.Direct__c) + Number(this.recordLocal.Indirect__c);
        } else if(this.recordLocal.Indirect__c != undefined){
            this.recordLocal.Total__c = this.recordLocal.Indirect__c;
        } else if(this.recordLocal.Direct__c != undefined){
            this.recordLocal.Total__c = this.recordLocal.Direct__c;
        } 
        const calculationdata = "calculationdata";
        //const calculationdata = { direct:this.recordLocal.Direct__c , indirect:this.recordLocal.Indirect__c, total:this.recordLocal.Total__c };
        const addEvent = new CustomEvent('totaldata', { detail: {calculationdata}});
        this.dispatchEvent(addEvent);
    }
}