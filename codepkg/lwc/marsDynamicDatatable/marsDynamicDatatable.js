import {
    LightningElement,
    api,
    track
} from 'lwc';

export default class MarsDynamicDatatable extends LightningElement {
    @api column;
    @track columnList;
    @api objectname;
    @api isDisabled;
    @api rows;
    connectedCallback() {
        this.columnList = this.column;
        if (!this.rows) {
            this.rows = [{
                uuid: this.createUUID()
            }];
        }
    }
    createUUID() {
        console.log('I am in createUUID')
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    addRow() {
        console.log('I am in add row')
        this.rows.push({
            uuid: this.createUUID()
        });
        console.log('rows after push: ' + JSON.stringify(this.rows))
    }

    removeRow(event) {
        console.log('###: remove 1: ' + JSON.stringify(event.target.value))
        console.log('###: remove 2: ' + JSON.stringify(event.target.name))
        console.log('###: remove 3: ' + JSON.stringify(this.template.querySelectorAll('lightning-input')[event.detail.value]))
        console.log('###: length 4: ' + JSON.stringify(this.rows)[event.detail.value])
        console.log(this.rows.length > 1)
        console.log('### row: '+event.detail.row)

        if (this.rows.length > 1)
            this.rows.splice(event.target.value, 1);
    }
}