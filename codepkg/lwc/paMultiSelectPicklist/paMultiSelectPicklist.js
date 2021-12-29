/*
 *LWC Name      : PaRequestProjectCloseout
 * Description  : This LWC is used to select multiseleted picklist
 *               
 * Author       : -
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * -             28/05/2021       Initial Implementation
**/

import { LightningElement,api,track } from 'lwc';
import Utility from 'c/utility';

export default class PaMultiSelectPicklist extends Utility {
    @api
    values = [];

    @track localValues = [];

    @track
    selectedvalues = [];

    @api
    picklistlabel = 'Status';

    @api recordSelectedValues;

    showdropdown;

    handleleave() {

        let sddcheck= this.showdropdown;

        if(sddcheck){
            this.showdropdown = false;
            this.fetchSelectedValues();
            let eventvalue = this.selectedvalues;
            const addEvent = new CustomEvent('selectedvalues', { detail: { eventvalue}});
            this.dispatchEvent(addEvent);
        }
    }

    connectedCallback(){
        debugger;
        this.localValues = JSON.parse(JSON.stringify(this.values));
        if(this.recordSelectedValues != null){
            let valuesSplit = this.recordSelectedValues.split(';');
            for (let valIndex = 0; valIndex < valuesSplit.length; valIndex++) {
                for (let index = 0; index < this.localValues.length; index++) {
                    if(this.localValues[index].value == valuesSplit[valIndex]){
                       this.localValues[index].selected = true;
                    }
                }
            }

        }
        this.localValues.forEach(element => element.selected
                            ? this.selectedvalues.push(element.value) : '');
    }

    fetchSelectedValues() {

        this.selectedvalues = [];

        //get all the selected values
        this.template.querySelectorAll('c-mars-picklist-value-row').forEach(
            element => {
                if(element.selected){
                    this.selectedvalues.push(element.value);
                }
            }
        );

        //refresh original list
        this.refreshOrginalList();
    }

    refreshOrginalList() {
        //update the original value array to shown after close

        const picklistvalues = this.localValues.map(eachvalue => ({...eachvalue}));

        picklistvalues.forEach((element, index) => {
            if(this.selectedvalues.includes(element.value)){
                picklistvalues[index].selected = true;
            }else{
                picklistvalues[index].selected = false;
            }
        });

        this.localValues = picklistvalues;
    }

    handleShowdropdown(){
        let sdd = this.showdropdown;
        if(sdd){
            this.showdropdown = false;
            this.fetchSelectedValues();

        }else{
            this.showdropdown = true;
        }

    }

    closePill(event){
        let selection = event.target.dataset.value;
        let selectedpills = this.selectedvalues;
        let pillIndex = selectedpills.indexOf(selection);
        this.selectedvalues.splice(pillIndex, 1);
        this.refreshOrginalList();
        let eventvalue = this.selectedvalues;
        const addEvent = new CustomEvent('selectedvalues', { detail: { eventvalue}});
        this.dispatchEvent(addEvent);
    }

    get selectedmessage() {
        return this.selectedvalues.length + ' values are selected';
    }

}