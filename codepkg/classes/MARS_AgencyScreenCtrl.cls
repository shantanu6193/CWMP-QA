public without sharing class MARS_AgencyScreenCtrl {
   
  @AuraEnabled 
  public static DataTableResponse getAccountDetails(String accId) {
    system.debug('accId: '+accId);
    DataTableResponse dataTableResponse = new DataTableResponse();
    try {
        List<Account> accRecord =
            [ SELECT 
            Id,
            Name,
            Entity_Type__c, 
            Chief_Name__c,
            MACS_ID__c,
            Chief_Email__c,
            Department_City__c,
            Department_Email__c,
            Department_State__c,
            Phone,
            ShippingStreet,
            ShippingCity,
            ShippingState,
            ShippingPostalCode,
            BillingStreet,
            BillingCity,
            BillingState,
            BillingPostalCode,
            Federally_Recognized_Tribe__c,
            Federal_Fire_Department__c,
            Department_of_Defence__c,
            Volunteer__c,
            Federal_Tax_ID__c,
            DUNS__c,
            Fiscal_Supplier_ID__c,
            Fiscal_Address_Id__c, 
            State_Region_Op_Area_County_Id__c,MARS_Is_Active__c,MARS_IsResponder__c,
            Mars_Agency_Type__c, MARS_Agency_Type_Other__c, MARS_Combination__c,MARS_Paid__c,MARS_Region__c, MARS_Operational_Area__c FROM Account WHERE Id =:accId ];
        dataTableResponse.accountRec = JSON.serialize(accRecord[0]);
        dataTableResponse.isTableEditable = !(MARS_SurveyLineItemsDataTableCtrl.getRelationshipStrength(accId));
        return dataTableResponse;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
@AuraEnabled 
public static Boolean saveAccount(String accountStr) {
  try {
    Account accRecord = (Account)JSON.deserialize(accountStr, Account.class);
    upsert accRecord;
    return true;
  } catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
  }
}

@AuraEnabled
public static void inviteUsersToAgency(string emails, string accessagencylink, string agencyname){
    try {
      
      sendInviteEmail(emails, accessagencylink,agencyname );
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

public static void sendInviteEmail( string emails, string accessagencylink, string agencyname ) {

  List<String> lstAlpha = emails.split(',');

  
  List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();

  
  for (String sendEmailTo : lstAlpha) {
  

    ///EMAIL START
    List<String> toAddresses = new List<String>();
    String fromAddr = KeyValueHelper.getTextValue('MARS_From_Email_Addresses');
    List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
    Id OrgWideEmailAddressId;

    if(String.isNotBlank(fromAddr)){
      fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
  }
  if(fromAddresses.size()>0){
      OrgWideEmailAddressId = fromAddresses[0].Id;
  }

  EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'MARS_Agency_Invite_User'];
  toAddresses.add(sendEmailTo);
  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

  mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);

  //Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null, null);
  //mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
  //mail.subject = singleEmail.subject;


  mail.setSubject('CalOES MARS Invitation | Agency: ' +  agencyname );
  
  string  newurlLink = '';
  newurlLink = accessagencylink + '' + '&email=' + toAddresses[0];
    
  mail.setHtmlBody( '<h2> You have been invited to the CalOES MARS System by your administrator. </h2> ' +
  '  <h3> To accept the invite click on the link:</h3> </br> <a href="' + newurlLink +'">Accept Invite </a>'    );
  mail.setToAddresses(toAddresses);
  mails.add(mail);


  }

  Messaging.sendEmail(mails);

}

  
  public class DataTableResponse {
        public DataTableResponse() {}
            
        @AuraEnabled public String accountRec {get; set;}
        @AuraEnabled public Boolean isTableEditable { get; set;}
  }
}