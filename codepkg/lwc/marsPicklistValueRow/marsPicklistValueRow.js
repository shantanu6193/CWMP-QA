import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
export default class MarsPicklistValueRow extends Utility {
    @api
    selected = false;
    
    @api
    label;
    
    @api
    value;


    handleSelect(event) {
        //this.selected = true;
        
        if(this.selected){
            this.selected = false;
        }else{
            this.selected = true;
        } 
        
    }
}