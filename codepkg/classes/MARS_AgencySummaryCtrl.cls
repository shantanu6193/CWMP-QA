public without sharing class MARS_AgencySummaryCtrl {

    @AuraEnabled
    public static Map<String, Object> getData(String accountId, Date dayOfRecord) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<SalaryAndNonSuppresionPersonnel> salarySurveyLineItems = getSalarySurveyItems(accountId, dayOfRecord);
        List<Agency_Special_Equipment_Line_Item__c> specialEquipmentLineItem = getSpecialEquipmentItems(accountId, dayOfRecord);
        String adminRate = getAdminLineItems(accountId, dayOfRecord);
        returnMap.put('salarySurveyLineItems', salarySurveyLineItems);
        returnMap.put('specialEquipmentLineItem', specialEquipmentLineItem);
        returnMap.put('adminRate', adminRate);
        return returnMap;
    }

    public static List<SalaryAndNonSuppresionPersonnel> getSalarySurveyItems(String accountId, Date dayOfRecord){
        List<SalaryAndNonSuppresionPersonnel> salarayAndNonSuppPersonelList = new List<SalaryAndNonSuppresionPersonnel>();
        try {
            String defaultOverTime = KeyValueHelper.getTextValue('MARS_Salary_Survey_Overtime_Titles');
            String parentId;
            List<Agency_Salary_Survey__c> surveys = [SELECT Id, Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Salary_Survey__c
                                                    WHERE Account__c = :accountId
                                                    AND Status__c != 'Rejected' AND (NOT Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];

            if(!surveys.isEmpty()){
                parentId = surveys[0].Id;

                List<Salary_Survey_Line_Items__c> salarySurveyLineItems = [SELECT Id, Name, Classification_Title__c, Base_Rates__c, WC_and_or_UI__c, Are_you_adding_WC_UI__c, Revised_Rate__c, Agency_Salary_Survey__r.Start_Date__c, 
                            Agency_Salary_Survey__r.End_Date__c, Agency_Salary_Survey__r.Status__c, Agency_Salary_Survey__r.Reject_Reason__c,Agency_Salary_Survey__c,
                            Agency_Salary_Survey__r.Name, Agency_Salary_Survey__r.CreatedBy.LastName, Agency_Salary_Survey__r.CreatedBy.FirstName
                        FROM Salary_Survey_Line_Items__c 
                        WHERE Agency_Salary_Survey__c = :parentId];
                String classiTitleSequence = KeyValueHelper.getTextValue('MARS_Classification_Title_Sequence');
                List<String> classiTitleSequenceList = classiTitleSequence.split(',');
                Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = getAgreementLineItemMap(accountId,dayOfRecord);
                for(String itemTitle :classiTitleSequenceList) {
                    for(Salary_Survey_Line_Items__c lineItem: salarySurveyLineItems) {
                        if(itemTitle == lineItem.Classification_Title__c) {
                            SalaryAndNonSuppresionPersonnel item = new SalaryAndNonSuppresionPersonnel();
                            String isovertime = 'No';
                            String isPTP = 'No';
                            if(defaultOverTime != null) {
                                for(String element:defaultOverTime.split(',')){
                                    if(element == lineItem.Classification_Title__c) {
                                        isovertime = 'Yes';
                                    }
                                }
                            }
                            if(agencyAgreementMap != null && agencyAgreementMap.containsKey(lineItem.Classification_Title__c)) {
                                for(Agency_Rate_Agreement_Line_Item__c aRALineItem : agencyAgreementMap.get(lineItem.Classification_Title__c)) {
                                   if(aRALineItem.OT__c) {
                                        isovertime = 'Yes';
                                    } 
                                    if(aRALineItem.PTP__c) {
                                        isPTP =  'Yes';
                                    }
                                }
                            }
                            item.ClassificationTitle = lineItem.Classification_Title__c;
                            item.SalaryRate = String.valueOf(lineItem.Revised_Rate__c);
                            item.Overtime = isovertime;
                            item.PortaltoPortal = isPTP;
                            salarayAndNonSuppPersonelList.add(item);
                        }
                    }
                }
               
                List<Agency_Non_Suppression_Line_Item__c> nonUspperssionList = getNonsupressionItems(accountId, dayOfRecord);
                for(Agency_Non_Suppression_Line_Item__c nonSupLineItem: nonUspperssionList) {
                    String isovertime = 'No';
                    String isPTP = 'No';
                    SalaryAndNonSuppresionPersonnel item = new SalaryAndNonSuppresionPersonnel();
                   
                    if(agencyAgreementMap != null && agencyAgreementMap.containsKey(nonSupLineItem.Classification_Title__c)) {
                        for(Agency_Rate_Agreement_Line_Item__c aRALineItem : agencyAgreementMap.get(nonSupLineItem.Classification_Title__c)) {
                           if(aRALineItem.OT__c) {
                                isovertime = 'Yes';
                            } 
                            if(aRALineItem.PTP__c) {
                                isPTP =  'Yes';
                            }
                        }
                    }
                    item.ClassificationTitle = nonSupLineItem.Classification_Title__c;
                    if(nonSupLineItem.Agency_Non_Suppression_Personnel__r.Approval_Status__c =='Pending Review' || nonSupLineItem.Agency_Non_Suppression_Personnel__r.Approval_Status__c == 'Rejected') {
                        item.SalaryRate = String.valueOf(nonSupLineItem.Revised_Rate__c);
                    } else {
                        item.SalaryRate = String.valueOf(nonSupLineItem.Current_Rate__c);
                    }
                    item.Overtime = 'Yes';//isovertime;
                    item.PortaltoPortal = isPTP;
                    /*item.Overtime = 'No';
                    if(nonSupLineItem.MOU_MOA_GBR__c) {
                        item.PortaltoPortal = 'Yes';
                    } else {
                        item.PortaltoPortal = 'No';
                    }*/
                    salarayAndNonSuppPersonelList.add(item);
                }
            }
        } catch (Exception e) {
           if(!Test.isRunningTest()) throw new AuraHandledException(e.getMessage());
        }
      return salarayAndNonSuppPersonelList;
    }
    public static List<Agency_Non_Suppression_Line_Item__c> getNonsupressionItems(String accountId, Date dayOfRecord){
        List<Agency_Non_Suppression_Line_Item__c> items = new List<Agency_Non_Suppression_Line_Item__c>();
        try {
            String parentId;
            List<Agency_Non_Suppression_Personnel__c> parentRecords = [SELECT Id, Approval_Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Non_Suppression_Personnel__c
                                                    WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];
          
                if(!parentRecords.isEmpty()) {  
                    parentId = parentRecords[0].Id;   

                    items = [SELECT Id, Name, Classification_Title__c,Current_Rate__c, Revised_Rate__c,MOU_MOA_GBR__c,
                                                                      Agency_Non_Suppression_Personnel__r.Approval_Status__c
                                                                      FROM Agency_Non_Suppression_Line_Item__c WHERE Agency_Non_Suppression_Personnel__c = :parentId];
              
               
            }
        } catch (Exception e) {
            if(!Test.isRunningTest())  throw new AuraHandledException(e.getMessage());
        }
        return items;
    }
    public static List<Agency_Special_Equipment_Line_Item__c> getSpecialEquipmentItems(String accountId, Date dayOfRecord){
        List<Agency_Special_Equipment_Line_Item__c> items = new List<Agency_Special_Equipment_Line_Item__c>();
        try {
            String parentId;
            List<Agency_Special_Equipment__c> parentRecords = [SELECT Id, Approval_Status__c, Start_Date__c , End_Date__c
                                                    FROM Agency_Special_Equipment__c
                                                    WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord))
                                                    order by Start_Date__c desc 
                                                    LIMIT 1];
         
                                                            
            if(!parentRecords.isEmpty()) {  
                parentId = parentRecords[0].Id;    

             
                items = [SELECT Id, Name, Special_Equipment_Type__c,FEMA_CODE__c, Current_Rate__c, Revised_Rate__c, Description__c,
                        Agency_Special_Equipment__r.Start_Date__c, Agency_Special_Equipment__r.Approval_Status__c,
                        Agency_Special_Equipment__r.Reject_Reason__c, Agency_Special_Equipment__r.End_Date__c,
                        Agency_Special_Equipment__r.CreatedBy.LastName, Agency_Special_Equipment__r.CreatedBy.FirstName,Agency_Special_Equipment__c
                        FROM Agency_Special_Equipment_Line_Item__c 
                        WHERE Agency_Special_Equipment__c = :parentId];
          
                              
            }
        } catch (Exception e) {
            if(!Test.isRunningTest())  throw new AuraHandledException(e.getMessage());
        }
        return items;  
    }
    public static Map<String, List<Agency_Rate_Agreement_Line_Item__c>> getAgreementLineItemMap(String accountId,Date dayOfRecord) {
        Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = new Map<String, List<Agency_Rate_Agreement_Line_Item__c>>();
        for (Agency_Rate_Agreement_Line_Item__c eachRecord :
        [ SELECT Id, Name, OT__c,
                PTP__c FROM Agency_Rate_Agreement_Line_Item__c Where
                Agency_Rate_Agreement__r.Agency__c =:accountId AND Agency_Rate_Agreement__r.Approval_Status__c IN ('Approved','Revised','Expired')
                AND (Agency_Rate_Agreement__r.Start_Date__c <= :dayOfRecord and (Agency_Rate_Agreement__r.END_Date__c = null or Agency_Rate_Agreement__r.End_Date__c >= :dayOfRecord))]) {
            for (String name : eachRecord.Name.split(';')) {
                if(agencyAgreementMap.get(name) == null) {
                    agencyAgreementMap.put(name, new List<Agency_Rate_Agreement_Line_Item__c>());
                }
                agencyAgreementMap.get(name).add(eachRecord);
            }
        }
        return agencyAgreementMap;
    }
    public static String getAdminLineItems(string accountId, Date dayOfRecord){
        String adminRate;
        try { 
            List<Agency_Admin_Rates__c> adminRateList = [SELECT Id, Approval_Status__c, Administrative_Rate_Indirect_Cost_Direct__c
                                                    FROM Agency_Admin_Rates__c WHERE Agency__c = :accountId
                                                    AND Approval_Status__c != 'Rejected' AND (NOT Approval_Status__c LIKE '%Pending%')
                                                    AND (Start_Date__c <= :dayOfRecord and (END_Date__c = null or End_Date__c >= :dayOfRecord)) order by Start_Date__c desc LIMIT 1];
        

            if(!adminRateList.isEmpty()) {  
                if(adminRateList[0].Administrative_Rate_Indirect_Cost_Direct__c != null)
                    adminRate = String.valueOf(adminRateList[0].Administrative_Rate_Indirect_Cost_Direct__c);
                else 
                    adminRate ='Not found';
            }else{
                adminRate ='Not found';
            }
        } catch (Exception e) {
            if(!Test.isRunningTest())  throw new AuraHandledException(e.getMessage());
        }
        return adminRate;
    }

    public class SalaryAndNonSuppresionPersonnel{
        @AuraEnabled
        public String ClassificationTitle{get;set;}
        @AuraEnabled
        public String SalaryRate{get;set;}
        @AuraEnabled
        public String Overtime{get;set;}
        @AuraEnabled
        public String PortaltoPortal{get;set;}
    }
}