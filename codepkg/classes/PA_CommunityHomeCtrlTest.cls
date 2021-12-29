/***********************************************************************************************************************************
* Class Name   : PA_CommunityHomeCtrlTest
* Description  : This class used  for check the test cover of PA_CommunityHomeCtrlTest
* Author       : Dayal
* Created On   : 02-09-2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             02-09-2021       Initial Implementation
**************************************************************************************************************************************/
@isTest(SeeAllData=false)
public  class PA_CommunityHomeCtrlTest {

/****************************************************************************
* Method  Name   : testCustomMetaValReportUrl
* Description  : this method test the testCustomMetaValReportUrl 
* Author       : Dayal
* Created On   : 02-09-2021 
* Modification Log:  
* ----------------------------------------------------------------------------*/

    @isTest 
    public static void testCustomMetaValReportUrl(){

       Test.startTest();
       PA_CommunityHomeCtrl.customMetaValReportUrl();        
       Map<String, Object> getDatatwo = PA_CommunityHomeCtrl.getDatatwo();
       system.assert(getDatatwo.size() > 0);
       Test.stopTest();      
    }

}