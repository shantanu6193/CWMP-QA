import { LightningElement, api,wire } from 'lwc';
import getOrderData from '@salesforce/apex/PHOS_Order_EditCtrl.getOrderData';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import PRIORITY_OF_REQUEST_FIELD from '@salesforce/schema/Order__c.Priority_for_Requests__c';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import Utility from 'c/utility';
export default class PhosOrderPrintPreview extends Utility {
    typeOfOrder='';
    recordId;
    priorityLabel='';
    priorityList;
    showModal = false;
    confirmCompliance;

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PRIORITY_OF_REQUEST_FIELD
    })
    priorityRequestPicklistValues({data,error}){
        if(data){
            this.priorityList = data.values;
         } else if(error){
            console.log('Error--->',error);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        console.log('In side wire');
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
                console.log('id---->',currentPageReference.state.id)
                this.getInitData();
          }
        }
    }
  
    getInitData() {
        debugger;
        console.log('In side init--->',this.recordId);
         this.executeAction(getOrderData, {'orderId' : this.recordId}, (response) => {
             console.log('response.Order----',response.Order);
             this.showModal = true;
             this.recordLocal = response.Order;
             if(this.recordLocal.SuppliesEquipment__c)
             this.typeOfOrder = 'Supplies / Equipment';
 
             if(this.recordLocal.Personnel__c)
             this.typeOfOrder = this.typeOfOrder +' '+ 'Personnel';
 
             if(this.recordLocal.Type_Of_Resource_Other__c)
             this.typeOfOrder = this.typeOfOrder +' '+'Other';
 
             this.recordLocal.TypeOfOrder = this.typeOfOrder;
             if(this.recordLocal.Confirm_Compliance_Checkboxes__c)
             this.confirmCompliance=this.recordLocal.Confirm_Compliance_Checkboxes__c.replaceAll(";","\n");
 
             const date = new Date();
             this.recordLocal.CurrentDate = date;
             setTimeout(function(){
                window.print(); 
            },700);
        });
    }

    get isGACHYes(){
        if(this.recordLocal.Is_this_for_a_GACH__c == 'Yes'){
            return true;
        }
        return false;
    }
    get isGACHNo(){
        if(this.recordLocal.Is_this_for_a_GACH__c == 'No'){
            return true;
        }
        return false;
    }
    get isVaccine(){
        if(this.recordLocal.Type_of_Personnel__c == 'Vaccination-related Personnel'){
            return true;
        }
        return false;
    }
    get isPersonnel(){
        if(this.recordLocal.Type_of_Personnel__c == 'Medical Personnel'){
            return true;
        }
        return false;
    }
    get istypeOfPesonnel(){
        if(this.recordLocal.Personnel__c){
            return true;
        }
        return false;
    }
  
    get isMedicalStaffingRequestAndGACHYes(){
        if(this.recordLocal.Is_this_for_a_GACH__c == 'Yes'){
            return true;
        }
        return false;
    }
    get staffSpeakSpecificLanguage(){
        if(this.recordLocal.Specific_language_preferred__c == 'Yes'){
            return true;
        }
        return false;
    }
    get vaccinationSdministrationSiteOther(){
        if(this.recordLocal.Vaccination_site_type__c == 'Other'){
            return true;
        }
        return false;
    }
    get placeForAdministeringVaccinDoses(){
        if(this.recordLocal.X2nd_Dose_plan_in_place__c == 'Yes'){
            return true;
        }
        return false;
    }
    get statePreviouslyHelpedYes(){
        if(this.recordLocal.Has_state_previously_helped__c == 'Yes'){
            return true;
        }
        return false;
    }
    get priorityLabelValue(){
        if(this.priorityList){
            for(let i = 0; i < this.priorityList.length; i++) {
                if(this.recordLocal.Priority_for_Requests__c == this.priorityList[i].value){
                    this.priorityLabel = this.priorityList[i].label;
                }
            }
        }
    return this.priorityLabel;    
    } 
    
}