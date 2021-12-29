@isTest
private class MARS_F42Entry_Ctrl_Test {
    @testSetup
    static void createRecData(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        acc.MACS_ID__c = 'OES';
        acc.Entity_Type__c = 'Fire Agency';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'testContact';
        insert con;
        
        Incident__c incid = new Incident__c();
        incid.Name = 'testIncident';
        incid.Available_for_Application__c = 'MARS';
        insert incid;
        
        F42_Entry__c f42Entry = new F42_Entry__c();
        f42Entry.Name = 'testF42Entry';
        f42Entry.Account__c = acc.Id;
        f42Entry.Entered_By__c = con.Id;
        f42Entry.Incident__c = incid.Id;
        f42Entry.Status__c = 'Online Draft';
        insert f42Entry;
        
        ICS_Title__c icsTitle = new ICS_Title__c();
        icsTitle.Name = 'testIcsTitle';
        icsTitle.IsActive__c = true;
        insert icsTitle;
        
        Agency_Special_Equipment__c agenSpEquip = new Agency_Special_Equipment__c();
        agenSpEquip.Name = 'testAgenSpEquip';
        agenSpEquip.Agency__c = acc.Id;
        agenSpEquip.Approval_Status__c = 'Reviewed';
        insert agenSpEquip;
        
        Agency_Special_Equipment_Line_Item__c agenSpEqiLI = new Agency_Special_Equipment_Line_Item__c();
        agenSpEqiLI.Name = 'testAgenSpEqiLI';
        agenSpEqiLI.Agency_Special_Equipment__c = agenSpEquip.Id;
        agenSpEqiLI.Status__c = 'Active';
        agenSpEqiLI.Special_Equipment_Type__c = 'testLI';
        insert agenSpEqiLI;
        
        Agency_Salary_Survey__c agenSalSur = new Agency_Salary_Survey__c();
        agenSalSur.Name = 'testAgenSalSur';
        agenSalSur.Account__c = acc.Id;
        agenSalSur.Status__c = 'Reviewed';
        insert agenSalSur;
        
        Salary_Survey_Line_Items__c salSurLI = new Salary_Survey_Line_Items__c();
        salSurLI.Agency_Salary_Survey__c = agenSalSur.Id;
        salSurLI.Classification_Title__c = 'chiefTest';
        insert salSurLI;
        
        Agency_Non_Suppression_Personnel__c agNonSupPer = new Agency_Non_Suppression_Personnel__c();
        agNonSupPer.Name = 'testAgNonSupPer';
        agNonSupPer.Agency__c = acc.Id;
        agNonSupPer.Approval_Status__c = 'Reviewed';
        insert agNonSupPer;
        
        Agency_Non_Suppression_Line_Item__c agNonSupPerLI = new Agency_Non_Suppression_Line_Item__c();
        agNonSupPerLI.Agency_Non_Suppression_Personnel__c = agNonSupPer.Id;
        agNonSupPerLI.Classification_Title__c = 'chiefTest';
        insert agNonSupPerLI;
        
        Agency_Rate_Agreement__c agRateAgr = new Agency_Rate_Agreement__c();
        agRateAgr.Agency__c = acc.Id;
        agRateAgr.Name = 'testAgRateAgr';
        agRateAgr.Approval_Status__c = 'Approved';
        insert agRateAgr;
        
        Agency_Rate_Agreement_Line_Item__c agRateAgrLI = new Agency_Rate_Agreement_Line_Item__c();
        agRateAgrLI.Agency_Rate_Agreement__c = agRateAgr.Id;
        agRateAgrLI.Name = 'testAgRateAgrLI';
        agRateAgrLI.PTP__c = true;
        insert agRateAgrLI;
        
        FEMA_Code__c femaCode = new FEMA_Code__c();
        femaCode.Status__c = 'Active';
        insert femaCode;
        
        FEMA_Code_LineItem__c femaCodeLI = new FEMA_Code_LineItem__c();
        femaCodeLI.FEMA_Code__c = femaCode.Id;
        femaCodeLI.Equipment__c = 'testfemaCodeLI';
        insert femaCodeLI;
    }
    
    
    
