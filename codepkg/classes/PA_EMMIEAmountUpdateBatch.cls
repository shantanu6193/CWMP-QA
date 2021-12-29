/***********************************************************************************************************************************
* Class Name   : PA_EMMIEAmountUpdateBatch
* Description  : 
* Author       : Digambar
* Created On   : 08/04/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
*/

public with sharing class PA_EMMIEAmountUpdateBatch implements Database.Batchable<EMMIE_Project_Staging__c>, Database.Stateful, Schedulable{
    
    public Iterable<EMMIE_Project_Staging__c> start(Database.BatchableContext bc) {
        List<EMMIE_Project_Staging__c> emmieList= [SELECT Id, Name, Amount__c, DR__c, PW__c, VER__c
                  						 		   FROM EMMIE_Project_Staging__c
                 						 		  ];
        return emmieList;
    }
    //**********************************************************************************************************************
    public void execute(Database.BatchableContext bc, List<EMMIE_Project_Staging__c> emmieList){
        Map<String, Decimal> emmieData = new Map<String, Decimal>();
        for(EMMIE_Project_Staging__c emmie : emmieList){
            	emmieData.put(emmie.PW__c + '-' + emmie.VER__c + '-' + emmie.DR__c , emmie.Amount__c);
        }
        List<String> emmieUniqueIdList = new List<String>(emmieData.keySet());
        
        //Update Project Closeout Amount 
        List<Project_Closeout__c> projectCloseoutList= [SELECT Id, EMMIE_Batch_Unique_No__c
									                    FROM Project_Closeout__c
									                    WHERE EMMIE_Batch_Unique_No__c IN :emmieUniqueIdList
                 					                    ];
        for(Project_Closeout__c projectCloseout : projectCloseoutList){
            projectCloseout.FEMA_Obligated_Amount__c = emmieData.get(projectCloseout.EMMIE_Batch_Unique_No__c);
        }
        update projectCloseoutList;
        
        //Update Award Amount
        List<Award__c> awardList = [SELECT Id, EMMIE_Batch_Unique_No__c
								    FROM Award__c
								    WHERE EMMIE_Batch_Unique_No__c IN :emmieUniqueIdList
                 				   ];
        for(Award__c award : awardList){
                award.FEMA_Obligated_Amount__c = emmieData.get(award.EMMIE_Batch_Unique_No__c);
        }
        update awardList;
        
    }
    //**********************************************************************************************************************
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()
                           ];
    }
    //**********************************************************************************************************************
    public static void execute(SchedulableContext ctx){
        PA_EMMIEAmountUpdateBatch EMMIEAmountUpdateBatch = new PA_EMMIEAmountUpdateBatch();
        Id batchId = Database.executeBatch(EMMIEAmountUpdateBatch, 500);
    } 
    /* 
    //**********************************************************************************************************************
    public static void schedular(){
        String jobId = System.schedule('EMMIE Amount Update Job', '0 0 * * * ?', new PA_EMMIEAmountUpdateBatch() );
        CronTrigger ct = [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
        system.debug('#CronTrigger :'+ct);
    }
    //**********************************************************************************************************************
   */
}