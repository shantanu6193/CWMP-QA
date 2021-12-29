/*
@Author : Rohith
@CreatedDate : 10th Dec 2020
@Description : To send account renewal expiry notification
*/
global class AccountEmailNotificationBatch implements Database.Batchable<sObject>, Schedulable {
    
    //Start method to get all account records where renewal date is greater than current date.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, DUNS_Expiration_Date__c, FFATAExpirationDate__c FROM Account WHERE Email_Address__c != NULL AND DUNS_Expiration_Date__c > TODAY AND FFATAExpirationDate__c > TODAY'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accounts){
        
        List<Account> accList = new List<Account>();
        
        //Update DUNS and FFATA expiry days based on expiry date to send email
        for(Account acc :accounts){
            Boolean isUpdate = false;
            //For DUNS Expiry
            if(acc.DUNS_Expiration_Date__c != NULL){
                
                if(acc.DUNS_Expiration_Date__c == System.today().addDays(1)){//For 1 day notification
                    isUpdate = true;
                    acc.DUNSExpiryDays__c = 1;
                }
                else if(acc.DUNS_Expiration_Date__c == System.today().addDays(14)){//For 14 days notification
                    isUpdate = true;
                    acc.DUNSExpiryDays__c = 14;
                }else if(acc.DUNS_Expiration_Date__c == System.today().addDays(30)){//For 30 days notification
                    isUpdate = true;
                    acc.DUNSExpiryDays__c = 30;
                }
                else if(acc.DUNS_Expiration_Date__c == System.today().addDays(60)){//For 60 days notification
                    isUpdate = true;
                    acc.DUNSExpiryDays__c = 60;
                }else if(acc.DUNS_Expiration_Date__c == System.today().addDays(90)){//For 90 days notification
                    isUpdate = true;
                    acc.DUNSExpiryDays__c = 90;
                }
            }
            //For FFATA Expiry
            if(acc.FFATAExpirationDate__c != NULL){
                if(acc.FFATAExpirationDate__c == System.today().addDays(1)){//For 1 day notification
                    isUpdate = true;
                    acc.FFATAExpiryDays__c = 1;
                }else if(acc.FFATAExpirationDate__c == System.today().addDays(14)){//For 14 days notification
                    isUpdate = true;
                    acc.FFATAExpiryDays__c = 14;
                }else if(acc.FFATAExpirationDate__c == System.today().addDays(30)){//For 30 days notification
                    isUpdate = true;
                    acc.FFATAExpiryDays__c = 30;
                }else if(acc.FFATAExpirationDate__c == System.today().addDays(60)){//For 60 days notification
                    isUpdate = true;
                    acc.FFATAExpiryDays__c = 60;
                }else if(acc.FFATAExpirationDate__c == System.today().addDays(90)){//For 90 days notification
                    isUpdate = true;
                    acc.FFATAExpiryDays__c = 90;
                }
            }
            if(isUpdate){
                accList.add(acc);
            }
        }
        //Update accounts
        if(!accList.isEmpty()){
            update accList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    //Scheduled batch
    global void execute(SchedulableContext sc) {
        Database.executebatch(new AccountEmailNotificationBatch(), 10);
    }
}