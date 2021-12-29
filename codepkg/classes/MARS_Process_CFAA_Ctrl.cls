public with sharing class MARS_Process_CFAA_Ctrl {

    @AuraEnabled
    public static string checkEndDate(string currentCFAAId){
        try {
            list<CFAA__c> existingCFAA = [SELECT Id, Name, Default_Admin_Rate__c, Start_Date__c, END_Date__c,
                                            CFAA_Processed_for_Salary_Surveys__c
                                            FROM CFAA__c WHERE Id=: currentCFAAId LIMIT 1];
            if(existingCFAA[0].End_Date__c == null){
                return 'Please put the end date for the current CFAA before cloning a new one.';
            }

            return '';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string cloneCFAA(date newStartDate, string currentCFAAId){
        try {
            CFAA__c newCFAA = new CFAA__c();
            list<CFAA_Line_Items__c> newCFAAlineItems = new list<CFAA_Line_Items__c>();

            list<CFAA__c> existingCFAA = [SELECT Id, Name,Default_Admin_Rate__c,Start_Date__c,END_Date__c,
                                            CFAA_Processed_for_Salary_Surveys__c
                                            FROM CFAA__c WHERE Id=: currentCFAAId LIMIT 1];

            newCFAA = existingCFAA[0].clone(false, false, false, false);
            newCFAA.Start_Date__c = newStartDate;
            newCFAA.ENd_Date__c = null;
            newCFAA.CFAA_Processed_for_Salary_Surveys__c = false;
            newCFAA.Name = 'CFAA beginning from '+newStartDate;

            insert newCFAA;

            list<CFAA_Line_Items__c> lineItems = [SELECT Id,CFAA__c,Emergency_Apparatus_Type__c,Is_Overhead__c,Order_No__c,Other_Role__c,
                                                    Over_Time_Rate__c, Personnel_Role__c, RecordTypeId, Straight_Time_Rate__c, Support_Equipment_Type__c,
                                                    Type__c, Unit_of_Measure__c 
                                                 FROM CFAA_Line_Items__c 
                                                 WHERE CFAA__c = :currentCFAAId];
            
            CFAA_Line_Items__c  lineItem;
            for(CFAA_Line_Items__c li: lineItems){
                lineItem = new CFAA_Line_Items__c();
                lineItem = li.clone(false, false, false, false);
                lineItem.CFAA__c = newCFAA.Id;
                newCFAAlineItems.add(lineItem);
            }

            insert newCFAAlineItems;

            return newCFAA.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    //This is for cloning salary survey line items
    @AuraEnabled
    public static string validateCFAAForSalarySurveys(string currentCFAAId){
        try {
            CFAA__c currentCFAA = [SELECT Id, Name, Default_Admin_Rate__c, Start_Date__c, END_Date__c,
                                            CFAA_Processed_for_Salary_Surveys__c
                                            FROM CFAA__c WHERE Id=: currentCFAAId LIMIT 1];
            
            if(currentCFAA.CFAA_Processed_for_Salary_Surveys__c){
                return 'This CFAA is already processed for Salary Surveys. Re-processing will create duplicate entries';
            }

            list<CFAA__c> noEndDateCFAA = [SELECT Id, Name, Default_Admin_Rate__c, Start_Date__c, END_Date__c,
                                            CFAA_Processed_for_Salary_Surveys__c
                                            FROM CFAA__c WHERE Id !=: currentCFAAId
                                            AND  END_Date__c = null
                                            LIMIT 1];
            
            if(!noEndDateCFAA.isEmpty()){
                return 'There is a CFAA record with Salesforce Id: '+noEndDateCFAA[0].Id+ ' that does not have end date. Please put end date to the CFAA before processing this for cloning salary surveys';
            }

            list<CFAA__c> overlapCFAA = [SELECT Id FROM CFAA__c WHERE 
                                            Id !=: currentCFAAId AND
                                            End_Date__c >= :currentCFAA.Start_Date__c 
                                            LIMIT 1];

            if(!overlapCFAA.isEmpty()){
                return 'Current CFAA record start date is overlapping with an existing CFAA record with Salesforce Id: '+overlapCFAA[0].Id+'. Please put correct the start date of the current CFAA before proceeding with cloning salary surveys';
            }


            return '';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string ProceedCloneSalarySurvey(string currentCFAAId){
        try {
            MARS_CFAAProcessing_Batch b = new MARS_CFAAProcessing_Batch();
            b.CFAArecId = currentCFAAId;
            Database.executeBatch(b,10);

            return 'Batch job to clone the salary survey records started in the backend. You will receive an email once the process is complete';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}