import {
  LightningElement,
  api,
  track,
  wire
} from 'lwc';
import retrivePrograms from '@salesforce/apex/MARS_AdministrativeRateCtrl.retrivePrograms';
import createLineItems from '@salesforce/apex/MARS_AdministrativeRateCtrl.createLineItems';
import Utility from 'c/utility';
import {
  refreshApex
} from '@salesforce/apex';

export default class AdministrativeRateInfoScreen extends Utility {
  @api objectName = 'Salary_Survey_Line_Items__c';
  @api fieldSetName = 'Administrative_Screen_Field_Set';
  forRefresh;
  @track data = [];
  @track error;
  @api recordId;
  isModalOpen = false;
  fyLow;
  fyHigh;
  inUseDate;
  totalIndirectAmount = 0;
  totalDirectAmount = 0;
  totalAmount = 0;
  totalDividend = 0;
  futureDate;
  minDate;
  parentRecord;
  hasError;
  disableSubmit = false;
  oldRequestedEffectiveDate

  @wire(retrivePrograms, {
    accountId: '$recordId'
  }) 
  resultFunction(result) {
    this.showLoader = true;
    this.forRefresh = result;
    if (result.data) {
      this.showLoader = false;
      this.parentRecord = result.data.objParentForDate;
      let todayDate = this.todayDateInYYYYMMDD();
      if (this.parentRecord != undefined && this.parentRecord.Start_Date__c != undefined && new Date(this.parentRecord.Start_Date__c) >= new Date(todayDate)) {
        this.oldRequestedEffectiveDate = this.parentRecord.Start_Date__c;
        var effectiveDate = new Date(this.oldRequestedEffectiveDate);
        this.minDate = new Date(effectiveDate).toISOString();
        effectiveDate.setDate(effectiveDate.getDate() + 1);
        this.futureDate = effectiveDate.toISOString();
      } else {
        this.minDate = todayDate;
        this.futureDate = todayDate;
      }
      this.data = result.data.lstDatatable;
      //this.disableSubmit = result.data.disableSubmit;
      if(this.parentRecord.Approval_Status__c == 'Pending Review') {
        this.disableSubmit = true;
      }
      /*this.data.forEach(element => {
        if (element.direct) {
          this.totalDirectAmount += Number(element.direct);
        }
        if (element.indirect) {
          this.totalIndirectAmount += Number(element.indirect);
        }
        if (element.total) {
          this.totalAmount += Number(element.total);
        }
      })*/
    } else if (result.error) {
      this.showLoader = false;
      console.log('###: error: ' + JSON.stringify(result.error))
    }
  }
  createRecords(event) {
    if (this.validateInputs() == false) return;
    /*if ((this.fyHigh && this.inUseDate) && (Number(this.fyHigh) >= Number(this.inUseDate))) {
      this.showErrorNotification('Current Fiscal Year cannot be less than or the same as start and end Fiscal Year');
      return;
    }
    if ((this.fyLow && this.fyHigh) && (Number(this.fyLow) > Number(this.fyHigh))) {
      this.showErrorNotification('End Fiscal Year cannot be less than the start Fiscal Year');
      return;
    }*/
    this.hasError = false;
    this.getAdminRateLines();
    if (this.hasError == true) return;
    let signatureBlob = this.template.querySelector('[data-id="signature"]').getSignatureBlob();
    if (signatureBlob == undefined) {
      this.showErrorNotification('Please sign form');
      this.template.querySelector('[data-id="signature"]').refreshCanvas();
      return;
    }
    if (!this.futureDate || (this.futureDate < this.minDate)) {
      this.showErrorNotification('Please select a future date');
      return;
    }
    this.showLoader = true;
    let wrapperObj = [];
    for (let i = 0; i < this.data.length; i++) {
      let rowElements = this.template.querySelectorAll(`c-mars-administrative-rate-info-screen-row[data-id="${i}"]`);
      let indirectAmount = 0;
      let directAmount = 0;
      let totalAmount = 0;
      rowElements.forEach(element => {
        const tableRow = element.getRecordDetails();
        if (tableRow.Total__c != undefined) {
          totalAmount = tableRow.Total__c;
        }
        if (tableRow.Indirect__c != undefined) {
          indirectAmount = tableRow.Indirect__c;
        }
        if (tableRow.Direct__c != undefined) {
          directAmount = tableRow.Direct__c;
        }

      });
      let obj = {
        'Name': this.data[i].program,
        'Direct__c': directAmount,
        Indirect__c: indirectAmount,
        Total__c: totalAmount
      };
      if (this.data[i].lineItemId) {
        obj.Id = this.data[i].lineItemId;
      }
      wrapperObj.push(obj);
    }
    let objParentData = {
      FY_From__c: this.fyLow,
      FY_To__c: this.fyHigh,
      Data_For_Use_In__c: this.inUseDate,
      Administrative_Total_Indirect_Direct__c: this.totalAmount,
      Administrative_Rate_Indirect_Cost_Direct__c: this.totalDividend,
      Total_Direct_Amount__c: this.totalDirectAmount,
      Total_Indirect_Amount__c: this.totalIndirectAmount
    };
    this.executeAction(createLineItems, {
      lineItemsString: JSON.stringify(wrapperObj),
      accountId: this.recordId,
      effectiveDate: this.futureDate,
      signatureBlob: signatureBlob,
      objParentData: JSON.stringify(objParentData)
    }, (response) => {
      this.disableSubmit = true;
      this.totalIndirectAmount = 0;
      this.totalDirectAmount = 0;
      this.totalAmount = 0;
      this.totalDividend = 0;
      this.showSuccessNotification('Records Submitted Successfully.');
      //this.template.querySelector("c-mars-administrative-rate-history").initData();
    });
  }

