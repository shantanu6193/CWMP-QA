/**
 * Created by Pankaj on 06-04-2021.
 */

public without sharing class MARS_SalarySurveyCrl {

    @AuraEnabled
    public static Map<String, Object> getData(String accountId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('salarySurveyLines', getSalarySurveyLines(accountId));
        List<Agency_Salary_Survey__c> salarySurveys = [SELECT id,Status__c,Requested_Effective_Date__c from Agency_Salary_Survey__c
                where Account__c =:accountId AND (Status__c =: MARS_Constants.SURVEY_STATUS_PENDING_REVIEW OR Status__c =: MARS_Constants.SURVEY_STATUS_REVIEWED) ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
        if(salarySurveys.size() == 0) {
                returnMap.put('salarySurvey', new Agency_Salary_Survey__c());
        } else {
            returnMap.put('salarySurvey', salarySurveys.get(0));
        }

        return returnMap;
    }

    private static List<Salary_Survey_Line_Items__c> getSalarySurveyLines(String accountId) {
        List<Salary_Survey_Line_Items__c> salarySurveyLineItems = new List<Salary_Survey_Line_Items__c>();
        //Set<String> overTimeCheckForClasTitle = new Set<String>{'Battalion Chief', 'Co. Officer/Capt./Lt.','App. Officer/Eng','Firefighter/FF-PMedic'};
        String overTimeCheckForClasTitle = KeyValueHelper.getTextValue('MARS_Salary_Survey_Overtime_Titles');
        Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = getAgreementLineItemMap(accountId);
        Map<String, Salary_Survey_Line_Items__c> currentRateMap = getSalarySurveyWithCurrentDate(accountId);
        Map<String, Salary_Survey_Line_Items__c> pendingRateMap = getSalarySurveyWithPendingApproval(accountId);
        for (CFAA_Line_Items__c cfaaLineItems : getCFAALineItems()) {
            Boolean isovertime = false;
            Boolean isPTP = false;
            if(overTimeCheckForClasTitle != null) {
                for(String element:overTimeCheckForClasTitle.split(',')){
                    if(element == cfaaLineItems.Personnel_Role__c) {
                        isovertime = true;
                    }    
                }    
            }
            if(agencyAgreementMap.containsKey(cfaaLineItems.Personnel_Role__c)) {
                for(Agency_Rate_Agreement_Line_Item__c lineItem : agencyAgreementMap.get(cfaaLineItems.Personnel_Role__c)) {
                   if(lineItem.OT__c) {
                        isovertime = lineItem.OT__c;
                    } 
                    if(lineItem.PTP__c) {
                        isPTP =  lineItem.PTP__c;
                    }
                }
            } 

            salarySurveyLineItems.add(new Salary_Survey_Line_Items__c(
                    Line_Item_Type__c = MARS_Constants.LINE_ITEM_TYPE_PERSONNEL,
                    Classification_Title__c = cfaaLineItems.Personnel_Role__c,
                    Base_Rates__c = cfaaLineItems.Straight_Time_Rate__c,
                    Order__c = cfaaLineItems.Order_No__c,
                    CFAA__c = cfaaLineItems.CFAA__c,
                    Are_you_adding_WC_UI__c = 'No',
                   /* P_T_P__c = agencyAgreementMap.containsKey(cfaaLineItems.Personnel_Role__c)
                                    ? agencyAgreementMap.get(cfaaLineItems.Personnel_Role__c).PTP__c
                                    : false,*/
                   /* MOU_MOA__c = agencyAgreementMap.containsKey(cfaaLineItems.Personnel_Role__c)
                                    ? agencyAgreementMap.get(cfaaLineItems.Personnel_Role__c).OT__c
                                    : false,*/
                    P_T_P__c   = isPTP,
                    MOU_MOA__c =  isovertime,         
                    Current_Rate__c = currentRateMap.get(cfaaLineItems.Personnel_Role__c) != null
                                    ? currentRateMap.get(cfaaLineItems.Personnel_Role__c).Current_Rate__c
                                    : 0.00,
                    Revised_Rate__c = pendingRateMap.get(cfaaLineItems.Personnel_Role__c) != null
                            ? pendingRateMap.get(cfaaLineItems.Personnel_Role__c).Revised_Rate__c
                            : null
                    )
            );
        }
        return salarySurveyLineItems;
    }

    private static Map<String, Salary_Survey_Line_Items__c> getSalarySurveyWithPendingApproval(String accountId) {
        Map<String, Salary_Survey_Line_Items__c> returnMap = new Map<String, Salary_Survey_Line_Items__c>();
        List<Agency_Salary_Survey__c> agencySalarySurveys = [SELECT Id,
        (SELECT Id, Classification_Title__c, Revised_Rate__c FROM Salary_Survey_Line_Items__r)
        FROM Agency_Salary_Survey__c
        WHERE Account__c=:accountId  AND Status__c =:MARS_Constants.SURVEY_STATUS_PENDING_REVIEW];
        if(agencySalarySurveys.size() == 0) return returnMap;
        for (Salary_Survey_Line_Items__c salarySurveyLineItems : agencySalarySurveys.get(0).Salary_Survey_Line_Items__r) {
            returnMap.put(salarySurveyLineItems.Classification_Title__c, salarySurveyLineItems);
        }
        return returnMap;
    }

    private static Map<String, Salary_Survey_Line_Items__c> getSalarySurveyWithCurrentDate(String accountId) {
        Map<String, Salary_Survey_Line_Items__c> returnMap = new Map<String, Salary_Survey_Line_Items__c>();
        List<Agency_Salary_Survey__c> agencySalarySurveys = [SELECT Id,
                (SELECT Id, Classification_Title__c, Current_Rate__c FROM Salary_Survey_Line_Items__r WHERE Status__c=:MARS_Constants.SURVEY_STATUS_ACTIVE)
                FROM Agency_Salary_Survey__c
                WHERE Start_Date__c<=:System.today() AND (END_Date__c>=:System.today() OR END_Date__c = null) AND Account__c=:accountId
                AND (Status__c=:'Reviewed' OR Status__c=:MARS_Constants.SURVEY_STATUS_REVISED)];
        if(agencySalarySurveys.size() == 0) return returnMap;
        if(agencySalarySurveys.size() > 1) {
            throw new AuraHandledException('More than one active Agency Survey found. Please contact Administrator.');
        }
        for (Salary_Survey_Line_Items__c salarySurveyLineItems : agencySalarySurveys.get(0).Salary_Survey_Line_Items__r) {
            returnMap.put(salarySurveyLineItems.Classification_Title__c, salarySurveyLineItems);
        }
        return returnMap;
    }

    private static List<CFAA_Line_Items__c> getCFAALineItems() {
        return [
                SELECT Id, Personnel_Role__c, Straight_Time_Rate__c, Order_No__c,
                        CFAA__r.Start_Date__c, CFAA__r.END_Date__c,
                        CFAA__c FROM CFAA_Line_Items__c Where CFAA__c != null and
                CFAA__r.Start_Date__c <= today and (CFAA__r.END_Date__c >= today or CFAA__r.END_Date__c = null) and
                RecordType.Name = :MARS_Constants.PERSONNEL_BASE_RATE ORDER BY Order_No__c ASC
        ];
    }

    private static Map<String, List<Agency_Rate_Agreement_Line_Item__c>> getAgreementLineItemMap(String accountId) {
        Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = new Map<String, List<Agency_Rate_Agreement_Line_Item__c>>();
        for (Agency_Rate_Agreement_Line_Item__c eachRecord :
        [ SELECT Id, Name, OT__c,
                PTP__c FROM Agency_Rate_Agreement_Line_Item__c Where
                Agency_Rate_Agreement__r.Agency__c =:accountId AND Agency_Rate_Agreement__r.Approval_Status__c IN ('Approved','Revised')]) {
            for (String name : eachRecord.Name.split(';')) {
                //agencyAgreementMap.put(name, eachRecord);
                if(agencyAgreementMap.get(name) == null) {
                    agencyAgreementMap.put(name, new List<Agency_Rate_Agreement_Line_Item__c>());
                }
                agencyAgreementMap.get(name).add(eachRecord);
            }
        }
        return agencyAgreementMap;
    }


    @AuraEnabled
    public static void submitSalarySurveyLines(String data, String accountId, String effectiveDate, String signatureBlob) {
       //try{
            List<Salary_Survey_Line_Items__c> lineItemsForUpdateList = (List<Salary_Survey_Line_Items__c>)JSON.deserialize( data, List<Salary_Survey_Line_Items__c>.class);
            Account accountRecord = [SELECT Id,MACS_ID__c FROM Account WHERE Id =: accountId];
            Agency_Salary_Survey__c agencySalarySurvey = processAgencySalarySurveyPendingForApproval(accountId, Date.valueOf(effectiveDate));
            for (Salary_Survey_Line_Items__c salarySurveyLineItems : lineItemsForUpdateList) {
                salarySurveyLineItems.Effective_Date__c = Date.valueOf(effectiveDate);
                salarySurveyLineItems.Name = salarySurveyLineItems.Classification_Title__c+'-'+accountRecord.MACS_ID__c;
                if (salarySurveyLineItems.Revised_Rate__c == null) {
                    salarySurveyLineItems.Revised_Rate__c = salarySurveyLineItems.Base_Rates__c;
                }
                salarySurveyLineItems.Agency_Salary_Survey__c = agencySalarySurvey.Id;
            }
            insert lineItemsForUpdateList;

            if(signatureBlob != null) {
                SignatureHelper.saveSign(signatureBlob, agencySalarySurvey.Id);
            }
            Map<String, String> paramMap = new Map<String, String>();
            paramMap.put('AgencySalarysurveyId', agencySalarySurvey.Id);
            Flow.Interview.MARS_Salary_Survey_Notify_Internal_People flow1=new Flow.Interview.MARS_Salary_Survey_Notify_Internal_People(paramMap );
            flow1.start();
        //}catch(Exception e){
        //    System.debug('Line 120===>'+e);
        //}
    }

    private static Agency_Salary_Survey__c processAgencySalarySurveyPendingForApproval(String accountId, Date effectDate) {
        List<Agency_Salary_Survey__c> agentSalarySurvey =[SELECT Id, Status__c FROM Agency_Salary_Survey__c WHERE Account__c=:accountId AND Status__c =:MARS_Constants.SURVEY_STATUS_PENDING_REVIEW LIMIT 1 ];

        Agency_Salary_Survey__c ass = new Agency_Salary_Survey__c();

        if (agentSalarySurvey.isEmpty()) {
            ass.Account__c = accountId;
            ass.Name = 'Salary Survey For Agency ' + System.now().format();
            ass.Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        } else {
            ass = agentSalarySurvey.get(0);
            delete [SELECT Id FROM Salary_Survey_Line_Items__c WHERE Agency_Salary_Survey__c=:ass.Id];
        }
        ass.Requested_Effective_Date__c = effectDate;
        upsert ass;
        return ass;
    }
}