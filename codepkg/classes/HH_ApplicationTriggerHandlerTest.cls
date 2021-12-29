/**
 * Created by Ricky on 31-08-2021.
 */

@IsTest(SeeAllData=true)
public without sharing class HH_ApplicationTriggerHandlerTest {
    @IsTest
    public static void testHH_ApplicationTriggerHandler() {
        Id homeownerId = null;
        Contact homeownerContact  =null;
        Id communityUserId = null;
        User caloesInternalUser = HH_TestHelper.createCaloesUser();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            User homeowner = HH_TestHelper.createCaloesPortalUser('homeowner@xyz.com');
            System.debug('homeowner'+homeowner);
            homeownerId = homeowner.Id;
            User communityUser = HH_TestHelper.createCaloesPortalUser('community@xyz.com');
            communityUserId = communityUser.Id;
            Contact c = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Id=:homeowner.ContactId];
            System.debug('Contact'+c);
            c.Is_Mailing_Address_Different__c = 'No';
            c.Is_Physical_Address_a_Foreign_Address__c = 'No';
            c.Preferred_Language__c = 'English';
            c.Physical_City__c = 'Napa';
            c.Physical_State__c = 'California';
            c.Physical_Country__c = 'UNITED STATES OF AMERICA';
            c.Physical_Street__c = 'Roosevelt Road';
            c.Physical_Zip_Postal_Code__c = '5234462';
            c.Phone = '1234567890';
            c.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Homeowner;
            update c;
            homeownerContact = c;
           
            List<County_Config__mdt> hhCountyConfigs = [SELECT Label, DeveloperName,
                                                     Application_Type__c, Queue_API_Name__c,Public_Group_API_Name__c 
                                                     FROM County_Config__mdt 
                                                     WHERE Application_Type__c =:HH_CONSTANTS.HH_Application_APIName_CountyConfig 
                                                     AND Label =:HH_CONSTANTS.HHApplication_County_SanDiego];
            List<String> groupsToShare = new List<String>();
            groupsToShare.add(hhCountyConfigs.get(0).Queue_API_Name__c);
            groupsToShare.add(hhCountyConfigs.get(0).Public_Group_API_Name__c);
            groupsToShare.add(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName);
            List<Group> customGroups = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN:groupsToShare];
            List<GroupMember> memberstoAdd = new List<GroupMember>();
            for (Group grp : customGroups) {
                if(grp.DeveloperName != HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName) {
                    GroupMember member1 = new GroupMember(UserOrGroupId=communityUserId,GroupId=grp.Id);
                    memberstoAdd.add(member1);
                }
                GroupMember member2 = new GroupMember(UserOrGroupId=caloesInternalUser.Id,GroupId=grp.Id);
                memberstoAdd.add(member2);
            }
            insert memberstoAdd;
        }


        PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = homeownerId, PermissionSetId = permissionSet.Id);
        PermissionSet permissionSet2 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUserId, PermissionSetId = permissionSet2.Id);
     
        Test.startTest();
        HH_Application__c hhApplication1 = null;
        System.runAs(new User(Id=homeownerId)){
            hhApplication1 = new HH_Application__c(Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft,
                Agreement_Disclosure__c = false,
                County__c = HH_CONSTANTS.HHApplication_County_SanDiego , Applicant__c = homeownerContact.Id);
                insert hhApplication1;
            hhApplication1.Applicant__r = homeownerContact;
        }
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<Document__c> docToInsertList = new List<Document__c>();
            Document__c doc1 = new Document__c(HH_Application__c = hhApplication1.Id, Document_Name__c = HH_CONSTANTS.Document_DocumentType_HomeAssessmentReport, Document_Type__c = HH_CONSTANTS.Document_DocumentType_HomeAssessmentReport);
            docToInsertList.add(doc1);
            Document__c doc2 = new Document__c(HH_Application__c = hhApplication1.Id, Document_Name__c = HH_CONSTANTS.Document_DocumentType_EnvironmentalChecklist, Document_Type__c = HH_CONSTANTS.Document_DocumentType_EnvironmentalChecklist);
            docToInsertList.add(doc2);
            insert docToInsertList;

            List<Document__c> docList = [SELECT Id,Stage__c, Document_Type__c,Is_Required__c,Status__c,Date_Uploaded__c FROM Document__c WHERE HH_Application__c =: hhApplication1.Id];
        System.debug('Total Documents: '+docList);

        for(Document__c doc : docList) {
                if (doc.Document_Type__c != HH_CONSTANTS.Document_DocumentType_Rental) {
                ContentVersion contentVersion = new ContentVersion(
                                                Title          = 'a picture',
                                                PathOnClient   = 'Pic.jpg',
                                                VersionData    = Blob.valueOf('Test Content'),
                                                IsMajorVersion = true);
                insert contentVersion;
                ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVersion.Id];
                ContentDocumentLink contentlink=new ContentDocumentLink();
                contentlink.ShareType= 'I';
                contentlink.LinkedEntityId = doc.Id; 
                contentlink.ContentDocumentId=testcontent.ContentDocumentId;
                contentlink.Visibility = 'AllUsers'; 
                insert contentlink;              
        }
            }
        for(Document__c doc : docList) {
                if (doc.Document_Type__c != HH_CONSTANTS.Document_DocumentType_Rental) {
                doc.Stage__c = HH_CONSTANTS.Document_Stage_Uploaded;
                doc.Status__c = HH_CONSTANTS.Document_Status_Active;
        }
            }
        update docList;
        }

        System.runAs(new User(Id=homeownerId)){
            Map<String,Object> getRecordMap  = HH_ApplicationCtrl.getApplicationRecord(hhApplication1.Id);
            hhApplication1 =(HH_Application__c) getRecordMap.get('application');
            hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        hhApplication1.Submission_Date__c = System.now();
        hhApplication1.Tax_Parcel_Number__c = '123455';
        hhApplication1.Is_the_property_in_the_floodplain__c = HH_CONSTANTS.PickList_Yes;
        hhApplication1.Agreement_Disclosure__c = true;
        hhApplication1.County__c = HH_CONSTANTS.HHApplication_County_SanDiego;
            hhApplication1.Rental_Property__c = 'Yes';
            hhApplication1.Currently_Occupied__c = 'No';
            hhApplication1.Agreement_Disclosure__c = true;
            update hhApplication1;
            String updateAppJson = JSON.serialize(hhApplication1);
            HH_ApplicationCtrl.saveApplication(updateAppJson,'', true,'ApplicantInfo');
            getRecordMap  = HH_ApplicationCtrl.getApplicationRecord(hhApplication1.Id);
            hhApplication1 =(HH_Application__c) getRecordMap.get('application');
            System.debug('Stage: '+hhApplication1.Stage__c);
            System.debug('OwnerId: '+hhApplication1.OwnerId);
            hhApplication1.Currently_Occupied__c = 'No';
            try{
        update hhApplication1;
            } catch(Exception e) {
                System.debug('he: '+e);
            }
            
        }



        System.debug('Application Submitted');
        System.runAs(new User(Id=communityUserId)){
        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
        hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress;
        hhApplication1.Tax_Parcel_Number__c = '123455';
        hhApplication1.Is_the_property_in_the_floodplain__c = HH_CONSTANTS.PickList_Yes;
        hhApplication1.Agreement_Disclosure__c = true;
            hhApplication1.Application_Lead__c = communityUserId;
            hhApplication1.Income_Bracket__c = '< 80%';
            hhApplication1.Assessed_Value_of_the_Property__c = 1400000;
        update hhApplication1;
            try{
                delete hhApplication1;
            } catch(Exception e) {
                System.debug('e'+e);
            }

        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityDecision;
        hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria;
        hhApplication1.Community_Rejection_Reason__c = 'Sample Reason';
        update hhApplication1;
        
        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
        hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_AppealApprovalResubmit;
        update hhApplication1;

            // hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
            // hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_CommunityReviewInProgress;
            // update hhApplication1;

        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityDecision;
        hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_ApprovedForAssessment;
        hhApplication1.Assessor_Email__c = 'Sample@gmail.com';
        update hhApplication1;

        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
            //hhApplication1.Status__c = null;
        update hhApplication1;

            // hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_Assessment;
            // hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_AssessmentComplete;
            // update hhApplication1;

        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_AssessmentDecision;
        hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_ReadyForCalOesReview;
        update hhApplication1;
        }

        System.runAs(caloesInternalUser){
        hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESReview;
        hhApplication1.Status__c = null;
        update hhApplication1;

            // Request_For_Information__c rfiRecord = new Request_For_Information__c(CWMP_Application__c = hhApplication1.Id, RFI_Deadline__c = System.today()+1, RecordTypeId = Schema.SObjectType.Request_For_Information__c?.getRecordTypeInfosByDeveloperName()?.get(HH_CONSTANTS.Rfi_CWMPRecordType_APIName)?.getRecordTypeId(), Status__c = HH_CONSTANTS.RFI_RFIStatus_Requested);
            // insert rfiRecord;
    
//            hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_OESDecision;
//            hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_ApprovedForFEMAReview;
//            update hhApplication1;
        }



        // try {
        //     hhApplication1.Stage__c = HH_CONSTANTS.HHApplication_Stage_FEMAReview;
        //     hhApplication1.Status__c = HH_CONSTANTS.HHApplication_Status_FEMAReviewPending;
        //     update hhApplication1;
        // }
        // catch (Exception e){}
        
        // try {
        //     delete hhApplication1;
        // }
        // catch (Exception e) {
		
        // }
        Test.stopTest();
    }
}