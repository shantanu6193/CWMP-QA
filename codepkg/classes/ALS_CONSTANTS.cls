/**
 * Created by Ricky on 18-01-2021.
 */

public with sharing class ALS_CONSTANTS {
        public static final String Task_Status_Open = 'Open';
        public static final String Task_Subject_InvoiceToSuRecipient = 'Invoice to Sub Recipient';
        public static final String PR_ReasonToAutoWithdraw = 'Project Withdrawn';

        //Contact Role
        public static final String ACRole_ContactRole_Employee = 'Employee';
        public static final String ACRole_Status_Active = 'Active';
    //Project Role Object Constants...
        public static final String ProjectRole_ContactType = 'Primary';
        public static final String ProjectRole_Role_AuthorizedAgent = 'Authorized Agent';
        public static final String ProjectRole_Role_Accounting = 'Accounting';
        public static final String ProjectRole_Role_Applicant = 'Applicant';

    //Constants for Custom Document Object...
        public static final String Document_Stage_New = 'New';
        public static final String Document_Stage_Uploaded = 'Uploaded';
        public static final String Document_Status_Active = 'Active';

        public static final String Document_IsRequired_Required = 'Required';
        public static final String Document_IsRequired_Optional = 'Optional';

        public static final String Document_DocumentType_Obligating ='Obligating';
        public static final String Document_DocumentType_Compliance ='Compliance';
        public static final String Document_DocumentType_DeObligation ='De Obligation';
        public static final String Document_DocumentType_Closeout ='Closeout';
        public static final String Document_DocumentType_Withdrawn ='Withdrawn';
        public static final String Document_DocumentType_ReimbursementRequest ='Reimbursement Request';
        public static final String Document_DocumentType_Supplement ='Supplement';
        public static final String Document_DocumentType_miscellaneous ='miscellaneous';

        public static final String ProfileName_SystemAdmin = 'System Administrator';
        public static final String Queue_API_Name = 'Transmittals_Accounting_Team';
        public static final String Queue_Type = 'Queue';
        public static final String Status_Pending = 'Pending';

    //Pay To State Admin filed constants...
        public static final String Picklist_Yes = 'Yes';
        public static final String Picklist_No = 'No';

    //Constants For Award Object...
        public static final String Award_Status_Active = 'Active';
        public static final String Award_Status_Inactive = 'Inactive';

    //Constants for Project Object...
        public static final String Project_DamageCategory_ZManagement = 'Z: Management Costs';
        //Funding Source field Constants...
        public static final String Project_FundingSource_FederalAndState = 'Federal and State';
        public static final String Project_FundingSource_FederalOnly = 'Federal Only';
        public static final String Project_FundingSource_StateOnly = 'State Only';
        //Stage field constants..
        public static final String Project_Stage_New = 'New';
        public static final String Project_Stage_Obligating = 'Obligating';
        public static final String Project_Stage_ComplianceVerification = 'Compliance Verification';
        public static final String Project_Stage_ActivePayment = 'Active Payment';
        public static final String Project_Stage_Deobligation = 'Deobligation';
        public static final String Project_Stage_Closeout = 'Closeout';
        public static final String Project_Stage_Withdrawn = 'Withdrawn';
        //Status Filed Constants...
        public static final String Project_Status_Active = 'Active';
        public static final String Project_Status_OnHoldDebtRecovery = 'On Hold - Debt Recovery';


    //Constants for Payment Object...
        public static final String Payment_ObjectAPIName = 'Payment__c';

        public static final String Payment_PaymentType_CloseoutPayment = 'Closeout Payment';
    public static final String Payment_PaymentType_RegularPayment = 'Regular Payment';

    //Constants for Payment Request Object...
        public static final String PR_ObjectAPIName = 'Payment_Request__c';
        //Stage field Constants...
        public static final String PR_Stage_New = 'New';
        public static final String PR_Stage_Processing = 'Processing';
        public static final String PR_Stage_InReview = 'In Review';
        public static final String PR_Stage_ReviewedNeedsInformation = 'Reviewed - Needs Information';
        public static final String PR_Stage_PaymentProcessing = 'Payment Processing';
        public static final String PR_Stage_ReturnedProjectPayment = 'Returned Project Payment';
        public static final String PR_Stage_Paid = 'Paid';
        public static final String PR_Stage_Withdrawn = 'Withdrawn';
        //Payment Type ...
        public static final String PR_PaymentType_Reimbursement = 'Reimbursement';
        public static final String PR_PaymentType_Advance = 'Advance';
        public static final String PR_PaymentType_Offset = 'Offset';
        public static final String PR_PaymentType_MutualAid = 'Mutual Aid';
        public static final String PR_PaymentType_FinalPayment = 'Final Payment';
        public static final String PR_PaymentType_ReturnedProjectPayment = 'Returned Project Payment'; 
        //Payment Delivery ...
        public static final String PR_PaymentDelivery_Standard = 'Standard';

    //Constants for Amendment Request Object...
        public static final String Amendment_Type_TimeExtension = 'Time Extension';
        public static final String Amendment_Type_MoneyExtension = 'Money Extension';
        public static final String Amendment_Type_PercentageChange = 'FEMA Percentage Change';
        public static final String Amendment_Type_MoneyExtensionAndTimeExtension = 'Additional Funding and Time Extension';
        public static final String Amendment_Type_MoneyExtensionAndCostShareChange = 'Additional Funding and FEMA Percentage Change';

    //Constants for Transmittal Object...
        public static final String Transmittal_RecallComment = 'System Recalled/Rejected this record because other associated Transmittal was Recalled/Rejected by ';
        public static final String Transmittal_ApprovalCommentForNegativeOffsetTR = 'System approved';
        public static final String Transmittal_ApprovalCommentForReturnedProjectPayment = 'System approved upon PR approval';
        public static final String Stage_New = 'New';

        //Transmittal Type...
        public static final String Transmittal_Type_State = 'State';
        public static final String Transmittal_Type_Federal = 'Federal';
        //Transmittal Stage...
        public static final String Transmittal_Stage_Approved = 'Approved';
        public static final String Transmittal_Stage_Paid = 'Paid';
        public static final String Transmittal_Stage_Rejected = 'Rejected';
        public static final String Transmittal_Stage_InReview = 'In Review';
        public static final String Transmittal_Stage_OnHold = 'On hold - Cost Threshold';
        public static final String Transmittal_Stage_Withdrawn = 'Withdrawn';
        //Payment Type
        public static final String Transmittal_PaymentType_MutualAid = 'Mutual Aid';
        public static final String Transmittal_PaymentType_Offset = 'Offset';

    //Constants for Program Document Object... 
        public static final String PDocument_ParentObject_PR = 'Payment Request';
        public static final String PDocument_ParentObject_Project = 'Project';
        public static final String PDocument_DocumentCategory_Obligating ='Obligating';
        public static final String PDocument_DocumentCategory_Compliance ='Compliance';
        public static final String PDocument_DocumentCategory_ReimbursementRequest ='Reimbursement Request';
        public static final String PDocument_DocumentCategory_Supplement ='Supplement';

        public static final String PDocument_DocumentCreationMethod_ManuallyUploaded ='Manually Uploaded';
        public static final String PDocument_DocumentCreationMethod_SystemGenerated ='System Generated';

        public static final String PDocument_DocumentFormat_PDF ='.pdf';
        public static final String PDocument_DocumentFormat_docx ='.docx';


    //Constants for Account Object---
        public static final String Account_EntityType_City = 'City';
        public static final String Account_EntityType_County = 'County';
        public static final String Account_EntityType_SpecialDistrict = 'Special District';

    //Constants for Program Names...
        public static final String Program_HMA = 'Hazard Mitigation Assistance';
        public static final String Program_PA = 'Public Assistance';
        public static final String Program_PA_Federal = 'PA - Federal';
        public static final String Program_CDAA = 'CDAA (State Funding)';
        public static final String Program_PA_StateOnly = 'Public Assistance State Only';
        public static final String Program_PA_FMAG = 'PA - FMAG';

    //Object API Name of Incident Sub Recipinet Summary Object....
        public static final String Summary_ObjectAPIName = 'Incident_Subrecipient_Stage__c';

        public static final String Summary_Stage_Closed = 'Closed';

}