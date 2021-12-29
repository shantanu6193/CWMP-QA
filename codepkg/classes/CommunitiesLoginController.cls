/***********************************************************************************************************************************
* Class Name   : CommunitiesLoginController
* Description  : An apex page controller that exposes the site login functionality
* Author       : Pankaj
* Created On   : 04/05/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            04/05/2020       Initial Implementation
**************************************************************************************************************************************/

global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController () {}
    
    /***********************************************
    * Method Name : forwardToAuthPage
    * Author : Pankaj
    * Inputs : -
    * Description: This method will invoke on page load and return PageReference
    *********************************************/
    global PageReference forwardToAuthPage() {
    	String startUrl = System.currentPageReference().getParameters().get('startURL');
    	String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}