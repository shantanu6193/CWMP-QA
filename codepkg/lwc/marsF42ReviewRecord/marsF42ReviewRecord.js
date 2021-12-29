import {
    LightningElement,
    api,
    track
} from 'lwc';
import Utility from 'c/utility';
import getIndividualF42 from "@salesforce/apex/MARS_F42ReviewCtrl.getIndividualF42";
import updateAgencyPrimaryUserComment from "@salesforce/apex/MARS_F42ReviewCtrl.updateAgencyPrimaryUserComment";

export default class MarsF42ReviewRecord extends Utility {
    f42RecordId;
    isInitExecuted = false;
    @track record = [];
    @track tmpRecord = [];
    @track accountRecord = [];
    @track newIncident = [];
    @track oldIncident = [];
    @track personnelRecords = [];
    @track actualHoursRecords = [];
    @track commentRecords = [];
    @track mutualStaffComment;
    @track primaryUserComment;
    @track imageUrl;
    @track f42Signature;
    documentId;
    // @track returnFromIncidentTimeVal;
    @track showICStitle = false;
    @track isCommentsVisible = false;
    overheadSelection = [];
    @track isButtonDisabled = true;

    get overheadTypeoptions() {
        return [{
                label: 'STEN',
                value: 'STEN'
            },
            {
                label: 'STEN(T)',
                value: 'STEN(T)'
            },
            {
                label: 'TFLD',
                value: 'TFLD'
            },
            {
                label: 'TFLD(T)',
                value: 'TFLD(T)'
            },
            {
                label: 'Overhead Position',
                value: 'Overhead Position'
            }
        ];
    }
    get vehicleOwnerTypeoptions() {
        return [{
                label: 'Agency',
                value: 'Agency'
            },
            {
                label: 'POV',
                value: 'POV'
            },
            {
                label: 'Rental',
                value: 'Rental'
            },
            {
                label: 'CDF/OES',
                value: 'CDF/OES'
            }
        ];
    }

    get vehicleTypeOptions() {
        return [{
                label: 'Sedan',
                value: 'Sedan'
            },
            {
                label: 'SUV',
                value: 'SUV'
            },
            {
                label: 'Van',
                value: 'Van'
            },
            {
                label: 'Pick-Up (1/2 Ton)',
                value: 'Pick-Up (1/2 Ton)'
            },
            {
                label: 'Other (3/4 Ton & Above)',
                value: 'Other (3/4 Ton & Above)'
            }
        ];
    }

    get payingAgencyoptions() {
        return [{
                label: 'CAL OES',
                value: 'CAL OES'
            },
            {
                label: 'CAL FIRE',
                value: 'CAL FIRE'
            },
            {
                label: 'USFS',
                value: 'USFS'
            },
            {
                label: 'BLM',
                value: 'BLM'
            },
            {
                label: 'NPS',
                value: 'NPS'
            },
            {
                label: 'BIA',
                value: 'BIA'
            },
            {
                label: 'FWS',
                value: 'FWS'
            },
            {
                label: 'LRA/MMA',
                value: 'LRA/MMA'
            }
        ];
    }

    @api get recordId() {
        return this.f42RecordId;
    }

    set recordId(value) {
        this.f42RecordId = value;
        console.log('***: setter')
        this.handleRecordIdChange();
    }

    handleRecordIdChange() {
        this.getF42Details();

    }

