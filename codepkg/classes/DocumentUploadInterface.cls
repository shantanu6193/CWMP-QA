/**
 * Created by StackNexus Admin on 08-10-2021.
 */

public interface DocumentUploadInterface {
    List<DocumentUploadCtrl.DocumentMetaInfoWrapper> executeAction(String masterRecordId, List<DocumentUploadCtrl.DocumentMetaInfoWrapper> docWrapperList);
    void executeDeleteAction(String docRecordId,String contentDocId);
    document__c executeEditAction(String docRecordId);
}