import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import HH_EN_Step_x_of_y from '@salesforce/label/c.HH_EN_Step_x_of_y';

export default class HhApplicationPath extends Utility {

    @api currentPathOrder;
    @api paths;
    @api isExternalUser;
    @api recordId;
    progressWidth;
    stageOrderMap = {};

    get pathValues() {
        let pathValues = [];
        let stepLabel  = HH_EN_Step_x_of_y;
        this.totalPaths = this.paths.length;
        for(let i=0; i<this.paths.length; i++) {
            let path = {};
            path = JSON.parse(JSON.stringify(this.paths[i]));
            if(this.currentPathOrder === this.paths[i]['order']) {
                path["className"] = "slds-wizard__item slds-is-active slds-is-current";
                path["class"] = "slds-path__item slds-is-current slds-is-active";
                path["currentPath"] = true;
            } else if (this.currentPathOrder > this.paths[i]['order']) {
                path["className"] = "slds-wizard__item slds-is-active";
                path["class"] = "slds-path__item slds-is-complete";
                path["currentPath"] = false;
            } else if (this.currentPathOrder < this.paths[i]['order']) {
                path["className"] = "slds-wizard__item";
                path["class"] = "slds-path__item slds-is-incomplete";
                path["currentPath"] = false;
            }

            path["stepLabel"] = stepLabel.replace('[[x]]',this.currentPathOrder).replace('[[y]]', this.totalPaths);
            console.log('====>',path['stepLabel']);
            this.stageOrderMap [this.paths[i]['order']] = this.paths[i]['name'];
            pathValues.push(path);
        }
        let width =  ((this.currentPathOrder-1)/(this.paths.length-1))*100;
        if(this.currentPathOrder == 2) {
            this.progressWidth = "width:21%";   
        } else if(this.currentPathOrder == 3) {
            this.progressWidth = "width:39%";   
        } else if(this.currentPathOrder == 4) {
            this.progressWidth = "width:56%";   
        } else if(this.currentPathOrder == 5) {
            this.progressWidth = "width:74%";   
        } else {
            this.progressWidth = "width:"+width+"%";
        }
        
        console.log('Paths: '+pathValues)
        return pathValues;
    }


    navigate(event) {
        let order = event.currentTarget.getAttribute('data-id');
        let stageName = this.stageOrderMap[order];
        if(stageName != undefined ) {
            this.dispatchValidateEvent(stageName);
        }
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


    
    /*
    * Notifies parent component when close clicked
    */
    dispatchValidateEvent(stageName) {
        const validateEvent = new CustomEvent('validatepage', {
            detail: { 'stageName': stageName },
        });
         this.dispatchEvent(validateEvent);
    }

    
}