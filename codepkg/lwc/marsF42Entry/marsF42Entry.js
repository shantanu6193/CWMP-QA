import {
    LightningElement,
    wire,
    api,
    track
  } from 'lwc';
import Utility from 'c/utility';
import apexgetDraftF42Entries from '@salesforce/apex/MARS_F42Entry_Ctrl.getDraftF42Entries';
import apexdisregardEntry from '@salesforce/apex/MARS_F42Entry_Ctrl.disregardF42Entry';
import initialize from '@salesforce/apex/MARS_F42Entry_Ctrl.initializeWrapper';
import saveF42 from '@salesforce/apex/MARS_F42Entry_Ctrl.saveWrapper';
import apexSearchIncident from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchIncident';
import apexSearchIcsTitle from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchIcsTitle';
import apexSearchSpecialEquipment from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchSpecialEquipment';
import apexSearchFireAgency from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchFireAgency';
import apexSearchRank from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchRank';
import apexSearchFemaCode from '@salesforce/apex/MARS_F42Entry_Ctrl.apexSearchFemaCode';
import Fiscal_Supplier_ID__c from '@salesforce/schema/Account.Fiscal_Supplier_ID__c';



export default class marsF42Entry extends Utility {
    @track selectedItem;
    @track currentContent;
    @api   accountId;
    @api   f42entryId;
    @track f42DraftEntries = [];
    @track showF42DraftEntries = false;
    @track showF42EntryDetails = false;
    @track f42Entry;
    @track personnelInfoItems = [];
    @track otherpersonnelInfoItems = [];
    @track actualHoursTotal = 0;
    @track actualHoursItems = [];
    @track comments = [];
    @track submitEnabled   = false;
    @track saveandNextEnabled   = false;
    errorMessages = [];
    @track errorMessage = '';
    @track infoMessage  = '';
    @track overheadSelection = [];
    @api
    incidentRequired = [];
    dispatchincidentRequired = [];
    dispatchfromincidentRequired = [];
    dispatchtoincidentRequired = [];
    icstitlerequired = [];
    specialEquipmentRequired = [];
    fireAgencyRequired = [];
    rankRequired = [];
    femacodeRequired = [];
    validLookups = true;
    buttonDisabled = false;
    isSubmitModalOpen = false;
    isDisregardModalOpen = false;
    buttonsEnabled  = false;
    showErrorMessage = false;
    showInfoMessage   = false;

    initData(){
        this.accountId =  window.location.href.split('id=')[1].substring(0,18);
        this.executeAction(apexgetDraftF42Entries, {
            accId: this.accountId
        }, 
        (response) => {
            this.f42DraftEntries = response;
            this.showF42DraftEntries = true;
            this.showF42EntryDetails = false;
            this.currentContent = '';
            this.selectedItem = '';
        });
    }

    initF42EntryData(){
        this.accountId =  window.location.href.split('id=')[1].substring(0,18);
        this.executeAction(initialize, {
            agencyId: this.accountId,
            f42EntryId: this.f42entryId
        }, 
        (response) => {
            this.f42Entry                   = response;
            if(!this.f42Entry.OH_overheadType){
                this.overheadSelection      = this.f42Entry.OH_overheadType.split(',');
            }
            
            this.personnelInfoItems         = this.f42Entry.personnelInfoList;
            this.otherpersonnelInfoItems    = this.f42Entry.otherpersonnelInfoList;
            this.actualHoursItems           = this.f42Entry.actualHoursList;
            this.comments                   = this.f42Entry.comments;

            this.actualHoursTotal = 0;
            for(let i=0; i<this.actualHoursItems.length; i++){
                let act = this.actualHoursItems[i];
                if(act.totalHours){
                    let actH = parseFloat(act.totalHours);
                    this.actualHoursTotal = parseFloat(this.actualHoursTotal) + actH;
                    this.actualHoursTotal = this.actualHoursTotal.toFixed(2);
                }
            }
            
        });
    }

    addNewF42Entry(){
        this.f42entryId = '';
        this.executeAction(initialize, {
            agencyId: this.accountId,
            f42EntryId: this.f42entryId
        }, 
        (response) => {
            this.f42Entry                   = response;
            this.personnelInfoItems         = this.f42Entry.personnelInfoList;
            this.otherpersonnelInfoItems    = this.f42Entry.otherpersonnelInfoList;
            this.actualHoursItems           = this.f42Entry.actualHoursList;
            this.comments                   = this.f42Entry.comments;
            this.showF42DraftEntries        = false;
            this.showF42EntryDetails        = true;
            this.currentContent             = '';
            this.selectedItem               = '';
            this.overheadSelection          = [];
            //this.currentContent             = '';
        });

    }

    closeF42EntryScreen(){
        this.f42entryId                 = '';
        this.initData();

    }

    handleShowF42Entry(event){
        var targetId = event.target.dataset.id;
        this.f42entryId = targetId;
        this.executeAction(initialize, {
            agencyId: this.accountId,
            f42EntryId: this.f42entryId
        }, 
        (response) => {
            this.f42Entry                   = response;
            this.personnelInfoItems         = this.f42Entry.personnelInfoList;
            this.otherpersonnelInfoItems    = this.f42Entry.otherpersonnelInfoList;
            this.actualHoursItems           = this.f42Entry.actualHoursList;
            this.comments                   = this.f42Entry.comments;
            this.showF42EntryDetails        = true;
            this.showF42DraftEntries        = false;

            this.currentContent             = '';
            this.selectedItem               = '';

            if(this.f42Entry.OH_overheadType){
                this.overheadSelection      = this.f42Entry.OH_overheadType.split(',');
            }else{
                this.overheadSelection      = [];
            }
            

            this.actualHoursTotal = 0;
            for(let i=0; i<this.actualHoursItems.length; i++){
                let act = this.actualHoursItems[i];
                if(act.totalHours){
                    let actH = parseFloat(act.totalHours);
                    this.actualHoursTotal = parseFloat(this.actualHoursTotal) + actH;
                    this.actualHoursTotal = this.actualHoursTotal.toFixed(2);
                }
            }

        });

    }

    handleDisregardF42Entry(event){
        var targetId = event.target.dataset.id;
        this.f42entryId = targetId;
        this.isDisregardModalOpen = true;
    }

