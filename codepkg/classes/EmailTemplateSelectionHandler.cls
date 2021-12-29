/***********************************************************************************************************************************
* Class Name   : EmailTemplateSelectionHandler
* Description  : This is helper class for getting email template while sending mail
* Author       : Dayal
* Created On   : 04/30/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal                04/30/2021      Initial Implementation
* Atul                 05/04/2021      Added with Email Template Perview Functionality. 
**************************************************************************************************************************************/

public with sharing class EmailTemplateSelectionHandler {
    public EmailTemplateSelectionHandler() {
    }
    /***********************************************
    * Method Name : getEmailTemplateFolderName
    * Author : Dayal
    * Inputs : -
    * Description: this method retrun all emailTemplate folder name
***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static list<String> getEmailTemplateFolderName(){
        list<EmailTemplate> folderNameList = [SELECT FolderName FROM EmailTemplate WITH SECURITY_ENFORCED];
        set<String> uniqueFolderName = new set<String>();
        for(EmailTemplate template : folderNameList){
            uniqueFolderName.add(template.FolderName);
        }
        list<String> folderNames = new list<String>(uniqueFolderName);
        return folderNames;       
    }
     /***********************************************
    * Method Name : getEmailTemplateFolderName
    * Author : Dayal
    * Inputs : -
    * Description: this method retrun all emailTemplate folder name
***********************************************************************************/
    @AuraEnabled
    public static list<EmailTemplate> getEmailTemplateFolderDetails(String folderName, String relatedObjectAPITypeId){
        Id recIdVal = Id.valueOf(relatedObjectAPITypeId);
        String sobjectType = recIdVal.getSObjectType().getDescribe().getName();

        System.debug('sobjectType====='+sobjectType); 
        System.debug('recIdVal====='+recIdVal);
        System.debug('folderName===='+folderName);

        list<EmailTemplate> emailTemplates = [SELECT Name, FolderName, Description, FolderId, RelatedEntityType 
                                                FROM EmailTemplate
                                                WHERE Folder.Name = :folderName AND  
                                                (RelatedEntityType =:sobjectType OR RelatedEntityType = null)
                                                WITH SECURITY_ENFORCED];
        System.debug('Email Template Info====='+emailTemplates);                                        
        return emailTemplates;       
    }

    @AuraEnabled(cacheable=true)
    public static list<EmailTemplate> getEmailTemplateFolderDetailsHH(String folderName, String relatedObjectAPITypeId){
        Id recIdVal = Id.valueOf(relatedObjectAPITypeId);
        String sobjectType = recIdVal.getSObjectType().getDescribe().getName();

        System.debug('sobjectType====='+sobjectType); 
        System.debug('recIdVal====='+recIdVal);

        list<EmailTemplate> folderDetails = [SELECT ID, FolderName,FolderId FROM EmailTemplate];
        set<ID> folderId = new set<ID>();
        for(EmailTemplate emailTemplate : folderDetails){
            if(emailTemplate.FolderName ==folderName){
               folderId.add(emailTemplate.FolderId);
                break;
            }
        }   
        list<EmailTemplate> folderInformation = [SELECT Name, FolderName, Description,FolderId,RelatedEntityType 
                                                FROM EmailTemplate where FolderId In:folderId and  
                                                (RelatedEntityType =:sobjectType or  RelatedEntityType = null)
                                                ORDER BY Name];
        System.debug('Email Template Info====='+folderInformation);                                        
        return folderInformation;       
    }

    /***********************************************
    * Method Name : getEmailTemplateFolderName
    * Author : Atul
    * Inputs : String emailTemplateId, String recordId
    * Description: this method retrun  Body and Subject for Email Template Preview
   ********************************************************************************/
    @AuraEnabled()
    public static Map<String,String> getEmailTemplateBody(String emailTemplateId, String recordId){
        Map<String,String> templateBodySubjectMap = new Map<String,String>();
        if(String.isNotEmpty(emailTemplateId)) {
            //Dummy Contact...
            Savepoint sp = Database.setSavepoint();
            Contact contVal = new Contact(FirstName='',LastName=',');
            insert contVal;

           Messaging.SingleEmailMessage singleMsgVal = AppUtils.handleEmailTemplatePreview(emailTemplateId, contVal.Id, recordId);
           //Rollback Contact......
           Database.rollback(sp);
           System.debug('Entered Single Email Body====='+singleMsgVal);
           System.debug('Entered Single Email htmlBody====='+singleMsgVal.htmlBody);
           templateBodySubjectMap.put('Subject', singleMsgVal.subject );
            if(singleMsgVal.htmlBody != null && singleMsgVal.htmlBody.contains('summary="[SOQL]')){
                String renderedSOQLEmailTemplate = renderSOQLEMailTemplate(singleMsgVal.htmlBody,recordId);
                templateBodySubjectMap.put('Body', renderedSOQLEmailTemplate);
            }
            else{
                templateBodySubjectMap.put('Body', singleMsgVal.htmlBody == null?singleMsgVal.plainTextBody:singleMsgVal.htmlBody);
            }
         }
        return templateBodySubjectMap;
    }
    /***********************************************
    * Method Name : renderSOQLEMailTemplate
    * Author : Digambar
    * Inputs : String template, String recordId)
    * Description: this method retrun SOQL data embedded Email template. 
    ********************************************************************************/
    private static String renderSOQLEMailTemplate(String template, String recordId){
        String renderedSOQLEmailTemplate = '';
        String afterSummary = template.substringAfter('summary="[SOQL]');
        System.debug('#afterSummary:'+afterSummary);
        String bodyTillFirstRow = template.substringBefore('summary="[SOQL]') + 'summary="[SOQL]' + afterSummary.substringBefore('</table>').substringBeforeLast('<tr>');
        System.debug('#bodyTillFirstRow:'+bodyTillFirstRow);
        String bodyAfterLastRow = '</tbody> </table>' + afterSummary.substringAfter('</table>');
        System.debug('#bodyAfterLastRow:'+bodyAfterLastRow);
        String dynamicRow = '<tr>' + afterSummary.substringBefore('</table>').substringAfterLast('<tr>').remove('</tbody>');
        System.debug('#dynamicRow:'+dynamicRow);
        //*************************************************************************************************
        String SOQL = template.substringBetween('summary="[SOQL]', '[SOQL]');
        System.debug('#SOQL:'+SOQL);
        if(SOQL.contains('{RecordId}')){
            SOQL = SOQL.replace('{RecordId}', recordId);
            System.debug('#SOQL AFTER RecordId:'+SOQL);
        }
        String SOQLFieldsTemp = SOQL.substringBetween('SELECT ', 'FROM');
        System.debug('#SOQLFieldsTemp:'+SOQLFieldsTemp);
        String[] soqlFields = SOQLFieldsTemp.split(',');
        System.debug('#soqlFields:'+soqlFields);
        List<sObject> tableData = Database.query(SOQL);
        System.debug('#tableData:'+tableData);
        for(sObject row : tableData){
                String rowData = dynamicRow;
            	for(String fieldName : soqlFields){
                    rowData = rowData.replace('{' + fieldName.trim() + '}', AppUtils.getFieldValueAsString(row, fieldName.trim()));
                }
                System.debug('#rowData:'+rowData);
            	bodyTillFirstRow += rowData;
                System.debug('#bodyTillFirstRow:'+bodyTillFirstRow);
        }
        renderedSOQLEmailTemplate = bodyTillFirstRow + bodyAfterLastRow;
        System.debug('#renderedSOQLEmailTemplate:'+renderedSOQLEmailTemplate);
        return renderedSOQLEmailTemplate;
    }
     
}