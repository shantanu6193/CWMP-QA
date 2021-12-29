public with sharing class MARS_CFAAProcessing_Batch implements Database.Batchable<sObject>{
    public string CFAArecId;
    Public CFAA__c cfaa;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(string.isBlank(cfaarecId)){
            throw new IllegalArgumentException('CFAArecId must not be null. You must pass a CFAA record Id that should be base for creating salary surveys');
        }
        cfaa = [SELECT Id, Start_Date__c FROM CFAA__c WHERE Id =:CFAArecId LIMIT 1 ];
        return Database.getQueryLocator([SELECT Id, Name, Account__c, Account__r.Macs_Id__c, Start_Date__c, END_Date__c, Status__c,
                                        Revised_From_Id__c, Unemployment_Insurance_Rate__c, Workers_Comp_Insurance_Rate__c,
                                        Actual_Admin_Rate__c, Same_as_Base_Rate_Count__c,
                                        (SELECT Id,Agency_Salary_Survey__c, Base_Rates__c, Classification_Title__c, 
                                        Line_Item_Type__c, Are_you_adding_WC_UI__c, WC_and_or_UI__c,Current_Rate__c,
                                        Revised_Rate__c FROM Salary_Survey_Line_Items__r)
                                        FROM Agency_Salary_Survey__c
                                        WHERE (end_date__c = null or (end_date__c >= :cfaa.Start_Date__c))
                                        AND Status__c != 'Rejected'
                                        AND Same_as_Base_Rate_Count__c	> 0
                                        
                                    ]);
                                        
    }
    
    public void execute(Database.BatchableContext BC, List<Agency_Salary_Survey__c> scope) {
        list<Agency_Salary_Survey__c> surveysToCreate = new list<Agency_Salary_Survey__c>();
        list<Agency_Salary_Survey__c> surveysToClone = new list<Agency_Salary_Survey__c>();
        list<Agency_Salary_Survey__c> surveysToUpdate = new list<Agency_Salary_Survey__c>();
        list<Salary_Survey_Line_Items__c> lineItemstoCreate = new list<Salary_Survey_Line_Items__c>();
        map<string,CFAA_Line_Items__c> CFAAtitletoRateMap = new map<string,CFAA_Line_Items__c>();
        map<string,list<Salary_Survey_Line_Items__c>> lineitemsMap = new map<string, list<Salary_Survey_Line_Items__c>>();
        map<string,string> newSurveysIdMap = new map<string,string>();
        list<Salary_Survey_Line_Items__c> lineItemstoUpdate = new list<Salary_Survey_Line_Items__c>();
		cfaa = [SELECT Id, Start_Date__c FROM CFAA__c WHERE Id =:CFAArecId LIMIT 1 ];

        list<CFAA_Line_Items__c> newCFAAitems = [SELECT Id, Name, Personnel_Role__c, Straight_Time_Rate__c, 
                                                        CFAA__r.Start_Date__c, Over_Time_Rate__c
                                                 FROM CFAA_Line_Items__c 
                                                 WHERE CFAA__c = :CFAArecId];
        for(CFAA_Line_Items__c cf: newCFAAitems){
            CFAAtitletoRateMap.put(cf.Personnel_Role__c, cf);
        }

        Date endDate = newCFAAitems[0].CFAA__r.Start_Date__c.addDays(-1);
        Date startDatefornewSalary  = newCFAAitems[0].CFAA__r.Start_Date__c;
        Agency_Salary_Survey__c newSurvey;

        for(Agency_Salary_Survey__c survey: scope){
            //identify the salary survey records that need a clone of line items
            if(survey.Start_Date__c <= cfaa.Start_Date__c && (survey.End_Date__c == null || survey.End_Date__c >= cfaa.start_Date__c)){
                newSurvey = new Agency_Salary_Survey__c();
                newSurvey = survey.clone(false, false, false, false);
                newSurvey.Revised_From_Id__c = survey.Id;
                newSurvey.Name = 'Salary Survey for Agency '+survey.Account__r.Macs_Id__c+' '+startDatefornewSalary;
                newSurvey.Start_Date__c = startDatefornewSalary;
                surveysToCreate.add(newSurvey);
                lineitemsMap.put(survey.Id, survey.Salary_Survey_Line_Items__r);

                surveysToUpdate.add(new Agency_Salary_Survey__c(Id=survey.Id, 
                                                                Status__c = 'Revised',
                                                                End_Date__c = endDate)
                                                              );//since we are cloning a copy for the new period, existing surveys should be marked as Revised
                                                            //If end date is in the past, Automated flow will set it to Expired
            } 

            //identify the surveys where lineitems data have to be updated without touching the actual salary survey
            if(survey.Start_Date__c > cfaa.Start_Date__c || survey.Start_Date__c == null){
                lineItemstoUpdate.addAll(survey.Salary_Survey_Line_Items__r);
            }
        }
        update surveysToUpdate;
        insert surveysToCreate;

        for(Agency_Salary_Survey__c survey: surveysToCreate){
            newSurveysIdMap.put(survey.Revised_From_Id__c, survey.Id);
        }

        for(Salary_Survey_Line_Items__c li: lineItemstoUpdate){
            if(CFAAtitletoRateMap.containsKey(li.Classification_Title__c)){
                li.Base_Rates__c = CFAAtitletoRateMap.get(li.Classification_Title__c).Straight_Time_Rate__c;
            }
            if(li.WC_and_or_UI__c == 'Yes' && li.Are_you_adding_WC_UI__c == 'No' && CFAAtitletoRateMap.containsKey(li.Classification_Title__c)){
                li.Revised_Rate__c =  CFAAtitletoRateMap.get(li.Classification_Title__c).Straight_Time_Rate__c;
                li.CFAA_Line_Items__c = CFAAtitletoRateMap.get(li.Classification_Title__c).Id;
            }
        }

        update lineItemstoUpdate;
        
        Salary_Survey_Line_Items__c lineItem;
        for(string surveyId: lineitemsMap.keySet()){
            for(Salary_Survey_Line_Items__c li: lineitemsMap.get(surveyId)){
                lineItem = new Salary_Survey_Line_Items__c();
                lineItem = li.clone(false, false, false, false);
                lineitem.Agency_Salary_Survey__c = newSurveysIdMap.get(surveyId);
                lineitem.CFAA__c = CFAArecId;
                lineItem.CFAA_Line_Items__c = null;
                if(CFAAtitletoRateMap.containsKey(li.Classification_Title__c)){
                    lineitem.Base_Rates__c = CFAAtitletoRateMap.get(li.Classification_Title__c).Straight_Time_Rate__c;
                }
                if(li.WC_and_or_UI__c == 'Yes' && li.Are_you_adding_WC_UI__c == 'No' && CFAAtitletoRateMap.containsKey(li.Classification_Title__c)){
                    lineitem.Revised_Rate__c =  CFAAtitletoRateMap.get(li.Classification_Title__c).Straight_Time_Rate__c;
                    lineItem.CFAA_Line_Items__c = CFAAtitletoRateMap.get(li.Classification_Title__c).Id;
                }
                lineItemstoCreate.add(lineItem);
            }

        }
        insert lineItemstoCreate;
        
    }   
    
    public void finish(Database.BatchableContext BC) {
        update new CFAA__c(Id=CFAArecId, CFAA_Processed_for_Salary_Surveys__c = true);
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = :BC.getJobId() ];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(Userinfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.subject = 'CFAA Processing for Salary Survey Creation Job is Completed';
        mail.plainTextBody = 'Batch job is completed. Total job items are '+job.TotalJobitems+' Number of Errors '+ job.NumberOfErrors;
        
        Messaging.sendEmail(new list<Messaging.SingleEmailMessage>{mail});
    }
    	
}