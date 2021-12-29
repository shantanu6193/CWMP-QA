import {
  LightningElement,
  api,
  track
} from 'lwc';
import getData from "@salesforce/apex/MARSNonSuppressionScreenCtrl.getData";
import submitData from "@salesforce/apex/MARSNonSuppressionScreenCtrl.submitNonSuppLines";
import Utility from 'c/utility';

export default class MarsNonSuppressionScreen extends Utility {
  @api headerTitle;
  @api recordId;
  @track columnList;
  @track rows;
  @track isDisabled = false;
  @track minDate;
  futureDate;
  parentRecord;
  @track isTableEditable;
  @track disableSubmit = false;
  agencyNonSuppPer;
  objectName = "Agency_Non_Suppression_Line_Item__c";
  fieldSetName = "Non_Suppression_Survey_Line_Item_Fields";

  initData() {
    this.executeAction(getData, {
      accountId: this.recordId
    }, (result) => {
      this.rows = result.nonSuppItemList;
      this.disableSubmit = result.disableSubmit;
      this.agencyNonSuppPer = result.agencyNonSuppPer;
      if (this.rows.length == 0 || !this.rows) {
        this.rows = [{
          uuid: this.createUUID()
        }];
      }
      let todayDate = this.todayDateInYYYYMMDD();
      if (this.agencyNonSuppPer && this.agencyNonSuppPer.Start_Date__c && new Date(this.agencyNonSuppPer.Start_Date__c) >= new Date(todayDate)) {
        var effectiveDate = new Date(this.agencyNonSuppPer.Start_Date__c);
        this.minDate = new Date(effectiveDate).toISOString();
        effectiveDate.setDate(effectiveDate.getDate() + 1);
        this.futureDate = effectiveDate.toISOString();
      } else {
        this.minDate = todayDate;
        this.futureDate = todayDate;
      }
    });
  }


  createUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = Math.random() * 16 | 0,
        v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  addRow() {
    this.rows.push({
      uuid: this.createUUID()
    });
  }

  removeRow(event) {
    if (this.rows.length > 1)
      this.rows.splice(event.target.value, 1);
  }
  hasError = false;
  saveData() {
    let recordsToSave = this.getNonSuppLines();
    if (recordsToSave.length == 0) {
      return;
    }
    if (this.hasError == true) return;
    let signatureBlob = this.template.querySelector('[data-id="signature"]').getSignatureBlob();
    if (signatureBlob == undefined) {
      this.showErrorNotification('Please sign form.');
      this.template.querySelector('[data-id="signature"]').refreshCanvas();
      return;
    }
    this.executeAction(submitData, {
      data: JSON.stringify(recordsToSave),
      accountId: this.recordId,
      effectiveDate: this.futureDate,
      signatureBlob: signatureBlob
    }, (response) => {
      this.showSuccessNotification('Records Submitted Successfully.');
      //this.template.querySelector("c-mars-non_suppression-history").initData();
      this.initData();
    });
  }

  getNonSuppLines() {
    let wrapperObj = []
    for (let i = 0; i < this.rows.length; i++) {
      let rowElements = this.template.querySelectorAll(`lightning-input[data-id="${i}"]`);
      let classificationTitle;
      let revisedRate;
      let portalToPortal = false;
      rowElements.forEach(element => {
        if (element.dataset.name && element.dataset.name === 'classificationTitle') {
          classificationTitle = element.value;
        } else if (element.dataset.name && element.dataset.name === 'revisedRate') {
          revisedRate = element.value;
        } else if(element.dataset.name && element.dataset.name === 'portalToPortal') {
            portalToPortal = element.checked;
        }
      });
      if (!revisedRate || revisedRate <= 0) {
        this.showErrorNotification('Please enter a valid value for Salary Rate');
        return wrapperObj;
      }
      let obj = {
        Classification_Title__c : classificationTitle,
        Revised_Rate__c : revisedRate,
        MOU_MOA_GBR__c : portalToPortal
      };
      if (wrapperObj == undefined) {
        this.hasError = true;
      }
      wrapperObj.push(obj);
    }

    return wrapperObj;

  }

  handleFutureDateChange(event) {
    this.futureDate = event.target.value;
    const futureDate = new Date(this.futureDate);
    var effectiveDate = new Date(this.minDate);
    effectiveDate.setDate(effectiveDate.getDate() + 1);
    let startDateCmp = this.template.querySelector(".futuredate");
    if (futureDate < effectiveDate) {
      startDateCmp.setCustomValidity("Please select a future date");
      startDateCmp.reportValidity();
      return false;
    } else {
      startDateCmp.setCustomValidity("");
      startDateCmp.reportValidity();
      return true;
    }
  }
}