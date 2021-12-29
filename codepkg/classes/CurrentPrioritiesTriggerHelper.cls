/***********************************************************************************************************************************
* Class Name   : CurrentPrioritiesTriggerHelper
* Description  : This class for publish the Events
* Author       : Pankaj
* Created On   : 04/15/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             04/15/2020       Initial Implementation
**************************************************************************************************************************************/

public class CurrentPrioritiesTriggerHelper extends TriggerHelper{
    
    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call publishEvent method after the records are inserted
    *********************************************/
    public override void processAfterInsert()  {
    publishEvent();
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call publishEvent method after the records are updated
    *********************************************/
    public override void processAfterUpdate() {
    publishEvent();
    }

    /***********************************************
    * Method Name : publishEvent
    * Author : Pankaj
    * Inputs : -
    * Description: This method publish the events
    *********************************************/
    private void publishEvent() {
            // Create an instance of the event and store it in the newsEvent variable
            Update_Current_Priority__e refreshEvent = new Update_Current_Priority__e();
            // Call method to publish events
            Database.SaveResult sr = EventBus.publish(refreshEvent);
            // Inspect publishing result 
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }
    }
}