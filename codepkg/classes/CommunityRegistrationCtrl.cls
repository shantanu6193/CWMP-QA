/***********************************************************************************************************************************
* Class Name   : CommunityRegistrationCtrl
* Description  : This class for community user registration process
* Author       : Pankaj
* Created On   : 07/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             07/12/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunityRegistrationCtrl {
    private final static Integer MAX_RESULTS = 1000;

    public class CustomException extends Exception{

    }

    /***********************************************
    * Method Name : apexSearchStateAgency
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type State Agency
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchStateAgency(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String stateAgency = 'State Agency';
        String query = 'Select Id,Name From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + stateAgency + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        //ToDo get subtypes for search results
        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            null,
                            opAccountReference
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }


    /***********************************************
    * Method Name : apexSearchFireAgency
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Fire Agency
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFireAgency(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String fireAgency = 'Fire Agency';
        String query = 'Select Id,Name From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + fireAgency + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR MACS_ID__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit ' + MAX_RESULTS;
        List<Account> accounts = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            null,
                            opAccountReference
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        return results;
    }


     /***********************************************
    * Method Name : apexSearchFederalAgency
    * Author : Shantanu
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Fire Agency
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFederalAgency(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String fireAgency = 'Federal Agency';
        String query = 'Select Id,Name From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + fireAgency + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\')';
        }
        query += ' Limit ' + MAX_RESULTS;
        List<Account> accounts = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            null,
                            opAccountReference
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

     /***********************************************
    * Method Name : apexSearchMARSpayingEntity
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type MARS Paying Entity
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchMARSpayingEntity(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
    
        String payingEntity = 'MARS Paying Entity';
        String query = 'Select Id,Name From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + payingEntity + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\')';
        }
        query += ' Limit ' + MAX_RESULTS;
        List<Account> accounts = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            null,
                            opAccountReference
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        return results;
    }


    /***********************************************
    * Method Name : apexSearchCity
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type City
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchCity(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String city = 'City';
        String county = 'County';
        String accName = 'San Francisco, City and County';
        searchTerm = searchTerm.replace(' ','%');
        String query = 'Select Id,Name From Account';
        query += ' Where (Skip_Registration__c != true AND Entity_Type__c = \'' + city + '\') OR (Name = \'' + accName + '\' AND Entity_Type__c = \'' + county + '\')';
        /*if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }*/
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);

        List<LookupSearchResult> results = searchAccount(accounts, false);
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : apexSearchTribal
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Tribal
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchTribal(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String tribal = 'Tribal';
        searchTerm = searchTerm.replace(' ','%');
        String query = 'Select Id,Name From Account';
        query += ' Where Entity_Type__c = \'' + tribal + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);

        List<LookupSearchResult> results = searchAccount(accounts, false);
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : apexSearchSpecialDistrict
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Special District
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchSpecialDistrict(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String specialDistrict = 'Special District';
        String query = 'Select Id,Name From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + specialDistrict + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);

        List<LookupSearchResult> results = searchAccount(accounts, false);

        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : apexSearchCourts
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Courts
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchCourts(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String courts = 'Courts';
        searchTerm = searchTerm.replace(' ','%');
        String query = 'Select Id,Name From Account';
        query += ' Where Entity_Type__c = \'' + courts + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);

        List<LookupSearchResult> results = searchAccount(accounts, false);
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : apexSearchFacility
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Health Care Facility
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFacility(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        String facility = 'Health Care Facility';
        searchTerm = searchTerm.replace(' ','%');
        String query = 'Select Entity_Id__c, Parent.Name, Id, Name From Account';
        query += ' Where Entity_Type__c = \'' + facility + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND (Name like\'%' + searchTerm + '%\' OR Parent.Name like\'%' + searchTerm + '%\' OR Entity_Id__c like\'%' + searchTerm + '%\')' ;
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);

        List<LookupSearchResult> results = searchAccount(accounts, true);
        System.debug('results---' + results);
        return results;
    }
    
    /***********************************************
    * Method Name : searchAccount
    * Author : Pankaj
    * Inputs : List<Account> accounts, Boolean showSubtitle
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Health Care Facility
    *********************************************/
    private static List<LookupSearchResult> searchAccount( List<Account> accounts, Boolean showSubtitle) {

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            showSubtitle ? ((opAccountReference.Parent.Name != null ? opAccountReference.Parent.Name + ' . ' : '') + (opAccountReference.Entity_Id__c != null ? opAccountReference.Entity_Id__c : '')) : null,
                            opAccountReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : getHealthCareFacilityDetails
    * Author : Pankaj
    * Inputs : String facilityId
    * Description: This method return list of Accounts with Entity Type Health Care Facility
    *********************************************/
    @AuraEnabled
    public static List<Account> getHealthCareFacilityDetails(String facilityId) {
        List<Account> accList = [SELECT Entity_Id__c,Entity_Type__c,Name,ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode,
                ShippingState,ShippingStreet,Parent.Name
            FROM Account where Entity_Type__c = 'Health Care Facility' AND Id =: facilityId];
        return  accList;
    }

    /***********************************************
    * Method Name : getCountyAccountList
    * Author : Chandrabhan
    * Inputs : 
    * Description: This method return list of Accounts with Entity Type County
    *********************************************/
    @AuraEnabled
    public static List<Account> getCountyAccountList() {
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Entity_Type__c = 'County' AND Skip_Registration__c != true order by Name];
        return  accList;
    }

    /***********************************************
    * Method Name : createUserRegistration
    * Author : Pankaj
    * Inputs : String record
    * Description: This method create user registration data
    *********************************************/
    @AuraEnabled
    public static void createUserRegistration(String record){
        try{
            User_Registration__c userRegData = (User_Registration__c) JSON.deserialize(record, User_Registration__c.class);
            /** Changes for - CALOESHHA-17 - Homeowner Register for an Account - Start */
            List<Account> hhAccountsWithUniqueHouseholdNumber = new List<Account>();
            if (userRegData.Unique_Household_Number__c != null) {
                String hhAccName = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + userRegData.Unique_Household_Number__c;
                hhAccountsWithUniqueHouseholdNumber = [SELECT Id, Name FROM Account WHERE Name = :hhAccName];
            }
            /** Changes for - CALOESHHA-17 - Homeowner Register for an Account - End */

            System.debug('record[------->'+record);
            System.debug('userRegData[------->'+userRegData);
            List<User> users = [Select id,Name,Email from User where Username =: userRegData.Email__c];
            if(users.size() > 0){
                throw new CustomException(System.Label.HH_EN_ExistingUserWithEmailErrorMessage);
            }
            /** Changes for - CALOESHHA-17 - Homeowner Register for an Account
            * If the user Record Type is of "HH_Registration", then creating User Registration record with HH Record Type. */
            else if (userRegData.RecordTypeId == Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId()) {
                checkForHomeownerDuplicateContact(userRegData);
                userRegData.Status__c = HH_CONSTANTS.UserRegistration_Status_VerificationPending;
                String passwordResetToken = SkyWalkerUtility.generateToken(40);
                userRegData.Token__c = passwordResetToken;
                /** Generating Household Number for User Registration record if the Value is null on record. */
                if (userRegData.Unique_Household_Number__c == null
                        || userRegData.Unique_Household_Number__c == ''
                        || hhAccountsWithUniqueHouseholdNumber?.size() == 0) {
                    String uniqueHouseholdToken = SkyWalkerUtility.generateToken(6);
                    userRegData.Unique_Household_Number__c = uniqueHouseholdToken;
                }
                /** If "Is Mailing Address Different?" filed is selected as No, then copying the Mailing Address from Physical Address fields.*/
                if (userRegData.Is_Mailing_Address_Different__c == HH_CONSTANTS.PickList_No) {
                    userRegData.Is_Mailing_Address_a_Foreign_Address__c = userRegData.Is_Physical_Address_a_Foreign_Address__c == null ? null : userRegData.Is_Physical_Address_a_Foreign_Address__c;
                    userRegData.Mailing_Address__c = userRegData.Street_Address__c == null ? null : userRegData.Street_Address__c;
                    userRegData.Mailing_City__c = userRegData.City_Name__c == null ? null : userRegData.City_Name__c;
                    userRegData.Mailing_State_Province__c = userRegData.State__c == null ? null : userRegData.State__c;
                    userRegData.Mailing_Zip_Postal_Code__c = userRegData.Zip_Postal_Code__c == null ? null : userRegData.Zip_Postal_Code__c;
                    userRegData.Mailing_Country_Region__c = userRegData.Country_Region__c == null ? null : userRegData.Country_Region__c;
                }
                Id registrationRecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
                userRegData.RecordTypeId = registrationRecordTypeId;
                insert userRegData;
            }
            else {
                /*if(userRegData.Entity_Type__c == 'State Agency') {
                    userRegData.County__c = 'State Agency';
                } else if(userRegData.Entity_Type__c == 'Non-Governmental Entity' && userRegData.Non_Government_Entity_Type__c == 'Other') {
                    userRegData.County__c = 'Non-Governmental Entity';
                }*/
                userRegData.Status__c = 'Verification Pending';
                String token = SkyWalkerUtility.generateToken(40);
                userRegData.Token__c = token;
                Id registrationRecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('Registration').getRecordTypeId();
                userRegData.RecordTypeId = registrationRecordTypeId;
                insert userRegData;
            }
        }
        catch(Exception ex) {
            if(ex.getMessage().contains('NO_MASS_MAIL_PERMISSION')){
                throw new CustomException('Something went wrong, please contact your administrator.');
            }else{
            	throw new CustomException(ex.getMessage());
            }
        }
    }

    /***********************************************
    * Method Name : getContactRecords
    * Author : Rakesh
    * Inputs : String Id
    * Description: This method returns contact Record filtered by Id
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getContactRecords(String contactRecordId){
        try {
            Map<String, Object> returnMap = new Map<String, Object>();
            if(String.isBlank(contactRecordId)) {
                returnMap.put('Success', false);
                return returnMap;
            } 
            List<Contact> contactList = [SELECT Id, FirstName, LastName, Email, Phone, AccountId, Account.Name, Account.Entity_Type__c
                                            FROM Contact
                                            WHERE Id = :contactRecordId];
            if(contactList.size() > 0) {
                returnMap.put('ContactRecord', contactList[0]);
                returnMap.put('Success', true);
            } else {
                returnMap.put('Sucess', false);
            }
            return returnMap;
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }

     /***********************************************
    * Method Name : checkForHomeownerDuplicateContact
    * Author : Shantanu
    * Inputs : User_Registration__c userReg (CWMP RecordType)
    * Description: This method will check for any duplicate contact with provided email address and 
                    Contact Type as CWMP Homeowner.
                    If exists, throw duplicate contact Exception.
    *********************************************/
    public static void checkForHomeownerDuplicateContact(User_Registration__c userReg) {
        List<Contact> contacts = [SELECT Id,Email FROM Contact WHERE Email =:userReg.Email__c AND
                                    Contact_Type__c =: HH_CONSTANTS.HH_Contact_Type_Homeowner ];
        if (contacts.size() > 0) {
            throw new CustomException(System.label.HH_EN_Duplicate_Homeowner_Contact_Detected);   
        }
    }
}