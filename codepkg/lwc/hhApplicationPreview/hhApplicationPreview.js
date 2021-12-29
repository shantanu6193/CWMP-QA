/**
 * Created by StackNexus Admin on 03-09-2021.
 */

import { LightningElement, track, api,wire } from 'lwc';
import getApplicationData from '@salesforce/apex/HH_ApplicationPreviewCtrl.getApplicationPreviewDetails';
import Utility from 'c/utility';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import HH_EN_Is_Head_of_Household from'@salesforce/label/c.HH_EN_Is_Head_of_Household';
import HH_EN_Relationship_to_Homeowner from'@salesforce/label/c.HH_EN_Relationship_to_Homeowner';
import HH_EN_Date_of_Birth from '@salesforce/label/c.HH_EN_Date_of_Birth';
import HH_EN_Annual_Income from '@salesforce/label/c.HH_EN_Annual_Income';
import HH_EN_First_Name from '@salesforce/label/c.HH_EN_First_Name';
import HH_EN_Last_Name from '@salesforce/label/c.HH_EN_Last_Name';
import HH_EN_Action from '@salesforce/label/c.HH_EN_Action';
import HH_EN_Date_Funding_Received from '@salesforce/label/c.HH_EN_Date_Funding_Received';
import HH_EN_Program_Name from '@salesforce/label/c.HH_EN_Program_Name';
import HH_EN_Other_Program_Name from '@salesforce/label/c.HH_EN_Other_Program_Name';
import HH_EN_Upload_Date from '@salesforce/label/c.HH_EN_Upload_Date';
import HH_EN_Document_Type from '@salesforce/label/c.HH_EN_Document_Type';
import HH_EN_File_Name from '@salesforce/label/c.HH_EN_File_Name';
import HH_EN_Version from '@salesforce/label/c.HH_EN_Version';
import HH_EN_Stage from '@salesforce/label/c.HH_EN_Stage';
import HH_EN_Click_to_preview from '@salesforce/label/c.HH_EN_Click_to_preview';
import HH_EN_UniqueHouseholdNumber from '@salesforce/label/c.HH_EN_UniqueHouseholdNumber';
import HH_EN_IsPhysicalAddressForeignAddress from '@salesforce/label/c.HH_EN_IsPhysicalAddressForeignAddress';
import HH_EN_PhysicalAddressStreet from '@salesforce/label/c.HH_EN_PhysicalAddressStreet';
import HH_EN_PhysicalAddressCity from '@salesforce/label/c.HH_EN_PhysicalAddressCity';
import HH_EN_PhysicalAddressState from '@salesforce/label/c.HH_EN_PhysicalAddressState';
import HH_EN_PhysicalAddressZip_PostalCode from '@salesforce/label/c.HH_EN_PhysicalAddressZip_PostalCode';
import HH_EN_PhysicalAddressCountry from '@salesforce/label/c.HH_EN_PhysicalAddressCountry';
import HH_EN_IsMailingAddressForeignAddress from '@salesforce/label/c.HH_EN_IsMailingAddressForeignAddress';
import HH_EN_IsMailingAddressDifferentFromPhysical from '@salesforce/label/c.HH_EN_IsMailingAddressDifferentFromPhysical';
import HH_EN_MailingAddressCity from '@salesforce/label/c.HH_EN_MailingAddressCity';
import HH_EN_MailingAddressState from '@salesforce/label/c.HH_EN_MailingAddressState';
import HH_EN_MailingAddressMailingZip_PostalCode from '@salesforce/label/c.HH_EN_MailingAddressMailingZip_PostalCode';
import HH_EN_MailingAddressCountry from '@salesforce/label/c.HH_EN_MailingAddressCountry';
import HH_EN_EmailAddress from '@salesforce/label/c.HH_EN_EmailAddress';
import HH_EN_PrimaryPhone from '@salesforce/label/c.HH_EN_PrimaryPhone';
import HH_EN_SecondaryPhone from '@salesforce/label/c.HH_EN_SecondaryPhone';
import HH_EN_MailingAddressStreet from '@salesforce/label/c.HH_EN_MailingAddressStreet';
import HH_EN_EnglishLanguageProficiency from '@salesforce/label/c.HH_EN_EnglishLanguageProficiency';
import HH_EN_PreferredLanguage from '@salesforce/label/c.HH_EN_PreferredLanguage';
import HH_EN_Applicant_Information_Page_Title from '@salesforce/label/c.HH_EN_Applicant_Information_Page_Title';
import HH_EN_Property_Owner from '@salesforce/label/c.HH_EN_Property_Owner';
import HH_EN_Primary_Residence from '@salesforce/label/c.HH_EN_Primary_Residence';
import HH_EN_Rental_Property from '@salesforce/label/c.HH_EN_Rental_Property';
import HH_EN_Currently_Occupied from '@salesforce/label/c.HH_EN_Currently_Occupied';
import HH_EN_Car_Ownership from '@salesforce/label/c.HH_EN_Car_Ownership';
import HH_EN_Is_Anyone_65 from '@salesforce/label/c.HH_EN_Is_Anyone_65';
import HH_EN_Is_Anyone_Age_5_and_Under from '@salesforce/label/c.HH_EN_Is_Anyone_Age_5_and_Under';
import HH_EN_Anyone_Not_a_Proficient_English_Speaker from '@salesforce/label/c.HH_EN_Anyone_Not_a_Proficient_English_Speaker';
import HH_EN_Ethnicities_of_Household_Members from '@salesforce/label/c.HH_EN_Ethnicities_of_Household_Members';
import HH_EN_Is_Anyone_has_Disabilities from '@salesforce/label/c.HH_EN_Is_Anyone_has_Disabilities';
import HH_EN_Household_members from '@salesforce/label/c.HH_EN_Household_members';
import HH_EN_Eligibility_Information_Page_Title from '@salesforce/label/c.HH_EN_Eligibility_Information_Page_Title';
import HH_EN_Residence_Information from '@salesforce/label/c.HH_EN_Residence_Information';
import HH_EN_Property_Structure from '@salesforce/label/c.HH_EN_Property_Structure';
import HH_EN_Property_Street_Address from '@salesforce/label/c.HH_EN_Property_Street_Address';
import HH_EN_Property_City from '@salesforce/label/c.HH_EN_Property_City';
import HH_EN_Property_State from '@salesforce/label/c.HH_EN_Property_State';
import HH_EN_Property_Zip from '@salesforce/label/c.HH_EN_Property_Zip';
import HH_EN_Property_Count from '@salesforce/label/c.HH_EN_Property_Count';
import HH_EN_Year_of_construction from '@salesforce/label/c.HH_EN_Year_of_construction';
import HH_EN_Authority_to_make_updates_to_the_Home from '@salesforce/label/c.HH_EN_Authority_to_make_updates_to_the_Home';
import HH_EN_Total_Living_Area from '@salesforce/label/c.HH_EN_Total_Living_Area';
import HH_EN_Number_of_Stories from '@salesforce/label/c.HH_EN_Number_of_Stories';
import HH_EN_Accessible_by_a_Passenger_Vehicle from '@salesforce/label/c.HH_EN_Accessible_by_a_Passenger_Vehicle';
import HH_EN_Is_National_Register_of_Historic_Places from '@salesforce/label/c.HH_EN_Is_National_Register_of_Historic_Places';
import HH_EN_Any_Other_Names_on_the_Property_Deed from '@salesforce/label/c.HH_EN_Any_Other_Names_on_the_Property_Deed';
import HH_EN_Property_Foreclosed_or_in_Foreclosure from '@salesforce/label/c.HH_EN_Property_Foreclosed_or_in_Foreclosure';
import HH_EN_Property_Liens from '@salesforce/label/c.HH_EN_Property_Liens';
import HH_EN_Good_Standing_on_Property_Taxes from '@salesforce/label/c.HH_EN_Good_Standing_on_Property_Taxes';
import HH_EN_Assessed_Value_of_the_Property from '@salesforce/label/c.HH_EN_Assessed_Value_of_the_Property';
import HH_EN_Property_Currently_Damaged from '@salesforce/label/c.HH_EN_Property_Currently_Damaged';
import HH_EN_Describe_the_damages from '@salesforce/label/c.HH_EN_Describe_the_damages';
import HH_EN_Measures_to_Reduce_Wildfire_Damage_Risk from '@salesforce/label/c.HH_EN_Measures_to_Reduce_Wildfire_Damage_Risk';
import HH_EN_List_of_Measures from '@salesforce/label/c.HH_EN_List_of_Measures';
import HH_EN_Assistance_for_Home_s_risk_to_wildfire from '@salesforce/label/c.HH_EN_Assistance_for_Home_s_risk_to_wildfire';
import HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION from '@salesforce/label/c.HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION';
import HH_EN_Co_Owners from '@salesforce/label/c.HH_EN_Co_Owners';
import HH_EN_Past_Funding_Received from '@salesforce/label/c.HH_EN_Past_Funding_Received';
import HH_EN_House_Hold_Members from '@salesforce/label/c.HH_EN_House_Hold_Members';
import HH_Community_BaseURL from '@salesforce/label/c.HH_Community_BaseURL';
import HH_EN_Exit from '@salesforce/label/c.HH_EN_Exit';
import HH_EN_Edit from '@salesforce/label/c.HH_EN_Edit';
import HH_EN_Yes from '@salesforce/label/c.HH_EN_Yes';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import HH_EN_Other_Comments from '@salesforce/label/c.HH_EN_Other_Comments';
import HH_EN_Assistance_for_Home_s_risk_to_wildfirefrom from '@salesforce/label/c.HH_EN_Assistance_for_Home_s_risk_to_wildfire';
import HH_EN_assistance_and_approximately_when from '@salesforce/label/c.HH_EN_assistance_and_approximately_when';
import HH_EN_any_assistance_from_any_program from '@salesforce/label/c.HH_EN_any_assistance_from_any_program';

