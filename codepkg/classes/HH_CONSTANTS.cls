/***********************************************************************************************************************************
* Class Name   : HH_CONSTANTS
* Description  : This class is used to store all the Constants used in Home Hardening Application.
* Author       : Ricky
* Created On   : 10/08/2021
**************************************************************************************************************************************/

public without sharing class HH_CONSTANTS {

    /** Picklist Constant for "Yes" and "No". */
    public static final String PickList_Yes = 'Yes';
    public static final String PickList_No = 'No';

    /** CommunityResetPasswordCtrl **/
    public static final String Language_English = 'en_US';
    public static final String Language_Spanish = 'es';

    /** User Registration Object **/


    /* User Registration User Type*/
    public static final String UserRegistration_UserType_Community = 'Community';
    public static final String UserRegistration_UserType_FEMA = 'FEMA';

    /** User Registration RecordType **/
    public static final String RecordType_Registration = 'Registration';
    public static final String RecordType_HH_RegistrationAPIName = 'HH_Registration';
    public static final String RecordType_HH_Registration = 'CWMP Registration';

    /** User Registration Status **/
    public static final String UserRegistration_Status_PasswordReset = 'Password Reset';
    public static final String UserRegistration_Status_Verified = 'Verified';
    public static final String UserRegistration_Status_VerificationPending = 'Verification Pending';

    /** PHOS_CommunityPassword_Email **/
    public static final String From_EmailAddress_PHOS = 'PHOS_From_Email_Addresses';
    public static final String From_EmailAddress_HH = 'HH_From_Email_Addresses';
    public static final String Email_Template_CalOES_Community_Set_Password = 'CalOES_Community_Set_Password';
    public static final String Email_Template_CalOES_HH_Community_Set_Password_EN = 'CalOES_HH_Community_Set_Password_EN_1628760896108';
    public static final String Email_Template_CalOES_HH_Community_Set_Password_ES = 'CalOES_HH_Community_Set_Password_ES_1628762238147';
    public static final String Email_Template_CalOES_HH_Community_Reset_Password_EN = 'CalOES_HH_Community_Reset_Password_EN_1629296989589';
    public static final String Email_Template_CalOES_HH_Community_Reset_Password_ES = 'CalOES_HH_Community_Reset_Password_ES_1629297137311';

    /** Account Object Constants. **/
    public static final String Account_HOUSEHOLD_Name = 'HOUSEHOLD';

    /** HH Application Object Constants. **/
    public static final String HHApplication_Stage_Draft = 'Draft';
    public static final String HHApplication_Stage_CommunityReview = 'Community Review';
    public static final String HHApplication_Stage_CommunityDecision = 'Community Decision';
    public static final String HHApplication_Stage_Assessment = 'Assessment';
    public static final String HHApplication_Stage_AssessmentDecision = 'Assessment Decision';
    public static final String HHApplication_Stage_OESReview = 'CalOES Review';
    public static final String HHApplication_Stage_OESDecision = 'OES Decision';
    public static final String HHApplication_Stage_FEMAReview = 'FEMA Review';
    public static final String HHApplication_Stage_FEMADecision = 'FEMA Decision';
    public static final String HHApplication_Stage_HomeownerAgreement = 'Homeowner Agreement';
    public static final String HHApplication_Stage_ApprovedConverted = 'Approved- Converted'; 
    public static final String HHApplication_Stage_RejectedClosed = 'Rejected - Closed';

    public static final String HHApplication_Status_New = 'New';
    public static final String HHApplication_Status_Withdrawn = 'Withdrawn';
    public static final String HHApplication_Status_AppealApprovalResubmit = 'Appeal Approval - Resubmit';
    public static final String HHApplication_Status_CommunityReviewPending = 'Community Review Pending';
    public static final String HHApplication_Status_CommunityReviewInProgress = 'Community Review In  Progress';
    public static final String HHApplication_Status_OpenRFINeedMoreInfo = 'Open Community RFI- Need more Info';
    public static final String HHApplication_Status_CommunityDecisionPending = 'Community Decision Pending';
    public static final String HHApplication_Status_RejectedDoesNotMeetCriteria = 'Rejected - Does not meet Criteria';
    public static final String HHApplication_Status_ApprovedForAssessment = 'Approved for Assessment';
    public static final String HHApplication_Status_AssessmentPending = 'Assessment Pending';
    public static final String HHApplication_Status_AssessmentInProgress = 'Assessment In progress';
    public static final String HHApplication_Status_AssessmentComplete = 'Assessment Complete';
    public static final String HHApplication_Status_RejectedNotEligible = 'Rejected - Not Eligible';
    public static final String HHApplication_Status_ReadyForCalOesReview = 'Ready for Cal OES Review';
    public static final String HHApplication_Status_OESReviewPending = 'Pending Cal OES Review';
    public static final String HHApplication_Status_OESReviewInProgress = 'OES Review In Progress';
    public static final String HHApplication_Status_OESReviewComplete = 'OES Review Complete';
    public static final String HHApplication_Status_OESOpenRFI = 'OES RFI- Need more Info';
    public static final String HHApplication_Status_OESDecisionRejected = 'Rejected - Not Eligible';
    public static final String HHApplication_Status_ApprovedForFEMAReview = 'Approved for FEMA Review';
    public static final String HHApplication_Status_FEMAReviewPending = 'Pending FEMA Review';
    public static final String HHApplication_Status_FEMAReviewInProgress = 'FEMA Review In Progress';
    public static final String HHApplication_Status_FEMAReviewComplete = 'FEMA Review Complete';
    public static final String HHApplication_Status_FEMAReviewOpenRFI = 'FEMA RFI- Need more Info';
    public static final String HHApplication_Status_FEMADecisionApprovedForProjectConversion = 'Approved for Project Conversion';
    public static final String HHApplication_Status_FEMADecisionRejected = 'Rejected';
    public static final String HHApplication_Status_ContractorQuoteReadyToBeRequested = 'Contractor Quote Ready to Be Requested';
    public static final String HHApplication_Status_ContractorQuoteRequested = 'Contractor Quote Requested';
    public static final String HHApplication_Status_ContractorQuoteReceived = 'Contractor Quote Received';
    public static final String HHApplication_Status_TriPartyAgreementFinalized = 'Tri-Party Agreement Finalized';

    public static final String RFI_RFIStatus_Requested = 'RFI Requested';
    public static final String RFI_RFIStatus_Received = 'Response Received';
    public static final String RFI_RFIStatus_Closed = 'Closed';
    public static final String RFI_RFIStatus_Withdrawn = 'Withdrawal';

    /** Profile Names Constant */
    public static final String HH_System_Admin_Profile_Name = 'System Administrator';
    public static final String CALOES_Portal_Profile_Name = 'CalOES Portal User';
    public static final String CALOES_Internal_Profile_Name = 'CalOES Internal User';

    /** HH Permission Set API Names Constants. */
    public static final String HH_Profile_SystemAdmin = 'System Administrator';
    public static final String HH_PermissionSet_HomeOwner_APIName = 'HH_Community_Homeowner_User';
    public static final String HH_PermissionSet_CommunityUser_APIName = 'HH_Community_County_User';
    public static final String HH_PermissionSet_CalOESUser_APIName = 'HH_CalOES_Internal_User';
    public static final String HH_PermissionSet_FemaUser_APIName = 'HH_Community_FEMA_User';

    /** Public Group API Names Constant. */
    public static final String HH_CalOESInternal_User_Group_APIName = 'HH_Cal_OES_Internal_Analyst';
    public static final String HH_CalOESInternal_User_Queue_APIName = 'HH_Cal_OES_Internal_Analyst';
    public static final String HH_FEMA_User_Group_APIName = 'HH_Community_FEMA_Analyst';
    public static final String HH_FEMA_User_Queue_APIName = 'HH_Community_FEMA_Analyst'; 


    /** hh Application Property County Names Constant. */
    public static final String HHApplication_County_LosAngeles = 'Los Angeles';
    public static final String HHApplication_County_SanDiego = 'San Diego';
    public static final String HHApplication_County_Shasta = 'Shasta';

    /** HH Application Sharing Constant. */
    public static final String HHApplication_Object_APIName = 'HH_Application__c';
    public static final String HHApplication_Object_LabelName = 'HH Application';
    public static final String HHApplication_ShareObject_APIName = 'HH_Application__Share';
    public static final String HHApplication_ShareObject_AccessLevel_Edit = 'Edit';
    public static final String HHApplication_RecordType_Editable = 'Editable_Record_Type';
    public static final String HHApplication_RecordType_ReadOnly = 'Read_Only_Record_Type';

    /** HH "Request for Information" Object Constant. */
    public static final String Rfi_Object_APIName = 'Request_For_Information__c';
    public static final String Rfi_CWMPRecordType_APIName = 'CWMP';
    public static final String Rfi_RFIType_CWMP = 'CWMP';

    /** HH "Account Role" Object Constant. */
    public static final String AccountRole_CWMPRecordType_APIName = 'CWMP';
    public static final String AccountRole_ShareObject_APIName = 'Account_Role__Share';
    public static final String AccountRole_Object_APIName = 'Account_Role__c';
    public static final String AccountRole_ShareObject_AccessLevel_Edit = 'Edit';

    /** Email Templates API Names Constants. */
    public static final String HH_Assessor_Email_Template_APINames = 'HH_Assessor_Email_Template';
    public static final String HH_Assessor_Email_Template_DisplayName = 'No Reply - Cal OES';
    public static final String HH_Application_Submissions_Community_Email_Template_APINames = 'CalOES_HH_Community_Application_Submission';
    public static final String HH_Application_Submissions_Community_Email_Template_DisplayName = 'No Reply - Cal OES';

    /** Program Name API Name Master Labels Constant. */
    public static final String HH_Application_ProgramName_MasterLabel = 'HH Application';

    /** Home Hardening Application Name Constant. */
    public static final String HH_Application_APIName_CountyConfig = 'Home Hardening';

    /** APP PAI Name Name */
    public static final String HH_Parent_Community_Application_Name = 'CWMP';

    /** Program Document*/
    public static final String HH_Program_Document_ParentObject_Name = 'HH Application';

    /** Application Contact Roles */
    public static final String HH_Application_Contact_Co_Owner = 'Co-owner';
    public static final String HH_Application_Contact_HouseHoldMember = 'Household Member';

    /*Contact Type*/ 
    public static final String HH_Contact_Type_Homeowner = 'CWMP Homeowner';
    public static final String HH_Contact_Type_Others = 'CWMP Others';
    public static final String HH_Contact_Type_Community = 'CWMP Community User';
    public static final String HH_Contact_Type_FEMA = 'CWMP FEMA';
    /** Document Object variables. */
    public static final String Document_Stage_Uploaded = 'Uploaded';
    public static final String Document_Stage_New = 'New';
    public static final String Document_IsRequired_Required = 'Required';
    public static final String Document_Status_Active = 'Active';
    public static final String Document_DocumentType_Rental = 'Proof of Rental';
    public static final String Document_DocumentType_PropertyOwnerID = 'Property Owner ID';
    public static final String Document_DocumentType_ProofOfOwnership = 'Proof of Ownership';
    public static final String Document_CreationMethod_SystemGenerated = 'System Generated';
    public static final String Document_DocumentType_EnvironmentalChecklist ='Environmental Checklist';
    public static final String Document_DocumentType_HomeAssessmentReport ='Home Assessment Report';
    
    /* Application Contact Object Relationship to Homeowner*/ 
    public static final String Relationship_to_Homeowner_Self = 'Self';

    /** CWMP Project Object Constants. **/
    public static final String CWMPProject_Stage_NewProjectCreated = 'New Project Created';
    public static final String CWMPProject_Stage_SiteWork = 'Site Work';
    public static final String CWMPProject_Stage_PostAssessment = 'Post-Assessment';
    public static final String CWMPProject_Stage_ProjectComplete = 'Project Complete';
    public static final String CWMPProject_API_Name = 'CWMP_Project__c';


    public static final String CWMPProject_Status_NewProject = 'New Project';
    public static final String CWMPProject_Status_SiteWorReady = 'Site Work Ready';
    public static final String CWMPProject_Status_SiteWorkInProgress = 'Site Work In Progress';
    public static final String CWMPProject_Status_SiteWorkComplete = 'Site Work Complete';
    public static final String CWMPProject_Status_ReadyForPostAssessment = 'Ready for Post Assessment';
    public static final String CWMPProject_Status_PostAssessmentPending = 'Post Assessment Pending';
    public static final String CWMPProject_Status_PostAssessmentIsCompleted = 'Post Assessment is Completed';
    public static final String CWMPProject_Status_ProjectReadyForCloseout = 'Project Ready for Closeout';
    public static final String CWMPProject_Status_ProjectCloseoutComplete = 'Project Closeout Complete';

    /** Account Role Object Constants. **/
    public static final String AccountRole_Status_Active = 'Active';
    public static final String AccountRole_Role_Contractor = 'Contractor';
}