    @isTest
    static void test(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'testAccount' LIMIT 1];
        String agencyId = acct.Id;
        List<String> accLst = new List<String>();
        accLst.add(acct.Id);
        
        Incident__c incident = [SELECT Id, Name FROM Incident__c WHERE Name = 'testIncident' LIMIT 1];
        List<String> selId = new List<String>();
        selId.add(incident.Id);
        
        F42_Entry__c f42Entry = [SELECT Id FROM F42_Entry__C WHERE Name = 'testF42Entry' LIMIT 1];
        String entryId = f42Entry.Id;
        
        Agency_Special_Equipment__c agenSpEquip = [SELECT Id FROM Agency_Special_Equipment__c WHERE Name = 'testAgenSpEquip' LIMIT 1];
        Agency_Special_Equipment_Line_Item__c agenSpEquipLI = [SELECT Id FROM Agency_Special_Equipment_Line_Item__c WHERE Name = 'testAgenSpEqiLI' LIMIT 1];
        List<String> agSpEqId = new List<String>();
        agSpEqId.add(agenSpEquipLI.Id);
        
        ICS_Title__c icsTitle = [SELECT Id FROM ICS_Title__c WHERE Name = 'testIcsTitle' LIMIT 1];
        List<String> icsIdLst = new List<String>();
        icsIdLst.add(icsTitle.Id);
        
        Salary_Survey_Line_Items__c salSurveyLI = [SELECT Id FROM Salary_Survey_Line_Items__c WHERE Classification_Title__c = 'chiefTest' LIMIT 1];
        List<String> salSurLst = new List<String>();
        salSurLst.add(salSurveyLI.Id);
        
        FEMA_Code_LineItem__c femaCodeLI = [SELECT Id FROM FEMA_Code_LineItem__c WHERE Equipment__c = 'testfemaCodeLI' LIMIT 1];
        List<String> femaLst = new List<String>();
        femaLst.add(femaCodeLI.Id);
        
        List<PersonnelInfo> perInfo = new List<PersonnelInfo>();
        PersonnelInfo perWrapper = new PersonnelInfo();
        perWrapper.fullName = 'testing';
        perWrapper.MACSID = 'OES';
        perWrapper.jobTitle = 'test';
        perWrapper.ssn = '1234';
        perWrapper.startDate = Date.today();
        perWrapper.startTime = '08:00';
        perWrapper.endDate = Date.today().addDays(10);
        perWrapper.endTime = '20:00';
        perWrapper.cdf = false;
        perWrapper.p2p = false;
        perWrapper.p2pDisabled = false;
        perWrapper.base = 'test';
        perWrapper.editable = false;
        perWrapper.readOnly = true;
        perInfo.add(perWrapper);
        
        List<PersonnelInfo> perInfoLst = new List<PersonnelInfo>();
        PersonnelInfo othPerWrapper = new PersonnelInfo();
        othPerWrapper.fullName = 'test';
        othPerWrapper.MACSID = 'OES';
        othPerWrapper.jobTitle = 'testing';
        othPerWrapper.ssn = '1234';
        othPerWrapper.startDate = System.today();
        othPerWrapper.startTime = '08:00';
        othPerWrapper.endDate = System.today() + 10;
        othPerWrapper.endTime = '20:00';
        othPerWrapper.cdf = false;
        othPerWrapper.p2p = false;
        othPerWrapper.p2pDisabled = false;
        othPerWrapper.base = 'test';
        othPerWrapper.editable = false;
        othPerWrapper.readOnly = true;
        perInfoLst.add(othPerWrapper);
        
        List<ActualHours> ahLst = new List<ActualHours>();
        ActualHours ah = new ActualHours();
        ah.dayOfHours = Date.today();
        ah.startTime = '08:00';
        ah.endTime = '20:00';
        ah.totalHours = 12.0;
        ahLst.add(ah);
        
        List<CommentWrapper> commWrapLst = new List<CommentWrapper>();
        CommentWrapper commWrap = new CommentWrapper();
        commWrap.dateofComment = Date.today();
        commWrap.timeofComment = '12:00';
        commWrap.comment = 'test';
        commWrapLst.add(commWrap);
        
