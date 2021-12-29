@IsTest
private class MARS_Process_CFAA_Ctrl_Test {
    @testSetup
    static void createCFAA(){
        CFAA__c currentCFAA = new CFAA__c();
        currentCFAA.Name = 'test';
        currentCFAA.Start_Date__c = Date.today();
        CFAA_Line_Items__c lineitem = new CFAA_Line_Items__c();
        
        insert currentCFAA;
        String currentID = currentCFAA.Id;
        lineitem.CFAA__c = currentCFAA.Id;
        insert lineitem;
    }
    @IsTest
    static void test(){      
        CFAA__c currentRecord = [SELECT Id, Name FROM CFAA__c WHERE Name = 'test'];
        String currentId = currentRecord.Id;
        
        MARS_Process_CFAA_Ctrl c = new MARS_Process_CFAA_Ctrl();
        MARS_Process_CFAA_Ctrl.checkEndDate(currentId);
        MARS_Process_CFAA_Ctrl.cloneCFAA(Date.today(), currentId);
        MARS_Process_CFAA_Ctrl.validateCFAAForSalarySurveys(currentId);
        MARS_Process_CFAA_Ctrl.ProceedCloneSalarySurvey(currentId);
        
    }
    
    @IsTest
    static void test1(){
        CFAA__c currentRecord = [SELECT Id, Name FROM CFAA__c WHERE Name = 'test'];
        String currentId = currentRecord.Id;
        currentRecord.Start_Date__c = Date.today() + 10;
        currentRecord.END_Date__c = Date.today() + 20;
        currentRecord.CFAA_Processed_for_Salary_Surveys__c = true;
        update currentRecord;
        
        MARS_Process_CFAA_Ctrl.checkEndDate(currentId);
        MARS_Process_CFAA_Ctrl.validateCFAAForSalarySurveys(currentId);
    }
    
    @IsTest
    static void test2(){
        CFAA__c currentCFAA = new CFAA__c();
        currentCFAA.Name = 'testing';
        currentCFAA.Start_Date__c = Date.today();
        currentCFAA.END_Date__c = Date.today() + 20;
        currentCFAA.CFAA_Processed_for_Salary_Surveys__c = false;
        CFAA_Line_Items__c lineitem = new CFAA_Line_Items__c();
        
        insert currentCFAA;
        String currentID = currentCFAA.Id;
        insert lineitem;
        
        CFAA__c noEndDate = [SELECT Id, Name, Default_Admin_Rate__c, Start_Date__c, END_Date__c,
                             CFAA_Processed_for_Salary_Surveys__c
                             FROM CFAA__c WHERE Id !=: currentId
                             AND  END_Date__c = null
                             LIMIT 1];
        
        noEndDate.END_Date__c = Date.today();
        update noEndDate;
        MARS_Process_CFAA_Ctrl.checkEndDate(currentId);
        MARS_Process_CFAA_Ctrl.validateCFAAForSalarySurveys(currentId);
    }
}