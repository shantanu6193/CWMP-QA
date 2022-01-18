/***********************************************************************************************************************************
* Class Name   : HH_CustomRelatedListAccountRolesCtrl
* Description  : Get related Account Role Records related to Application/Project.
* Author       : Shantanu
* Created On   : 05/01/2022
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu              05/01/2022      Initial Implementation
**************************************************************************************************************************************/
public with sharing class HH_CustomRelatedListAccountRolesCtrl {
    

   /***********************************************
   * Method Name : getCWMPAccountRoles
   * Author : Shantanu
   * Inputs : String recordID
   * Description: This method will fetch AccountRoles based on recordId Object Name
   *********************************************/
    @AuraEnabled
    public static Map<String,Object> getCWMPAccountRoles( String recordId) {
        Map<String,Object> result = new Map<String,Object>();
        String objectName = ApexUtils.getObjectNameByRecordId(recordId);
        String query = 'SELECT Id,Account__c, Account__r.Name, Account__r.Entity_Type__c, Account__r.Entity_Id__c, Account__r.Email_Address__c, Point_of_Contact__c, Status__c FROM Account_Role__c WHERE Account__r.Entity_Type__c = \'Contractor\'';
        if(objectName.equalsIgnoreCase('HH_Application__c')) {
            query += ' AND CWMP_Application__c = \''+recordId+'\'';
        } else if (objectName.equalsIgnoreCase('CWMP_Project__c')) {
            query += ' AND CWMP_Project__c = \''+recordId+'\'';
        } 
        System.debug('Query: '+query);
        List<Account_Role__c> accountRoles = Database.query(query);
        result.put('accountRoles',accountRoles);
        return result;
    }
}