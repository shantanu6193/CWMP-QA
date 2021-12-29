/**
 * Created by hp on 03-09-2021.
 */

import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';

export default class ProjectRolePicklistValueRow extends Utility {

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