/**
 * Created by Pankaj on 15-04-2021.
 */

public without sharing class MARS_AdministrativeRateCtrl {
    @AuraEnabled(cacheable = true) 
    public static finalWrapper retrivePrograms(String accountId) {
        System.debug('accountid'+ accountId);
        Boolean isEditable = MARS_SurveyLineItemsDataTableCtrl.getRelationshipStrength(accountId);
        /*List<Agency_Admin_Rates__c> agencyAdminList = [SELECT Id, Start_Date__c,FY_From__c,FY_To__c,Data_For_Use_In__c FROM Agency_Admin_Rates__c WHERE Agency__c =: accountid and Start_Date__c<=:System.today() 
                                                        AND END_Date__c>=:System.today() AND Approval_Status__c!='Expired' LIMIT 1];*/
        List<Agency_Admin_Rates__c> agencyAdminList = [SELECT Id, Start_Date__c,FY_From__c,FY_To__c,Data_For_Use_In__c FROM Agency_Admin_Rates__c WHERE Agency__c =: accountid AND 
                                                        (Approval_Status__c =: MARS_Constants.SURVEY_STATUS_PENDING_REVIEW ) ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1]; 
                system.debug('agencyAdminList: '+agencyAdminList);
            Map<String, Agency_Admin_Line_Items__c> lineItemMap = new  Map<String, Agency_Admin_Line_Items__c>();
                
            List<DataTable> dt = new List<DataTable>();
            finalWrapper fw = new finalWrapper();
                if(!agencyAdminList.isEmpty())
                fw.objParent = agencyAdminList[0];
                //dt.objParent = agencyAdminList[0].id
            if(agencyAdminList.size() > 0) {
                for(Agency_Admin_Line_Items__c eachLineItem : [
                    SELECT Id, Name, Direct__c, Indirect__c, Total__c FROM Agency_Admin_Line_Items__c WHERE Agency_Administrative_Rates__c =: agencyAdminList[0].Id]) {   
                    lineItemMap.put(eachLineItem.Name,eachLineItem);
                }
                //system.assertEquals(1, 0, lineItemMap);
            }
            dt.add(populateAmounts(isEditable, lineItemMap, frameDt('Emergency Medical Services', true, true)));
            dt.add(populateAmounts(isEditable, lineItemMap, frameDt('General Administration', false, true)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Information Technology', false, true)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Logistics/Procurement/Supply/Minor Fire Equipment', false,
                            true)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Public Information Office', false, true)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Telecommunications', false, true)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Arson Investigation', true , false )));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Community Education', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Facilities', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Fire Comm. Center/Dispatch/Comm. & Control Center', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Fire Hazard Reduction Program', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Fleet', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Hazardous Materials Response Program', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Mapping', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Operations', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Prevention', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Training', true , false)));
            dt.add(populateAmounts(isEditable, lineItemMap,frameDt('Urban Search and Rescue', true , false)));
            fw.lstDatatable = dt;
            system.debug('fw.lstDatatable: '+fw.lstDatatable);
            
            List<Agency_Admin_Rates__c> agencyAdminRates = [SELECT Id,Approval_Status__c,Start_Date__c FROM Agency_Admin_Rates__c WHERE Agency__c=:accountId AND Approval_Status__c !='Rejected' ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
            if(agencyAdminRates.size() > 0) {
              fw.objParentForDate = agencyAdminRates[0];
               // boolean ispendingforAppoval = agencyAdminRates[0].Approval_Status__c == 'Pending Review' ? true:false;
                //fw.disableSubmit = ispendingforAppoval;
            } else {
                //fw.disableSubmit = false;
            }

            return fw; 
    }
    private static DataTable populateAmounts(Boolean isEditable ,Map<String, Agency_Admin_Line_Items__c> lineItemMap, DataTable eachObj) {
          if(lineItemMap.containsKey(eachObj.program)) {
              if(eachObj.directeditable) {
                eachObj.direct = lineItemMap.get(eachObj.program).Direct__c;
                eachObj.direct = eachObj.direct != null && Integer.valueOf(eachObj.direct) != 0 ? eachObj.direct : null; 
              }
              if(eachObj.indirecteditable) {
                eachObj.indirect = lineItemMap.get(eachObj.program).Indirect__c;
                eachObj.indirect = eachObj.indirect != null && Integer.valueOf(eachObj.indirect) != 0 ? eachObj.indirect : null; 
              }
              eachObj.total = lineItemMap.get(eachObj.program).Total__c;
              eachObj.total = eachObj.total != null && Integer.valueOf(eachObj.total) != 0 ? eachObj.total : null; 
              
              eachObj.lineItemId = lineItemMap.get(eachObj.program).Id;
              eachObj.isReadOnly = !isEditable;
          }
          return eachObj;
      }

      @AuraEnabled
      public static Boolean createLineItems(String lineItemsString, Id accountId, String effectiveDate, String signatureBlob, String objParentData) {
        List<Agency_Admin_Rates__c> agencyAdminList = [SELECT Id, Start_Date__c, Approval_Status__c FROM Agency_Admin_Rates__c WHERE Agency__c =: accountId AND Approval_Status__c =: MARS_Constants.SURVEY_STATUS_PENDING_REVIEW LIMIT 1];
        Agency_Admin_Rates__c parentData = (Agency_Admin_Rates__c)JSON.deserialize(objParentData, Agency_Admin_Rates__c.class);
        Agency_Admin_Rates__c adminRecord = new Agency_Admin_Rates__c();
        if(agencyAdminList.isEmpty()) {
              adminRecord.Agency__c = accountId;
              adminRecord.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
              adminRecord.Start_Date__c = Date.valueOf(effectiveDate);
              adminRecord.FY_From__c = parentData.FY_From__c;
              adminRecord.FY_To__c = parentData.FY_To__c;
              adminRecord.Name = 'Administrative Rate For Agency ' + System.now().format();
              adminRecord.Data_For_Use_In__c = parentData.Data_For_Use_In__c;
              adminRecord.Administrative_Total_Indirect_Direct__c = parentData.Administrative_Total_Indirect_Direct__c;
              adminRecord.Administrative_Rate_Indirect_Cost_Direct__c = parentData.Administrative_Rate_Indirect_Cost_Direct__c;
              adminRecord.Total_Direct_Amount__c = parentData.Total_Direct_Amount__c;
              adminRecord.Total_Indirect_Amount__c = parentData.Total_Indirect_Amount__c;
          } else{
              adminRecord = agencyAdminList[0];
              adminRecord.FY_From__c = parentData.FY_From__c;
              adminRecord.FY_To__c = parentData.FY_To__c;
              adminRecord.Data_For_Use_In__c = parentData.Data_For_Use_In__c;
              adminRecord.Administrative_Total_Indirect_Direct__c = parentData.Administrative_Total_Indirect_Direct__c;
              adminRecord.Administrative_Rate_Indirect_Cost_Direct__c = parentData.Administrative_Rate_Indirect_Cost_Direct__c;
              adminRecord.Total_Direct_Amount__c = parentData.Total_Direct_Amount__c;
              adminRecord.Total_Indirect_Amount__c = parentData.Total_Indirect_Amount__c;
              delete [SELECT Id FROM Agency_Admin_Line_Items__c WHERE Agency_Administrative_Rates__c=:agencyAdminList[0].Id];
          }
          upsert adminRecord;
          
          List<Agency_Admin_Line_Items__c> lineItemsList = (List<Agency_Admin_Line_Items__c>)JSON.deserialize(lineItemsString, List<Agency_Admin_Line_Items__c>.class);
          System.debug('###: lineItemsList: ' + lineItemsList);
          for(Agency_Admin_Line_Items__c eachItem : lineItemsList) {
            eachItem.Agency_Administrative_Rates__c = adminRecord.Id; 
            eachItem.Effective_Date__c = Date.valueOf(effectiveDate);
            
          }
          insert lineItemsList;
         
          /*if (!agencyAdminList.isEmpty() && agencyAdminList[0].Approval_Status__c == 'Approved'){
              MARSAdministrativeRateHelper.cloneNonSuppressionLineItems(agencyAdminList[0].Id, Date.valueOf(effectiveDate)>System.today(), Date.valueOf(effectiveDate));
          }*/
          if(signatureBlob != null && Test.isRunningTest() == false) {
            SignatureHelper.saveSign(signatureBlob, adminRecord.Id);
          }
          Map<String, String> paramMap = new Map<String, String>();
          paramMap.put('RecordId', adminRecord.Id);
          Flow.Interview.MARS_Administrative_Rate_Submittion_Notify_Internal_People flow1 = new Flow.Interview.MARS_Administrative_Rate_Submittion_Notify_Internal_People( paramMap );
          flow1.start();
          return true;
    }
  
   public static DataTable frameDt(String pg, boolean direct, boolean indirect) {
      DataTable dt1 = new DataTable();
      dt1.program = pg;
      dt1.directeditable = direct;
      dt1.indirecteditable = indirect;
      return dt1;
    }
  
   public class DataTable {
     public DataTable() {}
     public DataTable(String program, Decimal indirect, Decimal direct, Decimal total,
                Boolean directeditable, Boolean indirecteditable) {
        this.program = program;
        this.indirect = indirect;
        this.direct = direct;
        this.total = total;
        this.directeditable = directeditable;
        this.indirecteditable = indirecteditable;
      }
      @AuraEnabled public String program {
        get;
        set;
      }
      @AuraEnabled public Decimal indirect {
        get;
        set;
      }
      @AuraEnabled public Decimal direct {
        get;
        set;
      }
      @AuraEnabled public Decimal total {
        get;
        set;
      }
      @AuraEnabled public Boolean directeditable {
        get;
        set;
      }
      @AuraEnabled public Boolean indirecteditable {
        get;
        set;
      }
      @AuraEnabled public Id lineItemId {
        get;
        set;
      }
      @AuraEnabled public Boolean isReadOnly  {
        get;
        set;
      }
        
    }
    public class finalWrapper{
      @AuraEnabled
      public List<Datatable> lstDatatable{get;set;}
      @AuraEnabled
      public Agency_Admin_Rates__c objParent{get;set;}
      @AuraEnabled
      public Agency_Admin_Rates__c objParentForDate{get;set;}
     /* @AuraEnabled
      public Boolean disableSubmit{get;set;}*/
      
    }
}