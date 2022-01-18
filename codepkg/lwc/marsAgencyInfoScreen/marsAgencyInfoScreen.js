import {
  LightningElement,
  wire,
  api,
  track
} from 'lwc';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import getAccountDetails from '@salesforce/apex/MARS_AgencyScreenCtrl.getAccountDetails';
import saveAccount from '@salesforce/apex/MARS_AgencyScreenCtrl.saveAccount';
import inviteUsersToAgency from '@salesforce/apex/MARS_AgencyScreenCtrl.inviteUsersToAgency';
import Utility from 'c/utility';
import {
  NavigationMixin
} from 'lightning/navigation';
import {
  refreshApex
} from '@salesforce/apex';
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";

const picklistOptions = [{
    label: 'Yes',
    value: 'Yes'
  },
  {
    label: 'No',
    value: 'No'
  }
];
const fieldsMap = {
  'agencyName': 'Name',
  'chiefsName': 'Chief_Name__c',
  'macsId': 'MACS_ID__c',
  'chiefsEmailAddress': 'Chief_Email__c',
  'deptCity': 'Department_City__c',
  'departmentEmailAddress': 'Department_Email__c',
  'deptState': 'Department_State__c',
  'telephoneNumber': 'Phone',
  'physicalAddress': 'BillingStreet',
  'physicalAddressCity': 'BillingCity',
  'physicalAddressState': 'BillingState',
  'physicalAddressZipCode': 'BillingPostalCode',
  'mailingAddress': 'ShippingStreet',
  'mailingCity': 'ShippingCity',
  'mailingState': 'ShippingState',
  'mailingZipCode': 'ShippingPostalCode',
  'federallyRecognizedTribe': 'Federally_Recognized_Tribe__c',
  'federalFireDepartment': 'Federal_Fire_Department__c',
  'departmentOfDefence': 'Department_of_Defence__c',
  'volunteerComboFireDepartment': 'Volunteer__c',
  'taxPayerIdFEIN': 'Federal_Tax_ID__c',
  'dunsNumber': 'DUNS__c',
  'fiscalAddreddId': 'Fiscal_Address_Id__c',
  'activeAgency': 'MARS_Is_Active__c',
  'responder': 'MARS_IsResponder__c',
  'agencyType': 'Mars_Agency_Type__c',
  'combination': 'MARS_Combination__c',
  'other': 'MARS_Agency_Type_Other__c',
  'otherType': 'MARS_Other_Type__c',
  'agencyPaid': 'MARS_Paid__c',
  'fiscalSupplierId': 'Fiscal_Supplier_ID__c',
  'region': 'MARS_Region__c',
  'operationalarea': 'MARS_Operational_Area__c'
};
export default class EntityTypeAgencySignUpLwc extends Utility {
  federallyRecognizedTribeValue = 'no';
  federalFireDepartmentValue = 'no';
  departmentOfDefenceValue = 'no';
  volunteerComboFireDepartmentValue = 'no';
  stateValue = '-';
  pickListvaluesByRecordType;
  get departmentOfDefenceOptions() {
    return picklistOptions;
  }
  get federallyRecognizedTribeOptions() {
    return picklistOptions;
  }
  get federalFireDepartmentOptions() {
    return picklistOptions;
  }
  get volunteerComboFireDepartmentOptions() {
    return picklistOptions;
  }
  get activeAgencyOptions() {
    return picklistOptions;
  }
  get responderOptions() {
    return picklistOptions;
  }
  @api
  recordId;
  _accountRecord = {};
  @track isEditable;
  @track error;
  @track isInviteUsersModalOpen = false;
  @track isOtherVisible = false;
  listEmails;
  urlInvite = '';
  controllingValues = [];
  dependentValue;
  @track finalDependentVal = [];
  @track selectedControlling = "--None--";
  renderInputs = true;
  showpicklist = false;
  dependentDisabled = true;
  showdependent = false;

  closeInviteUsersModal(event) {
    this.isInviteUsersModalOpen = false;
  }


  handleInviteUsers() {
    this.isInviteUsersModalOpen = true;
  }

