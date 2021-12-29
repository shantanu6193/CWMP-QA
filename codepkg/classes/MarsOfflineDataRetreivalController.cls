public without sharing class MarsOfflineDataRetreivalController {
    public String               dataPassed{get;set;}   
    public String               offlineDataPassed{get;set;}    
    public list<OfflineData>    OfflineDataTable {get;set;}    
    public String               syncJson{get;set;}    
    public String               syncSign{get;set;}    
    public PassObject           passedObject {get;set;}    
    public boolean              displayPopup {get; set;}     
    public boolean              displayTable {get; set;}  

    public void closeTable() {        
        displayTable = false;    
    }     
    public void showTable() {        
        displayTable = true;    
    }

    public PageReference doSubmit() {


        dataPassed = dataPassed;
        return null;
    }

    public PageReference passSyncSignature() {
        syncSign = syncSign;
        return null;
    }

    public PageReference selectedSync() {
        try{

        
            passedObject = (PassObject)JSON.deserialize(syncJson, PassObject.class);
            map<string,string> f42Data = (Map<String, string>)JSON.deserialize(syncJson, map<string,string>.class);
            system.debug('f42Data '+f42Data);
            //string f2 = JSON.serialize(f42Entry.get('f42'));
            //map<string,string> f42Data = (Map<String, string>)JSON.deserialize(f2, map<string,string>.class);
            User loggedinUser = [SELECT Id, Name, Phone, ContactId FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
            string  imageBase64 = passedObject.signatureString;//paying Ageency Signature
            imageBase64 = imageBase64.substring(23,imageBase64.length());
            imageBase64 = imageBase64.substring(0, (imageBase64.length() - 1));

            string  imageBase64Ra = passedObject.signatureStringRa; //Respondig agency Signature
            imageBase64Ra = imageBase64Ra.substring(23,imageBase64Ra.length());
            imageBase64Ra = imageBase64Ra.substring(0, (imageBase64Ra.length() - 1));

            MARS_F42Entry_Ctrl.F42EntryWrapper f42Wrapper = new MARS_F42Entry_Ctrl.F42EntryWrapper();
            f42Wrapper.f42Id                            = '';
            f42Wrapper.loggedinUser                     = loggedinUser;
            f42Wrapper.agency                           = new Account();
            f42Wrapper.strikeTeam                       = f42Data.get('strikeTeam');
            f42Wrapper.incident                         = new Incident__c();
            f42Wrapper.incidentRequestNumber            = f42Data.get('incidentRequestNumber');
            f42Wrapper.dispatchInfoIncident             = new Incident__c();
            f42Wrapper.DI_reportingLocation             = f42Data.get('DI_reportingLocation');
            f42Wrapper.DI_committedtoIncident           = string.isNotBlank(f42Data.get('DI_committedtoIncident')) ? Date.valueOf(f42Data.get('DI_committedtoIncident')) : null;
            f42Wrapper.DI_committedtoIncidentTime       = f42Data.get('DI_committedtoIncidentTime');
            f42Wrapper.DI_returnfromIncident            = string.isNotBlank(f42Data.get('DI_returnfromIncident')) ? Date.ValueOf(f42Data.get('DI_returnfromIncident')) : null; 
            f42Wrapper.DI_returnfromIncidentTime        = f42Data.get('DI_returnfromIncidentTime');
            f42Wrapper.DI_reDispatched                  = string.isNotBlank(f42Data.get('DI_reDispatched')) ? Date.ValueOf(f42Data.get('DI_reDispatched')) : null;
            f42Wrapper.DI_reDispatchedTime              = f42Data.get('DI_reDispatchedTime');
            f42Wrapper.DI_mobilizationCenter            = f42Data.get('DI_mobilizationCenter');
            f42Wrapper.dispatchFromIncident             = new Incident__c();
            f42Wrapper.DF_endDate                       = string.isNotBlank(f42Data.get('DF_endDate')) ? Date.ValueOf(f42Data.get('DF_endDate')) : null;
            //f42Wrapper.DF_endTime                       = f42Data.get('DF_endDateTime');
            f42Wrapper.DF_incidentRequestNumber         = f42Data.get('DF_incidentRequestNumber');
            f42Wrapper.dispatchToIncident               = new Incident__c();
            f42Wrapper.DT_startDate                     = string.isNotBlank(f42Data.get('DT_startDate')) ? Date.valueOf(f42Data.get('DT_startDate')) : null;
            //f42Wrapper.DT_startTime                     = f42Data.get('DT_startTime');
            f42Wrapper.DT_incidentRequestNumber         = f42Data.get('DT_incidentRequestNumber');
            f42Wrapper.LD_claim                         = f42Data.get('LD_claim');
            f42Wrapper.OH_overheadType                  = f42Data.get('OH_overheadType');
            //f42Wrapper.OH_icsTitle                      = f42Data.get('OH_icsTitle');
            f42Wrapper.OH_otherICStitle                 = f42Data.get('OH_otherICStitle');
            f42Wrapper.SV_vehicleOwnership              = f42Data.get('SV_vehicleOwnership');
            f42Wrapper.SV_licenseplateNumber            = f42Data.get('SV_licenseplateNumber');
            f42Wrapper.SV_vehicleType                   = f42Data.get('SV_vehicleType');
            f42Wrapper.ER_type                          = f42Data.get('ER_type');
            f42Wrapper.ER_apparatus                     = f42Data.get('ER_apparatus');
            f42Wrapper.ER_unitNumber                    = f42Data.get('ER_unitNumber');
            f42Wrapper.ER_licenseNumber                 = f42Data.get('ER_licenseNumber');
            f42Wrapper.ER_cdfoesVehicle                 = f42Data.get('ER_cdfOesVehicle');
            //f42Wrapper.                               = f42Data.get('RA_agencyName');
            f42Wrapper.ER_femaCode                      = f42Data.get('ER_femaCode');
            f42Wrapper.PI_numberofPersonnel             = f42Data.get('PI_numberofPersonnel');
            f42Wrapper.PI_documentationOnly             = f42Data.get('PI_documentationOnly');
            f42Wrapper.PO_odometerStart                 = f42Data.get('PO_odometerStart');
            f42Wrapper.PO_odometerEnd                   = f42Data.get('PO_odometerEnd');
            f42Wrapper.PO_totalMiles                    = f42Data.get('PO_totalMiles');
            f42Wrapper.SN_supplyNumber                  = f42Data.get('SN_supplyNumber');
            f42Wrapper.RA_agencyName                    = f42Data.get('RA_agencyName');
            f42Wrapper.RA_yourName                      = f42Data.get('RA_yourName'); 
            f42Wrapper.RA_yourTitle                     = f42Data.get('RA_yourTitle');
            f42Wrapper.RA_yourPhone                     = f42Data.get('RA_yourPhone');
            f42Wrapper.PA_payingAgency                  = f42Data.get('PA_payingAgency');
            f42Wrapper.PA_payingAgencyOther             = f42Data.get('PA_payingAgencyOther');
            f42Wrapper.PA_printedName                   = f42Data.get('PA_printedName');
            //f42Wrapper.PA_printedNameDate               = f42Data.get('RA_agencyName');
            f42Wrapper.PA_icsPosition                   = f42Data.get('PA_icsPosition');
            //f42Wrapper.PA_otherIcsPosition              = f42Data.get('RA_agencyName');
            f42Wrapper.PA_caloesRep                     = f42Data.get('PA_caloesRep');
            //f42Wrapper.PA_caloesRepDate                 = f42Data.get('RA_agencyName');
        



        /* list<Account> agency = [SELECT Id, Id, Name, MACS_ID__c,ShippingState,Mars_Agency_Designator__c 
                                    FROM Account 
                                    WHERE MACS_ID__c = :f42Data.get('AI_macsId') LIMIT 1];

            list<Incident__c> incident = [SELECT Id, NAME, Order_No__c FROM Incident__c 
                                        WHERE Order_No__c =: f42Data.get('AI_macsId') LIMIT 1];
            
            list<Incident__c> dispatchFromIncident = [SELECT Id, NAME, Order_No__c FROM Incident__c 
                                        WHERE Order_No__c =: f42Data.get('AI_macsId') LIMIT 1];

            list<Incident__c> dispatchToIncident = [SELECT Id, NAME, Order_No__c FROM Incident__c 
                                        WHERE Order_No__c =: f42Data.get('AI_macsId') LIMIT 1];*/

            F42_Entry__c entry = new F42_Entry__c();
            entry.Offline_Json__c =  passedObject.f42;
            entry.JSON__c         =  JSON.serialize(f42Wrapper);
            entry.Status__c =  'Offline Draft';
            entry.Entered_By__c =  loggedinUser.ContactId;
            entry.Source__c = 'Offline';
            entry.Name      = 'Offline Submission Draft';
            Userinfo.getUserId();

            insert entry;


            if(string.isNotBlank(imageBase64)) {
            SignatureHelper.saveSignwithName(imageBase64, entry.Id, 'Paying Agency Signature');
            }

            if(string.isNotBlank(imageBase64Ra)) {
                SignatureHelper.saveSignwithName(imageBase64Ra, entry.Id, 'Responding agency Signature');
            }
        }catch(exception e){
            ApexPages.addMessage(new Apexpages.message(Apexpages.Severity.ERROR, 'Sync failed due to '+e.getMessage()+' stack trace '+e.getStackTraceString()));
        }
        return null;
    }


    public PageReference showOfflineData() {
        showTable();
        if(offlineDataPassed == 'empty'){
            OfflineDataTable = null;
            return null;  
        }
        else {
            OfflineDataTable = (List<OfflineData>)JSON.deserialize(offlineDataPassed, List<OfflineData>.class);
            offlineDataPassed = 'First Record:' + OfflineDataTable[0].AI_agencyName;
            return null;  
        }
    }

    public PageReference saveRecord() {
        F42_Entry__c entry = new F42_Entry__c();
        entry.Json__c = dataPassed;
        entry.Status__c =  'Draft';
        entry.Name = 'F42Entry-Draft';
        insert entry;


        return null;
    }


    public class OfflineData {
        public String Id {get; set;}
        public String key {get; set;}
        public String AI_agencyName {get; set;}
        public String RA_agencyName {get; set;}
        public String RA_yourName {get; set;}
        public String PA_printedName {get; set;}
        public String designator {get; set;}
        public String incidentOrderNumber {get; set;}
        public String incidentrequestsnumber {get; set;}

    }


    public class PassObject {
        public String signatureString {get; set;}//paying agency Signature
        public String signatureStringRa {get; set;}//Responding agency signature
        public String f42 {get; set;}
        public String agencyName {get; set;}
    }
    
    

}