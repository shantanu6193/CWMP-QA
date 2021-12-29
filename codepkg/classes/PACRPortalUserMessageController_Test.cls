/*************************************************************************************
* Class Name   : PACRPortalUserMessageController_Test
* Description  : used to test controller
* Author       : Dayal
* Created On   : 17/11/2021
* Modification Log:  
* -----------------------------------------------------------------------
* Developer             Date             Description 
* -----------------------------------------------------------------------
* Dayal               17/11/2021     Initial Implementation
**************************************************************************************/
@isTest
public with sharing class PACRPortalUserMessageController_Test {
    
/***********************************************************************************************************************************
    * Method  Name   : closeoutCloseoutinProgress
    * Description    :used to test the closeout request message
    * Author         : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------*/
  
    @isTest 
    public static void closeoutCloseoutinProgress() {        
    Incident__c incident = PA_TestHelper.getIncident(true);
    //Account Subrecipent create
    Account account = PA_TestHelper.getAccountSubrecipent(true);


    // closeout requested  Created ;    
    Closeout_Request__c closeoutRequest = new Closeout_Request__c();      
    closeoutRequest.Request_Date__c = System.today();
    closeoutRequest.Subrecipient__c = account.Id;
    closeoutRequest.Incident__c = incident.Id;
    closeoutRequest.Status__c = 'Closeout in Progress';
      
    upsert closeoutRequest;

    //PACRPortalUserMessageController.getMessage(closeoutRequest.Id);
    PACloseoutPoratalMessageController.getMessage(closeoutRequest.Id);
    
              
    }   
    
    /***********************************************************************************************************************************
    * Method  Name   : closeoutPendingSRClaim
    * Description    :used to test the closeout request message
    * Author         : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------*/
  
        @isTest 
        public static void closeoutPendingSRClaim() {        
        Incident__c incident = PA_TestHelper.getIncident(true);
        //Account Subrecipent create
        Account account = PA_TestHelper.getAccountSubrecipent(true);

        // closeout requested  Created ;    
        Closeout_Request__c closeoutRequest1 = new Closeout_Request__c();      
        closeoutRequest1.Request_Date__c = System.today();
        closeoutRequest1.Subrecipient__c = account.Id;
        closeoutRequest1.Incident__c = incident.Id;
        closeoutRequest1.Status__c = 'Pending SR Claim';
            
        upsert closeoutRequest1;
        //PACRPortalUserMessageController.getMessage(closeoutRequest1.Id);
        PACloseoutPoratalMessageController.getMessage(closeoutRequest1.Id);       
                
    }   

    /***********************************************************************************************************************************
    * Method  Name   : closeoutCloseoutRequestFinalized
    * Description    :used to test the closeout request message
    * Author         : Dayal
    * Created On   : 30/08/2021
    * Modification Log:  
   * --------------------------------------------------------------------------------------------------------------------------------------*/
  
    @isTest 
    public static void closeoutCloseoutRequestFinalized() {        
    Incident__c incident = PA_TestHelper.getIncident(true);
    //Account Subrecipent create
    Account account = PA_TestHelper.getAccountSubrecipent(true);

   
    // closeout requested  Created ;    
    Closeout_Request__c closeoutRequest2 = new Closeout_Request__c();      
    closeoutRequest2.Request_Date__c = System.today();
    closeoutRequest2.Subrecipient__c = account.Id;
    closeoutRequest2.Incident__c = incident.Id;
    closeoutRequest2.Status__c = 'Closeout Request Finalized';
        
    upsert closeoutRequest2;
    PACloseoutPoratalMessageController.getMessage(closeoutRequest2.Id);
            
  }   

}