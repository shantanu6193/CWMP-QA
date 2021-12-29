import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRE_APPLICATION_OBJECT from '@salesforce/schema/Pre_Application__c';
import FUNDING_AUTHORITY_FIELD from '@salesforce/schema/Pre_Application__c.Federal_entity_have_funding_authority__c';
import SUBAPPLICATION_FOR_PROJECT_FIELD from '@salesforce/schema/Pre_Application__c.Subapplication_for_project_submitted__c';
import PHYSICAL_PROJECT_WORK_FIELD from '@salesforce/schema/Pre_Application__c.Physical_project_work_already_started__c';
import SUBAPPLICANT_FOR_INFRASTRUCTURE_FIELD from '@salesforce/schema/Pre_Application__c.Subapplicant_for_infrastructure__c';
import IndependentMitigationActivity_FIELD from '@salesforce/schema/Pre_Application__c.Independent_mitigation_activity__c';
import PlanningStudiesOrFeasibilityReports_FIELD from '@salesforce/schema/Pre_Application__c.Planning_studies_or_feasibility_reports__c';
import DesignDocumentsForThisProject_FIELD from '@salesforce/schema/Pre_Application__c.Design_documents_for_this_project__c';
import ProjectRelatedToAsset_FIELD from '@salesforce/schema/Pre_Application__c.Project_related_to_asset__c';
import ProtectionForThatAsset_FIELD from '@salesforce/schema/Pre_Application__c.Protection_for_that_asset__c';
import projectInConformance_FIELD from '@salesforce/schema/Pre_Application__c.Project_in_conformance_with_latest_codes__c';
import specialFloodHazard_FIELD from '@salesforce/schema/Pre_Application__c.Project_in_a_Special_Flood_Hazard_Area__c';
import floodInsuranceProgram_FIELD from '@salesforce/schema/Pre_Application__c.Project_located_in_NFIP__c';
import isProjectSiteIdentified_FIELD from '@salesforce/schema/Pre_Application__c.Is_Project_Site_Identified__c';
import IsThisProjectPhased_FIELD from '@salesforce/schema/Pre_Application__c.Is_this_project_phased__c';
import structuresIncluded_FIELD from '@salesforce/schema/Pre_Application__c.Structures_included_in_subapplication__c';
import projectMitigate_FIELD from '@salesforce/schema/Pre_Application__c.Project_mitigate_Severe_Repetitive_Loss__c';
import programSearch from '@salesforce/apex/HMA_SearchLookupCtrl.searchProgram';
//import updateFileDetails from '@salesforce/apex/FileListController.updateFileDetails';


export default class HmaNOIProjectInfo extends Utility {

    programSelection = [];
    programRequired = [];
    loadLookupDataOnLoad = true;
    showProjectNumber;
    showFileAction = true;
    docType;
    showAllCards = true;
    recordTypeId;
    recordTypeName;
    showCardsForPlanningRelated = true;

