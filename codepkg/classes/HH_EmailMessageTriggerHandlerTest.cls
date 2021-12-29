/**
 * Created by ricky on 09-12-2021.
 */
@IsTest
public with sharing class HH_EmailMessageTriggerHandlerTest {
    @IsTest
    public static void testEmailMessageTriggerHandler() {
        Contact c = new Contact();
        c.FirstName = 'Test FirstName';
        c.LastName = 'Test lastname';
        c.Email = 'testcontact23538476583@gmail.com';
        c.Is_Mailing_Address_Different__c = 'No';
        c.Is_Physical_Address_a_Foreign_Address__c = 'No';
        c.Preferred_Language__c = 'English';
        c.Physical_City__c = 'Napa';
        c.Physical_State__c = 'California';
        c.Physical_Country__c = 'UNITED STATES OF AMERICA';
        c.Physical_Street__c = 'Roosevelt Road';
        c.Physical_Zip_Postal_Code__c = '5234462';
        c.Phone = '1234567890';
        c.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Community;
        insert c;

        HH_Application__c hhApplication1 = new HH_Application__c(Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft,
                Agreement_Disclosure__c = false,
                County__c = HH_CONSTANTS.HHApplication_County_SanDiego ,
                Applicant__c = c.Id);
        insert hhApplication1;

        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'TestfromAddress@gmail.com',
                FromName = 'Test From Name',
                ToAddress = 'TestToAddress@gmail.com',
                Subject = 'Test Email Subject',
                TextBody = 'Test Email Text Body',
                HtmlBody = 'Test Email HTML Body',
                RelatedToId = hhApplication1.Id));
        insert newEmail;
    }
}