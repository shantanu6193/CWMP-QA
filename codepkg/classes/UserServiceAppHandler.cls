/***********************************************************************************************************************************
* Interface Name   : UserServiceAppHandler
* Description      : This is an interface to User Service App for approval or reject
* Author           : Pankaj
* Created On       : 07/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                07/09/2020       Initial Implementation
**************************************************************************************************************************************/

public interface UserServiceAppHandler {
    void handleApprove(List<User_Registration__c> userRegistrations);
    void handleReject(List<User_Registration__c> userRegistrations);

}