    DisregardF42Entry(){
        this.executeAction(apexdisregardEntry, {
            entryId: this.f42entryId,
            accId: this.accountId
        }, 
        (response) => {
            this.f42DraftEntries = response;
            this.showF42DraftEntries = true;
            this.showF42EntryDetails = false;
            this.f42entryId = '';
            this.showSuccessNotification('Success', 'Your Entry is Disregarded');
            this.isDisregardModalOpen = false;
        });
    }

    closeDeleteModal(){
        this.isDisregardModalOpen = false;
    }

    handleFieldUpdates(event){
        const fieldName = event.target.name;
        var selector = '[data-name="'+fieldName+'"]';
        this.template.querySelectorAll(selector).forEach(eachElement => {
            this.f42Entry[eachElement.name] = eachElement.value;
        })
    }

    handleOverheadTypeSelection(event){
        this.overheadSelection = event.detail.value;
        this.f42Entry.OH_overheadType = this.overheadSelection.join(',');
        if(this.f42Entry.OH_overheadType){
            if(!this.f42Entry.OH_overheadType.includes('Overhead Position')){
                this.f42Entry.OH_icsTitle = {};
                this.template.querySelector('[data-lookup="ICS_Title__c"]').handleClearSelection();
                this.f42Entry.OH_otherICStitle = '';
            }
        }
    }

    formatRAPhone() {
        var phoneNumberString = this.f42Entry.RA_yourPhone;
        var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
            this.f42Entry.RA_yourPhone =  '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
      }

    handleAddPILine(){
        for(let i=0; i<this.personnelInfoItems.length; i++) {
            var pInfo = this.personnelInfoItems[i];
            pInfo.editable = false;
            pInfo.readOnly = true;
            this.personnelInfoItems[i] = pInfo;
        }
        this.f42Entry.personnelInfoList = this.personnelInfoItems;

        var p = new Object();
        p.editable = true;
        p.readOnly = false;
        p.MACSID  = this.f42Entry.agency.MACS_ID__c;
        p.startDate = this.f42Entry.DI_committedtoIncident;
        p.startTime = this.f42Entry.DI_committedtoIncidentTime;
        p.endDate = this.f42Entry.DI_returnfromIncident ? this.f42Entry.DI_returnfromIncident : this.f42Entry.DI_reDispatched;
        p.endTime = this.f42Entry.DI_returnfromIncidentTime ? this.f42Entry.DI_returnfromIncidentTime : this.f42Entry.DI_reDispatchedTime;
        this.personnelInfoItems.push(p);
        this.f42Entry.personnelInfoList = this.personnelInfoItems;
    }

    handlePersonnelInfoUpdate(event){
        var index = event.currentTarget.dataset.index;
        var tarName = '';
        tarName =  event.target.name;
        var pInfo = this.personnelInfoItems[index];
        if(tarName === 'cdf' || tarName === 'p2p' || tarName === 'baseRate'){
            pInfo[tarName] = event.target.checked;
            if(tarName === 'cdf'){
                pInfo.MACSID = 'CDF';
                this.template.querySelector('[data-lookup="Rank__c"]').handleClearSelection();
                pInfo.jobTitle = '';
            }
        }else{
            pInfo[tarName] = event.target.value;
        }
        if(tarName === 'MACSID' && pInfo.jobTitle !== ''){
            this.template.querySelector('[data-lookup="Rank__c"]').handleClearSelection();
            pInfo.jobTitle = '';
        }
        this.personnelInfoItems[index] = pInfo;
        this.f42Entry.personnelInfoList = this.personnelInfoItems;
    }

    handlepersonnelEdit(event){
        var index = event.currentTarget.dataset.index;
        for(let i=0; i<this.personnelInfoItems.length; i++) {
            let pInfo = this.personnelInfoItems[i];
            if(index == i){
                pInfo.editable = true;
                pInfo.readOnly = false;
            }else{
                pInfo.readOnly = true;
                pInfo.editable = false;
            }
            this.personnelInfoItems[i] = pInfo;
        }
        this.f42Entry.personnelInfoList = this.personnelInfoItems;
    }

    handlepersonnelDelete(event){
        var index = event.currentTarget.dataset.index;
        this.personnelInfoItems.splice(index,1);
        this.f42Entry.personnelInfoList = this.personnelInfoItems;
    }

    handleAddotherPILine(){
        for(let i=0; i<this.otherpersonnelInfoItems.length; i++) {
            var pInfo = this.otherpersonnelInfoItems[i];
            pInfo.editable = false;
            pInfo.readOnly = true;
            this.otherpersonnelInfoItems[i] = pInfo;
        }
        this.f42Entry.otherpersonnelInfoList = this.otherpersonnelInfoItems;

        var p = new Object();
        p.editable = true;
        p.readOnly = false;
        p.MACSID  = this.f42Entry.agency.MACS_ID__c;
        p.startDate = this.f42Entry.DI_committedtoIncident;
        p.startTime = this.f42Entry.DI_committedtoIncidentTime;
        p.endDate = this.f42Entry.DI_returnfromIncident ? this.f42Entry.DI_returnfromIncident : this.f42Entry.DI_reDispatched;
        p.endTime = this.f42Entry.DI_returnfromIncidentTime ? this.f42Entry.DI_returnfromIncidentTime : this.f42Entry.DI_reDispatchedTime;
        this.otherpersonnelInfoItems.push(p);
        this.f42Entry.otherpersonnelInfoList = this.otherpersonnelInfoItems;
    }

    handleotherPersonnelInfoUpdate(event){
        var index = event.currentTarget.dataset.index;
        var tarName = '';
        tarName =  event.target.name;
        var pInfo = this.otherpersonnelInfoItems[index];
        if(tarName === 'cdf' || tarName === 'p2p' || tarName === 'baseRate'){
            pInfo[tarName] = event.target.checked;
            if(tarName === 'cdf'){
                pInfo.MACSID = 'CDF';
            }
        }else{
            pInfo[tarName] = event.target.value;
        }
        this.otherpersonnelInfoItems[index] = pInfo;
        this.f42Entry.otherpersonnelInfoList = this.otherpersonnelInfoItems;
    }

    handleotherpersonnelEdit(event){
        var index = event.currentTarget.dataset.index;
        for(let i=0; i<this.otherpersonnelInfoItems.length; i++) {
            let pInfo = this.otherpersonnelInfoItems[i];
            if(index == i){
                pInfo.editable = true;
                pInfo.readOnly = false;
            }else{
                pInfo.readOnly = true;
                pInfo.editable = false;
            }
            this.otherpersonnelInfoItems[i] = pInfo;
        }
        this.f42Entry.otherpersonnelInfoList = this.otherpersonnelInfoItems;
    }

