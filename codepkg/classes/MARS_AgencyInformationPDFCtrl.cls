public without sharing class MARS_AgencyInformationPDFCtrl {
    public Datetime currentDateTime { get;set;}
    public Account accRecord {get; set;}
    public String agencyId {get; set;}
    public MARS_AgencyInformationPDFCtrl() {
        Datetime now = Datetime.now(); 
        Integer offset = UserInfo.getTimezone().getOffset(now); 
        currentDateTime = now.addSeconds(offset/1000);
        agencyId = ApexPages.currentPage().getParameters().get('id');
        if(agencyId !=null){
            accRecord = getAgencyInfo(agencyId);
        }
    }

    private static Account getAgencyInfo(String accountId) {
        Account accRecord = [SELECT Id,DUNS__c,BillingAddress,BillingCity,BillingPostalCode,BillingState,BillingStreet,Chief_Email__c,Chief_Name__c,Department_Email__c,Department_State__c,Federally_Recognized_Tribe__c,Federal_Fire_Department__c,Federal_Tax_ID__c,Department_of_Defence__c,Fiscal_Address_Id__c,Fiscal_Supplier_ID__c,MACS_ID__c,MARS_IsResponder__c,MARS_Is_Active__c,MARS_Operational_Area__c,MARS_Region__c,MARS_Combination__c,MARS_Paid__c,MARS_Agency_Type_Other__c,Name,Phone,ShippingAddress,ShippingCity,ShippingPostalCode,ShippingState,ShippingStreet,SupplierID__c,Volunteer__c,Mars_Agency_Type__c FROM Account WHERE Id=:accountId];
        return accRecord;
    }
}