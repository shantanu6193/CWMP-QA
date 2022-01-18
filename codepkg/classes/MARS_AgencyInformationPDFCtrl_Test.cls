@isTest
public without sharing class MARS_AgencyInformationPDFCtrl_Test {
    @isTest
    static void testAgencyInformation(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.MACS_ID__c='ABS';
        acc.DUNS__c='196670256';        
        acc.BillingCity='test city';
        acc.BillingPostalCode='95628';
        acc.BillingState='CA';
        acc.BillingStreet='223 billing street';
        acc.Chief_Email__c='testchiefemail@gmail.com';
        acc.Chief_Name__c='chief Begley';
        acc.Department_Email__c='deptemail@gmail.com';
        acc.Department_State__c='CA';
        acc.Federally_Recognized_Tribe__c='No';
        acc.Federal_Fire_Department__c='No';
        acc.Federal_Tax_ID__c='36-4647307';
        acc.Department_of_Defence__c='No';
        acc.Fiscal_Address_Id__c=12345;
        acc.Fiscal_Supplier_ID__c='135259';        
        acc.MARS_IsResponder__c='';
        acc.MARS_Is_Active__c='';
        acc.MARS_Operational_Area__c='';
        acc.MARS_Region__c='2';        
        acc.Phone='(916) 555-1212';    
        acc.ShippingCity='shipping city';
        acc.ShippingPostalCode='95628';
        acc.ShippingState='CA';
        acc.ShippingStreet='123 shipping street';
        acc.SupplierID__c='135259';
        acc.Volunteer__c='No';
        acc.Mars_Agency_Type__c='Combination';
        insert acc;

        PageReference testPage = Page.MARS_AgencyInformationPDF; 
        
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));        
        MARS_AgencyInformationPDFCtrl test=new MARS_AgencyInformationPDFCtrl();
    }
}