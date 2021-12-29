@isTest(seeAllData=false)
public without sharing class HMA_TestHelper {

    /**Here userRoleName may be HMA_Analyst OR HMA_Manager */
    public static User getInternalUser(boolean create, String userRoleName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CalOES Internal User' limit 1];
        UserRole uRole = [Select Id, DeveloperName, Name From UserRole Where DeveloperName =: userRoleName Limit 1];
        User u = new User(Alias = 'standt', 
                            Email='standarduser@govbd.dev', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            UserRoleId = uRole.Id,
                            TimeZoneSidKey='America/New_York', 
                            UserName='standarduser'+Math.random()+'@govbd.dev');
        if(create)
            insert u;
        return u;
    }
    public static User getPortalUser(boolean create) {
            
        //**** First give call to getPortalContact() methos and provide ContactId to PortalUser

        Profile profile = [select Id,name from Profile where Name like 'PHOS Customer Community Plus Login User' limit 1];
        UserRole userRole = [Select Id, Name from UserRole where Name like 'Region 1 Customer User' limit 1];
        system.debug('profile-----------'+profile);
        Contact con = HMA_TestHelper.getPortalContact(create);
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User portalUser = new User(
            Username = uniqueName+'@acme.com',
            //ContactId = contact.Id,
            ProfileId = profile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id
            //IsActive = true,
            //UserRoleId = userRole.Id
        );
        
        if(create)
            insert portalUser;
        return portalUser;
    }
    public static Account getParentAccount(boolean create){
        Account newAccount = new Account();
        newAccount.Name = 'NewTest13'+system.now()+Math.random();
        newAccount.BillingStreet='rewxe';
        newAccount.BillingCountry='USA-11';
        newAccount.BillingState='NSdY';
        newAccount.Queue_Name__c = 'COVID_Contributions_Group_Initial';
        newAccount.BillingPostalCode='3425345';
        newAccount.Phone='544534334';
        newAccount.Entity_Type__c = 'Region';
        newAccount.Entity_Id__c = '234543';
        newAccount.Account_Name__c = 'Test';
        if(create)
            insert newAccount;
        return newAccount;
    }
    public static Account getPortalAccount(boolean create){
        Account newParentAccount = HMA_TestHelper.getParentAccount(create);
        Account newAccount = new Account();
        newAccount.Name = 'NewTest'+system.now()+Math.random();
        newAccount.ParentId = newParentAccount.Id;
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c = 'County';
        newAccount.Entity_Id__c = '23454453';
        if(create)
            insert newAccount;
        return newAccount;
    }
    public static Contact getPortalContact(boolean create) {
        Account acc = HMA_TestHelper.getPortalAccount(create);
        Contact portalContact = new Contact();
        portalContact.Firstname='FirstNameportal';
        portalContact.Lastname='LastNameportal';
        portalContact.Email='email@portal.com';
        portalContact.Phone ='923-875-1274';
        portalContact.AccountId = acc.Id;
        System.debug('Account---'+portalContact);
        if(create)
            insert portalContact;
        return portalContact;
    }
    public static Account getAccount(boolean create){
        Account parentAccount = new Account(Name = 'Region 1', Queue_Name__c = 'RDMHS_Region_1');
            insert parentAccount;
        Account account = new Account(Name = '01 - Alameda',AccountSource = 'web',AnnualRevenue = 1800000,Description = 'A bank account is a financial account maintained by a bank or other financial institution in which the financial transactions between the bank and a customer are recorded',
                                NumberOfEmployees = 15,Industry = 'banking',Phone = '8569321475',Rating = 'Warm',Entity_Type__c = 'State Agency',	Federal_Tax_ID__c = '101010',ParentId = parentAccount.Id);
        if(create)
        insert account;
        return account;
    }
    public static Contact getContact(boolean create){
        Account account = HMA_TestHelper.getAccount(create);
        Contact contact = new Contact(Firstname='FirstName', Lastname='LastName',Email='emailtestclass@gmail.com', Phone = '9652314586',	AccountId = account.Id);
        if(create)
        insert contact;
        return contact;
    }
    public static Incident__c getIncident(boolean create){
        Incident__c incident = new Incident__c(Name = 'HP-4908',isDefault__c = true);
        if(create)
        insert incident;
        return incident;
    }
    public static Program__c getProgram(boolean create){
        Program__c program = new Program__c(Name = 'BRIC');   
        if(create)
        insert program;
        return program;
    }
    public static Contact_Role__c getContactRole(boolean create){
        Pre_Application__c preApplication = HMA_TestHelper.getPreApplication(create);
        //Contact contact = HMA_TestHelper.getContact(create);
        Contact_role__c contactRole = new Contact_role__c(Pre_Application__c = preApplication.Id, Contact__c =  preApplication.Requestor__c, Role__c = 'Responsible Representative',
                                                            Type__c = 	'Primary');
        if(create)
        insert contactRole;
        return contactRole;
    }

    public static User getUser(boolean create){
        Contact contact = HMA_TestHelper.getContact(create);
        Profile profile = [Select Id From Profile Where Name='Standard User'];
        User user = new User(	Username = 'usernam11e@gmail.com',LastName = 'nik',Email = 'test1211345@test.com',	Alias = 'standt',	TimeZoneSidKey = 'America/New_York',	LocaleSidKey = 'en_US',EmailEncodingKey	= 'UTF-8',ProfileId = profile.Id,LanguageLocaleKey = 'en_US',SenderEmail = 'standarduser@govbd.dev',	SenderName = 'user',
                                IsActive = true,FirstName = 'first');
        if(create)
        insert user;
        return user;
    }
    
    public static User_Registration__c getUserRegistration(boolean create){
        Account account = HMA_TestHelper.getAccount(create);
        User user = HMA_TestHelper.getUser(create);
        Community_Application__c communityApplication = HMA_TestHelper.getCommunityApplication(true);
            User_Registration__c userRegistration = new User_Registration__c(First_Name__c = 'Test',Last_Name__c = 'User',Phone__c = '123456789',Email__c = 'test@111test.com',County__c = '01 - Alameda',Entity_Type__c= 'State Agency',
                                                                            User__c = user.Id,Federal_Tax_ID__c = '101010',Non_Governmental_Entity__c = 'test12345',Status__c = 'Pending for Approval',	State_Agency__c = account.Id,	Community_Application__c = communityApplication.Id);
            if(create)
            insert userRegistration;
            return userRegistration;
    }

    public static Pre_Application__c getPreApplication(boolean create){
        //Incident__c incident = HMA_TestHelper.getIncident(create);
        Contact contact = HMA_TestHelper.getContact(create);
        //User user = HMA_TestHelper.getUser(create);
        Pre_Application__c PreApplication = new Pre_Application__c( Applicant_Type__c = 'City',Status__c = 'Pending Review',City__c = 'NewYork',	County__c = 'Alameda',
                                                                    Hazard__c = 'Earthquake',	Requestor__c = contact.Id,Project_Number__c = 'P001', Is_this_project_phased__c = 'Yes',
                                                                    First_Name_of_Person_Completing_NOI__c= 'David',Last_Name_of_Person_Completing_NOI__c = 'richarson',
                                                                    Activity_TitleName__c = 'test123',Federal_Request_Share__c = 12534,Applicant_Match__c= 985412);

        Id hmaRecordTypeId = Schema.SObjectType.Pre_Application__c.getRecordTypeInfosByDeveloperName().get('HMGP').getRecordTypeId();
        PreApplication.RecordTypeId = hmaRecordTypeId;
        if(create)
        insert PreApplication;
        return PreApplication;
    }

    public static Community_Application__c getCommunityApplication(boolean create){
        //User user = HMA_TestHelper.getUser(create);
        Community_Application__c communityApplication = new Community_Application__c(Name = 'HMA',Description__c = 'Hazard Mitigation-NOI Requests Portal',isActive__c = true,User_Approval_Class__c = 'test123');
        if(create)
        insert communityApplication;
        return communityApplication;
    }
    public static Community_Application_to_User__c getCommunityApplicationToUser(boolean create){
        Community_Application__c communityApplication = HMA_TestHelper.getCommunityApplication(create);
        User user = HMA_TestHelper.getUser(create);
        Community_Application_to_User__c communityApplicationUser = new Community_Application_to_User__c(isActive__c = true,Community_Application__c = communityApplication.Id,User__c = user.Id);
        if(create)
        insert communityApplicationUser;
        return communityApplicationUser;
    }
    public static Application__c getApplication(boolean create, String subApplicationType, String projectType, String isThisProjectPhased) {
        Application__c newApplication;
        if(String.isNotBlank(subApplicationType) && String.isNotBlank(projectType)) {
            newApplication = HMA_TestHelper.getSpecificApplication(create, subApplicationType, projectType, isThisProjectPhased);
        } else {
            newApplication = HMA_TestHelper.getSpecificApplication(create, 'Project', 'Acquisition Demo-Relocation', 'Yes');
        }
        return newApplication;
    }
    public static Application__c getSpecificApplication(boolean create, String subApplicationType, String projectType, String isThisProjectPhased) {
        Account newAcc = HMA_TestHelper.getAccount(create);
        Incident__c incident = HMA_TestHelper.getIncident(create);
        Pre_Application__c newPreApplication = HMA_TestHelper.getPreApplication(create);
        Program__c newProgram = HMA_TestHelper.getProgram(create);
        Community_Application__c commApplication = HMA_TestHelper.getCommunityApplication(true);
        Id hmaRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('HMGP').getRecordTypeId();
        Application__c newApplication = new Application__c();
        newApplication.RecordTypeId = hmaRecordTypeId;
        newApplication.Status__c = 'Draft';
        newApplication.Status_Reason__c = 'In Progress';
        newApplication.Application_Type__c = subApplicationType;
        newApplication.Is_this_project_phased__c = isThisProjectPhased;
        newApplication.Project_Type__c = projectType;
        newApplication.Subapplicant_Entity__c = newAcc.Id; //Account      
        newApplication.Pre_Application__c = newPreApplication.Id; // Pre-Application
        newApplication.Disaster__c = incident.Id;  //Incident__c
        newApplication.Program__c = newProgram.Id;  //Program      
        newApplication.Sub_Applicant_Type__c = 'County';
        newApplication.Is_this_an_eligible_Activity__c = 'Yes';
        newApplication.Is_this_an_eligible_Subapplicant__c = 'Yes';
        newApplication.Match_Letter__c = 'Yes';
        newApplication.Maintenance_Letter__c = 'Yes';
        newApplication.Subapplication_Complete__c = 'Yes';
        newApplication.Verified_Benefit_Cost_Ratio_After_Review__c = 2;
        newApplication.Is_BCR_verified_at_1_0_or_greater__c = 'Yes';
        if(create) {
            insert newApplication;
        }
        return newApplication;
    }
    public static Application_Extension__c getApplicationExension(boolean create, Id applicationId) {
        Application_Extension__c appExtension = new Application_Extension__c();
        appExtension.Application__c = applicationId;
        appExtension.Pre_Event_or_Current_Market_Value__c = 'Current Market Values';
        if(create) {
            insert appExtension;
        }
        return appExtension;
    }
    public static Project_Site__c getProjectSite(boolean create, Id applicationId, Id applicationExId) {
        Project_Site__c newProjectSite = new Project_Site__c();
        newProjectSite.Application__c = applicationId;
        newProjectSite.Application_Extension__c = applicationExId;
        if(create) {
            insert newProjectSite;
        }
        return newProjectSite;
    }
    public static Work_Schedule__c getWorkSchedule(boolean create, Id applicationId) {
        Work_Schedule__c newWS = new Work_Schedule__c();
        newWS.Application__c = applicationId;
        if(create) {
            insert newWS;
        }
        return newWS;
    }
    public static Work_Schedule_Line_Item__c getWorkScheduleLineItem(boolean create, Id workScheduleId) {
        Work_Schedule_Line_Item__c newWSLI = new Work_Schedule_Line_Item__c();
        newWSLI.Work_Schedule__c = workScheduleId;
        newWSLI.Phase__c = 'Phase 1';
        if(create) {
            insert newWSLI;
        }
        return newWSLI;
    }

    public static Project_Cost__c getProjectCostwithProjectSiteRecordType(boolean create, Id projectSiteId) {
        Id projectRecordTypeId = Schema.SObjectType.Project_Cost__c.getRecordTypeInfosByDeveloperName()
                                    .get(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE).getRecordTypeId();

        Project_Cost__c newProjectCost = new Project_Cost__c();
        newProjectCost.Project_Site__c = projectSiteId;
        newProjectCost.RecordTypeId = projectRecordTypeId;
        if(create) {
            insert newProjectCost;
        }
        return newProjectCost;
    }

    public static Project_Budget__c getProjectBudget(boolean create, Id applicationId, Id applicationExtensionId) {
        Project_Budget__c newProjectBudget = new Project_Budget__c();
        newProjectBudget.Application__c = applicationId;
        newProjectBudget.Type__c = 'Project';
        newProjectBudget.Application_Extension__c = applicationExtensionId;
        if(create) {
            insert newProjectBudget;
        }
        return newProjectBudget;
    }
    public static Project_Cost__c getProjectCost(boolean create, Id projectBudgetId) {
        Id projectRecordTypeId = Schema.SObjectType.Project_Cost__c.getRecordTypeInfosByDeveloperName()
                                    .get(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT).getRecordTypeId();

        Project_Cost__c newProjectCost = new Project_Cost__c();
        newProjectCost.Project_Budget__c = projectBudgetId;
        newProjectCost.RecordTypeId = projectRecordTypeId;
        if(create) {
            insert newProjectCost;
        }
        return newProjectCost;
    }
    public static Project_Cost_Line_Item__c getProjectCostLineItem(boolean create, Id projectCostId) {
        Project_Cost_Line_Item__c newPCLI = new Project_Cost_Line_Item__c();
        newPCLI.Project_Cost__c = projectCostId;
        newPCLI.Phase__c = 'Phase 1';
        newPCLI.Cost_Type__c = 'Survey';
        newPCLI.Cost_Estimate_Total__c = 10000;
        if(create) {
            insert newPCLI;
        }
        System.debug('project cost line item--'+newPCLI);
        return newPCLI;
    }
    public static Program_Document__c getProgramDocument(boolean create, string filterClause, String parentObject) {
        Program_Document__c newProDocument = new Program_Document__c();
        newProDocument.Filter_Clause__c = filterClause;
        newProDocument.Document_Name__c = 'TestDoc';
        newProDocument.Parent_Object__c = parentObject;
        newProDocument.Document_Format__c = '.zip';
        newProDocument.Description__c = 'Test Description';
        if(create){
            insert newProDocument;
        }
        return newProDocument;
    }
    public static Pre_Application__c getPreApplicationQueryData(Id preAppId) {
            Pre_Application__c record = [SELECT Activity_Location_Latitude__c,
                                        Activity_Location_Longitude__c,
                                        Current_Stage__c,
                                        Mitigation_Dependent_On__c,
                                        Activity_in_Mitigation_Plan__c,
                                        Activity_Location__Latitude__s,
                                        Activity_Location__Longitude__s,
                                        Activity_TitleName__c,
                                        Applicant_Match__c,
                                        Applicant_Name_Entity__c,
                                        Applicant_Type__c,
                                        Application_Type__c,
                                        Brief_Summary__c,
                                        City__c,
                                        County__c,
                                        CreatedById,
                                        CreatedDate,
                                        Describe_the_problem_to_be_mitigated__c,
                                        Describe_the_scope_of_work__c,
                                        Design_documents_for_this_project__c,
                                        Disaster__c,
                                        DUNS__c,
                                        EIN_For_Private_Non_Profits__c,
                                        Federal_entity_have_funding_authority__c,
                                        Federal_Request_Share__c,
                                        FIPS__c,
                                        First_Name_of_Person_Completing_NOI__c,
                                        Funding_Opportunity__c,
                                        Hazard__c,
                                        Id,
                                        If_yes_identify_the_program__c,
                                        If_yes_planning_studies__c,
                                        If_yes_project_location__c,
                                        If_yes_proposed_project__c,
                                        Independent_mitigation_activity__c,
                                        IsDeleted,
                                        LastModifiedById,
                                        LastModifiedDate,
                                        Last_Name_of_Person_Completing_NOI__c,
                                        LHMP_Approval_Date__c,
                                        LHMP_Development_Status__c,
                                        Name,
                                        OwnerId,
                                        Percentage_complete_are_the_designs__c,
                                        Physical_project_work_already_started__c,
                                        Planning_studies_or_feasibility_reports__c,
                                        Program__c,
                                        Project_Duration_in_Months__c,
                                        Project_location_have_the_hazard__c,
                                        Project_Number__c,
                                        Project_related_to_asset__c,
                                        Project_Type__c,
                                        Proposed_project_area_documented__c,
                                        Protection_for_that_asset__c,
                                        RecordTypeId,
                                        RecordType.Name,
                                        Region__c,
                                        Source_of_applicant_match__c,
                                        State__c,
                                        Status_Reason__c,
                                        Status__c,
                                        Street_Address__c,
                                        Subapplicant_for_infrastructure__c,
                                        Subapplication_for_project_submitted__c,
                                        SystemModstamp,
                                        Total_Activity_Cost__c,
                                        Work_started_completed_in_detail__c,
                                        Zip_Code__c,
                                        Program__r.Id,
                                        Program__r.Name,
                                        Percentage_of_Applicant_Match__c,
                                        Percentage_of_Federal_Request_Share__c,
                                        Does_your_entity_have_an_active_LHMP__c,
                                        Entity_Responsible_For_Operation__c,
                                        Future_Hazard_Event_Trigger__c,
                                        Implementation_Plan_For_Mitigation__c,
                                        Protection_From_Future_Natural_Hazards__c,
                                        What_is_the_mitigation_action__c,
                                        Subapplicant_a_small_community__c,
                                        Project_in_conformance_with_latest_codes__c,
                                        Explain_why_project_not_in_conformance__c,
                                        Project_in_a_Special_Flood_Hazard_Area__c,
                                        National_Flood_Insurance_Program_NFIP__c,
                                        Structures_included_in_subapplication__c,
                                        Project_mitigate_Severe_Repetitive_Loss__c,
                                        Project_located_in_NFIP__c,

                                        (Select Id,
                                            Name,
                                            Contact__r.Id,
                                            Contact__r.FirstName,
                                            Contact__r.LastName,
                                            Contact__r.AccountId,
                                            Contact__r.Account.Name,
                                            Contact__r.Account.Entity_Id__c,
                                            Contact__r.Email,
                                            Contact__r.MobilePhone,
                                            Contact__r.Phone,
                                            Role__c,
                                            Type__c from Contact_Roles__r
                                        )
                                        FROM Pre_Application__c where Id =: preAppId];

            return record;
    }
    
    //This method returns contactRole for specifc application, contactId, accountId and role. Pass them as params and get the contact role.
    public static Contact_Role__c getContactRoleForSpecificApplication(boolean create, Application__c application, Id contactId, String role){
        Id accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId]?.AccountId;
        System.debug('accountId---'+accountId);
        AccountContactRole__c accountContactJunction = getAccountContactJunction(true, contactId, accountId);
        Contact_role__c contactRole = new Contact_role__c(Application__c = application.Id, AccountContactJunction__c = accountContactJunction.Id, Contact__c =  contactId, Role__c = role,Type__c = 'Primary');
        if(create)
            insert contactRole;
        return contactRole;
    }

    //This method returns accountContactRole for contact and account ids.
    public static AccountContactRole__c getAccountContactJunction(boolean create, Id contactId, Id accountId) {
        AccountContactRole__c accountContactJunction = new AccountContactRole__c(Contact_Name__c = contactId, Account_Name__c = accountId, Status__c = 'Active', Contact_Role_Global_List__c = 'Employee');
        if(create)
            insert accountContactJunction;
        return accountContactJunction;
    }

    //This method assigns permission set to particular user
    @future
    public static void assignPermissionSet(String userId, String psName) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :psName];
        System.debug('User Id String--'+userId);
        Id uId = Id.valueOf(userId);
        System.debug('User Id--'+uId);
        insert new PermissionSetAssignment(AssigneeId = uId, PermissionSetId = ps.Id);
    }

    public static Scoring_Checklist__c getScoringChecklist(boolean create, String applicationId, String appExtensionId) {
        Scoring_Checklist__c sc = new Scoring_Checklist__c();
        sc.Application__c = applicationId;
        if(String.isNotBlank(appExtensionId)) {
            sc.Application_Extension__c = appExtensionId;
        }
        if(create) {
            insert sc;
        }
        return sc;
    }

    public static User getPortalUserHMA(boolean create) {
            
        //**** First give call to getPortalContact() methos and provide ContactId to PortalUser

        Profile profile = [select Id,name from Profile where Name like 'CalOES Portal User' limit 1];
        // UserRole userRole = [Select Id, Name from UserRole where Name like 'Alameda Customer User' limit 1];
        system.debug('profile-----------'+profile);
        Contact con = HMA_TestHelper.getPortalContact(create);
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User portalUser = new User(
            Username = uniqueName+'@acme.com',
            //ContactId = contact.Id,
            ProfileId = profile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id
            //IsActive = true,
            //UserRoleId = userRole.Id
        );
        
        if(create)
            insert portalUser;
            String userId = String.valueOf(portalUser.Id);
            //assignPermissionSet(userId, 'HMA_Community_User');
        return portalUser;
    }

    public static Request_For_Information__c getRFI(Boolean create, Id appId, Integer days, String RFIType) {
        Request_For_Information__c rfi = new Request_For_Information__c(Application__c = appId, RFI_Deadline__c = Date.TODAY()+days, RFI_TYPE__c = RFIType, Description__c = 'Test');
        Id hmaRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByDeveloperName().get('HMA').getRecordTypeId();
        rfi.RecordTypeId = hmaRecordTypeId;
        if(create) 
            insert rfi;
        return rfi;
    }

    public static void createDocument(Id linkedEntityId) {
        Blob b = Blob.valueOf('Test Data');
        ContentVersion contentVersion_1 = new ContentVersion();
        contentVersion_1.Title = 'Penguins';
        contentVersion_1.PathOnClient = 'Penguins.jpg';
        contentVersion_1.Document_Type__c = 'GANTT Chart';
        contentVersion_1.VersionData = b;
        contentVersion_1.IsMajorVersion = true;   
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title,Document_Type__c, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ShareType = 'V';
        conDocLink.Visibility = 'AllUsers';
        conDocLink.LinkedEntityId = linkedEntityId;
        conDocLink.ContentDocumentId = contentVersion_2.ContentDocumentId;
        insert conDocLink;
    }

    public static Document__c createCustomDocumentRecord(Id appId) {
        Document__c customDoc = new Document__c(Document_Name__c = 'Doc1', Application__c = appId);
        insert customDoc;
        return customDoc;
    }

    //Contact Role for specific pre application
    public static Contact_Role__c getContactRoleForSpecificPreApplication(boolean create, Pre_Application__c preApp, Id contactId, String role){
        Id accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId]?.AccountId;
        System.debug('accountId---'+accountId);
        Contact_role__c contactRole = new Contact_role__c(Pre_Application__c = preApp.Id, Contact__c =  contactId, Role__c = role,Type__c = 'Primary');
        if(create)
            insert contactRole;
        return contactRole;
    }

    public static EmailTemplate getEmailTemplate(Boolean create, String name) {
        EmailTemplate et = new EmailTemplate();
        et.Name = name;
        et.DeveloperName = name;
        et.FolderId = UserInfo.getUserId();
        et.Subject = 'Test Subject';
        et.TemplateType = 'text';

        if(create) {
            insert et;
        }
        return et;
    }

}