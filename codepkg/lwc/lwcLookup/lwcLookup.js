import { LightningElement, track, wire, api } from "lwc";  
 import findRecords from "@salesforce/apex/lwcLookupController.findRecords";
 import findDefaultRecord from "@salesforce/apex/lwcLookupController.findDefaultRecord";
 import findContactsRelatedToAccount from "@salesforce/apex/lwcLookupController.findContactsRelatedToAccount";
 import searchSobjectUsingSOSL from "@salesforce/apex/lwcLookupController.searchSobjectUsingSOSL";
 export default class LwcLookup extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;
  @api selectedRecordId;
  @api objectApiName;  
  @api iconName;
  @api lookupLabel;
  @track message;
  //@api formname;
  @api lookupname;
  //@api disableCross;
  @api defaultid;
  //@api selectedRecord;
  @api accountid;
  @track accIds;
  @api objectName;
  @api fieldsToReturn;
  //@api whereClause;
  @api orderBy;
  @track error;
  //@api isRequired;

  connectedCallback(){
        findDefaultRecord({ searchId: this.defaultid ,objectName :this.objectApiName})
         .then((result) => {
          if (result.length===0) {
            this.recordsList = [];
            this.message = "No Records Found";
          }
          else {
              this.recordsList = result;
              this.message = "";
              this.selectedRecordId = this.recordsList[0].Id ;
              this.selectedRecord =this.recordsList[0];
              this.selectedValue = this.recordsList[0].Name;
              this.onSeletedRecordUpdate();
          }
           this.error = undefined;
         })
         .catch((error) => {
          this.error = error;
          this.recordsList = undefined;
         });
  }

     /* onLeave(event) {
       setTimeout(() => {
        this.searchKey = "";
        this.recordsList = null;
       }, 300);
      }*/

     @api hideDropDownList(event){
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {
   console.log('onRecordSelection-event.target.dataset.name =   '+event.target.dataset.name) ;
   this.selectedRecordId = event.target.dataset.key;
   this.selectedValue = event.target.dataset.name;
   let selectedItem = this.recordsList.filter((result) => result.Id === this.selectedRecordId); 
   console.log('onRecordSelection-selectedItem[0] =   '+selectedItem[0]) ;
   this.selectedRecord = selectedItem[0];
   //this.searchKey = "";
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
   
  removeRecordOnLookup(event) {  
   this.searchKey = "";  
   this.selectedValue = null;
   this.selectedRecord = "";  
   this.selectedRecordId = null;  
   this.recordsList = null; 
   this.onSeletedRecordUpdate();  
 }

 getLookupResult() { 
   if(this.lookupname == "lookupTwo") 
   {
    findRecords({ searchKey: this.searchKey ,objectName :this.objectName})
    .then((result) => { 
      if (result.length===0) {
      this.recordsList = [];  
      this.message = "No Records Found";  
      } else {  
      this.recordsList = result;
      this.message = "";  
      }  
      this.error = undefined;  
      })  
      .catch((error) => {  
      this.error = error;  
      this.recordsList = undefined; 
      });
   }
   else if(this.lookupname == "lookupOne") {
    searchSobjectUsingSOSL({ searchText: this.searchKey ,
      objectName :this.objectName ,
      fieldsToReturn:this.fieldsToReturn,
      whereClause:this.whereClause,
      orderBy:this.orderBy})
      .then((result) => {
      if (result.length===0) {  
      this.recordsList = [];  
      this.message = "No Records Found";  
      } else {  
      this.recordsList = result.soslResult;
      this.accIds = this.recordsList.Id; 
      this.message = "";  
      }  
      this.error = undefined;  
      })  
      .catch((error) => {  
      this.error = error;  
      this.recordsList = undefined; 
      //console.log('ERROR catch++++2'+error) 
      });
    }
    else if(this.lookupname == "ContactRealatedToAccount") {
    findContactsRelatedToAccount({searchKey: this.searchKey,AccountId:this.accountid})
    .then((result) => {
      if (result.length===0) {  
      this.recordsList = [];  
      this.message = "No Records Found";  
      } else {  
      this.recordsList = result.contactList;  
      this.message = "";  
      }  
      this.error = undefined;  
      })  
      .catch((error) => {  
      this.error = error;  
      this.recordsList = undefined; 
      });
      }
   }
    
   onSeletedRecordUpdate(event)
   {  
    const passEventr = new CustomEvent('recordselection', {
     detail: { selectedRecord: this.selectedRecord ,selectedRecordId: this.selectedRecordId } 
     });  
     this.dispatchEvent(passEventr); 
   } 
    
   @api ClearVal(event)
   {
   console.log('Child clear val');
   this.searchKey = "";  
   this.selectedValue = null; 
   this.selectedRecordId = null; 
   this.selectedRecord =null; 
   this.recordsList = null; 
  //this.onSeletedRecordUpdate(event);
   }

   get CorssButton()
   {
    if(this.lookupname == "lookupTwo")
    {
      return true;
    }
    else{
     return false;
    }
   }
   get NameOfObject()
      {
       if(this.objectApiName == "Account")
       {
         return true;
       }
       else{
        return false;
       }
      }
}