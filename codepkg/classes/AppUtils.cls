/***********************************************************************************************************************************
* Class Name   : AppUtils
* Description  : AppUtils Class contains method related to common App functionality  
* Author       : Pankaj
* Created On   : 04/03/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            04/03/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class AppUtils {

    public static String emailRegEx1 = '[A-Za-z0-9_\\-\\.]+@[A-Za-z0-9_\\-\\.]+[\\.]+[A-Za-z0-9_\\-\\.]+';
    public static Pattern myPattern1 = Pattern.compile(emailRegEx1);
    private static User loggedInUser;

    /***********************************************
    * Method Name : getAllFields
    * Author : Pankaj
    * Inputs : String objectName
    * Description: This method return list of strings with all fields of specified object 
    *********************************************/ 
    public static List<String> getAllFields(String objectName) {
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<string> selectFields = new List<string>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());
            }
        }
        return selectFields;
    }

    /***********************************************
    * Method Name : generateSnapshotInJSON
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method generate snapshot in json and insert it
    *********************************************/ 
    public static void generateSnapshotInJSON(String orderId) { 
        List<String> orderFieldsToQuery = AppUtils.getAllFields('Order__c');
        List<String> orderItemFieldsToQuery = AppUtils.getAllFields('Order_Product__c');
        orderItemFieldsToQuery.add('Product__r.Family');
        String requestorFields = 'Requestor__r.Account.Name,Requestor__r.Email,Requestor__r.FirstName,Requestor__r.LastName,Requestor__r.Phone,Requestor__r.Title';
        String delieveryFields = 'Delivery_Recipient__r.Email,Delivery_Recipient__r.FirstName,Delivery_Recipient__r.LastName,Delivery_Recipient__r.Phone,Delivery_Recipient__r.Title';
        String query = 'Select ' + String.join(orderFieldsToQuery, ', ')
                + ', ' + requestorFields + ', ' + delieveryFields
                + ',(Select '+String.join(orderItemFieldsToQuery, ',')+' From Order_Products__r)' + ' From Order__c Where Id=\'' + orderId + '\'';
        Order__c orderRec = Database.query(query);
        Integer maxVersion = getOrderVersion(orderId);
        Order_Version__c orderVersion = new Order_Version__c(Order_Custom__c = orderId, Version_Data__c=JSON.serialize(orderRec), Version__c = maxVersion);
        insert orderVersion;
    }

    /***********************************************
    * Method Name : generateSnapshotInJSONForDistributionPlan
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method generate snapshot in json for distribution plan and insert it
    *********************************************/ 
    public static void generateSnapshotInJSONForDistributionPlan(String orderId) {
        List<String> orderItemFieldsToQuery = AppUtils.getAllFields('Order_Product__c');
        List<String> distributionPlanFieldsToQuery = AppUtils.getAllFields('Product_Distribution_Plan__c');
        String versionData1 = '';
        String versionData2 = '';
        String versionData3 = '';
        String versionData4 = '';
        String versionData5 = '';
        String versionData6 = '';
        String countyFields = 'County__r.Name';
        String query = 'Select ' + String.join(orderItemFieldsToQuery, ', ') +  ',(Select '+String.join(distributionPlanFieldsToQuery, ',')+ ',' + countyFields +' From Product_Distribution_Plans__r)' + ' From Order_Product__c Where Order__c=\'' + orderId + '\'';
        //String query = 'Select '+ String.join(orderItemFieldsToQuery, ',') + ',' + '(Select ' + String.join(distributionPlanFieldsToQuery, ',')  + 'from Product_Distribution_Plans__r)' + 'FROM Order_Product__c Where Order__c=\'' + orderId + '\'';
        List<Order_Product__c> orderItemRec = Database.query(query);
        String recordString = JSON.serialize(orderItemRec);
        System.debug('str----'+recordString.length());

        if(recordString.length() > 131072) {
            versionData1 = recordString.substring(0,131072);
            if(recordString.length() <= 262144) {
                versionData2 = recordString.substring(131072,recordString.length());
            }
        }
        if(recordString.length() > 262144) {
            versionData2 = recordString.substring(131072,262144);
            if(recordString.length() <= 393216) {
                versionData3 = recordString.substring(262144,recordString.length());
            }
        }
        if(recordString.length() > 393216) {
            versionData3 = recordString.substring(262144,393216);
            if(recordString.length() <= 524288) {
                versionData4 = recordString.substring(393216,recordString.length());
            }
        }
        if(recordString.length() > 524288) {
            versionData4 = recordString.substring(393216,524288);
            if(recordString.length() <= 655360) {
                versionData5 = recordString.substring(524288,recordString.length());
            }
        }
        if(recordString.length() > 655360) {
            versionData5 = recordString.substring(524288,655360);
            versionData6 = recordString.substring(655360,recordString.length());
        }
        if(recordString.length() <= 131072) {
            versionData1 = recordString;
        }

        Integer maxVersion = getDistributionPlanVersion(orderId);
        Distribution_Plan_Version__c distributionVersion = new Distribution_Plan_Version__c(Order__c = orderId, Version_Data__c=versionData1, Version_Data_2__c=versionData2, Version_Data_3__c=versionData3, Version_Data_4__c=versionData4, Version_Data_5__c=versionData5, Version_Data_6__c=versionData6, Version__c = maxVersion);
        insert distributionVersion;
    }

    /***********************************************
    * Method Name : getOrderVersion
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return order version
    *********************************************/ 
    private static Integer getOrderVersion(String orderId){
        List<AggregateResult> AggregateResultList = [select MAX(Version__c)maxVersion from Order_Version__c where Order_Custom__c =: orderId];
        if(AggregateResultList != null && AggregateResultList.size() > 0) {
            if(AggregateResultList[0].get('maxVersion') != null){
                Integer maxVersion = Integer.valueOf(AggregateResultList[0].get('maxVersion'));
                return maxVersion + 1;
            }
        }
        return 1;
    }

    /***********************************************
    * Method Name : getDistributionPlanVersion
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return distribution plan version
    *********************************************/ 
    private static Integer getDistributionPlanVersion(String orderId){
        List<AggregateResult> AggregateResultList = [select MAX(Version__c)maxVersion from Distribution_Plan_Version__c where Order__c =: orderId];
        if(AggregateResultList != null && AggregateResultList.size() > 0) {
            if(AggregateResultList[0].get('maxVersion') != null){
                Integer maxVersion = Integer.valueOf(AggregateResultList[0].get('maxVersion'));
                return maxVersion + 1;
            }
        }
        return 1;
    }

    /***********************************************
    * Method Name : fetchAllEmailAddresses
    * Author : Pankaj
    * Inputs : String data
    * Description: This method return list of strings of email addresses
    *********************************************/ 
    public static List<String> fetchAllEmailAddresses(String data) {
        return fetchAllMatches(data, myPattern1);
    }

    /***********************************************
    * Method Name : fetchAllMatches
    * Author : Pankaj
    * Inputs : String data, Pattern pat
    * Description: This method return list of strings
    *********************************************/ 
    public static List<String> fetchAllMatches(String data, Pattern pat) {
        System.debug('input text: ' + data);
        List<String> result = new List<String>();
        Matcher mer = pat.matcher(data);
        String email = null;
        while (mer.find()) {
            email = mer.group();
            System.debug('found: ' + email);
            result.add(email);
        }
        System.debug('result: ' + result);
        return result;
    }

    /*
    get field value in formatted string based on field type
     */
    public static String getFieldValueAsString(Sobject record, String fieldAPIName) {
        String value = '';
        if(fieldAPIName.contains('.')){
            List<String> relationshipFields = fieldAPIName.split('\\.');
            Sobject temp;
            integer i = 0;
            String singleField = '';
            for(i=0;i<relationshipFields.size()-1;i++){
                singleField = relationshipFields[i];
                if(temp == null){
                    temp = record.getSobject(singleField);
                }else{
                    temp = temp.getSobject(singleField);
                }
                if(temp == null) {
                    return '';
                }
            }
            if(temp != null  && temp.get(relationshipFields[i]) != null){
                record = temp;
                fieldAPIName = relationshipFields[i];
            } else {
                return '';
            }
        }

        String objectAPIName = String.valueOf(record.getSObjectType());
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        if(record.get(fieldAPIName) == null) return value;

        Schema.DisplayType FldType = fieldMap.get(fieldAPIName).getDescribe().getType();
        String fieldType = String.valueOf(FldType);
        if(fieldType == 'DateTime') {
            value = getFormattedDateTime(Datetime.valueOf(record.get(fieldAPIName)));//.format('yyyy-MM-dd HH:mm:ss');
        } else if(fieldType == 'Double' || fieldType == 'Currency'){
            value = getFormattedNumber(Double.valueOf(record.get(fieldAPIName)), fieldMap.get(fieldAPIName).getDescribe().getScale(),
                    (fieldType == 'Currency'));
        }else if(fieldType == 'Email'){
            value = '<a href="mailto:'+String.valueOf(record.get(fieldAPIName))+'">'+String.valueOf(record.get(fieldAPIName))+'</a>';
        }
        else {
            value = String.valueOf(record.get(fieldAPIName));
        }
        return value;
    }

    public static String getFormattedDateTime(DateTime dateTimeToFormat) {
        // todo - add in constant
        return dateTimeToFormat.format('M/d/yyyy h:mm a z');
    }

    public static String getFormattedDateTime(DateTime dateTimeToFormat, String timezoneSidKey) {
        // todo  add on constant
        return dateTimeToFormat.format('M/d/yyyy h:mm a z', timezoneSidKey);
    }

    public static String getFormattedDateTimeInUserTimezone(DateTime dateTimeToFormat, Id userId) {
        if(dateTimeToFormat != null) {
            List<User> listUser = [SELECT ID, TimeZoneSidKey FROM User WHERE ID = :userId];
            if(listUser.isEmpty()) {
                return getFormattedDateTime(dateTimeToFormat);
            }
            String timezoneSidKey = listUser[0].TimeZoneSidKey;
            return getFormattedDateTime(dateTimeToFormat, timezoneSidKey);
        }
        return null;
    }

    public static String getFormattedNumber(Double val, Integer decimalScaleVal, Boolean isCurrency) {
        String formattedNo = '';
        System.debug('val-----' + val);
        if (val != null) {
            String format =  '###,###,###,##0';
            decimalScaleVal = decimalScaleVal == null ? 0 : decimalScaleVal;
            if (decimalScaleVal > 0) {
                format += '.';
            }
            for (Integer i=0; i<decimalScaleVal; i++) {
                format += '0';
            }
            List<String> args = new String[]{'0','number',format};
            formattedNo = String.format(val.format(), args);
            if(isCurrency == true) {
                formattedNo = '$' + formattedNo;
            }
        }
        return formattedNo;
    }

     /***********************************************
    * Method Name : getFieldValue
    * Author : Atul
    * Inputs : Sobject record, String fieldAPIName
    * Description: This method return sobject record
    *********************************************/ 

     public static Object getFieldValue(Sobject record, String fieldAPIName) {
        if(String.isEmpty(fieldAPIName)) {
            return null;
        }
        Object value = null;
        if(fieldAPIName.contains('.')){
            List<String> relationshipFields = fieldAPIName.split('\\.');
            Sobject temp;
            integer i = 0;
            for(i=0;i<relationshipFields.size()-1;i++){    
                String singleField = relationshipFields[i];                                                 
                if(temp == null){
                    temp = record.getSobject(singleField);
                    
                }else{
                    temp = temp.getSobject(singleField);
                }
                if(temp == null) { 
                    return null;
                }   
            } 
            if(temp != null && temp.get(relationshipFields[i]) != null){
                value = temp.get(relationshipFields[i]);
            }
        }else{
            value = record.get(fieldAPIName);
        }
        return value;
    }


     /***********************************************
    * Method Name : findObjectAPIName
    * Author : Atul
    * Inputs : String recordId
    * Description: This method return sobject Name
    *********************************************/
     public static string  findObjectAPIName( String recordId ){  
        String objectType = String.valueOf(((Id)recordId).getSobjectType());
        return objectType;    
    }

     /***********************************************
    * Method Name : handleEmailTemplatePreview
    * Author : Atul
    * Inputs : String templateId, String recordId
    * Description: This method return Single Email Message
    *********************************************/
    public static Messaging.SingleEmailMessage handleEmailTemplatePreview(String templateIdVal, String whoIdVal,String recIdVal){
        
            Messaging.SingleEmailMessage emailVal= Messaging.renderStoredEmailTemplate(templateIdVal, whoIdVal, recIdVal);
            return emailVal;
    }

    /***********************************************
    * Method Name : getLoggedInUser
    * Author : Prajakta
    * Description: This method returns current user
    *********************************************/
    public static User getLoggedInUser() {
        if(loggedInUser == null) {
            List<User> users = [select Id,Name,Profile.Name,AccountId from User where Id=:UserInfo.getUserId()];
            if(users.size() > 0) {
                loggedInUser = users.get(0);
            } else {
                loggedInUser = new User();
            }

        }
        return loggedInUser;
    }

    /***********************************************
    * Method Name : isLoggedInUserPortal
    * Author : Prajakta
    * Description: This method returns is current user portal
    *********************************************/
    public static Boolean isLoggedInUserPortal() {
        // if it is automated user
        if(UserInfo.getName() == 'Automated Process') {
            return false;
        }
        User u = getLoggedInUser();
        if(u.AccountId != null ) {
            return true;
        }
        return false;
    }

    /**********************************************************
    * Method Name : generateToken
    * Author : Dayal
    * Description: This method return the token number
    ***********************************************************/
    
    public static String generateToken(Integer length) {
        DateTime d = System.now();
        Long ll = d.getTime();
        String newS = '' + ll;
        String algorithmName = 'HMacSHA1';
        Blob mac = Crypto.generateMac(algorithmName, Blob.valueOf(newS), Blob.valueOf(String.valueOf(Math.random()*10000)));
                                                                  
        String token = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');
        token = token.replaceAll('%', 'p');
        Integer tokenLength = token.length();
        if (length > 0 && token.length() > length) {
            Integer startingPnt = tokenLength - length; 
            return token.substring(startingPnt, tokenLength); 
        }
        else {
            return token;
        }
    }

    /**********************************************************
    * Method Name : getCurrentUSerAppName
    * Author : Dayal
    * Description: This method return current App Name 
    ***********************************************************/

    public static String getCurrentUSerAppName(){
        List<UserAppInfo> userAppList = [SELECT Id, AppDefinitionId
        FROM UserAppInfo WHERE UserId = :UserInfo.getUserId()  ORDER BY CreatedDate DESC LIMIT 1];
     
        List<AppDefinition> appDefList = new List<AppDefinition>();
        if(userAppList.size() > 0) {

            appDefList = [SELECT DurableId, Label,DeveloperName FROM AppDefinition
            Where DurableId = :userAppList[0].AppDefinitionId LIMIT 1];

        }
       
        if(appDefList.size() > 0){
        return appDefList[0].DeveloperName;
        }
        else {
            return null;
        }

    }
}