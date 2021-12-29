/***********************************************************************************************************************************
* Class Name   : HMANOI_StatusEmail
* Description  : This class for send HMA NOI Status Email
* Author       : Pankaj
* Created On   : 07/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               07/12/2020       Initial Implementation
**************************************************************************************************************************************/

public class HMANOI_StatusEmail {

    /***********************************************
    * Method Name : getSendEmailInfo
    * Author : Pankaj
    * Inputs : List<Id> recIds
    * Description: This method send email info with status approved/rejected
    *********************************************/
    @InvocableMethod(Label = 'Pre-Application Send Email'  Description = 'Send Email For Status Approved/Rejected')
    public static void getSendEmailInfo(List<Id> recIds){
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        List<Pre_Application__c> preAppRecInfo = [Select Id, 
                                                        RecordType.Name, 
                                                        CreatedById, 
                                                        CreatedBy.Email, 
                                                        Status__c, 
                                                        Status_Reason__c, 
                                                        Project_Number__c, 
                                                        First_Name_of_Person_Completing_NOI__c, 
                                                        Last_Name_of_Person_Completing_NOI__c, 
                                                        Activity_TitleName__c, 
                                                        Federal_Request_Share__c,
                                                        Responsible_Representative__c,
                                                        Responsible_Representative_Name__c,
                                                        (SELECT Id, Contact__r.Email from Contact_Roles__r WHERE Role__c includes('Primary Contact','Responsible Representative'))
                                                        from Pre_Application__c Where Id IN :recIds];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Pre_Application__c preAppRec : preAppRecInfo){
            String toAddress = preAppRec.CreatedBy.Email;
            toAddresses.add(toAddress);
            if(preAppRec.Contact_Roles__r.size() > 0 && preAppRec.RecordType.Name == 'HMGP'){
                for(Contact_Role__c role : preAppRec.Contact_Roles__r) {
                    if(String.isNotEmpty(role.Contact__r.Email)) {
                        toAddresses.add(role.Contact__r.Email);
                    } 
                }
            }
            if(preAppRec.Status__c == 'Approved' && preAppRec.Status_Reason__c == 'NOI Approved' && preAppRec.RecordType.Name == 'HMGP'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'HMA_Status_Approved_NOI_Approved', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Approved' && preAppRec.Status_Reason__c == 'Approved For Future Consideration' && preAppRec.RecordType.Name == 'HMGP'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'HMA_Status_Approved_Approved_For_Future_Consideration', 'HMA_From_Email_Addresses');
            }
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c =='Ineligible Activity' && preAppRec.RecordType.Name == 'HMGP'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'HMA_Status_Rejected_Ineligible_Activity', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c == 'Ineligible Sub-applicant' && preAppRec.RecordType.Name == 'HMGP'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'HMA_Status_Rejected_Ineligible_Subapplicant', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c == 'Ineligible Sub-applicant & Activity' && preAppRec.RecordType.Name == 'HMGP'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'HMA_Status_Rejected_Ineligible_Subapplicant_And_Activity', 'HMA_From_Email_Addresses');
            }

            if(preAppRec.Status__c == 'Approved' && preAppRec.Status_Reason__c == 'NOI Approved' && preAppRec.RecordType.Name == 'BRIC'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'BRIC_Status_Approved_NOI_Approved', 'HMA_From_Email_Addresses');
            }
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c =='Ineligible Activity' && preAppRec.RecordType.Name == 'BRIC'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'BRIC_Status_Rejected_Ineligible_Activity', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c == 'Ineligible Sub-applicant' && preAppRec.RecordType.Name == 'BRIC'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'BRIC_Status_Rejected_Ineligible_Subapplicant', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c == 'Ineligible Sub-applicant & Activity' && preAppRec.RecordType.Name == 'BRIC'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'BRIC_Status_Rejected_Ineligible_Subapplicant_And_Activity', 'HMA_From_Email_Addresses');
            } 

            if(preAppRec.Status__c == 'Approved' && preAppRec.Status_Reason__c == 'NOI Approved' && preAppRec.RecordType.Name == 'FMA'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'FMA_Status_Approved_NOI_Approved', 'HMA_From_Email_Addresses');
            }
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c =='Ineligible Activity' && preAppRec.RecordType.Name == 'FMA'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'FMA_Status_Rejected_Ineligible_Activity', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c == 'Ineligible Sub-applicant' && preAppRec.RecordType.Name == 'FMA'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'FMA_Status_Rejected_Ineligible_Subapplicant', 'HMA_From_Email_Addresses');
            } 
            if(preAppRec.Status__c == 'Rejected' && preAppRec.Status_Reason__c == 'Ineligible Sub-applicant & Activity' && preAppRec.RecordType.Name == 'FMA'){
                mails = EmailHelper.sendEmail(new List<SObject>{preAppRec}, toAddresses, ccAddresses, 'FMA_Status_Rejected_Ineligible_Subapplicant_And_Activity', 'HMA_From_Email_Addresses');
            } 
        }
        Messaging.sendEmail(mails);
    }
    public static List<String> getContactRoleEmail(List<Id> preApplicationIds) {
        List<String> emails = new List<String>();
        List<Contact_Role__c > conRoles = [SELECT Id, Contact__c, Contact__r.Email, Pre_Application__c, Pre_Application__r.Status__c FROM Contact_Role__c  WHERE Pre_Application__c IN: preApplicationIds AND Role__c includes('Responsible Representative')];
        for(Contact_Role__c role : conRoles) {
            if(String.isNotEmpty(role.Contact__r.Email)) {
                emails.add(role.Contact__r.Email);
            }                
        }
        return emails;
    }
}