    handleotherpersonnelDelete(event){
        var index = event.currentTarget.dataset.index;
        this.otherpersonnelInfoItems.splice(index,1);
        this.f42Entry.otherpersonnelInfoList = this.otherpersonnelInfoItems;
    }

    handleAddActualHoursLine(){
        this.actualHoursItems.push(new Object());
    }

    handleActualHoursUpdate(event){
        var index = event.currentTarget.dataset.index;
        var tarName = '';
        tarName =  event.target.name;
        var hInfo = this.actualHoursItems[index];
        hInfo[tarName] = event.target.value;
        if(hInfo.startTime && hInfo.endTime){
            let mathDiff = 0;
            let hrs = 0;
            let mins = 0;
            var totalHrs = 0;
            mathDiff = hInfo.endTime - hInfo.startTime;
            if(mathDiff.toString().length <  3){
                hrs = 0;
                mins = (mathDiff)/60;
                totalHrs =  mins.toFixed(2);
                
            }
            if(mathDiff.toString().length === 3){
                hrs = mathDiff.toString().slice(0,1);
                mins = (mathDiff.toString().slice(-2))/60;
                totalHrs = (parseFloat(hrs) + parseFloat(mins)).toFixed(2);
            }
            if(mathDiff.toString().length === 4){
                hrs = mathDiff.toString().slice(0,2);
                mins = (mathDiff.toString().slice(-2))/60;
                totalHrs = (parseFloat(hrs) + parseFloat(mins)).toFixed(2);
            }
            hInfo.totalHours = totalHrs;
        }

        this.actualHoursItems[index] = hInfo;
        this.f42Entry.actualHoursList = this.actualHoursItems;
        this.actualHoursTotal = 0;
        for(let i=0; i<this.actualHoursItems.length; i++){
            let act = this.actualHoursItems[i];
            if(act.totalHours){
                let actH = parseFloat(act.totalHours);
                this.actualHoursTotal = parseFloat(this.actualHoursTotal) + actH;
                this.actualHoursTotal = this.actualHoursTotal.toFixed(2);
            }

        }
    }

    handleActualHoursDelete(event){
        var index = event.currentTarget.dataset.index;
        this.actualHoursItems.splice(index,1);
        this.f42Entry.actualHoursList = this.actualHoursItems;
        this.actualHoursTotal = 0;
        for(let i=0; i<this.actualHoursItems.length; i++){
            let act = this.actualHoursItems[i];
            if(act.totalHours){
                let actH = parseFloat(act.totalHours);
                this.actualHoursTotal = parseFloat(this.actualHoursTotal) + actH;
                this.actualHoursTotal = this.actualHoursTotal.toFixed(2);
            }
        }
    }

    handleAddComment(){
        this.comments.push(new Object());
    }

    handleCommentsUpdate(event){
        var index = event.currentTarget.dataset.index;
        var tarName = '';
        tarName =  event.target.name;
        var cInfo = this.comments[index];
        cInfo[tarName] = event.target.value;
        this.comments[index] = cInfo;
        this.f42Entry.comments = this.comments;
    }

    handleCommentsDelete(event){
        var index = event.currentTarget.dataset.index;
        this.comments.splice(index,1);
        this.f42Entry.comments = this.comments;
    }



    handleSave(){
        if(this.validateonSave(false) === true){
            this.save('Save Button');
        }
    }

    handleSelect(event) {
        const selected = event.detail.name;
        this.errorMessages = [];
        this.showErrorMessage = false;
        this.currentContent = selected;
        this.selectedItem = selected;

        if(this.currentContent !== ''){
            this.buttonsEnabled   = true;
        }
        if(this.currentContent === 'incident_info_paying_agency'){
            this.submitEnabled   = true;
            this.saveandNextEnabled = false;
        }else{
            this.submitEnabled   = false;
            this.saveandNextEnabled = true;
        }
        
    }

    handleSaveandNext(){
        this.submitEnabled   = false;
        if(this.validateonSave(false) === true){
            this.save('navigation Change');
            if(this.currentContent === 'agency_incident'){
                this.currentContent = 'dispatch_info';
                this.selectedItem = 'dispatch_info';
            }else if(this.currentContent === 'dispatch_info'){
                this.currentContent = 'dispatch_from';
                this.selectedItem = 'dispatch_from';
            }else if(this.currentContent === 'dispatch_from'){
                this.currentContent = 'dispatch_to';
                this.selectedItem = 'dispatch_to';
            }else if(this.currentContent === 'dispatch_to'){
                this.currentContent = 'overhead';
                this.selectedItem = 'overhead';
            }else if(this.currentContent === 'overhead'){
                this.currentContent = 'support_vehicle_info';
                this.selectedItem = 'support_vehicle_info';
            }else if(this.currentContent === 'support_vehicle_info'){
                this.currentContent = 'equipment_resource_info';
                this.selectedItem = 'equipment_resource_info';
            }else if(this.currentContent === 'equipment_resource_info'){
                this.currentContent = 'personnel_info';
                this.selectedItem = 'personnel_info';
            }else if(this.currentContent === 'personnel_info'){
                this.currentContent = 'comments';
                this.selectedItem = 'comments';
            }else if(this.currentContent === 'comments'){
                this.currentContent = 'supply_number';
                this.selectedItem = 'supply_number';
            }else if(this.currentContent === 'supply_number'){
                this.currentContent = 'responding_agency_info';
                this.selectedItem = 'responding_agency_info';
            }else if(this.currentContent === 'responding_agency_info'){
                this.currentContent = 'incident_info_paying_agency';
                this.selectedItem = 'incident_info_paying_agency';
            }

            if(this.currentContent === 'incident_info_paying_agency'){
                this.submitEnabled   = true;
                this.saveandNextEnabled = false;
            }else{
                this.saveandNextEnabled = true;
            }
            this.buttonsEnabled = true;
        }
    }

