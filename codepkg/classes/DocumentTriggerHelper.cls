/**
 * Created by Ricky 0n 20/11/2020....
 */
public with sharing class DocumentTriggerHelper extends TriggerHelper{
    public override void processAfterInsert(){
        shareDocumentWithCommunityAndCalOES();
    }
    public override void processBeforeUpdate() {
        preventChangingDocumentStatus();
        clearGlobalDocumentsRelatedClonedDates();
    }
    //To prevent changing of Document "Stage" to "Uploaded", until a file is uploaded in it...
    private void preventChangingDocumentStatus() {
        Map<Id, Document__c> idToDocumentMap = new Map<Id, Document__c>();
        for(Document__c doc : (List<Document__c>) Trigger.new) //Iterating Trigger.new of Document Trigger...
        {
            Document__c oldDocRecord = (Document__c )(Trigger.oldMap.get(doc.Id)); //Fetching Old record from Trigger.oldMap collection....
            if((oldDocRecord.Stage__c != doc.Stage__c) && doc.Stage__c == ALS_CONSTANTS.Document_Stage_Uploaded) //Condition to check if the stage is changed to Uploaded...
            {
                idToDocumentMap.put(doc.Id, doc); //Collecting the Document record into a Mao collection.....
            }
        }
        if (idToDocumentMap.size() > 0) { //Checking for null pointer for Exception...
            //Collecting all the contentDocumentLink which has been created for this current Document record...
            Map<Id, Document__c> lstContDocLink = new Map<Id, Document__c>([SELECT Id, Name, (SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLinks) FROM Document__c WHERE Id IN : idToDocumentMap.keySet()]);

            for(Document__c docToProcess : idToDocumentMap.values()) { //Iterating the Document map...
                List<ContentDocumentLink> contentDocLinks = lstContDocLink.get(docToProcess.Id).ContentDocumentLinks; //Fetching the ContentDocumentLick for the Document...
                if(contentDocLinks.isEmpty()) //To check if there is any ContentDocumentLink available, if not then prevent changing stage to Uploaded..
                {
                    docToProcess.addError('Please upload the file to mark the Stage as Uploaded.'); //Displaying the error...
                }
            }
        }
    }
    private void clearGlobalDocumentsRelatedClonedDates() {
        for(Document__c doc : (List<Document__c>) Trigger.new) //Iterating Trigger.new of Document Trigger.
        {
            Document__c oldDocRecord = (Document__c )(Trigger.oldMap.get(doc.Id)); //Fetching Old record from Trigger.oldMap collection.
            if(doc.Global_Document__c == false && oldDocRecord.Global_Document__c == true ){
                doc.ExpirationDate__c = null;
                doc.Date_Of_Signature__c = null;
                doc.Date_Of_Fiscal_Year_End__c = null;
                doc.Approval_Date__c = null;
                doc.Letter_Date__c = null;
            }
        }
    }
//    private void  shareDocumentWithCommunityAndCalOES(){
//        List<Id> hhAppId = new List<Id>();
//        List<Document__c> docList = new List<Document__c>();
//        for(Document__c doc : (List<Document__c>) Trigger.new) //Iterating Trigger.new of Document Trigger.
//        {
//            if(doc.hh_Application__c !=null){
//                hhAppId.add(doc.hh_Application__c);
//                docList.add(doc);
//            }
//        }
//        if(hhAppId.size()>0){
//            Map<Id,HH_Application__c> hhApplicationsIdToHHProcess = new Map<Id,HH_Application__c>([SELECT Id,County__c,stage__c,(SELECT Id,HH_Application__c from Documents__r) from HH_Application__c WHERE  Id IN :hhAppId AND stage__c !='draft']);
//            Map<String,Group> groupNameToGroupMap = new Map<String, Group>();
//
//            if(hhApplicationsIdToHHProcess.size()>0){
//                List<County_Config__mdt> CountyConfig = County_Config__mdt.getall().values();//Get Records from Global Document Configuration Metadata
//                Map<String,County_Config__mdt> labelToCountyMp = new Map<String, County_Config__mdt>();
//                for(County_Config__mdt cc:CountyConfig){
//                    labelToCountyMp.put(cc.label,cc);
//                }
//
//                Set<String> groupsAPINames = new Set<String>();
//                for(HH_Application__c hhApplication: hhApplicationsIdToHHProcess.values()) {
//                        groupsAPINames.add(labelToCountyMp?.get(hhApplication?.County__c)?.Public_Group_API_Name__c);
//                        groupsAPINames.add(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName);
//                }
//                List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName IN :groupsAPINames AND Type != 'Queue'];
//                if(groups?.size() >0){
//                    for (Group gp : groups) {
//                        groupNameToGroupMap.put(gp.DeveloperName, gp);
//                    }
//                }
//
//                List<Document__Share> dShares = new List<Document__Share>();
//                for(HH_Application__c hhApplication: hhApplicationsIdToHHProcess.values()) {
//                    for (Document__c docs : hhApplication.Documents__r) {
//                        Document__Share dShare = new Document__Share(ParentId = docs.Id, UserOrGroupId = groupNameToGroupMap.get(labelToCountyMp?.get(hhApplication?.County__c)?.Public_Group_API_Name__c).Id, AccessLevel = 'Edit', RowCause = Document__Share.RowCause.HH_Document__c);
//                        dShares.add(dShare);
//                        if(hhApplication.county__c !=null){
//                            Document__Share dShare1 = new Document__Share(ParentId = docs.Id, UserOrGroupId = groupNameToGroupMap.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName).Id, AccessLevel = 'Edit', RowCause = Document__Share.RowCause.HH_Document__c);
//                            dShares.add(dShare1);
//                        }
//                    }
//                }
//                if(dShares.size() >0){
//                    new SystemContextProvider().insertDocumentShares(dShares);
//                }
//            }
//        }
//    }
private void  shareDocumentWithCommunityAndCalOES() {
    List<Document__c> docListToProcess = new List<Document__c>();
    for(Document__c doc : (List<Document__c>) Trigger.new) //Iterating Trigger.new of Document Trigger.
        {
            if(doc.hh_Application__c !=null){
                docListToProcess.add(doc);
            }
        }
    if(docListToProcess.size() >0) {
        shareHHDocuments(docListToProcess);
    }
}

public void shareHHDocuments(List<Document__c> docs) {
    new SystemContextProvider().shareHHDocuments(docs);
}



public  without sharing class SystemContextProvider {

    public void shareHHDocuments(List<Document__c> docs) {
        System.debug('share Documents: '+docs);
        List<String> applicationIds = new List<String>();
        for(Document__c doc : docs) {
            if(doc.HH_Application__c != null) {
                applicationIds.add(doc.HH_Application__c);
            }
        }
        Map<Id,HH_Application__c> appMap = new Map<Id,HH_Application__c> ([SELECT Id,County__c,Applicant__c FROM HH_Application__c WHERE
                                                                      Id IN: applicationIds AND Stage__c !=: HH_CONSTANTS.HHApplication_Stage_Draft
                                                                      AND (Status__c != null OR Status__c !=:HH_CONSTANTS.HHApplication_Status_New)]);
        System.debug('appMaps: '+appMap);
        if (appMap.size()==0) {
            return ;
        }
        List<String> applicantIds = new List<String>();
        List<String> counties = new List<String>();
        for(HH_Application__c app : appMap.values()) {
            applicantIds.add(app.Applicant__c);
            counties.add(app.County__c);
        }
        List<User> users = [SELECT Id,ContactId FROM User WHERE ContactId IN: applicantIds];
        Map<String,String> applicantMap = new Map<String,String>();
        for (User user : users) {
            applicantMap.put(user.ContactId, user.Id);
        }
        List<County_Config__mdt> countyConfigs = [SELECT Id,Label,Public_Group_API_Name__c FROM County_Config__mdt WHERE Label IN:counties];
        Map<String,String> grpAPIToLabelMap = new Map<String,String>();
        for (County_Config__mdt countyConfig : countyConfigs) {
            grpAPIToLabelMap.put(countyConfig.Public_Group_API_Name__c, countyConfig.Label);
        }
        grpAPIToLabelMap.put(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName, 'CalOES');
        grpAPIToLabelMap.put(HH_CONSTANTS.HH_FEMA_User_Group_APIName,'FEMA');
        List<Group> groups = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN :grpAPIToLabelMap.keySet() AND Type != 'Queue'];
        Map<String,String> groupLabelToIdMap = new Map<String,String>();
        for( Group group1 : groups) {
            String identifierName = grpAPIToLabelMap.get(group1.DeveloperName);
            if(identifierName != null) {
                groupLabelToIdMap.put(identifierName,group1.Id);
            }
        }
        System.debug('groupLabelToIdMap: '+ groupLabelToIdMap);
        List<Document__Share> dShares = new List<Document__Share>();
        for (Document__c doc : docs) {
            HH_Application__c app = appMap.get(doc.HH_Application__c);
            String femaGroupId = groupLabelToIdMap.get('FEMA');
            String caloesGroupId = groupLabelToIdMap.get('CalOES');
            String countyGroupId = groupLabelToIdMap.get(app.County__c);
            String userId = applicantMap.get(app.Applicant__c);
            //caloes internal user
            if(caloesGroupId != null) {
                Document__Share dShare = new Document__Share(ParentId=doc.Id, UserOrGroupId=caloesGroupId, AccessLevel='Edit', RowCause = Document__Share.RowCause.HH_Document__c);
                dShares.add(dShare);
            }
            //community user
            if(countyGroupId != null) {
                Document__Share dShare = new Document__Share(ParentId=doc.Id, UserOrGroupId=countyGroupId, AccessLevel='Edit', RowCause = Document__Share.RowCause.HH_Document__c);
                dShares.add(dShare);
            }
            //Homeowner
            if(userId != null) {
                Document__Share dShare = new Document__Share(ParentId=doc.Id, UserOrGroupId=userId, AccessLevel='Edit', RowCause = Document__Share.RowCause.HH_Document__c);
                dShares.add(dShare);
            }
            //fema
            if(femaGroupId != null ) {
                Document__Share dShare = new Document__Share(ParentId=doc.Id, UserOrGroupId=femaGroupId, AccessLevel='Edit', RowCause = Document__Share.RowCause.HH_Document__c);
                dShares.add(dShare);
            }
        }
        System.debug('doc shares: '+dshares);
        if(dShares.size() > 0) {
            insert dShares;
        }
    }

   }

   
}