    @wire(getObjectInfo, { objectApiName: PRE_APPLICATION_OBJECT }) objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: FUNDING_AUTHORITY_FIELD}) fundingAuthorityPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: SUBAPPLICATION_FOR_PROJECT_FIELD}) subapplicationForProjectPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: PHYSICAL_PROJECT_WORK_FIELD}) physicalProjectWorkPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: SUBAPPLICANT_FOR_INFRASTRUCTURE_FIELD}) subapplicantForInfrastructurePicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: IndependentMitigationActivity_FIELD}) independentMitigationActivityPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: PlanningStudiesOrFeasibilityReports_FIELD}) planningStudiesOrFeasibilityReportsPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: DesignDocumentsForThisProject_FIELD}) designDocumentsForThisProjectPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: ProjectRelatedToAsset_FIELD}) projectRelatedToAssetPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: ProtectionForThatAsset_FIELD}) protectionForThatAssetPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: projectInConformance_FIELD}) projectInConformancePicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: specialFloodHazard_FIELD}) specialFloodHazardPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: floodInsuranceProgram_FIELD}) floodInsuranceProgramPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: isProjectSiteIdentified_FIELD}) isProjectSiteIdentifiedPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: IsThisProjectPhased_FIELD}) IsThisProjectPhasedPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: structuresIncluded_FIELD}) structuresIncludedPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: projectMitigate_FIELD}) projectMitigatePicklistValues;


    isMultiEntry = false;
    maxSelectionSize = 20;
    errors = [];

    remainingCharsActivity = 100;
    remainingChars = 2500;
    remainingCharsScope = 2500;
    remainingCharsMitigationAction = 2000;
    remainingCharsProtection = 2000;
    remainingCharsImplimentation = 2000;
    remainingCharsSummary = 2500;
    remainingCharsWorkStarted = 2500;

    textAreaFieldChanged(event){
        if(event.target.name == 'DescribeProblem'){
            this.recordLocal.Describe_the_problem_to_be_mitigated__c = event.target.value;
            this.remainingChars = 2500 - this.recordLocal.Describe_the_problem_to_be_mitigated__c.length;
        }
        if(event.target.name == 'DescribeTheScopeOfWork'){
            this.recordLocal.Describe_the_scope_of_work__c = event.target.value;
            this.remainingCharsScope = 2500 - this.recordLocal.Describe_the_scope_of_work__c.length;
        }
        if(event.target.name == 'ActivityName'){
            this.recordLocal.Activity_TitleName__c = event.target.value;
            this.remainingCharsActivity = 100 - this.recordLocal.Activity_TitleName__c.length;
        }
        if(event.target.name == 'MitigationAction'){
            this.recordLocal.What_is_the_mitigation_action__c = event.target.value;
            this.remainingCharsMitigationAction = 2000 - this.recordLocal.What_is_the_mitigation_action__c.length;
        }
        if(event.target.name == 'NaturalHazardProtection'){
            this.recordLocal.Protection_From_Future_Natural_Hazards__c = event.target.value;
            this.remainingCharsProtection = 2000 - this.recordLocal.Protection_From_Future_Natural_Hazards__c.length;
        }
        if(event.target.name == 'ImplimentationPlan'){
            this.recordLocal.Implementation_Plan_For_Mitigation__c = event.target.value;
            this.remainingCharsImplimentation = 2000 - this.recordLocal.Implementation_Plan_For_Mitigation__c.length;
        }
        if(event.target.name == 'BriefSummary'){
            this.recordLocal.Brief_Summary__c = event.target.value;
            this.remainingCharsSummary = 2500 - this.recordLocal.Brief_Summary__c.length;
        }
        if(event.target.name == 'WorkStarted'){
            this.recordLocal.Work_started_completed_in_detail__c = event.target.value;
            this.remainingCharsWorkStarted = 2500 - this.recordLocal.Work_started_completed_in_detail__c.length;
        }
    }

    get showIdentifyTheProgramField(){
        if(this.recordLocal.Federal_entity_have_funding_authority__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Federal_entity_have_funding_authority__c == 'No') {
            this.recordLocal.If_yes_identify_the_program__c = '';
        }
        return false;
    }
    get showEntityResponsibleField(){
        if(this.recordLocal.Subapplicant_for_infrastructure__c == 'No'){
            return true;
        }
        else if(this.recordLocal.Subapplicant_for_infrastructure__c == 'Yes'){
            this.recordLocal.Entity_Responsible_For_Operation__c = '';
        }
    }
    get showProgramField(){
        if(this.recordLocal.Subapplication_for_project_submitted__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Subapplication_for_project_submitted__c == 'No') {
            this.programSelection = [];
            this.recordLocal.Program__c = '';
            //this.recordLocal.Program__r = {};
            this.recordLocal.Project_Number__c = '';
            this.showProjectNumber = false;
        }
        return false;
    }
    get showMitigationDependentField(){
        if(this.recordLocal.Independent_mitigation_activity__c == 'No') {
            return true;
        }
        else if(this.recordLocal.Independent_mitigation_activity__c == 'Yes') {
            this.Mitigation_Dependent_On__c = '';
        }
        return false;
    }
    get showWorkStartedField(){
        if(this.recordLocal.Physical_project_work_already_started__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Physical_project_work_already_started__c == 'No') {
            this.recordLocal.Work_started_completed_in_detail = '';
        }
        return false;
    }
    get showWhatIsAvailableField(){
        if(this.recordLocal.Planning_studies_or_feasibility_reports__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Planning_studies_or_feasibility_reports__c == 'No'){
            this.recordLocal.If_yes_planning_studies__c = '';
        }
        return false;
    }
    get showPercentageCompleteAreTheDesignsField(){
        if(this.recordLocal.Design_documents_for_this_project__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Design_documents_for_this_project__c == 'No') {
            this.recordLocal.Percentage_complete_are_the_designs__c = '';
        }
        return false;
    }
    get showProtectionForThatAssetField(){
        if(this.recordLocal.Project_related_to_asset__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Project_related_to_asset__c == 'No') {
            this.recordLocal.Protection_for_that_asset__c = '';
        }
        return false;
    }
    get acceptedFormats() {
         return ['.png', '.jpg', '.jpeg'];
    }
    get showPhysicalWorkField(){
        if(this.recordTypeName == 'HMGP' || (this.recordTypeName == 'BRIC'  && this.recordLocal.Application_Type__c == 'Capability and Capacity Building (C&CB)' && this.recordLocal.Project_Type__c == 'Project Scoping') || (this.recordTypeName == 'BRIC'  && this.recordLocal.Application_Type__c == 'Project') || (this.recordTypeName == 'FMA'  && (this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project' || this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project'))) {
            return true;
        }
        return false;
    }
    get showForBRICandFMA(){
        if(this.recordTypeName == 'HMGP' || (this.recordTypeName == 'BRIC'  && this.recordLocal.Application_Type__c == 'Project') || (this.recordTypeName == 'FMA'  && (this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project' || this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project'))) {
            return true;
        }
        return false;
    }
    get showProjectNotInConformance() {
        if(this.recordLocal.Project_in_conformance_with_latest_codes__c == 'No') {
            return true;
        }
        else if(this.recordLocal.Project_in_conformance_with_latest_codes__c == 'Yes') {
            this.recordLocal.Explain_why_project_not_in_conformance__c = '';
        }
        return false;
    }
    get showFloodInsuranceProgram() {
        if((this.recordTypeName == 'BRIC' && this.recordLocal.Project_in_a_Special_Flood_Hazard_Area__c == 'Yes') || this.recordTypeName == 'FMA') {
            return true;
        }
        else if(this.recordLocal.Project_in_a_Special_Flood_Hazard_Area__c == 'No') {
            this.recordLocal.National_Flood_Insurance_Program_NFIP__c = '';
            this.recordLocal.Project_located_in_NFIP__c = '';
            this.recordLocal.Structures_included_in_subapplication__c = '';
        }
        return false;
    }
    get showProjectMitigateField() {
        if(this.recordTypeName == 'FMA' && (this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project' || this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project')) {
            return true;
        }
        return false;
    }
    get hideForProblemMitigation(){
        if(this.recordTypeName == 'BRIC'  && this.recordLocal.Application_Type__c == 'Capability and Capacity Building (C&CB)' && (this.recordLocal.Project_Type__c == 'Planning-New Plan' || this.recordLocal.Project_Type__c == 'Planning-Plan Update') || (this.recordTypeName == 'FMA'  && this.recordLocal.Application_Type__c == 'Flood Hazard Mitigation Planning')) {
            this.recordLocal.Describe_the_problem_to_be_mitigated__c = '';
            this.recordLocal.What_is_the_mitigation_action__c = '';
            this.recordLocal.Protection_From_Future_Natural_Hazards__c = '';
            this.recordLocal.Implementation_Plan_For_Mitigation__c = '';
            return false;
        }
        return true;
    }
    get recordTypeBRIC() {
        if(this.recordTypeName == 'BRIC') {
            return true;
        }
        return false;
    }
    get recordTypeFMA() {
        if(this.recordTypeName == 'FMA') {
            return true;
        }
        return false;
    }
    get recordTypeHMGP() {
        if(this.recordTypeName == 'HMGP') {
            return true;
        }
        return false;
    }
    get showConformanceFields() {
        if(this.recordTypeName == 'BRIC' && (this.recordLocal.Application_Type__c == 'Project' || this.recordLocal.Project_Type__c == 'Project Scoping')) {
            return true;
        }
        return false;
    }

    get hideSpecialFloodHazardArea() {
        if(this.recordTypeName == 'BRIC' && this.recordLocal.Application_Type__c == 'Capability and Capacity Building (C&CB)' && (this.recordLocal.Project_Type__c == 'Planning-New Plan' || this.recordLocal.Project_Type__c == 'Planning-Plan Update' || this.recordLocal.Project_Type__c == 'Building Code' || this.recordLocal.Project_Type__c == 'Planning-Related Activities')) {
            return false;
        }
        return true;
    }
   /* get showForBRICandFMA(){
        if((this.RecordTypeName == 'BRIC'  && this.recordLocal.Application_Type__c == 'Project') || (this.RecordTypeName == 'FMA'  && (this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project' || this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project'))) {
            return true;
        }
        return false;
    }*/

    initData() {
         if(this.recordLocal.RecordTypeId != undefined || this.recordLocal.RecordTypeId != null) {
            this.recordTypeId = this.recordLocal.RecordTypeId;
            this.recordTypeName = this.recordLocal.RecordType.Name;
            console.log('recordTypeId----',this.recordTypeId);
            console.log('recordTypeName----',this.recordTypeName);
        }
        if(this.recordLocal.Activity_Location_Latitude__c && this.recordLocal.Activity_Location_Latitude__c != 0) {
            this.recordLocal.Activity_Location__Latitude__s = '+' + this.recordLocal.Activity_Location_Latitude__c;
        }

        if(this.recordLocal.Activity_Location_Longitude__c && this.recordLocal.Activity_Location_Longitude__c != 0) {
            this.recordLocal.Activity_Location__Longitude__s = this.recordLocal.Activity_Location_Longitude__c;
        }

        if(this.recordLocal.Application_Type__c == 'Planning') {
            this.showAllCards = false;
            this.showCardsForPlanningRelated = false;
            // nullifying the fields if Application Type is Planning or Planning-Related
            let fieldsToBlank = ['Federal_entity_have_funding_authority__c','If_yes_identify_the_program__c','Physical_project_work_already_started__c','Work_started_completed_in_detail__c','Subapplicant_for_infrastructure__c','Entity_Responsible_For_Operation__c','Independent_mitigation_activity__c','Mitigation_Dependent_On__c','Planning_studies_or_feasibility_reports__c','If_yes_planning_studies__c','Design_documents_for_this_project__c','Percentage_complete_are_the_designs__c','Project_related_to_asset__c','Protection_for_that_asset__c','Describe_the_problem_to_be_mitigated__c','Future_Hazard_Event_Trigger__c','What_is_the_mitigation_action__c','Protection_From_Future_Natural_Hazards__c','Implementation_Plan_For_Mitigation__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
        if(this.recordLocal.Application_Type__c == 'Planning-related') {
            this.showAllCards = false;
            this.showCardsForPlanningRelated = true;
            // nullifying the fields if Application Type is Planning or Planning-Related
            let fieldsToBlank = ['Federal_entity_have_funding_authority__c','If_yes_identify_the_program__c','Physical_project_work_already_started__c','Work_started_completed_in_detail__c','Subapplicant_for_infrastructure__c','Entity_Responsible_For_Operation__c','Independent_mitigation_activity__c','Mitigation_Dependent_On__c','Planning_studies_or_feasibility_reports__c','If_yes_planning_studies__c','Design_documents_for_this_project__c','Percentage_complete_are_the_designs__c','Project_related_to_asset__c','Protection_for_that_asset__c','Future_Hazard_Event_Trigger__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
        if(!this.recordLocal.Brief_Summary__c){
            this.recordLocal.Brief_Summary__c = 'This <insert project type> project will reduce or prevent <explain damage> resulting from <describe hazard> by <explain the mitigation action>';
        }
        if(this.recordLocal.Describe_the_problem_to_be_mitigated__c){
            this.remainingChars = 2500 - this.recordLocal.Describe_the_problem_to_be_mitigated__c.length;
        }
        if(this.recordLocal.Describe_the_scope_of_work__c){
            this.remainingCharsScope = 2500 - this.recordLocal.Describe_the_scope_of_work__c.length;
        }
        if(this.recordLocal.Activity_TitleName__c){
            this.remainingCharsActivity = 100 - this.recordLocal.Activity_TitleName__c.length;
        }
        if(this.recordLocal.What_is_the_mitigation_action__c){
            this.remainingCharsMitigationAction = 2000 - this.recordLocal.What_is_the_mitigation_action__c.length;
        }
        if(this.recordLocal.Protection_From_Future_Natural_Hazards__c){
            this.remainingCharsProtection = 2000 - this.recordLocal.Protection_From_Future_Natural_Hazards__c.length;
        }
        if(this.recordLocal.Implementation_Plan_For_Mitigation__c){
            this.remainingCharsImplimentation = 2000 - this.recordLocal.Implementation_Plan_For_Mitigation__c.length;
        }
        if(this.recordLocal.Brief_Summary__c){
            this.remainingCharsSummary = 2500 - this.recordLocal.Brief_Summary__c.length;
        }
        if(this.recordLocal.Work_started_completed_in_detail__c){
            this.remainingCharsWorkStarted = 2500 - this.recordLocal.Work_started_completed_in_detail__c.length;
        }
        
        if(this.recordLocal != undefined) {
            if(this.recordLocal.Files__r == undefined) {
                this.recordLocal.Files__r = '';
            }
        }
        if(this.recordLocal != undefined && this.recordLocal.Program__r != undefined) {
            this.showProjectNumber = true;
            this.programSelection = [
                {
                    id: this.recordLocal.Program__c,
                    sObjectType: 'Program__c',
                    icon: 'standard:channel_programs',
                    title: this.recordLocal.Program__r.Name,
                    subtitle: ''
                }
            ];
        }
    }

    handleProgramSearch(event) {
        programSearch(event.detail)
            .then((results) => {
                this.template.querySelector('[data-lookup="Program__c"]').setSearchResults(results);
                console.log('results----', results);
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }
    handleProgramSelectionChange(response) {
        console.log('response--', response.detail);
        if(response.detail != null && response.detail.selectedItem.id != undefined ) {
            this.recordLocal.Program__c = response.detail.selectedItem.id;
            this.recordLocal.Program__r = response.detail.selectedItem.sObject;
            console.log('in if');
            this.showProjectNumber = true;
        }
        else {
            console.log('in else');
            this.showProjectNumber = false;
            this.recordLocal.Program__c = '';
            this.recordLocal.Project_Number__c = '';
            this.programSelection = [];
        }
    }
    validateCustomInput() {
        let isSuccess = true;
        this.programRequired = [];

        if (this.recordLocal.Subapplication_for_project_submitted__c == 'Yes' && this.recordLocal.Program__r == undefined) {
            this.programRequired.push({ message: 'Complete this field.' });
            isSuccess = false;
        }
        return isSuccess;
    }
     get documentPicklistValues(){
        return [
                    { label: 'Project Site Photos', value: 'Project Site Photos' },
                    { label: 'Activity Site Location', value: 'Activity Site Location' }
                ];
    }

    documentPicklistChange(event){
        this.docType = event.detail.value;
    }

    get isDocTypeSelected(){
        return this.docType == undefined;
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        try{
        console.log('in file upload-----');
        let uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " + uploadedFiles.length);
        console.log("this.docType : " + this.docType);
        this.executeAction(updateFileDetails, {'docId' : uploadedFiles[0].documentId,'fileType':this.docType}, (response) => {
            console.log('response= '+response);
            if(response){
                this.recordLocal.Files__r = this.template.querySelector('c-file-list').refreshFileList();
            }
        });
        }
        catch(e){
            console.log(e);
        }
    }
    latitudeBlur(event) {
        var validPattern = new RegExp(/^(\+)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))$/);
        let value = event.target.value;
        if(value.length > 0) {
            if(!validPattern.test(value)) {
                event.target.setCustomValidity('Please enter the Latitude in the following format: +XX.XXXXXX');
            }
            else{
                event.target.setCustomValidity('');
                if(value != undefined && value != '') {
                    value = Number(value);
                    value = value.toFixed(6);
                    var checkSymbol = value.charAt(value[0]);
                    if(checkSymbol != '+') {
                        value = '+' + value;
                    }
                    this.recordLocal.Activity_Location__Latitude__s =  value;
                }
            }
        }
        event.target.reportValidity();
    }

    longitudeBlur(event){
        var validPattern = new RegExp(/^(-)?(?:180(?:(?:\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\.[0-9]{1,6})?))$/);
        let value = event.target.value;
        console.log('velue----',value);
        if(value.length > 0) {
           if(!validPattern.test(value)) {
               event.target.setCustomValidity('Please enter the Longitude in the following format: -XXX.XXXXXX');
           }
           else{
               event.target.setCustomValidity('');
               if(value != undefined && value != '') {
                   value = Number(value);
                   value = value.toFixed(6);
                   var checkSymbol = value.charAt(value[0]);
                   if(checkSymbol != '-') {
                       value = '-' + value;
                   }
                   this.recordLocal.Activity_Location__Longitude__s =  value;
               }
           }
        }
        event.target.reportValidity();
    }

    /*get latMaxLength(){
        let value = this.recordLocal.Activity_Location__Latitude__s;
        value = parseFloat(value);
        value = value.toFixed(6);
        console.log(value.toString().length);
        return value.toString().length;
    }

    get longMaxLength(){
        let value = this.recordLocal.Activity_Location__Longitude__s;
        value = parseFloat(value);
        value = value.toFixed(6);
        return value.toString().length;
    }*/

    removeZeros(event) {
        let value = event.target.value;
        let field = event.target.dataset.field;
        if(value != undefined && value != ''){
            value = parseFloat(value);
            this.recordLocal[field] = value;
        }
    }
}