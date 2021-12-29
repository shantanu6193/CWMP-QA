@isTest
public with sharing class RelatedRecordCtrlTest {
       @IsTest 
     static void testGetRecord(){
                Map<String,List<User_Registration__c>> returnMap = new Map<String,List<User_Registration__c>>();
                Test.startTest();
         		User_Registration__c userReg1 = PHOS_TestHelper.getUserRegistration(false);
         		userReg1.Email__c ='test@gmail.com';
         		insert userReg1;
         		 String Id = String.valueOf(userReg1.Id);
                List<User_Registration__c> userReg = RelatedRecordCtrl.getRecords('User_Registration__c',Id,'Email__c','Email__c');
                returnMap.put('record',userReg);
                system.assert(returnMap.size()>0);
                Test.stopTest();
    		}
    @IsTest
    static void countRecords_Test(){
        User testUser = [Select id from user where id = :UserInfo.getUserId()];
        Test.startTest();
        System.runAs(testUser){
            RelatedRecordCtrl.countRecords('Select count() FROM Contact LIMIT 1');
            RelatedRecordCtrl.countRecords(null);
        }
        Test.stopTest();
        
    }

}