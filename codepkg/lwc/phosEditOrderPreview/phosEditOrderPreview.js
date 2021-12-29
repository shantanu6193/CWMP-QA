import { LightningElement,api,wire } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import PRIORITY_OF_REQUEST_FIELD from '@salesforce/schema/Order__c.Priority_for_Requests__c';
export default class PhosEditOrderPreview extends Utility {
    typeOfOrder='';
    @api orderVersion;
    orderVersionData = false;
    @api createdDate;
    @api createdByName;
    confirmCompliance;
    priorityLabel='';
    priorityList;

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
    initData() {
        if(this.orderVersion != undefined){
            const tempData=JSON.stringify(this.orderVersion);
            this.recordLocal = this.orderVersion;
            if(this.recordLocal.Order_Products__r != null && this.recordLocal.Order_Products__r != undefined)
                this.orderVersionData = true;
        }
        if(this.recordLocal.Confirm_Compliance_Checkboxes__c)
            this.confirmCompliance=this.recordLocal.Confirm_Compliance_Checkboxes__c.replaceAll(";","\n");

        if(this.recordLocal != undefined ) {
            if(this.recordLocal.SuppliesEquipment__c)
            this.typeOfOrder = 'Supplies / Equipment';

            if(this.recordLocal.Personnel__c)
            this.typeOfOrder = this.typeOfOrder +' '+ 'Personnel';

            if(this.recordLocal.Type_Of_Resource_Other__c)
            this.typeOfOrder = this.typeOfOrder +' '+'Other';
       }  
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
    get priorityLabelValue(){
        if(this.priorityList){
            for(let i = 0; i < this.priorityList.length; i++) {
                if(this.recordLocal.Priority_for_Requests__c == this.priorityList[i].value){
                    this.priorityLabel = this.priorityList[i].label;
                }
            }
        }
    return  this.priorityLabel;    
    } 
}