public without sharing class SendEmailController {
    public SendEmailController() {

    }

    @AuraEnabled
    public static void sendEmailAction(Map<String, Object> paramsMap){
        System.debug('ParamsMap Val ===='+paramsMap);
        String templateIdStr = '';
        String htmlBody = '';
        String subjVal = '';
         List<String> toAddressArray = new List<String>();
         List<String> ccAddressArray = new List<String>();
         List<String> bccAddressArray = new List<String>();
        String toAddressVal = String.valueOf(paramsMap.get('toEmailIds')) ; 
        String ccAddressVal = String.valueOf(paramsMap.get('ccEmailIds'));
        String fromAddressVal = String.valueOf(paramsMap.get('fromEmailId'));
        String bccAddressVal = String.valueOf(paramsMap.get('bccEmailIds'));
        String replyTo = paramsMap.containsKey('replyTo') ? String.valueOf(paramsMap.get('replyTo')) : '';
        System.debug('To Address Val before===='+toAddressVal);
        System.debug('From Address Val before===='+fromAddressVal);
        System.debug('To Address Val before===='+bccAddressVal);
        templateIdStr = String.valueOf(paramsMap.get('templateId'));
         System.debug('templateIdStr===='+templateIdStr);
        if(toAddressVal != null && toAddressVal !=''){
            toAddressArray = toAddressVal.split(';');
            System.debug('Entered toAddressArray Split Block==='+toAddressArray);
        }

        if(ccAddressVal != null && ccAddressVal !='' && !ccAddressVal.contains('()')){
             System.debug('ccAddressVal===='+ccAddressVal);
           
            ccAddressArray = ccAddressVal.split(';');
        }

        if(bccAddressVal != null && bccAddressVal !='' && !bccAddressVal.contains('()')){
            bccAddressArray = bccAddressVal.split(';');
        }
        
       
        htmlBody = String.valueOf(paramsMap.get('body'));
        subjVal = String.valueOf(paramsMap.get('subject'));

        //todo - put validations like to email and subject and body should required.
        validateEmailFields(toAddressVal, subjVal);

        String parentObjRecId = String.valueOf(paramsMap.get('parentRecdId'));

        List<Object> contentDocIdsLst = (List<Object>)paramsMap.get('contentDocIds');
        List<String> contDocsIdStrLst = new List<String>();

        for(Object contDocsId: contentDocIdsLst){
            contDocsIdStrLst.add(String.valueOf(contDocsId));
        }    

        ////Get all related contentVersion file
          List<ContentVersion> contentVersionFile = [SELECT VersionData, title, FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN :contDocsIdStrLst AND IsLatest = true];

              //New email message method
        Messaging.SingleEmailMessage mail= new Messaging.SingleEmailMessage(); 
        //rename key value REPLY_EMAIL_HANDLER_ADDRESS_FOR_CUSTOM_EMAIL
        /* String replyEmailHandlerAddress = KeyValueHelper.getTextValue('REPLY_EMAIL_HANDLER_ADDRESS_FOR_MAIL');
        if(String.isEmpty(replyTo)) {
        mail.setReplyTo(replyEmailHandlerAddress);
        } else*/ if(String.isNotEmpty(replyTo)){
            mail.setReplyTo(replyTo);
        } 
        
        
        //defining list of email attachments
        List<Messaging.EmailFileAttachment> attach= new List<Messaging.EmailFileAttachment>();
        List<Id> orgAttachmentList = new List<Id>();

        for(ContentVersion file : contentVersionFile){
            orgAttachmentList.add(file.Id);
             /* Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                //efa.setFileName(file.title+'.'+file.FileType);
                efa.setFileName(file.title+'.'+file.FileExtension);
                efa.setBody(file.VersionData);
                attach.add(efa); */

        }

        //mail.setFileAttachments(attach);
        mail.setEntityAttachments(orgAttachmentList);
        mail.setSubject(subjVal);
        // Replace Merger fields from Body if present...
        if(String.isNotEmpty(htmlBody)){
       //  htmlBody  = replaceRecordMergeFields(htmlBody, parentObjRecId);
        }
        htmlBody += '<br/><div style="display:none">[ Ref: '+parentObjRecId+' ]</div> <br/> <div style="display:none">[ RefToEmail: '+fromAddressVal+' :Email]</div>';
        mail.setHtmlBody(htmlBody);
        
        
        System.debug('Too Address Updated Val==='+toAddressArray);
        if(toAddressArray.size() > 0){
            mail.setToAddresses(toAddressArray);
        }
        
        System.debug('ccAddressArray Updated Val==='+ccAddressArray);
        System.debug('ccAddressArray Size==='+ccAddressArray.size());
        System.debug('bccAddressArray Size==='+bccAddressArray.size());
        System.debug('bccAddressArray Val==='+bccAddressArray);
        if(ccAddressArray != null && ccAddressArray.size() > 0){
            mail.setCcAddresses(ccAddressArray);
        }

        if(bccAddressArray !=null && bccAddressArray.size() > 0){
            mail.setBccAddresses(bccAddressArray);
        }

        if(String.isNotEmpty(fromAddressVal) && fromAddressVal.startsWith('0D2')){
            //mail.setSenderDisplayName(fromAddressVal);
            mail.setOrgWideEmailAddressId(fromAddressVal);
        }
        
        mail.setWhatId(parentObjRecId);
        mail.setSaveAsActivity(true);

        // Set Template and RecordId.....
        if(String.isNotEmpty(templateIdStr)){
            mail.setTemplateId(templateIdStr);
        }

        if(String.isNotEmpty(parentObjRecId)){
          //  mail.setTargetObjectId(parentObjRecId);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }


     /***********************************************
    * Method Name : getCWMPFromAddressOptions
    * Author : Shantanu
    * Inputs : 1. String default From Email Name(QWA), applicationId(HH_Application__c) 
    * Description: This method will will provide from Email Address based on Current User Permission Set .
    *********************************************/
     // Provide From Address Option Val...
     @AuraEnabled(Cacheable=true)
     public static List<FromEmailOptionsWrapper> getCWMPFromAddressOptions(String fromEmail,String applicationId) {
        System.debug('fromEmail---'+fromEmail);
        String userEmail = UserInfo.getUserEmail();
        List<FromEmailOptionsWrapper> formAddressOption = new List<FromEmailOptionsWrapper>();
        String query = 'SELECT Id, Address, Displayname FROM OrgWideEmailAddress WHERE DisplayName = \''+fromEmail+'\'';
        County_Config__mdt countyConfig = getCountyConfig();
        List<String> countyEmails = new List<String>();
        //Check the County configs Email is Org - Wide Addresses
        if(countyconfig != null && countyconfig.Emails__c != null) {
            String countyEmail =  countyconfig.Emails__c.replace(';', '$').replace(',', '$').replaceAll('(\\s+)', '');
            countyEmails = countyEmail.split('\\$');
            if(countyEmails.size() > 0) {
                query += ' OR Address IN (\''+String.join(countyEmails,'\',\'')+'\')';
            }
        }
        boolean addFromEmail = true;
        boolean isCommunityUser = isCommunityUser();
        if(countyConfig != null && countyConfig.Show_NoReply_Email_Address__c == false && isCommunityUser ) {
            addFromEmail = false;
        }
        System.debug('Query: '+query);
        List<OrgWideEmailAddress> orgWideEmailAddresses = Database.query(query);
        System.debug('orgwideAddresses---'+orgWideEmailAddresses);
        List<FromEmailOptionsWrapper> otherAddressOptions = new List<FromEmailOptionsWrapper>();
        if(orgWideEmailAddresses.size() > 0) {

            //first add From Email Address provided to method
            for (OrgWideEmailAddress orgWideAddress : orgWideEmailAddresses) {
                if(orgWideAddress.DisplayName == fromEmail && addFromEmail) {
                    FromEmailOptionsWrapper fromEmailOption = new FromEmailOptionsWrapper(orgWideAddress.Address, String.valueOf(orgWideAddress.Id));
                    formAddressOption.add(fromEmailOption);   
                    break;
                } 
            }
            //Second Add Current user Email Address if its communityUser
            if(countyconfig != null && isCommunityUser) {
                FromEmailOptionsWrapper fromEmailOption = new FromEmailOptionsWrapper(userEmail, userEmail);
                formAddressOption.add(fromEmailOption);   
            }
             //Add Rest of From Email Addresses.
            for (OrgWideEmailAddress orgWideAddress : orgWideEmailAddresses) {
                if(orgWideAddress.DisplayName != fromEmail) {
                    FromEmailOptionsWrapper fromEmailOption = new FromEmailOptionsWrapper(orgWideAddress.Address, String.valueOf(orgWideAddress.Id));
                    formAddressOption.add(fromEmailOption);   
                } 
            }
        }

        //Add Current user Email Address if its not community user.
        if(countyconfig == null && !isCommunityUser) {
            FromEmailOptionsWrapper fromEmailOption = new FromEmailOptionsWrapper(userEmail, userEmail);
            formAddressOption.add(fromEmailOption);   
        }
        return formAddressOption;                               
    }

    private static Boolean isCommunityUser() {
        List<User> userRecord = [SELECT Id, Name, Profile.Name, AccountId, ContactId,
        (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
        FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if(userRecord?.size()==1){
            for(PermissionSetAssignment perSet:userRecord[0].PermissionSetAssignments){
                if(perSet.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName) {
                    return true;
                }
            }
        }
        return false;
    }

    private static County_Config__mdt getCountyConfig() {
        List<GroupMember> members = [SELECT Id,GroupId,Group.DeveloperName FROM GroupMember WHERE UserOrGroupId =:UserInfo.getUserId() AND Group.Type = 'Queue'];
        List<String> countyEmails = new List<String>();
        if(members.size() > 0 ) {
            System.debug('members: '+members.get(0).Group.DeveloperName);
            List<County_Config__mdt> countyconfigs = [SELECT Id,Emails__c,Show_NoReply_Email_Address__c FROM County_Config__mdt WHERE Queue_API_Name__c =: members.get(0).Group.DeveloperName];
            System.debug('countyconfigs: '+countyconfigs);
            if(countyconfigs.size() > 0 ) {
                return countyconfigs.get(0);    
            }
        }
        return null;
    }

    // Provide From Address Option Val...
    @AuraEnabled(Cacheable=true)
    public static List<FromEmailOptionsWrapper> getFromAddressOptions(String fromEmail) {
        System.debug('fromEmail---'+fromEmail);
        List<FromEmailOptionsWrapper> formAddressOption = new List<FromEmailOptionsWrapper>();
        List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address, DisplayName
                                          FROM OrgWideEmailAddress WHERE DisplayName=:fromEmail];
        System.debug('orgwideAddresses---'+orgWideEmailAddresses);
        if(orgWideEmailAddresses.size() > 0) {
            FromEmailOptionsWrapper fromEmailOption = new FromEmailOptionsWrapper(orgWideEmailAddresses[0].Address, String.valueOf(orgWideEmailAddresses[0].Id));
            formAddressOption.add(fromEmailOption);
        }
        String userEmail = UserInfo.getUserEmail();
        FromEmailOptionsWrapper fromEmailOption = new FromEmailOptionsWrapper(userEmail, userEmail);
        formAddressOption.add(fromEmailOption);
        System.debug('fromAddressOptions---'+formAddressOption);
        return formAddressOption;                               
    }

    private static void validateEmailFields(String toAddressVal, String SubjectVal ){
        if(String.isEmpty(toAddressVal)){
            throw new CustomException('To Address field cannot be empty');
        }

         if(String.isEmpty(SubjectVal)){
            throw new CustomException('Subject field cannot be empty');
        }
    }

    public class FromEmailOptionsWrapper {
        @AuraEnabled public String key;
        @AuraEnabled public String value;
        public FromEmailOptionsWrapper(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }

    public class CustomException extends Exception {
   
    }
    
}