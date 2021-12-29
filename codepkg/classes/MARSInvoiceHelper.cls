/**
 * Created by Pankaj on 2021-05-27.
 */

public without sharing class MARSInvoiceHelper {
    // create invoice agncy wise under 1 incident 
    public static List<String> createInvoiceStaging(String incidentNumber, String agencyId, List<String> f42s, String fundingRuleId, String parentInvoiceId, String invoiceType, List<String> expenseClaims) {
        System.debug('incidentNumber=='+incidentNumber+ ' agencyId='+agencyId+ ' f42s='+f42s + ' fundingRuleId='+fundingRuleId+' invoiceType='+invoiceType+ ' expenseClaims='+expenseClaims+' parentInvoiceId='+parentInvoiceId);
        List<String> invoiceIds = new List<String>();  
        Map<String,List<F42__c>> accountF42sMap = new  Map<String,List<F42__c>>();
        Map<String,List<Reimbursement__c>> accountExpenseClaimsMap = new  Map<String,List<Reimbursement__c>>();
        List<F42__c> f42List = new List<F42__c>();
        Map<String,List<FieldHistory>> f42History = new Map<String,List<FieldHistory>>();
        Map<String,List<FieldHistory>> f42PersonnelHistory = new Map<String,List<FieldHistory>>();
        Map<String,List<FieldHistory>> f42ActualHrsHistory = new Map<String,List<FieldHistory>>();
        Map<String,List<String>> accountExpenseClaimMap = new Map<String,List<String>>();
        Map<String, String> f42ExpenseClaimMap = new Map<String, String>();
        if(f42s !=null && !f42s.isEmpty()) {
            f42List = getF42s(f42s);
            f42History = getFieldHistF_42s(f42s);
            f42PersonnelHistory = getFieldHistPersonnel(f42List);
            f42ActualHrsHistory = getFieldHistActualHours(f42List);
        }
        List<Reimbursement__c> expanseClaimList = getExpensClaimList(expenseClaims,f42s);
        Map<String,ExpenseClaim> expenseClaimList = getExpenseClaim(expanseClaimList);
        Map<String,List<FieldHistory>> expenseClaimHistory = getFieldHistExpClaim(expanseClaimList);
        Map<String,List<FieldHistory>> expenseClaimLineItemHistory = getFieldHistExpClaimLineItem(expanseClaimList);
        List<Funding_Rule__c> fundingRules = getFundingSource(fundingRuleId); 
        String paidRateFactor = KeyValueHelper.getTextValue('MARS_Paid_Rate_Factor');


        // Map account to F42s 
        if(f42List != null && !f42List.isEmpty()) {
            for(F42__c record : f42List) {
                if(accountF42sMap.get(record.Account__c) == null) {
                    accountF42sMap.put(record.Account__c, new List<F42__c>());
                }
                accountF42sMap.get(record.Account__c).add(record);
                // Get F42 related Expense Claim
                for(Reimbursement__c expClaim : record.Reimbursements__r) {
                    f42ExpenseClaimMap.put(expClaim.F_42__c, expClaim.Id);
                }
            }
        }
        // Map account Expense Calim map 
        if(expenseClaims!= null && !expenseClaims.isEmpty() && expanseClaimList != null && !expanseClaimList.isEmpty()) {
            for(Reimbursement__c record : expanseClaimList) {
                if(accountExpenseClaimsMap.get(record.Account__c) == null) {
                    accountExpenseClaimsMap.put(record.Account__c, new List<Reimbursement__c>());
                }
                accountExpenseClaimsMap.get(record.Account__c).add(record);
            }
        }
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Invoice__c> parentInvoice =[SELECT Id, Name FROM Invoice__c WHERE Id =: parentInvoiceId ORDER BY CreatedDate DESC LIMIT 1];
        List<Invoice__c> childInvoice = new List<Invoice__c>();
        if(parentInvoiceId != null) {
            childInvoice = [SELECT Id, Name FROM Invoice__c WHERE Parent_Invoice__c =: parentInvoiceId ORDER BY CreatedDate DESC LIMIT 1];
        }
        Set<String> invoiceIdsToDelete = new Set<String>();
        Map<String, List<InvoicePayment>> accountFundingPayMap = new  Map<String, List<InvoicePayment>>();
        //Create invoice agencywise from F-42 And Related Expense Claim
        if(f42s != null && !f42s.isEmpty()) {
            for(String accountId : accountF42sMap.keySet()) {
                InvoicePDF invoiceRecord = createInvoiceDataFromF42(accountId, accountF42sMap.get(accountId), fundingRules, paidRateFactor, f42History, f42PersonnelHistory, f42ActualHrsHistory, expenseClaimList, expenseClaimHistory, expenseClaimLineItemHistory);
               
                if(accountFundingPayMap.get(accountId) == null) {
                    accountFundingPayMap.put(accountId, new List<InvoicePayment>());
                }
                accountFundingPayMap.get(accountId).addAll(invoiceRecord.fundingRulesForPaymnet);
                Invoice__c invoice = getInvoice(invoiceRecord, accountId, incidentNumber, fundingRuleId, invoiceType, parentInvoiceId, childInvoice, parentInvoice);
                invoiceList.add(invoice);
                if(parentInvoiceId != null && invoiceType != 'Amendment Invoice') {
                    invoiceIdsToDelete.add(parentInvoiceId);
                }
            }
        }
      
         //Create invoice agencywise from Expense Claim only // to do changes
        if(expenseClaims!= null && !expenseClaims.isEmpty()) {
            for(String accountId : accountExpenseClaimsMap.keySet()){
                InvoicePDF invoiceRecord = createInvoiceDataFromExpenseClaim(accountId, accountExpenseClaimsMap.get(accountId), fundingRules, expenseClaimList, expenseClaimHistory, expenseClaimLineItemHistory);
               
                if(accountFundingPayMap.get(accountId) == null) {
                    accountFundingPayMap.put(accountId, new List<InvoicePayment>());
                }
                accountFundingPayMap.get(accountId).addAll(invoiceRecord.fundingRulesForPaymnet);
                Invoice__c invoice = getInvoice(invoiceRecord, accountId, incidentNumber, fundingRuleId, invoiceType, parentInvoiceId, childInvoice, parentInvoice);
                invoiceList.add(invoice);
                if(parentInvoiceId != null && invoiceType != 'Amendment Invoice') {
                    invoiceIdsToDelete.add(parentInvoiceId);
                }
            }
        }

        upsert invoiceList;
        if(invoiceIdsToDelete.size() > 0) {
            List<Invoice_Payment__c> invoicePaymnetList = [SELECT Id FROM Invoice_Payment__c WHERE Invoice__c =: invoiceIdsToDelete];
            delete invoicePaymnetList;
        }
        List<F42__c> updateF42List = new List<F42__c>();
        List<F_42_Invoices__c> f42InvoiceList = new List<F_42_Invoices__c>();
        //create invoice PDF
        List<Invoice_Payment__c> invoicePaymentList = new List<Invoice_Payment__c>();
        if(invoiceList.size() > 0){
            for(Invoice__c inviceRecord : invoiceList) {
                invoiceIds.add(inviceRecord.Id);
                if(f42s!= null && !f42s.isEmpty()) {
                    if(accountF42sMap.containsKey(inviceRecord.Account__c)) {
                        for(F42__c record : accountF42sMap.get(inviceRecord.Account__c)){
                            //if(parentInvoiceId == null) {
                            if(invoiceType != 'Regenerate Invoice') {   
                                F_42_Invoices__c f42InvRec = new F_42_Invoices__c();
                                f42InvRec.F_42__c = record.Id;
                                f42InvRec.Invoice__c = inviceRecord.Id;
                                record.Invoice__c = inviceRecord.Id;
                                if(f42ExpenseClaimMap.containsKey(record.Id)) {
                                    f42InvRec.Expense_Claim__c = f42ExpenseClaimMap.get(record.Id);
                                }
                                updateF42List.add(record);
                                f42InvoiceList.add(f42InvRec);
                            }
                        }
                    }
                }
                if(expenseClaims!= null && !expenseClaims.isEmpty()) { 
                    for(Reimbursement__c expenseRec : accountExpenseClaimsMap.get(inviceRecord.Account__c)){
                        if(invoiceType != 'Regenerate Invoice') {    
                            F_42_Invoices__c f42InvRec = new F_42_Invoices__c();
                            f42InvRec.Expense_Claim__c = expenseRec.Id;
                            f42InvRec.Invoice__c = inviceRecord.Id;
                            f42InvoiceList.add(f42InvRec);
                        }
                    }
                }
                if(accountFundingPayMap.containsKey(inviceRecord.Account__c)) {
                    if(accountFundingPayMap.get(inviceRecord.Account__c) != null) {
                        for(InvoicePayment invPayment : accountFundingPayMap.get(inviceRecord.Account__c)){
                            Invoice_Payment__c invPay = new Invoice_Payment__c();
                            invPay.Invoice__c = inviceRecord.Id;
                            invPay.Funding_Source__c = invPayment.fundingSourceId;
                            invPay.Invoice_Percent__c = Decimal.valueOf(invPayment.invoiceFundingPercent);
                            invPay.Invoice_Amount__c = Decimal.valueOf(invPayment.invoiceFundingAmount);
                            invPay.Status__c = 'Pending';
                            invoicePaymentList.add(invPay);
                        }
                    }

                }
                System.enqueueJob(new GeneratePDFFromInvoice(String.valueOf(inviceRecord.Id)));
            }
        }
        update updateF42List;
        insert f42InvoiceList;
        insert invoicePaymentList;
        return invoiceIds;
    }
    // Invoice Wrapper class fro generate invoice
    public class InvoicePDF {
       public String incidentNumber{get; set;}
       public String invoiceDate{get; set;}
       public String incidentOrderNo{get; set;}
       public String incidentName{get; set;}
       public String MACSDesignator{get; set;}
       public String firstCharWithYearForInvoiceNo{get; set;} 
       public String remitToName{get; set;}
       public String remitToStreet{get; set;}
       public String remitToCity{get; set;}
       public String remitToState{get; set;}
       public String remitToZip{get; set;}

       public String federalTaxId{get; set;}
       public String federalDUNSNo{get; set;}
       public String supplierNo{get; set;}
       public String addressNo{get; set;}

       public String localAgencyName{get; set;}
       public String localAgencyAddress{get; set;}

       public List<SummaryInformation> summaryInformationList{get; set;}
       public String personnelTotal{get; set;}
       public String engReimbTotal{get; set;}
       public String supportVehicleTotal{get; set;}
       public String adminSurchargeTotal{get; set;}
       public String expenseReiumbTotal{get; set;}
       public String personnelHoursTotal{get; set;}
       public String summaryHoursTotal{get; set;}
       public String equipmentHoursTotal{get; set;}
       public String supportVehicleDaysTotal{get; set;}

       public String claimTotal{get; set;}
       public List<String> fundingRules{get; set;}
       public List<InvoicePayment> fundingRulesForPaymnet{get; set;}
       public List<VechicleRate> vechicleRateList{get; set;}
       public List<ApparatusRate> apparatusRateList{get; set;}
       public List<SalarySurveyRate> SalarySurveyRateList{get; set;}
       public String agencySalarySurveyonFile{get; set;}
       public string administrativeRate{get; set;}
       public string mileRate{get; set;}
       public List<F24Records> f24RecordsList{get; set;}
    }
    public class InvoicePayment {
        public String invoiceFundingPercent{get; set;}
        public String invoiceFundingAmount{get; set;}
        public String fundingSourceId{get; set;}
    }
    public class F24Records {
        public F42Details f42Details{get; set;}
        public F42DetailsUI f42DetailsUI{get; set;}
        public ExpenseClaim expenseClaim{get; set;}
        public List<FieldHistory> fieldHistExpClaim{get; set;}
        public List<FieldHistory> fieldHistExpClaimLineItem{get; set;}
        public List<FieldHistory> fieldHistF_42s{get; set;}
        public List<FieldHistory> fieldHistPersonnel{get; set;}
        public List<FieldHistory> fieldHistActualHours{get; set;}
    }
    public class FieldHistory {
        public String changeDate{get; set;}
        public String fieldName{get; set;}
        public String user{get; set;}
        public String originalValue{get; set;}
        public String newValue{get; set;}
    }
    public class FundingSourceData{
        public List<String> fundingRules{get; set;}
        public List<InvoicePayment> fundingRulesForPayment{get; set;}
    }
    public class F42Details {
        public String MACSDesignator{get; set;}
        public String incidentName{get; set;}
        public String strikeTeam{get; set;}
        public String orderNo{get; set;}
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
    public class SummaryInformation {
        public String unit{get; set;}
        public String reqNo{get; set;}
        public String strikeTeam{get; set;}
        public String departDateTime{get; set;}
        public String returnDateTime{get; set;}
        public String totalHours{get; set;}
        public String personnelTotal{get; set;}
        public String engineHours{get; set;}
        public String engineReimb{get; set;}
        public String supportVehicle{get; set;}
        public String expenseReiumb{get; set;}
        public String adminSurcharge{get; set;}
        public String totalDays{get; set;}
        public String personnelHours{get; set;}
        public String equipmentHours{get; set;}
        public String supportVehicleDays{get; set;}

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
    public class F42DetailsUI {
        public String agencyDesignator{get; set;} 
        public String strikeTeamAndTaskForce{get; set;}
        public String incidentOrderNumber{get; set;} 
        public String incidentRequestNumber{get; set;}
        public String incidentName{get; set;} 
        public String reportingLocation{get; set;}
        public String to{get; set;} 
        public String committedToIncidentDate{get; set;}
        public String committedToIncidentTime{get; set;} 
        public String returnToIncidentDate{get; set;}
        public String returnToIncidentTime{get; set;} 
        public String redispatchedToIncidentDate{get; set;}
        public String redispatchedToIncidentTime{get; set;} 
        public String oldIncidentName{get; set;}
        public String oldIncidentEndDate{get; set;} 
        public String oldIncidentOrderNumber{get; set;} 
        public String oldIncidentRequestNumber{get; set;}
        public String newIncidentName{get; set;}
        public String newIncidentStartDate{get; set;} 
        public String newIncidentOrderNumber{get; set;} 
        public String newIncidentRequestNumber{get; set;}
        public String overheadInformation{get; set;}
        public String ICSTitle{get; set;} 
        public String otherTitle{get; set;} 
        public String vehicleOwnership{get; set;}
        public String licenseNumber{get; set;} 
        public String vehicleType{get; set;}
        public String vehicleOther{get; set;} 
        public String beginningOdometer{get; set;}
        public String endingOdometer{get; set;} 
        public String totalMiles{get; set;}
        public String apparatus{get; set;} 
        public String apparatusType{get; set;}
        public String apparatusUnit{get; set;} 
        public String apparatusLicense{get; set;}
        public List<F42ActualHours> f42ActualHoursList {get; set;} 
        public List<PersonnelInfo> f42personnelInfoList{get; set;}
        public List<F42Comments> f42CommentsList{get; set;}
        public String lossOrDamageClaim{get; set;}
        public String supplyNumber{get; set;}
        public String agencyOrDeptName{get; set;}
        public String yourName{get; set;}
        public String yourPhoneNumber{get; set;}
        public String yourTitle{get; set;}
        public String payingAgency{get; set;} 
        public String payingAgencyOther{get; set;}
        public String printedName{get; set;}
        public String printedTitle{get; set;}
        public String printedDate{get; set;}
        public String calOESrepresentative{get; set;}
        public String calOESrepresentativeDate{get; set;}
        public String payingAgencySignature{get; set;}
        public String respondingAgencySignature{get; set;}
        public String OESVehicle{get; set;}
        public String FEMACode{get; set;}
        public String specialEquipment{get; set;}
        public String numberOfPersonnelonApp{get; set;}
    }
    public class PersonnelInfo {
        public String name{get; set;}
        public String MACSID{get; set;}
        public String jobTitle{get; set;}
        public String last4SSN{get; set;}
        public String startDate{get; set;}
        public String startTime{get; set;}
        public String endDate{get; set;}
        public String endTime{get; set;}
        public String portalToPortal{get; set;}
        public String baseRate{get; set;}
        public String CDF{get; set;}

    } 
    public class F42ActualHours {
        public String actualHoursDate{get; set;}
        public String actualHoursStartTime{get; set;}
        public String actualHoursEndTime{get; set;}
        public String actualHours{get; set;}
    }
    public class F42Comments {
        public String comments{get; set;}
        public String CommentsDate{get; set;}
        public String CommentsTime{get; set;}
    }

    public class DateTimeCalculation {
        public String hours24{get; set;}
        //public String pendingHours{get; set;}
        public String days{get; set;}
        public String hours16{get; set;}
    }

    public class ExpenseClaim {
        public String submittedDate{get; set;}
        public String comments{get; set;}
        public String incidentOrderNumber{get; set;}
        public String incidentRequestNumber{get; set;}
        public String localAgencyComments{get; set;}
        public String lodgingTotal{get; set;}
        public String MACIDs{get; set;}
        public String mealTotal{get; set;}
        public String MISCTotal{get; set;}
        public String mutualAidStaffComments{get; set;}
        public String printedName{get; set;}
        public String name{get; set;}
        public String strikeTeam{get; set;}
        public String totalReimbursementAmount{get; set;}
        public String unitNumber{get; set;}
        public String F_42Name{get; set;}
        public String incidentName{get; set;}
        public String attachmentType{get; set;}
        public String respondingAgencySignature{get; set;}
        public List<ExpenseClaimLineItem> expenseClaimLineItems{get; set;}
        public List<AttachedFiles> attachedFiles{get; set;}
    }
    public class ExpenseClaimLineItem {
        public String lineItemDate{get; set;}
        public String city{get; set;}
        public String lodging{get; set;}
        public String meal{get; set;}
        public String MISC{get; set;}
        public String amount{get; set;}
        public String description{get; set;}
        public String name{get; set;}
    }
    public class AttachedFiles {
        public String name{get; set;}
        public String type{get; set;}
    }
     
    // generate invoice data for  F42 
    public static InvoicePDF createInvoiceDataFromF42(String agencyId, List<F42__c> f42List, List<Funding_Rule__c> fundingRules, String paidRateFactor, Map<String,List<FieldHistory>> f42History, Map<String,List<FieldHistory>> f42PersonnelHistory, Map<String,List<FieldHistory>> f42ActualHrsHistory, Map<String,ExpenseClaim> expenseClaimList, Map<String,List<FieldHistory>> expenseClaimHistory, Map<String,List<FieldHistory>> expenseClaimLineItemHistory) {
        String jsonData='';
        Boolean isAdminRatePresent = false;
        List<VechicleRate> vechicleRateList = new List<VechicleRate>();
        List<ApparatusRate> apparatusRateList = new List<ApparatusRate>();
        List<SalarySurveyRate> salarySurveyRateList = new List<SalarySurveyRate>();
        Map<Id, Map<String,Decimal>> salarySurveyPaidRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<Id, Map<String,Decimal>> salarySurveyPaidBaseRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<Id, Map<String,Decimal>> salarySurveyHourlyRateMapBy42 = new Map<Id, Map<String,Decimal>>();
        Map<Id, Map<String,Decimal>> vechicleRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<Id, Map<String,Decimal>> apparatusRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<Id, Map<String,Decimal>> nonSuppressionRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<String, Decimal> adminRateMapByF42 = new Map<String, Decimal>();
        Map<Id,Map<String,Decimal>> femaCodeRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<Id, Map<String,Decimal>> speicalEquipmentRateMapByF42 = new Map<Id, Map<String,Decimal>>();
        Map<String, Decimal> mileRateByF42 = new Map<String, Decimal>();
        InvoicePDF ivoiceObj = new InvoicePDF();
        ivoiceObj.invoiceDate = System.now().format('MM/dd/yyyy');
            
        List<Date> f42MinDate = new List<Date>();
         String lastestF42; 
         Date maxDate;
        if(f42List != null && !f42List.isEmpty()) {
            for(F42__c record : f42List) {
                if(record.DI_Committed_to_Incident_Date__c != null) {
                    f42MinDate.add(record.DI_Committed_to_Incident_Date__c);
                } 
                if(maxDate == null) {
                    maxDate = record.DI_Committed_to_Incident_Date__c;
                    lastestF42 = record.Id;
                } else if(maxDate < record.DI_Committed_to_Incident_Date__c) {
                    maxDate = record.DI_Committed_to_Incident_Date__c;
                    lastestF42 = record.Id; 
                }
            }

            // Get CFAA Data
            List<CFAA__c> CFAAMap = getCFAA(f42MinDate);
            if(CFAAMap.size() > 0) {
                for(F42__c record : f42List) {
                    Map<String, Decimal> apparatusRateMap = new Map<String, Decimal>();
                    Map<String, Decimal> vechicleRateMap = new Map<String, Decimal>();
                    apparatusRateMapByF42.put(record.Id, apparatusRateMap);
                    vechicleRateMapByF42.put(record.Id, vechicleRateMap);
                    for(CFAA__c cfaadata : CFAAMap) {
                        if(cfaadata.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (cfaadata.End_Date__c == null || cfaadata.End_Date__c >= record.DI_Committed_to_Incident_Date__c)) {
                            for(CFAA_Line_Items__c cfaaLineItem : cfaadata.CFAA_Line_Items__r) {
                                if(cfaaLineItem.RecordType.Name == 'Support Equipment Rate') {
                                    if(!vechicleRateMap.containsKey(cfaaLineItem.Support_Equipment_Type__c)) {
                                        vechicleRateMap.put(cfaaLineItem.Support_Equipment_Type__c, cfaaLineItem.Straight_Time_Rate__c);
                                    }
                                } else if(cfaaLineItem.RecordType.Name == 'Emergency Apparatus Rate') {
                                    if(!apparatusRateMap.containsKey(cfaaLineItem.Emergency_Apparatus_Type__c)) {
                                        apparatusRateMap.put(cfaaLineItem.Emergency_Apparatus_Type__c,cfaaLineItem.Straight_Time_Rate__c);
                                    }
                                } else if(cfaaLineItem.RecordType.Name == 'POV Rate' && cfaaLineItem.Straight_Time_Rate__c != null ) {
                                        mileRateByF42.put(record.Id,cfaaLineItem.Straight_Time_Rate__c);
                                }
                            }  
                        }                                              
                    }
                }
                //For PDF First Page Latest Appratus Rate
                if(apparatusRateMapByF42 != null) {
                    Map<String, Decimal> apparatusRate = apparatusRateMapByF42.get(lastestF42);
                    for(String str: apparatusRate.keySet()) {
                        ApparatusRate apparatusRcord = new ApparatusRate();
                        apparatusRcord.apparatusType = str;
                        apparatusRcord.rate = String.valueOf(apparatusRate.get(str));
                        apparatusRateList.add(apparatusRcord);
                    }
                }
                //For PDF First Page Latest Viechicle Rate
                if(vechicleRateMapByF42 != null) {
                    Map<String, Decimal> vechicelRate = vechicleRateMapByF42.get(lastestF42);
                    for(String str: vechicelRate.keySet()) {
                        VechicleRate vechicleRecord = new VechicleRate();
                        vechicleRecord.vechicleType = str;
                        vechicleRecord.rate = String.valueOf(vechicelRate.get(str));
                        vechicleRateList.add(vechicleRecord);
                    }
                }
                ivoiceObj.vechicleRateList = vechicleRateList;
                ivoiceObj.apparatusRateList = apparatusRateList;
                ivoiceObj.mileRate = String.valueOf(mileRateByF42.get(lastestF42));
            }

            Set<String> overTimeCheckForClasTitle = new Set<String>{'Battalion Chief', 'Co. Officer/Capt./Lt.','App. Officer/Eng','Firefighter/FF-PMedic'};
            Map<String, List<Agency_Rate_Agreement_Line_Item__c>> agencyAgreementMap = getAgreementLineItemMap(agencyId);
            // get agency salary Survey
            List<Agency_Salary_Survey__c> agencySalarySurveyLineItem = getAgencySalarySurvey(agencyId, f42MinDate);
            if((CFAAMap !=null || !CFAAMap.isEmpty())|| (agencySalarySurveyLineItem != null && !agencySalarySurveyLineItem.isEmpty())) {
                for(F42__c record : f42List) {
                    Map<String, Decimal> salarySurveyPaidRateMap = new Map<String, Decimal>();
                    Map<String, Decimal> salarySurveyBasePaidRateMap = new Map<String, Decimal>();
                    Map<String, Decimal> salarySurveyHourlyRateMap = new Map<String, Decimal>();
                    salarySurveyPaidRateMapByF42.put(record.Id, salarySurveyPaidRateMap);
                    salarySurveyHourlyRateMapBy42.put(record.Id, salarySurveyHourlyRateMap);
                    salarySurveyPaidBaseRateMapByF42.put(record.Id, salarySurveyBasePaidRateMap);
                    Boolean isSalarySurveyPresent = false;
                    for(Agency_Salary_Survey__c salSurveyRec : agencySalarySurveyLineItem) {
                        if(salSurveyRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (salSurveyRec.END_Date__c == null || salSurveyRec.END_Date__c >= record.DI_Committed_to_Incident_Date__c)) {
                            isSalarySurveyPresent = true;
                            ivoiceObj.agencySalarySurveyonFile = String.valueOf(DateTime.valueOf(salSurveyRec.Start_Date__c+'00:00:00').format('MM/dd/yyyy'));// to do take date from latest first
                            for(Salary_Survey_Line_Items__c salSurLineItem : salSurveyRec.Salary_Survey_Line_Items__r) {
                                if(!salarySurveyPaidRateMap.containsKey(salSurLineItem.Classification_Title__c) && salSurLineItem.Current_Rate__c != null) {
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
                                    Decimal amount = salSurLineItem.Current_Rate__c;
                                    salarySurveyHourlyRateMap.put(salSurLineItem.Classification_Title__c, amount);
                                    if(isovertime) { //salSurLineItem.MOU_MOA__c
                                        salarySurveyPaidRateMap.put(salSurLineItem.Classification_Title__c,(amount * Decimal.valueOf(paidRateFactor)).setScale(2,System.RoundingMode.HALF_UP));
                                        salarySurveyBasePaidRateMap.put(salSurLineItem.Classification_Title__c,(salSurLineItem.Base_Rates__c * Decimal.valueOf(paidRateFactor)).setScale(2,System.RoundingMode.HALF_UP));
                                    } else {
                                        salarySurveyPaidRateMap.put(salSurLineItem.Classification_Title__c, amount);
                                        salarySurveyBasePaidRateMap.put(salSurLineItem.Classification_Title__c,salSurLineItem.Base_Rates__c);
                                    }
                                }
                            }
                        }
                    }

                    if(isSalarySurveyPresent == false) {
                        for(CFAA__c cfaadata : CFAAMap) {
                            if(cfaadata.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (cfaadata.End_Date__c == null || cfaadata.End_Date__c >= record.DI_Committed_to_Incident_Date__c)) {
                                for(CFAA_Line_Items__c sfaaRecord : cfaadata.CFAA_Line_Items__r) {
                                    if(sfaaRecord.RecordType.Name == 'Personnel Base Rate') {
                                        // check with Agreement records
                                        Boolean isovertime = false;
                                        if(overTimeCheckForClasTitle.contains(sfaaRecord.Personnel_Role__c)) {
                                            isovertime = true;
                                        } else if(agencyAgreementMap.containsKey(sfaaRecord.Personnel_Role__c)) {
                                            for(Agency_Rate_Agreement_Line_Item__c lineItem : agencyAgreementMap.get(sfaaRecord.Personnel_Role__c)) {
                                               if(lineItem.OT__c) {
                                                    isovertime = lineItem.OT__c;
                                                } 
                                            }
                                        }
                                        if(isovertime) { //salSurLineItem.MOU_MOA__c
                                            salarySurveyPaidRateMap.put(sfaaRecord.Personnel_Role__c,(sfaaRecord.Straight_Time_Rate__c * Decimal.valueOf(paidRateFactor)).setScale(2,System.RoundingMode.HALF_UP));
                                            salarySurveyBasePaidRateMap.put(sfaaRecord.Personnel_Role__c,(sfaaRecord.Straight_Time_Rate__c * Decimal.valueOf(paidRateFactor)).setScale(2,System.RoundingMode.HALF_UP));
                                        } else {
                                            salarySurveyPaidRateMap.put(sfaaRecord.Personnel_Role__c,sfaaRecord.Straight_Time_Rate__c);
                                            salarySurveyBasePaidRateMap.put(sfaaRecord.Personnel_Role__c,sfaaRecord.Straight_Time_Rate__c);
                                        } 
                                        salarySurveyHourlyRateMap.put(sfaaRecord.Personnel_Role__c,sfaaRecord.Straight_Time_Rate__c);
                                    }
                                }
                            }
                        }
                    }
                }
                //For PDF First page Latest Salary survey Rate
                if(salarySurveyHourlyRateMapBy42 != null) {
                    Map<String, Decimal> salarySurveyPaidRate = salarySurveyHourlyRateMapBy42.get(lastestF42);
                    for(String str: salarySurveyPaidRate.keySet()) {
                        SalarySurveyRate salarySurveyRecord = new SalarySurveyRate();
                        salarySurveyRecord.personnelRole = str;
                        salarySurveyRecord.rate = String.valueOf(salarySurveyPaidRate.get(str));
                        salarySurveyRateList.add(salarySurveyRecord);
                    }
                }
                ivoiceObj.SalarySurveyRateList = salarySurveyRateList;

            }

            // get non Suppression Personnel
            List<Agency_Non_Suppression_Personnel__c> agecyNonSuppressionLineItem = getAgencyNonSuppressionList(agencyId, f42MinDate);
            if(agecyNonSuppressionLineItem.size() > 0) {
                for(F42__c record : f42List) {
                    Map<String, Decimal> nonSuppressionRateMap = new Map<String, Decimal>();
                    nonSuppressionRateMapByF42.put(record.Id, nonSuppressionRateMap);
                    for(Agency_Non_Suppression_Personnel__c salNonSuppRec : agecyNonSuppressionLineItem) {
                        if(salNonSuppRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (salNonSuppRec.End_Date__c == null || salNonSuppRec.End_Date__c >= record.DI_Committed_to_Incident_Date__c)){
                            for(Agency_Non_Suppression_Line_Item__c nonSuppLineItem : salNonSuppRec.Agency_Non_Suppression_Line_Items__r) {
                                if(!nonSuppressionRateMap.containsKey(nonSuppLineItem.Classification_Title__c)){
                                    if(nonSuppLineItem.Classification_Title__c != null && nonSuppLineItem.Current_Rate__c != null) {
                                        nonSuppressionRateMap.put(nonSuppLineItem.Classification_Title__c,nonSuppLineItem.Current_Rate__c);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //Get administrator data
            List<Agency_Admin_Rates__c> agencyAdminData = getAgencyAdminRate(agencyId, f42MinDate);
            if((CFAAMap != null && !CFAAMap.isEmpty())|| (agencyAdminData != null && !agencyAdminData.isEmpty())) {
                for(F42__c record : f42List) {
                    //iterate over f42 and set data from admin rate
                    for(Agency_Admin_Rates__c adminRec : agencyAdminData) {
                        if(adminRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (adminRec.End_Date__c == null || adminRec.End_Date__c >= record.DI_Committed_to_Incident_Date__c)
                                && adminRec.Administrative_Rate_Indirect_Cost_Direct__c != null) {
                            adminRateMapByF42.put(record.Id, adminRec.Administrative_Rate_Indirect_Cost_Direct__c);
                        }
                    }
                    // iterate over 42 and check if admin rate data not present then set from CFAA
                    if(adminRateMapByF42.get(record.Id) == null) {
                        for(CFAA__c cfaadata : CFAAMap) {
                            if(cfaadata.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (cfaadata.End_Date__c == null || cfaadata.End_Date__c >= record.DI_Committed_to_Incident_Date__c)
                                    && cfaadata.Default_Admin_Rate__c != null) {
                                adminRateMapByF42.put(record.Id, cfaadata.Default_Admin_Rate__c);
                            }
                        }
                    }
                }
                ivoiceObj.administrativeRate = String.valueOf(adminRateMapByF42.get(lastestF42));
            }
          
           
            // Get Special Equipment Rate 
            List<Agency_Special_Equipment__c> specialEquipmentList = getSpecialEquipment(agencyId, f42MinDate);
            if(specialEquipmentList.size() > 0) {
                for(F42__c record : f42List) {
                    Map<String, Decimal> speicalEquipmentRateMap = new Map<String, Decimal>();
                    speicalEquipmentRateMapByF42.put(record.Id, speicalEquipmentRateMap);
                    for(Agency_Special_Equipment__c speEquipRec : specialEquipmentList) {
                        if(speEquipRec.Start_Date__c <= record.DI_Committed_to_Incident_Date__c && (speEquipRec.End_Date__c == null || speEquipRec.End_Date__c >= record.DI_Committed_to_Incident_Date__c)){
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
            List<FEMA_Code__c> femaCodeList = getFEMARecords(f42MinDate);
            if(femaCodeList.size() > 0) {
                for(F42__c record : f42List) {
                    Map<String, Decimal> femaCodeRateMap = new Map<String, Decimal>();
                    femaCodeRateMapByF42.put(record.Id, femaCodeRateMap);
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
            ivoiceObj.incidentName = f42List[0].Incident__r.Name;
            ivoiceObj.incidentOrderNo = f42List[0].Incident_Order__c;
            ivoiceObj.firstCharWithYearForInvoiceNo = createInvoicePrefix(fundingRules);
            ivoiceObj.MACSDesignator = f42List[0].Account__r.MACS_ID__c;
            ivoiceObj.remitToName = f42List[0].Account__r.Name;
            ivoiceObj.remitToStreet = f42List[0].Account__r.ShippingStreet;
            ivoiceObj.remitToCity = f42List[0].Account__r.ShippingCity;
            ivoiceObj.remitToState = f42List[0].Account__r.ShippingState;
            ivoiceObj.remitToZip = f42List[0].Account__r.ShippingPostalCode;
            ivoiceObj.federalTaxId = f42List[0].Account__r.Federal_Tax_ID__c;
            ivoiceObj.supplierNo = f42List[0].Account__r.Fiscal_Supplier_ID__c;
            ivoiceObj.addressNo = String.valueOf(f42List[0].Account__r.Fiscal_Address_Id__c);
            ivoiceObj.summaryInformationList = createSummaryData(f42List, salarySurveyPaidRateMapByF42, apparatusRateMapByF42, vechicleRateMapByF42, adminRateMapByF42, salarySurveyHourlyRateMapBy42, mileRateByF42, speicalEquipmentRateMapByF42, femaCodeRateMapByF42, nonSuppressionRateMapByF42, salarySurveyPaidBaseRateMapByF42);
            if(ivoiceObj.summaryInformationList != null) {
                Decimal personnelTotal = 0.0;
                Decimal engReimbTotal = 0.0;
                Decimal supportVehicleTotal = 0.0;
                Decimal adminSurchargeTotal = 0.0;
                Decimal expenseReiumbTotal = 0.0;
                Decimal personnelHoursTotal = 0.0;
                Decimal equipmentHoursTotal = 0.0;
                Decimal supportVehicleDaysTotal = 0.0;
                Decimal summaryHrsTotal = 0.0;
                //get total of all F-42s
                for(SummaryInformation sumInfo : ivoiceObj.summaryInformationList) {
                    if(sumInfo.personnelTotal != null) {
                        personnelTotal = personnelTotal + Decimal.valueOf(sumInfo.personnelTotal);
                        sumInfo.personnelTotal = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.personnelTotal).setScale(2)));
                    }
                    if(sumInfo.engineReimb != null) {
                        engReimbTotal = engReimbTotal + Decimal.valueOf(sumInfo.engineReimb);
                        sumInfo.engineReimb = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.engineReimb).setScale(2)));
                    }
                    if(sumInfo.supportVehicle != null) {
                        supportVehicleTotal = supportVehicleTotal + Decimal.valueOf(sumInfo.supportVehicle);
                        sumInfo.supportVehicle = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.supportVehicle).setScale(2)));
                    }
                    if(sumInfo.adminSurcharge != null) {
                        adminSurchargeTotal = adminSurchargeTotal + Decimal.valueOf(sumInfo.adminSurcharge);
                        sumInfo.adminSurcharge = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.adminSurcharge).setScale(2)));
                    }
                    if(sumInfo.expenseReiumb != null) {
                        expenseReiumbTotal = expenseReiumbTotal + Decimal.valueOf(sumInfo.expenseReiumb);
                        sumInfo.expenseReiumb = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.expenseReiumb).setScale(2)));
                    }
                    if(sumInfo.personnelHours != null) {
                        personnelHoursTotal = personnelHoursTotal + Decimal.valueOf(sumInfo.personnelHours);
                        sumInfo.personnelHours = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.personnelHours).setScale(2)));
                    }
                    if(sumInfo.totalHours != null) {
                        summaryHrsTotal = summaryHrsTotal + Decimal.valueOf(sumInfo.totalHours);
                        sumInfo.totalHours = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.totalHours).setScale(2)));
                    }
                    if(sumInfo.equipmentHours != null) {
                        equipmentHoursTotal = equipmentHoursTotal + Decimal.valueOf(sumInfo.equipmentHours);
                        sumInfo.equipmentHours = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.equipmentHours).setScale(2)));
                    }
                    if(sumInfo.supportVehicleDays != null) {
                        supportVehicleDaysTotal = supportVehicleDaysTotal + Decimal.valueOf(sumInfo.supportVehicleDays);
                        sumInfo.supportVehicleDays = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.supportVehicleDays).setScale(2)));
                    }
                }
                Decimal claimTotal = personnelTotal + engReimbTotal + supportVehicleTotal + adminSurchargeTotal + expenseReiumbTotal;
                ivoiceObj.claimTotal = String.valueOf(claimTotal);

                FundingSourceData fundingMap = getFundingData(fundingRules,claimTotal); 
                ivoiceObj.fundingRules = fundingMap.fundingRules;
                ivoiceObj.fundingRulesForPaymnet = fundingMap.fundingRulesForPayment;
                ivoiceObj.personnelTotal = String.valueOf(personnelTotal);
                ivoiceObj.engReimbTotal = String.valueOf(engReimbTotal);
                ivoiceObj.supportVehicleTotal = String.valueOf(supportVehicleTotal);
                ivoiceObj.adminSurchargeTotal = String.valueOf(adminSurchargeTotal);
                ivoiceObj.expenseReiumbTotal = String.valueOf(expenseReiumbTotal);
                ivoiceObj.personnelHoursTotal = String.valueOf(personnelHoursTotal);
                ivoiceObj.equipmentHoursTotal = String.valueOf(equipmentHoursTotal);
                ivoiceObj.supportVehicleDaysTotal = String.valueOf(supportVehicleDaysTotal);
                ivoiceObj.summaryHoursTotal = String.valueOf(summaryHrsTotal);
                ivoiceObj.f24RecordsList = createF42Record(f42List, salarySurveyPaidRateMapByF42, apparatusRateMapByF42, vechicleRateMapByF42, adminRateMapByF42, nonSuppressionRateMapByF42, salarySurveyHourlyRateMapBy42, mileRateByF42, speicalEquipmentRateMapByF42, femaCodeRateMapByF42, nonSuppressionRateMapByF42, salarySurveyPaidBaseRateMapByF42, f42History, f42PersonnelHistory, f42ActualHrsHistory, expenseClaimList, expenseClaimHistory, expenseClaimLineItemHistory);
            }
        }
        return ivoiceObj;
    }

    public static List<F24Records> createF42Record(List<F42__c> f42List, Map<Id, Map<String,Decimal>> salarySurveyPaidRateMapByF42, Map<Id,Map<String,Decimal>> apparatusRateMapByF42, Map<Id,Map<String,Decimal>> vechicleRateMapByF42, Map<String, Decimal> administrativeRate, Map<Id, Map<String,Decimal>> nonSuppressionRateMapBy42, Map<Id, Map<String,Decimal>> salarySurveyHourlyRateMapBy42, Map<String,Decimal> mileRateByF42,  Map<Id, Map<String,Decimal>> speicalEquipmentRateMapByF42, Map<Id,Map<String,Decimal>> femaCodeRateMapByF42, Map<Id,Map<String,Decimal>> nonSuppressionRateMapByF42,Map<Id, Map<String,Decimal>> salarySurveyPaidBaseRateMapByF42, Map<String,List<FieldHistory>> f42History, Map<String,List<FieldHistory>> f42PersonnelHistory, Map<String,List<FieldHistory>> f42ActualHrsHistory, Map<String,ExpenseClaim> expenseClaimList, Map<String,List<FieldHistory>> expenseClaimHistory, Map<String,List<FieldHistory>> expenseClaimLineItemHistory) {
        List<F24Records>  f24RecordsList = new List<F24Records>();
        for(F42__c record : f42List) {
            Map<String,Decimal> salarySurveyPaidRateMap = salarySurveyPaidRateMapByF42.get(record.Id);
            Map<String,Decimal> salarySurveyHourlyRateMap = salarySurveyHourlyRateMapBy42.get(record.Id);
            Map<String,Decimal> nonSuppressionRateMap = nonSuppressionRateMapBy42.get(record.Id);
            Map<String,Decimal> speicalEquipmentRateMap = speicalEquipmentRateMapByF42.get(record.Id);
            Map<String,Decimal> apparatusRateMap = apparatusRateMapByF42.get(record.Id);
            Map<String,Decimal> vechicleRateMap = vechicleRateMapByF42.get(record.Id);
            Map<String,Decimal> femaCodeRateMap = femaCodeRateMapByF42.get(record.Id);
            Map<String,Decimal> salarySurveyPaidBaseRateMap = salarySurveyPaidBaseRateMapByF42.get(record.Id);
            String mileRate = String.valueOf(mileRateByF42.get(record.Id));
            F24Records f42Record = new F24Records();
            String adminRateFactor = String.valueOf(administrativeRate.get(record.Id));
            f42Record.f42Details = createf42DetailsList(new List<F42__c>{record}, salarySurveyPaidRateMap, apparatusRateMap, vechicleRateMap, adminRateFactor, salarySurveyHourlyRateMap, mileRate, speicalEquipmentRateMap, femaCodeRateMap, nonSuppressionRateMap, salarySurveyPaidBaseRateMap);
            f42Record.f42DetailsUI = createf42DetailsUIList(new List<F42__c>{record});
            f42Record.expenseClaim = expenseClaimList.get(record.Id);//getExpenseClaim(record.Id,null);Map<String,ExpenseClaim> 
            f42Record.fieldHistExpClaim = expenseClaimHistory.get(record.Id); //getFieldHistExpClaim(record.Id, '');
            f42Record.fieldHistExpClaimLineItem = expenseClaimLineItemHistory.get(record.Id); //getFieldHistExpClaimLineItem(record.Id, '');
            f42Record.fieldHistF_42s = f42History.get(record.Id);//getFieldHistF_42s(record.Id);
            f42Record.fieldHistActualHours = f42ActualHrsHistory.get(record.Id);// getFieldHistActualHours(record.Id);
            f42Record.fieldHistPersonnel = f42PersonnelHistory.get(record.Id); //getFieldHistPersonnel(record.Id);
            f24RecordsList.add(f42Record);
        }
        return f24RecordsList;
    }

    public static F42DetailsUI createf42DetailsUIList(List<F42__c> f42List) { 
        F42DetailsUI f42Record = new F42DetailsUI();
        for(F42__c record : f42List) {
            f42Record.agencyDesignator = record.Account__r.Mars_Agency_Designator__c;
            f42Record.strikeTeamAndTaskForce = record.Strike_Team__c;
            f42Record.incidentOrderNumber = record.Incident_Order__c;
            f42Record.incidentRequestNumber = record.Incident_Request_Number__c;
            f42Record.to = record.Incident__r.Incident_Type__c;
            f42Record.incidentName = record.Incident__r.Name;
            f42Record.numberOfPersonnelonApp = record.PI_NUMBER_OF_PERSONNEL_ON_APPARATUS__c;
            f42Record.reportingLocation = record.DI_REPORTING_LOCATION__c;
            if(record.DI_Committed_to_Incident_Date__c != null)
                f42Record.committedToIncidentDate = String.valueOf(DateTime.valueOf(record.DI_Committed_to_Incident_Date__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.committedToIncidentTime = String.valueOf(record.DI_Committed_to_Incident_Time__c);  
            if(record.DI_Return_from_Incident_Date__c != null) 
                f42Record.returnToIncidentDate = String.valueOf(DateTime.valueOf(record.DI_Return_from_Incident_Date__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.returnToIncidentTime = String.valueOf(record.DI_Return_from_Incident_Time__c);
            if(record.DI_Redispatched_Date__c != null)
                f42Record.redispatchedToIncidentDate =  String.valueOf(DateTime.valueOf(record.DI_Redispatched_Date__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.redispatchedToIncidentTime =  String.valueOf(record.DI_Redispatched_Time__c);
            f42Record.oldIncidentName = record.DF_OLD_INCIDENT__c;
            if(record.DF_Dispatch_From_End_Date__c != null)
                f42Record.oldIncidentEndDate = String.valueOf(DateTime.valueOf(record.DF_Dispatch_From_End_Date__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.oldIncidentOrderNumber = record.DF_OLD_INCIDENT__r.Order_No__c;
            f42Record.oldIncidentRequestNumber = record.DF_OLD_INCIDENT_REQUEST__c;
            f42Record.newIncidentName = record.DT_NEW_INCIDENT__c;
            if(record.DT_Dispatch_To_Start_Date__c != null)
                f42Record.newIncidentStartDate = String.valueOf(DateTime.valueOf(record.DT_Dispatch_To_Start_Date__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.newIncidentOrderNumber = record.DT_NEW_INCIDENT__r.Order_No__c;
            f42Record.newIncidentRequestNumber = record.DT_NEW_INCIDENT_REQUEST__c;
            f42Record.overheadInformation = record.OH_OVERHEAD_TYPE__c;
            f42Record.ICSTitle = record.OH_ICS_Title__c;
            f42Record.otherTitle = record.OH_OTHER_ICS_TITLE__c;
            f42Record.vehicleOwnership = record.SV_VEHICLE_OWNERSHIP__c;
            f42Record.licenseNumber = record.SV_LICENSE__c;
            f42Record.vehicleType = record.SV_TYPE__c;
           
            if(record.SV_TOTAL_MILES__c != null && record.SV_BEGINNING_ODODMETER__c != null && record.SV_ENDING_ODOMETER__c != null) {
                f42Record.totalMiles = String.valueOf(formatCurrency(record.SV_TOTAL_MILES__c));
                f42Record.beginningOdometer = String.valueOf(formatCurrency(record.SV_BEGINNING_ODODMETER__c));
                f42Record.endingOdometer = String.valueOf(formatCurrency(record.SV_ENDING_ODOMETER__c));
            }
            f42Record.apparatus = record.ER_APPARATUS__c;
            f42Record.apparatusType = record.ER_TYPE__c;
            f42Record.apparatusUnit = record.ER_UNIT__c;
            f42Record.apparatusLicense = record.ER_LICENSE_NUMBER__c;
            if(record.SN_LOSS_DAMAGE_CLAIM__c) {
                f42Record.lossOrDamageClaim = 'Yes';
            } else {
                f42Record.lossOrDamageClaim = 'No';
            }
            if(record.ER_CDF_OES_VEHICLE__c)
                f42Record.OESVehicle = 'Yes';
            else
                f42Record.OESVehicle = 'No';
            f42Record.FEMACode = record.ER_FEMA_CODES__c;    
            f42Record.specialEquipment =  record.ER_SPECIAL_EQUIPMENT__c;
            f42Record.supplyNumber = record.SN_SUPPLY_NUMBER__c; 
            f42Record.agencyOrDeptName = record.RA_AGENCY_NAME__c;
            f42Record.yourName = record.RA_YOUR_NAME__c;
            f42Record.yourPhoneNumber = record.RA_YOUR_PHONE__c;
            f42Record.yourTitle = record.RA_YOUR_TITLE__c;
            f42Record.payingAgency = record.PA_PAYING_AGENCY__c;
            f42Record.payingAgencyOther = record.PA_OTHER__c;
            f42Record.printedName = record.PA_PRINTED_NAME__c;
            f42Record.printedTitle = record.PA_ICS_POSITION_TITLE__c;
            if(record.PA_DATE__c != null)
                f42Record.printedDate  = String.valueOf(DateTime.valueOf(record.PA_DATE__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.calOESrepresentative = record.PA_Cal_OES_REPRESENTATIVE__c;
            if(record.PA_CALOESREP_DATE__c != null)
                f42Record.calOESrepresentativeDate = String.valueOf(DateTime.valueOf(record.PA_CALOESREP_DATE__c+' 00:00:00').format('MM/dd/yyyy'));
            f42Record.f42personnelInfoList = getPersonnelList(record.F_42_Personnel_Info__r);
            f42Record.f42ActualHoursList = getActualHoursList(record.F_42_Actual_Hours__r);
            f42Record.f42CommentsList = getCommentsList(record.F_42_Comments__r);

            List<ContentVersion> signDco = getContentVersions(new List<String>{record.Id});
            if(signDco.size() > 0) {
                f42Record.payingAgencySignature = '/sfc/servlet.shepherd/version/download/'+signDco[0].Id;
                if(signDco.size() == 2)
                    f42Record.respondingAgencySignature = '/sfc/servlet.shepherd/version/download/'+signDco[1].Id;
            }
        }
        return f42Record;
    }
    public static List<PersonnelInfo> getPersonnelList(List<F_42_Personnel_Info__c> perssonelList){
        List<PersonnelInfo> personnelInfoList = new List<PersonnelInfo>();
        if(perssonelList.size() > 0) {
            for(F_42_Personnel_Info__c personnelRec : perssonelList) {
                PersonnelInfo obj = new  PersonnelInfo();
                obj.name = personnelRec.Name;
                obj.MACSID = personnelRec.MACS_ID__c;
                obj.jobTitle = personnelRec.Rank_Job_Title__c;
                obj.last4SSN = personnelRec.SSN__c;
                if(personnelRec.Base_Rate__c) {
                    obj.baseRate = 'Yes';
                } else {
                    obj.baseRate = 'No';
                }
                
                if(personnelRec.Start_Date__c != null)
                    obj.startDate = String.valueOf(DateTime.valueOf(personnelRec.Start_Date__c+' 00:00:00').format('MM/dd/yyyy'));
                obj.startTime = personnelRec.Start_Time__c;
                if(personnelRec.End_Date__c != null)
                    obj.endDate = String.valueOf(DateTime.valueOf(personnelRec.End_Date__c+' 00:00:00').format('MM/dd/yyyy'));
                obj.endTime = personnelRec.End_Time__c;
                if(personnelRec.Portal_To_Portal__c)
                {
                    obj.portalToPortal = 'Y';
                } else {
                    obj.portalToPortal = 'N';
                }
                if(personnelRec.CDF__c)
                {
                    obj.CDF = 'Y';
                } else {
                    obj.CDF = 'N';
                }   
                personnelInfoList.add(obj);
            }
        }
        return personnelInfoList;
    }
    public static List<F42ActualHours> getActualHoursList(List<F_42_Actual_Hours__c>  actualHoursRecords){
        List<F42ActualHours> actualHoursList = new List<F42ActualHours>();
        for(F_42_Actual_Hours__c record : actualHoursRecords) {
            F42ActualHours obj = new F42ActualHours();
            if(record.Date__c != null)
                obj.actualHoursDate = String.valueOf(DateTime.valueOf(record.Date__c+' 00:00:00').format('MM/dd/yyyy'));
            obj.actualHoursStartTime = record.Start_Time__c;
            obj.actualHoursEndTime = record.End_Time__c;
            obj.actualHours = String.valueOf(record.Hours__c);
            actualHoursList.add(obj);
        }    
        return actualHoursList;
    }
    //get F-42s Comments
    public static List<F42Comments> getCommentsList(List<F_42_Comment__c> commentsRecords){
        List<F42Comments> commentList = new List<F42Comments>();
        for(F_42_Comment__c record : commentsRecords) {
            F42Comments obj = new F42Comments();
            obj.comments = record.Comment__c;
            if(record.Date__c != null) 
                obj.CommentsDate = String.valueOf(DateTime.valueOf(record.Date__c+' 00:00:00').format('MM/dd/yyyy'));
            obj.CommentsTime = record.Time__c;
            commentList.add(obj);
        }
        return commentList;
    }
    //create F-42s details for PDF 2nd page
    public static F42Details createf42DetailsList(List<F42__c> f42List, Map<String,Decimal> salarySurveyPaidRateMap, Map<String,Decimal> apparatusRateMap, Map<String,Decimal> vechicleRateMap, String adminRateFactor, Map<String,Decimal> salarySurveyHourlyRateMap, String mileRate, Map<String,Decimal> speicalEquipmentRateMap, Map<String,Decimal> femaCodeRateMap, Map<String,Decimal> nonSuppressionRateMap, Map<String,Decimal> salarySurveyPaidBaseRateMap) {
        //List<F42Details> f42DetailsList = new List<F42Details>();
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
            f42Record.departedDate = String.valueOf(DateTime.valueOf(record.DI_Committed_to_Incident_Date__c+'00:00:00').format('MM/dd/yyyy'));
            f42Record.departedTime = String.valueOf(record.DI_Committed_to_Incident_Time__c);   
            f42Record.returnDate = String.valueOf(record.DI_Redispatched_Date__c != null ? DateTime.valueOf(record.DI_Redispatched_Date__c+'00:00:00').format('MM/dd/yyyy') : DateTime.valueOf(record.DI_Return_from_Incident_Date__c+'00:00:00').format('MM/dd/yyyy'));
            f42Record.returnTime = String.valueOf(record.DI_Redispatched_Time__c != null ? record.DI_Redispatched_Time__c : record.DI_Return_from_Incident_Time__c);
            f42Record.departedDateTime = record.DI_COMMITTED_TO_INCIDENT_FORMULA__c;
            f42Record.returnDateTime = String.valueOf(record.DI_REDISPATCHED__c != null ? record.DI_REDISPATCHED__c : record.DI_RETURN_FROM_INCIDENT__c);
            DateTime startDate = null;
            DateTime endDate = null;
            if(f42Record.departedDateTime != null) {
                String timestr1 = record.DI_Committed_to_Incident_Time__c;
                String hrs1 = timestr1.substring(0,2);
                String mins1 = timestr1.substring(2);
                startDate = DateTime.valueOf(String.valueOf(record.DI_Committed_to_Incident_Date__c).removeEnd(' 00:00:00')+' '+hrs1+':'+mins1+':00');
            }
            if(f42Record.returnDateTime != null){
                if(record.DI_RETURN_FROM_INCIDENT__c != null && record.DI_Return_from_Incident_Date__c != null && record.DI_Return_from_Incident_Time__c != null){
                    String timestr2 = record.DI_Return_from_Incident_Time__c;
                    String hrs2 = timestr2.substring(0,2);
                    String mins2 = timestr2.substring(2);
                    endDate = DateTime.valueOf(String.valueOf(record.DI_Return_from_Incident_Date__c).removeEnd(' 00:00:00')+' '+hrs2+':'+mins2+':00');
                }
                if(record.DI_REDISPATCHED__c != null && record.DI_Redispatched_Date__c != null && record.DI_Redispatched_Time__c != null){
                    String timestr3 = record.DI_Redispatched_Time__c;
                    String hrs3 = timestr3.substring(0,2);
                    String mins3 = timestr3.substring(2);
                    endDate = DateTime.valueOf(String.valueOf(record.DI_Redispatched_Date__c).removeEnd(' 00:00:00')+' '+hrs3+':'+mins3+':00');
                } 
            }

            DateTimeCalculation dateDetails = getDateTimeCalculation2(startDate, endDate);
            Decimal TotalEngineHrs = Decimal.valueOf(dateDetails.hours16);
            String erType = getApparatusType(record.ER_TYPE__c);
            // calculate appratus hours and toal using Type
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
            if(speicalEquipmentRateMap != null && record.ER_SPECIAL_EQUIPMENT__c!=null && speicalEquipmentRateMap.containsKey(record.ER_SPECIAL_EQUIPMENT__c)) {
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
            if(femaCodeRateMap != null && record.ER_FEMA_CODES__c != null && femaCodeRateMap.containsKey(record.ER_FEMA_CODES__c)) {
                f42Record.FEMACodeHours = String.valueOf(TotalEngineHrs);
                f42Record.FEMACodTotal = String.valueOf((TotalEngineHrs * femaCodeRateMap.get(record.ER_FEMA_CODES__c)).setScale(2));
                f42Record.FEMACodeRate = String.valueOf(femaCodeRateMap.get(record.ER_FEMA_CODES__c));
            } else {
                f42Record.FEMACodeHours = '0.00';
                f42Record.FEMACodTotal = '0.00';
                f42Record.FEMACodeRate = '0.00';
            }
            f42Record.specialEquipFEMASubTotal = String.valueOf((Decimal.valueOf(f42Record.FEMACodTotal) + Decimal.valueOf(f42Record.specialEquipmentTotal)+ Decimal.valueOf(f42Record.totleEngineHours)).setScale(2));
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
                    f42Record.beginningOdoMeter = String.valueOf(formatCurrency(record.SV_BEGINNING_ODODMETER__c));
                    f42Record.endingOdoMeter = String.valueOf(formatCurrency(record.SV_ENDING_ODOMETER__c));
                    f42Record.totalMiles = String.valueOf(formatCurrency(record.SV_TOTAL_MILES__c));
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
            
            List<StrikeTeamExpenses> strikeTeamExpensesList = getStrikeTeamExpenseList(record.F_42_Personnel_Info__r, salarySurveyPaidRateMap, salarySurveyHourlyRateMap, nonSuppressionRateMap, salarySurveyPaidBaseRateMap, record.F_42_Actual_Hours__r);
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
            f42Record.expenseClaim = getExpenseAmount(record.Reimbursements__r);
            f42Record.surchargeExpenseClaim = String.valueOf((Decimal.valueOf(f42Record.expenseClaim) * Decimal.valueOf(adminRateFactor)).setScale(2));
            f42Record.totalForThisF42 = String.valueOf(personnelTotal + Decimal.valueOf(f42Record.vehicleCost) + Decimal.valueOf(f42Record.surchargeEngine) + Decimal.valueOf(f42Record.surchargePersonnel) + Decimal.valueOf(f42Record.surchargeVehicle) + Decimal.valueOf(f42Record.expenseClaim) + Decimal.valueOf(f42Record.surchargeExpenseClaim) + Decimal.valueOf(f42Record.specialEquipFEMASubTotal));
            
            f42Record.specialEquipmentTotal = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.specialEquipmentTotal).setScale(2)));
            f42Record.FEMACodTotal = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.FEMACodTotal).setScale(2)));
            f42Record.specialEquipFEMASubTotal = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.specialEquipFEMASubTotal).setScale(2)));
            f42Record.expenseClaim = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.expenseClaim).setScale(2)));
            f42Record.vehicleCost = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.vehicleCost).setScale(2)));
            f42Record.vehicleDays = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.vehicleDays).setScale(2)));
            f42Record.supportOrOverheadVehicle = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.supportOrOverheadVehicle).setScale(3)));  
            f42Record.surchargeEngine = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeEngine).setScale(2)));
            f42Record.surchargeVehicle = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeVehicle).setScale(2)));
            f42Record.totalPersonnel = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totalPersonnel).setScale(2).setScale(2)));
            f42Record.surchargePersonnel = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargePersonnel).setScale(2)));
            f42Record.totalForThisF42 = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totalForThisF42).setScale(2)));
            f42Record.totleEngineHours = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totleEngineHours).setScale(2)));
            f42Record.surchargeExpenseClaim = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeExpenseClaim).setScale(2)));
            //f42DetailsList.add(f42Record);
            System.debug(record.Id + 'f42Record--' + f42Record);
        }
        //return f42DetailsList;

        return f42Record; 
    }
    // get Strike Team Expense List data
    public static List<StrikeTeamExpenses> getStrikeTeamExpenseList(List<F_42_Personnel_Info__c> perssonelList, Map<String,Decimal> salarySurveyPaidRateMap, Map<String,Decimal> salarySurveyHourlyRateMap, Map<String,Decimal> nonSuppressionRateMap, Map<String,Decimal> salarySurveyPaidBaseRateMap, List<F_42_Actual_Hours__c> actualHoursList) {
        Map<String,StrikeTeamExpenses> StrikeTeamExpensesMap = new Map<String,StrikeTeamExpenses>();
        if(perssonelList != null && !perssonelList.isEmpty()) {
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
                Decimal hours = 0.00;
                personnelStartDate = DateTime.valueOf(String.valueOf(personnelRec.Start_Date__c).removeEnd(' 00:00:00') +' '+starthrs+':'+startmins+':00');
                personnelEndDate = DateTime.valueOf(String.valueOf(personnelRec.End_Date__c).removeEnd(' 00:00:00') +' '+endhrs+':'+endmins+':00');
                if(personnelRec.Portal_To_Portal__c) {
                    DateTimeCalculation dateDetails = getDateTimeCalculation2(personnelStartDate, personnelEndDate);
                    hours = Decimal.valueOf(dateDetails.hours24);
                } else {
                    hours = getNonPToPHourswithTime(actualHoursList, personnelRec.Start_Date__c, personnelRec.End_Date__c, starttimestr, endtimestr);
                }
                
                Decimal paidRates = 0.00;
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
    // Get Apparatus Type values
    public static String getApparatusType(String appratusType){
        String erType = null;
        if(appratusType == '1' ) erType = 'Type I';
        else if (appratusType == '2') erType = 'Type II';
        else if (appratusType == '3') erType = 'Type III';
        else if (appratusType == '4' || appratusType == '5' || appratusType == '6' || appratusType == '7') erType = 'Type IV - VII';
        else if (appratusType == 'WT-1') erType = 'Water Tender Tactical I';
        else if (appratusType == 'WT-2') erType = 'Water Tender Tactical II';
        return erType;
    }
    // get Personnel Infor list of F-42
    public static List<F_42_Personnel_Info__c>  getPersonnelInfoList(List<String> f42s) {
        return [SELECT Id,Name,F_42__c,Is_Job_Title_Other__c,Rank_Job_Title__c,MACS_ID__c,Start_Date__c,Start_Time__c,End_Date__c,End_Time__c,CDF__c,Portal_To_Portal__c,SSN__c,Base_Rate__c FROM F_42_Personnel_Info__c WHERE F_42__c =:f42s];
    }

    //Create invoice summary data from list in F-42's
    public static List<SummaryInformation> createSummaryData(List<F42__c> f42List, Map<Id, Map<String,Decimal>> salarySurveyPaidRateMapByF42, Map<Id, Map<String,Decimal>> apparatusRateMapByF42, Map<Id, Map<String,Decimal>> vechicleRateMapByF42, Map<String, Decimal> administrativeRate, Map<Id, Map<String,Decimal>> salarySurveyHourlyRateMap, Map<String,Decimal> mileRateByF42, Map<Id, Map<String,Decimal>> specicalEquipmentRateMapByF42, Map<Id, Map<String,Decimal>> femaCodeRateMapByF42,Map<Id,Map<String,Decimal>> nonSuppressionRateMapByF42, Map<Id,Map<String,Decimal>> salarySurveyPaidBaseRateMapByF42){
        List<SummaryInformation> summaryInformationList = new List<SummaryInformation>();
        Map<String,List<F_42_Personnel_Info__c>> perssonelMap = new  Map<String,List<F_42_Personnel_Info__c>>();
        for(F42__c record : f42List) {
            Map<String,Decimal> speicalEquipmentRateMap = specicalEquipmentRateMapByF42.get(record.Id);
            Map<String,Decimal> apparatusRateMap = apparatusRateMapByF42.get(record.Id);
            Map<String,Decimal> vechicleRateMap = vechicleRateMapByF42.get(record.Id);
            Map<String,Decimal> femaCodeRateMap = femaCodeRateMapByF42.get(record.Id);
            Map<String,Decimal> nonSuppressionRateMap = nonSuppressionRateMapByF42.get(record.Id);
            Map<String, Decimal> salarySurveyPaidRateMap = salarySurveyPaidRateMapByF42.get(record.Id);
            Map<String, Decimal> salarySurveyPaidBaseRateMap = salarySurveyPaidBaseRateMapByF42.get(record.Id);
            
            SummaryInformation summdayData = new SummaryInformation();
            DateTime startDate;
            DateTime endDate;
            if(record.DI_COMMITTED_TO_INCIDENT_FORMULA__c != null &&  record.DI_Committed_to_Incident_Date__c != null && record.DI_Committed_to_Incident_Time__c != null) {
                String timestr = record.DI_Committed_to_Incident_Time__c;
                String hrs = timestr.substring(0,2);
                String mins = timestr.substring(2);
                startDate = DateTime.valueOf(String.valueOf(record.DI_Committed_to_Incident_Date__c).removeEnd(' 00:00:00')+' '+hrs+':'+mins+':00');
                summdayData.departDateTime = String.valueOf(DateTime.valueOf(record.DI_Committed_to_Incident_Date__c+' '+hrs+':'+mins+':00').format('MM/dd/yyyy')+ ' '+timestr);
            }
            if(record.DI_RETURN_FROM_INCIDENT__c != null && record.DI_Return_from_Incident_Date__c != null && record.DI_Return_from_Incident_Time__c != null){
                String timestr = record.DI_Return_from_Incident_Time__c;
                String hrs = timestr.substring(0,2);
                String mins = timestr.substring(2);
                endDate = DateTime.valueOf(String.valueOf(record.DI_Return_from_Incident_Date__c).removeEnd(' 00:00:00')+' '+hrs+':'+mins+':00');
                summdayData.returnDateTime = String.valueOf(DateTime.valueOf(record.DI_Return_from_Incident_Date__c+' '+hrs+':'+mins+':00').format('MM/dd/yyyy')+ ' '+timestr);
            } 
            if(record.DI_REDISPATCHED__c != null && record.DI_Redispatched_Date__c != null && record.DI_Redispatched_Time__c != null){
                String timestr = record.DI_Redispatched_Time__c;
                String hrs = timestr.substring(0,2);
                String mins = timestr.substring(2);
                endDate = DateTime.valueOf(String.valueOf(record.DI_Redispatched_Date__c).removeEnd(' 00:00:00')+' '+hrs+':'+mins+':00');
                summdayData.returnDateTime = String.valueOf(DateTime.valueOf(record.DI_Redispatched_Date__c+' '+hrs+':'+mins+':00').format('MM/dd/yyyy')+ ' '+timestr);
            }
            Decimal personnelHoursTotal = 0;
            Decimal personnelTotal = 0;
            for(F_42_Personnel_Info__c personnelRec : record.F_42_Personnel_Info__r) {
                DateTime personnelStartDate;
                DateTime personnelEndDate;
                String starttimestr = personnelRec.Start_Time__c;
                String starthrs = starttimestr.substring(0,2);
                String startmins = starttimestr.substring(2);
                String endtimestr = personnelRec.End_Time__c;
                String endhrs = endtimestr.substring(0,2);
                String endmins = endtimestr.substring(2);
                Decimal hours = 0.00;
                if(personnelRec.Start_Time__c != null && personnelRec.End_Time__c != null && personnelRec.Start_Date__c != null && personnelRec.End_Date__c != null) {
                    personnelStartDate = DateTime.valueOf(String.valueOf(personnelRec.Start_Date__c).removeEnd(' 00:00:00') +' '+starthrs+':'+startmins+':00');
                    personnelEndDate = DateTime.valueOf(String.valueOf(personnelRec.End_Date__c).removeEnd(' 00:00:00') +' '+endhrs+':'+endmins+':00');
                }
                if(personnelRec.Portal_To_Portal__c) {
                    DateTimeCalculation dateDetails = getDateTimeCalculation2(personnelStartDate, personnelEndDate);
                    hours = Decimal.valueOf(dateDetails.hours24);
                } else {
                    hours = getNonPToPHourswithTime(record.F_42_Actual_Hours__r, personnelRec.Start_Date__c, personnelRec.End_Date__c, starttimestr, endtimestr);
                }
                    
                Decimal paidRate = 0.00;
                System.debug('Title=='+personnelRec.Rank_Job_Title__c);
                System.debug('salarySurveyPaidRateMap=='+salarySurveyPaidRateMap);
                if(salarySurveyPaidRateMap != null && salarySurveyPaidBaseRateMap != null && salarySurveyPaidBaseRateMap.containsKey(personnelRec.Rank_Job_Title__c) && salarySurveyPaidRateMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                    if(personnelRec.Base_Rate__c) {
                        paidRate = salarySurveyPaidBaseRateMap.get(personnelRec.Rank_Job_Title__c);
                    } else {
                        paidRate = salarySurveyPaidRateMap.get(personnelRec.Rank_Job_Title__c);
                    }
                } else if(nonSuppressionRateMap != null && salarySurveyPaidRateMap != null && nonSuppressionRateMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                    if(personnelRec.Base_Rate__c && salarySurveyPaidRateMap.containsKey('Firefighter/FF-PMedic')) {
                        paidRate = salarySurveyPaidRateMap.get('Firefighter/FF-PMedic');
                    } else if(nonSuppressionRateMap.containsKey(personnelRec.Rank_Job_Title__c)) {
                        paidRate = nonSuppressionRateMap.get(personnelRec.Rank_Job_Title__c);
                    }
                } else if(salarySurveyPaidRateMap != null && salarySurveyPaidRateMap.containsKey('Firefighter/FF-PMedic')){
                    paidRate = salarySurveyPaidRateMap.get('Firefighter/FF-PMedic');
                }

                if(paidRate != null) {
                    Decimal total = hours * paidRate;
                    personnelTotal = personnelTotal + total;  
                    personnelHoursTotal = personnelHoursTotal + hours;
                }
            } 
            
            DateTimeCalculation dateDetail = getDateTimeCalculation2(startDate, endDate);
            System.debug('dateDetails1114='+dateDetail);
            Decimal TotalEngineHrs = Decimal.valueOf(dateDetail.hours16);
            summdayData.totalHours = String.valueOf(dateDetail.hours24);
            summdayData.totalDays = String.valueOf(dateDetail.days);
            String erType = getApparatusType(record.ER_TYPE__c);

            // Type I,II,III ... Calculation of Appratus
            if(apparatusRateMap != null && erType != null && apparatusRateMap.containsKey(erType)) {
                summdayData.engineReimb = String.valueOf((TotalEngineHrs * apparatusRateMap.get(erType)).setScale(2));
            } 
            summdayData.equipmentHours = String.valueOf(TotalEngineHrs);
            summdayData.engineHours = String.valueOf(TotalEngineHrs);  
            if (summdayData.engineReimb == null || summdayData.equipmentHours == null || summdayData.engineHours == null) {
                summdayData.engineReimb = '0.00'; 
                summdayData.equipmentHours = '0.00';
                summdayData.engineHours = '0.00';
            }
            //Special Equipment Calculation of Appratus
            if(speicalEquipmentRateMap != null && record.ER_SPECIAL_EQUIPMENT__c != null && speicalEquipmentRateMap.containsKey(record.ER_SPECIAL_EQUIPMENT__c)) {
                summdayData.engineReimb = String.valueOf((Decimal.valueOf(summdayData.engineReimb) + (TotalEngineHrs * speicalEquipmentRateMap.get(record.ER_SPECIAL_EQUIPMENT__c))).setScale(2));
            } 
            // FEMA Code Calculation of Appratus
            if(femaCodeRateMap!= null && record.ER_FEMA_CODES__c!=null && femaCodeRateMap.containsKey(record.ER_FEMA_CODES__c)) {
                summdayData.engineReimb = String.valueOf((Decimal.valueOf(summdayData.engineReimb) + (TotalEngineHrs * femaCodeRateMap.get(record.ER_FEMA_CODES__c))).setScale(2));
            } 

            if(record.SV_VEHICLE_OWNERSHIP__c != null) {
                if(record.SV_VEHICLE_OWNERSHIP__c == 'POV') {
                    if(record.SV_TOTAL_MILES__c != null && record.SV_ENDING_ODOMETER__c!= null && record.SV_BEGINNING_ODODMETER__c != null) {
                        if(mileRateByF42 != null && mileRateByF42.containsKey(record.Id)) {    
                            summdayData.supportVehicle = String.valueOf((record.SV_TOTAL_MILES__c * mileRateByF42.get(record.Id)).setScale(2));
                            summdayData.supportVehicleDays = String.valueOf(dateDetail.days);
                        }
                    }
                } else {
                    if(record.SV_TYPE__c != null){
                        if(vechicleRateMap != null && vechicleRateMap.containsKey(record.SV_TYPE__c)) {
                            summdayData.supportVehicle = String.valueOf((Decimal.valueOf(dateDetail.days) * vechicleRateMap.get(record.SV_TYPE__c)).setScale(2));
                            summdayData.supportVehicleDays = String.valueOf(dateDetail.days);
                        }
                    }
                }
            }
            if(summdayData.supportVehicle == null || summdayData.supportVehicleDays == null) {
                summdayData.supportVehicleDays = '0.00';
                summdayData.supportVehicle = '0.00';
            }
            summdayData.personnelHours = String.valueOf(personnelHoursTotal);
            summdayData.unit = record.ER_UNIT__c != null ? record.ER_UNIT__c: record.OH_ICS_Title__c != null ? record.OH_ICS_Title__c : record.OH_OTHER_ICS_TITLE__c;
            summdayData.reqNo = record.Incident_Request_Number__c;
            summdayData.strikeTeam = record.Strike_Team__c;
            summdayData.personnelTotal = String.valueOf(personnelTotal.setScale(2));
            summdayData.expenseReiumb = getExpenseAmount(record.Reimbursements__r);
            Decimal adminRateFactor = administrativeRate.get(record.Id);
            System.debug('adminRateFactor--' + adminRateFactor);
            summdayData.adminSurcharge = String.valueOf(((Decimal.valueOf(summdayData.personnelTotal) + Decimal.valueOf(summdayData.engineReimb) + Decimal.valueOf(summdayData.supportVehicle) + Decimal.valueOf(summdayData.expenseReiumb)) * adminRateFactor).setScale(2));
            summaryInformationList.add(summdayData);
        }
        return summaryInformationList;
    }
    //Get Expense claim Amount
    public static String getExpenseAmount(List<Reimbursement__c> expanseClaimList) {
        String expanseAmount = '0.00';
        //List<Reimbursement__c> expanseClaimList = [SELECT Id,Total_Reimbursement_Amount__c,Status__c FROM Reimbursement__c WHERE F_42__c=:f42Id];
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
    public static List<Agency_Salary_Survey__c> getAgencySalarySurvey(String agencyId, List<Date> f42MinDates) {
        String query = 'SELECT Id,Start_Date__c,END_Date__c,Account__c,Account__r.Name,' +
                ' (SELECT Id, Classification_Title__c, Current_Rate__c,MOU_MOA__c,Base_Rates__c FROM Salary_Survey_Line_Items__r ) ' +
                ' FROM Agency_Salary_Survey__c WHERE Account__c=\''+agencyId+'\' ' +
                ' AND (Status__c=\'' + MARS_Constants.SURVEY_STATUS_REVIEWED + '\' OR Status__c= \'' + MARS_Constants.SURVEY_STATUS_REVISED + '\' OR Status__c= \'' + MARS_Constants.SURVEY_STATUS_EXPIRED + '\') AND ( ';
        List<String> dateFilterClauses = new List<String>();
        for (Date dateObj : f42MinDates) {
            String formattedDate = DateTime.newInstance(dateObj.year(),dateObj.month(),dateObj.day()).format('yyyy-MM-dd');
            dateFilterClauses.add('(Start_Date__c <= '+ formattedDate +' AND ( End_Date__c = null OR End_Date__c >= '+ formattedDate  + '))');
        }
        query += String.join(dateFilterClauses, ' OR ');
        query +=')  ORDER BY CreatedDate ';
        return Database.query(query);
    }
    //Get Agency Non Suppression Line Item
    public static List<Agency_Non_Suppression_Personnel__c> getAgencyNonSuppressionList(String agencyId, List<Date> f42MinDates) {
        String query = 'SELECT Id,Start_Date__c,End_Date__c,Agency__c,Agency__r.Name, ' +
                ' (SELECT Id, Classification_Title__c, Current_Rate__c FROM Agency_Non_Suppression_Line_Items__r ) ' +
                ' FROM Agency_Non_Suppression_Personnel__c WHERE Agency__c=\'' + agencyId  + '\'' +
                ' AND (Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_REVIEWED +'\' OR Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_REVISED +'\' OR Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_EXPIRED +'\') AND (';

        List<String> dateFilterClauses = new List<String>();
        for (Date dateObj : f42MinDates) {
            String formattedDate = DateTime.newInstance(dateObj.year(),dateObj.month(),dateObj.day()).format('yyyy-MM-dd');
            dateFilterClauses.add('(Start_Date__c <= '+ formattedDate +' AND ( End_Date__c = null OR End_Date__c >= '+ formattedDate  + '))');
        }
        query += String.join(dateFilterClauses, ' OR ');
        query +=')  ORDER BY CreatedDate ';
        return Database.query(query);
    }

    // Get Agency Admin Rates
    public static List<Agency_Admin_Rates__c> getAgencyAdminRate(String agencyId, List<Date> f42MinDates) {
        String query = 'SELECT Id,Start_Date__c,End_Date__c,Agency__c,Agency__r.Name,Administrative_Rate_Indirect_Cost_Direct__c ' +
                ' FROM Agency_Admin_Rates__c WHERE Agency__c=\'' + agencyId +'\'' +
                ' AND (Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_REVIEWED + '\' OR Approval_Status__c= \''+ MARS_Constants.SURVEY_STATUS_REVISED +'\' OR Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_EXPIRED + '\') AND ( ';
        List<String> dateFilterClauses = new List<String>();
        for (Date dateObj : f42MinDates) {
            String formattedDate = DateTime.newInstance(dateObj.year(),dateObj.month(),dateObj.day()).format('yyyy-MM-dd');
            dateFilterClauses.add('(Start_Date__c <= '+ formattedDate +' AND ( End_Date__c = null OR End_Date__c >= '+ formattedDate  + '))');
        }
        query += String.join(dateFilterClauses, ' OR ');
        query +=')  ORDER BY CreatedDate ';
        return Database.query(query);
    }

    // Get CFAA Records
    public static List<CFAA__c> getCFAA(List<Date> f42MinDates) {
        String query = 'SELECT Id,Name,Default_Admin_Rate__c,Start_Date__c,END_Date__c, ' +
                ' (SELECT Id,CFAA__c,Name, Unit_of_Measure__c,Type__c,Support_Equipment_Type__c,Straight_Time_Rate__c,Emergency_Apparatus_Type__c,Order_No__c,Other_Role__c,Over_Time_Rate__c,Personnel_Role__c,RecordType.Name,RecordTypeId FROM CFAA_Line_Items__r ORDER BY Emergency_Apparatus_Type__c,Support_Equipment_Type__c,Personnel_Role__c) ' +
                ' FROM CFAA__c WHERE ';
        List<String> dateFilterClauses = new List<String>();
        for (Date dateObj : f42MinDates) {
            String formattedDate = DateTime.newInstance(dateObj.year(),dateObj.month(),dateObj.day()).format('yyyy-MM-dd');
            dateFilterClauses.add('(Start_Date__c <= '+ formattedDate +' AND ( End_Date__c = null OR End_Date__c >= '+ formattedDate  + '))');
        }
        query += String.join(dateFilterClauses, ' OR ');
        return Database.query(query);
    }
    // Get FEMA code Records
    public static List<FEMA_Code__c> getFEMARecords(List<Date> f42MinDates) {
        String query ='SELECT Id,Name,Effective_Date__c,End_Date__c,'+
                   ' (SELECT Id,Name,Current_Rate__c,Equipment__c,Unit__c,Specifications__c,HP__c,Capacity_Size__c  FROM FEMA_Schedule_of_Equipment__r) '+
                   ' FROM FEMA_Code__c WHERE Status__c =\''+ MARS_Constants.SURVEY_STATUS_ACTIVE + '\' AND (';
        List<String> dateFilterClauses = new List<String>();
        for (Date dateObj : f42MinDates) {
            String formattedDate = DateTime.newInstance(dateObj.year(),dateObj.month(),dateObj.day()).format('yyyy-MM-dd');
            dateFilterClauses.add('(Effective_Date__c <= '+ formattedDate +' AND ( End_Date__c = null OR End_Date__c >= '+ formattedDate  + '))');
            }
        query += String.join(dateFilterClauses, ' OR ');
        query +=')  ORDER BY CreatedDate ';
        System.debug('Line 1474='+query);
        return Database.query(query);
    }

     // Get Special equipment rate
     public static List<Agency_Special_Equipment__c> getSpecialEquipment(String agencyId, List<Date> f42MinDates) {
         String query = 'SELECT Id,Start_Date__c,End_Date__c,Agency__c,Agency__r.Name,' +
                 ' (SELECT Id,FEMA_CODE__c,Revised_Rate__c,Current_Rate__c,Special_Equipment_Type__c  FROM Agency_Special_Equipment_Line_Items__r )' +
                 ' FROM Agency_Special_Equipment__c WHERE Agency__c= \'' + agencyId + '\'' +
                 ' AND (Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_REVIEWED + '\' OR Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_REVISED + '\' OR Approval_Status__c=\'' + MARS_Constants.SURVEY_STATUS_EXPIRED + '\') AND (';
         List<String> dateFilterClauses = new List<String>();
         for (Date dateObj : f42MinDates) {
             String formattedDate = DateTime.newInstance(dateObj.year(),dateObj.month(),dateObj.day()).format('yyyy-MM-dd');
             dateFilterClauses.add('(Start_Date__c <= '+ formattedDate +' AND ( End_Date__c = null OR End_Date__c >= '+ formattedDate  + '))');
         }
         query += String.join(dateFilterClauses, ' OR ');
         query +=')  ORDER BY CreatedDate ';
         return Database.query(query);
    }

    // Create Invoice Number
    public static String createInvoicePrefix(List<Funding_Rule__c> fundingRule) {
        String fundingSourceName = '';
        String invoiceNumber = '';
        if(fundingRule != null && !fundingRule.isEmpty()) {
            fundingSourceName = fundingRule[0].Funding_Source_1__r.Name;
            String payingAgency_U = KeyValueHelper.getTextValue('MARS_U_Paying_Agency');
            String payingAgency_F = KeyValueHelper.getTextValue('MARS_F_Paying_Agency');
            String payingAgency_I = KeyValueHelper.getTextValue('MARS_I_Paying_Agency');
            Date dt = System.today();
            Integer year = dt.Year();
            if(String.isNotBlank(payingAgency_U) && payingAgency_U.contains(fundingSourceName.toUpperCase())) {
                invoiceNumber = 'U-';
            } else if(String.isNotBlank(payingAgency_F) && payingAgency_F.contains(fundingSourceName.toUpperCase())) {
                invoiceNumber = 'F-';
            } else if(String.isNotBlank(payingAgency_I) && payingAgency_I.contains(fundingSourceName.toUpperCase())) {
                invoiceNumber = 'I-';
            } else {
                invoiceNumber = 'O-';
            }
            invoiceNumber = invoiceNumber + String.valueOf(year);
        }
        return invoiceNumber;
    }
  /***********************************************************************************************************************************
    * Class Name   : GeneratePDFFromInvoice
    * Description  : This is Queueable class for generate invoice and save it and update invoice status
    * Author       : Chandrabhan
    * Created On   : 06/01/2021
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj                06/01/2021       Initial Implementation
    **************************************************************************************************************************************/
    public class GeneratePDFFromInvoice implements Queueable, Database.AllowsCallouts {
        String invoiceId;
        public GeneratePDFFromInvoice(String Id) {
            System.debug('InvoiceId=='+Id);
            this.invoiceId = Id;
        }
        public void execute(QueueableContext context) {
            Account account ;
            Invoice__c invoiceRecord = [SELECT Id,Status__c,Name,Account__c,Invoice_Number_For_Json__c FROM Invoice__c WHERE Id =:invoiceId];
            if(invoiceRecord != null) {
                account = [SELECT Id,MACS_ID__c FROM Account WHERE Id =: invoiceRecord.Account__c];
            }
            String fileName = invoiceRecord.Name +'.pdf';//Name of the file
            //update old content document names to void.
            List<ContentDocumentLink> documentLinks = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:invoiceId];
            List<String> contentDocIds = new List<String>();
            for (ContentDocumentLink contentDocumentLink : documentLinks) {
                contentDocIds.add(contentDocumentLink.ContentDocumentId);
            }
            List<ContentDocument> contentDocuments = [SELECT Title FROM ContentDocument WHERE Id=:contentDocIds AND Title=:fileName];
            for (ContentDocument contentDocument : contentDocuments) {
                contentDocument.Title = contentDocument.Title.replace('.pdf', '- void.pdf');
            }
            update contentDocuments;

            PageReference pr = new PageReference('/apex/MARS_GenerateInvoice?id='+InvoiceId);
           // Blob content = pr.getContent();
            //Blob content = pr.getContent();
            Blob content;
            if(Test.isRunningTest()) { 
                content = blob.valueOf('Unit.Test');
            } else {
                content = pr.getContent();
            }
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            //cv.PathOnClient = 'Invoice-'+System.now() +'.pdf';//File name with extention
            cv.PathOnClient = invoiceRecord.Name +'.pdf';//File name with extention
            cv.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            //cv.Title = 'Invoice-'+System.now() +'.pdf';//Name of the file
            cv.Title = fileName;
            //cv.PathOnClient = 'Invoice.pdf';
            cv.VersionData = content;
            cv.IsMajorVersion = true;
            Insert cv;
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
           
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = InvoiceId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'I';
            cdl.Visibility = 'AllUsers';
            Insert cdl;

            invoiceRecord.Status__c = 'Invoice Generated';
            update invoiceRecord;
        }
    } 
    private static List<ContentVersion> getContentVersions(List<String> recordIds) {

        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }

        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest=true AND Title LIKE '%Signature%' order by ContentModifiedDate desc];
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
    public static FundingSourceData getFundingData(List<Funding_Rule__c> fundingRule, Decimal claimTotal) {
        FundingSourceData returnMap = new FundingSourceData();                
        List<String> fundingRules = new List<String>();
        List<InvoicePayment> fundingRulesForPayment = new List<InvoicePayment>();
        
        if(fundingRule.size() >0 ) {
            Decimal fundingSourcePer = 0;
            if(fundingRule[0].Funding_Source_1_Percent__c != null && fundingRule[0].Funding_Source_1__c != null) {
                fundingSourcePer += fundingRule[0].Funding_Source_1_Percent__c;
                Decimal funding1 = ((claimTotal * fundingRule[0].Funding_Source_1_Percent__c) / 100).setScale(2);
                fundingRules.add(fundingRule[0].Funding_Source_1__r.Name+ ' ('+fundingRule[0].Funding_Source_1_Percent__c+'%): $'+formatCurrency(funding1));
                InvoicePayment foundingAmt = new InvoicePayment();
                foundingAmt.invoiceFundingPercent = String.valueOf(fundingRule[0].Funding_Source_1_Percent__c);
                foundingAmt.invoiceFundingAmount = String.valueOf(funding1);
                foundingAmt.fundingSourceId = fundingRule[0].Funding_Source_1__c;
                fundingRulesForPayment.add(foundingAmt);
            }
            if(fundingRule[0].Funding_Source_2_Percent__c != null && fundingRule[0].Funding_Source_2__c != null) {
                fundingSourcePer += fundingRule[0].Funding_Source_2_Percent__c;
                Decimal funding1 = ((claimTotal * fundingRule[0].Funding_Source_2_Percent__c) / 100).setScale(2);
                fundingRules.add(fundingRule[0].Funding_Source_2__r.Name+ ' ('+fundingRule[0].Funding_Source_2_Percent__c+'%): $'+formatCurrency(funding1));
                InvoicePayment foundingAmt = new InvoicePayment();
                foundingAmt.invoiceFundingPercent = String.valueOf(fundingRule[0].Funding_Source_2_Percent__c);
                foundingAmt.invoiceFundingAmount = String.valueOf(funding1);
                foundingAmt.fundingSourceId = fundingRule[0].Funding_Source_2__c;
                fundingRulesForPayment.add(foundingAmt);
            }    
            if(fundingRule[0].Funding_Source_3_Percent__c != null && fundingRule[0].Funding_Source_3__c != null) {
                fundingSourcePer += fundingRule[0].Funding_Source_3_Percent__c;
                Decimal funding1 = ((claimTotal * fundingRule[0].Funding_Source_3_Percent__c) / 100).setScale(2);
                fundingRules.add(fundingRule[0].Funding_Source_3__r.Name+ ' ('+fundingRule[0].Funding_Source_3_Percent__c+'%): $'+formatCurrency(funding1));
                InvoicePayment foundingAmt = new InvoicePayment();
                foundingAmt.invoiceFundingPercent = String.valueOf(fundingRule[0].Funding_Source_3_Percent__c);
                foundingAmt.invoiceFundingAmount = String.valueOf(funding1);
                foundingAmt.fundingSourceId = fundingRule[0].Funding_Source_3__c;
                fundingRulesForPayment.add(foundingAmt);
            }
            if(fundingRule[0].Funding_Source_4_Percent__c != null && fundingRule[0].Funding_Source_4__c != null) {
                fundingSourcePer += fundingRule[0].Funding_Source_4_Percent__c;
                Decimal funding1 = ((claimTotal * fundingRule[0].Funding_Source_4_Percent__c) / 100).setScale(2);
                fundingRules.add(fundingRule[0].Funding_Source_4__r.Name+ ' ('+fundingRule[0].Funding_Source_4_Percent__c+'%): $'+formatCurrency(funding1));
                InvoicePayment foundingAmt = new InvoicePayment();
                foundingAmt.invoiceFundingPercent = String.valueOf(fundingRule[0].Funding_Source_4_Percent__c);
                foundingAmt.invoiceFundingAmount = String.valueOf(funding1);
                foundingAmt.fundingSourceId = fundingRule[0].Funding_Source_4__c;
                fundingRulesForPayment.add(foundingAmt);
            }
            if(fundingRule[0].Funding_Source_5_Percent__c != null && fundingRule[0].Funding_Source_5__c != null) {
                fundingSourcePer += fundingRule[0].Funding_Source_5_Percent__c;
                Decimal funding1 = ((claimTotal * fundingRule[0].Funding_Source_5_Percent__c) / 100).setScale(2);
                fundingRules.add(fundingRule[0].Funding_Source_5__r.Name+ ' ('+fundingRule[0].Funding_Source_5_Percent__c+'%): $'+formatCurrency(funding1));
                InvoicePayment foundingAmt = new InvoicePayment();
                foundingAmt.invoiceFundingPercent = String.valueOf(fundingRule[0].Funding_Source_5_Percent__c);
                foundingAmt.invoiceFundingAmount = String.valueOf(funding1);
                foundingAmt.fundingSourceId = fundingRule[0].Funding_Source_5__c;
                fundingRulesForPayment.add(foundingAmt);
            }
            if(fundingSourcePer < 100) {
                Decimal funding1 = ((claimTotal * ( 100.00 - fundingSourcePer)) / 100).setScale(2);
                fundingRules.add('NON-REIMBURSABLE TOTAL: $'+formatCurrency(funding1));
            }
            returnMap.fundingRules = fundingRules;
            returnMap.fundingRulesForPayment = fundingRulesForPayment;
        }
        return returnMap;
    }
 
    /***********************************************
    * Method Name : regenerateInvoice
    * Author : Chandrabhan
    * Inputs : List<Id> invoiceIds
    * Description: regenerate incvoice
    *********************************************/
    @InvocableMethod(label='Regenerate Invoice' description='Regenerate Invoice')
    public static void regenerateInvoice(List<Id> invoiceIds) {
        System.debug('invoiceIds=='+invoiceIds);
        List<String> f42Ids = new List<String>(); 
        List<Invoice__c> invoiceList = [SELECT Account__c,Incident__c,Funding_Rule__c FROM Invoice__c WHERE Id =: invoiceIds[0]];
        List<F42__c> f42List = [SELECT Id FROM F42__c WHERE Invoice__c =: invoiceIds[0]];
        if(invoiceList.size() > 0  && f42List.size() > 0) {
           for(F42__c f42Record : f42List) {
            f42Ids.add(f42Record.Id);
        }
        //createInvoiceStaging(invoiceList[0].Incident__c, invoiceList[0].Account__c, f42Ids,invoiceList[0].Funding_Rule__c);
       }
    }
    private static Invoice__c getInvoice(InvoicePDF invoiceRecord, String accountId, String incidentNumber, String fundingRuleId, String invoiceType, String parentInvoiceId, List<Invoice__c> childInvoice, List<Invoice__c> parentInvoice) {
        Invoice__c invoice =  new Invoice__c();
        invoice.Invoice_Number_For_Json__c = invoiceRecord.firstCharWithYearForInvoiceNo;
        invoice.Status__c = 'Invoice Generation In-progress';
        invoice.Total_Invoice_Amount__c = Decimal.valueOf(invoiceRecord.claimTotal);
        invoice.Personnel_Total_Value__c = Decimal.valueOf(invoiceRecord.personnelTotal);
        invoice.Personnel_Hours__c = Decimal.valueOf(invoiceRecord.personnelHoursTotal);
        //invoice.Equipment_Total_Value__c = String.valueOf(invoiceRecord.);
        invoice.Equipment_Hours__c = Decimal.valueOf(invoiceRecord.equipmentHoursTotal);
        invoice.Support_Vehicle_Total__c = Decimal.valueOf(invoiceRecord.supportVehicleTotal);
        invoice.Support_Vehicle_Days__c = Decimal.valueOf(invoiceRecord.supportVehicleDaysTotal);
        invoice.Admin_Surcharge_Total__c = Decimal.valueOf(invoiceRecord.adminSurchargeTotal);
        //invoice.Travel_Total__c = String.valueOf(invoiceRecord.);
        invoice.Engine_Value_of_F42__c = Decimal.valueOf(invoiceRecord.engReimbTotal);
        invoiceRecord.claimTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.claimTotal).setScale(2)));
        invoiceRecord.personnelTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.personnelTotal).setScale(2)));
        invoiceRecord.equipmentHoursTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.equipmentHoursTotal).setScale(2)));
        invoiceRecord.personnelHoursTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.personnelHoursTotal).setScale(2)));
        invoiceRecord.supportVehicleTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.supportVehicleTotal).setScale(2)));
        invoiceRecord.supportVehicleDaysTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.supportVehicleDaysTotal).setScale(2)));
        invoiceRecord.adminSurchargeTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.adminSurchargeTotal).setScale(2)));
        invoiceRecord.engReimbTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.engReimbTotal).setScale(2)));
        invoiceRecord.expenseReiumbTotal = String.valueOf(formatCurrency(Decimal.valueOf(invoiceRecord.expenseReiumbTotal).setScale(2)));
        String invoiceJson = JSON.serialize(invoiceRecord);
        invoice.Invoice_Json__c = invoiceJson;
        invoice.Account__c = accountId;
        invoice.Incident__c = incidentNumber;
        invoice.Funding_Rule__c = fundingRuleId;
        if(parentInvoiceId != null && invoiceType == 'Amendment Invoice') {
            invoice.Parent_Invoice__c = parentInvoiceId;
            invoice.Invoice_Type__c = 'Amendment';
            if(childInvoice.size() > 0) {
                String str = childInvoice[0].Name;
                Integer charCode =  str.charAt(str.length()-1);
                List<Integer> chars = new List<Integer>{charCode + 1};
                String nextChar = String.fromCharArray(chars);
                invoice.Name = parentInvoice[0].Name+'-A'+nextChar;
            } else {
                if(parentInvoice.size() > 0) {
                    invoice.Name = parentInvoice[0].Name +'-A1';
                }
            } 
        } else {
            if(parentInvoiceId != null) {
                invoice.Id = parentInvoiceId;  
            }
            invoice.Invoice_Type__c = 'Invoice';
        }
        return invoice;
    }

    // generate invoice data for  Expense Claim 
    public static InvoicePDF createInvoiceDataFromExpenseClaim(String agencyId, List<Reimbursement__c> expClaimList, List<Funding_Rule__c> fundingRule, Map<String,ExpenseClaim> expenseClaimList, Map<String,List<FieldHistory>> expenseClaimHistory, Map<String,List<FieldHistory>> expenseClaimLineItemHistory) {
        String jsonData='';
        List<VechicleRate> vechicleRateList = new List<VechicleRate>();
        List<ApparatusRate> apparatusRateList = new List<ApparatusRate>();
        List<SalarySurveyRate> salarySurveyRateList = new List<SalarySurveyRate>();
        Map<String,Decimal> salarySurveyPaidRateMap = new Map<String,Decimal>();
        Map<String,Decimal> salarySurveyHourlyRateMap = new Map<String,Decimal>();
        Map<String,Decimal> vechicleRateMap = new Map<String,Decimal>();
        Map<String,Decimal> apparatusRateMap = new Map<String,Decimal>();
        Map<String,Decimal> nonSuppressionRateMap = new Map<String,Decimal>();
        InvoicePDF ivoiceObj = new InvoicePDF();
        ivoiceObj.invoiceDate = System.now().format('MM/dd/yyyy');
            
        /*List<Date> expenseClaimMinDate = new List<Date>();
        String lastestF42; 
        Date maxDate;*/
          
        if(expClaimList.size() > 0) {
            /*for(Reimbursement__c record : expClaimList) {
                if(record.Submission_Date__c < expClaimMinDate) {
                    expClaimMinDate = record.Submission_Date__c;
                }
            }*/
            // Get CFAA Data
            List<CFAA__c> CFAAMap = getCFAAForExpenseClaim();
            if(CFAAMap.size() > 0) {
                ivoiceObj.administrativeRate = String.valueOf(CFAAMap[0].Default_Admin_Rate__c);
                for(CFAA__c cfaadata : CFAAMap) {
                    for(CFAA_Line_Items__c record : cfaadata.CFAA_Line_Items__r) {
                        VechicleRate vechicleRecord = new VechicleRate();
                        ApparatusRate apparatusRcord = new ApparatusRate();
                        SalarySurveyRate salarySurveyRecord = new SalarySurveyRate();
                        if(record.RecordType.Name == 'Support Equipment Rate'){
                            if(!vechicleRateMap.containsKey(record.Support_Equipment_Type__c)) {
                                vechicleRecord.vechicleType = record.Support_Equipment_Type__c;
                                vechicleRecord.rate = String.valueOf(record.Straight_Time_Rate__c);
                                vechicleRateList.add(vechicleRecord);
                                vechicleRateMap.put(record.Support_Equipment_Type__c, record.Straight_Time_Rate__c);
                            }
                        } else if(record.RecordType.Name == 'Emergency Apparatus Rate') {
                            if(!apparatusRateMap.containsKey(record.Emergency_Apparatus_Type__c)) {
                                apparatusRcord.apparatusType = record.Emergency_Apparatus_Type__c;
                                apparatusRcord.rate = String.valueOf(record.Straight_Time_Rate__c);
                                apparatusRateList.add(apparatusRcord);
                                apparatusRateMap.put(record.Emergency_Apparatus_Type__c,record.Straight_Time_Rate__c);
                            }
                        } else if(record.RecordType.Name == 'Personnel Base Rate') {
                            if(!salarySurveyPaidRateMap.containsKey(record.Personnel_Role__c)){
                                salarySurveyRecord.personnelRole = record.Personnel_Role__c;
                                salarySurveyRecord.rate = String.valueOf(record.Straight_Time_Rate__c);
                                salarySurveyRateList.add(salarySurveyRecord);
                                salarySurveyPaidRateMap.put(record.Personnel_Role__c,record.Straight_Time_Rate__c);
                                salarySurveyHourlyRateMap.put(record.Personnel_Role__c,record.Straight_Time_Rate__c);
                            }
                        } else if(record.RecordType.Name == 'POV Rate' && record.Straight_Time_Rate__c != null ) {
                            ivoiceObj.mileRate = String.valueOf(record.Straight_Time_Rate__c);
                        }
                    }
                }
                            
                ivoiceObj.vechicleRateList = vechicleRateList;
                ivoiceObj.apparatusRateList = apparatusRateList;
                ivoiceObj.SalarySurveyRateList = salarySurveyRateList;
            }

            ivoiceObj.incidentName = expClaimList[0].Incident__r.Name;
            ivoiceObj.incidentOrderNo = expClaimList[0].Incident_Order_Number__c;
            ivoiceObj.firstCharWithYearForInvoiceNo = createInvoicePrefix(fundingRule);
            ivoiceObj.MACSDesignator = expClaimList[0].Account__r.MACS_ID__c;
            ivoiceObj.remitToName = expClaimList[0].Account__r.Name;
            ivoiceObj.remitToStreet = expClaimList[0].Account__r.ShippingStreet;
            ivoiceObj.remitToCity = expClaimList[0].Account__r.ShippingCity;
            ivoiceObj.remitToState = expClaimList[0].Account__r.ShippingState;
            ivoiceObj.remitToZip = expClaimList[0].Account__r.ShippingPostalCode;
            ivoiceObj.federalTaxId = expClaimList[0].Account__r.Federal_Tax_ID__c;
            ivoiceObj.supplierNo = expClaimList[0].Account__r.Fiscal_Supplier_ID__c;
            ivoiceObj.addressNo = String.valueOf(expClaimList[0].Account__r.Fiscal_Address_Id__c);
            ivoiceObj.summaryInformationList = createSummaryDataForExpClaim(expClaimList, ivoiceObj.administrativeRate);
            if(ivoiceObj.summaryInformationList != null) {
                Decimal personnelTotal = 0.0;
                Decimal engReimbTotal = 0;
                Decimal supportVehicleTotal = 0;
                Decimal adminSurchargeTotal = 0;
                Decimal expenseReiumbTotal = 0;
                Decimal personnelHoursTotal = 0;
                Decimal equipmentHoursTotal = 0;
                Decimal supportVehicleDaysTotal = 0;
                //get total of all F-42s
                for(SummaryInformation sumInfo : ivoiceObj.summaryInformationList) {
                    if(sumInfo.personnelTotal != null) {
                        personnelTotal = personnelTotal + Decimal.valueOf(sumInfo.personnelTotal);
                        sumInfo.personnelTotal = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.personnelTotal).setScale(2)));
                    }
                    if(sumInfo.engineReimb != null) {
                        engReimbTotal = engReimbTotal + Decimal.valueOf(sumInfo.engineReimb);
                        sumInfo.engineReimb = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.engineReimb).setScale(2)));
                    }
                    if(sumInfo.supportVehicle != null) {
                        supportVehicleTotal = supportVehicleTotal + Decimal.valueOf(sumInfo.supportVehicle);
                        sumInfo.supportVehicle = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.supportVehicle).setScale(2)));
                    }
                    if(sumInfo.adminSurcharge != null) {
                        adminSurchargeTotal = adminSurchargeTotal + Decimal.valueOf(sumInfo.adminSurcharge);
                        sumInfo.adminSurcharge = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.adminSurcharge).setScale(2)));
                    
                    }
                    if(sumInfo.expenseReiumb != null) {
                        expenseReiumbTotal = expenseReiumbTotal + Decimal.valueOf(sumInfo.expenseReiumb);
                        sumInfo.expenseReiumb = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.expenseReiumb).setScale(2)));
                    }
                    if(sumInfo.personnelHours != null) {
                        personnelHoursTotal = personnelHoursTotal + Decimal.valueOf(sumInfo.personnelHours);
                        sumInfo.personnelHours = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.personnelHours).setScale(2)));
                    }
                    if(sumInfo.equipmentHours != null) {
                        equipmentHoursTotal = equipmentHoursTotal + Decimal.valueOf(sumInfo.equipmentHours);
                        sumInfo.equipmentHours = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.equipmentHours).setScale(2)));
                    }
                    if(sumInfo.supportVehicleDays != null) {
                        supportVehicleDaysTotal = supportVehicleDaysTotal + Decimal.valueOf(sumInfo.supportVehicleDays);
                        sumInfo.supportVehicleDays = String.valueOf(formatCurrency(Decimal.valueOf(sumInfo.supportVehicleDays).setScale(2)));
                    }
                }
                Decimal claimTotal = personnelTotal + engReimbTotal + supportVehicleTotal + adminSurchargeTotal + expenseReiumbTotal;
                ivoiceObj.claimTotal = String.valueOf(claimTotal);

                FundingSourceData fundingMap = getFundingData(fundingRule,claimTotal); 
                ivoiceObj.fundingRules = fundingMap.fundingRules;
                ivoiceObj.fundingRulesForPaymnet = fundingMap.fundingRulesForPayment;
                ivoiceObj.personnelTotal = String.valueOf(personnelTotal);
                ivoiceObj.engReimbTotal = String.valueOf(engReimbTotal);
                ivoiceObj.supportVehicleTotal = String.valueOf(supportVehicleTotal);
                ivoiceObj.adminSurchargeTotal = String.valueOf(adminSurchargeTotal);
                ivoiceObj.expenseReiumbTotal = String.valueOf(expenseReiumbTotal);
                ivoiceObj.personnelHoursTotal = String.valueOf(personnelHoursTotal);
                ivoiceObj.equipmentHoursTotal = String.valueOf(equipmentHoursTotal);
                ivoiceObj.supportVehicleDaysTotal = String.valueOf(supportVehicleDaysTotal);
                ivoiceObj.f24RecordsList = createf42RecordExpClaim(expClaimList, ivoiceObj.administrativeRate, expenseClaimList, expenseClaimHistory, expenseClaimLineItemHistory);
            }
        }
        return ivoiceObj;
    }   
    //Create invoice summary data from lsit in F-42's
    public static List<SummaryInformation> createSummaryDataForExpClaim(List<Reimbursement__c> expClaimList, String adminRateFactor){
        List<SummaryInformation> summaryInformationList = new List<SummaryInformation>();
        for(Reimbursement__c record : expClaimList) {
            SummaryInformation summdayData = new SummaryInformation();
            summdayData.engineReimb = '0.00'; 
            summdayData.equipmentHours = '0.00';
            summdayData.engineHours = '0.00';
            summdayData.supportVehicleDays = '0';
            summdayData.supportVehicle = '0.00';
            summdayData.unit = record.Unit_Number__c;
            summdayData.reqNo = record.Incident_Request_Number__c;
            summdayData.strikeTeam = record.Strike_Team__c;
            summdayData.personnelTotal = '0.00';
            summdayData.expenseReiumb = String.valueOf(record.Total_Reimbursement_Amount__c);
            summdayData.adminSurcharge = String.valueOf(((Decimal.valueOf(summdayData.personnelTotal) + Decimal.valueOf(summdayData.engineReimb) + Decimal.valueOf(summdayData.supportVehicle) + Decimal.valueOf(summdayData.expenseReiumb)) * Decimal.valueOf(adminRateFactor)).setScale(2));
            summaryInformationList.add(summdayData);
        }

        return summaryInformationList;
    }     

    public static List<F24Records> createf42RecordExpClaim(List<Reimbursement__c> expenseClaim, String adminRateFactor, Map<String,ExpenseClaim> expenseClaimList, Map<String,List<FieldHistory>> expenseClaimHistory, Map<String,List<FieldHistory>> expenseClaimLineItemHistory) { 
        List<F24Records>  expClaimRecordsList = new List<F24Records>();
        for(Reimbursement__c record : expenseClaim) { 
            F24Records f42Record = new F24Records();
            f42Record.f42Details = createf42DetailsListForExpClaim(new List<Reimbursement__c>{record},adminRateFactor);
            f42Record.fieldHistExpClaim =expenseClaimHistory.get(record.Id); //getFieldHistExpClaim('', record.Id);
            f42Record.fieldHistExpClaimLineItem = expenseClaimLineItemHistory.get(record.Id); //getFieldHistExpClaimLineItem('', record.Id);
            f42Record.expenseClaim = expenseClaimList.get(record.Id);//getExpenseClaim(null,record.Id);
            expClaimRecordsList.add(f42Record);
        }
        return expClaimRecordsList;
    }
    //create F-42s details for PDF 2nd page
    public static F42Details createf42DetailsListForExpClaim(List<Reimbursement__c> expenseClaim, String adminRateFactor) {
            F42Details f42Record = new F42Details();
            for(Reimbursement__c record : expenseClaim) {
                f42Record.incidentName  = record.Incident__r.Name;
                f42Record.MACSDesignator = record.Account__r.MACS_ID__c;
                f42Record.strikeTeam = record.Strike_Team__c;
                f42Record.orderNo = record.Incident_Order_Number__c;
                f42Record.requestNo = record.Incident_Request_Number__c;
                f42Record.to = record.Incident__r.Incident_Type__c;
                f42Record.name = record.Incident__r.Name;
                f42Record.appUnitNo = record.Unit_Number__c;
                f42Record.OESVehicle = '-';
                f42Record.totleEngineHours = '0.00';
                f42Record.engineHours ='0.0';
                f42Record.surchargeEngine = '0.00';
                f42Record.apparatusRate = '0.00';
                f42Record.totalHours = '0.00';
                f42Record.fireEngineOr ='';
                f42Record.vehicleCost = '0.00';
                f42Record.vehicleDays = '0.00';
                f42Record.FEMACodeHours = '0.00';
                f42Record.FEMACodTotal = '0.00';
                f42Record.FEMACodeRate = '0.00';
	        f42Record.specialEquipmentHours = '0.00';
                f42Record.specialEquipmentTotal = '0.00';
                f42Record.specialEquipmentRate = '0.00';
                f42Record.supportOrOverheadVehicle = '0.00';
                f42Record.surchargeVehicle = '0.00';
                f42Record.specialEquipFEMASubTotal = '0.00';
                f42Record.department = record.Account__r.Name;
                f42Record.chief = record.Account__r.Chief_Name__c;
                f42Record.phone =  record.Account__r.Phone;
                f42Record.fax = record.Account__r.Fax;
                f42Record.address = record.Account__r.ShippingStreet;
                f42Record.city = record.Account__r.ShippingCity;
                f42Record.state = record.Account__r.ShippingState;
                f42Record.zip = record.Account__r.ShippingPostalCode;
                Decimal personnelTotal = 0;
                f42Record.totalPersonnel ='0.00';
                f42Record.surchargePersonnel = '0.00';
                f42Record.expenseClaim = String.valueOf(record.Total_Reimbursement_Amount__c);
                f42Record.surchargeExpenseClaim = String.valueOf((Decimal.valueOf(f42Record.expenseClaim) * Decimal.valueOf(adminRateFactor)).setScale(2));
                f42Record.totalForThisF42 = String.valueOf(personnelTotal + Decimal.valueOf(f42Record.totleEngineHours) + Decimal.valueOf(f42Record.vehicleCost) + Decimal.valueOf(f42Record.surchargeEngine) + Decimal.valueOf(f42Record.surchargePersonnel) + Decimal.valueOf(f42Record.surchargeVehicle) + Decimal.valueOf(f42Record.expenseClaim) + Decimal.valueOf(f42Record.surchargeExpenseClaim));
                f42Record.expenseClaim = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.expenseClaim).setScale(2)));
                f42Record.vehicleCost = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.vehicleCost).setScale(2)));
                f42Record.vehicleDays = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.vehicleDays).setScale(2)));
                f42Record.supportOrOverheadVehicle = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.supportOrOverheadVehicle).setScale(3)));  
                f42Record.surchargeEngine = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeEngine).setScale(2)));
                f42Record.surchargeVehicle = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeVehicle).setScale(2)));
                f42Record.totalPersonnel = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totalPersonnel).setScale(2).setScale(2)));
                f42Record.surchargePersonnel = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargePersonnel).setScale(2)));
                f42Record.totalForThisF42 = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.totalForThisF42).setScale(2)));
                f42Record.surchargeExpenseClaim = String.valueOf(formatCurrency(Decimal.valueOf(f42Record.surchargeExpenseClaim).setScale(2)));
            }
        return f42Record; 
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

    public static Decimal mathForHours(string startTime, string EndTime){
        Decimal hours = 0;
        decimal mins = 0;
        decimal diff = decimal.valueOf(EndTime) - decimal.valueOf(startTime);
        string differnece = string.ValueOf(diff);
        if(differnece.length() > 2){
            hours = decimal.valueOf(differnece.substring(0, differnece.length() - 2));
            mins = decimal.valueOf(differnece.right(2));
            if(mins > 60){
                mins = mins - 40;
            }
            mins = mins/60;
            hours = hours + mins;
            hours = hours.setScale(2);
            return hours;
        }else{
            mins =  decimal.valueOf(differnece);
            if(mins > 60){
                mins = mins - 40;
            }
            hours = mins/60;
            hours = hours.setScale(2);
            return hours;
        }
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
    //    System.debug('Hours24Old =  '+dt.Hours24);
    //    System.debug('Hours16Old =  '+dt.Hours16);
    //    System.debug('daysOld =  '+dt.days);
        return dt;
    }

    private static DateTimeCalculation getDateTimeCalculation2(Datetime startDateTime, DateTime endDateTime) {
        DateTimeCalculation dt = new DateTimeCalculation();
      
        Decimal totalHoursAndMinutes = (Decimal.valueOf(endDateTime.getTime() - startDateTime.getTime())/(1000*60*60)).setScale(2);
        Long totalHours = (endDateTime.getTime() - startDateTime.getTime())/(1000*60*60);
        Decimal minutes = totalHoursAndMinutes - totalHours;

        if(minutes >= 0.01 && minutes <= 0.25) {
            minutes = 0.25;
        } else if(minutes >= 0.26 && minutes <= 0.50) {
            minutes = 0.50;
        } else if(minutes >= 0.51 && minutes <= 0.75) {
            minutes = 0.75;
        } else if(minutes >= 0.76) {
            totalHours += 1;
            minutes = 0.0;
        }
        totalHoursAndMinutes = totalHours + minutes;
        
        Long fullDays = (TotalHours/24);
        Long hoursRemainder =  math.mod(totalHours,24);// Integer.valueOf((hours24/24));
        

        Decimal hoursAt16PerDayMaximum = fullDays*16;
        if ((hoursRemainder < 16) || ((hoursRemainder == 16) && (minutes == 0))){
            hoursAt16PerDayMaximum = hoursAt16PerDayMaximum + hoursRemainder + minutes;
        } else {
            hoursAt16PerDayMaximum += 16;
        }

        //this does not represent full days, but any portion of a day. 2 hour period from 2300 - 0100 is two daysnumberofDates  
        Long numberOfDates = startDateTime.date().daysBetween(endDateTime.date()) + 1;

        dt.hours24 = String.valueOf(totalHoursAndMinutes);
        dt.hours16 = String.valueOf(hoursAt16PerDayMaximum);
        dt.days = String.valueOf(numberOfDates);
      //  System.debug('Hours24New =  '+dt.Hours24);
      //  System.debug('Hours16New =  '+dt.Hours16);
      //  System.debug('daysNew =  '+dt.days);
        return dt;
    }



    public static Map<String,ExpenseClaim> getExpenseClaim(List<Reimbursement__c> reimbursementList) {
        Map<String,ExpenseClaim> f42sExpenseClaimMap = new Map<String,ExpenseClaim>();
        if(reimbursementList != null && !reimbursementList.isEmpty()) {
            for(Reimbursement__c expenseCalimRecord : reimbursementList) {
                ExpenseClaim expenseRecord = new ExpenseClaim();
                if(expenseCalimRecord.F_42__c != null) {
                    f42sExpenseClaimMap.put(expenseCalimRecord.F_42__c,expenseRecord);
                } else {
                    f42sExpenseClaimMap.put(expenseCalimRecord.Id,expenseRecord);
                }    
                List<ExpenseClaimLineItem> expenseClaimLineItems = new List<ExpenseClaimLineItem>();
                List<AttachedFiles> attachedFiles = new List<AttachedFiles>();
                // get expense line Items
                for(Reimbursement_Line_Item__c lineItem : expenseCalimRecord.Reimbursement_Line_Items__r) {
                    ExpenseClaimLineItem record = new ExpenseClaimLineItem();
                    record.lineItemDate = String.valueOf((DateTime.valueOf(lineItem.Date__c+' 00:00:00').format('MM/dd/yyyy')));
                    record.city = lineItem.City__c;
                    record.meal = String.valueOf(formatCurrency(lineItem.Meal__c));
                    record.lodging = String.valueOf(formatCurrency(lineItem.Lodging__c));
                    record.MISC = String.valueOf(formatCurrency(lineItem.MISC__c));
                    record.description = lineItem.Description__c;
                    record.amount = String.valueOf(formatCurrency(lineItem.Amount__c));
                    record.name = lineItem.Name;
                    expenseClaimLineItems.add(record);
                }
                //get expense claim attachement 
                List<ContentVersion> fileList = getContentVersionsForAttachment(new List<String>{expenseCalimRecord.Id});
                for(ContentVersion cv : fileList) {
                    AttachedFiles file = new AttachedFiles();
                    file.name = cv.Title;
                    file.type = cv.Type__c;
                    attachedFiles.add(file);
                }
                // get Signature from expense claim
                List<ContentVersion> signDco = getContentVersions(new List<String>{expenseCalimRecord.Id});
                if(signDco.size() > 0) {
                    expenseRecord.respondingAgencySignature ='/sfc/servlet.shepherd/version/download/'+signDco[0].Id;
                }

                expenseRecord.submittedDate = String.valueOf((DateTime.valueOf(expenseCalimRecord.Submission_Date__c+' 00:00:00').format('MM/dd/yyyy')));
                expenseRecord.comments = expenseCalimRecord.Comments__c;
                expenseRecord.incidentName = expenseCalimRecord.Incident__r.Name;
                expenseRecord.incidentOrderNumber = expenseCalimRecord.Incident_Order_Number__c;
                expenseRecord.incidentRequestNumber = expenseCalimRecord.Incident_Request_Number__c;
                expenseRecord.localAgencyComments = expenseCalimRecord.Approver_Comments__c;
                expenseRecord.lodgingTotal = String.valueOf(formatCurrency(expenseCalimRecord.Lodging_Total__c));
                expenseRecord.MACIDs = String.valueOf(expenseCalimRecord.MACIDs__c);
                expenseRecord.mealTotal = String.valueOf(formatCurrency(expenseCalimRecord.Meal_Total__c));
                expenseRecord.MISCTotal = String.valueOf(formatCurrency(expenseCalimRecord.MISC_Total__c));
                expenseRecord.mutualAidStaffComments = expenseCalimRecord.Mutual_Aid_Staff_Comments__c;
                expenseRecord.printedName = expenseCalimRecord.Printed_Name__c;
                expenseRecord.name = expenseCalimRecord.Name;
                expenseRecord.strikeTeam = expenseCalimRecord.Strike_Team__c;
                expenseRecord.totalReimbursementAmount = String.valueOf(formatCurrency(expenseCalimRecord.Total_Reimbursement_Amount__c));
                expenseRecord.unitNumber = expenseCalimRecord.Unit_Number__c;
                expenseRecord.F_42Name = expenseCalimRecord.F_42__r.Name;
                expenseRecord.attachmentType = expenseCalimRecord.Attachment_Type__c;
                expenseRecord.expenseClaimLineItems = expenseClaimLineItems;
                expenseRecord.attachedFiles = attachedFiles;   
            }
        }                
        return f42sExpenseClaimMap;
    }
    private static List<ContentVersion> getContentVersionsForAttachment(List<String> recordIds) {

        Set<Id> contentDocIds = new Set<Id>();
        // added dynamic query due to weired issue with static query - ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        String query = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in(\'' + String.join(recordIds, '\',\'') + '\')';
        for(ContentDocumentLink contentDocLink : Database.query(query)) {
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }
        return [select Id,ContentModifiedDate,ContentModifiedById,Type__c,Title,Owner.Name,ContentDocumentId,FileExtension
        from ContentVersion where ContentDocumentId in:contentDocIds AND IsLatest = true AND Type__c != null order by ContentModifiedDate desc];
    }
    private static Map<String,List<FieldHistory>> getFieldHistF_42s(List<String> f42Ids) {
        Map<String,List<FieldHistory>> f42HistoryMap = new Map<String,List<FieldHistory>>();
        List<F42__History> f42shistoryList = [SELECT CreatedDate,DataType,Field,Id,NewValue,OldValue,ParentId,CreatedBy.Name FROM F42__History WHERE ParentId =: f42Ids  ORDER BY CreatedDate DESC];
        String type = 'F42__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for(String f42Id : f42Ids) {
            List<FieldHistory> f42HistoryList = new List<FieldHistory>();
            f42HistoryMap.put(f42Id,f42HistoryList);
            if(f42shistoryList != null && !f42shistoryList.isEmpty()) {
                for(F42__History record : f42shistoryList) {
                    if(f42Id == record.ParentId) {
                        FieldHistory fieldData = new FieldHistory();
                        fieldData.user = record.CreatedBy.Name;
                        fieldData.changeDate = String.valueOf(record.CreatedDate.format('MM/dd/yyyy hh:mm:ss'));
                        String fieldLabel = record.Field;
                        if(fieldMap.get(record.Field) != null) {
                            fieldLabel = fieldMap.get(record.Field).getDescribe().getLabel();
                        }
                        fieldData.fieldName = fieldLabel;
                        fieldData.originalValue = String.valueOf(record.OldValue);
                        fieldData.newValue = String.valueOf(record.NewValue);
                        f42HistoryList.add(fieldData);
                    }
                }
            }
        }
        return f42HistoryMap;
    }
    private static Map<String,List<FieldHistory>> getFieldHistPersonnel(List<F42__c> f42List) {
        Map<String,List<FieldHistory>> f42PersonnelHistoryMap = new Map<String,List<FieldHistory>>();
        Set<String> parentIds = new Set<String>();
        //List<F42__c> f42List = [SELECT Id,(SELECT Id FROM F_42_Personnel_Info__r) FROM F42__c WHERE Id=:f42Ids];
        if(f42List != null && !f42List.isEmpty()) {
            for(F42__c f42Rec : f42List) {
                for(F_42_Personnel_Info__c info : f42Rec.F_42_Personnel_Info__r) {
                    parentIds.add(info.Id);
                }
            }
            List<F_42_Personnel_Info__History> f42shistoryList = [SELECT CreatedDate,DataType,Field,Id,NewValue,OldValue,ParentId,CreatedBy.Name FROM F_42_Personnel_Info__History WHERE ParentId =: parentIds  ORDER BY CreatedDate DESC];
            String type = 'F_42_Personnel_Info__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            for(F42__c f42Rec : f42List) {
                List<FieldHistory> f42PerHistoryList = new List<FieldHistory>();
                f42PersonnelHistoryMap.put(f42Rec.Id,f42PerHistoryList);
                if(f42shistoryList != null && !f42shistoryList.isEmpty()) {
                    for(F_42_Personnel_Info__c info : f42Rec.F_42_Personnel_Info__r) {
                        for(F_42_Personnel_Info__History record : f42shistoryList) {
                            if(info.Id == record.ParentId) {
                                FieldHistory fieldData = new FieldHistory();
                                fieldData.user = record.CreatedBy.Name;
                                fieldData.changeDate = String.valueOf(record.CreatedDate.format('MM/dd/yyyy hh:mm:ss'));
                                String fieldLabel = record.Field;
                                if(fieldMap.get(record.Field) != null) {
                                    fieldLabel = fieldMap.get(record.Field).getDescribe().getLabel();
                                }
                                fieldData.fieldName = fieldLabel;
                                fieldData.originalValue = String.valueOf(record.OldValue);
                                fieldData.newValue = String.valueOf(record.NewValue);
                                f42PerHistoryList.add(fieldData);
                            }
                        }
                    }
                }
            }    
        }    
        return f42PersonnelHistoryMap;
    }

    private static Map<String,List<FieldHistory>> getFieldHistActualHours(List<F42__c> f42List) {
        Map<String,List<FieldHistory>> f42ActualHrsHistoryMap = new Map<String,List<FieldHistory>>();
        Set<String> parentIds = new Set<String>();
        if(f42List != null && !f42List.isEmpty()) {
            for(F42__c f42Rec : f42List) {
                for(F_42_Actual_Hours__c info : f42Rec.F_42_Actual_Hours__r) {
                    parentIds.add(info.Id);
                }
            }
            List<F_42_Actual_Hours__History> f42shistoryList = [SELECT CreatedDate,DataType,Field,Id,NewValue,OldValue,ParentId,CreatedBy.Name FROM F_42_Actual_Hours__History WHERE ParentId =: parentIds];
            String type = 'F_42_Actual_Hours__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            for(F42__c f42Rec : f42List) {
                List<FieldHistory> f42ACHistoryList = new List<FieldHistory>();
                f42ActualHrsHistoryMap.put(f42Rec.Id,f42ACHistoryList);
                if(f42shistoryList != null && !f42shistoryList.isEmpty()) {
                    for(F_42_Actual_Hours__c info : f42Rec.F_42_Actual_Hours__r) {
                        for(F_42_Actual_Hours__History record : f42shistoryList) {
                            if(info.Id == record.ParentId) {
                                FieldHistory fieldData = new FieldHistory();
                                fieldData.user = record.CreatedBy.Name;
                                fieldData.changeDate = String.valueOf(record.CreatedDate.format('MM/dd/yyyy hh:mm:ss'));
                                String fieldLabel = record.Field;
                                if(fieldMap.get(record.Field) != null) {
                                    fieldLabel = fieldMap.get(record.Field).getDescribe().getLabel();
                                }
                                fieldData.fieldName = fieldLabel;
                                fieldData.originalValue = String.valueOf(record.OldValue);
                                fieldData.newValue = String.valueOf(record.NewValue);
                                f42ACHistoryList.add(fieldData);
                            }
                        }
                    }    
                }
            }    
        }    
        return f42ActualHrsHistoryMap;
    }
    private static Map<String,List<FieldHistory>> getFieldHistExpClaim(List<Reimbursement__c> reimbursementList) {
        Map<String,List<FieldHistory>> f42ExpClaimHistoryMap = new Map<String,List<FieldHistory>>();
        Set<String> parentIds = new Set<String>();
        if(reimbursementList != null || !reimbursementList.isEmpty()) {
            for(Reimbursement__c record : reimbursementList) {
                parentIds.add(record.Id);
            }

            List<Reimbursement__History> f42shistoryList = [SELECT CreatedDate,DataType,Field,Id,NewValue,OldValue,ParentId,CreatedBy.Name FROM Reimbursement__History WHERE ParentId =: parentIds ORDER BY CreatedDate DESC];
            if(f42shistoryList != null && !f42shistoryList.isEmpty()) {
                String type = 'Reimbursement__c';
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                for(Reimbursement__c expenseCalimRecord : reimbursementList) {
                    List<FieldHistory> expClaimHistoryList = new List<FieldHistory>();
                    if(expenseCalimRecord.F_42__c != null) {
                        f42ExpClaimHistoryMap.put(expenseCalimRecord.F_42__c,expClaimHistoryList);
                    } else {
                        f42ExpClaimHistoryMap.put(expenseCalimRecord.Id,expClaimHistoryList);
                    }
                    for(Reimbursement__History record : f42shistoryList) {
                        if(expenseCalimRecord.Id == record.ParentId) {
                            FieldHistory fieldData = new FieldHistory();
                            fieldData.user = record.CreatedBy.Name;
                            fieldData.changeDate = String.valueOf(record.CreatedDate.format('MM/dd/yyyy hh:mm:ss'));
                            String fieldLabel = record.Field;
                            if(fieldMap.get(record.Field) != null) {
                                fieldLabel = fieldMap.get(record.Field).getDescribe().getLabel();
                            }
                            fieldData.fieldName = fieldLabel;
                            fieldData.originalValue = String.valueOf(record.OldValue);
                            fieldData.newValue = String.valueOf(record.NewValue);
                            expClaimHistoryList.add(fieldData);
                        }    
                    }
                }    
            }
        }
        return f42ExpClaimHistoryMap;
    }
    private static Map<String,List<FieldHistory>> getFieldHistExpClaimLineItem(List<Reimbursement__c> reimbursementList) {
        Map<String,List<FieldHistory>> f42ExpClaimLineHistoryMap = new Map<String,List<FieldHistory>>();
        Set<String> parentIds = new Set<String>();
        if(reimbursementList != null && !reimbursementList.isEmpty()) {   
            for(Reimbursement__c record : reimbursementList) {
                for(Reimbursement_Line_Item__c lineItem : record.Reimbursement_Line_Items__r) {
                    parentIds.add(lineItem.Id);
                }
            }                                    
            List<Reimbursement_Line_Item__History> expCalimLineList = [SELECT CreatedDate,DataType,Field,Id,NewValue,OldValue,ParentId,CreatedBy.Name FROM Reimbursement_Line_Item__History WHERE ParentId =: parentIds ORDER BY CreatedDate DESC];
            String type = 'Reimbursement_Line_Item__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            for(Reimbursement__c expenseCalimRecord : reimbursementList) {
                List<FieldHistory> expClaimLineHistoryList = new List<FieldHistory>();
                if(expenseCalimRecord.F_42__c != null) {
                    f42ExpClaimLineHistoryMap.put(expenseCalimRecord.F_42__c,expClaimLineHistoryList);
                } else {
                    f42ExpClaimLineHistoryMap.put(expenseCalimRecord.Id,expClaimLineHistoryList);
                }    
                if(expCalimLineList != null && !expCalimLineList.isEmpty()) {    
                    for(Reimbursement_Line_Item__c lineItem : expenseCalimRecord.Reimbursement_Line_Items__r) {
                        for(Reimbursement_Line_Item__History record : expCalimLineList) {
                            if(lineItem.Id == record.ParentId) {
                                FieldHistory fieldData = new FieldHistory();
                                fieldData.user = record.CreatedBy.Name;
                                fieldData.changeDate = String.valueOf(record.CreatedDate.format('MM/dd/yyyy hh:mm:ss'));
                                String fieldLabel = record.Field;
                                if(fieldMap.get(record.Field) != null) {
                                    fieldLabel = fieldMap.get(record.Field).getDescribe().getLabel();
                                }
                                fieldData.fieldName = fieldLabel;
                                fieldData.originalValue = String.valueOf(record.OldValue);
                                fieldData.newValue = String.valueOf(record.NewValue);
                                expClaimLineHistoryList.add(fieldData);
                            }    
                        }
                    }
                }        
            }
        }
        return f42ExpClaimLineHistoryMap;
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

    // Get CFAA Records for shwoing on PDF first Page not used in calculation only admin rate is used
    public static List<CFAA__c> getCFAAForExpenseClaim() {
        String query = 'SELECT Id,Name,Default_Admin_Rate__c,Start_Date__c,END_Date__c, (SELECT Id,CFAA__c,Name, Unit_of_Measure__c,Type__c,Support_Equipment_Type__c,Straight_Time_Rate__c,Emergency_Apparatus_Type__c,Order_No__c,Other_Role__c,Over_Time_Rate__c,Personnel_Role__c,RecordType.Name,RecordTypeId FROM CFAA_Line_Items__r ORDER BY Emergency_Apparatus_Type__c,Support_Equipment_Type__c,Personnel_Role__c) '+
                        'FROM CFAA__c ORDER BY Start_Date__c, CreatedDate DESC Limit 1';
        return Database.query(query);
    }
    private static List<F42__c> getF42s(List<String> f42Ids) {
        // Get F42s, F_42_Personnel_Info, F_42_Actual_Hours,F_42_Comments, Reimbursements= 5 Queries
        List<F42__c> f42List = [SELECT Id,Account__c,Account__r.Name,Account__r.Mars_Agency_Designator__c,Invoice__c,
                                Incident__r.Name,Incident__r.Incident_Type__c,Account__r.MACS_ID__c,Account__r.ShippingStreet,
                                Account__r.ShippingCity,Account__r.ShippingState,Account__r.ShippingPostalCode,Account__r.Chief_Name__c,
                                Account__r.Phone,DF_OLD_INCIDENT_REQUEST__c,DT_NEW_INCIDENT_REQUEST__c,Account__r.Fax, Days_from_Submission__c, 
                                DF_Dispatch_From_End_Date__c, SV_LICENSE__c,DF_OLD_INCIDENT__c,DT_NEW_INCIDENT__c,DT_Dispatch_To_Start_Date__c,                            Account__r.Federal_Tax_ID__c,Account__r.DUNS__c,Account__r.Fiscal_Supplier_ID__c,Account__r.Fiscal_Address_Id__c,OH_OVERHEAD_TYPE__c, ER_UNIT__c,Incident_Request_Number__c,Strike_Team__c,DI_Committed_to_Incident_Date__c, DI_COMMITTED_TO_INCIDENT_FORMULA__c,DI_Committed_to_Incident_Time__c,DI_RETURN_FROM_INCIDENT__c,DI_Return_from_Incident_Date__c,DI_Return_from_Incident_Time__c,ER_TYPE__c,SV_TOTAL_MILES__c,DI_REPORTING_LOCATION__c,DI_REDISPATCHED__c,DI_Redispatched_Date__c,DI_Redispatched_Time__c,SV_TYPE__c,SV_VEHICLE_OWNERSHIP__c,Incident_Order__c,PA_PAYING_AGENCY__c,
                                ER_CDF_OES_VEHICLE__c,SV_ENDING_ODOMETER__c,SV_BEGINNING_ODODMETER__c,ER_LICENSE_NUMBER__c,OH_ICS_Title__c,
                                DT_NEW_INCIDENT__r.Order_No__c,DF_OLD_INCIDENT__r.Order_No__c,OH_OTHER_ICS_TITLE__c,ER_APPARATUS__c,
                                SN_LOSS_DAMAGE_CLAIM__c,SN_SUPPLY_NUMBER__c,RA_AGENCY_NAME__c,RA_YOUR_NAME__c,RA_YOUR_PHONE__c,
                                ER_FEMA_CODES__c,ER_SPECIAL_EQUIPMENT__c,RA_YOUR_TITLE__c,PA_PRINTED_NAME__c,PA_OTHER__c,
                                PA_DATE__c,PA_CALOESREP_DATE__c,PA_Cal_OES_REPRESENTATIVE__c,PA_ICS_POSITION_TITLE__c,
                                PI_NUMBER_OF_PERSONNEL_ON_APPARATUS__c,
                                (SELECT Id,Name,F_42__c,Is_Job_Title_Other__c,Rank_Job_Title__c,MACS_ID__c,Start_Date__c,
                                Start_Time__c,End_Date__c,End_Time__c,CDF__c,Portal_To_Portal__c,SSN__c,Base_Rate__c FROM F_42_Personnel_Info__r),  
                                (SELECT Id,Name,Date__c,End_Time__c,Hours__c,Start_Time__c FROM F_42_Actual_Hours__r),
                                (SELECT Id,Name, Comment__c,Comment_By__c,Date__c,Time__c FROM F_42_Comments__r),
                                (SELECT Id,Total_Reimbursement_Amount__c,Status__c,F_42__c FROM Reimbursements__r)
                                FROM F42__c WHERE Id =:f42Ids];
        return f42List;
    }

    private static List<Reimbursement__c> getExpensClaimList(List<String> expClaimIds, List<String> f42Ids) { 
        String query = 'SELECT Id, Name,Total_Reimbursement_Amount__c,Printed_Name__c,Submission_Date__c,Status__c,Approver_Comments__c,F_42__r.Name,F_42__c,'+
                    'MACIDs__c,Strike_Team__c,Incident_Order_Number__c,Incident_Request_Number__c,Unit_Number__c,Incident__r.Name,Mutual_Aid_Staff_Comments__c,'+
                    'Account__r.MACS_ID__c,Account__r.ShippingStreet,Account__r.ShippingCity,Account__r.ShippingState,Account__r.ShippingPostalCode,Account__r.Federal_Tax_ID__c,Account__r.Fiscal_Supplier_ID__c,Account__r.Fiscal_Address_Id__c,Account__r.Name,'+
                    'Comments__c,Meal_Total__c,MISC_Total__c,Lodging_Total__c,Attachment_Type__c,Account__c,Incident__r.Incident_Type__c,Account__r.Chief_Name__c,Account__r.Phone,Account__r.Fax,'+
                    '(SELECT Id,Name,Date__c, City__c,Meal__c, Lodging__c, MISC__c, Description__c, Amount__c FROM Reimbursement_Line_Items__r) FROM Reimbursement__c WHERE ';
      
        if(expClaimIds != null && !expClaimIds.isEmpty()) {
            query += ' Id IN: expClaimIds';
        } else if(f42Ids != null && !f42Ids.isEmpty()) {
            query += ' F_42__c IN: f42Ids';
        }
        System.debug('Reimbursement query='+query);
        return Database.query(query);
    }
    private static List<Funding_Rule__c> getFundingSource(String fundingRuleId) {
        List<Funding_Rule__c> fundingRule = [SELECT Id,Rule_Type__c,Name,Funding_Source_1__c,Funding_Source_1__r.Name,Funding_Source_1_Percent__c,
                                        Funding_Source_2__c,Funding_Source_2__r.Name,Funding_Source_2_Percent__c,Funding_Source_3__c,Funding_Source_3__r.Name,Funding_Source_3_Percent__c,
                                        Funding_Source_4__c,Funding_Source_4__r.Name,Funding_Source_4_Percent__c,Funding_Source_5__c,Funding_Source_5__r.Name,Funding_Source_5_Percent__c 
                                        FROM Funding_Rule__c WHERE Id =: fundingRuleId];
        return fundingRule;
    }    
}