import editDetails from '@salesforce/apex/HH_EditRequestCtrl.getInitData';
export default class HhApplicationPreview extends Utility {

    @track label = {
        HH_EN_Is_Head_of_Household,
        HH_EN_Relationship_to_Homeowner,
        HH_EN_Date_of_Birth,
        HH_EN_Annual_Income,
        HH_EN_First_Name,
        HH_EN_Last_Name,
        HH_EN_Action,
        HH_EN_Date_Funding_Received,
        HH_EN_Program_Name,
        HH_EN_Other_Program_Name,
        HH_EN_Upload_Date,
        HH_EN_Document_Type,
        HH_EN_File_Name,
        HH_EN_Version,
        HH_EN_Stage,
        HH_EN_Click_to_preview,
        HH_EN_UniqueHouseholdNumber,
        HH_EN_IsMailingAddressDifferentFromPhysical,
        HH_EN_IsPhysicalAddressForeignAddress,
        HH_EN_PhysicalAddressStreet,
        HH_EN_PhysicalAddressCity,
        HH_EN_PhysicalAddressState,
        HH_EN_PhysicalAddressZip_PostalCode,
        HH_EN_PhysicalAddressCountry,
        HH_EN_IsMailingAddressForeignAddress,
        HH_EN_MailingAddressCity,
        HH_EN_MailingAddressState,
        HH_EN_MailingAddressMailingZip_PostalCode,
        HH_EN_MailingAddressCountry,
        HH_EN_EmailAddress,
        HH_EN_PrimaryPhone,
        HH_EN_SecondaryPhone,
        HH_EN_MailingAddressStreet,
        HH_EN_EnglishLanguageProficiency,
        HH_EN_PreferredLanguage,
        HH_EN_Applicant_Information_Page_Title,
        HH_EN_Property_Owner,
        HH_EN_Primary_Residence,
        HH_EN_Rental_Property,
        HH_EN_Currently_Occupied,
        HH_EN_Car_Ownership,
        HH_EN_Is_Anyone_65,
        HH_EN_Is_Anyone_Age_5_and_Under,
        HH_EN_Anyone_Not_a_Proficient_English_Speaker,
        HH_EN_Ethnicities_of_Household_Members,
        HH_EN_Is_Anyone_has_Disabilities,
        HH_EN_Household_members,
        HH_EN_Eligibility_Information_Page_Title,
        HH_EN_Residence_Information,
        HH_EN_Property_Structure,
        HH_EN_Property_Street_Address,
        HH_EN_Property_City,
        HH_EN_Property_State,
        HH_EN_Property_Zip,
        HH_EN_Property_Count,
        HH_EN_Year_of_construction,
        HH_EN_Authority_to_make_updates_to_the_Home,
        HH_EN_Total_Living_Area,
        HH_EN_Number_of_Stories,
        HH_EN_Accessible_by_a_Passenger_Vehicle,
        HH_EN_Is_National_Register_of_Historic_Places,
        HH_EN_Any_Other_Names_on_the_Property_Deed,
        HH_EN_Property_Foreclosed_or_in_Foreclosure,
        HH_EN_Property_Liens,
        HH_EN_Good_Standing_on_Property_Taxes,
        HH_EN_Assessed_Value_of_the_Property,
        HH_EN_Property_Currently_Damaged,
        HH_EN_Describe_the_damages,
        HH_EN_Measures_to_Reduce_Wildfire_Damage_Risk,
        HH_EN_List_of_Measures,
        HH_EN_Assistance_for_Home_s_risk_to_wildfire,
        HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION,
        HH_EN_Co_Owners,
        HH_EN_Past_Funding_Received,
        HH_EN_House_Hold_Members,
        HH_Community_BaseURL,
        HH_EN_Exit,
        HH_EN_Edit,
        HH_EN_Yes,
        HH_EN_Other_Comments,
        HH_EN_Assistance_for_Home_s_risk_to_wildfirefrom,
        HH_EN_any_assistance_from_any_program,
        HH_EN_assistance_and_approximately_when
    }

