/*
 *LWC Name      : PaEmailTemplateSelection
 * Description  : This LWC is used to Email Template selectetion
 *               
 * Author       : Atul
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Atul             28/05/2021       Initial Implementation
**/

import {
    LightningElement, track,wire,api
    } from 'lwc';


import emailTemplateFolderName from '@salesforce/apex/EmailTemplateSelectionHandler.getEmailTemplateFolderName';
import getEmailTemplateFolderDetails from '@salesforce/apex/EmailTemplateSelectionHandler.getEmailTemplateFolderDetails';


import Utility from 'c/utility';

const columnList = [
    {label: 'Template Name', fieldName: 'Name'},
    {label: 'Folder Name', fieldName: 'FolderName'},
    {label: 'Description', fieldName: 'Description'}
];
export default class PaEmailTemplateSelection extends Utility {
    @track emailTemplateFolder  = [];
    @track templateFolderName  = [];
   // @track mapData= [];
   @track columnList = columnList;
   @track selectedValusDropdown = false;
   @track emailTemplateList = [];
   @track isModalOpen =true;
   @api templaterelatedapitypeid;

    initData(){
        this.isModalOpen = true;
    }

    @wire(emailTemplateFolderName)
    folderName({
        error,
        data
    }) {
        if (data) {
           
            this.templateFolderName = JSON.parse(JSON.stringify(data));
            this.emailTemplateFolderNameDropDown(this.templateFolderName);
        } else if (error) {
        }
    }

    emailTemplateFolderNameDropDown(data) {
        
        for (var i = 0; i < data.length; i++) {
            this.emailTemplateFolder.push({
                label: data[i],
                value: data[i]
            });
            
        }
       this.emailTemplateFolder = JSON.parse(JSON.stringify(this.emailTemplateFolder));
    }

    fieldChangeHandler(event){
        
        this.selectedValusDropdown = true; 
        this.executeAction(getEmailTemplateFolderDetails, {
            'folderName': event.target.value,
            'relatedObjectAPITypeId': this.templaterelatedapitypeid
        }, (response) => {
            this.emailTemplateList = response;
            
           });
            }

        closeModal(){
            //this.isModalOpen = false;
            this.dispatchEvent(new CustomEvent('close'));
        }

         selectedTemplateInfo(event){
            this.isModalOpen = false;
                const selectedRows = event.detail.selectedRows;
                
                // Display that fieldName of the selected rows
                for (let i = 0; i < selectedRows.length; i++){
                    //alert("You selected: " + selectedRows[i].Name);
                    // Creates the event with the data.
                        const selectedEvent = new CustomEvent("selectedtemplateinfo", {
                        detail: {selectedtemplate:selectedRows[i].Id}
                        });  
            
                        //Dispatch of Events...
                        this.dispatchEvent(selectedEvent);
                        this.dispatchEvent(new CustomEvent('close'));
                } 
        }
}