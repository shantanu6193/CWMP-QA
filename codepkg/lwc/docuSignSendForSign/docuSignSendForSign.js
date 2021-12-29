import { LightningElement, api, wire, track } from 'lwc';
import Utility from 'c/utility';
import getDocuSignTemplateId from '@salesforce/apex/DocuSignSendForSignController.getDocuSignTemplateId';

export default class docuSignSendForSign extends Utility {


    @api docuSignTemplateName;
    @api recordId;
    
    @wire(getDocuSignTemplateId, {docuSignTemplateName: '$docuSignTemplateName', recordId: '$recordId'})
    url;
    
    sendForSign(){
       console.log('#docuSignTemplateName :',this.docuSignTemplateName);
       console.log('#recordId :',this.recordId);
       console.log('#url :',this.url);
       console.log('#url.data :',this.url.data);
       let url = this.url.data;

        const generateDocEvent = new CustomEvent('generateClicked', {
            detail: {url}
        });

        // Fire the custom event
        this.dispatchEvent(generateDocEvent); 
        
        /* 
       // Navigation to web page 
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": url
            }
        });
         */
        

        /* 
         //Navigate to visualforce page
        this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    //url: '/apex/AccountVFExample?id=' + this.recordId
                    ///apex/dfsle__gendocumentgenerator?sId=a1a35000000HXXWAA4&templateId=a1a35000000HXXWAA4&recordId={RecordId}&title=Generate%20PDF
                   //url: '!URLFOR(IF($Site.prefix == '/s','/apex/dfsle__sending', $Site.Prefix +'/apex/dfsle__sending'), null, [sId = Closeout_Task__c.Id, templateId = 'a1U35000004bCxJEAU', recordId = Closeout_Task__c.Id, title = 'DocuSign', quickSend = false, isEmbedded = false])'
                    url: '/apex/dfsle__sending?sId =' + this.recordId +'&templateId=' + this.docuSignTemplateId.data + '&recordId=' +  this.recordId + '&title=DocuSign&quickSend=false&isEmbedded=false'
                   
                }
            }).then(generatedUrl => {
                console.log('#generatedUrl: ',generatedUrl);
                window.open(generatedUrl);
            });
             */

    }

}