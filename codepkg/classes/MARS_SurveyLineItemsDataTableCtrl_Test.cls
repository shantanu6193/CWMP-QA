@isTest
private class MARS_SurveyLineItemsDataTableCtrl_Test {
 @isTest
    static void testGetDataTableAndCreatePersonnelRecordsIfNotExisting(){
            Account testAccount = MARS_TestHelper.getAccount(true);
            Contact cont = new Contact();
            cont.FirstName='Test';
            cont.LastName='Test';
            cont.Accountid= testAccount.Id;
            insert cont;
            User user = MARS_TestHelper.getPortalUser(false);
        	user.ContactId = cont.Id;
        	insert user;
            Account acct = new Account();
            acct.Name = 'Testing';
            insert acct;
            AccountContactRelation acr = new AccountContactRelation();
            acr.AccountId = acct.Id;
            acr.ContactId = cont.Id;
            acr.Relationship_Strength__c = 'Primary';
            insert acr;
            Agency_Salary_Survey__c salarySurvey = new Agency_Salary_Survey__c();
            salarySurvey.Account__c = testAccount.Id;
            salarySurvey.Actual_Admin_Rate__c = 0.10;
            salarySurvey.Start_Date__c = DateTime.Now().AddDays(-3).date();
            salarySurvey.Status__c = 'Reviewed';
            insert salarySurvey;
            List<Salary_Survey_Line_Items__c> salaItemList = new List<Salary_Survey_Line_Items__c>();
            Salary_Survey_Line_Items__c salaItem = new Salary_Survey_Line_Items__c();
            salaItem.Classification_Title__c = 'Firefighter/FF-PMedic';
            salaItem.Current_Rate__c = 20.50;
            salaItem.Status__c = 'Active';
            salaItem.Agency_Salary_Survey__c = salarySurvey.Id;
            salaItemList.add(salaItem);
            insert salaItemList;
            Agency_Non_Suppression_Personnel__c nonSupPer = new Agency_Non_Suppression_Personnel__c();
            nonSupPer.Agency__c = testAccount.Id;
            nonSupPer.Start_Date__c =  DateTime.Now().AddDays(-3).date();
            nonSupPer.Approval_Status__c = 'Reviewed';
            insert nonSupPer;
            Agency_Non_Suppression_Line_Item__c nonSupPerItem = new Agency_Non_Suppression_Line_Item__c();
            nonSupPerItem.Classification_Title__c = 'Test';
            nonSupPerItem.Current_Rate__c = 25.00;
            nonSupPerItem.Status__c = 'Active';
            nonSupPerItem.Agency_Non_Suppression_Personnel__c = nonSupPer.Id;
            List<Agency_Non_Suppression_Line_Item__c> nonItemList = new List<Agency_Non_Suppression_Line_Item__c>();
            nonItemList.add(nonSupPerItem);
        	//insert nonItemList;
            Agency_Special_Equipment__c speEqup = new Agency_Special_Equipment__c();
            speEqup.Agency__c = testAccount.Id;
            speEqup.Start_Date__c =  DateTime.Now().AddDays(-3).date();
            speEqup.Approval_Status__c = 'Reviewed';
            insert speEqup;
            Agency_Special_Equipment_Line_Item__c speEqupItem = new Agency_Special_Equipment_Line_Item__c();
            speEqupItem.FEMA_CODE__c = '8089';
            speEqupItem.Special_Equipment_Type__c = 'Chain Saw';
            speEqupItem.Current_Rate__c = 25.00;
            speEqupItem.Revised_Rate__c = 25.00;
            speEqupItem.Status__c = 'Active';
            speEqupItem.Agency_Special_Equipment__c = speEqup.Id;
        	List<Agency_Special_Equipment_Line_Item__c> speQuipItemList = new List<Agency_Special_Equipment_Line_Item__c>();
        	speQuipItemList.add(speEqupItem);
            insert speEqupItem;
            Agency_Rate_Agreement__c agg = new Agency_Rate_Agreement__c();
        	agg.Start_Date__c = DateTime.Now().AddDays(-3).date();
        	agg.Agency__c = testAccount.Id;
        	agg.Approval_Status__c ='Revised';
        	insert agg;
        	Agency_Rate_Agreement_Line_Item__c aggLineItem = new Agency_Rate_Agreement_Line_Item__c();
        	aggLineItem.Agency_Rate_Agreement__c = agg.Id;
        	aggLineItem.Name ='Chief';
  			insert aggLineItem;
            Salary_Survey_Line_Items__c salaItem1 = new Salary_Survey_Line_Items__c();
            salaItem1.Classification_Title__c = 'Firefighter/FF-PMedic';
            salaItem1.Current_Rate__c = 20.50;
            salaItem1.Status__c = 'Active';
            Agency_Rate_Agreement_Line_Item__c agreRate = new Agency_Rate_Agreement_Line_Item__c();
            Agency_Non_Suppression_Line_Item__c nonSupp =  new Agency_Non_Suppression_Line_Item__c();
            Agency_Special_Equipment_Line_Item__c specialEquipment =  new Agency_Special_Equipment_Line_Item__c();
            String salaryLineItem = JSON.serialize(salaItemList);
            String nonItemListStr = JSON.serialize(nonItemList);
            String speEqupItemListStr = JSON.serialize(speQuipItemList);
        	String effDate =String.valueOf(DateTime.Now().date());
            //User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        	System.runAs(user) {  
                Salary_Survey_Line_Items__c record = MARS_SurveyLineItemsDataTableCtrl.getSurveyLineItemRecord(salaItemList[0].Id);
          		MARS_SurveyLineItemsDataTableCtrl.DataTableResponse result1 = MARS_SurveyLineItemsDataTableCtrl.getDataTableAndCreatePersonnelRecordsIfNotExisting(testAccount.Id,'Personnel_Survey_Line_Item_Fields','Salary_Survey_Line_Items__c');
                MARS_SurveyLineItemsDataTableCtrl.DataTableResponse result2 = MARS_SurveyLineItemsDataTableCtrl.getDataTableAndCreatePersonnelRecordsIfNotExisting(testAccount.Id,'Non_Suppression_Survey_Line_Item_Fields','Agency_Non_Suppression_Line_Item__c');
                MARS_SurveyLineItemsDataTableCtrl.DataTableResponse result3 = MARS_SurveyLineItemsDataTableCtrl.getDataTableAndCreatePersonnelRecordsIfNotExisting(testAccount.Id,'Resource_Agreement_Field','Agency_Rate_Agreement_Line_Item__c');
             	MARS_SurveyLineItemsDataTableCtrl.DataTableResponse result4 = MARS_SurveyLineItemsDataTableCtrl.getAdminDataTableResponse(testAccount.Id,'Personnel_Survey_Line_Item_Fields','Salary_Survey_Line_Items__c');
            	String salSurvey = MARS_SurveyLineItemsDataTableCtrl.upsertSurveyLineItem(salaryLineItem,testAccount.Id,effDate);
                String nonSep = MARS_SurveyLineItemsDataTableCtrl.upsertNonPersonnelLineItem(nonItemList,testAccount.Id,effDate);
                String SepcialEqup = MARS_SurveyLineItemsDataTableCtrl.upsertSpecialEquipLineItem(speQuipItemList,testAccount.Id,effDate);
                String agreemetn = MARS_SurveyLineItemsDataTableCtrl.upsertAgencyAgreementLineItem(aggLineItem,testAccount.Id);
                Salary_Survey_Line_Items__c record1 = MARS_SurveyLineItemsDataTableCtrl.createSSLI(salaItem1,testAccount.Id,'Personnel_Survey_Line_Item_Fields');
                Agency_Rate_Agreement_Line_Item__c record2 = MARS_SurveyLineItemsDataTableCtrl.createAgreeLineItem(agreRate,testAccount.Id);
                Agency_Non_Suppression_Line_Item__c record3 = MARS_SurveyLineItemsDataTableCtrl.createNonSuppressionPersonnelLineItem(nonSupp,testAccount.Id,effDate);
                Agency_Special_Equipment_Line_Item__c record4 = MARS_SurveyLineItemsDataTableCtrl.createSpecialEquipLineItem(specialEquipment,testAccount.Id,effDate);
            }
       }
     @isTest
    static void testGetDataTableAndCreatePersonnelRecordsIfNotExisting1(){
            Account testAccount = MARS_TestHelper.getAccount(true);
            Contact cont = new Contact();
            cont.FirstName='Test';
            cont.LastName='Test';
            cont.Accountid= testAccount.Id;
            insert cont;
            User user = MARS_TestHelper.getPortalUser(false);
        	user.ContactId = cont.Id;
        	insert user;
            Account acct = new Account();
            acct.Name = 'Testing';
            insert acct;
            AccountContactRelation acr = new AccountContactRelation();
            acr.AccountId = acct.Id;
            acr.ContactId = cont.Id;
            acr.Relationship_Strength__c = 'Primary';
            insert acr;
            CFAA__c cfaaParent =  new CFAA__c();
            cfaaParent.Name = 'Test CFAA';
            cfaaParent.Default_Admin_Rate__c = 0.10;
            cfaaParent.Start_Date__c = DateTime.Now().AddDays(-3).date();
            cfaaParent.END_Date__c = DateTime.Now().date();
            insert cfaaParent;
            List<CFAA_Line_Items__c> childList = new List<CFAA_Line_Items__c>();
            Id prssonel = Schema.SObjectType.CFAA_Line_Items__c.getRecordTypeInfosByName().get('Personnel Base Rate').getRecordTypeId();
            CFAA_Line_Items__c cfaaChild = new CFAA_Line_Items__c();
            cfaaChild.CFAA__c = cfaaParent.Id;
            cfaaChild.Personnel_Role__c = 'Firefighter/FF-PMedic';
            cfaaChild.Straight_Time_Rate__c = 27;
            cfaaChild.RecordTypeId = prssonel;
            childList.add(cfaaChild);
            Insert childList;   
             ContentVersion cv = MARS_TestHelper.getContentVersion();
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = testAccount.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
        	System.runAs(user) {  
               
          		MARS_SurveyLineItemsDataTableCtrl.DataTableResponse result1 = MARS_SurveyLineItemsDataTableCtrl.getDataTableAndCreatePersonnelRecordsIfNotExisting(testAccount.Id,'Personnel_Survey_Line_Item_Fields','Salary_Survey_Line_Items__c');
                MARS_SurveyLineItemsDataTableCtrl.DataTableResponse result2 = MARS_SurveyLineItemsDataTableCtrl.getDataTableResponse(testAccount.Id,'Personnel_Survey_Line_Item_Fields','Salary_Survey_Line_Items__c',result1);
                List<ContentDocument> getFiles = MARS_SurveyLineItemsDataTableCtrl.getFiles(testAccount.Id);
            }
       }
}