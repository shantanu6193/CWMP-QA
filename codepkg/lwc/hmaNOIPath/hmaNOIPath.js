import { LightningElement,track,api } from 'lwc';
import Utility from 'c/utility';

    export default class HmaNOIPath extends Utility {
        @api listOfStatus;
        @api selectedStatus;
        progressWidth;

        get path(){
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
            return status;
        }
    }