/*
 *Class Name   : PA_RequestCloseoutController
 * Description  : This class used to create closeout Request. On close out list view of poratl once you click
 *                on new we have override lwc component to create closeout Request.
 *                On this community Portal page, You can search on Incident and Sub recipient is autopopulated or 
 *                in internal portal  You can search both Incident and Sub recipient.
 *                Post selection you will get Projects whose closeout is not initiated.
 *                Once you click on submit closeout request and project closeout  will get created.
 * Author       : Dayal
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Dayal             28/05/2021       Initial Implementation
**/

public without sharing class PA_RequestCloseoutController {

    /*******************************************************************************
    * Method Name  : isCurrentUserPortal
    * Description  : This method is used to loged in user is portal user or internal user
    * Return       : true if logged in user is portal    
    * Inputs       : 
    * Author       : Prajakta
    * Created On   : 08/11/2021
    * Modification Log: 
    *******************************************************************************/
    @AuraEnabled
    public static Boolean isCurrentUserPortal() {
        return AppUtils.isLoggedInUserPortal();
    }

    /*******************************************************************************
    * Method Name  : getProjectsForSR
    * Description  : This method is used to get Project based on selected Sub Recipient or Incident or selected program
    * Return       : List of Projects    
    * Inputs       : String selectedSRRecordId, String selectedIncidentRecordId, String selectedProgramname   
    * Author : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    @AuraEnabled
    public static List<Project__c> getProjectsForSR(String selectedSRRecordId, String selectedIncidentRecordId, String selectedProgramname) {
        // Sub Recipient , Incident and Program is required to search project. If either is blank then throw exception.
        if(String.isEmpty(selectedIncidentRecordId) || String.isEmpty(selectedSRRecordId) || String.isEmpty(selectedProgramname)) {
            throw new AuraHandledException('Please select Sub Recipient and Incident and Program Type');
        }

        //todo - need discussion - in case of community show all projects or only shared projects?
        List<Project__c> projList = new List<Project__c> ();
        // check the logged in user is not portal user
        if(AppUtils.isLoggedInUserPortal() == false) {

            projList = [Select Id, Name, Project_Number__c, Declaration_Number__c,
            Was_Ever_Large__c, Total_Project_Award__c, Percent_Complete_To_Date__c
                    from Project__c where Id Not IN (SELECT Project_Name__c
                        FROM Project_Closeout__c
                        WHERE Project_Name__r.Obligating_Sub_Recipient__c =:selectedSRRecordId
                        AND Project_Name__r.Incident_Name__c =: selectedIncidentRecordId
                        AND Closeout_Request__c != null)
                        AND Obligating_Sub_Recipient__c =:selectedSRRecordId
                        AND Incident_Name__c =: selectedIncidentRecordId           
                        AND  Funding_Opportunity_Name__r.Program_Name__r.Name =:selectedProgramname
                    ];

        }
        
        // if no project found then throw exception on UI. 
        if(projList.size() == 0) {
            throw new AuraHandledException('Projects not available for selected incident and subrecipient');
        }       

        return projList;
    }

    /*****************************************************************************
    * Method Name    : apexSearchIncident
    * Description    : This method is used to get Project based on selected Sub Recipient or Incident or selected program
    * Return         : List of Lookup result which contains Incidents   
    * Inputs         : String searchTerm   
    * Author         : Dayal
    * Created On     : 26/05/2021
    * Modification Log: 
    *******************************************************************************/

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchIncident(String searchTerm) {
        // Prepare query paramters
        String query = 'SELECT Id, Name, Program_Name__r.Name, Declaration_Number__c, Incident_Name__r.Name FROM Funding_Opportunity__c WHERE Name != null';
        // add filter clause only if added by user
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND (Incident_Name__r.Name like\'%' + searchTerm + '%\' OR Declaration_Number__c like\'%' + searchTerm + '%\')';
        }
        query += ' AND Incident_Name__c IN(SELECT Incident_Name__c FROM Project__c)';
        // add filter clause if loged in user is not community poratl user
        if(ApexUtils.checkCommunityUser() == false) {
            query += ' AND Program_Name__r.Name IN(\'PA - Federal\', \'CDAA (State Funding)\', \'PA - FMAG\')';
        } else{       
            query += ' AND Program_Name__r.Name IN(\'PA - Federal\', \'CDAA (State Funding)\')';
        }
        
        query += ' Limit 200';



        List<Funding_Opportunity__c> fundingOpsList = Database.query(query);

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract incidents & convert them into LookupSearchResult
        String productIcon = 'standard:account';
        String subtitle = '';

        for (Funding_Opportunity__c fundingOp : fundingOpsList) {
            subtitle = '';
            if(!String.isBlank(fundingOp.Program_Name__r.Name)){
                subtitle = fundingOp.Program_Name__r.Name + ' ; ';
            }
            if(!String.isBlank(fundingOp.Declaration_Number__c)){
                subtitle += fundingOp.Declaration_Number__c;
            }
            results.add(
                    new LookupSearchResult(
                            fundingOp.Id,
                            'Account',
                            productIcon,
                            fundingOp.Incident_Name__r.Name,
                            subtitle,
                            fundingOp
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    /*****************************************************************************
    * Method Name : apexSearchAgency
    * Description  : This method return list of LookupSearchResult from Account
    * Return       : List of Lookup result which contains Account  
    * Inputs       : String searchTerm 
    * Author       : Pankaj
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchAgency(String searchTerm) {
        // Prepare query paramters
        String query = 'Select Id,Name,Entity_Type__c From Account ';
        // add filter clause only if added by user
        if(String.isNotEmpty(searchTerm)) {
            query += ' Where Name like\'%' + searchTerm + '%\'';
        }

        query += ' Limit 200';
        
        List<Account> accounts = Database.query(query);
        // Prepare results
        // Extract Accounts & convert them into LookupSearchResult
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String productIcon = 'standard:account';
        for (Account opProductReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opProductReference.Id,
                            'Account',
                            productIcon,
                            opProductReference.Name,
                            (opProductReference.Entity_Type__c != null ? opProductReference.Entity_Type__c  : ''),
                            opProductReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    /*****************************************************************************
    * Method Name : initiateCloseout
    * Description  : This method generate the closeout request and share to public group
                     with read permission and added the documents this closeout request.
    * Return       : id of generated closeout request 
    * Inputs       : String  projectLst, List<String> files, String subrecipient, String incident,
                     String closeoutCheckList, String selectedProgramType 
    * Author : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    @AuraEnabled
        public static String initiateCloseout( String  projectLst, List<String> files, List<String> fileNames, String subrecipient, String incident,String closeoutCheckList, String selectedProgramType,  String authorizedAgent, String SignedP4DocumentAvailable ) {
        List<Object> projectData ;
        //add the filter clause of program type 
        if(selectedProgramType == PA_CONSTANTS.PA_PROGRAM_FEDERAL || selectedProgramType == PA_CONSTANTS.PA_PROGRAM_CDAA) {
            if(files.isEmpty() && AppUtils.isLoggedInUserPortal() == true) {
                throw new AuraHandledException('Please upload p4 file');
            }
        }
       
        // add filter clause project list should not empty
        if(String.isEmpty(projectLst)) {
            throw new AuraHandledException('Please select project');
        } else {            
            projectData = (List<Object>) JSON.deserializeUntyped(projectLst);            
        }

        List<Group> recordOwner= [SELECT Id FROM Group  WHERE DeveloperName ='Public_Assistance_Analyst' AND Type='Queue'];

        Closeout_Request__c closeoutRequest = new Closeout_Request__c();      
        closeoutRequest.Request_Date__c = System.today();
        closeoutRequest.Subrecipient__c = subrecipient;
        closeoutRequest.Incident__c = incident;
        closeoutRequest.Authorized_Agent__c = authorizedAgent;
        closeoutRequest.Signed_P_4_Document_Available__c = SignedP4DocumentAvailable;
        closeoutRequest.Program_Name__c = selectedProgramType;
        closeoutRequest.Status__c = 'Pending SR Claim';
        //if record owner found
        if(recordOwner.size() > 0){
            closeoutRequest.OwnerId = recordOwner[0].Id;
        }

        //if portal user is loged in
        if(AppUtils.isLoggedInUserPortal() == true){
            closeoutRequest.Requestor__c = UserInfo.getUserId();
        }

        Closeout_Request__c closeoutRequestInstance = PA_SystemContextHelper.upsertCloseoutRequest(closeoutRequest);

         /*Note: As per new requirement project closeut should not create while creating time of closoeut request 
                    now create the closoeut request time ww need to link project closeout as per selected project
        */
        List<Project__c> projectList = new List<Project__c>();

        Set<Id> projectIdSet = new Set<Id>();
        for(Object projRec : projectData) {
                Map<String,Object> mapfpidata = (Map<String,Object>)projRec;
                
                //update Project object to  Closeout_Request__c
                Project__c project = new Project__c(Id = String.valueof(mapfpidata.get('Id')), Closeout_Request__c = closeoutRequest.Id);
                projectList.add(project);

                //added project Id in set
                projectIdSet.add(String.valueof(mapfpidata.get('Id')));
        }

        //Retrive the all project closeout as per selected project -new logic
        List<Project_Closeout__c> projectCloseOutList = [SELECT Id, Name, Project_Name__r.Id, Project_Name__r.Name, Project_Name__c,Closeout_Request__c, CreatedById  FROM Project_Closeout__c
                                                        where Project_Name__r.Id In: projectIdSet];
        Set<Id> projectClosueoutCreatedIdSet = new Set<Id>();
        Set<Id> existingProjectWithProjectClseoutIds = new Set<Id>();
        for(Project_Closeout__c projClo  : projectCloseOutList){
            existingProjectWithProjectClseoutIds.add(projClo.Project_Name__c);
        }
        for(Project__c proj : projectList){
            if(existingProjectWithProjectClseoutIds.contains(proj.Id) ==  false){
                Project_Closeout__c closeoutInitiate = new Project_Closeout__c();
                closeoutInitiate.Project_Name__c = proj.Id;
                closeoutInitiate.Status__c = 'Request for Closeout';
                if(recordOwner.size() > 0){
                    closeoutInitiate.OwnerId = recordOwner[0].Id;
                }
                projectCloseOutList.add(closeoutInitiate);
            }
        }

        Map<String,String> projectWithProjectClseoutMap = new  Map<String,String>();
        for(Project_Closeout__c projectClosOut : projectCloseOutList){

                projectClosOut.Closeout_Request__c  = closeoutRequest.Id;
                    for(Object selectedProject : projectData) {

                            Map<String,Object> mapfpidata = (Map<String,Object>)selectedProject;
                            
                            if(projectClosOut.Project_Name__r.Id == String.valueof(mapfpidata.get('Id')) && String.valueof(mapfpidata.get('Total_Amount_Claimed__c')) !=null && String.valueof(mapfpidata.get('Total_Amount_Claimed__c')) != '') {

                                projectClosOut.Total_Amount_Claimed__c = decimal.valueOf(String.valueof(mapfpidata.get('Total_Amount_Claimed__c')));
                            }   
                    }                       
                projectClosueoutCreatedIdSet.add(projectClosOut.CreatedById);
        }
        TriggerHelper.skipTrigger = false;
        PA_SystemContextHelper.upsertProjectCloseouts(projectCloseOutList);
        for(Project_Closeout__c closeout : projectCloseOutList){
            projectWithProjectClseoutMap.put(closeout.Project_Name__c,closeout.Id);

        }

        List<Incident_Subrecipient_Stage__c> incidentSubrecipientSummaryList = [SELECT id FROM Incident_Subrecipient_Stage__c Where Incident__c =:incident AND Account__c =: subrecipient];
        List<String> incidentSubrecipientIdList = new List<String>();
        for(Incident_Subrecipient_Stage__c incidentSub : incidentSubrecipientSummaryList){
            incidentSubrecipientIdList.add(incidentSub.Id);
        }

        String projectRoleGobalList = KeyValueHelper.getTextValue('PA_Project_Role_Global_List');
        List<String> projectRoleListCommaSeprated = projectRoleGobalList.split(',');
        List<Project_Role__c> projectRoleRecordList = [SELECT Id, Incident_Subrecipient_Summary__c, Project_Role_Global_List__c, AccountContactJunction__r.Contact_Name__c,
                                                        Project_Name__c, Subrecipient__c FROM Project_Role__c WHERE
        ((Incident_Subrecipient_Summary__c IN: incidentSubrecipientIdList AND Programs__c=:PA_CONSTANTS.PA_PARENT_PROGRAM_NAME) OR  (Subrecipient__c =: subrecipient AND Programs__c=:PA_CONSTANTS.PA_PARENT_PROGRAM_NAME) OR Project_Name__c IN: projectIdSet) AND Project_Role_Global_List__c IN: projectRoleListCommaSeprated];
       

        Set<Id> contactIdList = new Set<Id>();
        for(Project_Role__c projectRole : projectRoleRecordList) {
            if(projectRole.AccountContactJunction__c != null) {
                contactIdList.add(projectRole.AccountContactJunction__r.Contact_Name__c);
            }
        }
       
        Map<Id, Id> contactToUserId = new Map<Id, Id>();
        if(contactIdList != null){
            List<User> userValueList = [SELECT Id,ContactId FROM User WHERE ContactId IN: contactIdList AND ContactId != NULL];
            for (User userRec : userValueList) {
                contactToUserId.put(userRec.ContactId, userRec.Id);
            }
        }

        List<Project_Role__c> projectRoleWithIncidentSubrecipient = new  List<Project_Role__c>();
        List<Project_Role__c> projectRoleWithProjects = new  List<Project_Role__c>();
        for(Project_Role__c role : projectRoleRecordList){
            if(String.isNotEmpty(role.Incident_Subrecipient_Summary__c) || String.isNotEmpty(role.Subrecipient__c)){
                projectRoleWithIncidentSubrecipient.add(role);
            }
        }

        for(Project_Role__c role : projectRoleRecordList){
            if(String.isNotEmpty(role.Project_Name__c) ){
                projectRoleWithProjects.add(role);
            }
        }
        List<Project_Closeout__Share> projectCloseoutShareListToInsert  = new List<Project_Closeout__Share>();
        for(Project_Role__c projRole : projectRoleWithIncidentSubrecipient){
            for(Project_Closeout__c projectClosOut : projectCloseOutList){
                Project_Closeout__Share projectCloseoutShare = new Project_Closeout__Share();
                // Set the ID of record being shared
                projectCloseoutShare.ParentId = projectClosOut.Id;
                // Set the ID of user or group being granted access
                projectCloseoutShare.UserOrGroupId = contactToUserId.get(projRole.AccountContactJunction__r.Contact_Name__c);
                // Set the access level
                projectCloseoutShare.AccessLevel = 'Read';
                projectCloseoutShare.RowCause = Schema.Project_Closeout__Share.RowCause.ProjectCloseoutShare__c;

                // Add objects to list for insert
                projectCloseoutShareListToInsert.add(projectCloseoutShare);
            }
        }
        PA_SystemContextHelper.insertProjectCloseoutShareRecords(projectCloseoutShareListToInsert);


        List<Project_Closeout__Share> projectCloseoutShareList  = new List<Project_Closeout__Share>();
        for(Project_Role__c projRole : projectRoleWithProjects){
            for(Project_Closeout__c projectClosOut : projectCloseOutList){
                if(projRole.Project_Name__c == projectClosOut.Project_Name__c){
                    Project_Closeout__Share projectCloseoutShare = new Project_Closeout__Share();
                    // Set the ID of record being shared
                    projectCloseoutShare.ParentId = projectClosOut.Id;
                    // Set the ID of user or group being granted access
                    projectCloseoutShare.UserOrGroupId = contactToUserId.get(projRole.AccountContactJunction__r.Contact_Name__c);
                    // Set the access level
                    projectCloseoutShare.AccessLevel = 'Read';
                    projectCloseoutShare.RowCause = Schema.Project_Closeout__Share.RowCause.ProjectCloseoutShare__c;

                    // Add objects to list for insert
                    projectCloseoutShareList.add(projectCloseoutShare);
                }

            }
        }
        PA_SystemContextHelper.insertProjectCloseoutShareRecords(projectCloseoutShareList);



        //---------------closeout Request share------------------------------------------------------
        List<Closeout_Request__Share> closeoutShareListToInsert  = new List<Closeout_Request__Share>();
        Set<String> toAddress = new Set<String>();
        List<String> toAddresses = new List<String>();
        //for(Id id : projectClosueoutCreatedIdSet){
            for(Project_Role__c projectRole : projectRoleRecordList) {
                if(contactToUserId.get(projectRole.AccountContactJunction__r.Contact_Name__c) != null) {
                toAddress.add(contactToUserId.get(projectRole.AccountContactJunction__r.Contact_Name__c));
                }
        Closeout_Request__Share closeoutShare = new Closeout_Request__Share();
            // Set the ID of record being shared
        closeoutShare.ParentId = closeoutRequest.Id;
            // Set the ID of user or group being granted access
                closeoutShare.UserOrGroupId = contactToUserId.get(projectRole.AccountContactJunction__r.Contact_Name__c);
            // Set the access level
        closeoutShare.AccessLevel = 'Read';
         // Set the Apex sharing reason 
        CloseoutShare.RowCause = Schema.Closeout_Request__Share.RowCause.closeoutShare__c;
               
            // Add objects to list for insert
        closeoutShareListToInsert.add(closeoutShare);
            }
            toAddresses.addAll(toAddress);
      
        //Insert sharing records and capture save result
        // The false parameter allows for partial processing if multiple records are passed into the operation

        List<Project__c> projectDetailsList =  [Select Id, Name, Was_Ever_Large__c from  Project__c where Id In: projectIdSet];
    
        Integer IsLargeProject = 0;
        Integer IsSmallProject = 0;
        for(Project__c project : projectDetailsList) {
          
            if(project.Was_Ever_Large__c == true){

                IsLargeProject = IsLargeProject + 1;
               
            } else {
                IsSmallProject = IsSmallProject + 1;
               
            }
        }

        String PACloseoutRequestMailForFEDLarge  = KeyValueHelper.getTextValue('PA_Closeout_Request_Mail_For_FED_Large');
        String PACloseoutRequestMailForFEDSmall	  = KeyValueHelper.getTextValue('PA_Closeout_Request_Mail_For_FED_Small');
        String PACloseoutRequestMailForCDAA  = KeyValueHelper.getTextValue('PA_Closeout_Request_Mail_For_CDAA');
      
        List<Messaging.SingleEmailMessage> mailsFederalLarge = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> mailsFederaSmall = new List<Messaging.SingleEmailMessage>(); 
        List<Messaging.SingleEmailMessage> mailCDAA = new List<Messaging.SingleEmailMessage>(); 

        List<Closeout_Request__c> closeoutReqList = [SELECT Id, Name, Subrecipient_Names__c, Declaration_Number__c, FIPS__c, CalOES_ID__c FROM Closeout_Request__c WHERE Id=:closeoutRequestInstance.id];
       
        if(selectedProgramType == PA_CONSTANTS.PA_PROGRAM_FEDERAL && IsLargeProject > 0  && toAddresses.size() > 0) {
            mailsFederalLarge =  EmailHelper.sendEmail(new List<SObject>{closeoutReqList[0]}, toAddresses, null, PACloseoutRequestMailForFEDLarge, 'PA_From_Email_Addresses');
            Messaging.sendEmail(mailsFederalLarge);
        }
        if(selectedProgramType == PA_CONSTANTS.PA_PROGRAM_FEDERAL &&  IsSmallProject > 0 && toAddresses.size() > 0) {
            mailsFederaSmall =  EmailHelper.sendEmail(new List<SObject>{closeoutReqList[0]}, toAddresses, null, PACloseoutRequestMailForFEDSmall, 'PA_From_Email_Addresses');
            Messaging.sendEmail(mailsFederaSmall);
        }

        if(selectedProgramType == PA_CONSTANTS.PA_PROGRAM_CDAA && toAddresses.size() > 0) {
            mailCDAA =  EmailHelper.sendEmail(new List<SObject>{closeoutReqList[0]}, toAddresses, null, PACloseoutRequestMailForCDAA, 'PA_From_Email_Addresses');
            Messaging.sendEmail(mailCDAA);
        }

        PA_SystemContextHelper.insertCloseoutShareRecords(closeoutShareListToInsert);

        //if checklist is not empty
        if(String.isNotEmpty(closeoutCheckList)) {
            List<Closeout_Checklist__c> checkOutCheckList = (List<Closeout_Checklist__c>) JSON.deserialize (closeoutCheckList, List<Closeout_Checklist__c>.Class);
            for(Closeout_Checklist__c checklist : checkOutCheckList){
                checklist.Project_Closeout__c = projectWithProjectClseoutMap.get(checklist.Project__c);
                checklist.Project__c = null;
            }
            upsert checkOutCheckList;
        }




        //update Project__c
        PA_SystemContextHelper.upsertProject(projectList);
        TriggerHelper.skipTrigger = false;

        //Project_Closeout__Share
      
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<ContentDocument> contentDocumentList = new List<ContentDocument>();
        Integer counter = 0;
        for (String file : files) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = file;
                cdl.LinkedEntityId = closeoutRequest.Id;
                cdl.ShareType = 'I';
                contentDocumentLinks.add(cdl);

                String fileName = fileNames.get(counter);
                if(SignedP4DocumentAvailable == 'yes'){
                    fileName = 'Signed ' + fileName;
                }
                else if(SignedP4DocumentAvailable == 'no'){
                    fileName = 'Unsigned ' + fileName;
                }

                system.debug('#fileName After Rename :'+fileName);
                ContentDocument contentDocument = new ContentDocument(Id = file, Title = fileName);
                contentDocumentList.add(contentDocument);
                counter++;
        }

        PA_SystemContextHelper.upsertContentDocLinks(contentDocumentLinks);
        PA_SystemContextHelper.upsertContentDoc(contentDocumentList);
        return closeoutRequest.Id;
    }

      /*****************************************************************************
    * Method Name  : finalizeClosoeutRequest
    * Description  : This method finalized the closoeut out request through portal user
    * Return       : -
    * Inputs       : String  projectLst, List<String> files, List<String> fileNames, 
                      String subrecipient, String incident,String closeoutCheckList, 
                      String selectedProgramType,  String authorizedAgent, String SignedP4DocumentAvailable, 
                      String closeoutRequestId
    * Author       : Dayal
    * Created On   : 8/11/2021
    * Modification Log: 
    *******************************************************************************/   
    @AuraEnabled
        public static String finalizeClosoeutRequest( String  projectLst, List<String> files, List<String> fileNames ,String closeoutCheckList, String selectedProgramType,  String authorizedAgent, String SignedP4DocumentAvailable, String closeoutRequestId) {
        List<Object> projectData ;                                         
        //add the filter clause of program type 
        if(selectedProgramType == PA_CONSTANTS.PA_PROGRAM_FEDERAL || selectedProgramType == PA_CONSTANTS.PA_PROGRAM_CDAA) {
            if(files.isEmpty() && AppUtils.isLoggedInUserPortal() == true) {
                throw new AuraHandledException('Please upload p4 file');
            }
        }

        // add filter clause project list should not empty
        if(String.isEmpty(projectLst)) {
            throw new AuraHandledException('Please select project');
        } else {            
            projectData = (List<Object>) JSON.deserializeUntyped(projectLst);            
        }

       
        Closeout_Request__c closeoutRequest = new Closeout_Request__c(Id = closeoutRequestId, Status__c = 'Closeout Request Finalized');      
        closeoutRequest.Authorized_Agent__c = authorizedAgent;
        
        //if portal user is loged in
        if(AppUtils.isLoggedInUserPortal() == true){
            closeoutRequest.Requestor__c = UserInfo.getUserId();
        }

        PA_SystemContextHelper.upsertCloseoutRequest(closeoutRequest);

         /*Note: As per new requirement project closeut should not create while creating time of closoeut request 
                    now create the closoeut request time ww need to link project closeout as per selected project
        */
        List<Project__c> projectList = new List<Project__c>();

        Set<Id> projectIdSet = new Set<Id>();
        for(Object projRec : projectData) {
                Map<String,Object> mapfpidata = (Map<String,Object>)projRec;
                
                //update Project object to  Closeout_Request__c
                Project__c project = new Project__c(Id = String.valueof(mapfpidata.get('Id')), Closeout_Request__c = closeoutRequest.Id);
                projectList.add(project);

                //added project Id in set
                projectIdSet.add(String.valueof(mapfpidata.get('Id')));
        }

        //Retrive the all project closeout as per selected project -new logic
        List<Project_Closeout__c> projectCloseOutList = [SELECT Id, Name, Project_Name__r.Id, Project_Name__r.Name, Closeout_Request__c, CreatedById  FROM Project_Closeout__c 
                                                        where Project_Name__r.Id In: projectIdSet];
       // Set<Id> projectClosueoutCreatedIdSet = new Set<Id>();

        for(Project_Closeout__c projectClosOut : projectCloseOutList){

                projectClosOut.Closeout_Request__c  = closeoutRequest.Id;

                    for(Object selectedProject : projectData) {
                            Map<String,Object> mapfpidata = (Map<String,Object>)selectedProject;
                            
                            if(projectClosOut.Project_Name__r.Id == String.valueof(mapfpidata.get('Id')) && String.valueof(mapfpidata.get('Total_Amount_Claimed__c')) !=null && String.valueof(mapfpidata.get('Total_Amount_Claimed__c')) != '') {

                                projectClosOut.Total_Amount_Claimed__c = decimal.valueOf(String.valueof(mapfpidata.get('Total_Amount_Claimed__c')));
                            }   
                    }                       
               // projectClosueoutCreatedIdSet.add(projectClosOut.CreatedById);
        }

        PA_SystemContextHelper.upsertProjectCloseouts(projectCloseOutList);
        Map<String,String> projectWithProjectClseoutMap = new  Map<String,String>();
        for(Project_Closeout__c closeout : projectCloseOutList){
            projectWithProjectClseoutMap.put(closeout.Project_Name__c,closeout.Id);

        }
      
        //if checklist is not empty
        if(String.isNotEmpty(closeoutCheckList)) {
            List<Closeout_Checklist__c> checkOutCheckList = (List<Closeout_Checklist__c>) JSON.deserialize (closeoutCheckList, List<Closeout_Checklist__c>.Class);
            upsert checkOutCheckList;
        }
        if(String.isNotEmpty(closeoutCheckList)) {
            List<Closeout_Checklist__c> checkOutCheckList = (List<Closeout_Checklist__c>) JSON.deserialize (closeoutCheckList, List<Closeout_Checklist__c>.Class);
            for(Closeout_Checklist__c checklist : checkOutCheckList){
                checklist.Project_Closeout__c = projectWithProjectClseoutMap.get(checklist.Project__c);
                checklist.Project__c = null;
            }
            upsert checkOutCheckList;
        }

        //update Project__c
        PA_SystemContextHelper.upsertProject(projectList);
        TriggerHelper.skipTrigger = false;



        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<ContentDocument> contentDocumentList = new List<ContentDocument>();
        Integer counter = 0;
        for (String file : files) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = file;
            cdl.LinkedEntityId = closeoutRequest.Id;
            cdl.ShareType = 'I';
            contentDocumentLinks.add(cdl);

                String fileName = fileNames.get(counter);
                if(SignedP4DocumentAvailable == 'yes'){
                    fileName = 'Signed ' + fileName;
        }
                else if(SignedP4DocumentAvailable == 'no'){
                    fileName = 'Unsigned ' + fileName;
                }

                system.debug('#fileName After Rename :'+fileName);
                ContentDocument contentDocument = new ContentDocument(Id = file, Title = fileName);
                contentDocumentList.add(contentDocument);
                counter++;
        }

        PA_SystemContextHelper.upsertContentDocLinks(contentDocumentLinks);
        PA_SystemContextHelper.upsertContentDoc(contentDocumentList);
        return closeoutRequest.Id;
    }

    /*****************************************************************************
    * Method Name : getUserSubrecipientDetails
    * Description  : This method return the account name as per login user
    * Return       : details of loged in user
    * Inputs       : 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  

    @AuraEnabled(cacheable=true)
    public static List<sObject> getUserSubrecipientDetails(){
        list<sObject> userData =[SELECT Id,contact.account.Name,Profile.Name from user where Id = :UserInfo.getUserId()];
        return userData;
    }

    /*****************************************************************************
    * Method Name : getReviewMetadata
    * Description  : This method return the metadata records
    * Return       : metaData Record
    * Inputs       : 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static List<PA_Project_Closeout_Review_Checklist__mdt> getReviewMetadata(String selectedProgramType){
        String type;
        // add filter  clause of program type
        if(selectedProgramType == PA_CONSTANTS.PA_PROGRAM_CDAA) {
            type = 'CDAA';
        } else if(selectedProgramType ==  PA_CONSTANTS.PA_PROGRAM_FEDERAL) {
            type = 'Federal';
        }      

        List<PA_Project_Closeout_Review_Checklist__mdt>  reviewList = [SELECT Id, DeveloperName, Helptext_Document_Name1__c, Helptext_Document_Name2__c, Helptext_Document_URL1__c,
                Helptext_Document_URL2__c, Static_Text__c, Sequence__c, Question__c, Render_yes__c, Render_No__c, Render_NA__c, Show_Only_For_Yes_Value__c, Helptext__c, Shown_NA_Comments__c,
                Type__c, Show_Yes_Comments__c,Show_No_Comments__c from PA_Project_Closeout_Review_Checklist__mdt Where Type__c =: type ORDER BY Sequence__c];
        return reviewList;
    }

    /*****************************************************************************
    * Method Name  : getCloseoutRequestDetailsOnCommunity
    * Description  : This project list and incident Details
    * Return       :map
    * Inputs       : closeoutRequestId
    * Author       : Dayal
    * Created On   : 02/11/2021
    * Modification Log: 
    *******************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static Map<String, List<SObject>> getCloseoutRequestDetailsOnCommunity(String closeoutRequestId){
        Map < String, List<SObject>> mapData = new Map < String, List<SObject> >();
        
        list<Closeout_Request__c> closeoutRequest = [Select Id, Incident__r.Name, Signed_P_4_Document_Available__c, Program_Name__c, Authorized_Agent__c from Closeout_Request__c where Id =:closeoutRequestId];

        mapData.put('IncidentName',closeoutRequest);
      

        list<Project__c> projectList = [Select Id, Name, Project_Number__c, Declaration_Number__c,
                                        Was_Ever_Large__c, Total_Project_Award__c, Percent_Complete_To_Date__c
                                        from Project__c where Closeout_Request__c =:closeoutRequestId];

        mapData.put('projectList',projectList);   

        //program detai
        
        
                            
        return mapData;
    }

     /*****************************************************************************
    * Method Name  : getCloseoutRequestStatus
    * Description  : this method return the current status of 
    * Return       :  String in the form of status
    * Inputs       : closeoutRequestId
    * Author       : Dayal
    * Created On   : 09/11/2021
    * Modification Log: 
    *******************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static String getCloseoutRequestStatus(String closeoutRequestId){
      
        Closeout_Request__c closeoutRequest = [Select Id, Name, Status__c from Closeout_Request__c where Id =:closeoutRequestId];              
        return closeoutRequest.Status__c;
    }


     /*****************************************************************************
    * Method Name  : getCloseoutCheckList
    * Description  : this method returun the closeout check list of releted proect
    * Return       :  Return the closoeut checklist 
    * Inputs       : projectClosoeutId
    * Author       : Dayal
    * Created On   : 09/12/2021
    * Modification Log: 
    *******************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static List <Closeout_Checklist__c> getCloseoutCheckList(String projectClosoeutId){
       
       List <Closeout_Checklist__c> closeoutCheckList = [select Id, Name, Checklist__c, Comment__c, Response__c from Closeout_Checklist__c where Project_Closeout__r.Id =:projectClosoeutId];              
       return closeoutCheckList;
    }
}