        F42EntryWrapper wrapper = new F42EntryWrapper();
        wrapper.f42Id = f42Entry.Id;
        wrapper.agency = acct;
        wrapper.strikeTeam = '22132';
        wrapper.incident = incident;
        wrapper.incidentRequestNumber = '';
        wrapper.dispatchInfoIncident = incident;
        wrapper.personnelInfoList = perInfo;
        wrapper.otherpersonnelInfoList = perInfoLst;
        wrapper.actualHoursList = ahLst;
        wrapper.comments = commWrapLst;
        wrapper.DI_reportingLocation = 'California';
        wrapper.DI_committedtoIncident = System.today() - 10;
        wrapper.DI_returnfromIncident = System.today();
        wrapper.dispatchFromIncident = incident;
        wrapper.dispatchToIncident = incident;
        wrapper.OH_icsTitle = icsTitle;
        wrapper.ER_specialEquipment = agenSpEquipLI;
        wrapper.ER_cdfoesVehicle = 'Yes';
        String data = JSON.serialize(wrapper);
        
        MARS_F42Entry_Ctrl.getDraftF42Entries(acct.Id);
        MARS_F42Entry_Ctrl.disregardF42Entry(entryId, acct.Id);
        MARS_F42Entry_Ctrl.initializeWrapper(acct.Id, '');
        MARS_F42Entry_Ctrl.saveWrapper(data, 'test', 'test', 'Save');
        try {
        	MARS_F42Entry_Ctrl.saveWrapper(data, 'test1', 'test2', 'Cancel');
        } catch(Exception e) {
            
        }
        MARS_F42Entry_Ctrl.apexSearchIncident('test', selId);
        MARS_F42Entry_Ctrl.apexSearchIcsTitle('testIcsTitle', icsIdLst);
        MARS_F42Entry_Ctrl.apexSearchSpecialEquipment('testLI',  agSpEqId, agencyId);
        MARS_F42Entry_Ctrl.apexSearchRank('chiefTest', salSurLst, 'OES');
        MARS_F42Entry_Ctrl.apexSearchFireAgency('OES', accLst);
        MARS_F42Entry_Ctrl.apexSearchFemaCode('testfemaCodeLI', femaLst);
    }
    
    public class F42EntryWrapper{   
        @AuraEnabled
        public string           f42Id{get; set;}
        @AuraEnabled
        public User             loggedinUser {get; set;}
        @AuraEnabled
        public Account          agency{get;set;}
        @AuraEnabled
        public string           strikeTeam{get;set;}
        @AuraEnabled
        public Incident__c      incident{get;set;}
        @AuraEnabled
        public string           incidentRequestNumber{get;set;}
        @AuraEnabled
        public Incident__c      dispatchInfoIncident{get;set;}
        @AuraEnabled
        public string           DI_reportingLocation {get; set;}
        @AuraEnabled
        public date             DI_committedtoIncident {get; set;}
        @AuraEnabled
        public string           DI_committedtoIncidentTime {get; set;}
        @AuraEnabled
        public date             DI_returnfromIncident {get; set;}
        @AuraEnabled
        public string           DI_returnfromIncidentTime {get; set;}
        @AuraEnabled
        public date             DI_reDispatched{get; set;}
        @AuraEnabled
        public string           DI_reDispatchedTime{get; set;}
        @AuraEnabled
        public string           DI_mobilizationCenter {get; set;}
        @AuraEnabled
        public Incident__c      dispatchFromIncident{get;set;}
        @AuraEnabled
        public date             DF_endDate{get; set;}
        @AuraEnabled
        public string           DF_incidentRequestNumber{get; set;}
        @AuraEnabled
        public Incident__c      dispatchToIncident{get;set;}
        @AuraEnabled
        public date             DT_startDate{get; set;}
        @AuraEnabled
        public string           DT_incidentRequestNumber{get; set;}
        @AuraEnabled
        public string           LD_claim{get; set;}
        @AuraEnabled
        public string           OH_overheadType{get;set;}
        @AuraEnabled
        public ICS_Title__c     OH_icsTitle {get; set;}
        @AuraEnabled
        public string           OH_otherICStitle {get; set;}
        @AuraEnabled
        public string           SV_vehicleOwnership{get; set;}
        @AuraEnabled
        public string           SV_licenseplateNumber {get; set;}
        @AuraEnabled
        public string           SV_vehicleType {get; set;}
        @AuraEnabled
        public string           ER_type {get; set;}
        @AuraEnabled
        public string           ER_apparatus {get; set;}
        @AuraEnabled
        public string           ER_unitNumber {get; set;}
        @AuraEnabled
        public string           ER_licenseNumber {get; set;}
        @AuraEnabled
        public string           ER_cdfoesVehicle {get; set;}
        @AuraEnabled
        public Agency_Special_Equipment_Line_Item__c ER_specialEquipment{get; set;}
        @AuraEnabled
        public string           ER_femaCode {get; set;}
        @AuraEnabled
        public string           PI_numberofPersonnel {get; set;}
        @AuraEnabled
        public string           PI_documentationOnly {get; set;}
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl_Test.PersonnelInfo> personnelInfoList;
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl_Test.PersonnelInfo> otherpersonnelInfoList;
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl_Test.ActualHours> actualHoursList {get; set;}
        @AuraEnabled
        public string           PO_odometerStart {get;set;}
        @AuraEnabled
        public string           PO_odometerEnd {get; set;}
        @AuraEnabled
        public string           PO_totalMiles {get;set;}
        @AuraEnabled
        public string           SN_supplyNumber{get; set;}
        @AuraEnabled
        public string           RA_agencyName{get; set;}
        @AuraEnabled
        public string           RA_yourName{get; set;}
        @AuraEnabled
        public string           RA_yourTitle{get; set;}
        @AuraEnabled
        public string           RA_yourPhone{get; set;}
        @AuraEnabled
        public string           RA_signURL{get; set;}
        @AuraEnabled
        public string           PA_payingAgency{get; set;}
        @AuraEnabled
        public string           PA_payingAgencyOther{get; set;}
        @AuraEnabled
        public string           PA_printedName{get; set;} 
        @AuraEnabled
        public date             PA_printedNameDate{get; set;} 
        @AuraEnabled
        public string           PA_icsPosition{get; set;}
        @AuraEnabled
        public string           PA_otherIcsPosition{get; set;}
        @AuraEnabled
        public string           PA_caloesRep{get; set;}
        @AuraEnabled
        public date             PA_caloesRepDate{get; set;} 
        @AuraEnabled
        public string           PA_signURL{get; set;}
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl_Test.CommentWrapper>  comments{get; set;}
    }
    
    public class PersonnelInfo{
        @AuraEnabled
        public string fullName {get; set;}
        @AuraEnabled
        public string MACSID {get; set;}
        @AuraEnabled
        public string jobTitle {get; set;}
        @AuraEnabled
        public string ssn {get; set;}
        @AuraEnabled
        public Date startDate {get; set;}
        @AuraEnabled
        public string startTime {get; set;}
        @AuraEnabled
        public Date endDate {get; set;}
        @AuraEnabled
        public string endTime {get; set;}
        @AuraEnabled
        public Boolean cdf {get; set;}
        @AuraEnabled
        public Boolean p2p {get; set;}
        @AuraEnabled
        public Boolean p2pDisabled {get; set;}
        @AuraEnabled
        public string base {get; set;}
        @AuraEnabled
        public boolean editable {get; set;}
        @AuraEnabled
        public boolean readOnly {get; set;}
        
    }
    
    public class ActualHours{
        @AuraEnabled
        public Date dayOfHours {get; set;}
        @AuraEnabled
        public string startTime {get; set;}
        @AuraEnabled
        public string endTime {get; set;}
        @AuraEnabled
        public Decimal totalHours {get; set;}
        
    }
    
    public class CommentWrapper{
        @AuraEnabled
        public date dateofComment {get; set;}
        @AuraEnabled
        public string timeofComment {get; set;}
        @AuraEnabled
        public string comment{get; set;}
    }
}