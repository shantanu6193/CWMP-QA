/**
 * Created by Ricky on 15-04-2021.
 */

public without sharing class RecordLockUnlockClass {
    public void unlockRecord(List<Id> recordIds){ //Method to Unlock the Record...
        List<Approval.UnlockResult> unlockRecords = Approval.unlock(recordIds, false );
    }
    public void lockRecord(List<Id> recordIds){ //Method to lock the Record...
        List<Approval.LockResult> lockRecords = Approval.lock(recordIds, false );
    }
}