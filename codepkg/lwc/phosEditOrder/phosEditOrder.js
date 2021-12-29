import { LightningElement, track, api, wire} from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import getOrderData from '@salesforce/apex/PHOS_Order_EditCtrl.getOrderData';
import saveOrder from '@salesforce/apex/PHOS_Order_EditCtrl.saveOrder';
import isCommunityUser from '@salesforce/apex/ApexUtils.checkCommunityUser';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
export default class PhosEditOrder extends Utility {
    currentStage = '';
    @api recordId;
    @api orderRecord;
    communityUser;
    isRecordLoaded = false;
    actionClicked = '';
    showModal = false;
    addressLine2;

    get stagesList() {
        if(this.record.Personnel__c == true) {
            return ['OrderInfo','OrderRequesterInfo','OrderProducts','OrderDescription','OrderPreview'];
        } else {
            return ['OrderInfo','OrderRequesterInfo','OrderProducts','OrderPreview'];
        }

    }

   /*@wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state && currentPageReference.state.currentStage) {
          if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
          }
            let currentStageURL = currentPageReference.state.currentStage;
            if(currentStageURL) {
              this.currentStage = currentStageURL;
            }
        }
    }*/
    initData() {
        if(this.currentStage == undefined || this.currentStage=='' || this.currentStage == 'Record Submitted'){
            this.currentStage ='OrderInfo';
        }
        this.retrieveData(this.currentStage);
        this.executeAction(isCommunityUser, {}, (response) => {
            this.communityUser = response;
        });
    }
    retrieveData(stageName) {
        if(this.recordId){
            /*this.executeAction(getOrderData, {'orderId' : this.recordId}, (response) => {
                this.handleGetDataResponse(response, stageName);
            });*/
            this.handleGetDataResponse(this.orderRecord, stageName);
        } else {
           this.currentStage = 'OrderInfo';
        }
    }

    handleGetDataResponse(result, stageName) {
        this.record = result;
        this.recordLocal = result;
        this.currentStage = stageName;
        let currentStageURL = this.getURLParameter("currentStage");
        if(currentStageURL) {
          this.currentStage = currentStageURL;
        }
    }

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    objectInfo;

    get isOrderInfoStage() {
        if(this.currentStage == 'OrderInfo') return true;
        return false;
    }
    get isOrderRequesterInfoStage() {
        if(this.currentStage == 'OrderRequesterInfo') return true;
        return false;
    }
    get isOrderProductsStage() {
        if(this.currentStage == 'OrderProducts') return true;
        return false;
    }
    get isOrderDescriptionStage() {
        if(this.currentStage == 'OrderDescription') return true;
        return false;
    }
    get isOrderPreviewStage() {
        if(this.currentStage == 'OrderPreview') return true;
        return false;
    }
    redirectToPrevious() {
        this.getData(true);
        this.actionClicked = 'Previous';
        this.processSaveCallback(this.record);
    }

    redirectToNext() {
        debugger;
        if(this.getData(false) == false) {
            return;
        }
        this.actionClicked = 'Next';
        this.record.Current_Stage__c = this.currentStage;
        this.processSaveCallback(this.record);
        //this.saveRecord(this.record);
    }

    getData(isPrevious) {
        if(this.template.querySelector('[data-custom="innerComponent"]') != undefined) {
            if(isPrevious == true) {
                this.template.querySelector('[data-custom="innerComponent"]').skipAllValidations();
            } else {
                console.log('this.currentStage****',this.currentStage);
                /*if(this.currentStage == 'OrderProducts') {
                    this.template.querySelector('[data-custom="innerComponent"]').skipInputValidations();
                    this.template.querySelector('[data-custom="innerComponent"]').enableCustomValidations();
                } else {
                    this.template.querySelector('[data-custom="innerComponent"]').enableAllValidations();
                }*/
                this.template.querySelector('[data-custom="innerComponent"]').enableAllValidations();
            }
            let localRecord = this.template.querySelector('[data-custom="innerComponent"]').getRecordDetails();
            console.log('....lll',localRecord);
            if(localRecord != undefined) {
                this.record = localRecord;
                return true;
            }
        }
        console.log('record--', JSON.parse(JSON.stringify(this.record)));
        if(this.currentStage != 'OrderProducts') {
            window.scrollTo(0,0);
            this.showNotification('Error', 'Please complete all required fields', 'error', 'dismissable');
        }
        return false;
    }

