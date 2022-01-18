/**
 * Created by Chandrabhan on 06-21-2021.
 */
public without sharing class Mars_ReimbursementCtrl {
   /***********************************************
    * Method Name : apexSearchIncident
    * Author : Pankaj
    * Inputs : String searchTerm
    * Description: This method return list of LookupSearchResult from Incident__c
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchIncident(String searchTerm) {
        // Prepare query paramters
        //searchTerm += '*';
        String query = 'Select Id,Name,Declaration_Number__c,Order_No__c From Incident__c Where Name != null AND Available_for_Application__c INCLUDES (\'MARS\')';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR Order_No__c  like\'%' + searchTerm + '%\' )';
            //query += ' AND (Name like\'%' + searchTerm + '%\')';
        }
        query += ' Limit 200';
        system.debug('query===='+query);
        List<Incident__c> incidents = Database.query(query);

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String IncidentIcon = 'standard:account';
        for (Incident__c opProductReference : incidents) {
            results.add(
                new LookupSearchResult(
                        opProductReference.Id,
                        'Incident__c',
                        IncidentIcon,
                        opProductReference.Name,
                        'Order #'+opProductReference.Order_No__c,
                        //(opProductReference.Order_No__c != null ? opProductReference.Order_No__c  : ''),
                        opProductReference
                )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }
    /***********************************************
    * Method Name : getAgencyDetails
    * Author : Chandrabhan
    * Inputs : String agencyId
    * Description: This method return Account info.
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static Account getAgencyDetails(String agencyId) {
        return [SELECT Name, Mars_Agency_Designator__c  FROM Account WHERE Id=:agencyId LIMIT 1];
    }
    /***********************************************
    * Method Name : apexSearchStrikeTeam
    * Author : Chandrabhan
    * Inputs : String searchTerm, String incidentId
    * Description: This method return list of LookupSearchResult from F42__c
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchStrikeTeam(String searchTerm, String incidentId) {
        System.debug('incidentId=='+incidentId +'  searchTerm=='+searchTerm);
        // Prepare query paramters
        String query = 'Select Id,Name,Strike_Team__c,Incident_Request_Number__c,ER_UNIT__c From F42__c Where Incident__c =: incidentId';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND (Strike_Team__c like\'%' + searchTerm + '%\')';
        }
        query += ' Limit 200';
        system.debug('query===='+query);
        List<F42__c> f42Records = Database.query(query);

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        Set<String> uniqueSet = new Set<String>();
        String IncidentIcon = 'standard:account';
        for (F42__c f42Reference : f42Records) {
            if(!uniqueSet.contains(f42Reference.Strike_Team__c)) {
                results.add(
                    new LookupSearchResult(
                        f42Reference.Id,
                        'F42__c',
                        IncidentIcon,
                        f42Reference.Strike_Team__c,
                        '',
                        f42Reference
                    )
                );
                uniqueSet.add(f42Reference.Strike_Team__c);
            } 
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    } 
    @AuraEnabled
    public static void createReimbursementRecord(String lineItemsString, String objParentData, String signatureBlob, String fileUpdateWrapper) {
        Reimbursement__c reimbursementRecord = (Reimbursement__c)JSON.deserialize(objParentData, Reimbursement__c.class);
        List<F42__c> f42Record = [SELECT Id,Name FROM F42__c WHERE  Incident__c =: reimbursementRecord.Incident__c AND ER_UNIT__c =: reimbursementRecord.Unit_Number__c AND Strike_Team__c =: reimbursementRecord.Strike_Team__c
                                  AND  Incident_Request_Number__c =: reimbursementRecord.Incident_Request_Number__c AND Account__c =: reimbursementRecord.Account__c ORDER BY CreatedDate DESC LIMIT 1];
        //reimbursementRecord.Name = 'Expense Claim ' + System.now().format();
        
        if(f42Record.size() > 0) {
            reimbursementRecord.F_42__c = f42Record[0].Id;
        }
        reimbursementRecord.Status__c = 'CALOES Review';
        System.debug('reimbursementRecord=='+reimbursementRecord);
        insert reimbursementRecord;
        // query the record for MACISD field, it it formula filed
        Reimbursement__c  expenseRecord = [SELECT Id,MACIDs__c,Strike_Team__c,Unit_Number__c FROM Reimbursement__c WHERE Id =:reimbursementRecord.Id];
        String UnitNo = expenseRecord.Unit_Number__c != null ? expenseRecord.Unit_Number__c : '';
        String strikeNo = expenseRecord.Strike_Team__c != null ? expenseRecord.Strike_Team__c : '';
        String MackId = expenseRecord.MACIDs__c != null ? expenseRecord.MACIDs__c : '';
        String fileName = MackId +'-'+strikeNo +'-'+ UnitNo;
        List<Reimbursement_Line_Item__c> lineItemsList = (List<Reimbursement_Line_Item__c>)JSON.deserialize(lineItemsString, List<Reimbursement_Line_Item__c>.class);
        System.debug('###: lineItemsList: ' + lineItemsList);
        for(Reimbursement_Line_Item__c eachItem : lineItemsList) {
          eachItem.Reimbursement__c = reimbursementRecord.Id; 
        }
        upsert lineItemsList;
        
        if(signatureBlob != null) {
            SignatureHelper.saveSign(signatureBlob, reimbursementRecord.Id);
        }
        if(fileUpdateWrapper != null) {
            List<FileUpdateWrapper> fileDocUpdateList = (List<FileUpdateWrapper>)JSON.deserialize(fileUpdateWrapper, List<FileUpdateWrapper>.class);
            if(fileDocUpdateList.size() > 0){
                Map<String,String> cvIdMap = new Map<String,String>();
                for(FileUpdateWrapper fuw : fileDocUpdateList){
                    cvIdMap.put(fuw.contentVersionId,fuw.Type);
                }
                Set<Id> cdIdSet = new Set<Id>();
                List<ContentVersion> cvUpdateList = [SELECT Id,Type__c,ContentDocumentId FROM ContentVersion WHERE Id=:cvIdMap.keySet()];
                for(ContentVersion cvRec : cvUpdateList){
                    cdIdSet.add(cvRec.ContentDocumentId);
                    if(cvIdMap.containsKey(cvRec.Id) && cvRec.Type__c == null){
                        cvRec.Type__c = cvIdMap.get(cvRec.Id);
                        cvRec.Title = fileName;
                    }
                }
                if(!cvUpdateList.isEmpty() && cvUpdateList != null) 
                    update cvUpdateList;
                System.debug('ContentDocumentLink 84==>'+cvUpdateList.size());

                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                List<ContentDocumentLink> cdlExt = new List<ContentDocumentLink>();
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: reimbursementRecord.Account__c AND ContentDocumentId=:cdIdSet]) {
                                                ContentDocumentLink cloned = cdl.clone();
                                                cloned.LinkedEntityId = reimbursementRecord.Id;
                                                cloned.ShareType = cdl.ShareType;
                                                cdlList.add(cloned);
                                                cdlExt.add(cdl);
                                                }
                insert cdlList; // new CDL records
                delete cdlExt; // delete old CDL records
            }
        }
    }
    @AuraEnabled 
    public static void deleteFile(String contentVersionId){
        ContentVersion data = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE  Id=:contentVersionId limit 1];
        ContentDocument cd = new ContentDocument();
        cd.Id = data.ContentDocumentId;
        delete cd;
    }

    public class FileUpdateWrapper {
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
        public String Type{get;set;}
    }
    /***********************************************
    * Method Name : apexSearchUnitNumber
    * Author : Chandrabhan
    * Inputs : String incidentId
    * Description: This method return list of LookupSearchResult from F42__c
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> apexSearchUnitNumber(String incidentId, String strickTeam, String incidentRequestNumber) {
        // Prepare query paramters
        String query = 'SELECT Id,ER_UNIT__c FROM F42__c WHERE Incident__c =: incidentId AND ER_UNIT__c != null ';
        if(String.isNotEmpty(strickTeam)) {
            query += ' AND Strike_Team__c =: strickTeam ';
        }
        if(String.isNotEmpty(incidentRequestNumber)) {
            query += ' AND Incident_Request_Number__c =: incidentRequestNumber ';
        }
        query += ' Limit 200';
        System.debug('Unit number Query='+query);
        List<F42__c> f42Records = Database.query(query);
        List<Map<String, String>> options = new List<Map<String, String>>();
        Set<String> unitNumber = new Set<String>();
        options.add(new Map<String, String>{'value' => '', 'label' => '--Select--'});
        for (F42__c obj : f42Records) {
                if(!unitNumber.contains(obj.ER_UNIT__c)) {
                    options.add(new Map<String, String>{'value' => obj.ER_UNIT__c, 'label' => obj.ER_UNIT__c});
                    unitNumber.add(obj.ER_UNIT__c);
                }
            }
        return options;
    }

        /***********************************************
    * Method Name : apexSearchIncidentRequestNumber
    * Author : Chandrabhan
    * Inputs : String searchTerm, String incidentId
    * Description: This method return list of LookupSearchResult from F42__c
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> apexSearchIncidentRequestNumber(String incidentId, String strickTeam) {
        // Prepare query paramters
        List<Map<String, String>> options = new List<Map<String, String>>();
        Set<String> unitNumber = new Set<String>();
        options.add(new Map<String, String>{'value' => '', 'label' => '--Select--'});
        for (F42__c obj :[SELECT Id,Incident_Request_Number__c FROM F42__c WHERE Incident__c =: incidentId AND Strike_Team__c =: strickTeam]) {
                if(!unitNumber.contains(obj.Incident_Request_Number__c)) {
                    options.add(new Map<String, String>{'value' => obj.Incident_Request_Number__c, 'label' => obj.Incident_Request_Number__c});
                    unitNumber.add(obj.Incident_Request_Number__c);
                }
            }
        return options;
    }
}