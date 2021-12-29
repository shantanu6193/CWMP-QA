import {
    LightningElement, track,wire,api
    } from 'lwc';

import emailTemplateFolderName from '@salesforce/apex/EmailTemplateSelectionHandler.getEmailTemplateFolderName';
//import emailTemplateInforation from '@salesforce/apex/SendEmailController.getEmailTemplate';
import getEmailTemplateFolderDetails from '@salesforce/apex/EmailTemplateSelectionHandler.getEmailTemplateFolderDetailsHH';
import Utility from 'c/utility';

const columnList = [
    {label: 'Template Name', fieldName: 'Name', wrapText: true},
    //{label: 'Folder Name', fieldName: 'FolderName'},
    {label: 'Description', fieldName: 'Description', wrapText: true}
];


export default class HhEmailTemplateSelection  extends Utility {

    @track emailTemplateFolder  = [];
    @track templateFolderName  = [];
   // @track mapData= [];
   @track columnList = columnList;
   @track selectedValusDropdown = true;
   @track emailTemplateList = [];
   @track isModalOpen =true;
   @api templaterelatedapitypeid;
   @api templatefolder;

    initData(){
        console.log('emailTemplateFolderName ------: ');
        this.isModalOpen = true;
    }


    connectedCallback() {
            
        this.getEmailTemplates();
    }

    // @wire(emailTemplateFolderName)
    // folderName({
    //     error,
    //     data
    // }) {
    //     if (data) {
    //         console.log('emailTemplateFolderName data', data);
    //         this.templateFolderName = JSON.parse(JSON.stringify(data));
    //         console.log('emailTemplateFolderName emailTemplateFolder ',this.templateFolderName);
    //         this.emailTemplateFolderNameDropDown(this.templateFolderName);
    //     } else if (error) {
    //         console.log('emailTemplateFolderName error', error);
    //     }
    // }

    emailTemplateFolderNameDropDown(data) {
        console.log('emailTemplateFolderNameDropDown length', data.length);
        console.log('emailTemplateFolderNameDropDown 0', data[0]);
        for (var i = 0; i < data.length; i++) {
            this.emailTemplateFolder.push({
                label: data[i],
                value: data[i]
            });
            //console.log('emailTemplateFolderNameDropDown ---', data[i]);
        }
       this.emailTemplateFolder = JSON.parse(JSON.stringify(this.emailTemplateFolder));
       console.log('emailTemplateFolderNameDropDown final test ----', this.emailTemplateFolder);
    }

    getEmailTemplates(){
        //console.log('fieldChangeHandler event pass ----', event.target.value); 
        this.selectedValusDropdown = true; 
        this.executeAction(getEmailTemplateFolderDetails, {
            'folderName': this.templatefolder,
            'relatedObjectAPITypeId': this.templaterelatedapitypeid
        }, (response) => {
            console.log('fieldChangeHandler responce: ', response);
            this.emailTemplateList = response;
            console.log('fieldChangeHandler emailTemplateList: ',  this.emailTemplateList);
           // this.isModalOpen = false;

            
           });

    }
    
   /* @wire(emailTemplateInforation)
    emailTemplateInforation({
        error,
        data
    }) {
        if (data) {
            console.log('emailTemplateInforation data', data);
            for(var key in data){
                this.mapData.push({value:data[key], key:key}); //Here we are creating the array to show on UI.
            }
            console.log('emailTemplateInforation mapData', this.mapData);
            } else if (error) {
                console.log('emailTemplateInforation error', error);
            }
        } */

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