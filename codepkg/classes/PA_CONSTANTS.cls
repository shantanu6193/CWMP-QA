/***********************************************************************************************************************************
* Class Name   : PA_CONSTANTS
* Description  : This class for declare the constants to the PA Program Type
* Author       : Dayal
* Created On   : 28/07/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Dayal             28/07/2021       Initial Implementation
**************************************************************************************************************************************/

public class PA_CONSTANTS {   
    public static final String PA_PROGRAM_FEDERAL= 'PA - Federal';
    public static final String PA_PROGRAM_CDAA= 'CDAA (State Funding)';
    public static final String PA_PROGRAM_FMAG= 'PA - FMAG';
    public static final String PA_PROJECT_NEW_STATUS= 'New';
    public static final String PA_PARENT_PROGRAM_NAME = 'Public Assistance';

    // if  closeout task status is less or equal to OES Review then then closeout task is show in Merge, Remove,Create time if it search
   
    public static Set<String> closeoutTaskStatus(){
        Set<String> statusValSet = new Set<String>{'OES Review','FEMA Workflow','PA Correspondence','Cost Share','Transmittals','FPU Workflow'};
        return statusValSet;
    }
       
}