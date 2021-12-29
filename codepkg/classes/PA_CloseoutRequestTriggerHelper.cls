/**
* Class Name   : PA_CloseoutRequestTriggerHelper
* Description  : This helper used  to populate DeclarationNumber , Name field, check NSPO Amount and send the email whent 
                 Closeout Request is created , updated
* Author       : Prajakta
* Created On   : 23/06/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prajakta             23/06/2021       Initial Implementation
 */

public without sharing class PA_CloseoutRequestTriggerHelper extends TriggerHelper{

    /******************************************************************
    * Method Name : processAfterUpdate
    * Author : Prajakta
    * Inputs : -
    * Description: This method will called after  closeout request  record is updated.
    *******************************************************************/
    public override void processAfterUpdate() {
        List<Closeout_Request__c> closeoutRequestList =  (List<Closeout_Request__c>)Trigger.new;

        //if closeout request status is equal with PA_ExternalUser_CloseoutRequest_Status key value store vlaue 
        String status = getExternaUserCloseoutRequestStatus();
        for(Closeout_Request__c closeoutRequest : closeoutRequestList){
            if(closeoutRequest.Status__c == status){
        checkNSPOAmount(closeoutRequestList);
    }
        }
       
    }

    public override void processBeforeUpdate() {
        avoidCloseoutRequestNameUpdate();
    }

    /*******************************************************************
   * Method Name : processBeforeUpdate
   * Author      : Prajakta
   * Inputs      : -
   * Description : This method will called before closeout request record is updated to avoid updating closerequest name.
   ********************************************************************/
    public  static void avoidCloseoutRequestNameUpdate() {
        for(Closeout_Request__c original: (List<Closeout_Request__c>)Trigger.new) {
            Closeout_Request__c toCompare = (Closeout_Request__c)Trigger.oldMap.get(original.Id);//here we compare old version and new.
            if (original.Name != toCompare.Name) {
                original.addError('You do not have permission to change Closeout Request Name');
            }
        }
    }

    /*******************************************************************
    * Method Name : processBeforeInsert
    * Author : Prajakta
    * Inputs : -
    * Description: This method will called before closeout request record is inserted.
    ********************************************************************/

    public override void processBeforeInsert() {
        populateDeclarationNumber();
    }

    /********************************************************************
    * Method Name : processAfterInsert
    * Author      : Prajakta
    * Inputs      : -
    * Description : This method will called after  closeout request  record is created.
    *********************************************************************/  

    public override void processAfterInsert() {

        List<Closeout_Request__c> closeoutRequestList =  (List<Closeout_Request__c>)Trigger.new;
        populateNameField(closeoutRequestList);

    }

    /*******************************************************************
    * Method Name : populateDeclarationNumber
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to populate Declaration Number.
    ******************************************************************/

    private void populateDeclarationNumber(){
        Set<String> incidentIds = new Set<String>();
        List<Closeout_Request__c> closeoutReqList =  new List<Closeout_Request__c>();
        for (Closeout_Request__c closeoutReq : (List<Closeout_Request__c>)Trigger.new) {
            //added filter clause closeout request incident not null
            if (closeoutReq.Incident__c != null) {
                incidentIds.add(closeoutReq.Incident__c);
                closeoutReqList.add(closeoutReq);
            }
        }
        if (incidentIds.size() > 0) {
            Map<Id, Incident__c> idToIncidentMap = new Map<Id, Incident__c>([SELECT Id, Declaration_Number__c
            FROM Incident__c WHERE Id IN  : incidentIds]);
            for (Closeout_Request__c closeoutRequest : closeoutReqList) {
                Incident__c incident = idToIncidentMap.get(closeoutRequest.Incident__c);
                closeoutRequest.Declaration_Number__c = incident.Declaration_Number__c;
            }
        }
    }

    /******************************************************************
    * Method Name : checkNSPOAmount
    * Author : Prajakta
    * Inputs : - List of closeout request.
    * Description: This method will check old and new NSPO amount. This method get fired when old value is '0' or 'null'.
    ******************************************************************/

    private void  checkNSPOAmount(List<Closeout_Request__c> closeOutReqList){
        Set<String> requestorId = new Set<String>();
        for (Closeout_Request__c closeReq : closeOutReqList) {
            //added filter clause of old closeout request
            if(Trigger.oldMap == null || Trigger.oldMap.get(closeReq.Id) == null) continue;
            Closeout_Request__c toCompare = (Closeout_Request__c)Trigger.oldMap.get(closeReq.Id);
            //added filter clause of old NSPO and new NSPO Amount
            if((toCompare.NSPO_Amount__c == 0 || toCompare.NSPO_Amount__c == null) && closeReq.NSPO_Amount__c != toCompare.NSPO_Amount__c){
                //added filter clause closeout Request Requestor should not null
                if(String.isNotEmpty(closeReq.Requestor__c)){
                    requestorId.add(closeReq.Requestor__c);
                }
            }

        }
        //if get closeout Request Requestor then it send the email
        if(requestorId.size() > 0){
            Map<String,User> userIdWithUserMap = new Map<String,User>([SELECT ContactId,Contact.Email FROM User WHERE id IN: requestorId]);
            sendEmailToContact(closeOutReqList,userIdWithUserMap);
        }

    }

    /***********************************************************************
    * Method Name : sendEmailToContact
    * Author : Prajakta
    * Inputs : -List of closeout request and Map<String,User> userIdWithUserMap
    * Description: This method is used to send mail to contact email.
    ***********************************************************************/

    private static void sendEmailToContact(List<Closeout_Request__c> closeOutReqList,Map<String,User> userIdWithUserMap) {
        String emailTemplateName;
        List<Key_Value_Store__mdt> keyValStoreLst = [SELECT Text_Value__c,DeveloperName FROM Key_Value_Store__mdt WHERE DeveloperName = 'PA_NSPO_Submittal_Deadline_Template'];
        //getting email template in metadat
        if(keyValStoreLst.size() > 0){
            emailTemplateName = keyValStoreLst[0].Text_Value__c;
        }
        Set<Id> closeoutRequestId = new Set<Id>();
        for(Closeout_Request__c closeReq:closeOutReqList){
            closeoutRequestId.add(closeReq.Id);
        }

        List<Project_Closeout__c> projectCloseoutList = [Select id,Is_Last_Project__c from Project_Closeout__c Where Closeout_Request__c In:closeoutRequestId And Is_Last_Project__c = true];

        List<EmailTemplate> emailTemplateIns = [SELECT Id, markup FROM EmailTemplate WHERE Name =: emailTemplateName];
        //email template available 
        if(emailTemplateIns.size() > 0){
           List<Messaging.SingleEmailMessage> mailingList = new List<Messaging.SingleEmailMessage>();

           for(Closeout_Request__c conReq :closeOutReqList){
               //closeout request requestor should not null
               if(conReq != null && conReq.Requestor__c != null && userIdWithUserMap.get(conReq.Requestor__c) != null && userIdWithUserMap.get(conReq.Requestor__c).ContactId != null && projectCloseoutList.size() > 0){
                   Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(emailTemplateIns[0].Id, userIdWithUserMap.get(conReq.Requestor__c).ContactId, projectCloseoutList[0].Id);
                   singleEmail.toAddresses = new List<String>{ userIdWithUserMap.get(conReq.Requestor__c).Contact.Email };
                   singleEmail.setHtmlBody(singleEmail.htmlBody);
                   singleEmail.setSaveAsActivity(true);
                   singleEmail.setSubject(singleEmail.subject);
                   mailingList.add(singleEmail);
               }

           }
           List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailingList, true);
        }
    }

    /*************************************************************************
   * Method Name : populateNameField
   * Author : Dayal
   * Inputs : -projectCloseoutList
   * Description: This method is used to populate Name Field.
    *************************************************************************/

  private void populateNameField(List<Closeout_Request__c> closeoutRequestList){
    List<Closeout_Request__c> updatedCloseoutRequestList = new List<Closeout_Request__c>();
        for(Closeout_Request__c   closeOutRequest : closeoutRequestList){
            Closeout_Request__c CloseOutRequestInstance = new Closeout_Request__c();
            CloseOutRequestInstance.Id = closeOutRequest.Id;
            //closeout Request number should not null
            if(String.isNotEmpty(closeOutRequest.Request_Number__c)){
                CloseOutRequestInstance.Name =  closeOutRequest.Request_Number__c;
                if(String.isNotEmpty(closeOutRequest.Declaration_Number__c) && String.isNotEmpty(closeOutRequest.FIPS__c)){
                    CloseOutRequestInstance.Name += ' (' + closeOutRequest.Declaration_Number__c +' / FIPS: '+closeOutRequest.FIPS__c +')';
                   
                }else if(String.isNotEmpty(closeOutRequest.Declaration_Number__c)){
                    CloseOutRequestInstance.Name +=  ' (' + closeOutRequest.Declaration_Number__c  + ')';
                }else if(String.isNotEmpty(closeOutRequest.FIPS__c)){
                    CloseOutRequestInstance.Name +=  ' (FIPS: ' + closeOutRequest.FIPS__c + ')';
                }
            }

            updatedCloseoutRequestList.add(CloseOutRequestInstance);
        }
        TriggerHelper.skipTrigger = true;
        update updatedCloseoutRequestList;

    }

    /***********************************************************************************************
    * Method Name   : getExternaUserCloseoutRequestStatus
    * Description   :this Method is used get External User Closeout Request Status
    * Return        : -status valus which stored in Metadata
    * Inputs        : -
    * Author        : Dayal
    * Created On    : 26/05/2021
    * Modification Log:  
    * ---------------------------------------------------------------------------------------------*/  
   
    @AuraEnabled(Cacheable=true)
    public static string getExternaUserCloseoutRequestStatus(){
        try {

            String status = KeyValueHelper.getTextValue('PA_ExternalUser_CloseoutRequest_Status');
            return status;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}