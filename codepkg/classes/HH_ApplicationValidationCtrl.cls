public with sharing class HH_ApplicationValidationCtrl {
    
    @AuraEnabled
    public static Map<String,Object> validateApplication(String applicationId) {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c app = queryApplication(applicationId);
        result.put('1',validateApplicantInfo(app));
        result.put('2',validateEligibilityInfo(app));
        result.put('3',validatePropertyInfo(app));
        result.put('4',validateApplicationDocmentation(app));
        result.put('5',validateApplicantCertification(app));
        return result;
    }


    public static Boolean validateApplicantInfo(HH_Application__c app) {
        if(app.Applicant__r.FirstName != null && app.Applicant__r.FirstName != null  && app.Applicant__r.Physical_Street__c != null && 
            app.Applicant__r.Physical_City__c != null && app.Applicant__r.Physical_State__c != null &&  
            app.Applicant__r.Physical_Country__c != null && app.Applicant__r.Physical_Zip_Postal_Code__c != null && 
            app.Applicant__r.Phone != null && app.Applicant__r.LastName != null && 
            app.Applicant__r.Is_Physical_Address_a_Foreign_Address__c != null &&  
            app.Applicant__r.Is_Mailing_Address_a_Foreign_Address__c != null && 
            app.Applicant__r.Is_Mailing_Address_Different__c != null &&  
            app.Applicant__r.Preferred_Language__c != null  && 
            app.Applicant__r.MailingStreet != null && app.Applicant__r.MailingCity != null &&
            app.Applicant__r.MailingState != null && app.Applicant__r.MailingCountry != null && 
            app.Applicant__r.MailingPostalCode != null && app.Applicant__r.English_Language_Proficiency__c != null) {
                return true;
        }
        return false;

    }


    public static Boolean validateEligibilityInfo(HH_Application__c app) {
        if(app.Property_Owner__c != null &&  app.Primary_Residence__c != null &&  app.Rental_Property__c != null  && app.Car_Ownership__c != null &&
        app.Is_Anyone_65__c != null &&  app.Is_Anyone_Age_5_and_Under__c != null && app.Anyone_Not_a_Proficient_English_Speaker__c != null &&
          app.Is_Anyone_has_Disabilities__c != null ) {
            return true;
        }
        return false;
    }

    public static Boolean validateApplicationDocmentation(HH_Application__c app) {
        return true;
    }

    public static Boolean validatePropertyInfo(HH_Application__c app) {
        if(app.Property_Structure__c != null &&  app.Property_Street_Address__c != null &&  app.City__c != null  &&
            app.State__c != null && app.Zip_Postal_Code__c != null &&  app.County__c != null &&
            app.Year_of_Construction__c != null &&  app.Authority_to_make_updates_to_the_Home__c != null &&  app.Total_Living_Area__c != null && 
            app.Number_of_Stories__c != null &&  app.Accessible_by_a_Passenger_Vehicle__c != null &&  app.Is_National_Register_of_Historic_Places__c != null &&
            app.Any_Other_Names_on_the_Property_Deed__c != null &&  app.Property_Foreclosed_or_in__c != null &&  app.Property_Liens__c != null && 
            app.Good_Standing_with_a_payment_plan_on_you__c != null  &&  app.Measures_to_Reduce_risks_to_wi__c != null && app.Did_you_receive_wildfire_assistance__c != null) { 
            return true;
        }
        return false;
    }

    public static Boolean validateApplicantCertification(HH_Application__c app) {
        return app.Agreement_Disclosure__c;
    }

    private static HH_Application__c queryApplication(String applicationId) {
        return [SELECT Id, Name, Property_Owner__c, Property_Structure__c, Car_Ownership__c, Currently_Occupied__c,
                Damage_Description__c,Ethnicities_of_Household_Members__c, Is_Anyone_65__c, Is_Anyone_Age_5_and_Under__c,
                Is_Anyone_has_Disabilities__c, Property_Currently_Damaged__c, Rental_Property__c,
                Agreement_Disclosure__c, Primary_Residence__c, Accessible_by_a_Passenger_Vehicle__c, Any_Other_Names_on_the_Property_Deed__c, 
                Anyone_Not_a_Proficient_English_Speaker__c, Assessed_Value_of_the_Property__c, Assistance_to_reduce_yo__c,
                City__c, County__c, Property_Street_Address__c,Did_you_receive_wildfire_assistance__c,
                State__c, Zip_Postal_Code__c, Authority_to_make_updates_to_the_Home__c, Year_of_Construction__c, Total_Living_Area__c,
                Number_of_Stories__c, Is_National_Register_of_Historic_Places__c,
                Property_Foreclosed_or_in__c, Property_Liens__c,Good_Standing_with_a_payment_plan_on_you__c,
                Measures_to_Reduce_risks_to_wi__c, Stage__c, List_of_Measures__c,Program__c,
                Applicant__r.AccountId, Applicant__r.Account.Name, Applicant__r.Account.Account_Name__c, Applicant__r.FirstName,
                Applicant__r.Physical_Street__c,Applicant__r.Physical_City__c,Applicant__r.Physical_State__c, Applicant__r.Physical_Country__c,Applicant__r.Physical_Zip_Postal_Code__c,
                Applicant__r.Email, Applicant__r.Phone,Applicant__r.LastName,
                Applicant__r.Is_Physical_Address_a_Foreign_Address__c, Applicant__r.Is_Mailing_Address_a_Foreign_Address__c,
                Applicant__r.Is_Mailing_Address_Different__c, Applicant__r.Preferred_Language__c, Applicant__r.OtherPhone,
                Applicant__r.MailingStreet,Applicant__r.MailingCity,Applicant__r.MailingState,
                Applicant__r.MailingCountry, Applicant__r.MailingPostalCode,OwnerId,
                Applicant__r.English_Language_Proficiency__c, Applicant__r.MobilePhone, Applicant__r.HomePhone, Unique_Household_Number__c,Household_Members__c 
                FROM HH_Application__c WHERE Id =:applicationId  LIMIT 1];
    }
}