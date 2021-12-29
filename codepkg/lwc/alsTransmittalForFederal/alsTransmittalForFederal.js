import { LightningElement,api, wire } from 'lwc';
import CalOes_Image from '@salesforce/resourceUrl/caloesimage';
import getDetail from '@salesforce/apex/ALS_TransmittalPreviewController.getDetails';
import { CurrentPageReference } from 'lightning/navigation';


export default class AlsTransmittalForFederal extends LightningElement {
    caloesimage = CalOes_Image; 
    @api recordId;
    @api transmittalId;
	transmittalDetails ={};
	currentPageReference;
	@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
   		this.recordId = currentPageReference.state.c__refRecordId;
    }
    connectedCallback()
	{

		//console.log('transmittalIds+++++ ', this.recordId);
			getDetail({
				transmittalId: this.recordId
			   })
				.then(result => {
					//console.log('result++++++++++ ',JSON.stringify(result));
					//console.log('result++++++++++ Id '+result.TransmittalObj.Id);
					this.transmittalDetails =result.TransmittalObj;
					//console.log('************Details of Transmittal'+JSON.stringify(this.transmittalDetails));
					//console.log('ApplicantName__r+++++++++ Id '+ this.transmittalDetails.ApplicantName__r.Name);
					window.scrollTo(0,0);
				})
				.catch(error => {
					console.log('Error', error);
					window.scrollTo(0,0);
				});
		
	}
	handlePrintClick(){
	  window.print();
	}
	get isPAFederal(){
        if(this.transmittalDetails.ProgramName__r.Name == 'PA - Federal'){
              return true;
          }
          return false;
    }
	 get isMutualAid()
        {

          if(this.transmittalDetails.PaymentType__c == 'Mutual Aid')
          {
              return true;
          }
          return false;
        }
    get isRejected()
            {

              if(this.transmittalDetails.Stage__c == 'Rejected')
              {
                  return false;
              }
              return true;
            }
    get isStateTransmittal()
    {
        if(this.transmittalDetails.TransmittalType__c == 'State')
                      {
                          return true;
                      }
                      return false;
    }
}