  handleLowFYChange(event) {
    this.fyLow = event.detail.value;
    this.fyHigh = Number(this.fyLow) + 1;
  }

  handleInUseChange(event) {
    const fieldVal = this.validateCurrentYearField(event.detail.value);
    if (!fieldVal) {
      return;
    } else {
      this.inUseDate = event.detail.value;
    }

  }
  validateCurrentYearField(currenYearValue) {
    let currenYearCmp = this.template.querySelector(".dataforuseincmp");
    let maxValue = Number(this.fyHigh) + 2;
    if (Number(currenYearValue) > Number(maxValue)) {
      currenYearCmp.setCustomValidity("This field value can't more than 2 years of " + this.fyHigh);
      currenYearCmp.reportValidity();
      return false;
    } else if (Number(currenYearValue) <= Number(this.fyHigh)) {
      currenYearCmp.setCustomValidity("This field value must be greater than " + this.fyHigh);
      currenYearCmp.reportValidity();
      return false;
    } else {
      currenYearCmp.setCustomValidity("");
      currenYearCmp.reportValidity();
      return true;
    }
  }
  handleFutureDateChange(event) {
    this.futureDate = event.target.value;
    const futureDate = new Date(this.futureDate);
    var effectiveDate = new Date(this.oldRequestedEffectiveDate);
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
  getFormattedDate(date) {
    var year = date.getFullYear();

    var month = (1 + date.getMonth()).toString();
    month = month.length > 1 ? month : '0' + month;

    var day = date.getDate().toString();
    day = day.length > 1 ? day : '0' + day;

    return year + '-' + month + '-' + day;
  }

  handleTotalCalculation(event) {
    let rowElements = this.template.querySelectorAll('c-mars-administrative-rate-info-screen-row');
    let indirectAmount = 0;
    let directAmount = 0;
    let totalAmount = 0;
    rowElements.forEach(element => {
      const tableRow = element.getRecordDetails();
      if (tableRow != undefined) {
        if (tableRow.Total__c != undefined) {
          totalAmount = totalAmount + Number(tableRow.Total__c);
        }
        if (tableRow.Indirect__c != undefined) {
          indirectAmount = indirectAmount + Number(tableRow.Indirect__c);
        }
        if (tableRow.Direct__c != undefined) {
          directAmount = directAmount + Number(tableRow.Direct__c);
        }
      }
    });
    this.totalIndirectAmount = indirectAmount;
    this.totalDirectAmount = directAmount;
    this.totalAmount = totalAmount;
    const dividend = this.totalIndirectAmount / this.totalDirectAmount;
    if (dividend != Infinity) {
      this.totalDividend = dividend.toFixed(5);
    }
  }

  getAdminRateLines() {
    let recordsToSave = [];
    for (let i = 0; i < this.data.length; i++) {
      let adminRate = this.template.querySelector('[data-id="' + i + '"]').getRecordDetails();
      if (adminRate == undefined) {
        this.hasError = true;
      }
      recordsToSave.push(adminRate);
    }
    return recordsToSave;
  }
  get checkSubmitDisable() {
    if (this.disableSubmit) {
      return true;
    } else {
      return false;
    }
  }
}