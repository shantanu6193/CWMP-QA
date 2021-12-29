import { LightningElement,api,track } from 'lwc';
import Utility from 'c/utility';

export default class MarsMultiSelectPicklist extends Utility {
    @api
    values = [];

    @track
    selectedvalues = [];

    @api
    picklistlabel = 'Status';

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
        this.values.forEach(element => element.selected 
                            ? this.selectedvalues.push(element.value) : '');
        console.log(this.selectedvalues);
    }

    fetchSelectedValues() {
        
        this.selectedvalues = [];

        //get all the selected values
        this.template.querySelectorAll('c-mars-picklist-value-row').forEach(
            element => {
                if(element.selected){
                    //console.log(element.value);
                    this.selectedvalues.push(element.value);
                }
            }
        );

        //refresh original list
        this.refreshOrginalList();
    }

    refreshOrginalList() {
        //update the original value array to shown after close

        const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));

        picklistvalues.forEach((element, index) => {
            if(this.selectedvalues.includes(element.value)){
                picklistvalues[index].selected = true;
            }else{
                picklistvalues[index].selected = false;
            }
        });

        this.values = picklistvalues;
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