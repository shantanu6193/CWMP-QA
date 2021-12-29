/**
 * Created by nehab on 14-10-2020.
 */

public with sharing class CustomDocumentTriggerHelper extends TriggerHelper{

    public override void processAfterUpdate() {
        publishEvent();
    }
    private void publishEvent() {
        // Create an instance of the event and store it in the newsEvent variable
        Update_Document_Detail__e refreshEvent = new Update_Document_Detail__e();
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