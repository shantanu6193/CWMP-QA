/**
 * Created by Chandrabhan on 2021-07-26.
 */
public without sharing class MARS_GenerateEstimateForF42sCtrl {
     // create invoice agncy wise under 1 incident 
     @AuraEnabled
     public static Map<String, Object> createInvoiceEstimate(String f42s) {
        Map<String, Object> returnMap = new Map<String, Object>();
        InvoicePDF invoiceRecord = createEstimateData(f42s);
        returnMap.put('invoiceRecord', JSON.serialize(invoiceRecord));
        return returnMap;
    }
    // Invoice Wrapper class fro generate invoice
  // Invoice Wrapper class fro generate invoice
    private class InvoicePDF {
        public List<VechicleRate> vechicleRateList{get; set;}
        public List<ApparatusRate> apparatusRateList{get; set;}
        public List<SalarySurveyRate> SalarySurveyRateList{get; set;}
        public String agencySalarySurveyonFile{get; set;}
        public string administrativeRate{get; set;}
        public F42Details f42DetailsList{get; set;}
        public string mileRate{get; set;}
    }
    public class F42Details {
        public String MACSDesignator{get; set;}
        public String incidentName{get; set;}
        public String strikeTeam{get; set;}
        public  String orderNo{get; set;}
        public String requestNo{get; set;}
        public String name{get; set;}
        public String to{get; set;}
        public String location{get; set;}
        public String appUnitNo{get; set;}
        public String OESVehicle{get; set;}
        public String departedDate{get; set;}
        public String returnDate{get; set;}
        public String departedTime{get; set;}
        public String returnTime{get; set;}
        public String departedDateTime{get; set;}
        public String returnDateTime{get; set;}
        public String totalHours{get; set;}
        public String fireEngineOr{get; set;}
        public String apparatusType{get; set;}
        public String LicenseNumber{get; set;}
        public String licenseNo{get; set;}
        public String beginningOdoMeter{get; set;}
        public String endingOdoMeter{get; set;}
        public String totalMiles{get; set;}
        public String ICSTitle{get; set;}
        public String vehicleMakeandModel{get; set;}
        public String vehicleOwnership{get; set;}
        public String department{get; set;}
        public String chief{get; set;}
        public String phone{get; set;}
        public String fax{get; set;}
        public String mailBox{get; set;}
        public String address{get; set;}
        public String city{get; set;}
        public String state{get; set;}
        public String zip{get; set;}
        public String CDFExplainOther{get; set;}
        public String CDFContract{get; set;}
        public String internetMail{get; set;}
        public String POV{get; set;}
        
        public String FEMACode{get; set;}
        public String FEMACodeRate{get; set;}
        public String FEMACodeHours{get; set;}
        public String FEMACodTotal{get; set;}
        public String specialEquipment{get; set;}
        public String specialEquipmentRate{get; set;}
        public String specialEquipmentHours{get; set;}
        public String specialEquipmentTotal{get; set;}
        public String specialEquipFEMASubTotal{get; set;}

        public String totalPersonnel{get; set;}
        public String surchargePersonnel{get; set;}
        public String engineHours{get; set;}
        public String totleEngineHours{get; set;}
        public String apparatusRate{get; set;}
        public String surchargeEngine{get; set;}
        public String supportOrOverheadVehicle{get; set;}
        public String vehicleCost{get; set;}
        public String vehicleDays{get; set;}
        public String surchargeVehicle{get; set;}
        public String totalForThisF42{get; set;}
        public String expenseClaim{get; set;}
        public String surchargeExpenseClaim{get; set;}
        public List<StrikeTeamExpenses> strikeTeamExpensesList{get; set;}
    }
    public class StrikeTeamExpenses {
        public String personnelType{get; set;}
        public String hourlyRate{get; set;}
        public String paidRate{get; set;}
        public String onThisF42{get; set;}
        public String hoursOnThisF42{get; set;}
        public String totalForThisF42{get; set;}
    }

    public class VechicleRate {
        public String vechicleType{get; set;}
        public String rate{get; set;}
    }
    public class ApparatusRate {
        public String apparatusType{get; set;}
        public String rate{get; set;}
    }
    public class SalarySurveyRate {
        public String personnelRole{get; set;}
        public String rate{get; set;}
    }

    public class DateTimeCalculation {
        public String hours24{get; set;}
        public String days{get; set;}
        public String hours16{get; set;}
    }
     
    // generate invoice data
    private static InvoicePDF createEstimateData(String f42s) {
        String jsonData='';
        Boolean isSalarySurveyPresent = false;
        Boolean isAdminRatePresent = false;
        String accountId;
        List<VechicleRate> vechicleRateList = new List<VechicleRate>();
        List<ApparatusRate> apparatusRateList = new List<ApparatusRate>();
        List<SalarySurveyRate> salarySurveyRateList = new List<SalarySurveyRate>();
        Map<String,Decimal> salarySurveyBasePaidRateMap = new Map<String,Decimal>();
        Map<String,Decimal> salarySurveyPaidRateMap = new Map<String,Decimal>();
        Map<String,Decimal> salarySurveyHourlyRateMap = new Map<String,Decimal>();
        Map<String,Decimal> vechicleRateMap = new Map<String,Decimal>();
        Map<String,Decimal> apparatusRateMap = new Map<String,Decimal>();
        Map<String,Decimal> nonSuppressionRateMap = new Map<String,Decimal>();
        Map<String,Decimal> femaCodeRateMap = new Map<String,Decimal>();
        Map<String,Decimal> speicalEquipmentRateMap = new Map<String,Decimal>();
        InvoicePDF ivoiceObj = new InvoicePDF();
        List<F42__c> f42List = [SELECT Id,Account__c,Account__r.Name,Account__r.Mars_Agency_Designator__c,Incident__r.Name,Incident__r.Incident_Type__c,Account__r.MACS_ID__c,Account__r.ShippingStreet,Account__r.ShippingCity,
                                Account__r.ShippingState,Account__r.ShippingPostalCode,Account__r.Chief_Name__c,Account__r.Phone,DF_OLD_INCIDENT_REQUEST__c,DT_NEW_INCIDENT_REQUEST__c,
                                Account__r.Fax, Days_from_Submission__c, DF_Dispatch_From_End_Date__c, SV_LICENSE__c,DF_OLD_INCIDENT__c,DT_NEW_INCIDENT__c,DT_Dispatch_To_Start_Date__c,
                                Account__r.Federal_Tax_ID__c,Account__r.DUNS__c,Account__r.Fiscal_Supplier_ID__c,Account__r.Fiscal_Address_Id__c,OH_OVERHEAD_TYPE__c,
                                ER_UNIT__c,Incident_Request_Number__c,Strike_Team__c,DI_Committed_to_Incident_Date__c, DI_COMMITTED_TO_INCIDENT_FORMULA__c, DI_Committed_to_Incident_Time__c,
                                DI_RETURN_FROM_INCIDENT__c,DI_Return_from_Incident_Date__c,DI_Return_from_Incident_Time__c,ER_TYPE__c,SV_TOTAL_MILES__c,DI_REPORTING_LOCATION__c,
                                DI_REDISPATCHED__c,DI_Redispatched_Date__c,DI_Redispatched_Time__c,SV_TYPE__c,SV_VEHICLE_OWNERSHIP__c,Incident_Order__c,PA_PAYING_AGENCY__c,
                                ER_CDF_OES_VEHICLE__c,SV_ENDING_ODOMETER__c,SV_BEGINNING_ODODMETER__c,ER_LICENSE_NUMBER__c,OH_ICS_Title__c,DT_NEW_INCIDENT__r.Order_No__c,DF_OLD_INCIDENT__r.Order_No__c,
                                OH_OTHER_ICS_TITLE__c,ER_APPARATUS__c,SN_LOSS_DAMAGE_CLAIM__c,SN_SUPPLY_NUMBER__c,RA_AGENCY_NAME__c,RA_YOUR_NAME__c,RA_YOUR_PHONE__c,ER_FEMA_CODES__c,ER_SPECIAL_EQUIPMENT__c,
                                RA_YOUR_TITLE__c,PA_PRINTED_NAME__c,PA_OTHER__c,PA_DATE__c,PA_CALOESREP_DATE__c,PA_Cal_OES_REPRESENTATIVE__c,PA_ICS_POSITION_TITLE__c,PI_NUMBER_OF_PERSONNEL_ON_APPARATUS__c
                                FROM F42__c WHERE Id =:f42s];
            
        String paidRateFactor = KeyValueHelper.getTextValue('MARS_Paid_Rate_Factor');
        if(f42List.size() > 0){
            accountId = f42List[0].Account__c;
            // get agnecy salary Survey
            Set<String> overTimeCheckForClasTitle = new Set<String>{'Battalion Chief', 'Co. Officer/Capt./Lt.','App. Officer/Eng','Firefighter/FF-PMedic'};
            Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = getAgreementLineItemMap(accountId);
            List<Agency_Salary_Survey__c> agecySalarySurveyLineItem = getAgencySalarySurvey(accountId, f42List[0].DI_Committed_to_Incident_Date__c);
            if(agecySalarySurveyLineItem.size() > 0) {
                for(F42__c record : f42List) {
                    for(Agency_Salary_Survey__c salSurveyRec : agecySalarySurveyLineItem) {
                        if(salSurveyRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (salSurveyRec.END_Date__c == null || salSurveyRec.END_Date__c >= record.DI_Committed_to_Incident_Date__c)){
                            isSalarySurveyPresent = true;
                            for(Salary_Survey_Line_Items__c salSurLineItem : salSurveyRec.Salary_Survey_Line_Items__r) {
                                if(!salarySurveyPaidRateMap.containsKey(salSurLineItem.Classification_Title__c)){
                                    // check with Agreement records
                                    Boolean isovertime = false;
                                    if(overTimeCheckForClasTitle.contains(salSurLineItem.Classification_Title__c)) {
                                        isovertime = true;
                                    } else if(agencyAgreementMap.containsKey(salSurLineItem.Classification_Title__c)) {
                                        for(Agency_Rate_Agreement_Line_Item__c lineItem : agencyAgreementMap.get(salSurLineItem.Classification_Title__c)) {
                                           if(lineItem.OT__c) {
                                                isovertime = lineItem.OT__c;
                                            } 
                                        }
                                    }

                                    SalarySurveyRate salarySurveyRecord = new SalarySurveyRate();
                                    salarySurveyRecord.personnelRole = salSurLineItem.Classification_Title__c;
                                    salarySurveyRecord.rate = String.valueOf(salSurLineItem.Current_Rate__c);
                                    salarySurveyRateList.add(salarySurveyRecord);
                                    Decimal amount = salSurLineItem.Current_Rate__c;
                                    salarySurveyHourlyRateMap.put(salSurLineItem.Classification_Title__c, salSurLineItem.Current_Rate__c);
                                    if(isovertime) { //salSurLineItem.MOU_MOA__c
                                        salarySurveyPaidRateMap.put(salSurLineItem.Classification_Title__c,(amount * Decimal.valueOf(paidRateFactor)).setScale(2));
                                        salarySurveyBasePaidRateMap.put(salSurLineItem.Classification_Title__c,(salSurLineItem.Base_Rates__c * Decimal.valueOf(paidRateFactor)).setScale(2));
                                    } else {
                                        salarySurveyPaidRateMap.put(salSurLineItem.Classification_Title__c, amount);
                                        salarySurveyBasePaidRateMap.put(salSurLineItem.Classification_Title__c,salSurLineItem.Base_Rates__c);
                                    }
                                }
                            }
                        }
                    }
                }
                if(salarySurveyRateList != null)
                ivoiceObj.salarySurveyRateList = salarySurveyRateList;
            }
            // get non Suppression Personnel
            List<Agency_Non_Suppression_Personnel__c> agecyNonSuppressionLineItem = getAgencyNonSuppresssionList(accountId, f42List[0].DI_Committed_to_Incident_Date__c);
            if(agecyNonSuppressionLineItem.size() > 0) {
                for(F42__c record : f42List) {
                    for(Agency_Non_Suppression_Personnel__c salNonSuppRec : agecyNonSuppressionLineItem) {
                        if(salNonSuppRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c){
                            for(Agency_Non_Suppression_Line_Item__c nonSuppLineItem : salNonSuppRec.Agency_Non_Suppression_Line_Items__r) {
                                if(!nonSuppressionRateMap.containsKey(nonSuppLineItem.Classification_Title__c)){
                                    nonSuppressionRateMap.put(nonSuppLineItem.Classification_Title__c,nonSuppLineItem.Current_Rate__c);
                                }
                            }
                        }
                    }
                }
            }

            //Get administrator data
            List<Agency_Admin_Rates__c> AgencyAdminData = getAgencyAdminRate(accountId, f42List[0].DI_Committed_to_Incident_Date__c);
            if(AgencyAdminData.size() > 0) {
                for(F42__c record : f42List) {
                    for(Agency_Admin_Rates__c adminRec : AgencyAdminData) {
                        if(adminRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && adminRec.Administrative_Rate_Indirect_Cost_Direct__c != null){
                            isAdminRatePresent = true;
                            ivoiceObj.administrativeRate = String.valueOf(adminRec.Administrative_Rate_Indirect_Cost_Direct__c);
                        }
                    }
                }
            }
            // Get CFAA Data
            List<CFAA__c> CFAAMap = getCFAA(f42List[0].DI_Committed_to_Incident_Date__c);
            if(CFAAMap.size() > 0) {
                for(F42__c record : f42List) {

                    for(CFAA__c cfaadata : CFAAMap) {
                        if(cfaadata.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (cfaadata.End_Date__c == null || cfaadata.End_Date__c >= record.DI_Committed_to_Incident_Date__c)) {
                            if(isAdminRatePresent == false) {
                                ivoiceObj.administrativeRate = String.valueOf(cfaadata.Default_Admin_Rate__c);
                            }
                            for(CFAA_Line_Items__c cfaaLineItem : cfaadata.CFAA_Line_Items__r) {
                                VechicleRate vechicleRecord = new VechicleRate();
                                ApparatusRate apparatusRcord = new ApparatusRate();
                                SalarySurveyRate salarySurveyRecord = new SalarySurveyRate();
                            
                                if(cfaaLineItem.RecordType.Name == 'Support Equipment Rate'){
                                    if(!vechicleRateMap.containsKey(cfaaLineItem.Support_Equipment_Type__c)) {
                                        /*vechicleRecord.vechicleType = cfaaLineItem.Support_Equipment_Type__c;
                                        vechicleRecord.rate = String.valueOf(cfaaLineItem.Straight_Time_Rate__c);
                                        vechicleRateList.add(vechicleRecord);*/
                                        vechicleRateMap.put(cfaaLineItem.Support_Equipment_Type__c, cfaaLineItem.Straight_Time_Rate__c);
                                    }

                                } else if(cfaaLineItem.RecordType.Name == 'Emergency Apparatus Rate') {
                                    if(!apparatusRateMap.containsKey(cfaaLineItem.Emergency_Apparatus_Type__c)) {
                                        /*apparatusRcord.apparatusType = cfaaLineItem.Emergency_Apparatus_Type__c;
                                        apparatusRcord.rate = String.valueOf(cfaaLineItem.Straight_Time_Rate__c);
                                        apparatusRateList.add(apparatusRcord);*/
                                        apparatusRateMap.put(cfaaLineItem.Emergency_Apparatus_Type__c,cfaaLineItem.Straight_Time_Rate__c);
                                    }
                                } else if(cfaaLineItem.RecordType.Name == 'Personnel Base Rate' && isSalarySurveyPresent == false) {
                                    if(!salarySurveyPaidRateMap.containsKey(cfaaLineItem.Personnel_Role__c)){
                                        // check with Agreement records
                                        Boolean isovertime = false;
                                        if(overTimeCheckForClasTitle.contains(cfaaLineItem.Personnel_Role__c)) {
                                            isovertime = true;
                                        } else if(agencyAgreementMap.containsKey(cfaaLineItem.Personnel_Role__c)) {
                                            for(Agency_Rate_Agreement_Line_Item__c lineItem : agencyAgreementMap.get(cfaaLineItem.Personnel_Role__c)) {
                                                if(lineItem.OT__c) {
                                                    isovertime = lineItem.OT__c;
                                                } 
                                            }
                                        }
                                        if(isovertime) { //salSurLineItem.MOU_MOA__c
                                            salarySurveyPaidRateMap.put(cfaaLineItem.Personnel_Role__c,(cfaaLineItem.Straight_Time_Rate__c * Decimal.valueOf(paidRateFactor)).setScale(2));
                                            salarySurveyBasePaidRateMap.put(cfaaLineItem.Personnel_Role__c,(cfaaLineItem.Straight_Time_Rate__c * Decimal.valueOf(paidRateFactor)).setScale(2));
                                        } else {
                                            salarySurveyPaidRateMap.put(cfaaLineItem.Personnel_Role__c,cfaaLineItem.Straight_Time_Rate__c);
                                            salarySurveyBasePaidRateMap.put(cfaaLineItem.Personnel_Role__c,cfaaLineItem.Straight_Time_Rate__c);
                                        } 
                                        salarySurveyHourlyRateMap.put(cfaaLineItem.Personnel_Role__c,cfaaLineItem.Straight_Time_Rate__c);
                                        /*salarySurveyRecord.personnelRole = cfaaLineItem.Personnel_Role__c;
                                        salarySurveyRecord.rate = String.valueOf(cfaaLineItem.Straight_Time_Rate__c);
                                        salarySurveyRateList.add(salarySurveyRecord);*/
                                    }
                                } else if(cfaaLineItem.RecordType.Name == 'POV Rate' && cfaaLineItem.Straight_Time_Rate__c != null ) {
                                    ivoiceObj.mileRate = String.valueOf(cfaaLineItem.Straight_Time_Rate__c);
                                }
                            }
                        }    
                    }
                }
                ivoiceObj.vechicleRateList = vechicleRateList;
                ivoiceObj.apparatusRateList = apparatusRateList;
                if(salarySurveyRateList != null)
                    ivoiceObj.salarySurveyRateList = salarySurveyRateList;
            }
            // Get Special Equipment Rate 
            List<Agency_Special_Equipment__c> specialEquipmentList = getSpecialEquipment(accountId, f42List[0].DI_Committed_to_Incident_Date__c);
            if(specialEquipmentList.size() > 0) {
                for(F42__c record : f42List) {
                    for(Agency_Special_Equipment__c speEquipRec : specialEquipmentList) {
                        if(speEquipRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (speEquipRec.End_Date__c == null || speEquipRec.End_Date__c >= record.DI_Committed_to_Incident_Date__c)) {
                            for(Agency_Special_Equipment_Line_Item__c speEquipItem : speEquipRec.Agency_Special_Equipment_Line_Items__r) {
                                if(!speicalEquipmentRateMap.containsKey(speEquipItem.Special_Equipment_Type__c) && speEquipItem.Revised_Rate__c != null){
                                    speicalEquipmentRateMap.put(speEquipItem.Special_Equipment_Type__c, speEquipItem.Revised_Rate__c);
                                }
                            }
                        }
                    }
                }
            }
            
            //Get FEMA Code Rate 
            List<FEMA_Code__c> femaCodeList = getFEMARecords(f42List[0].DI_Committed_to_Incident_Date__c);
            if(femaCodeList.size() > 0) {
                for(F42__c record : f42List) {
                    for(FEMA_Code__c femaCodeRec : femaCodeList) {
                        if(femaCodeRec.Effective_Date__c <= record.DI_Committed_to_Incident_Date__c && (femaCodeRec.End_Date__c == null || femaCodeRec.End_Date__c >= record.DI_Committed_to_Incident_Date__c)) {
                            for(FEMA_Code_LineItem__c femaCodeItem : femaCodeRec.FEMA_Schedule_of_Equipment__r) {
                                if(!femaCodeRateMap.containsKey(femaCodeItem.Name)){
                                    femaCodeRateMap.put(femaCodeItem.Name, femaCodeItem.Current_Rate__c);
                                }
                            }
                        }    
                    }
                }    
            }

            ivoiceObj.f42DetailsList = createf42DetailsList(f42List, salarySurveyPaidRateMap, apparatusRateMap, vechicleRateMap, ivoiceObj.administrativeRate, f42s, salarySurveyHourlyRateMap, speicalEquipmentRateMap, femaCodeRateMap, ivoiceObj.mileRate, nonSuppressionRateMap, salarySurveyBasePaidRateMap);
        }
        //return JSON.serialize(ivoiceObj);
        return ivoiceObj;
    }

    private static F42Details createf42DetailsList(List<F42__c> f42List, Map<String,Decimal> salarySurveyPaidRateMap, Map<String,Decimal> apparatusRateMap, Map<String,Decimal> vechicleRateMap, String adminRateFactor, String f42s, Map<String,Decimal> salarySurveyHourlyRateMap, Map<String,Decimal> speicalEquipmentRateMap, Map<String,Decimal> femaCodeRateMap, String mileRate, Map<String,Decimal> nonSuppressionRateMap, Map<String,Decimal> salarySurveyBasePaidRateMap) {
        F42Details f42Record = new F42Details();
        for(F42__c record : f42List) {
            f42Record.incidentName  = record.Incident__r.Name;
            f42Record.MACSDesignator = record.Account__r.MACS_ID__c;
            f42Record.strikeTeam = record.Strike_Team__c;
            f42Record.orderNo = record.Incident_Order__c;
            f42Record.requestNo = record.Incident_Request_Number__c;
            f42Record.to = record.Incident__r.Incident_Type__c;
            f42Record.name = record.Incident__r.Name;
            f42Record.location = record.DI_REPORTING_LOCATION__c;
            f42Record.appUnitNo = record.ER_UNIT__c;
            if(record.ER_CDF_OES_VEHICLE__c)
                f42Record.OESVehicle = 'Yes';
            else
                f42Record.OESVehicle = 'No';
            f42Record.FEMACode = record.ER_FEMA_CODES__c;    
            f42Record.specialEquipment =  record.ER_SPECIAL_EQUIPMENT__c;    
            f42Record.departedDate = String.valueOf(DateTime.valueOf(record.DI_Committed_to_Incident_Date__c+'00:00:00').format('MM/dd/yyyy'));
            f42Record.departedTime = String.valueOf(record.DI_Committed_to_Incident_Time__c);   
            f42Record.returnDate = String.valueOf(record.DI_Redispatched_Date__c != null ? DateTime.valueOf(record.DI_Redispatched_Date__c+'00:00:00').format('MM/dd/yyyy') : DateTime.valueOf(record.DI_Return_from_Incident_Date__c+'00:00:00').format('MM/dd/yyyy'));
            f42Record.returnTime = String.valueOf(record.DI_Redispatched_Time__c != null ? record.DI_Redispatched_Time__c : record.DI_Return_from_Incident_Time__c);
            f42Record.departedDateTime = record.DI_COMMITTED_TO_INCIDENT_FORMULA__c;
            f42Record.returnDateTime = String.valueOf(record.DI_REDISPATCHED__c != null ? record.DI_REDISPATCHED__c : record.DI_RETURN_FROM_INCIDENT__c);
            DateTime startDate;
            DateTime endDate;
            if(f42Record.departedDateTime != null) {
                    String timestr = record.DI_Committed_to_Incident_Time__c;
                    String hrs = timestr.substring(0,2);
                    String mins = timestr.substring(2);
                    startDate = DateTime.valueOf(String.valueOf(record.DI_Committed_to_Incident_Date__c).removeEnd(' 00:00:00')+' '+hrs+':'+mins+':00');

            }
            if(f42Record.returnDateTime != null){
                if(record.DI_RETURN_FROM_INCIDENT__c != null && record.DI_Return_from_Incident_Date__c != null && record.DI_Return_from_Incident_Time__c != null){
                    String timestr = record.DI_Return_from_Incident_Time__c;
                    String hrs = timestr.substring(0,2);
                    String mins = timestr.substring(2);
                    endDate = DateTime.valueOf(String.valueOf(record.DI_Return_from_Incident_Date__c).removeEnd(' 00:00:00')+' '+hrs+':'+mins+':00');
                }
                if(record.DI_REDISPATCHED__c != null && record.DI_Redispatched_Date__c != null && record.DI_Redispatched_Time__c != null){
                    String timestr = record.DI_Redispatched_Time__c;
                    String hrs = timestr.substring(0,2);
                    String mins = timestr.substring(2);
                    endDate = DateTime.valueOf(String.valueOf(record.DI_Redispatched_Date__c).removeEnd(' 00:00:00')+' '+hrs+':'+mins+':00');
                } 
            }
            DateTimeCalculation dateDetails = getDateTimeCalculation(startDate, endDate);
            Decimal TotalEngineHrs = Decimal.valueOf(dateDetails.hours16);
            
            String erType = getApparatusType(record.ER_TYPE__c);
            if(apparatusRateMap != null && erType != null && apparatusRateMap.containsKey(erType)) {
                f42Record.engineHours = String.valueOf(TotalEngineHrs);
                f42Record.totleEngineHours = String.valueOf((TotalEngineHrs * apparatusRateMap.get(erType)).setScale(2));
                f42Record.apparatusRate = String.valueOf(apparatusRateMap.get(erType));
            } else {
                f42Record.totleEngineHours = '00.00';
                f42Record.engineHours ='0.0';
                f42Record.surchargeEngine = '0.00';
                f42Record.apparatusRate = '0.00';
            }
            f42Record.specialEquipment = record.ER_SPECIAL_EQUIPMENT__c;
            // calculate appratus hours and toal using Special Equipment
            if(speicalEquipmentRateMap != null && record.ER_SPECIAL_EQUIPMENT__c != null && speicalEquipmentRateMap.containsKey(record.ER_SPECIAL_EQUIPMENT__c)) {
                f42Record.specialEquipmentHours = String.valueOf(TotalEngineHrs);
                f42Record.specialEquipmentTotal = String.valueOf((TotalEngineHrs * speicalEquipmentRateMap.get(record.ER_SPECIAL_EQUIPMENT__c)).setScale(2));
                f42Record.specialEquipmentRate = String.valueOf(speicalEquipmentRateMap.get(record.ER_SPECIAL_EQUIPMENT__c));
            } else {
                f42Record.specialEquipmentHours = '0.00';
                f42Record.specialEquipmentTotal = '0.00';
                f42Record.specialEquipmentRate = '0.00';
            }
            f42Record.FEMACode = record.ER_FEMA_CODES__c;
            // calculate appratus hours and toal using FEMA Code
            if(femaCodeRateMap != null && record.ER_FEMA_CODES__c!=null && femaCodeRateMap.containsKey(record.ER_FEMA_CODES__c)) {
                f42Record.FEMACodeHours = String.valueOf(TotalEngineHrs);
                f42Record.FEMACodTotal = String.valueOf((TotalEngineHrs * femaCodeRateMap.get(record.ER_FEMA_CODES__c)).setScale(2));
                f42Record.FEMACodeRate = String.valueOf(femaCodeRateMap.get(record.ER_FEMA_CODES__c));
            } else {
                f42Record.FEMACodeHours = '0.00';
                f42Record.FEMACodTotal = '0.00';
                f42Record.FEMACodeRate = '0.00';
            }
            f42Record.specialEquipFEMASubTotal = String.valueOf((Decimal.valueOf(f42Record.totleEngineHours) + Decimal.valueOf(f42Record.FEMACodTotal) + Decimal.valueOf(f42Record.specialEquipmentTotal)).setScale(2));
            f42Record.surchargeEngine = String.valueOf(((Decimal.valueOf(f42Record.totleEngineHours) + Decimal.valueOf(f42Record.FEMACodTotal) + Decimal.valueOf(f42Record.specialEquipmentTotal)) * Decimal.valueOf(adminRateFactor)).setScale(2));
            f42Record.totalHours = String.valueOf(dateDetails.hours24);
            f42Record.fireEngineOr ='';
            f42Record.apparatusType = getApparatusType(record.ER_TYPE__c);
            f42Record.LicenseNumber = record.ER_LICENSE_NUMBER__c;
            f42Record.ICSTitle = record.OH_ICS_Title__c != null ? record.OH_ICS_Title__c : record.OH_OTHER_ICS_TITLE__c;
            f42Record.vehicleMakeandModel = record.SV_TYPE__c;
            f42Record.vehicleOwnership = record.SV_VEHICLE_OWNERSHIP__c;
            f42Record.licenseNo = record.SV_LICENSE__c;
            if(record.SV_VEHICLE_OWNERSHIP__c != null) {
                if(record.SV_VEHICLE_OWNERSHIP__c == 'POV') {
                    f42Record.POV = 'Yes';
                    f42Record.beginningOdoMeter = String.valueOf(record.SV_BEGINNING_ODODMETER__c);
                    f42Record.endingOdoMeter = String.valueOf(record.SV_ENDING_ODOMETER__c);
                    f42Record.totalMiles = String.valueOf(record.SV_TOTAL_MILES__c);
                    if(mileRate != null) {
                        f42Record.vehicleCost = String.valueOf((record.SV_TOTAL_MILES__c * Decimal.valueOf(mileRate)).setScale(2));
                        f42Record.vehicleDays = String.valueOf(record.SV_TOTAL_MILES__c);
                        f42Record.supportOrOverheadVehicle = mileRate;
                        f42Record.surchargeVehicle = String.valueOf((Decimal.valueOf(f42Record.vehicleCost) * Decimal.valueOf(adminRateFactor)).setScale(2));
                    }
                }
                else {
                    f42Record.POV = 'No';
                    if(vechicleRateMap != null && record.SV_TYPE__c != null && vechicleRateMap.containsKey(record.SV_TYPE__c)) {
                        f42Record.vehicleCost = String.valueOf((Decimal.valueOf(dateDetails.days) * vechicleRateMap.get(record.SV_TYPE__c)).setScale(2));
                        f42Record.vehicleDays = String.valueOf(dateDetails.days);
                        f42Record.supportOrOverheadVehicle = String.valueOf(vechicleRateMap.get(record.SV_TYPE__c));
                        f42Record.surchargeVehicle = String.valueOf((Decimal.valueOf(f42Record.vehicleCost) * Decimal.valueOf(adminRateFactor)).setScale(2));
                    }
                }
            }  
            if(f42Record.vehicleCost == null || f42Record.vehicleDays == null || f42Record.supportOrOverheadVehicle == null || f42Record.surchargeVehicle == null) {
                f42Record.vehicleCost = '0.00';
                f42Record.vehicleDays = '0.00';
                f42Record.supportOrOverheadVehicle = '0.00';
                f42Record.surchargeVehicle = '0.00';
            }
          
            f42Record.department = record.Account__r.Name;
            f42Record.chief = record.Account__r.Chief_Name__c;
            f42Record.phone =  record.Account__r.Phone;
            f42Record.fax = record.Account__r.Fax;
            f42Record.address = record.Account__r.ShippingStreet;
            f42Record.city = record.Account__r.ShippingCity;
            f42Record.state = record.Account__r.ShippingState;
            f42Record.zip = record.Account__r.ShippingPostalCode;
 
            List<String> f42sId = new List<String>();
            f42sId.add(record.Id);
            Decimal personnelTotal = 0;
            
            List<StrikeTeamExpenses> strikeTeamExpensesList = getStrikeTeamExpenseList(f42sId, salarySurveyPaidRateMap, salarySurveyHourlyRateMap, nonSuppressionRateMap, salarySurveyBasePaidRateMap);
            f42Record.strikeTeamExpensesList = strikeTeamExpensesList;
            if(strikeTeamExpensesList.size() > 0) {
                for(StrikeTeamExpenses strikeRecord : strikeTeamExpensesList) {
                    personnelTotal = personnelTotal + Decimal.valueOf(strikeRecord.totalForThisF42);
                    strikeRecord.totalForThisF42 = String.valueOf(formatCurrency(Decimal.valueOf(strikeRecord.totalForThisF42).setScale(2)));
                }
            } 
            if(personnelTotal != 0 || personnelTotal!= null) {
                f42Record.totalPersonnel = String.valueOf(personnelTotal);
                f42Record.surchargePersonnel = String.valueOf((Decimal.valueOf(f42Record.totalPersonnel) * Decimal.valueOf(adminRateFactor)).setScale(2));
            }  else {
                f42Record.totalPersonnel ='0.00';
                f42Record.surchargePersonnel = '0.00';
            }
            f42Record.expenseClaim = getExpenseAmount(record.Id);
            f42Record.surchargeExpenseClaim = String.valueOf((Decimal.valueOf(f42Record.expenseClaim) * Decimal.valueOf(adminRateFactor)).setScale(2));
            f42Record.totalForThisF42 = String.valueOf(personnelTotal + Decimal.valueOf(f42Record.vehicleCost) + Decimal.valueOf(f42Record.surchargeEngine) + Decimal.valueOf(f42Record.surchargePersonnel) + Decimal.valueOf(f42Record.surchargeVehicle) + Decimal.valueOf(f42Record.expenseClaim) + Decimal.valueOf(f42Record.surchargeExpenseClaim) + Decimal.valueOf(f42Record.specialEquipFEMASubTotal));
            f42Record.expenseClaim = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.expenseClaim).setScale(2)));
            f42Record.vehicleCost = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.vehicleCost).setScale(2)));
            f42Record.vehicleDays = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.vehicleDays).setScale(2)));
            f42Record.supportOrOverheadVehicle = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.supportOrOverheadVehicle).setScale(2)));  
            f42Record.surchargeEngine = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeEngine).setScale(2)));
            f42Record.surchargeVehicle = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeVehicle).setScale(2)));
            f42Record.totalPersonnel = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totalPersonnel).setScale(2).setScale(2)));
            f42Record.surchargePersonnel = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargePersonnel).setScale(2)));
            f42Record.totalForThisF42 = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totalForThisF42).setScale(2)));
            f42Record.specialEquipmentTotal = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.specialEquipmentTotal).setScale(2)));
            f42Record.FEMACodTotal = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.FEMACodTotal).setScale(2)));
            f42Record.specialEquipFEMASubTotal = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.specialEquipFEMASubTotal).setScale(2)));
            f42Record.totleEngineHours = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totleEngineHours).setScale(2)));
            f42Record.surchargeExpenseClaim = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeExpenseClaim).setScale(2)));
            //f42DetailsList.add(f42Record);
        }
        //return f42DetailsList;
        return f42Record; 
    }
    // get Strike Team Expense List data
    private static List<StrikeTeamExpenses> getStrikeTeamExpenseList(List<String> f42s, Map<String,Decimal> salarySurveyPaidRateMap, Map<String,Decimal> salarySurveyHourlyRateMap,Map<String,Decimal> nonSuppressionRateMap, Map<String,Decimal> salarySurveyPaidBaseRateMap) {
        //List<StrikeTeamExpenses> StrikeTeamExpensesList = new List<StrikeTeamExpenses>();
        Map<String,StrikeTeamExpenses> StrikeTeamExpensesMap = new Map<String,StrikeTeamExpenses>();
        List<F_42_Personnel_Info__c> perssonelList = getPersonnelInfoList(f42s);
        List<F_42_Actual_Hours__c>  actualHoursList = [SELECT Id,Name,Date__c,End_Time__c,Hours__c,Start_Time__c FROM F_42_Actual_Hours__c WHERE F_42__c =: f42s];
        if(perssonelList.size() > 0) {
            for(F_42_Personnel_Info__c personnelRec : perssonelList) {
                StrikeTeamExpenses obj = new StrikeTeamExpenses();
                DateTime personnelStartDate;
                DateTime personnelEndDate;
                String starttimestr = personnelRec.Start_Time__c;
                String starthrs = starttimestr.substring(0,2);
                String startmins = starttimestr.substring(2);
                String endtimestr = personnelRec.End_Time__c;
                String endhrs = endtimestr.substring(0,2);
                String endmins = endtimestr.substring(2);
                personnelStartDate = DateTime.valueOf(String.valueOf(personnelRec.Start_Date__c).removeEnd(' 00:00:00') +' '+starthrs+':'+startmins+':00');
                personnelEndDate = DateTime.valueOf(String.valueOf(personnelRec.End_Date__c).removeEnd(' 00:00:00') +' '+endhrs+':'+endmins+':00');
 
                Decimal paidRates = 0.00;
                Decimal hours = 0.00;
                if(personnelRec.Portal_To_Portal__c) {
                    DateTimeCalculation dateDetails = getDateTimeCalculation(personnelStartDate, personnelEndDate);
                    hours = Decimal.valueOf(dateDetails.hours24);
                } else {
                    hours = getNonPToPHourswithTime(actualHoursList, personnelRec.Start_Date__c, personnelRec.End_Date__c, starttimestr, endtimestr);
                }
                if(salarySurveyPaidRateMap != null && salarySurveyPaidBaseRateMap != null && salarySurveyPaidBaseRateMap.containsKey(personnelRec.Rank_Job_Title__c) && salarySurveyPaidRateMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                    if(StrikeTeamExpensesMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                        if(personnelRec.Base_Rate__c) {
                            paidRates = salarySurveyPaidBaseRateMap.get(personnelRec.Rank_Job_Title__c);
                        } else {
                            paidRates = salarySurveyPaidRateMap.get(personnelRec.Rank_Job_Title__c);
                        }
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).onThisF42 = String.valueOf((Integer.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).onThisF42)) + 1);
                        Decimal total = (Decimal.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).totalForThisF42) + (hours * paidRates));
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).totalForThisF42 = String.valueOf(total);
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).hoursOnThisF42 = String.valueOf(Decimal.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).hoursOnThisF42) + hours);
                    } else {
                        if(personnelRec.Base_Rate__c ) {
                            paidRates = salarySurveyPaidBaseRateMap.get(personnelRec.Rank_Job_Title__c);
                        } else {
                            paidRates = salarySurveyPaidRateMap.get(personnelRec.Rank_Job_Title__c);
                        }
                        obj.personnelType = personnelRec.Rank_Job_Title__c;
                        obj.hourlyRate = String.valueOf(salarySurveyHourlyRateMap.get(personnelRec.Rank_Job_Title__c));
                        obj.paidRate = String.valueOf(paidRates);
                        obj.onThisF42 = '1';
                        Decimal total = (hours * paidRates * Decimal.valueOf(obj.onThisF42));
                        obj.hoursOnThisF42 = String.valueOf(hours);
                        obj.totalForThisF42 = String.valueOf(total);
                        StrikeTeamExpensesMap.put(personnelRec.Rank_Job_Title__c,obj);
                    }
                } else if(nonSuppressionRateMap != null && nonSuppressionRateMap.containsKey(personnelRec.Rank_Job_Title__c) && salarySurveyPaidRateMap != null) {
                    if(StrikeTeamExpensesMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                        if(personnelRec.Base_Rate__c) {
                            paidRates = salarySurveyPaidRateMap.get('Firefighter/FF-PMedic');
                        } else if(nonSuppressionRateMap != null && nonSuppressionRateMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                            paidRates = nonSuppressionRateMap.get(personnelRec.Rank_Job_Title__c);
                        }
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).onThisF42 = String.valueOf((Integer.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).onThisF42)) + 1);
                        Decimal total = (Decimal.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).totalForThisF42) + (hours * paidRates));
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).totalForThisF42 = String.valueOf(total);
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).hoursOnThisF42 = String.valueOf(Decimal.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).hoursOnThisF42) + hours);
                    } else {
                        if(personnelRec.Base_Rate__c ) {
                            paidRates = salarySurveyPaidRateMap.get('Firefighter/FF-PMedic');
                        } else {
                            paidRates = nonSuppressionRateMap.get(personnelRec.Rank_Job_Title__c);
                        }
                        obj.personnelType = personnelRec.Rank_Job_Title__c;
                        obj.hourlyRate = String.valueOf(paidRates);
                        obj.paidRate = String.valueOf(paidRates);
                        obj.onThisF42 = '1';
                        Decimal total = (hours * paidRates * Decimal.valueOf(obj.onThisF42));
                        obj.hoursOnThisF42 = String.valueOf(hours);
                        obj.totalForThisF42 = String.valueOf(total);
                        StrikeTeamExpensesMap.put(personnelRec.Rank_Job_Title__c,obj);
                    }
                } else if(salarySurveyPaidRateMap != null && salarySurveyPaidRateMap.containsKey('Firefighter/FF-PMedic')){
                    if(StrikeTeamExpensesMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).onThisF42 = String.valueOf((Integer.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).onThisF42)) + 1);     
                        Decimal total = (Decimal.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).totalForThisF42) + (hours * salarySurveyPaidRateMap.get('Firefighter/FF-PMedic')));
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).totalForThisF42 = String.valueOf(total);
                        StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).hoursOnThisF42 = String.valueOf(Decimal.valueOf(StrikeTeamExpensesMap.get(personnelRec.Rank_Job_Title__c).hoursOnThisF42) + hours);
                    } else {
                        obj.personnelType = personnelRec.Rank_Job_Title__c;
                        obj.hourlyRate = String.valueOf(salarySurveyHourlyRateMap.get('Firefighter/FF-PMedic'));
                        obj.paidRate = String.valueOf(salarySurveyPaidRateMap.get('Firefighter/FF-PMedic'));
                        obj.onThisF42 = '1';
                        Decimal total = (hours * salarySurveyPaidRateMap.get('Firefighter/FF-PMedic') * Decimal.valueOf(obj.onThisF42));
                        obj.hoursOnThisF42 = String.valueOf(hours);
                        obj.totalForThisF42 = String.valueOf(total);
                        StrikeTeamExpensesMap.put(personnelRec.Rank_Job_Title__c,obj);
                    }
                }  
            }
        }
        return StrikeTeamExpensesMap.values();//StrikeTeamExpensesList;
    } 
    // get Personnel Infor list of F-42
    private static List<F_42_Personnel_Info__c>  getPersonnelInfoList(List<String> f42s) {
        return [SELECT Id,Name,F_42__c,Is_Job_Title_Other__c,Rank_Job_Title__c,MACS_ID__c,Start_Date__c,Start_Time__c,End_Date__c,End_Time__c,CDF__c,Portal_To_Portal__c,SSN__c,Base_Rate__c FROM F_42_Personnel_Info__c WHERE F_42__c =:f42s];
    }
    // Get Apparatus Type values
    private static String getApparatusType(String appratusType){
        String erType = null;
        if(appratusType == '1' ) erType = 'Type I';
        else if (appratusType == '2') erType = 'Type II';
        else if (appratusType == '3') erType = 'Type III';
        else if (appratusType == '4' || appratusType == '5' || appratusType == '6' || appratusType == '7') erType = 'Type IV - VII';
        else if (appratusType == 'WT-1') erType = 'Water Tender Tactical I';
        else if (appratusType == 'WT-2') erType = 'Water Tender Tactical II';
        return erType;
    }
   
    //Get Expense claim Amount
    private static String getExpenseAmount(String f42Id) {
        String expanseAmount = '0.00';
        List<Reimbursement__c> expanseClaimList = [SELECT Id,Total_Reimbursement_Amount__c,Status__c FROM Reimbursement__c WHERE F_42__c=:f42Id];
        if(expanseClaimList.size() > 0) {
            if(expanseClaimList[0].Status__c != 'Approved') {
                throw new AuraHandledException('Please Approve the Expense Claim related to F42');
            }
            if(expanseClaimList[0].Total_Reimbursement_Amount__c != null) {
                expanseAmount = String.valueOf(expanseClaimList[0].Total_Reimbursement_Amount__c);
            }
        }
        return expanseAmount;
    }
    //Get Agency Salary Survey 
    private static List<Agency_Salary_Survey__c> getAgencySalarySurvey(String agencyId,Date f42MinDate){
        List<Agency_Salary_Survey__c> agencySalarySurveyList = [SELECT Id,Start_Date__c,END_Date__c,Account__c,Account__r.Name,
                                                                (SELECT Id, Classification_Title__c, Current_Rate__c,MOU_MOA__c,Base_Rates__c FROM Salary_Survey_Line_Items__r WHERE Status__c=:MARS_Constants.SURVEY_STATUS_ACTIVE)
                                                                FROM Agency_Salary_Survey__c WHERE (Start_Date__c<=:f42MinDate AND (End_Date__c = null OR End_Date__c >=:f42MinDate)) AND Account__c=:agencyId
                                                                AND (Status__c=:MARS_Constants.SURVEY_STATUS_REVIEWED OR Status__c=:MARS_Constants.SURVEY_STATUS_REVISED OR Status__c=:MARS_Constants.SURVEY_STATUS_EXPIRED) ORDER BY Start_Date__c  DESC LIMIT 1];

        return agencySalarySurveyList;
    }
    //Get Agency Non Suppression Line Item
    private static List<Agency_Non_Suppression_Personnel__c> getAgencyNonSuppresssionList(String agencyId,Date f42MinDate){
        List<Agency_Non_Suppression_Personnel__c> agencyNonSuppressionList = [SELECT Id,Start_Date__c,End_Date__c,Agency__c,Agency__r.Name,
                                                                (SELECT Id, Classification_Title__c, Current_Rate__c FROM Agency_Non_Suppression_Line_Items__r WHERE (Status__c =: MARS_Constants.SURVEY_STATUS_ACTIVE OR Status__c =: MARS_Constants.SURVEY_STATUS_REVISED))
                                                                FROM Agency_Non_Suppression_Personnel__c WHERE (Start_Date__c<=:f42MinDate AND (End_Date__c = null OR End_Date__c >=:f42MinDate)) AND Agency__c=:agencyId
                                                                AND (Approval_Status__c=:MARS_Constants.SURVEY_STATUS_REVIEWED OR Approval_Status__c=:MARS_Constants.SURVEY_STATUS_REVISED OR Approval_Status__c=:MARS_Constants.SURVEY_STATUS_EXPIRED) ORDER BY Start_Date__c DESC LIMIT 1];

        return agencyNonSuppressionList;
    }
    // Get Agency Admin Rates
    private static List<Agency_Admin_Rates__c> getAgencyAdminRate(String agencyId,Date f42MinDate){
        List<Agency_Admin_Rates__c> agencyAdminRateList = [SELECT Id,Start_Date__c,End_Date__c,Agency__c,Agency__r.Name,Administrative_Rate_Indirect_Cost_Direct__c
                                                                        FROM Agency_Admin_Rates__c WHERE (Start_Date__c <=: f42MinDate AND (End_Date__c = null OR End_Date__c >=:f42MinDate)) AND Agency__c=:agencyId
                                                                        AND (Approval_Status__c=:MARS_Constants.SURVEY_STATUS_REVIEWED OR Approval_Status__c=:MARS_Constants.SURVEY_STATUS_REVISED OR Approval_Status__c=:MARS_Constants.SURVEY_STATUS_EXPIRED) ORDER BY Start_Date__c DESC LIMIT 1];

        return  agencyAdminRateList;
    }
    // Get CFAA Records
    private static List<CFAA__c> getCFAA(Date f42MinDate){
        List<CFAA__c> cfaaList = [SELECT Id,Name,Default_Admin_Rate__c,Start_Date__c,END_Date__c,
                                                                (SELECT Id,CFAA__c,Name, Unit_of_Measure__c,Type__c,Support_Equipment_Type__c,Straight_Time_Rate__c,Emergency_Apparatus_Type__c,Order_No__c,Other_Role__c,Over_Time_Rate__c,Personnel_Role__c,RecordType.Name,RecordTypeId FROM CFAA_Line_Items__r ORDER BY CreatedDate )
                                                                FROM CFAA__c WHERE (Start_Date__c<=:f42MinDate AND (End_Date__c = null OR End_Date__c >=:f42MinDate)) ORDER BY Start_Date__c DESC LIMIT 1];

        return cfaaList;
    }
    // Get FEMA code Records
    private static List<FEMA_Code__c> getFEMARecords(Date f42MinDate) {
        List<FEMA_Code__c> agencyFEMAList = [SELECT Id,Name,Effective_Date__c,End_Date__c,
                                            (SELECT Id,Name,Current_Rate__c,Equipment__c,Unit__c,Specifications__c,HP__c,Capacity_Size__c  FROM FEMA_Schedule_of_Equipment__r)
                                            FROM FEMA_Code__c WHERE (Effective_Date__c<=:f42MinDate AND (End_Date__c = null OR End_Date__c >=:f42MinDate)) AND Status__c =: MARS_Constants.SURVEY_STATUS_ACTIVE ORDER BY Effective_Date__c DESC LIMIT 1];
    
        return agencyFEMAList;
    }
    // Get Special equipment rate
    private static List<Agency_Special_Equipment__c> getSpecialEquipment(String agencyId, Date f42MinDate) {
        List<Agency_Special_Equipment__c> agencySpecialEquipList = [SELECT Id,Start_Date__c,End_Date__c,Agency__c,Agency__r.Name,
                                                                        (SELECT Id,FEMA_CODE__c,Revised_Rate__c,Current_Rate__c,Special_Equipment_Type__c  FROM Agency_Special_Equipment_Line_Items__r  WHERE (Status__c =: MARS_Constants.SURVEY_STATUS_ACTIVE OR Status__c =: MARS_Constants.SURVEY_STATUS_REVISED))
                                                                        FROM Agency_Special_Equipment__c WHERE (Start_Date__c<=:f42MinDate AND (End_Date__c = null OR End_Date__c >=:f42MinDate)) AND Agency__c=:agencyId
                                                                        AND (Approval_Status__c=:MARS_Constants.SURVEY_STATUS_REVIEWED OR Approval_Status__c=:MARS_Constants.SURVEY_STATUS_REVISED OR Approval_Status__c=:MARS_Constants.SURVEY_STATUS_EXPIRED) ORDER BY Start_Date__c DESC];


        return agencySpecialEquipList;
    }
    private static String formatCurrency(Decimal x){
        String y = String.valueOf(x);
        String z = '.';
        if(y.contains(',')) z = ',';
        y = y.substring(0, y.indexOf(z));
        if(x - Decimal.valueOf(y) == 0)
            return String.valueOf(x.format()) + z + '00';
        else return String.valueOf(x.format());
    }
    private static DateTimeCalculation getDateTimeCalculation(Datetime startDate, DateTime endDate) {
        DateTimeCalculation dt = new DateTimeCalculation();
        Long days = 0;
        Decimal minutesToAdd = 0.0;

        Decimal hoursInFraction = (Decimal.valueOf(endDate.getTime() - startDate.getTime())/(1000*60*60)).setScale(2);
        Long hoursInInteger = (endDate.getTime() - startDate.getTime())/(1000*60*60);
        Decimal hours24Fraction = hoursInFraction - hoursInInteger;
        Decimal equipmentHrs = 0.0;
        Decimal hours24 = 0.0;
        Decimal dayDiff = 0.00;
        if(hours24Fraction >= 0.01 && hours24Fraction <= 0.25) {
            minutesToAdd = 0.25;
        } else if(hours24Fraction >= 0.26 && hours24Fraction <= 0.50) {
            minutesToAdd = 0.50;
        } else if(hours24Fraction >= 0.51 && hours24Fraction <= 0.75) {
            minutesToAdd = 0.75;
        } else if(minutesToAdd >= 0.76) {
            hoursInInteger += 1;
        }
        hours24 = hoursInInteger + minutesToAdd;
        Long hoursToday =  Integer.valueOf((hours24/24));
        Decimal dayInFraction =  (hours24/24);
        dayDiff = dayInFraction - hoursToday;
        Decimal hoursIn16Fraction = ((hours24/24)*16).setScale(2);
        Long hoursIn16Integer = Integer.valueOf((hours24/24)*16);
        Decimal hours16Fraction = hoursIn16Fraction - hoursIn16Integer;
        if((dayDiff).setScale(2) >= 0.66) { 
            equipmentHrs = (hoursToday * 16) + 16;
        } else if((dayDiff).setScale(2) < 0.66 && hoursToday == 0) { 
            equipmentHrs = (dayInFraction * 24).setScale(2);
        } else {
            equipmentHrs = ((hoursToday * 16) + (dayDiff * 24).setScale(2));
        }
        if(hours24 < 24) {
            days = 1;
        } else {
            if(dayDiff != 0.00) {
                days = hoursToday + 1;
            } else {
                days = hoursToday;
            }
        }
        dt.hours24 = String.valueOf(hours24);
        dt.hours16 = String.valueOf(equipmentHrs);
        dt.days = String.valueOf(days);
        return dt;
    }
    private static Map<String, List<Agency_Rate_Agreement_Line_Item__c>> getAgreementLineItemMap(String accountId) {
        Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = new Map<String, List<Agency_Rate_Agreement_Line_Item__c>>();
        for (Agency_Rate_Agreement_Line_Item__c eachRecord :
        [ SELECT Id, Name, OT__c,
                PTP__c FROM Agency_Rate_Agreement_Line_Item__c Where
                Agency_Rate_Agreement__r.Agency__c =:accountId AND Agency_Rate_Agreement__r.Approval_Status__c IN ('Approved','Revised')]) {
            for (String name : eachRecord.Name.split(';')) {
                if(agencyAgreementMap.get(name) == null) {
                    agencyAgreementMap.put(name, new List<Agency_Rate_Agreement_Line_Item__c>());
                }
                agencyAgreementMap.get(name).add(eachRecord);
            }
        }
        return agencyAgreementMap;
    }
    //get total hours of Non Portal to Portal user getNonPToPHours
    private static Decimal getNonPToPHours(List<F_42_Actual_Hours__c> actualHoursList, Date startDate, Date endDate) {
        Decimal totalHours = 0.00;
        if(actualHoursList != null || !actualHoursList.isEmpty()) {
            for(F_42_Actual_Hours__c acRecord : actualHoursList) {
                if(acRecord.Date__c >= startDate && acRecord.Date__c <= endDate) {
                    totalHours += acRecord.Hours__c;
                }
            }
        }
        return totalHours;
    }
     //get total hours of Non Portal to Portal user
     private static Decimal getNonPToPHourswithTime(List<F_42_Actual_Hours__c> actualHoursList, Date startDate, Date endDate, string pstartTime, string pEndTime) {
        Decimal totalHours = 0.00;
        if(actualHoursList != null && !actualHoursList.isEmpty()) {
            for(F_42_Actual_Hours__c acRecord : actualHoursList) {
                if(acRecord.Date__c >= startDate && acRecord.Date__c <= endDate) {
                    if(acRecord.Date__c != startDate && acRecord.Date__c != endDate){
                        totalHours += acRecord.Hours__c;
                    }
                    if(acRecord.Date__c == startDate || acRecord.Date__c == EndDate){
                        if(acRecord.Date__c == startDate) {
                            if((pstartTime < acRecord.start_time__c) || (pstartTime == acRecord.start_time__c)) {
                                totalHours += acRecord.Hours__c;
                            }
                            if(pstartTime > acRecord.start_time__c) {
                                totalHours+=mathForHours(pstartTime,acRecord.End_time__c);
                            }
                        }
                        if(acRecord.Date__c == EndDate) {
                            if((pEndTime > acRecord.End_time__c) || (pEndTime == acRecord.End_time__c) ) {
                                totalHours += acRecord.Hours__c;
                            }
                            if(pEndTime < acRecord.End_time__c) {
                                totalHours+=mathForHours(acRecord.start_time__c,pEndTime);
                            }
                        }
                        /*if(pstartTime >  acRecord.start_time__c && pEndTime < acRecord.End_time__c){
                            totalHours += mathForHours(pstartTime, pEndTime);
                        }
                        if(pstartTime <  acRecord.start_time__c && pEndTime > acRecord.End_time__c){
                            totalHours += acRecord.Hours__c;
                        }
                        if(pstartTime < acRecord.start_time__c && pEndTime < acRecord.End_time__c){
                            totalHours += mathForHours(acRecord.start_time__c, pEndTime);
                            //totalHours += pEndTime - acRecord.start_time__c do the math
                        }
                        if(pstartTime > acRecord.start_time__c && pEndTime > acRecord.End_time__c){
                            totalHours += mathForHours(pstartTime, acRecord.End_time__c);
                            //totalHours += acRecord.End_time__c - pstartTime do the math
                        }
                        if(pstartTime == acRecord.start_time__c && pEndTime == acRecord.End_time__c){
                            totalHours += mathForHours(acRecord.start_time__c, acRecord.End_time__c);
                            //totalHours += acRecord.End_time__c - pstartTime do the math
                        }*/
                    }
                }
            }
        }
        return totalHours;
    }
    
    public static Decimal mathForHours(string startTime, string EndTime) {
        Decimal hours = 0;
        decimal mins = 0;
        decimal diff = decimal.valueOf(EndTime) - decimal.valueOf(startTime);
        string differnece = string.ValueOf(diff);
        if(differnece.length() > 2) {
            hours = decimal.valueOf(differnece.substring(0, differnece.length() - 2));
             mins = decimal.valueOf(differnece.right(2));
            if(mins > 60) {
                mins = mins - 40;
            }
            mins = mins/60;
            hours = hours + mins;
            hours = hours.setScale(2);
            return hours;
        }else {
            mins =  decimal.valueOf(differnece);
            if(mins > 60) {
                 mins = mins - 40;
            }
            hours = mins/60;
            hours = hours.setScale(2);
            return hours;
        }
    }
}