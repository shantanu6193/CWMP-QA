public without sharing class HMA_ApplicationCtrl {

    @AuraEnabled
    public static Map<String,Object> processRecord(String objectApiName, String appRecord, String accRecord, String workScheduleLineItems, String recordId, String programTemplatePageId, String projectCostLineItems, String buttonAction) {
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            if(String.isNotEmpty(accRecord)) {
                Account acc = (Account) JSON.deserialize(accRecord, Account.class);
                update acc;
                returnMap.put('account', acc);
            }
            if(objectApiName.equals('Application__c')){
            Application__c app = (Application__c) JSON.deserialize(appRecord, Application__c.class);
                Application__c appDetails = [SELECT Id, Status__c, Status_Reason__c FROM Application__c WHERE Id =: app.Id];
                if((buttonAction.equals('Save & Continue') || buttonAction.equals('quickSave')) && appDetails.Status__c == 'Draft'){
                    app.Status_Reason__c = HMA_CONSTANTS.APPLICATION_STATUS_REASON_IN_PROGRESS;
                }
            update app;        
            returnMap.put('application', app);
            }else if(objectApiName.equals('Application_Extension__c')){
                Application_Extension__c app = (Application_Extension__c) JSON.deserialize(appRecord, Application_Extension__c.class);
                update app;
                returnMap.put('application', app);
            }                     
            if(String.isNotEmpty(workScheduleLineItems)) {
               List<Work_Schedule_Line_Item__c> workScheduleLineItemList = (List<Work_Schedule_Line_Item__c>) JSON.deserialize(workScheduleLineItems, List<Work_Schedule_Line_Item__c>.class);
                upsert workScheduleLineItemList;
                returnMap.put('workScheduleLineItems', workScheduleLineItemList);
            }
            if(String.isNotBlank(projectCostLineItems)) {
                List<Project_Cost_Line_Item__c> projectCostLineItemList = (List<Project_Cost_Line_Item__c>) JSON.deserialize(projectCostLineItems, List<Project_Cost_Line_Item__c>.class);
                upsert projectCostLineItemList;
                returnMap.put('projectCostLineItems', projectCostLineItemList);
            }
			if(buttonAction.equals('submit') &&  ((Id)recordId).getSobjectType().getDescribe().getName().equals('Application__c')){
                Group queues = [SELECT Id FROM Group WHERE DeveloperName=:HMA_CONSTANTS.SUB_APPLICATION_QUEUE AND Type='Queue'];
                Application__c app = new Application__c(Id= recordId);
                app.Status__c = HMA_CONSTANTS.APPLICATION_STATUS_OES_REVIEW;
                app.Status_Reason__c = HMA_CONSTANTS.APPLICATION_STATUS_REASON_PENDING_OES_REVIEW;
                app.OwnerId = queues.Id;
                update app;
                deleteProjectSites(app);
            }
            returnMap.putAll(PageLayoutHelper.handleNextPreviousProgramTemplatePage(buttonAction, recordId, programTemplatePageId));// findNextProgramTemplatePage(recordId, programTemplatePageId),
            returnMap.put('isSuccess', true);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            String errorMsg = CustomExceptionController.getSpecificErrorMessage(e.getMessage());        
            throw new AuraHandledException(errorMsg);
        }
        return returnMap;
    }

    /* This method delete project sites custom document object records and contentDocuments  
    *  related to project sites
    */
    private static void deleteProjectSites(Application__c app) {
        List<Project_Site__c> projectSites = [SELECT Id FROM Project_Site__c WHERE Application__c = :app.Id AND Is_Discarded__c = true];
        if(projectSites.size() == 0) return;
        
        Set<Id> projectSiteIds = new Set<Id>();
        for(Project_Site__c ps : projectSites) {
            projectSiteIds.add(ps.Id);
        }

        //Delete custom document records
        Document__c[] customDocumentList = [SELECT Id FROM Document__c WHERE Project_Site__c IN :projectSiteIds];
        if(customDocumentList.size() > 0){
            Set<Id> customDocumentIds = new Set<Id>();
            List<Id> docIdList = new List<Id>();
        for(Document__c doc : customDocumentList) {
            customDocumentIds.add(doc.Id);
        }

        //To get the contentDocumentId we query on contentDocumentLink
        List<ContentDocumentLink> contentDocumentLinkList =[SELECT Id,ContentDocumentId FROM ContentDocumentLink 
                                                                WHERE LinkedEntityId IN :customDocumentIds];
        for(ContentDocumentLink cdl: contentDocumentLinkList){
            docIdList.add(cdl.contentdocumentid);
        }
        List<ContentDocument> conDocList =[SELECT Id FROM ContentDocument where Id IN :docIdList];
        
            if(customDocumentList.size() > 0){
                delete customDocumentList;
            }
            if(conDocList.size() > 0){
                delete conDocList;
            }
        }
        delete projectSites;
    }

    @AuraEnabled
    public static Map<String,Object> processNextPreviousProgramTemplatePage(String recordId, String buttonAction, String programTemplatePageId) {
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            returnMap.putAll(PageLayoutHelper.handleNextPreviousProgramTemplatePage(buttonAction, recordId, programTemplatePageId));// findNextProgramTemplatePage(recordId, programTemplatePageId),
            returnMap.put('isSuccess', true);
        } catch (Exception e) {
            returnMap.put('isSuccess', false);
            String errorMsg = CustomExceptionController.getSpecificErrorMessage(e.getMessage());
            throw new AuraHandledException(errorMsg);
        }
        return returnMap;
    }
    @AuraEnabled
    public static Map<String,Object> processReadOnlyRecord(String recordId, String programTemplatePageId, String buttonAction){
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            returnMap.putAll(PageLayoutHelper.handleNextPreviousProgramTemplatePage(buttonAction, recordId, programTemplatePageId));// findNextProgramTemplatePage(recordId, programTemplatePageId),
            returnMap.put('isSuccess', true);
        }catch (Exception e){
            returnMap.put('isSuccess', false);
            String errorMsg = CustomExceptionController.getSpecificErrorMessage(e.getMessage());
            throw new AuraHandledException(errorMsg);
        }
        return returnMap;
    }

    /*below method not in used remove the reference from applicationWorkSchedule LWC cmp*/
    @AuraEnabled
    public static List<ContentVersion> fileUpload(String documentId){
        try{
            List<ContentVersion> conVer = new List<ContentVersion>();
            if(String.isNotEmpty(documentId)){
                conVer = [SELECT Id, Title, FileType, Document_Type__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: documentId];
                for(ContentVersion cv : conVer) {
                    cv.Document_Type__c = 'GANTT Chart';                                  
                }
                update conVer;                
            }
            return conVer;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<ContentVersion> getFiles(String workScheduleId, String documentType){
        try {
            List<ContentVersion> contentVersionsList = new List<ContentVersion>();
            if(String.isNotEmpty(workScheduleId) && String.isNotEmpty(documentType)){
                List<String> contentDocIds = new List<String>();
                List<String> docTypes = (List<String>) JSON.deserialize(documentType, List<String>.class);
                List<ContentDocumentLink> contentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: workScheduleId];                
                for(ContentDocumentLink cdl : contentLink) {
                    contentDocIds.add(cdl.ContentDocumentId);
                }
                contentVersionsList = [
                                        SELECT  Id, 
                                                Title, 
                                                FileType,
                                                ContentDocumentId,
                                                Document_Type__c,
                                                CreatedDate
                                        FROM ContentVersion WHERE ContentDocumentId IN :contentDocIds AND Document_Type__c IN: docTypes Order by CreatedDate ];
                System.debug('contentVersionsList : '+contentVersionsList);
            }
            return contentVersionsList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled
    public static Boolean removeFile(String contentDocId){
        List<ContentDocument> ContentDocumentList = new List<ContentDocument>();
        try {
            if(String.isNotEmpty(contentDocId)) {
                ContentDocumentList = [SELECT  Id FROM ContentDocument WHERE Id =: contentDocId];
                delete ContentDocumentList;
                return true;
            }            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    @AuraEnabled
    public static List<Work_Schedule_Line_Item__c> getWorkScheduleLineItem(String appId){
        List<Work_Schedule_Line_Item__c> workScheduleLineItemList = new List<Work_Schedule_Line_Item__c>();
        try {
            if(String.isNotEmpty(appId)){
                workScheduleLineItemList = [SELECT Id, 
                                                    Work_Schedule__c,
                                                    Work_Schedule__r.Project_Plan_Duration_In_Months__c,
                                                    Phase__c, 
                                                    Task_Name__c, 
                                                    Description__c,
                                                    Start_Month__c,
                                                    Duration_Months__c
                                                    FROM Work_Schedule_Line_Item__c WHERE Work_Schedule__r.Application__c =: appId ORDER BY Start_Month__c ASC];
            }
            return workScheduleLineItemList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getApplication(String appId){
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            if(String.isNotEmpty(appId)){
                Application__c app = [SELECT Id, 
                                            Application_Type__c, 
                                            Subapplicant_Entity__c, 
                                            Program__c, 
                                            Subapplicant_Entity__r.Is_this_project_phased__c,
                                            (SELECT Id FROM Work_Schedules__r)
                                            FROM Application__c WHERE Id =: appId];
                returnMap.put('application', app);
                returnMap.put('workSchedules', app.Work_Schedules__r);
            }
            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean updateLineItems(String lineItemRecords, String workScheduleRecord) {
        try {
            if(String.isNotEmpty(workScheduleRecord)) {
                List<Work_Schedule__c> workSchedule = (List<Work_Schedule__c>) JSON.deserialize(workScheduleRecord, List<Work_Schedule__c>.class);
                if(workSchedule.size() > 0) {
                    update workSchedule;
                }
            }
            if(String.isNotEmpty(lineItemRecords)) {
                List<Work_Schedule_Line_Item__c> lineItems = (List<Work_Schedule_Line_Item__c>) JSON.deserialize(lineItemRecords, List<Work_Schedule_Line_Item__c>.class);
                if(lineItems.size() > 0) {
                    upsert lineItems;
                    return true;
                }
            }            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }

    @AuraEnabled 
    public static Map<String, Object> updateProjectSiteRecord(String recordDetails, String mode, String parentId){
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            Project_Site__c projectSite = (Project_Site__c) JSON.deserialize(recordDetails, Project_Site__c.class);
            projectSite.Is_Discarded__c = false;
            update projectSite;
            returnMap.put('projectSite', projectSite);
            returnMap.put('isSuccess', true);
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> getProjectSitePageDetails(String projectSiteId, String projectSitePageId, String parentId, String mode){
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            if(String.isNotEmpty(parentId)){
                /*Return the page Layout details*/
                Map<String, Object> projectSiteMap = PageLayoutHelper.getProgramTemplatePageForProjectSite(parentId, null, null);
                returnMap.putAll(projectSiteMap);//projectSiteId present then it will find the first site page details
                if(String.isEmpty(projectSiteId) && (Boolean) projectSiteMap.get('isSuccess') && mode.equals('create')){ 
                    System.debug('Project Site Page Found');
                    //Application_Extension__c applicationExtension = [SELECT Id from Application_Extension__c WHERE Application__c=:parentId LIMIT 1];
                    Project_Site__c projectSite = new Project_Site__c();
                    projectSite.Application__c = parentId;
                    projectSite.Application_Extension__c = [SELECT Id from Application_Extension__c WHERE Application__c=:parentId LIMIT 1]?.Id;
                    insert projectSite;
                    Id projectSiteRecordTypeId = Schema.SObjectType.Project_Cost__c.getRecordTypeInfosByDeveloperName()
                                    .get(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE).getRecordTypeId();
                    Project_Cost__c projectCost = new Project_Cost__c(Project_Site__c = projectSite.Id, RecordTypeId=projectSiteRecordTypeId);
                    insert projectCost;
                    returnMap.put('projectSiteRecord',projectSite);
                }
            }
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Contact_Role__c processOnContactInformation(Map<String, Object> recordDetailsMap) {
        try{
            List<Contact> relatedContact = new List<Contact>();
            System.debug('recordDetailMap---'+recordDetailsMap);
            String recordDetails = String.valueOf(recordDetailsMap.get('recordDetails'));
            Boolean createAccount = (Boolean) recordDetailsMap.get('createAccount');
            System.debug('createAccount---'+createAccount);
            Contact_Role__c contactRoleDetail = (Contact_Role__c) JSON.deserialize(recordDetails, Contact_Role__c.class);
            String accountId = '';
            if(contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) || contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR)) {
                accountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()]?.AccountId;
            } else {
                System.debug('createAccount---'+createAccount);
                if(createAccount == false && String.isNotBlank(String.valueOf(recordDetailsMap.get('accountId')))) {
                    accountId = String.valueOf(recordDetailsMap.get('accountId'));
                } else if(createAccount == true){
                    //create account
                    accountId = HMA_ApplicationHelper.processAccount(recordDetailsMap);
                }
            }
            
            System.debug('recordDetails Deserialized---'+contactRoleDetail);
            if(String.isNotEmpty(contactRoleDetail.Contact__r.Email) && String.isEmpty(contactRoleDetail.Contact__r.Id)) {
                String email = contactRoleDetail.Contact__r.Email;
                relatedContact = [SELECT Id, Title, FirstName, LastName, Phone, Email FROM Contact WHERE Email =: email];
            }
            if(relatedContact.size() > 0) {
                contactRoleDetail.Contact__r = null;
                contactRoleDetail.Contact__c = relatedContact[0].Id;
            }else {
                //TODO: Set Account Id
                Contact con = contactRoleDetail.Contact__r;
                System.debug('con---'+con);
                System.debug('accountId---'+accountId);
                if(con.AccountId == null && String.isNotBlank(accountId)){
                    con.AccountId = accountId;
                }                
                relatedContact.add(con);
                upsert relatedContact;
                contactRoleDetail.Contact__c = relatedContact[0].Id;
            }
            //If user exists in salesforce as a contact and it's role is added as Responsible Representative
            //List<User> users = [SELECT Id FROM User WHERE ContactId = :relatedContact[0].Id];
            //TODO: Use Static variables for Role
            //TODO: Share Document Records as well
            /*if(contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) || contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR) || contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR) || contactRoleDetail.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER)) {
                HMA_ApplicationHelper.processAccountContactRole(relatedContact[0], contactRoleDetail, accountId);
                HMA_ApplicationHelper.prepareDataForSendingEmail(relatedContact[0], contactRoleDetail);
                HMA_ApplicationHelper.processCommunityUser(relatedContact[0], contactRoleDetail, users);
                System.debug('----shareSubApplication----------');
                HMA_ApplicationHelper.shareSubApplication(relatedContact[0], contactRoleDetail, users);
            }*/
            upsert contactRoleDetail;
            return contactRoleDetail;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CommAppActionClass {
        public String action;
        public String value;
    }
    
    /**
     * To get Current logged in user role for the application based on role we are deciding the application access
     * Responsible Representative = can edit,submit application
     * Primary Contact = can edit sub application but not allowed to submit
     * Contributor = can edit sub application but not allowed to submit and send match and maintenance commitment latter
     * Viewer = can only view the sub application
     * */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLoggedInUserContactRoleForApplication(String applicationId){
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('isSuccess', false);
            User[] user = [Select Id, ContactId from User where Id=: UserInfo.getUserId()];
            System.debug('user :'+ user);
            if(user.size() > 0){
                Contact_Role__c[] contactRoles = [SELECT Id,Role__c, Application__r.Status__c, Application__r.Status_Reason__c, Application__r.Is_Any_Open_RFI__c FROM Contact_Role__c WHERE Application__c =:applicationId AND AccountContactJunction__r.Contact_Name__c=:user[0].ContactId];
                System.debug('contactRoles :'+ contactRoles);
                if(contactRoles.size() > 0){
                    returnMap.put('contactRole', contactRoles[0]);
                    returnMap.put('isSuccess', true);
                }
            }
            return returnMap;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
	@AuraEnabled
    public static String getAccountDetails(String contactId) {
        try {
            if(String.isBlank(contactId)) return '';
            String entityType = [SELECT Account.Entity_Type__c, Account.Name FROM Contact WHERE Id = :contactId]?.Account.Name;
            return entityType;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}