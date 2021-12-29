@isTest(SeeAllData=false)
public class AccountMerge_Batch_Test {
    @isTest public static void testAccount(){
        List<Account> accList = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        accList.add(acc1);
        Account acc2 = new Account();
        acc2.Name = 'Test1';
        accList.add(acc2);
        insert accList;
        Test.startTest();
        Account_Merge_Batch_Setting__c accMerge = new Account_Merge_Batch_Setting__c();
        accMerge.Name = 'Account Merge';
        insert accMerge;
        AccountMerge_Batch job = NEW AccountMerge_Batch();
        Database.executeBatch( job );
        AccountMerge_Batch job1 = NEW AccountMerge_Batch('Account Merge');
        Database.executeBatch( job1);
        Test.stopTest();
    }
}