    getF42Details() {
        console.log('###: recordId: ' + JSON.stringify(this.f42RecordId));
        this.executeAction(getIndividualF42, {
            Id: this.f42RecordId
        }, (result) => {
            this.overheadSelection = '';
            this.tmpRecord = result.f42Rec;
            this.accountRecord = result.f42Rec.Account__r;
            console.log('overhead: ' + result.f42Rec.OH_OVERHEAD_TYPE__c)
            if (result.f42Rec.OH_OVERHEAD_TYPE__c) {
                this.overheadSelection = result.f42Rec.OH_OVERHEAD_TYPE__c.split(',');
                console.log('overhead selection: '+this.overheadSelection)
            }
            if (this.overheadSelection.includes('Overhead Position')) {
                this.showICStitle = true;
            } else {
                this.showICStitle = false;
            }
            if (result.f42Rec.DT_NEW_INCIDENT__r) {
                this.newIncident = result.f42Rec.DT_NEW_INCIDENT__r;
            }
            if (result.f42Rec.DF_OLD_INCIDENT__r) {
                this.oldIncident = result.f42Rec.DF_OLD_INCIDENT__r;
            }
            if (result.f42Rec.Status__c === 'AGENCY REVIEW') {
                this.isCommentsVisible = true;
                this.isButtonDisabled = false;
            } else {
                this.isCommentsVisible = false;
                this.isButtonDisabled = true;
            }
            this.personnelRecords = result.personnelInfoRecs;
            this.actualHoursRecords = result.actualHoursRecs;
            this.commentRecords = result.commentRecs;
            this.mutualStaffComment = result.mutualStaffComment;
            this.imageUrl = result.documentLink;
            this.f42Signature = result.f42DocumentLink;
            this.record = this.tmpRecord;
            console.log('###: record:' + JSON.stringify(this.record))
            console.log('###: record Id:' + JSON.stringify(this.record.Id))
            // var committedDate = new Date(this.record.DI_RETURN_FROM_INCIDENT__c).toISOString();
            // console.log('###: this.record.DI_RETURN_FROM_INCIDENT__c: ' + JSON.stringify(this.record.DI_RETURN_FROM_INCIDENT__c))
            // console.log('###: this.record.DI_RETURN_FROM_INCIDENT__c: ' + this.record.DI_RETURN_FROM_INCIDENT__c)
            // console.log('###: committedDate: ' + JSON.stringify(committedDate))
            // console.log('###: Timezone committedDate: ' + JSON.stringify(committedDate.getTimezoneOffset()))

            // if (committedDate && committedDate !== 'null') {
            //     this.returnFromIncidentTimeVal = committedDate.toString().split(" ")[4].substr(0, 5);
            //     console.log('###: this.record.returnFromIncidentTime: ' + JSON.stringify(this.returnFromIncidentTimeVal));
            // } else if (this.record.DI_RETURN_FROM_INCIDENT__c) {
            //     this.returnFromIncidentTimeVal = this.record.DI_RETURN_FROM_INCIDENT__c.toString().split(" ")[4].substr(0, 5);
            //     console.log('###: this.record.returnFromIncidentTime: ' + JSON.stringify(this.returnFromIncidentTimeVal));
            // }
            // console.log('###: this.record.returnFromIncidentTime: ' + JSON.stringify(this.record.returnFromIncidentTime));
            //console.log('###: record.DI_Committed_to_Incident_Date__c Time: ' + JSON.stringify(this.record.DI_Committed_to_Incident_Date__c).getTime())
            // console.log('###: record.DI_Committed_to_Incident_Date__c Date: ' + JSON.stringify(this.record.DI_Committed_to_Incident_Date__c.getDate()))
            console.log('###: record DI_REDISPATCHED__c:' + JSON.stringify(this.record.hasOwnProperty('DI_REDISPATCHED__c')))
            console.log('###: accountRecord: ' + JSON.stringify(this.record.Account__r))
            console.log('###: newIncident: ' + JSON.stringify(this.newIncident));
            console.log('###: oldIncident: ' + JSON.stringify(this.oldIncident));
            console.log('###: personnelRecords: ' + JSON.stringify(this.personnelRecords))
            console.log('###: actualHoursRecords: ' + JSON.stringify(this.actualHoursRecords));
            console.log('###: commentRecords: ' + JSON.stringify(this.commentRecords));
        });
    }

    initData() {}

    handleSubmit() {
        console.log('###: In Submit');
        if (!this.primaryUserComment) {
            this.showErrorNotification('LOCAL AGENCY PRIMARY USER COMMENTS is Required');
            return;
        }
        this.executeAction(updateAgencyPrimaryUserComment, {
            comment: this.primaryUserComment,
            f42Id: this.f42RecordId
        }, (result) => {
            console.log('###: result: ' + result)
            if (result === 'success') {
                this.showSuccessNotification('Comments Submitted Successfully.');
                this.getF42Details();
            } else {
                this.showErrorNotification('Failed to Submit Comments');
            }
        })
    }

    commentOnChange(event) {
        this.primaryUserComment = event.target.value;
        console.log('###: primaryUserComment: ' + this.primaryUserComment)
    }
}