import { LightningElement,wire,api } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getIncidentList  from '@salesforce/apex/PHOS_Order_EditCtrl.getIncidentList';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import PRIORITY_OF_REQUEST_FIELD from '@salesforce/schema/Order__c.Priority_for_Requests__c';
export default class PhosEditOrderInfo extends Utility {
    isLoading = true;
    incidentOptions ='';
    incidentList ='';
    orderTypeOptions ='';
    orderTypeList ='';
    @api communityUser;
    //@api isCommunityUser;
    initData(){

    }

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    objectInfo;

    @wire(getIncidentList, {available : "PHOS"})
    incidentPicklistValues({data,error}){
        if(data){
            this.incidentList = data;
            let incidentValues = [];
            for(let i = 0; i < this.incidentList.length; i++) {
                incidentValues.push({
                label: this.incidentList[i].label,
                value: this.incidentList[i].value
            })
            }
            this.incidentOptions = incidentValues;
      }
      else if(error){
        console.log('incident error--',error); 
      }
    };
   
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PRIORITY_OF_REQUEST_FIELD
    })
    priorityRequestPicklistValues;

    updateIncident(event){
        let incidentValues =this.incidentOptions;
        let  value = event.target.value;
        this.recordLocal.Incident__c = value;
        for(var i=0;i<incidentValues.length;i++){
            if(value == incidentValues[i].value){
                this.recordLocal.Incident_Name__c = incidentValues[i].label;
            }
        }
    }
    validateCustomInput(){
        if(this.recordLocal.Personnel__c || this.recordLocal.SuppliesEquipment__c || this.recordLocal.Type_Of_Resource_Other__c) {
            return true;
        } else {
            this.showErrorNotification('Error', 'Please select Type of Order');
            return false;
        }
    }
    /*get isPersonnel() {
        if(this.recordLocal.Personnel__c)
            return true;
        return false;
    }*/
}