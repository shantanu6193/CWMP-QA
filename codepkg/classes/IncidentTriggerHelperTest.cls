/**
 * Created by Ricky on 03-08-2021.
 */
@IsTest
public with sharing class IncidentTriggerHelperTest {
    @TestSetup private static void setup() {
        Date startDate = System.today()+1;
        Date EndDate = System.today()+10;
        //Profile and User Test Data...
        Profile pf= [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName=orgId+dateString+RandomId;
        User uu=new User(FirstName = 'ABC',
                LastName = 'XYZ',
                Email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = pf.Id
        );
        insert uu;
        //Program Record Test Data....
        Program__c prP = new Program__c(Name='Test Program Parent');
        insert prP;

        List<Program__c> childProgramList = new List<Program__c>();
        Program__c prC = new Program__c(Name='Test Program Child', Parent_Program__c=prP.Id);
        childProgramList.add(prC);
        insert childProgramList;

        //Incident Record Test Data...
        List<Incident__c> incidentList = new List<Incident__c>();
        Incident__c inc1 = new Incident__c(Name = 'Test Incident FP',Declaration_Number__c = '4456',State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
        incidentList.add(inc1);
        Incident__c inc2 = new Incident__c(Name = 'Test Incident FP', State_Small_Project_Threshold__c=200,Federal_Small_Project_Threshold__c=200);
        incidentList.add(inc2);
        insert incidentList;

        //Account Record Test Data...
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(DUNS__c = '1234', Sub_Recipient_FIPS__c = '090-12345', Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate );
        accountList.add(acc1);
        Account acc2 = new Account(DUNS__c = '1234', Email_Address__c='test@gmail.com',Name ='Test Account' ,Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City, DUNS_Expiration_Date__c =EndDate,FFATAExpirationDate__c =EndDate );
        accountList.add(acc2);
        insert accountList;

        // Incident Sub Recipient Trigger Helper Test Data...
        List<Incident_Subrecipient_Stage__c> stageList = new List<Incident_Subrecipient_Stage__c>();
        Incident_Subrecipient_Stage__c stage1 = new Incident_Subrecipient_Stage__c(Account__c = accountList[0].Id, Incident__c = incidentList[0].Id, Stage__c = ALS_CONSTANTS.PR_Stage_New);
        stageList.add(stage1);
        Incident_Subrecipient_Stage__c stage2 = new Incident_Subrecipient_Stage__c(Account__c = accountList[0].Id, Incident__c = incidentList[1].Id, Stage__c = ALS_CONSTANTS.PR_Stage_New);
        stageList.add(stage2);
        Incident_Subrecipient_Stage__c stage3 = new Incident_Subrecipient_Stage__c(Account__c = accountList[1].Id, Incident__c = incidentList[0].Id, Stage__c = ALS_CONSTANTS.PR_Stage_New);
        stageList.add(stage3);
        Incident_Subrecipient_Stage__c stage4 = new Incident_Subrecipient_Stage__c(Account__c = accountList[1].Id, Incident__c = incidentList[1].Id, Stage__c = ALS_CONSTANTS.PR_Stage_New);
        stageList.add(stage4);

        insert stageList;
    }

    @IsTest
    public static void testIncidentTriggerHelper() {
        List<Incident__c> incidentList = [SELECT Id, Name, Declaration_Number__c  FROM Incident__c];
        List<Account> accountList = [SELECT Id, Name, Sub_Recipient_FIPS__c FROM Account];

        incidentList[0].Declaration_Number__c = null;
        incidentList[1].Declaration_Number__c = null;
        update incidentList;

        accountList[0].Sub_Recipient_FIPS__c = null;
        accountList[1].Sub_Recipient_FIPS__c = null;
        update accountList;


        incidentList[0].Declaration_Number__c = '4485';
        incidentList[1].Declaration_Number__c = '4485';
        update incidentList;

        accountList[0].Sub_Recipient_FIPS__c = '090-56789';
        accountList[1].Sub_Recipient_FIPS__c = '090-56789';
        update accountList;
    }
}