  submitEmailDetails() {

    if (this.listEmails == undefined) {
      this.showErrorNotification('Please enter email address');
      return;
    } else if (this.listEmails != undefined) {
      let regExpEmailformat = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
      let emailArray = this.listEmails.split(',');
      for (let i = 0; i < emailArray.length; i++) {
        //let emailval=emailArray[i];
        //let removeSpaces=trim(emailval);
        if (!regExpEmailformat.test(emailArray[i].trim())) {
          this.showErrorNotification('Please enter valid email address');
          return;
        }
      }
    }
    inviteUsersToAgency({
        emails: this.listEmails,
        accessagencylink: this.urlInvite,
        agencyname: this.existingAccountRecord.Name

      })
      .then(result => {
        this.isInviteUsersModalOpen = false;
        this.showSuccessNotification('Invitation link sent to users!');

        /*this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: 'Invitation link sent to users!',
            variant: "success"
          })
        );*/

      })
      .catch(error => {
        this.showErrorNotification('Error sending invitation link');
        /*this.dispatchEvent(
          new ShowToastEvent({
            title: "Error sending invitation link",
            message: error.body.message,
            variant: "error"
          })
        );*/

        this.error = error;
      });




  }

  handleCopy(component, event, helper) {

    //var text = component.find('copyMe').getElement().innerHTML;
    // calling common helper class to copy selected text value

    var hiddenInput = document.createElement("input");
    hiddenInput.setAttribute("value", this.urlInvite);
    document.body.appendChild(hiddenInput);
    hiddenInput.select();
    document.execCommand("copy");

    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: 'Invitation link copied!',
        variant: "success"
      })
    );

  }

  handleChange(event) {
    var value;
    value = event.target.value;
    if (event.target.dataset.id === 'emailsfield') {
      this.listEmails = value;
    }
  }

  get existingAccountRecord() {
    console.log('this.account record from here: ' + JSON.stringify(this._accountRecord));
    return this._accountRecord;
  }
  connectedCallback() {
    getAccountDetails({
      accId: this.recordId
    }).then(
      result => {
        this._accountRecord = JSON.parse(result.accountRec);
        this._accountRecord.Phone = this.getFormatedPhoneNumber(this._accountRecord.Phone);
        this.createURLlink();
        this.isEditable = result.isTableEditable;
        console.log('###: this._accountRecord : ' + JSON.stringify(this._accountRecord))
        console.log('###: this.isEditable: ' + JSON.stringify(this.isEditable))
      }
    )
  }

  createURLlink() {

    var test = location.origin;
    console.log(test);
    this.urlInvite = test + '/s/cal-sign-up?agency=' + this._accountRecord.Name + '&type=' + this._accountRecord.Entity_Type__c + '&accountid=' + this._accountRecord.Id;

  }


  get agencyTypeOptions() {
    return [{
        "label": "Paid",
        "value": "Paid"
      },
      {
        "label": "Volunteer",
        "value": "Volunteer"
      },
      {
        "label": "Combination",
        "value": "Combination"
      },
      {
        "label": "Tribal",
        "value": "Tribal"
      },
      {
        "label": "Department of Defense",
        "value": "Department of Defense"
      },
      {
        "label": "Federal",
        "value": "Federal"
      },
      {
        "label": "Other",
        "value": "Other"
      }
    ]
  }

  get states() {
    return [{
        "label": "Alabama",
        "value": "AL"
      },
      {
        "label": "Alaska",
        "value": "AK"
      },
      {
        "label": "American Samoa",
        "value": "AS"
      },
      {
        "label": "Arizona",
        "value": "AZ"
      },
      {
        "label": "Arkansas",
        "value": "AR"
      },
      {
        "label": "California",
        "value": "CA"
      },
      {
        "label": "Colorado",
        "value": "CO"
      },
      {
        "label": "Connecticut",
        "value": "CT"
      },
      {
        "label": "Delaware",
        "value": "DE"
      },
      {
        "label": "District Of Columbia",
        "value": "DC"
      },
      {
        "label": "Federated States Of Micronesia",
        "value": "FM"
      },
      {
        "label": "Florida",
        "value": "FL"
      },
      {
        "label": "Georgia",
        "value": "GA"
      },
      {
        "label": "Guam",
        "value": "GU"
      },
      {
        "label": "Hawaii",
        "value": "HI"
      },
      {
        "label": "Idaho",
        "value": "ID"
      },
      {
        "label": "Illinois",
        "value": "IL"
      },
      {
        "label": "Indiana",
        "value": "IN"
      },
      {
        "label": "Iowa",
        "value": "IA"
      },
      {
        "label": "Kansas",
        "value": "KS"
      },
      {
        "label": "Kentucky",
        "value": "KY"
      },
      {
        "label": "Louisiana",
        "value": "LA"
      },
      {
        "label": "Maine",
        "value": "ME"
      },
      {
        "label": "Marshall Islands",
        "value": "MH"
      },
      {
        "label": "Maryland",
        "value": "MD"
      },
      {
        "label": "Massachusetts",
        "value": "MA"
      },
      {
        "label": "Michigan",
        "value": "MI"
      },
      {
        "label": "Minnesota",
        "value": "MN"
      },
      {
        "label": "Mississippi",
        "value": "MS"
      },
      {
        "label": "Missouri",
        "value": "MO"
      },
      {
        "label": "Montana",
        "value": "MT"
      },
      {
        "label": "Nebraska",
        "value": "NE"
      },
      {
        "label": "Nevada",
        "value": "NV"
      },
      {
        "label": "New Hampshire",
        "value": "NH"
      },
      {
        "label": "New Jersey",
        "value": "NJ"
      },
      {
        "label": "New Mexico",
        "value": "NM"
      },
      {
        "label": "New York",
        "value": "NY"
      },
      {
        "label": "North Carolina",
        "value": "NC"
      },
      {
        "label": "North Dakota",
        "value": "ND"
      },
      {
        "label": "Northern Mariana Islands",
        "value": "MP"
      },
      {
        "label": "Ohio",
        "value": "OH"
      },
      {
        "label": "Oklahoma",
        "value": "OK"
      },
      {
        "label": "Oregon",
        "value": "OR"
      },
      {
        "label": "Palau",
        "value": "PW"
      },
      {
        "label": "Pennsylvania",
        "value": "PA"
      },
      {
        "label": "Puerto Rico",
        "value": "PR"
      },
      {
        "label": "Rhode Island",
        "value": "RI"
      },
      {
        "label": "South Carolina",
        "value": "SC"
      },
      {
        "label": "South Dakota",
        "value": "SD"
      },
      {
        "label": "Tennessee",
        "value": "TN"
      },
      {
        "label": "Texas",
        "value": "TX"
      },
      {
        "label": "Utah",
        "value": "UT"
      },
      {
        "label": "Vermont",
        "value": "VT"
      },
      {
        "label": "Virgin Islands",
        "value": "VI"
      },
      {
        "label": "Virginia",
        "value": "VA"
      },
      {
        "label": "Washington",
        "value": "WA"
      },
      {
        "label": "West Virginia",
        "value": "WV"
      },
      {
        "label": "Wisconsin",
        "value": "WI"
      },
      {
        "label": "Wyoming",
        "value": "WY"
      }
    ]
  }
  handleSave() {
    let recordToSave = {};
    console.log()
    this.template.querySelectorAll('[data-id="accountForm"]').forEach(eachElement => {
      console.log('validity: ' + eachElement.reportValidity());
      recordToSave[fieldsMap[eachElement.name]] = eachElement.value;
    })
    console.log('###: recordToSave: ' + recordToSave);
    if (this.existingAccountRecord.Id) {
      recordToSave.Id = this.existingAccountRecord.Id;
    }
    if (recordToSave.MARS_Agency_Type_Other__c == 'No') {
      recordToSave.MARS_Other_Type__c = '';
    }
    console.log('###: recordToSave: ' + JSON.stringify(recordToSave))
    if (!recordToSave.MARS_Region__c || !recordToSave.MARS_Operational_Area__c) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: 'Region and Operational Area are mandatory',
          variant: "error"
        })
      );
      return;
    }
    saveAccount({
      accountStr: JSON.stringify(recordToSave)
    }).then(result => {
      console.log(result);
      if (result) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: 'Agency updated successfully',
            variant: "success"
          })
        );
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: 'Agency update failed',
            variant: "error"
          })
        );
      }
    }).catch(error => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error updating record",
          message: error.body.message,
          variant: "error"
        })
      );
    });
  }
  formatPhone(event) {
    let number = event.detail.value;
    if(number.length == 10) {
      this.renderInputs = false;
      this.existingAccountRecord.Phone = this.getFormatedPhoneNumber(number); 
      this.renderInputs = true; 
    }
  }
  getFormatedPhoneNumber(number) {
    let cleanedNumber = ('' + number).replace(/\D/g, '');
    let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
    let newNumber = '';
    if (phoneNumber) {
      newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
      return newNumber;
    }
    return number;
  }

  handlePrint(event){
    console.log('this.recordId');
    console.log(this.recordId);
    event.preventDefault();
    if (this.recordId){
      window.open('/mars/apex/MARS_AgencyInformationPDF?id=' + this.recordId);
    }    
  }
  /* setOtherVisible(value) {
     if (value === 'Yes') {
       this.isOtherVisible = true;
     } else {
       this.isOtherVisible = false;
       this.existingAccountRecord.MARS_Other_Type__c = '';
     }
   }

   handleOtherChange(event) {
     this.setOtherVisible(event.target.value);
   }*/
}