    save(originofSave){
        this.buttonDisabled = true;
        let PA_signatureBlob = '';
        let RA_signatureBlob = '';
         if(this.currentContent === 'incident_info_paying_agency' && this.showPASign === true){
            PA_signatureBlob = this.template.querySelector('[data-id="PA_signature"]').getSignatureBlob();
        }
        if(!PA_signatureBlob){
            PA_signatureBlob = '';
        }
      if(this.currentContent === 'responding_agency_info' && this.showRASign === true){
            RA_signatureBlob = this.template.querySelector('[data-id="RA_signature"]').getSignatureBlob();
        }
        if(!RA_signatureBlob){
            RA_signatureBlob = '';
        }
        this.executeAction(saveF42, {
            'wrapper'           : JSON.stringify(this.f42Entry),
            PAsignatureBlob     : PA_signatureBlob,
            RAsignatureBlob     : RA_signatureBlob,
            saveorSubmit        : 'Save'
        },(response) => {
            this.f42Entry = response;
            this.showSuccessNotification('Success', 'Your Entry is Saved');
            this.buttonDisabled = false;
        });
    }
    openSubmitModal(){
        this.isSubmitModalOpen = true;
    }

    validateonSave(isSubmit){
        this.showErrorMessage = false;
        this.errorMessages = [];

        //1-4 Agency/Incident
        if(this.currentContent === 'agency_incident' || isSubmit){
            if(this.f42Entry.agency.Id === '' || this.f42Entry.agency.Id === undefined){
                this.errorMessages.push('Agency selection is required');
            }
            if(this.f42Entry.incident.Id === '' || this.f42Entry.incident.Id === undefined){
                this.errorMessages.push('Incident selection is required');
            }
            if(this.f42Entry.strikeTeam === '' || this.f42Entry.strikeTeam === undefined){
                this.errorMessages.push('Strike team/ taskforce is required');
            }
            if(this.f42Entry.incidentRequestNumber === '' || this.f42Entry.incidentRequestNumber === undefined){
                this.errorMessages.push('Incident Request Number is required');
            }

        }

        //5. Dispatch Information
        if(this.currentContent === 'dispatch_info' || isSubmit){
            if((this.f42Entry.DI_committedtoIncidentTime && !this.f42Entry.DI_committedtoIncident) ||
                (!this.f42Entry.DI_committedtoIncidentTime && this.f42Entry.DI_committedtoIncident)){
                    this.errorMessages.push('Please fill both Date and Time fields for committed to Incident');
            }
            if((this.f42Entry.DI_returnfromIncidentTime && !this.f42Entry.DI_returnfromIncident) ||
                (!this.f42Entry.DI_returnfromIncidentTime && this.f42Entry.DI_returnfromIncident)){
                    this.errorMessages.push('Please fill both Date and Time fields for Return from Incident');
            }
            if((this.f42Entry.DI_reDispatchedTime && !this.f42Entry.DI_reDispatched) ||
                (!this.f42Entry.DI_reDispatchedTime && this.f42Entry.DI_reDispatched)){
                this.errorMessages.push('Please fill both Date and Time fields for Redispatched');
            }

            if(!this.f42Entry.DI_returnfromIncidentTime  && !this.f42Entry.DI_reDispatchedTime ){
                this.errorMessages.push('Either Return from Incident or Redispatched have to be filled');
            }
            if(this.f42Entry.DI_returnfromIncidentTime  && this.f42Entry.DI_reDispatchedTime ){
                this.errorMessages.push('Either Return from Incident or Redispatched have to be filled but not both');
            }
            if(!this.f42Entry.DI_committedtoIncidentTime){
                this.errorMessages.push('Committed to Incident is required.');
            }
            if(this.f42Entry.DI_committedtoIncident && this.f42Entry.DI_committedtoIncidentTime 
                && this.f42Entry.DI_reDispatchedTime && this.f42Entry.DI_reDispatched){
                    if(this.f42Entry.DI_committedtoIncident > this.f42Entry.DI_reDispatched){
                        this.errorMessages.push('Committed to Incident Date cannot be greater than Redispatched Date.');
                    }
                    if(this.f42Entry.DI_committedtoIncident == this.f42Entry.DI_reDispatched && 
                        Number(this.f42Entry.DI_committedtoIncidentTime) > Number(this.f42Entry.DI_reDispatchedTime)){
                            this.errorMessages.push('Redispatched Time have to greater than committed to incident time.');
                    }
            }
            if(this.f42Entry.DI_committedtoIncident && this.f42Entry.DI_committedtoIncidentTime 
                && this.f42Entry.DI_returnfromIncidentTime && this.f42Entry.DI_returnfromIncident){
                    if(this.f42Entry.DI_committedtoIncident > this.f42Entry.DI_returnfromIncident){
                        this.errorMessages.push('Committed to Incident Date cannot be greater than Return from Incident Date.');
                    }
                    if(this.f42Entry.DI_committedtoIncident == this.f42Entry.DI_returnfromIncident && 
                        Number(this.f42Entry.DI_committedtoIncidentTime) > Number(this.f42Entry.DI_returnfromIncidentTime)){
                            this.errorMessages.push('Return from Incident Time have to greater than committed to incident time.');
                    }
            }

            if(this.f42Entry.DI_committedtoIncidentTime){
                let chours = this.f42Entry.DI_committedtoIncidentTime.slice(0,2);
                let cmins = this.f42Entry.DI_committedtoIncidentTime.slice(-2);
                if(Number(chours) > 23){
                    this.errorMessages.push('Committed to Incident time hours cannot be more than 23');
                }
                if(Number(cmins) > 59){
                    this.errorMessages.push('Committed to Incident time minutes cannot be more than 59');
                }
            }
            if(this.f42Entry.DI_returnfromIncidentTime){ 
                let rthours = this.f42Entry.DI_returnfromIncidentTime.slice(0,2);
                let rtmins = this.f42Entry.DI_returnfromIncidentTime.slice(-2);
                if(Number(rthours) > 23){
                    this.errorMessages.push('Return from Incident time hours cannot be more than 23');
                }
                if(Number(rtmins) > 59){
                    this.errorMessages.push('Return from Incident time minutes cannot be more than 59');
                }
            }
            if(this.f42Entry.DI_reDispatchedTime){
                let rdhours = this.f42Entry.DI_reDispatchedTime.slice(0,2);
                let rdmins = this.f42Entry.DI_reDispatchedTime.slice(-2);
                if(Number(rdhours) > 23){
                    this.errorMessages.push('Resdispatched time hours cannot be more than 23');
                }
                if(Number(rdmins) > 59){
                    this.errorMessages.push('Redispatched time minutes cannot be more than 59');
                }
            }
        }

        //8. Overhead
        if(this.currentContent === 'overhead' || isSubmit){
            if(this.f42Entry.OH_overheadType === 'Overhead Position' && 
                (!this.f42Entry.OH_icsTitle.Id &&  !this.f42Entry.OH_otherICStitle)){
                this.errorMessages.push('Either ICS Title or Other ICS Title is required');
            }
        }

         //9-10. Support Vehicle Information
         if(this.currentContent === 'support_vehicle_info' || isSubmit ){
            if(this.f42Entry.SV_vehicleOwnership === 'POV' && !this.f42Entry.SV_licenseplateNumber){
                this.errorMessages.push('For POV, License Number is required');
            }
            if(this.f42Entry.SV_vehicleOwnership === 'POV' && !this.f42Entry.PO_odometerStart && !this.f42Entry.PO_odometerEnd){
                this.errorMessages.push('For POV, Beginning and Ending Odometer readings are required');
            }
            if(this.f42Entry.SV_vehicleOwnership === 'Agency' && !this.f42Entry.SV_licenseplateNumber){
                this.errorMessages.push('For Agency, License Number is required');
            }
            if(this.f42Entry.SV_vehicleOwnership === 'Agency' && !this.f42Entry.SV_vehicleType){
                this.errorMessages.push('For Agency, Type is required');
            }
            if(this.f42Entry.SV_vehicleOwnership === "CDF/OES" && !this.f42Entry.SV_licenseplateNumber){
                this.errorMessages.push('For CDF/OES, License Number is required');
            }
            if(this.f42Entry.SV_vehicleOwnership === "CDF/OES" && !this.f42Entry.SV_vehicleType){
                this.errorMessages.push('For CDF/OES, Type is required');
            }

            if(this.f42Entry.SV_vehicleOwnership  === 'Agency' || this.f42Entry.SV_vehicleOwnership  === 'CDF/OES'){
                this.f42Entry.PO_odometerStart = '';
                this.f42Entry.PO_odometerEnd = '';
                this.f42Entry.PO_totalMiles = '';
            }
            if(this.f42Entry.SV_vehicleOwnership  === 'POV'){
                this.f42Entry.SV_vehicleType = '';
            }
            if(this.f42Entry.SV_vehicleOwnership  === 'Rental'){
                this.f42Entry.PO_odometerStart = '';
                this.f42Entry.PO_odometerEnd = '';
                this.f42Entry.PO_totalMiles = '';
                this.f42Entry.SV_vehicleType = '';
                this.f42Entry.SV_licenseplateNumber = '';
            }
        }

        //12-13 Personnel Info
        if(this.currentContent === 'personnel_info' || isSubmit){
            if(!this.f42Entry.PI_numberofPersonnel){
                this.errorMessages.push('Number of personnel on apparatus is required');
            }
            var actualHoursReq = false;
            var fieldMissing = false;
            var timeError = false;

            for(let i=0; i<this.personnelInfoItems.length; i++) {
                var pInfo = this.personnelInfoItems[i];
                if(!pInfo.fullName || !pInfo.MACSID || !pInfo.jobTitle ||
                    !pInfo.ssn || !pInfo.startDate || !pInfo.startTime ||
                    !pInfo.endDate || !pInfo.endTime){

                        fieldMissing = true;
                }

                if(pInfo.startTime){
                    let sHours = pInfo.startTime.slice(0,2);
                    let sMins = pInfo.startTime.slice(-2);
                    if(Number(sHours) > 23 || Number(sMins) > 59){
                        timeError = true;
                    }
                }
                if(pInfo.endTime){
                    let eHours = pInfo.endTime.slice(0,2);
                    let eMins = pInfo.endTime.slice(-2);
                    if(Number(eHours) > 23 || Number(eMins) > 59){
                        timeError = true;
                    }
                }
                if(pInfo.startDate && pInfo.endDate){
                    if(pInfo.startDate > pInfo.endDate){
                        timeError = true;
                    }
                }
                if(pInfo.startDate && pInfo.endDate && pInfo.startTime  && pInfo.endTime){
                    if(pInfo.startDate == pInfo.endDate && (pInfo.startTime > pInfo.endTime)){
                        timeError = true;
                    }
                }
                if(pInfo.p2p === false && pInfo.MACSID !== 'CDF'){
                    actualHoursReq = true;
                }
            }
            if(fieldMissing === true){
                this.errorMessages.push('Full Name, MACSID, SSN, Job Title, Start and End time are required for all line items in Personnel section');
            }
            if(timeError === true){
                this.errorMessages.push('Please check the start and end date/time entered in the line items in Personnel Section. Start date cannot be greater than end date. Start time cannot be greater than end time for the same day. Hours cannot be more than 23 and minutes can be more than 59.');
            }
            if(this.f42Entry.actualHoursList.length === 0 && actualHoursReq === true){
                this.errorMessages.push('Actual Hours have to be entered when atleast one of the portal-portal checkbox is false in personnel section');
            
            }

            var otheractualHoursReq = false;
            var otherfieldMissing = false;
            var othertimeError = false;

            for(let i=0; i<this.otherpersonnelInfoItems.length; i++) {
                var pInfo = this.otherpersonnelInfoItems[i];
                if(!pInfo.fullName || !pInfo.MACSID || !pInfo.jobTitle ||
                    !pInfo.ssn || !pInfo.startDate || !pInfo.startTime ||
                    !pInfo.endDate || !pInfo.endTime){

                        otherfieldMissing = true;
                }
                if(pInfo.startTime){
                    let sHours = pInfo.startTime.slice(0,2);
                    let sMins = pInfo.startTime.slice(-2);
                    if(Number(sHours) > 23 || Number(sMins) > 59){
                        othertimeError = true;
                    }
                }
                if(pInfo.endTime){
                    let eHours = pInfo.endTime.slice(0,2);
                    let eMins = pInfo.endTime.slice(-2);
                    if(Number(eHours) > 23 || Number(eMins) > 59){
                        othertimeError = true;
                    }
                }
                if(pInfo.startDate && pInfo.endDate){
                    if(pInfo.startDate > pInfo.endDate){
                        othertimeError = true;
                    }
                }
                if(pInfo.startDate && pInfo.endDate && pInfo.startTime  && pInfo.endTime){
                    if(pInfo.startDate == pInfo.endDate && (pInfo.startTime > pInfo.endTime)){
                        othertimeError = true;
                    }
                }
                if(pInfo.MACSID !== 'CDF'){
                    otheractualHoursReq = true;
                }
            }

            if(otherfieldMissing === true){
                this.errorMessages.push('Full Name, MACSID, SSN, Job Title, Start and End time are required for all line items in other Personnel Section');
            }
            if(othertimeError === true){
                this.errorMessages.push('Please check the start and end date/time entered in the line items in other Personnel Section. Start date cannot be greater than end date. Start time cannot be greater than end time for the same day. Hours cannot be more than 23 and minutes cannot be more than 59.');
            }
            if(this.f42Entry.actualHoursList.length === 0 && otheractualHoursReq === true){
                this.errorMessages.push('Actual Hours have to be entered when atleast one line item is addded in Other Personnel Section');
            }

            if(fieldMissing === false && timeError === false){
                for(let i=0; i<this.personnelInfoItems.length; i++) {
                    var pInfo = this.personnelInfoItems[i];
                    pInfo.editable = false;
                    pInfo.readOnly = true;
                    this.personnelInfoItems[i] = pInfo;
                }
                this.f42Entry.personnelInfoList = this.personnelInfoItems;
            }
            
            if(otherfieldMissing === false && othertimeError === false){
                for(let i=0; i<this.otherpersonnelInfoItems.length; i++) {
                    let pInfo = this.otherpersonnelInfoItems[i];
                    pInfo.editable = false;
                    pInfo.readOnly = true;
                    this.otherpersonnelInfoItems[i] = pInfo;
                }
                this.f42Entry.otherpersonnelInfoList = this.otherpersonnelInfoItems;
            }
        }

        //14 Comments
        if(this.currentContent === 'comments' || isSubmit){
            var valid = true;
            var timeValid = true;
            for(let i=0; i<this.comments.length; i++) {
                var com = this.comments[i];
                if(!com.dateofComment || !com.timeofComment || !com.comment){
                    valid = false;
                    break;
                }
                if(com.timeofComment){
                    let cHours = com.timeofComment.slice(0,2);
                    let cMins = com.timeofComment.slice(-2);
                    if(Number(cHours) > 23 || Number(cMins) > 59){
                        timeValid = false;
                        break;
                    }
                }
            }
            if(valid === false){
                this.errorMessages.push('Date, time and Comment is required for each line. Please use Del option if a line is not valid');
            }
            if(timeValid === false){
                this.errorMessages.push('Time: Hours Cannot be greater than 23 and minutes cannot be greater than 59');
            }
        }

        //15-16 Supply Number
        if(this.currentContent === 'supply_number' || isSubmit){
            if(this.f42Entry.LD_claim === 'Yes' && !this.f42Entry.SN_supplyNumber){
                this.errorMessages.push('Supply number is required when loss/damage claim is yes');
            }
        }

        //18 Incident Info - Paying Agency
        if(this.currentContent === 'incident_info_paying_agency' || isSubmit){
            if(!this.f42Entry.PA_payingAgency  && !this.f42Entry.PA_payingAgencyOther){
                this.errorMessages.push('Paying Agency or Other is required.');
            }
            if(!this.f42Entry.PA_printedName){
                this.errorMessages.push('Printed Name is required.');
            }
            if(!this.f42Entry.PA_printedNameDate){
                this.errorMessages.push('Date is required.');
            }
            if(!this.f42Entry.PA_icsPosition && !this.f42Entry.PA_otherIcsPosition){
                this.errorMessages.push('ICS Position title or Other Position title is required');
            }
            if(this.showPASign === true && !this.template.querySelector('[data-id="PA_signature"]').getSignatureBlob()){
                this.errorMessages.push('Signature of Authorized Incident Personnel is required. Please click reset and try if you are unable to sign');
            }
        }

        if(this.errorMessages.length > 0){
            this.showErrorMessage = true;
            return false;
        }
        return true;
    }

