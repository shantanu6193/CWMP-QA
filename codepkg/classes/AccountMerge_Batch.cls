/***********************************************************************************************************************************
* Class Name   : AccountMerge_Batch
* Description  : AccountMerge_Batch Class to merge the Accounts  
* Author       : Pankaj
* Created On   : 09/24/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            09/24/2020       Initial Implementation
**************************************************************************************************************************************/

global class AccountMerge_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global Map<Id, Id> mapDuplicateIDToMasterAcc;
    global String csvColumnHeader;
    global String accName;
    public AccountMerge_Batch(String accountName) {
        this.accName = accountName;
        mapDuplicateIDToMasterAcc = new Map<Id, Id>();
    }
    public AccountMerge_Batch() {
        mapDuplicateIDToMasterAcc = new Map<Id, Id>();
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(String.isNotBlank(accName)) {
            return Database.getQueryLocator('Select Id,Name,Type from Account where Entity_Id__c = null AND Entity_Type__c= null AND Name =\'' + accName +'\'' + 'ORDER BY Name');
        } else {
            Account_Merge_Batch_Setting__c mergeBatchSetting = Account_Merge_Batch_Setting__c.getValues('Account Merge');
            if(mergeBatchSetting.Created_From__c != null && mergeBatchSetting.Created_To__c != null) {
                return Database.getQueryLocator('Select Id,Name,Type from Account where Entity_Id__c = null AND Entity_Type__c= null AND DAY_ONLY(CreatedDate) >=' +
                        String.valueOf(mergeBatchSetting.Created_From__c ).removeEnd(' 00:00:00') +
                        ' AND DAY_ONLY(CreatedDate) <='+  String.valueOf(mergeBatchSetting.Created_To__c ).removeEnd(' 00:00:00') + 'ORDER BY Name');
            } else if(mergeBatchSetting.Account_Name__c != null) {
                return Database.getQueryLocator('Select Id,Name,Type from Account where Entity_Id__c = null AND Entity_Type__c= null AND Name =\'' + mergeBatchSetting.Account_Name__c +'\'' + 'ORDER BY Name');
            } else {
                return Database.getQueryLocator('Select Id,Name,Type from Account where Entity_Id__c = null AND Entity_Type__c= null ORDER BY Name');
            }
        }
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Map<String, List<Account>> accountsToMergeList = new Map<String, List<Account>>();
        for (Account account : scope) {
            if(accountsToMergeList.get(account.Name) ==  null) {
                accountsToMergeList.put(account.Name, new List<Account>());
            }
            accountsToMergeList.get(account.Name).add(account);
        }
        for (String name : accountsToMergeList.keySet()) {
            List<Account> accountsToMerge = accountsToMergeList.get(name);
            if (accountsToMerge.size() > 1) {
                Account masterAccount;
                List<Id> duplicateAccounts = new List<Id>();
                List<Id> duplicateAccountsFinal = new List<Id>();
                for (Account account : accountsToMerge) {
                    if (masterAccount == null) {
                        masterAccount = account;
                    } else {
                        duplicateAccounts.add(account.Id);
                        duplicateAccountsFinal.add(account.Id);
                    }
                    if(duplicateAccountsFinal != null && !duplicateAccountsFinal.isEmpty()) {
                        for(ID idRec : duplicateAccountsFinal) {
                            mapDuplicateIDToMasterAcc.put(idRec, masterAccount.Id);
                        }
                    }

                    if(duplicateAccounts.size() == 2){
                        Database.MergeResult[] results = Database.merge(masterAccount, duplicateAccounts, false);
                        duplicateAccounts.clear();
                        System.debug('***results merged** ' + results);
                        for (Database.MergeResult res : results) {
                            if (res.isSuccess()) {
                                System.debug('Master record ID: ' + res.getId());
                                System.assertEquals(masterAccount.Id, res.getId());
                                List<Id> mergedIds = res.getMergedRecordIds();
                                System.debug('IDs of merged records: ' + mergedIds);
                            } else {
                                for (Database.Error err : res.getErrors()) {
                                    System.debug('Error--'+err.getMessage());
                                }
                            }
                        }
                    }
                }
                System.debug('Master Account='+masterAccount);
                Database.MergeResult[] results = Database.merge(masterAccount, duplicateAccounts, false);

                System.debug('***results merged** ' + results);
                for (Database.MergeResult res : results) {
                    if (res.isSuccess()) {
                        System.debug('Master record ID: ' + res.getId());
                        System.assertEquals(masterAccount.Id, res.getId());
                        List<Id> mergedIds = res.getMergedRecordIds();
                        System.debug('IDs of merged records: ' + mergedIds);
                    } else {
                        for (Database.Error err : res.getErrors()) {
                            System.debug('Error--'+err.getMessage());
                        }
                    }
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        System.debug('mapDuplicateIDToMasterAcc---'+mapDuplicateIDToMasterAcc);
        List<Folder> folders = [SELECT Id, Name FROM Folder WHERE Name = 'Merged Accounts'];

        if(!folders.isEmpty() && !mapDuplicateIDToMasterAcc.isEmpty()){
            String documentName = 'Merged Accounts -'+ Datetime.now().format('MMM') + ' ' +Datetime.now().day() + ' ' +Datetime.now().year();
            csvColumnHeader = 'Merged Account ID, Master Merge Account ID\n';
            List<String> csvRowValues = new List<String>();
            for(ID idRec : mapDuplicateIDToMasterAcc.keySet()) {
                String rowStr = idRec + ',' +  mapDuplicateIDToMasterAcc.get(idRec);
                csvRowValues.add(rowStr);
            }
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');

            // Insert the generated CSV file in Document object under "Setup Audit Trail Logs".
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folders[0].Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;
        }
    }
}