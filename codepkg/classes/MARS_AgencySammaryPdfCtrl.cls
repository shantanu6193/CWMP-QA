public without sharing class MARS_AgencySammaryPdfCtrl {
    public String selectedDate {get; set;}
    public String agencyId {get; set;}
    public List<MARS_AgencySummaryCtrl.SalaryAndNonSuppresionPersonnel> salarySurveyLineItems {get; set;}
    public List<Agency_Special_Equipment_Line_Item__c> specialEquipmentLineItem {get; set;}
    public String adminRate {get; set;}
    public Account accRecord {get; set;}
    public Datetime currentDateTime { get;set;}
    public MARS_AgencySammaryPdfCtrl() {
        Datetime now = Datetime.now(); 
        Integer offset = UserInfo.getTimezone().getOffset(now); 
        currentDateTime = now.addSeconds(offset/1000);
        agencyId = ApexPages.currentPage().getParameters().get('id');
        selectedDate = ApexPages.currentPage().getParameters().get('date');
        Date dateValue = Date.valueOf(selectedDate);
        if(agencyId != null && selectedDate != null) {
            salarySurveyLineItems = MARS_AgencySummaryCtrl.getSalarySurveyItems(agencyId,dateValue);
            specialEquipmentLineItem = MARS_AgencySummaryCtrl.getSpecialEquipmentItems(agencyId, dateValue);
            adminRate = MARS_AgencySummaryCtrl.getAdminLineItems(agencyId, dateValue); 
            accRecord = getAgencyInfo(agencyId);
        }
        selectedDate = dateValue.format();
    }
    private static Account getAgencyInfo(String accountId) {
        Account accRecord = [SELECT Id,DUNS__c,Fiscal_Supplier_ID__c,Federal_Tax_ID__c,Fiscal_Address_Id__c,
                            MACS_ID__c,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,ShippingStreet,
                            ShippingCity,ShippingState,ShippingPostalCode,Chief_Name__c,Chief_Email__c,
                            Department_Email__c,Phone FROM Account WHERE Id=:accountId];
        return accRecord;
    }
}