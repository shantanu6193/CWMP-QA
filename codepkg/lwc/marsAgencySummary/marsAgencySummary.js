import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import getAgencySummary from '@salesforce/apex/MARS_AgencySummaryCtrl.getData';
export default class MarsAgencySummary extends Utility {
    @api recordId;
    dateInputValue;
    salarysurveylineItems = [];
    splEquipLineItemRecords = [];
    adminRateFactor;
    showTables = false;
    showPrint = false;
    initData() {
        console.log('Id 1=',this.recordId);
        if(!this.recordId) {
            let urlId = this.getURLParameter("id");
            this.recordId = urlId;
        }
    }
    handleDateChange(event){
        this.dateInputValue = event.detail.value;
    }
    handleSearch(){
        this.salarysurveylineItems = [];
        this.splEquipLineItemRecords = [];
        this.adminRateList = []
        this.adminRateFactor ='';
        this.showTables = false;
        this.showPrint = false;

        console.log('Id 2=',this.recordId);
        console.log('date=',this.dateInputValue);
        if(!this.recordId || !this.dateInputValue){
            this.showErrorNotification('Please select Date to display the result');
            return;
        }
        this.executeAction(getAgencySummary, {
            accountId: this.recordId,
            dayOfRecord: this.dateInputValue
        }, 
        (response) => {
            this.salarysurveylineItems = response.salarySurveyLineItems;
            this.splEquipLineItemRecords = response.specialEquipmentLineItem;
            this.adminRateFactor = response.adminRate;

            this.showTables = true;
            this.showPrint = true;
            console.log('response=',JSON.stringify(response))
        });
    }
    get showSalarySurveyItem() {
        if(this.salarysurveylineItems.length === 0){
            return false;
        } 
        else {
            return true;
        }
    }
    get showSpecialEquipmentItem() {
        if(this.splEquipLineItemRecords.length === 0){
            return false;
        } 
        else {
            return true;
        }
            
    }
   
    handlePrint(event){
        if(!this.recordId || !this.dateInputValue){
            this.showErrorNotification('Please select Date to display the result');
            return;
        }
        window.open('/mars/apex/MARS_AgencySummaryPDF?id=' + this.recordId+'&date='+this.dateInputValue);
    }
}