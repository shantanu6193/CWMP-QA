/***********************************************************************************************************************************
* Class Name   : CommunityLoginFlow
* Description  : This class for Community Login flow
* Author       : Pankaj
* Created On   : 07/15/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             07/15/2020       Initial Implementation
**************************************************************************************************************************************/

public class CommunityLoginFlow {

    /***********************************************
    * Method Name : FinishLoginFlowHome
    * Author : Pankaj
    * Inputs : -
    * Description: This method return page reference of hma community
    *********************************************/
    public PageReference FinishLoginFlowHome() {
        return Auth.SessionManagement.finishLoginFlow('/hma/s/');
    }
    
}