/***********************************************************************************************************************************
* Class Name   : MARS_GenerateInvoiceHelper
* Description  : This class for Generate Invoice
* Author       : Chandrabhan
* Created On   : 05/05/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Chandrabhan          05/05/2021      Initial Implementation
**************************************************************************************************************************************/


public without sharing class MARS_GenerateInvoiceHelper {
    /***********************************************
    * Method Name : generateInvoice
    * Author : Pankaj
    * Inputs : List<List<String>> ids
    * Description: This method 
    *********************************************/
    @InvocableMethod(label='Generate Invoice' description='Generate Invoice From F-42s')
    public static void generateInvoice(List<List<String>> ids) {//List<List<F42__c>> ids
        System.debug('F42_RecordIdList===>'+ids);
        System.debug('F42_RecordIdList[]===>'+ids[0]);
        System.debug('Length===>'+ids[0].get(0));
        List<F42__c> f42List = [SELECT Name,Account__c, Account__r.Name,Incident__c, Incident__r.Name, Status__c,SN_LOSS_DAMAGE_CLAIM__c,SN_SUPPLY_NUMBER__c,Strike_Team__c,Incident_Order__c,Incident_Request_Number__c,RA_AGENCY_NAME__c,
                                ER_APPARATUS__c,SV_BEGINNING_ODODMETER__c,PA_Cal_OES_REPRESENTATIVE__c,ER_CDF_OES_VEHICLE__c,DI_COMMITTED_TO_INCIDENT_FORMULA__c,DI_Committed_to_Incident_Date__c,DI_Committed_to_Incident_Time__c,
                                PA_CALOESREP_DATE__c,PA_DATE__c,DF_Dispatch_From_End_Date__c,DT_Dispatch_To_Start_Date__c,SV_ENDING_ODOMETER__c,F42_Entry__c,ER_FEMA_CODES__c,
                                PA_ICS_POSITION_TITLE__c,OH_ICS_Title__c,Incident_Name__c,ER_LICENSE_NUMBER__c,SV_LICENSE__c,DI_Mobilization_Center_Preposition__c,DT_NEW_INCIDENT__c,DT_NEW_INCIDENT_REQUEST__c,DF_OLD_INCIDENT__c,DF_OLD_INCIDENT_REQUEST__c,
                                PA_OTHER__c,OH_OTHER_ICS_TITLE__c,PA_OTHER_POSITION_TITLE__c,OH_OVERHEAD_TYPE__c,PA_PAYING_AGENCY__c,PA_PRINTED_NAME__c,DI_REDISPATCHED__c,DI_Redispatched_Date__c,DI_Redispatched_Time__c,DI_REPORTING_LOCATION__c
                                ,DI_RETURN_FROM_INCIDENT__c,DI_Return_from_Incident_Date__c,DI_Return_from_Incident_Time__c,SV_TOTAL_MILES__c,SV_TYPE__c,ER_TYPE__c,ER_UNIT__c,SV_VEHICLE_OWNERSHIP__c,RA_YOUR_NAME__c,
                                RA_YOUR_PHONE__c,RA_YOUR_TITLE__c  FROM F42__c WHERE Id=:ids[0]];
        System.debug('f42List===>'+f42List);
        Set<Id> f42EntryIdSet = new Set<Id>();  
        for(F42__c frecord : f42List){
            f42EntryIdSet.add(frecord.F42_Entry__c);
        }                      
        List<F42_Entry__c> f42EntryList = [SELECT Name,Account__c, Account__r.Name,Incident__c, Incident__r.Name,JSON__c, Offline_JSON__c,Source__c, Status__c  from F42_Entry__c WHERE  Id=:f42EntryIdSet];
        System.debug('f42EntryList===>'+f42EntryList);
        List<FEMA_Code_LineItem__c> fEMACodeLintItemList =[SELECT Id,Name, Equipment__c, HP__c, Current_Rate__c FROM FEMA_Code_LineItem__c WHERE FEMA_Code__r.Status__c = 'Active'];
        System.debug('fEMACodeLintItemList===>'+fEMACodeLintItemList);
        List<CFAA_Line_Items__c> cFAALineItemList=[SELECT Id, Personnel_Role__c, Straight_Time_Rate__c, Order_No__c,
                                                    CFAA__r.Start_Date__c, CFAA__r.END_Date__c,CFAA__c FROM CFAA_Line_Items__c WHERE CFAA__c != null AND CFAA__r.Start_Date__c <= today AND CFAA__r.END_Date__c >= today AND RecordType.Name = 'Personnel Base Rate' ORDER BY Order_No__c ASC];
        System.debug('cFAALineItemList===>'+cFAALineItemList);
       /* PageReference pr = new PageReference('/apex/GenerateInvoice');
        Blob content = pr.getContent();

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = content;
        cv.IsMajorVersion = true;
        Insert cv;
         
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
         
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = 'a0D35000001OVxuEAG';//record.Incident__c;//
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;*/
    }

    
}