    validateData(){
        this.errorMessages = [];
        this.isSubmitModalOpen = true;
    }

    submitData(){
        this.buttonDisabled = true;
        if(this.validateonSave(true) === true){
            let PA_signatureBlob = '';
            let RA_signatureBlob = '';
            if(this.currentContent === 'incident_info_paying_agency' && this.showPASign === true){
                PA_signatureBlob = this.template.querySelector('[data-id="PA_signature"]').getSignatureBlob();
            }
            if(!PA_signatureBlob){
                PA_signatureBlob = '';
            }
            if(this.currentContent === 'responding_agency_info' && this.showRASign === true){
                RA_signatureBlob = this.template.querySelector('[data-id="RA_signature"]').getSignatureBlob();
            }
            if(!RA_signatureBlob){
                RA_signatureBlob = '';
            }
            this.executeAction(saveF42, {
                'wrapper'           : JSON.stringify(this.f42Entry),
                PAsignatureBlob     : PA_signatureBlob,
                RAsignatureBlob     : RA_signatureBlob,
                saveorSubmit        : 'Submit'
            },(response) => {
                this.f42Entry = response;
                this.buttonDisabled = false;
                this.isSubmitModalOpen = false;
                this.personnelInfoItems = this.f42Entry.personnelInfoList;
                this.otherpersonnelInfoItems = this.f42Entry.otherpersonnelInfoList;
                this.actualHoursItems   = this.f42Entry.actualHoursList;
                this.comments           = this.f42Entry.comments;
                this.showSuccessNotification('Success', 'Your Entry is Submitted and sent for CALOES approval');
                this.f42entryId                 = '';
                this.initData();
                
                
            });
        }else{
            this.buttonDisabled = false;
            this.isSubmitModalOpen = false;
        }
    }

