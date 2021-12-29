import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';

export default class HmaNOIPreview extends Utility {
    recordTypeId;
    recordTypeName;
    initData() {
        if(this.recordLocal.RecordTypeId != undefined || this.recordLocal.RecordTypeId != null) {
            this.recordTypeId = this.recordLocal.RecordTypeId;
            this.recordTypeName = this.recordLocal.RecordType.Name;
        }
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
    get hideFieldsForBRICAndFMA() {
        if((this.recordTypeName == 'BRIC' && this.recordLocal.Applicant_Type__c == 'Capability and Capacity Building (C&CB)') ||
           (this.recordTypeName == 'FMA' && (this.recordLocal.Applicant_Type__c == 'Flood Hazard Mitigation Planning'|| this.recordLocal.Applicant_Type__c == 'Project Scoping'))) {
            return false;
        }
        return true;
    }
     get hideSpecialFloodHazardArea() {
        if(this.recordTypeName == 'BRIC' && this.recordLocal.Application_Type__c == 'Capability and Capacity Building (C&CB)' && (this.recordLocal.Project_Type__c == 'Planning-New Plan' || this.recordLocal.Project_Type__c == 'Planning-Plan Update' || this.recordLocal.Project_Type__c == 'Building Code' || this.recordLocal.Project_Type__c == 'Planning-Related Activities')) {
            return false;
        }
        return true;
    }
    /*get showActivityPage() {
        if(this.record.Application_Type__c != 'Project' && this.record.Applicant_Type__c == 'Private Non-Profit') {
            return false;
        }
        return true;
    }*/
    get isPrivateNonProfit(){
        if(this.record.Applicant_Type__c == 'Private Non-Profit') {
            return true;
        }
        return false;
    }
    get showAllCards() {
        if(this.record.Application_Type__c == 'Planning' || this.record.Application_Type__c == 'Planning-related') {
            return false;
        }
        return true;
    }
    get showCardsForPlanningRelated() {
        if(this.record.Application_Type__c != 'Planning') {
            return true;
        }
        return false;
    }
    get showIdentifyTheProgramField(){
        if(this.record.Federal_entity_have_funding_authority__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showEntityResponsibleField(){
        if(this.record.Subapplicant_for_infrastructure__c == 'No'){
            return true;
        }
        return false;
    }
    get showProgramField(){
        if(this.record.Subapplication_for_project_submitted__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showMitigationDependentField(){
        if(this.record.Independent_mitigation_activity__c == 'No') {
            return true;
        }
        return false;
    }
    get showWorkStartedField(){
        if(this.record.Physical_project_work_already_started__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showWhatIsAvailableField(){
        if(this.record.Planning_studies_or_feasibility_reports__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showPercentageCompleteAreTheDesignsField(){
        if(this.record.Design_documents_for_this_project__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showProtectionForThatAssetField(){
        if(this.record.Project_related_to_asset__c == 'Yes') {
            return true;
        }
        return false;
    }

    get getApplicantType() {
        if(this.record.Applicant_Type__c == 'Private Non-Profit') {
            return false;
        }
        return true;
    }
    get getApplicationType() {
        if(this.recordLocal.Application_Type__c == 'Project' || this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project' || this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project') {
            return true;
        }
        return false;
    }
    get activeLHMP() {
        if(this.record.Does_your_entity_have_an_active_LHMP__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showProposedProjectField() {
        if(this.record.Proposed_project_area_documented__c == 'Yes') {
            return true;
        }
        return false;
    }
    get showProjectlocationField(){
        if(this.record.Project_location_have_the_hazard__c == 'Yes') {
            return true;
        }
        return false;
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
        }
        return false;
    }
    get showProjectMitigateField() {
        if(this.recordTypeName == 'FMA' && this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project') {
            return true;
        }
        return false;
    }
    get hideForProblemMitigation(){
        if(this.recordTypeName == 'BRIC'  && this.recordLocal.Application_Type__c == 'Capability and Capacity Building (C&CB)' && (this.recordLocal.Project_Type__c == 'Planning-New Plan' || this.recordLocal.Project_Type__c == 'Planning-Plan Update') || (this.recordTypeName == 'FMA'  && this.recordLocal.Application_Type__c == 'Flood Hazard Mitigation Planning')) {
            return false;
        }
        return true;
    }
    get showConformanceFields() {
        if(this.recordTypeName == 'BRIC' && this.recordLocal.Application_Type__c == 'Project') {
            return true;
        }
        return false;
    }
}