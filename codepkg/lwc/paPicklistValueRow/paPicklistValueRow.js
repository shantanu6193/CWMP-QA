/**
 * Created by hp on 24-08-2021.
 */

import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';

export default class PaPicklistValueRow extends Utility {
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