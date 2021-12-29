/***********************************************************************************************************************************
* Class Name   : SupportResourceTriggerHelper
* Description  : This is helper class for support resource trigger
* Author       : Pankaj
* Created On   : 05/13/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                05/13/2020       Initial Implementation
**************************************************************************************************************************************/

public class SupportResourceTriggerHelper extends TriggerHelper{
    
    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are inserted
    *********************************************/
    public override void processAfterInsert()  {
        publishEvent();
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated
    *********************************************/
    public override void processAfterUpdate() {
        publishEvent();
    }

    /***********************************************
    * Method Name : publishEvent
    * Author : Pankaj
    * Inputs : -
    * Description: This method publish the event
    *********************************************/
    private void publishEvent() {
        // Create an instance of the event and store it in the refreshEvent variable
        Update_Support_Resource__e refreshEvent = new Update_Support_Resource__e();
        // Call method to publish events
        Database.saveResult sr = EventBus.publish(refreshEvent);
        // Inspect publishing result
        if(sr.isSuccess()){
            System.debug('Successfully published event.');
        }
        else{
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                        err.getStatusCode() +
                        ' - ' +
                        err.getMessage());
            }
        }
    }
}