    processSaveCallback(response) {
        //this.recordId = response.Id;
        if(this.actionClicked == 'Quick Save') {
            /*this.record.Id = response.Id;
            this.record.Status__c = response.OrderRec.Status__c;*/
            this.record = response.OrderRec;
            this.showNotification('Success', 'Order saved successfully. Order Number is '+ response.OrderNumber, 'success', 'dismissable');
            //this.redirectToCommunityCustomPage('edit-order', {'id' : this.recordId, 'currentStage' : this.currentStage});
        } else if(this.actionClicked == 'Next') {
            //this.redirectToCommunityCustomPage('edit-order', {'id' : this.recordId, 'currentStage' : this.getNextStage()});
            this.currentStage = this.getNextStage();
        } else if(this.actionClicked == 'Previous') {
            //this.redirectToCommunityCustomPage('edit-order', {'id' : this.recordId, 'currentStage' : this.getPreviousStage()});
            this.currentStage = this.getPreviousStage();
        } else if(this.actionClicked == 'Submit') {
            this.handleSubmitResponse(response.Id);
            if(this.recordId) {
               this.dispatchCloseEvent();
            }
            this.recordId = response.Id;
       }
    }
    getNextStage() {
        if(this.currentStage == 'OrderInfo') return 'OrderRequesterInfo';
        else if(this.currentStage == 'OrderRequesterInfo') return 'OrderProducts'; 
        else if(this.currentStage == 'OrderProducts') {
            if(this.stagesList.includes('OrderDescription')) return 'OrderDescription';
            return 'OrderPreview';
        }
        else if(this.currentStage == 'OrderDescription') return 'OrderPreview';
        
    }

    getPreviousStage() {
        if(this.currentStage == 'OrderPreview') {
            if(this.stagesList.includes('OrderDescription')) return 'OrderDescription';
            return 'OrderProducts';
        }
        else if(this.currentStage == 'OrderDescription')  return 'OrderProducts';
        else if(this.currentStage == 'OrderProducts') return 'OrderRequesterInfo';
        else if(this.currentStage == 'OrderRequesterInfo') return 'OrderInfo';
    }
    /*getDeliveryAddress(){
        var address = [];
         if(this.record.Shipping_Street__c != undefined) {
            address = this.record.Shipping_Street__c.split('\n');
            this.record.Shipping_Street__c=address[0];
            if(address.length > 1){
                this.addressLine2 = address[1];
            }
         }
    }
    setDeliveryAddress(){
        let addressLine = this.addressLine2;
        if(addressLine == undefined){
            addressLine = '';
        }
        this.record.Shipping_Street__c = this.record.Shipping_Street__c+ "\n " + addressLine;
    }*/
    quickSave() {
        if(this.getData(false) == false) return;
        this.actionClicked = 'Quick Save';
        this.record.Current_Stage__c = this.currentStage;
        this.saveRecord(this.record, true);
    }

    submit() {
        this.record.Current_Stage__c = 'Record Submitted';
        this.actionClicked = 'Submit';
        this.saveRecord(this.record, false);
    }

    saveRecord(record, quickSaved) {
        let recordToSend = JSON.parse(JSON.stringify(record));
        if(recordToSend.Order_Products__r && !recordToSend.Order_Products__r.records) {
            recordToSend.Order_Products__r= {
                totalSize: recordToSend.Order_Products__r.length,
                done: true,
                records: recordToSend.Order_Products__r
            };
        }
        this.executeAction(saveOrder, {'recordData' : JSON.stringify(recordToSend), 'quickSave' : quickSaved}, (response) => { this.processSaveCallback(response); });
    }
    handleSubmitResponse(response) {
        this.showNotification('Success', 'Request submitted successfully', 'success', 'sticky');
        this.navigateRecordViewPage(response);
    }
    /*
    * Notifies parent component when close clicked
    */
    dispatchCloseEvent() {
        //console.log('iiiiii');
        let close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         this.dispatchEvent(closeclickedevt);
    }
}