    /*
        Method to calculate the miles from odometer values
    */
    calculateOdometer(event){
        var fieldName = event.target.name;
        if(fieldName === 'PO_odometerStart'){
            this.f42Entry.PO_odometerStart = event.detail.value;
        }
        if(fieldName === 'PO_odometerEnd'){
            this.f42Entry.PO_odometerEnd = event.detail.value;
        }

        if(this.f42Entry.PO_odometerEnd && this.f42Entry.PO_odometerStart){
            this.f42Entry.PO_totalMiles =  this.f42Entry.PO_odometerEnd - this.f42Entry.PO_odometerStart;
        }else{
            this.f42Entry.PO_totalMiles = 0;
        }

    }

     /*
        Method to handle Paying agency other value
    */
    handlePayingAgencyOther(event){
            var fieldName = event.target.name;
            if(fieldName === 'PA_payingAgency'){
                this.f42Entry.PA_payingAgency = event.detail.value;
                if(this.f42Entry.PA_payingAgency !== 'OTHER'){
                    this.f42Entry.PA_payingAgencyOther = '';
                }
            }else{
                this.f42Entry.PA_payingAgency = 'OTHER';
                this.f42Entry.PA_payingAgencyOther = event.detail.value;
            }
        }

    get showPAOther(){
        if(this.f42Entry.PA_payingAgency ){
            return this.f42Entry.PA_payingAgency.includes('OTHER');
        }

        return false;
    }

