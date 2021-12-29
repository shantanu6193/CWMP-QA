/***********************************************************************************************************************************
* Class Name   : HH_UpdateTaxParcelAndFloodplain_Ctrl
* Description  : This Controller class is used in HhUpdateTaxParcelAndFloodplain LWC component.
* Author       : Ricky
* Created On   : 10/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              23/08/2021       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HH_UpdateTaxParcelAndFloodplain_Ctrl {

    /***********************************************
    * Method Name : getRecordDetails
    * Author : Ricky
    * Input Parameters - 1. masterRecordId - Home Hardening Application Record Id, whose data needs to be fetched.
    *                    2. userId - current logged In user Id, In order to check where the component needs to be visible to user or not?
    * Description: This method is used to fetch the record detail by passing record Id and user ID and returns the data to LWC page.
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getRecordDetails(String masterRecordId, String userId) {
        /** Variable to store the return Type for this method. */
        Map<String, Object> resultMap = new Map<String, Object>();

        /** Fetching Application record whose Id has been passes to the method. */
        List<HH_Application__c> applicationRecord = [SELECT Id, Name, Stage__c, Status__c, Tax_Parcel_Number__c,
                Is_the_property_in_the_floodplain__c, Assessor_Email__c, Income_Bracket__c,Assessed_Value_of_the_Property__c FROM HH_Application__c WHERE Id =: masterRecordId LIMIT 1];

        /** Checking if the Application record/Data is available. */
        if (applicationRecord?.size() == 1) {
            /** First element in the return Map is Home Hardening Application record. */
            resultMap.put('hhApplication', applicationRecord);
            /** Second element in the return map is User Permission, That is If the Component needs to be displayed to user or not? */
            resultMap.putAll(getUserPermissionForComponent(userId));
            /** Third element in the return map is Is the details in component is editable in current stage of the record? */
            resultMap.put('isEdit', isDetailsEditable(applicationRecord[0]));
        }
        /** Returning the result map to LWC component. */
        return resultMap;
    }

    /***********************************************
    * Method Name : getUserPermissionForComponent
    * Author : Ricky
    * Description: This method is used to decide whether component needs to be visible to the current logged In user or not based on assigned Permission.
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getUserPermissionForComponent(String userId) {
        /** Variable to store the boolean value for return Type. */
        Map<String, Object> returnMap = new Map<String, Object>();
        /** Condition to check if the User Id is available in order to fetch the user record data. */
        if (userId != null && userId != '') {
            /** Set collection to store the current user available Permission Set Assignment API Name. */
            Set<String> currentUserPermissionSet = new Set<String>();
            /** Fetching the User record and its related Permission Set assignments. */
            List<User> userRecord = [SELECT Id, Name, Profile.Name,
                                            (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                                        FROM User WHERE Id =: userId LIMIT 1];

            /** Checking for null pointer exception for user record and then Iterating the Permission Set assignments,
             * in order to collect the API names of teh assigned Permission Sets. */
            if (userRecord?.size() == 1 && userRecord[0]?.PermissionSetAssignments?.size() > 0) {
                for (PermissionSetAssignment pAssignment : userRecord[0]?.PermissionSetAssignments) {
                    currentUserPermissionSet.add(pAssignment.PermissionSet.Name);
                }
            }
            /** Need to add this condition for Sprint 5 - || currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName */
            /** Checking if the Current user is System Admin or user has Community User/Cal OES User Permission Set,
             * then only setting the return type Value to true. */
            if (userRecord?.size() == 1
                    && (userRecord[0]?.Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin
                        || currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                        || currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName))) {
                returnMap.put('isEdit', true);
                if (userRecord[0]?.Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin) {
                    returnMap.put('userType', 'Admin');
                }
                else if (currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)) {
                    returnMap.put('userType', 'Community');
                }
                else if (currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)) {
                    returnMap.put('userType', 'CalOES');
                }
            }

            /*if (userRecord?.size() == 1
                    && (userRecord[0]?.Profile.Name == HH_CONSTANTS.HH_Profile_SystemAdmin
                        || (currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CommunityUser_APIName)
                            && ((applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_CommunityReview
                                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI)))
                        || (currentUserPermissionSet?.contains(HH_CONSTANTS.HH_PermissionSet_CalOESUser_APIName)
                            && ((applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_Assessment
                                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OpenRFINeedMoreInfo)
                                || (applicationRecord.Stage__c == HH_CONSTANTS.HHApplication_Stage_OESReview
                                    && applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESOpenRFI))))) {
                returnType = true;
            }*/
            }
        return returnMap;
    }

    /***********************************************
    * Method Name : isDetailsEditable
    * Author : Ricky
    * Description: This method is used to decide whether the details in the component is editable for the current stage of Application?
    *********************************************/
    public static Boolean isDetailsEditable(HH_Application__c applicationRecord) {
        /** Variable to store the boolean value for return Type. */
        Boolean isEdit = true;
        /** Condition to check if the Current record Stage-Reason is Community Rejection/OES Rejection/FEMA Rejection,
         * then only setting the return type to true. */
        if (applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_RejectedDoesNotMeetCriteria
                || applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_OESDecisionRejected
                || applicationRecord.Status__c == HH_CONSTANTS.HHApplication_Status_FEMADecisionRejected) {
            isEdit = false;
        }
        return isEdit;
    }

    /***********************************************
    * Method Name : updateTaxParcelAndFloodPlain
    * Author : Ricky
    * Description: This method is used to update the Tax Parcel number, Is Your Property in 100 year Floodplain?, and Assessor Email of the record passed from LWC component.
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> updateTaxParcelAndFloodPlain(String record, String userId) {
        /** Variable to store the return Type for this method after the record is Saved. */
        Map<String, Object> returnMap = new Map<String, Object>();
        /** Application variable to store the deserialized Application record passes from LWC component. */
        HH_Application__c applicationRecordDeserialized = (HH_Application__c) JSON.deserialize(record, HH_Application__c.class);
        /** Adding the values in Application record in order to update it. */
        HH_Application__c applicationRecord = new HH_Application__c();
        applicationRecord.Id = applicationRecordDeserialized.Id;
        applicationRecord.Tax_Parcel_Number__c = applicationRecordDeserialized.Tax_Parcel_Number__c;
        applicationRecord.Is_the_property_in_the_floodplain__c = applicationRecordDeserialized.Is_the_property_in_the_floodplain__c;
        applicationRecord.Assessor_Email__c = applicationRecordDeserialized.Assessor_Email__c;
        applicationRecord.Assessed_Value_of_the_Property__c = applicationRecordDeserialized.Assessed_Value_of_the_Property__c;
        applicationRecord.Income_Bracket__c = applicationRecordDeserialized.Income_Bracket__c;
        /** Updating the Application record,
         * 1. If its success - Then returning the result map.
         * 2. If Error - then Passing the Error message to component. */
        try {
            update applicationRecord;

            returnMap = getRecordDetails(applicationRecord.Id, userId);
            return returnMap;
        }
        catch (Exception e) {
            throw new AuraHandledException(CustomExceptionController.getSpecificErrorMessage(e.getMessage()));
        }
    }
}