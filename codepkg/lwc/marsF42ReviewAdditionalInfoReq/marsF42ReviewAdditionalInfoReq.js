import {
    LightningElement,
    track
} from 'lwc';
import getPendingInforF42 from "@salesforce/apex/MARS_F42ReviewCtrl.getAdditionalInfoRequiredF42";
import Utility from 'c/utility';

export default class MarsF42ReviewAdditionalInfoReq extends Utility {
    accountId;
    f42List = [];
    @track targetId;
    oldTargetId;
    @track showHideReviewDetails = false;
    @track visibleRecords;
    /*
     * Set value to the component if product is present
     */
    initData() {
        this.accountId = window.location.href.split('id=')[1].substring(0, 18);
        console.log('account id: ' + this.accountId)
        this.executeAction(getPendingInforF42, {
            accountId: this.accountId
        }, (result) => {
            console.log('result:' + result)
            this.f42List = result;
        });
    }
    handleShowReviewDetails(event) {
        this.targetId = event.target.dataset.id;
        this.showHideReviewDetails = false;
        if (this.oldTargetId !== this.targetId) {
            this.showHideReviewDetails = true;
            console.log('###: opening');
            this.oldTargetId = this.targetId;
        } else {
            this.oldTargetId = undefined;
        }
        console.log('###: oldTargetId: ' + JSON.stringify(this.oldTargetId))
        console.log('###: targetId: ' + JSON.stringify(this.targetId))
        console.log('###: event details: ' + JSON.stringify(this.targetId));
        console.log('###:  showHideReviewDetails: ' + JSON.stringify(this.showHideReviewDetails));
    }

    paginationHandler(event) {
        this.visibleRecords = event.detail.slicedRecords;
    }
}