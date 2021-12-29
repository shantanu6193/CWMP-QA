/**
 * Created by hp on 06-09-2021.
 */
@isTest
public with sharing class PA_ProjectSharingBatchTest {

    @testSetup static void setup() {
        Account acc = PA_TestHelper.getAccountSubrecipent(true);

        Contact con =  PA_TestHelper.getContact(true,acc);

        AccountContactRole__c accCon = new AccountContactRole__c();
        accCon.Account_Name__c = acc.id;
        accCon.Contact_Name__c = con.id;
        insert accCon;

        List<Project_Role__c> roleList = new List<Project_Role__c>();
        roleList.add(new Project_Role__c(AccountContactJunction__c = accCon.Id,Sharing_Batch_Executed__c = false));
        insert roleList;
    }

    static testmethod void testProjectRoleSharingBatch() {
        Database.executebatch(new PA_ProjectSharingBatch(), 1);
    }

}