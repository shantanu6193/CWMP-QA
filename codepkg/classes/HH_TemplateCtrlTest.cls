@isTest(seeAllData=false)
public class HH_TemplateCtrlTest {

    @isTest 
    public static void testGetUserName() {
        User homeowner = new User();
        User communityUser = new User();
        User femaUser = new User();
        Contact homeownerContact  =null;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            homeowner = HH_TestHelper.createCaloesPortalUser('homeowner@xyz.com');
            System.debug('homeowner'+homeowner);
            communityUser = HH_TestHelper.createCaloesPortalUser('community@xyz.com');
            femaUser = HH_TestHelper.createCaloesPortalUser('fema@xyz.com');
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
                    GroupMember member1 = new GroupMember(UserOrGroupId=communityUser.Id,GroupId=grp.Id);
                    memberstoAdd.add(member1);
                }
            }
            insert memberstoAdd;
        }

        PermissionSet permissionSet =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = homeowner.Id, PermissionSetId = permissionSet.Id);
        PermissionSet permissionSet2 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUser.Id, PermissionSetId = permissionSet2.Id);
		PermissionSet permissionSet3 =  [SELECT Id,Name FROM PermissionSet WHERE Name =: HH_CONSTANTS.HH_PermissionSet_FemaUser_APIName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = communityUser.Id, PermissionSetId = permissionSet3.Id);
        
        Test.startTest();
        System.runAs(homeowner) {
        HH_TemplateCtrl.getUserName();
        }
        System.runAs(communityUser) {
            HH_TemplateCtrl.getUserName();
        }
        System.runAs(femaUser) {
            HH_TemplateCtrl.getUserName();
        }
        //HH_TemplateCtrl.getUserName();
        Test.stopTest();
    }
}