    get isagency_incident(){
        if(this.currentContent=='agency_incident'){
            return true;
        }
        return false;
        //return true;
    }

    get isdispatch_info(){
        if(this.currentContent=='dispatch_info'){
            return true;
        }
        return false;
    }

    get isdispatch_from(){
        if(this.currentContent=='dispatch_from'){
            return true;
        }
        return false;
    }

    get isdispatch_to(){
        if(this.currentContent=='dispatch_to'){
           
            return true;
        }
        return false;
    }

    get isoverhead(){
        if(this.currentContent=='overhead'){
           
            return true;
        }
        return false;
    }

    get issupport_vehicle_info(){
        if(this.currentContent=='support_vehicle_info'){
            return true;
        }
        return false;
    }

    get isprivately_owned_vehicle(){
        if(this.currentContent=='privately_owned_vehicle'){
            return true;
        }
        return false;
    }

    get isequipment_resource_info(){
        if(this.currentContent=='equipment_resource_info'){
            return true;
        }
        return false;
    }

    get ispersonnel_info(){
        if(this.currentContent=='personnel_info'){
            return true;
        }
        return false;
    }

    get iscomments(){
        if(this.currentContent=='comments'){
            return true;
        }
        return false;
    }

    get isloss_damage(){
        if(this.currentContent=='loss_damage'){
            return true;
        }
        return false;
    }

    get issupply_number(){
        if(this.currentContent=='supply_number'){
            return true;
        }
        return false;
    }

    get isresponding_agency_info(){
        if(this.currentContent=='responding_agency_info'){
            return true;
        }
        return false;
    }

    get isincident_info_paying_agency(){
        if(this.currentContent=='incident_info_paying_agency'){
            return true;
        }
        return false;
    }

   

    get overheadTypeoptions() {
        return [
            { label: 'STEN', value: 'STEN' },
            { label: 'STEN(T)', value: 'STEN(T)' },
            { label: 'TFLD', value: 'TFLD' },
            { label: 'TFLD(T)', value: 'TFLD(T)' },
            { label: 'Overhead Position', value: 'Overhead Position' }
        ];
    }