    @api recordId;
    @track recordLocal;
    @track record;
    @track language = 'en_US';
    @track isEdit=false;
    @track previewData = {};

    isExternalUser;
    showLoader = false;
    @api isPartOfStage = false;

    get showHouseHoldTable() {

    }

    get showCoOwnerTable() {
        if(this.previewData != undefined && this.previewData.Any_Other_Names_on_the_Property_Deed__c != undefined && (this.previewData.Any_Other_Names_on_the_Property_Deed__c == 'Yes' || this.previewData.Any_Other_Names_on_the_Property_Deed__c == this.label.HH_EN_Yes)) {
            return true;
        }
        return false;
    }

    get showPastFundingRecievedTable() {
        if(this.previewData != undefined && this.previewData.Assistance_to_reduce_yo__c != undefined && (this.previewData.Assistance_to_reduce_yo__c == 'Yes' || this.previewData.Assistance_to_reduce_yo__c == this.label.HH_EN_Yes)) {
            return true;
        }
        return false;
    }


    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state ) {
            if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
            }
            if(currentPageReference.state.c__id) {
                this.recordId = currentPageReference.state.c__id;
            }
            if(currentPageReference.state.language) {
                this.language = currentPageReference.state.language;
            }
            if(currentPageReference.state.c__language) {
                this.language = currentPageReference.state.c__language;
            }
            this.retrieveData();
        } 
    }

    retrieveData(){
            this.showLoader = true;
            getApplicationData({
                applicationId: this.recordId
            })
            .then(result => {
                this.previewData = result.applicationPreview;
                this.previewData['contacts'] = result.appContactsPreview;
                this.previewData['deedContacts'] = result.deedContactsPreview;
                //this.previewData['fundedPrograms'] = result.fundedProgramsPreview;
                this.previewData['documents'] = result.documentsPreview;
                this.isExternalUser = result.isExternalUser;
                this.showLoader = false;
                this.handleEdit();

            })
            .catch(error => {
                console.log('Error', error);
                alert(error);
                this.showLoader = false;
            });
        }

    handlePreviewDocument(event){
        console.log('Select event Type1-- '+event.target.getAttribute("data-documentid"));
        //window.open('/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+event.target.getAttribute("data-versionid"), '_blank');
        window.open('/sfc/servlet.shepherd/document/download/'+event.target.getAttribute("data-documentid"), '_blank');
   }

    handleExit() {
        if(this.recordId != undefined || this.recordId != null) {
            this.dispatchCloseEvent();
            this.navigateRecordViewPage(this.recordId);
        } else {
            this.dispatchCloseEvent();
            this.navigateToObjectListView('HH_Application__c');
        }
    }

   get isFirefox(){
       if(navigator.userAgent.indexOf("Firefox") != -1){
          return true;
       }else{
           return false;
       }
   }

    handleEdit(){
        editDetails({
            appId:this.recordId
       })
        .then(result => {
            this.isEdit = result.isEdit;
        })
        .catch(error => {
             this.errorToast('Error..'+error);
        });
    }
	errorToast(mes) {
		const event = new ShowToastEvent({
			title: 'Error',
			message:mes ,
			variant: 'error',
			mode: 'dismissible' //pester
		});
		this.dispatchEvent(event);
	}
    redirectEdit(){
        if(this.isExternalUser) {
            this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId, 'currentStage' : 'ApplicantInfo'});
        } else {
            this.dispatchCloseEvent();
            let state = {};
            state['c__id'] = this.recordId;
            state['c__currentStage'] = 'ApplicantInfo';
            this.navigateToComponent('c__HH_Application',state);
          //  this.redirectToTabPage('HH_Application_Form',{'c__id' : this.recordId, 'c__currentStage' : 'ApplicantInfo'})
        }
        // let url = this.label.HH_Community_BaseURL+'hh-application?id=' +this.recordId+'&currentStage=ApplicantInfo';
        // console.log('url -- '+url);
        // window.location.href = url;
        }
        
      /*
    * Notifies parent component when close clicked
    */
      dispatchCloseEvent() {
        let close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         this.dispatchEvent(closeclickedevt);
    }

}