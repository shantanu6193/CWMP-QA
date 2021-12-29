public class HMA_CONSTANTS {

    //Application Status
    public static final String APPLICATION_STATUS_DRAFT  = 'Draft';
    public static final String APPLICATION_STATUS_OES_REVIEW  = 'OES Review';
    public static final String APPLICATION_STATUS_FEMA_REVIEW = 'FEMA Review';
    public static final String APPLICATION_STATUS_FEMA_DECISION = 'FEMA Decision';
    public static final String APPLICATION_STATUS_WITHDRAWN = 'Withdrawn';

    //Application Status Reason
    public static final String APPLICATION_STATUS_REASON_NOT_STARTED  = 'Not Started';
    public static final String APPLICATION_STATUS_REASON_IN_PROGRESS  = 'In Progress';
    public static final String APPLICATION_STATUS_REASON_PENDING_OES_REVIEW  = 'Pending OES Review';
    public static final String APPLICATION_STATUS_REASON_ANALYST_REVIEW_IN_PROGRESS = 'Analyst Review In Progress';
    public static final String APPLICIATION_STATUS_REASON_SUBMITTED_TO_FEMA = 'Submitted to FEMA';
    public static final String APPLICIATION_STATUS_REASON_BY_SUBAPPLICANT_AFTER_FUNDS_ARE_OBLIGATED = 'By Subapplicant after funds are obligated';
    public static final String APPLICIATION_STATUS_REASON_BY_SUBAPPLICANT_WITH_NO_FUNDS_OBLIGATED = 'By Subapplicant with no funds obligated';
    public static final String APPLICIATION_STATUS_REASON_BY_OES = 'By OES';

    //Application SubApplication Types
    public static final String APPLICATION_SUBAPPLICATION_TYPE_PLANNING  = 'Planning';
    public static final String APPLICATION_SUBAPPLICATION_TYPE_PROJECT  = 'Project';
    public static final String APPLICATION_SUBAPPLICATION_TYPE_5INITIATIVE  = '5% Initiative';
    public static final String APPLICATION_SUBAPPLICATION_TYPE_PLANNING_RELATED  = 'Planning-related';
    public static final String APPLICATION_SUBAPPLICATION_TYPE_ADVANCE_ASSISTANCE  = 'Advance Assistance';

    //Application field Error messages
    public static final String APPLICATION_IS_THIS_AN_ELIGIBLE_ACTIVITY_VALUE_SHOULD_BE_YES  = 'Is this an eligible Activity value should be Yes';
    public static final String APPLICATION_IS_THIS_AN_ELIGIBLE_SUBAPPLICANT_VALUE_SHOULD_BE_YES  = 'Is this an eligible Subapplicant value should be Yes'; 
    public static final String APPLICATION_IS_BCR_VERIFIED_AT_1_OR_GREATER_VALUE_SHOULD_BE_YES_OR_NOT_APPLICABLE  = 'Is BCR verified at 1.0 or greater value should be Yes or Not Applicable'; 
    public static final String APPLICATION_MATCH_LETTER_VALUE_SHOULD_BE_YES  = 'Match Letter value should be Yes'; 
    public static final String APPLICATION_MAINTENANCE_LETTER_VALUE_SHOULD_BE_YES  = 'Maintenance Letter value should be Yes'; 
    public static final String APPLICATION_READY_TO_SUBMIT_VALUE_SHOULD_BE_YES  = 'Ready to Submit value should be Yes'; 

    public static final String WSLI_PHASE_THE_PLANNING_PROCESS  = 'The Planning Process';
    public static final String WSLI_PHASE_HAZARD_IDENTIFICATION  = 'Hazard Identification';
    public static final String WSLI_PHASE_RISK_ASSESSMENT  = 'Risk Assessment';
    public static final String WSLI_PHASE_MITIGATION_STRATEGY  = 'Mitigation Strategy';
    public static final String WSLI_PHASE_PLAN_PREPARATION  = 'Plan Preparation';
    public static final String WSLI_PHASE_PLAN_DRAFTING  = 'Plan Drafting';
    public static final String WSLI_PHASE_PUBLIC_OUTREACH_MEETINGS_PUBLICHEARINGS  = 'Public Outreach/Meetings/Public Hearings';
    public static final String WSLI_PHASE_PLAN_ADOPTION  = 'Plan Adoption';
    public static final String WSLI_PHASE_PHASE1  = 'Phase 1';
    public static final String WSLI_PHASE_PHASE2  = 'Phase 2';
    public static final String DOCUMENT_TYPE_GANTT_CHART  = 'GANTT Chart';
    public static final String DOCUMENT_TYPE_SITE_RESTORATION_PLAN  = 'Site Restoration Plan';


    public static final String PROJECT_TYPE_ACQUISITION_DEMO_RELOCATION = 'Acquisition Demo-Relocation';
    public static final String PROJECT_TYPE_NEW_PLAN = 'New Plan';
    public static final String PROJECT_TYPE_PLAN_UPDATE = 'Plan Update';


    public static final String PICKLIST_VALUE_YES = 'Yes';
    public static final String PICKLIST_VALUE_NO = 'No';

    public static final String PRE_EVENT_VALUE = 'Pre-Event';

    public static final String PROJECT_COST_TYPE_PRE_AWARD = 'Pre Award';
    public static final String PROJECT_COST_TYPE_STAFF_TIME = 'Staff Time';
    public static final String PROJECT_COST_TYPE_TRAVEL_EXPENSES = 'Travel Expenses';
    public static final String PROJECT_COST_TYPE_EQUIPMENT_EXPENSES = 'Equipment Expenses';
    public static final String PROJECT_COST_TYPE_SUPPLIES = 'Supplies';
    public static final String PROJECT_COST_TYPE_INDIRECT_COST = 'Indirect Cost';
    public static final String PROJECT_COST_TYPE_OTHER = 'Other';

    // Project Cost Line Item Fields
    public static final String PROJECT_COST_LINE_ITEM_PHASE_PHASE_1 = 'Phase 1';
    public static final String PROJECT_COST_LINE_ITEM_PHASE_PHASE_2 = 'Phase 2';

    public static final String PROJECT_BUDGET_TYPE_MANAGEMENT_COST = 'Management Cost'; 
    public static final String PROJECT_BUDGET_TYPE_PROJECT = 'Project';

    public static final String PROJECT_COST_RECORDTYPE_MANAGEMENT_COST = 'Management_Cost';
    public static final String PROJECT_COST_RECORDTYPE_PROJECT = 'Project';
    public static final String PROJECT_COST_RECORDTYPE_PROJECT_SITE = 'Project_Site';


    // public static final String DOCUMENT_TYPE_PAID_PREMIUMS_OF_CURRENT_POLICY  = 'Paid Premiums Of Current Policy';
    // public static final String DOCUMENT_TYPE_NOTICE_OF_VOLUNTARY_INTEREST_SIGNED  = 'Notice of Voluntary Interest Signed';
    // public static final String DOCUMENT_TYPE_MAP_OF_PROPOSED_RELOCATION_SITES  = 'Maps of proposed relocation site(s)';
    // public static final String DOCUMENT_TYPE_DEED_RESTRICTION_IN_PERPETUITY_LANGUAGE  = 'Deed Restriction in Perpetuity -Language';
    // public static final String DOCUMENT_TYPE_CZMA  = 'CZMA';
    // public static final String DOCUMENT_TYPE_ENVIR_SITE_ASSESSMNT_DOCS  = 'Envir Site Assessmnt docs';
    // public static final String DOCUMENT_TYPE_SHIPO_REVIEW_DOCS  = 'SHIPO Review Docs';
    // public static final String DOCUMENT_TYPE_CONSULTATION_LETTERS_DOT_USACE  = 'consultation letters DOT USACE';
    // public static final String DOCUMENT_TYPE_PROVIDE_LOCATION_ON_HAZARD_MAPS  = 'Provide locations on hazard maps';
    //public static final String DOCUMENT_TYPE_CZMA  = 'CZMA';
    
    public static final String PROGRAM_DOC_PARENT_OBJECT_WORK_SCHEDULE  = 'Work Schedule';
    public static final String PROGRAM_DOC_PARENT_OBJECT_APPLICATION_EXTENSION  = 'Application Extensions';
    public static final String PROGRAM_DOC_PARENT_OBJECT_PROJECT_SITE  = 'Project Site';
    public static final String PROGRAM_DOC_PARENT_OBJECT_APPLICATION  = 'Application';

    public static final String CONTACT_ROLE_PICKLIST_REQUESTOR = 'Primary Contact';
    public static final String CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE = 'Responsible Representative';
    public static final String CONTACT_ROLE_PICKLIST_CONTRIBUTOR = 'Contributor';
    public static final String CONTACT_ROLE_PICKLIST_VIEWER = 'Viewer';
    public static final String CONTACT_ROLE_PICKLIST_FEMA_EHP_ANALYST = 'FEMA EHP Analyst';
    public static final String CONTACT_ROLE_PICKLIST_FEMA_REVIEW = 'FEMA Viewer';
    public static final String CONTACT_ROLE_PICKLIST_FEMA_PROGRAMMATIC_ANALYST = 'FEMA Programmatic Analyst';

    public static final String SUB_APPLICATION_QUEUE = 'HMA_SubApplication_Pending_Review';

    public static final String SUB_APPLICATION_RECORDTYPE_HMGP = 'HMGP';
    
    public static final String HMA_USER_ROLE_HMA_ANALYST = 'HMA Analyst';

    /*RFI Types*/
    public static final String REQUEST_FOR_INFORMATION_TYPE_OES_BCA = 'OES BCA';
    public static final String REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC = 'OES Programmatic';
    public static final String REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC = 'FEMA Programmatic';
    public static final String REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP = 'FEMA EHP';
    public static final String REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC = 'FEMA OES Programmatic';
    public static final String REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP = 'FEMA OES EHP';

    //Status for Request For Information Object
    public static final String REQUEST_FOR_INFORMATION_STATUS_DRAFT = 'Draft';
    public static final String REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT = 'Sent to Subapplicant';
    public static final String REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REQUESTED = 'Time Extension Requested';
    public static final String REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_ACCEPTED = 'Time Extension Accepted';
    public static final String REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REJECTED = 'Time Extension Rejected';
    public static final String REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED = 'Response Submitted';
    public static final String REQUEST_FOR_INFORMATION_STATUS_RESPONSE_ACCEPTED = 'Response Accepted';
    public static final String REQUEST_FOR_INFORMATION_STATUS_RESPONSE_REJECTED = 'Response Rejected';
    //Status for Request For Information Object (FEMA-OES EHP RFI type statuses)
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_OES_ANALYST_REVIEW_FEMA_EHP_RFI = 'OES Analyst Review FEMA EHP RFI';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_EHP_RFI_ACCEPTED = 'FEMA EHP RFI Accepted';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_EHP_RFI_REJECTED = 'FEMA EHP RFI Rejected';
    // Status for Request For Information Object (FEMA-OES Programmatic RFI type Statuses)
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_DRAFT = 'FEMA Draft';
    public static final String REQUEST_FOR_INFORMATION_STATUS_SUBMITTED_TO_CAL_OES_ANALYST = 'Submitted to Cal OES Analyst';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_OES_ANALYST_REVIEW_FEMA_PROGRAMMATIC_RFI = 'OES Analyst Review FEMA Programmatic RFI';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED = 'FEMA Time Extension Requested';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_ACCEPTED = 'FEMA Time Extension Accepted';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REJECTED = 'FEMA Time Extension Rejected';
    public static final String REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED_BY_CAL_OES_ANALYST = 'Response Submitted by Cal OES Analyst';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_PROGRAMMATIC_RFI_ACCEPTED = 'FEMA Programmatic RFI Accepted';
    public static final String REQUEST_FOR_INFORMATION_STATUS_FEMA_PROGRAMMATIC_RFI_REJECTED = 'FEMA Programmatic RFI Rejected';
    
    //Email Templates related constants
    public static final String EMAIL_TEMPLATE_HMA_SEND_INVITE_CONTACT_ROLE_NOTIFICATION = 'HMA Responsible Representative Manage Subapp';
    public static final String EMAIL_TEMPLATE_HMA_SUBAPP_SUBMISSION_NOTIFICATION = 'HMA Subapplication Submission Notification';
    public static final String HMA_FROM_EMAIL_ADDRESSES = 'HMA_From_Email_Addresses';
    public static final String HMA_RFI_SENT_TO_SUBAPPLICANT_NOTIFICATION = 'HMA_RFI_Sent_To_SubApplicant_Notification';
    public static final String HMA_SUBAPPLICATION_WITHDRAWN_EMAIL_NOTIFICATION = 'HMA_Subapplication_Withdrawn_Email_Notification';
    public static final String HMA_SUBAPPLICATION_WITHDRAWN_BY_CAL_OES_EMAIL_NOTIFICATION = 'HMA_Subapplication_Withdrawn_by_Cal_OES_Email_Notification';


    //public static final String HMA_RFI_TIME_EXTENSION_REQUEST_TO_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_RFI_Time_Extension_Request_To_HMA_Analyst_Email_Notification';
    public static final String HMA_RFI_TIME_EXTENSION_ACCEPTED_TO_SUBAPPLICANTS_EMAIL_NOTIFICATION = 'HMA_RFI_Time_Extension_Accepted_To_SubApplicants_Email_Notification';
    public static final String HMA_RFI_TIME_EXTENSION_REJECTED_TO_SUBAPPLICANTS_EMAIL_NOTIFICATION = 'HMA_RFI_Time_Extension_Rejected_To_SubApplicants_Email_Notification';
    public static final String HMA_RFI_RESPONSE_ACCEPTED_EMAIL_NOTIFICATION = 'HMA_RFI_Response_Accepted_Email_Notification';
    public static final String HMA_RFI_RESPONSE_REJECTED_EMAIL_NOTIFICATION = 'HMA_RFI_Response_Rejected_Email_Notification';
    public static final String HMA_RFI_RESPONSE_SUBMITTED_TO_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_RFI_Response_Submitted_To_HMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_RFI_SUBMITTED_TO_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_RFI_Submitted_To_HMA_Analyst_Email_Notification';
    //public static final String HMA_FEMA_RFI_TIME_EXTENSION_REQUESTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_RFI_Time_Extension_Requested_By_HMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_EHP_RFI_TIME_EXTENSION_REQUESTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_EHP_RFI_Time_Extension_Request_By_HMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_PROGRAMMATIC_RFI_TIME_EXTENSION_REQUESTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_Programmatic_RFI_Time_Extension_Request_By_HMA_Analyst_Email';
    public static final String HMA_FEMA_RFI_TIME_EXTENSION_REQUEST_ACCEPTED_BY_FEMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_RFI_Time_Extension_Request_Accepted_By_FEMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_RFI_TIME_EXTENSION_REQUEST_REJECTED_BY_FEMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_RFI_Time_Extension_Request_Rejected_By_FEMA_Analyst_Email_Notification';
    //public static final String HMA_FEMA_RFI_RESPONSE_SUBMITTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_RFI_Response_Submitted_By_HMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_EHP_RFI_RESPONSE_SUBMITTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_EHP_RFI_Response_Submitted_By_HMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_PROGRAMMATIC_RFI_RESPONSE_SUBMITTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION = 'HMA_FEMA_Programmatic_RFI_Response_Submitted_By_HMA_Analyst_Email_Notification';
    public static final String HMA_FEMA_USER_INVITATION_FOR_APPLICATION_REVIEW = 'HMA FEMA User Invitation for Application Review';

    //Permission Set
    public static final String PERMISSIONSET_HMA_FEMA_ANALYST_COMMUNITY_USER = 'HMA FEMA Analyst Community User';
    public static final String PERMISSIONSET_HMA_FEMA_VIEWER_COMMUNITY_USER = 'HMA FEMA Viewer Community User';

    //Profile Names
    public static final String PROFILE_CALOES_CUSTOMER_COMMUNITY_PLUS_USER = 'CalOES Customer Community Plus User';

    //Scoring Checklist Error Message
    public static final String SCORE_FIELD_MUST_BE_LESS_ERROR_MESSAGE = 'Score should not more than Maximum Points';
}