    get lossDamageOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
            
        ];
    }

    get vehicleOwnerTypeoptions() {
        return [
            { label: 'Agency', value: 'Agency' },
            { label: 'POV', value: 'POV' },
            { label: 'Rental', value: 'Rental' },
            { label: 'CDF/OES', value: 'CDF/OES' }
        ];
    }

    get vehicleTypeTypeoptions() {
        return [
            { label: 'Sedan', value: 'Sedan' },
            { label: 'SUV', value: 'SUV' },
            { label: 'Van', value: 'Van' },
            { label: 'Pick-Up (1/2 Ton)', value: 'Pick-Up (1/2 Ton)' },
            { label: 'Other (3/4 Ton & Above)', value: 'Other (3/4 Ton & Above)' }
        ];
    }

    get payingAgencyoptions() {
        return [
            { label: 'CAL OES', value: 'CAL OES' },
            { label: 'CAL FIRE', value: 'CAL FIRE' },
            { label: 'USFS', value: 'USFS' },
            { label: 'BLM', value: 'BLM' },
            { label: 'NPS', value: 'NPS'},
            { label: 'BIA', value: 'BIA' },
            { label: 'FWS', value: 'FWS'},
            { label: 'LRA/MMA', value: 'LRA/MMA'},
            { label: 'OTHER', value: 'OTHER'}
        ];
    }

    get mobilizationCenterOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
            
        ];
    }

    get ertypeOptions(){
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5'},
            { label: '6', value: '6' },
            { label: '7', value: '7'},
            { label: 'WT-1', value: 'WT-1'},
            { label: 'WT-2', value: 'WT-2'}
        ];
    }

    get ercdfoesOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
            
        ];
    }

    get pidocumentOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
            
        ];
    }

    get getYesNoOptions() {
        return [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        },
        ];
    }

    clearOverheadType(){
        this.f42Entry.OH_overheadType = '';
        this.overheadSelection = [];
        this.f42Entry.OH_icsTitle = {};
        this.template.querySelector('[data-lookup="ICS_Title__c"]').handleClearSelection();
        this.f42Entry.OH_otherICStitle = '';
    }

    clearVehicleOwnership(){
        this.f42Entry.SV_vehicleOwnership = '';
        this.f42Entry.SV_licenseplateNumber = '';
        this.f42Entry.SV_vehicleType = '';
        this.f42Entry.PO_odometerStart = '';
        this.f42Entry.PO_odometerEnd = '';
        this.f42Entry.PO_totalMiles = '';
    }

    clearVehicleType(){
        this.f42Entry.SV_vehicleType = '';
    }
    clearErType(){
        this.f42Entry.ER_type = '';
    }
    clearPayingAgency(){
        this.f42Entry.PA_payingAgency = '';
        this.f42Entry.PA_payingAgencyOther = '';
    }

    clearFemaCode(){
        this.f42Entry.ER_femaCode = '';
        this.template.querySelector('[data-lookup="FEMA_CODE__C"]').handleClearSelection();
    }

    clearSpecialEquipment(){
        this.f42Entry.ER_specialEquipment = {};
        this.template.querySelector('[data-lookup="Agency_Special_Equipment"]').handleClearSelection();
    }

    get showOdometer(){
        return this.f42Entry.SV_vehicleOwnership === 'POV';
    }

    get showSVType(){
        return this.f42Entry.SV_vehicleOwnership === 'Agency' || this.f42Entry.SV_vehicleOwnership === 'CDF/OES';
    }

    get showSVLicense(){
        return this.f42Entry.SV_vehicleOwnership === 'Agency' || this.f42Entry.SV_vehicleOwnership === 'CDF/OES' || this.f42Entry.SV_vehicleOwnership === 'POV';
    }


    get showICStitle(){
        if(this.f42Entry.OH_overheadType){
            return this.f42Entry.OH_overheadType.includes('Overhead Position');
        }
        return false;
    }

    get showPASign(){
        if(this.f42Entry.PA_signURL !== ''){
            return false;
        }
        return true;
    }

    get showRASign(){
        if(this.f42Entry.RA_signURL !== ''){
            return false;
        }
        return true;
    }

    handlePAResign(){
        this.f42Entry.PA_signURL = '';
    }

    handleRAResign(){
        this.f42Entry.RA_signURL = '';
    }
    
    loadLookupDataOnLoad = false;
    loadagencyLookupDataOnLoad = false;
     /*
    * Searches Incidents for MARS on Agency Incident Section
    */
     handleIncidentSearch(event) {
        apexSearchIncident(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Incident field on Agency Incidentsection
    */
    handleIncidentChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.incident = response.detail.selectedItem.sObject;//assign the entire sObject so its saved in JSON
        }
    }

     /*
    * Searches Incidents for MARS on Dispatch Info Section
    */
     handleDispatchIncidentSearch(event) {
        apexSearchIncident(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Dispatch_Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Incident field on Dispatch Info section
    */
    handleDispatchIncidentChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.dispatchInfoIncident = response.detail.selectedItem.sObject;//assign the entire sObject so its saved in JSON
        }
    }

     /*
    * Searches Incidents for MARS on Dispatch From Section
    */
     handleDispatchFromIncidentSearch(event) {
        apexSearchIncident(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Dispatch_From_Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Incident field on Dispatch From section
    */
    handleDispatchFromIncidentChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.dispatchFromIncident = response.detail.selectedItem.sObject;//assign the entire sObject so its saved in JSON
        }
    }

     /*
    * Searches Incidents for MARS on Dispatch To Section
    */
     handleDispatchToIncidentSearch(event) {
        apexSearchIncident(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Dispatch_To_Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for Incident field on Dispatch To section
    */
    handleDispatchToIncidentChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.dispatchToIncident = response.detail.selectedItem.sObject;//assign the entire sObject so its saved in JSON
        }
    }


     /*
    * Searches for ICS Title field on Overhead Section
    */
     handleICSTitleSearch(event) {
        apexSearchIcsTitle(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="ICS_Title__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    
    /*
    * Lookup selection for ICS Title field on Overhead Section
    */
    handleICSTitleChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.OH_icsTitle = response.detail.selectedItem.sObject;//assign the entire sObject so its saved in JSON
            this.f42Entry.OH_otherICStitle = '';
        }
    }

    handleOHICSUpdate(event){
        const fieldName = event.target.name;
        var selector = '[data-name="'+fieldName+'"]';
        this.template.querySelectorAll(selector).forEach(eachElement => {
            this.f42Entry[eachElement.name] = eachElement.value;
        })
        this.f42Entry.OH_icsTitle = {};
        this.template.querySelector('[data-lookup="ICS_Title__c"]').handleClearSelection();
    }

     /*
    * Searches for FEMA Codes
    */
     handleFemaCodeSearch(event) {
        apexSearchFemaCode(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="FEMA_CODE__C"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for agency FEMA CODE
    */
    handleFemaCodeChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
           this.f42Entry.ER_femaCode = response.detail.selectedItem.title;
           //this.f42Entry.ER_specialEquipment = {};
           //this.template.querySelector('[data-lookup="Agency_Special_Equipment"]').handleClearSelection();
        }
    }

     /*
    * Searches for agency special equipment for equipment resource info section
    */
     handleSpecialEquipmentSearch(event) {
        event.detail.agencyId = this.f42Entry.agency.Id;
        apexSearchSpecialEquipment(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Agency_Special_Equipment"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for agency special equipment for equipment resource info section
    */
    handleSpecialEquipmentChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.ER_specialEquipment = response.detail.selectedItem.sObject;//assign the entire sObject so its saved in JSON
            //this.f42Entry.ER_femaCode = '';
            //this.template.querySelector('[data-lookup="FEMA_CODE__C"]').handleClearSelection();
        }
    }

    
    handleFireAgencySearch(event) {
        apexSearchFireAgency(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Account__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for agency special equipment for equipment resource info section
    */
    handleFireAgencyChange(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.agency = response.detail.selectedItem.sObject;
            /*this.executeAction(initialize, {agencyId: this.this.f42Entry.agency.Id}, (response) => {
                this.f42Entry                   = response;
                this.personnelInfoItems         = this.f42Entry.personnelInfoList;
                this.otherpersonnelInfoItems    = this.f42Entry.otherpersonnelInfoList;
                this.actualHoursItems           = this.f42Entry.actualHoursList;
                this.comments                   = this.f42Entry.comments;
            });*/
        }
    }

     /*
    * Searches for classification titles from salary survey
    */
     handleRankSearch(event) {
         event.detail.agencyId = this.personnelInfoItems[event.currentTarget.dataset.custom].MACSID;
        //event.detail.agencyId = this.f42Entry.agency.Id;
        apexSearchRank(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="Rank__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for classification titles from salary survey
    */
    handleRankChange(response) {
        if(response.detail != null && response.detail.selectedItem.title != undefined) {
            var pInfo = this.personnelInfoItems[response.currentTarget.dataset.custom];
            pInfo.jobTitle = response.detail.selectedItem.title;
            pInfo.p2p      = response.detail.selectedItem.sObject.P_T_P__c;
            if(response.detail.selectedItem.sObject.P_T_P__c == false){
                pInfo.p2pDisabled = true;
            }else{
                pInfo.p2pDisabled = false;
            }
            this.personnelInfoItems[response.currentTarget.dataset.custom] = pInfo;
            this.f42Entry.personnelInfoList = this.personnelInfoItems;
        }
    }

     /*
    * Searches for ICS Title field on Overhead Section
    */
     handleICSTitleSearchforPA(event) {
        apexSearchIcsTitle(event.detail)
        .then((results) => {
            this.template.querySelector('[data-lookup="ICS_Title"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    /*
    * Lookup selection for ICS Title field on Overhead Section
    */
    handleICSTitleChangeforPA(response) {
        if(response.detail != null && response.detail.selectedItem.id != undefined) {
            this.f42Entry.PA_icsPosition = response.detail.selectedItem.title;
            this.f42Entry.PA_otherIcsPosition = '';
        }
    }

    handlePAICSUpdate(event){
        const fieldName = event.target.name;
        var selector = '[data-name="'+fieldName+'"]';
        this.template.querySelectorAll(selector).forEach(eachElement => {
            this.f42Entry[eachElement.name] = eachElement.value;
        })
        this.f42Entry.PA_icsPosition = '';
        this.template.querySelector('[data-lookup="ICS_Title"]').handleClearSelection();
    }
    closeSubmitModal(){
        this.isSubmitModalOpen = false;
    }

}