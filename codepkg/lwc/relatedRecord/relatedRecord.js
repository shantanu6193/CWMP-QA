import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecords from "@salesforce/apex/RelatedRecordCtrl.getRecords";
import countRecords from "@salesforce/apex/RelatedRecordCtrl.countRecords";
//import getDynamicObjectData from '@salesforce/apex/RelatedRecordCtrl.getDynamicObjectData';
let cols;
/*const actions = [
  { label: "Show details", name: "show_details" },
  { label: "Edit", name: "edit" },
  { label: "Delete", name: "delete" },
];*/
export default class RelatedRecord extends NavigationMixin(LightningElement) {
    @api recordId;
    @api iconName;
    @api title;
    @api objectName;
    @api columns;
    @api relatedFieldAPI;
    @api whereClause;
    @api limit = 10;
    @track data =[];
    @track soql;
    @track offSet = 0;
    @track totalRows = 0;
    @track error;
    @api allFields;
    @track checkAssociatedRecord = false;
    connectedCallback() {
        if (this.columns != null && this.columns != undefined) {
            cols = JSON.parse(this.columns);
        }
        /*cols.push({
            type: "action",
            typeAttributes: { rowActions: actions },
        });*/
        this.columns =cols;
        console.log('columns-------',this.columns);
        //this.allFields=this.columns;
        this.buildSOQL();
        countRecords({ countSOQL: this.objectName}).then((result) => {
            this.totalRows = result;
            console.log('totalRows-------',this.totalRows);
        });
        this.fetchRecords();
    }
  
    fetchRecords() {
        console.log('this.objectName----------------',this.objectName);
        console.log('this.recordId----------------',this.recordId);
        console.log('this.relatedFieldAPI----------------',this.relatedFieldAPI);
        // getDynamicObjectData({objectName:this.objectName,
        //                       recordId:this.recordId,
        //                       fieldName:this.relatedFieldAPI,
        //                       allFields:this.allFields}).
        //   then((data)=>{
        //     console.log('datasink-------',data);
        //   }).catch(error=>{
        //     console.log('error---------',error);
        //   });
        getRecords({ //soql: this.soql,
                      objectName:this.objectName,
                      recordId:this.recordId,
                      fieldName:this.relatedFieldAPI,
                      allFields:this.allFields
                     })
            .then((data) => {
            if (data) {
              console.log('datasink-------',data);
              if(data.length == 0) this.checkAssociatedRecord=true;
                data.map((e) => {
                for (let key in e) {
                    if (typeof e[key] === "object") {
                    for (let onLevel in e[key]) {
                        e[key + "." + onLevel] = e[key][onLevel];
                    }
                    }
                }
                });
                  let nameUrl;
                  this.data = data.map(row => { 
                      nameUrl = `/${row.Id}`;
                      return {...row , nameUrl} 
                  })
            }
            })
            .catch((error) => {
            if (error) {
                this.error = "Unknown error";
                if (Array.isArray(error.body)) {
                this.error = error.body.map((e) => e.message).join(", ");
                } else if (typeof error.body.message === "string") {
                this.error = error.body.message;
                }
                console.log("error-------------", this.error);
            }
            });
    }
  
    // newRecord() {
    //     this[NavigationMixin.Navigate]({
    //         type: "standard__objectPage",
    //         attributes: {
    //         objectApiName: this.objectName,
    //         actionName: "new",
    //         },
    //     });
    // }
  
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case "edit":
            this.editRecord(row);
            break;
            case "delete":
            this.deleteRow(row);
            break;
            case "show_details":
            this.showRowDetails(row);
            break;
            default:
        }
    }
  
   
  
    /*********************************************************************
     * All Helper Method's
     *********************************************************************/
    deleteRow(row) {
      let id = row["Id"],
        index = this.findRowIndexById(id);
      console.log(index);
      if (index !== -1) {
        deleteRecord(id)
          .then(() => {
            this.data = this.data
              .slice(0, index)
              .concat(this.data.slice(index + 1));
            this.showToast("Success", "Record deleted", "success");
          })
          .catch((error) => {
            this.showToast("Error deleting record", error.body.message, "error");
          });
      }
    }
  
    findRowIndexById(id) {
      let ret = -1;
      this.data.some((row, index) => {
        if (row.Id === id) {
          ret = index;
          return true;
        }
        return false;
      });
      return ret;
    }
  
    showRowDetails(row) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: row["Id"],
          objectApiName: this.objectName,
          actionName: "view",
        },
      });
    }
  
    editRecord(row) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: row["Id"],
          objectApiName: this.objectName,
          actionName: "edit",
        },
      });
    }
  
    //Generic function to build soql
    buildSOQL() {
      let soql = this.appendField();
      soql += this.appendWhere();
      soql += this.appendLimit();
      soql += this.appendOffset();
      this.soql = soql;
    }
  
    appendField() {
      let soql = "SELECT Id,",
        col = [];
      if (cols) {
        cols.map((val) => {
          if (val.hasOwnProperty("fieldNameAPI")) {
            col.push(val["fieldNameAPI"]);
          }
        });
        this.allFields = col.join(",");
        soql = soql + `${col.join(",")} FROM ${this.objectName}`;
        console.log('soql---------',soql);
        console.log('col---------',col);
        console.log('col.join---------',col.join(","));
      }
      return soql;
    }
  
    appendWhere() {
      let where = " WHERE ";
      if (this.relatedFieldAPI)
        where += `${this.relatedFieldAPI} = '${this.recordId}'`;
      if (this.whereClause && this.relatedFieldAPI){
        where += 'AND ${this.whereClause}';
       // where+= 'AND ${Id!=this.recordId}';
        console.log('wehre-------',where);
      }
        
      else if (this.whereClause){
        where += `${this.whereClause} AND Id!= '${this.recordId}'`;
        //where += ' AND Id!= ${this.recordId}';
        console.log('where-------',where);
      } 
      return where === " WHERE " ? "" : where;
    }
  
    appendLimit() {
      return ` LIMIT ${this.limit}`;
    }
  
    appendOffset() {
      return ` OFFSET ${this.offSet}`;
    }
  
    showToast(title, message, variant) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
        })
      );
    }
}