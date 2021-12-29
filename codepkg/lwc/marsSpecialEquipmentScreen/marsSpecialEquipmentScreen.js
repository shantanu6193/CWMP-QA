import {
  LightningElement,
  api,
  track
} from 'lwc';
import getData from "@salesforce/apex/MARSSpecialEquipmentScreenCtrl.getData";
import submitData from "@salesforce/apex/MARSSpecialEquipmentScreenCtrl.submitSpecEquipLines";
import Utility from 'c/utility';


export default class MarsNonSuppressionScreen extends Utility {
  @api headerTitle;
  @api recordId;
  @track columnList;
  @track rows;
  @track isDisabled = false;
  @track minDate;
  futureDate;
  @track isTableEditable;
  disableSubmit = false;
  currentIndex = 0;
  hasError = false;
  specEquip;
  oldRequestedEffectiveDate;
  initData() {
    let todayDate = this.todayDateInYYYYMMDD();
    this.executeAction(getData, {
      accountId: this.recordId
    }, (result) => {
      if (result) {
        if (result.specEquipList.length !== 0)
          this.rows = result.specEquipList;
        if (this.rows != undefined) {
          this.rows.forEach(element => {
            delete element.Id;
            element.index = this.currentIndex;
            this.currentIndex++;
          });
        } else {
          this.rows = []
          this.rows.push({
            index: this.currentIndex
          });
          this.currentIndex++;
        }
        this.disableSubmit = result.disableSubmit; 
        this.specEquip = result.specEquip;
        console.log('this.specEquip=',JSON.stringify(this.specEquip));
        if (this.specEquip && this.specEquip.Start_Date__c && new Date(this.specEquip.Start_Date__c) >= new Date(todayDate)) {
          var effectiveDate = new Date(this.specEquip.Start_Date__c);
          this.oldRequestedEffectiveDate = this.specEquip.Start_Date__c;
          //this.minDate = new Date(effectiveDate).toISOString();
          effectiveDate.setDate(effectiveDate.getDate() + 1);
          this.minDate = new Date(this.oldRequestedEffectiveDate).toISOString();
          this.futureDate = effectiveDate.toISOString();
        } else {
          this.minDate = todayDate;
          this.futureDate = todayDate;
        }

      }
    });

  }

  // createUUID() {
  //   console.log('I am in createUUID')
  //   return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
  //     var r = Math.random() * 16 | 0,
  //       v = c == 'x' ? r : (r & 0x3 | 0x8);
  //     return v.toString(16);
  //   });
  // }

  addRow() {
    this.rows.push({
      index: this.currentIndex
    });
    this.currentIndex++;
  }

  removeRow(response) {
    let childIndex = response.detail.index;
    console.log('childIndex===', childIndex);
    this.rows.splice(childIndex, 1);
    /**if( this.rows.length > 1) {
        this.rows.splice(childIndex, 1);
    } else if( this.rows.length == 1) {
        this.rows = undefined;
        this.rows = [];
        this.rows.push({index : 0});
    } **/
    // if (this.rows.length > 1)
    //   this.rows.splice(event.target.value, 1);
  }

  saveData() {
    this.hasError = false;
    let recordsToSave = this.getNonSuppLines();
    if (!recordsToSave) {
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
      this.disableSubmit = true;
      this.showSuccessNotification('Records Submitted Successfully.');
      this.template.querySelector("c-mars-special-equipment-history").initData();
    });
  }

  getNonSuppLines() {
    let recordsToSave = [];
    for (let i = 0; i < this.rows.length; i++) {
      let row = this.template.querySelector('[data-id="' + i + '"]').getRecordDetails();
      if (row == undefined) {
        this.hasError = true;
      }
      delete row.index;
      if (!row.Revised_Rate__c || row.Revised_Rate__c <= 0) {
        this.showErrorNotification('Please enter a valid value for Equipment Rate');
        return;
      }
      recordsToSave.push(row);
    }
    return recordsToSave;
  }
  handleFutureDateChange(event) {
    this.futureDate = event.target.value;
    const futureDate = new Date(this.futureDate);
    var effectiveDate = new Date(this.oldRequestedEffectiveDate);
    //var effectiveDate = new Date(this.minDate);
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