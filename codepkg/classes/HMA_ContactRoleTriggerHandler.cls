public without sharing class HMA_ContactRoleTriggerHandler extends TriggerHandler implements TriggerInterface {
    static Map<String, Contact> contactDetailsMap = new Map<String, Contact>();
    static  Set<Id> contactIds = new Set<Id>();
    static  Set<Id> accountIds = new Set<Id>();
    public HMA_ContactRoleTriggerHandler() {

    }

    public override void beforeInsert() {
        processContactRoles();
        if(contactIds.size() >0){
            prepareContactDetails();
            processAccountContactJunctionRecord((List<Contact_Role__c>) Trigger.new);
        }
    }

    public override void afterInsert() {
        processContactRoles((List<Contact_Role__c>) Trigger.new);
    }

    private static void processContactRoles(){
        for(Contact_Role__c contactRole: (List<Contact_Role__c>)Trigger.new){
            if(isValidaContactRoleForAcContactRelationship(contactRole.Role__c)){
                contactIds.add(contactRole.Contact__c);
            }
        }
    }

    private static void prepareContactDetails(){
        Contact[] contacts = [SELECT Id, AccountId FROM Contact WHERE Id IN:contactIds AND AccountId != null];
        for(Contact contact: contacts){
            if(contactDetailsMap.get(contact.Id) == null){
                contactDetailsMap.put(contact.Id, contact);
            }else{
                contactDetailsMap.put(contact.Id, contact);
            }
            /*Prepare account set*/
            if(contact.AccountId != null){
                accountIds.add(contact.AccountId);
            }
        }
    }

    /************************************
    * Author : Rakesh
    * Date : 10th August 2021
    * Method : processContactRoles
    * Parameters : List of Contact_Role__c
    * Description : Check User and create community ApplicationUser send invitation to fema users only
    TODO: We are only processing for FEMA Users
    *************************************/

    private static void processContactRoles(List<Contact_Role__c> contactRoleRecords) {
        Set<Id> appIds = new Set<Id>();
        Set<Id> contactRoleIds = new Set<Id>();
        for(Contact_Role__c contactRole : contactRoleRecords) {
            appIds.add(contactRole.Application__c);
            if(isValidaContactRoleForAcContactRelationship(contactRole.Role__c)) {
                    contactRoleIds.add(contactRole.Id);
            }
            
        }
        if(contactRoleIds.size() == 0) return;
        Map<Id, Application__c> appIdToApplicationMap = new Map<Id, Application__c>([SELECT Id, Status_Reason__c, Status__c, (SELECT Id, Contact__c, Contact__r.Email, Role__c FROM Contact_Roles__r
                                                                                        WHERE Id IN :contactRoleIds)
                                                                                        FROM Application__c
                                                                                        WHERE Id IN :appIds]);
                                                                                               
        if(appIdToApplicationMap.size() > 0) {
	        HMA_ApplicationHelper.checkUserAndCreateCommunityApplicationUser(appIdToApplicationMap.keySet());
	        HMA_ApplicationHelper.sendInviteToContactRoleUsers(appIdToApplicationMap);
         }
    }
    //TODO : Do we need to consider update contact role scenarios

    private static void processAccountContactJunctionRecord(List<Contact_Role__c> contactRoleRecords) {
        //List<Id> contactIds = new List<Id>();
                //collect contact Ids from List of ContactRole
        /*for(Contact_Role__c crole : contactRoleRecords) {
            if(crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_EHP_ANALYST) ||
                    crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_REVIEW) ||
                    crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_PROGRAMMATIC_ANALYST) ||
                    crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR) ||
                    crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) ||
                    crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER) ||
                    crole.Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR)
                    ){
                        contactIds.add(crole.Contact__c);
                }

        }*/
        //String femaAccountName = KeyValueHelper.getTextValue('FEMA_Account_Name');
        //List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name = :femaAccountName];
        //&& accountList.size() > 0
        if(contactIds.size() > 0) {
            Map<Id, AccountContactRole__c> contactIdAccountContactRoleMap = new Map<Id, AccountContactRole__c>();
                List<AccountContactRole__c> accountContactRoles = [SELECT Id, Name, Status__c, Contact_Name__c FROM AccountContactRole__c 
                                                                    WHERE Account_Name__c IN :accountIds
                                                                        AND Contact_Name__c IN :contactDetailsMap.values()];
                if(accountContactRoles.size() > 0) {
                    for(AccountContactRole__c acr : accountContactRoles) {
                        contactIdAccountContactRoleMap.put(acr.Contact_Name__c, acr);
                    }
                    for(Contact_Role__c conRole : contactRoleRecords) {
                    if(isValidaContactRoleForAcContactRelationship(conRole.Role__c)){
                        if(contactIdAccountContactRoleMap.containsKey(conRole.Contact__c)) {
                            conRole.AccountContactJunction__c = contactIdAccountContactRoleMap.get(conRole.Contact__c)?.Id;
                        } else {
                            //This is the case where some of the contact role do not have accountContactRole records then we should create
                            // accountContactRole records.
                            AccountContactRole__c acr = createAccountContactRoleRecord(contactDetailsMap.get(conRole.Contact__c)?.AccountId, conRole.Contact__c, conRole);
                            if(acr != null) contactIdAccountContactRoleMap.put(conRole.Contact__c, acr);
                        }
                    }
                }
                    upsert contactIdAccountContactRoleMap.values();
                    //This for loop for newly created accountContactRole records
                    for(Contact_Role__c conRole : contactRoleRecords) {
                    if(isValidaContactRoleForAcContactRelationship(conRole.Role__c)) {
                        conRole.accountContactJunction__c = contactIdAccountContactRoleMap.get(conRole.Contact__c)?.Id;
                    }
                }
                } else {
                    for(Contact_Role__c conRole : contactRoleRecords) {
                    if(isValidaContactRoleForAcContactRelationship(conRole.Role__c)) {
                        AccountContactRole__c acr = createAccountContactRoleRecord(contactDetailsMap.get(conRole.Contact__c)?.AccountId, conRole.Contact__c, conRole);
                        if(acr != null) contactIdAccountContactRoleMap.put(conRole.Contact__c, acr);
                    }
                }
                    insert contactIdAccountContactRoleMap.values();
                    for(Contact_Role__c conRole : contactRoleRecords) {
                    if(isValidaContactRoleForAcContactRelationship(conRole.Role__c)) {
                        conRole.accountContactJunction__c = contactIdAccountContactRoleMap.get(conRole.Contact__c)?.Id;
                    }
                }
        }
    }
    }

    private static AccountContactRole__c createAccountContactRoleRecord(Id accountId, Id contactId, Contact_Role__c conRole) {
        if(accountId == null || contactId == null) return null;
        if(conRole.Application__c == null) return null;
        AccountContactRole__c acr = new AccountContactRole__c();
        acr.Account_Name__c = accountId;
        acr.Contact_Name__c = contactId;
        acr.Status__c = 'Active';
        return acr;
    }

    private static Boolean isValidaContactRoleForAcContactRelationship(String role){
        List<String> roles = role?.split(';');
        if(roles != null){
            if(roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_EHP_ANALYST) != -1 ||
                    roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_PROGRAMMATIC_ANALYST) != -1 ||
                    roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_REVIEW) != -1 ||
                    roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR) != -1 ||
                    roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) != -1 ||
                    roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER) != -1 ||
                    roles.indexOf(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR) != -1
                    ){
                return true;
            }
        }
        return false;
    }
}