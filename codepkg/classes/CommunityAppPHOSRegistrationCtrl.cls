/***********************************************************************************************************************************
* Class Name   : CommunityAppPHOSRegistrationCtrl
* Description  : An apex page controller that supports self registration of users in communities that allow self registration
* Author       : Pankaj
* Created On   : 07/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            07/09/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CommunityAppPHOSRegistrationCtrl {

    /***********************************************
    * Method Name : processPHOSRequest
    * Author : Pankaj
    * Inputs : String userRegistrationStr
    * Description: This method process the PHOS App Request.
    *********************************************/
    @AuraEnabled
    public static void processPHOSRequest(String userRegistrationStr) {

        User_Registration__c userRegistration = (User_Registration__c) JSON.deserialize(userRegistrationStr, User_Registration__c.class);
        system.debug('userRegistration----'+userRegistration);

        User_Registration__c newUserReg = [ SELECT City__c,Community_Application__c,
                                            County__c,Courts__c,Email__c,Entity_Type__c,Facility_Name__c,Facility__c,
                                            Federal_Tax_ID__c, First_Name__c,Last_Name__c,
                                            Non_Governmental_Entity__c,Non_Government_Entity_Type__c,
                                            Password__c,Phone__c,Special_District__c,State_Agency__c,
                                            State__c,Status__c,Street_Address__c,Token__c,Tribal__c,City_Name__c,
                                            Zip_Postal_Code__c,User__c FROM User_Registration__c
                                            WHERE User__c =: UserInfo.getUserId() and Email__c =: UserInfo.getUserEmail()
                                            ORDER BY CreatedDate DESC LIMIT 1];
        String newUserRegistration = JSON.serialize(newUserReg);
        //newUserRegistration = newUserRegistration.replace('Id','----');
        User_Registration__c userReg = (User_Registration__c) JSON.deserialize(newUserRegistration, User_Registration__c.class);
        userReg.Status__c = 'App Requested';
        // remove id from existing record of User Registration
        userReg.Id = null;
        userReg.Community_Application__c = userRegistration.Community_Application__c;
        userReg.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
        insert userReg;
        updateOwner(userReg.Id);
        PHOS_UserInfoEmail userInfoObject = new PHOS_UserInfoEmail(userReg.Id);
        System.enqueueJob(userInfoObject);
        //sendEmailInformationForPHOSAppRequest(userReg.Id);
        //System.assertEquals('34', '4444');
    }

    /***********************************************
    * Method Name : processPHOSRequestForRejection
    * Author : Pankaj
    * Inputs : String userRegistrationStr
    * Description: This method process the PHOS App Request for Rejection.
    *********************************************/
    @AuraEnabled
    public static void processPHOSRequestForRejection(String userRegistrationStr) {
        User userRec =  ApexUtils.getCurrentUserDetails();
        User_Registration__c userRegistration = (User_Registration__c) JSON.deserialize(userRegistrationStr, User_Registration__c.class);
        system.debug('userRegistration----'+userRegistration);
        userRegistration.Status__c = 'App Requested';
        // remove id from existing record of User Registration
        userRegistration.Community_Application__c = userRegistration.Community_Application__c;
        userRegistration.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
        userRegistration.First_Name__c = userRec.FirstName;
        userRegistration.Last_Name__c = userRec.LastName;
        userRegistration.Email__c = userRec.Email;
        userRegistration.User__c = userRec.Id;
        userRegistration.Rejection_Reason__c = 'Entity Change Required';
        insert userRegistration;
        UserService.createCommunityStandardUser(new List<User_Registration__c>{userRegistration});
        updateOwner(userRegistration.Id);
        PHOS_UserInfoEmail userInfoObject = new PHOS_UserInfoEmail(userRegistration.Id);
        System.enqueueJob(userInfoObject);
    }

    /***********************************************
    * Method Name : updateOwner
    * Author : Pankaj
    * Inputs : String recordId
    * Description: This method update the record owner.
    *********************************************/
    public static void updateOwner(String recordId){
        User_Registration__c userReg = [SELECT Id,County__c,Non_Governmental_Entity__c,State_Agency__c,Entity_Type__c FROM User_Registration__c WHERE Id =: recordId];
        //String comment = 'Record for approval';

        List<Group> queues = new List<Group>();
        User user = [SELECT Id,Account.Parent.Queue_Name__c FROM User WHERE Id=:UserInfo.getUserId()];

        queues = [SELECT Id FROM Group WHERE DeveloperName=:user.Account.Parent.Queue_Name__c AND Type='Queue'];
        if(queues.size() == 0) return;

        User_Registration__c updateUserReg = new User_Registration__c(Id = userReg.Id, OwnerId = queues.get(0).Id);
        update updateUserReg;
    }

    /***********************************************
    * Method Name : getUserDetails
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of Contact details.
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getUserDetails(){
        Map<String,Object> returnMap = new Map<String,Object>();
        String userId = UserInfo.getUserId();
        User userRec = [SELECT Id,ContactId from User where Id =:userId];
        Contact contactRec = [SELECT FirstName,LastName,Email,Phone,Account.Name,Account.Parent.Name,Account.Entity_Type__c,Entity_Change_Requested__c FROM Contact WHERE Id =: userRec.ContactId];
        returnMap.put('ContactDetails',contactRec);
        return returnMap;
    }



    /***********************************************
    * Method Name : formatPlainBody
    * Author : Pankaj
    * Inputs : String plainBody
    * Description: This method return mail plain body, replace \n to <br/>.
    *********************************************/
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

    /***********************************************************************************************************************************
    * Class Name   : PHOS_UserInfoEmail
    * Description  : Inner class for send email to Queue members when user send PHOS App Request.
    * Author       : Pankaj
    * Created On   : 07/09/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj            07/09/2020       Initial Implementation
    **************************************************************************************************************************************/

    private class PHOS_UserInfoEmail implements Queueable {
        private String recordId;
        public  PHOS_UserInfoEmail(String recordId)
        {
            this.recordId = recordId;
        }
        public void execute(QueueableContext context) {
            System.debug('Line=111'+recordId);
            User_Registration__c userReg = [SELECT Id,OwnerId FROM User_Registration__c WHERE Id =: recordId];
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            List<Group> queues = new List<Group>();
            List<String> ccAddresses = new List<String>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate et=[SELECT Id FROM EmailTemplate WHERE developerName = 'PHOS_User_Registration_Request'];
            List<User> userList = [SELECT Id,Email FROM User WHERE Id IN (SELECT UserOrGroupId  FROM GroupMember WHERE Group.Type='Queue' AND GroupId=:userReg.OwnerId) AND IsActive=true];
            System.debug('Line 119'+userList);
            if(userList.size() == 0) return;
            for (User userRecord : userList) {
                if(userRecord.Email != null)
                 ccAddresses.add(userRecord.Email);
            }
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id, null, recordId);
            mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            mail.subject = singleEmail.subject;
            mail.setWhatId(userReg.Id);
            mail.setSaveAsActivity(true);
            mail.setCcAddresses(ccAddresses);
            mails.add(mail);
            System.debug('Line 132'+mail);
            Messaging.sendEmail(mails);
        }
    }

}