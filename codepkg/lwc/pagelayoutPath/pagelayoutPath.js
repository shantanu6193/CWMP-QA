import { LightningElement,track,api } from 'lwc';
import Utility from 'c/utility';

export default class PagelayoutPath extends Utility {
    // @track listOfStatus = ["HMGPSubApplication", "HMGP_Sub_Application_Scope_of_Work_Step1", "HMGP_Sub_Application_Scope_of_Work_Step2", "WorkSchedule"];
    // @track selectedStatus = 'HMGP_Sub_Application_Scope_of_Work_Step1';
    @api listOfStatus;
    @api selectedStatus;
    progressWidth;

    get path(){
        console.log('selectedStatus--------',this.selectedStatus);
        let status = [];
        let index;
        for(let i=0; i<this.listOfStatus.length; i++){
            let className;
            if(this.listOfStatus[i] == this.selectedStatus){
                className = 'slds-wizard__item slds-is-active';
                index = i;
            }
            else{
                className = 'slds-wizard__item';
            }
            status.push({
                status: this.listOfStatus[i],
                className: className
            });
        }
        for (let item = 0; item <= index; item++) {
            status[item].className = 'slds-wizard__item slds-is-active';
            let width = (index/(this.listOfStatus.length-1))*100;
            this.progressWidth = 'width:' + width + '%';
        }
        //status[index].className = 'slds-wizard__item slds-is-active slds-is-current';
        return status;
    }
}